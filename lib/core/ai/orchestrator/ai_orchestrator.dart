import 'dart:async';
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:tag/core/ai/cactus/cactus_model_registry.dart';
import 'package:tag/core/ai/cactus/cactus_model_service.dart';
import 'package:tag/core/ai/prompts/cactus_prompt_templates.dart';
import 'package:tag/core/ai/schemas/card_proposal_schema.dart';
import 'package:tag/core/ai/schemas/extraction_result_schema.dart';
import 'package:tag/core/ai/schemas/intention_result_schema.dart';
import 'package:tag/core/ai/validation/ai_json_validator.dart';
import 'package:tag/core/ai/validation/ai_schema_validation_exception.dart';
import 'package:tag/core/error/app_error.dart';
import 'package:tag/core/platform/local_text_recognition_service.dart';
import 'package:tag/features/source_ingestion/domain/entities/source_item_entity.dart';

class AiOrchestrator {
  AiOrchestrator({
    required CactusModelService cactusModelService,
    AiJsonValidator jsonValidator = const AiJsonValidator(),
    LocalTextRecognitionService? localTextRecognitionService,
    DateTime Function()? now,
    Future<String> Function()? modelSlugProvider,
    String? fallbackModelSlug,
    this.invalidOutputRetries = 1,
    Duration completionTimeout = const Duration(seconds: 75),
  }) : _cactusModelService = cactusModelService,
       _jsonValidator = jsonValidator,
       _localTextRecognitionService = localTextRecognitionService,
       _now = now ?? DateTime.now,
       _modelSlugProvider = modelSlugProvider,
       _fallbackModelSlug =
           fallbackModelSlug ?? CactusModelRegistry.defaultPrimaryModelSlug,
       _completionTimeout = completionTimeout;

  static const double cardCreationConfidenceThreshold = 0.60;

  final CactusModelService _cactusModelService;
  final AiJsonValidator _jsonValidator;
  final LocalTextRecognitionService? _localTextRecognitionService;
  final DateTime Function() _now;
  final Future<String> Function()? _modelSlugProvider;
  final String _fallbackModelSlug;
  final Duration _completionTimeout;
  final int invalidOutputRetries;

  Future<String> resolveModelSlug() async {
    final provided = await _modelSlugProvider?.call();
    final slug = provided?.trim();
    if (slug == null || slug.isEmpty) {
      return _fallbackModelSlug;
    }

    return CactusModelRegistry.primaryModelConfigForSlug(slug).modelSlug;
  }

  Future<ExtractionResult> extractSourceContent(
    SourceItemEntity source, {
    String? modelSlug,
  }) async {
    final activeModelSlug = modelSlug ?? await resolveModelSlug();
    final isImage = _isImageSource(source);
    await _ensureModelAvailable(
      modelSlug: activeModelSlug,
      requiresVision: isImage,
    );

    final textSource = isImage ? null : _withTextPayload(source);
    final imagePath = isImage ? await _requiredImagePath(source) : null;
    final recognizedText = isImage && imagePath != null
        ? await _recognizeImageText(imagePath)
        : null;
    final messages = [
      const AiChatMessage(
        role: 'system',
        content: CactusPromptTemplates.extractionSystemPrompt,
      ),
      AiChatMessage(
        role: 'user',
        content: isImage
            ? CactusPromptTemplates.extractionUserPromptForImage(
                source,
                recognizedText: _recognizedTextForPrompt(recognizedText),
              )
            : CactusPromptTemplates.extractionUserPromptForText(textSource!),
      ),
    ];

    final extraction = await _completeValidated<ExtractionResult>(
      taskLabel: 'extraction',
      messages: messages,
      imagePath: imagePath,
      decoder: ExtractionResult.fromJson,
      modelSlug: activeModelSlug,
      fallbackFromInvalidOutput: isImage
          ? (rawOutput) => _extractionFromPlainText(
              rawOutput,
              recognizedText: recognizedText,
            )
          : (rawOutput) => _extractionFromPlainText(
              rawOutput,
              sourceText: textSource!.rawText,
            ),
      options: const AiCompletionOptions(
        temperature: 0.1,
        maxTokens: 700,
        localOnly: true,
      ),
    );

    final normalizedExtraction = extraction.copyWith(
      dates: _normalizeDates(extraction.dates),
      times: _normalizeTimes(extraction.times),
    );

    if (!isImage) {
      return _preserveLocalTextExtraction(
        normalizedExtraction,
        sourceText: textSource!.rawText!,
      );
    }

    return normalizedExtraction;
  }

  Future<IntentionResult> detectIntention({
    required SourceItemEntity source,
    required ExtractionResult extraction,
    String? modelSlug,
  }) async {
    final activeModelSlug = modelSlug ?? await resolveModelSlug();
    final localIntention = _localActionableIntention(
      source: source,
      extraction: extraction,
      allowTimelessPurchase: false,
    );
    if (localIntention != null) {
      return _withCardCreationThreshold(localIntention);
    }

    await _ensureModelAvailable(
      modelSlug: activeModelSlug,
      requiresVision: false,
    );

    final messages = [
      const AiChatMessage(
        role: 'system',
        content: CactusPromptTemplates.intentionSystemPrompt,
      ),
      AiChatMessage(
        role: 'user',
        content: CactusPromptTemplates.intentionUserPrompt(
          source: source,
          extractionJson: extraction.toJson(),
          now: _now().toLocal(),
        ),
      ),
    ];

    final intention = await _completeValidated<IntentionResult>(
      taskLabel: 'intention',
      messages: messages,
      decoder: IntentionResult.fromJson,
      modelSlug: activeModelSlug,
      fallbackFromInvalidOutput: (_) =>
          _intentionFromLocalEvidence(source: source, extraction: extraction),
      options: const AiCompletionOptions(
        temperature: 0.1,
        maxTokens: 650,
        localOnly: true,
      ),
    );

    return _withCardCreationThreshold(
      _withLocalActionableFallback(
        source: source,
        extraction: extraction,
        intention: intention,
      ),
    );
  }

  bool shouldCreateCard(CardProposal proposal) {
    return proposal.cardType != 'passive' &&
        proposal.confidence >= cardCreationConfidenceThreshold;
  }

  CardProposal buildCardProposal({
    required SourceItemEntity source,
    required IntentionResult intention,
  }) {
    return CardProposal.fromIntention(
      intention: intention,
      sourceId: source.id,
    );
  }

  Future<T> _completeValidated<T>({
    required String taskLabel,
    required List<AiChatMessage> messages,
    required AiJsonDecoder<T> decoder,
    required AiCompletionOptions options,
    required String modelSlug,
    T Function(String rawOutput)? fallbackFromInvalidOutput,
    String? imagePath,
  }) async {
    var attemptMessages = messages;
    AiSchemaValidationException? lastValidationError;
    T? fallbackCandidate;
    var hasFallbackCandidate = false;

    for (var attempt = 0; attempt <= invalidOutputRetries; attempt++) {
      final AiCompletionResult result;
      try {
        result = await _complete(
          modelSlug: modelSlug,
          messages: attemptMessages,
          options: options,
          imagePath: imagePath,
        ).timeout(_completionTimeout);
      } on TimeoutException catch (error) {
        if (fallbackFromInvalidOutput != null) {
          try {
            return fallbackFromInvalidOutput('');
          } on AiSchemaValidationException {
            // Surface a timeout when the local fallback has no usable text.
          }
        }
        throw AppError(
          'Local $taskLabel took too long. Tag kept the source and will retry '
          'or fall back to local text when available.',
          cause: error,
        );
      }

      try {
        return _jsonValidator.parseObject<T>(
          rawOutput: result.response,
          decoder: decoder,
        );
      } on AiSchemaValidationException catch (error) {
        lastValidationError = error;
        if (fallbackFromInvalidOutput != null) {
          try {
            fallbackCandidate = fallbackFromInvalidOutput(result.response);
            hasFallbackCandidate = true;
          } on AiSchemaValidationException {
            // Keep the stricter schema error unless an image fallback succeeds.
          }
        }
        if (attempt == invalidOutputRetries) {
          break;
        }

        attemptMessages = [
          ...attemptMessages,
          AiChatMessage(role: 'assistant', content: result.response),
          AiChatMessage(
            role: 'user',
            content: CactusPromptTemplates.retryPrompt(error.message),
          ),
        ];
      }
    }

    if (hasFallbackCandidate) {
      return fallbackCandidate as T;
    }

    throw AiSchemaValidationException(
      'Local $taskLabel JSON validation failed: '
      '${lastValidationError?.message ?? 'unknown schema error'}.',
    );
  }

  Future<AiCompletionResult> _complete({
    required String modelSlug,
    required List<AiChatMessage> messages,
    required AiCompletionOptions options,
    String? imagePath,
  }) {
    if (imagePath != null) {
      return _cactusModelService.completeWithImage(
        modelSlug: modelSlug,
        imagePath: imagePath,
        messages: messages,
        options: options,
      );
    }

    return _cactusModelService.complete(
      modelSlug: modelSlug,
      messages: messages,
      options: options,
    );
  }

  Future<void> _ensureModelAvailable({
    required String modelSlug,
    required bool requiresVision,
  }) async {
    final availableModels = await _cactusModelService.getAvailableModels();
    final model = _modelBySlug(availableModels, modelSlug);

    if (model == null) {
      throw AppError(
        'Local model $modelSlug is unavailable. Open Model setup and prepare '
        'a local card model before processing sources.',
      );
    }

    final requiredCapabilities = {
      AiModelCapability.completion,
      if (requiresVision) AiModelCapability.vision,
    };
    final missingCapabilities = requiredCapabilities
        .where((capability) => !model.supports(capability))
        .toList(growable: false);

    if (missingCapabilities.isNotEmpty) {
      final missing = missingCapabilities
          .map((capability) => capability.storageValue)
          .join(', ');
      throw AppError('Local model $modelSlug is missing: $missing.');
    }

    if (!model.isDownloaded && !model.isInitialized) {
      throw AppError(
        'Local model $modelSlug is not ready on this device. Open Model setup '
        'and download the local model before processing sources.',
      );
    }
  }

  LocalAiModelInfo? _modelBySlug(List<LocalAiModelInfo> models, String slug) {
    for (final model in models) {
      if (model.slug == slug) {
        return model;
      }
    }

    return null;
  }

  SourceItemEntity _withTextPayload(SourceItemEntity source) {
    final text = source.rawText?.trim().isNotEmpty == true
        ? source.rawText!.trim()
        : source.extractedText?.trim().isNotEmpty == true
        ? source.extractedText!.trim()
        : source.originalUri?.trim();

    if (text == null || text.isEmpty) {
      throw AppError('Source ${source.id} has no local text to extract.');
    }

    return source.copyWith(rawText: text);
  }

  Future<String> _requiredImagePath(SourceItemEntity source) async {
    final path = source.localFilePath?.trim();
    if (path == null || path.isEmpty) {
      throw AppError('Source ${source.id} has no local image file.');
    }

    if (await File(path).exists()) {
      return path;
    }

    final repairedPath = await _repairedAppDocumentsPath(path);
    if (repairedPath != null && await File(repairedPath).exists()) {
      return repairedPath;
    }

    throw AppError('Source ${source.id} local image file is missing.');
  }

  Future<String?> _repairedAppDocumentsPath(String storedPath) async {
    final marker = '${p.separator}Documents${p.separator}';
    final markerIndex = storedPath.indexOf(marker);
    if (markerIndex < 0) {
      return null;
    }

    final relativePath = storedPath.substring(markerIndex + marker.length);
    if (relativePath.trim().isEmpty) {
      return null;
    }

    final documentsDirectory = await getApplicationDocumentsDirectory();
    return p.joinAll([documentsDirectory.path, ...p.split(relativePath)]);
  }

  Future<LocalRecognizedText?> _recognizeImageText(String imagePath) async {
    final service = _localTextRecognitionService;
    if (service == null) {
      return null;
    }

    final recognizedText = await service.recognizeTextFromImage(imagePath);
    if (recognizedText.isEmpty) {
      return null;
    }

    return recognizedText;
  }

  String? _recognizedTextForPrompt(LocalRecognizedText? recognizedText) {
    final text = recognizedText?.text.trim();
    if (text == null || text.isEmpty) {
      return null;
    }

    if (text.length <= 2400) {
      return text;
    }

    return '${text.substring(0, 2400).trim()}...';
  }

  bool _isImageSource(SourceItemEntity source) {
    return switch (source.type) {
      SourceItemType.image || SourceItemType.screenshot => true,
      _ => false,
    };
  }

  List<String> _normalizeDates(List<String> rawDates) {
    return rawDates
        .map(_normalizeDate)
        .where((date) => date.isNotEmpty)
        .toSet()
        .toList(growable: false);
  }

  List<String> _normalizeTimes(List<String> rawTimes) {
    return rawTimes
        .map(_normalizeTime)
        .where((time) => time.isNotEmpty)
        .toSet()
        .toList(growable: false);
  }

  String _normalizeDate(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || _isUnknownEvidenceValue(trimmed)) {
      return '';
    }

    final parsed = DateTime.tryParse(trimmed);
    if (parsed != null) {
      return _dateOnly(parsed);
    }

    for (final format in _dateFormats) {
      try {
        return _dateOnly(format.parseStrict(trimmed));
      } on FormatException {
        continue;
      }
    }

    return trimmed;
  }

  String _normalizeTime(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || _isUnknownEvidenceValue(trimmed)) {
      return '';
    }

    final twentyFourHourMatch = RegExp(
      r'^([01]?\d|2[0-3]):([0-5]\d)$',
    ).firstMatch(trimmed);
    if (twentyFourHourMatch != null) {
      final hour = int.parse(twentyFourHourMatch.group(1)!);
      final minute = int.parse(twentyFourHourMatch.group(2)!);
      return _timeOnly(hour, minute);
    }

    final meridiemMatch = RegExp(
      r'^(\d{1,2})(?::([0-5]\d))?\s*([aApP][mM])$',
    ).firstMatch(trimmed);
    if (meridiemMatch == null) {
      return trimmed;
    }

    var hour = int.parse(meridiemMatch.group(1)!);
    final minute = int.tryParse(meridiemMatch.group(2) ?? '0') ?? 0;
    final meridiem = meridiemMatch.group(3)!.toLowerCase();

    if (hour < 1 || hour > 12) {
      return trimmed;
    }
    if (meridiem == 'am' && hour == 12) {
      hour = 0;
    } else if (meridiem == 'pm' && hour < 12) {
      hour += 12;
    }

    return _timeOnly(hour, minute);
  }

  IntentionResult _withLocalActionableFallback({
    required SourceItemEntity source,
    required ExtractionResult extraction,
    required IntentionResult intention,
  }) {
    if (intention.suggestedCardType != 'passive' ||
        intention.intentionType != 'remember') {
      return intention;
    }

    return _localActionableIntention(source: source, extraction: extraction) ??
        intention;
  }

  IntentionResult? _localActionableIntention({
    required SourceItemEntity source,
    required ExtractionResult extraction,
    bool allowTimelessPurchase = true,
  }) {
    final text = extraction.text.trim();
    if (_hasCourseApplicationDeadline(text)) {
      final evidence = _evidenceSnippet(text);
      final title = _courseApplicationTitleFromText(text);

      return IntentionResult(
        intentionType: 'apply',
        confidence: extraction.confidence.clamp(0.7, 0.9).toDouble(),
        title: title,
        reason:
            'The saved source shows an application deadline for a learning cohort.',
        nextActiveDeadline: _courseApplicationDeadlineFromText(text),
        suggestedCardType: 'urgent',
        spaceSuggestion: _courseApplicationSpaceFromText(text),
        sourceSummary: title,
        evidenceSummary: 'The source text says: $evidence',
      );
    }

    if (_hasAiLearningResource(text)) {
      final evidence = _evidenceSnippet(text);
      final title = _aiLearningTitleFromText(text);

      return IntentionResult(
        intentionType: 'learn',
        confidence: extraction.confidence.clamp(0.64, 0.84).toDouble(),
        title: title,
        reason:
            'The saved source looks like part of an AI systems learning thread.',
        nextActiveDeadline: null,
        suggestedCardType: 'suggestion',
        spaceSuggestion: 'Learning',
        sourceSummary: title,
        evidenceSummary: 'The source text says: $evidence',
      );
    }

    if (_hasSavedReadingArticle(text)) {
      final evidence = _evidenceSnippet(text);
      final title = _savedReadingTitleFromText(text);

      return IntentionResult(
        intentionType: 'read',
        confidence: extraction.confidence.clamp(0.62, 0.86).toDouble(),
        title: title,
        reason: 'The saved source is an article that appears worth reading.',
        nextActiveDeadline: null,
        suggestedCardType: 'goal',
        spaceSuggestion: _savedReadingSpaceFromText(text),
        sourceSummary: title,
        evidenceSummary: 'The source text says: $evidence',
      );
    }

    if (_hasApplicationOpportunity(text)) {
      final role = _applicationRoleFromText(text);
      final company = _applicationCompanyFromText(text);
      final title = role == null
          ? 'Review job application'
          : company == null
          ? 'Apply for $role'
          : 'Apply to $company: $role';
      final evidence = _evidenceSnippet(text);

      return IntentionResult(
        intentionType: 'apply',
        confidence: extraction.confidence.clamp(0.6, 0.88).toDouble(),
        title: title,
        reason:
            'The saved source appears to show a job application opportunity.',
        nextActiveDeadline: null,
        suggestedCardType: 'goal',
        spaceSuggestion: 'Career',
        sourceSummary: role ?? 'Job application source',
        evidenceSummary: 'The source text says: $evidence',
      );
    }

    if (_hasEventInvitationAction(text)) {
      final title = _eventTitleFromText(text);
      final deadline = _futureDeadlineFromEventEvidence(text);
      final evidence = _evidenceSnippet(text);

      return IntentionResult(
        intentionType: deadline == null ? 'decide' : 'attend',
        confidence: extraction.confidence.clamp(0.6, 0.88).toDouble(),
        title: title == null
            ? 'Review saved invitation'
            : deadline == null
            ? 'Review $title invitation'
            : 'RSVP to $title',
        reason: deadline == null
            ? 'The saved source shows an invitation or RSVP prompt, but no future event time is confirmed.'
            : 'The saved source shows an invitation with RSVP options and a future event time.',
        nextActiveDeadline: deadline,
        suggestedCardType: deadline == null ? 'suggestion' : 'urgent',
        spaceSuggestion: 'Schedule',
        sourceSummary: title == null ? 'Saved invitation' : '$title invitation',
        evidenceSummary: 'The source text says: $evidence',
      );
    }

    if (_hasStreakCompletionAction(text)) {
      final title = _streakCompletionTitleFromText(text);
      final evidence = _evidenceSnippet(text);

      return IntentionResult(
        intentionType: 'complete',
        confidence: extraction.confidence.clamp(0.68, 0.9).toDouble(),
        title: title,
        reason:
            'The saved source shows an active streak that needs same-day action.',
        nextActiveDeadline: _endOfTodayDeadline(),
        suggestedCardType: 'urgent',
        spaceSuggestion: _streakSpaceFromText(text),
        sourceSummary: title,
        evidenceSummary: 'The source text says: $evidence',
      );
    }

    if (_hasVerificationCodeAction(text)) {
      final serviceName = _accountServiceFromText(text);
      final code = _verificationCodeFromText(text);
      final evidence = _evidenceSnippet(text);

      return IntentionResult(
        intentionType: 'follow_up',
        confidence: extraction.confidence.clamp(0.6, 0.86).toDouble(),
        title: serviceName == null
            ? 'Use saved sign-in code'
            : 'Use $serviceName sign-in code',
        reason: code == null
            ? 'The saved source contains a sign-in or verification code.'
            : 'The saved source contains sign-in code $code.',
        nextActiveDeadline: null,
        suggestedCardType: 'suggestion',
        spaceSuggestion: 'Accounts',
        sourceSummary: serviceName == null
            ? 'Sign-in code'
            : '$serviceName sign-in code',
        evidenceSummary: 'The source text says: $evidence',
      );
    }

    if (_hasAccountSecurityAlert(text)) {
      final serviceName = _accountServiceFromText(text);
      final evidence = _evidenceSnippet(text);
      final serviceLabel = serviceName == null
          ? 'account'
          : '$serviceName account';

      return IntentionResult(
        intentionType: 'decide',
        confidence: extraction.confidence.clamp(0.6, 0.88).toDouble(),
        title: 'Review $serviceLabel activity',
        reason:
            'The saved source shows a security alert for account activity that may need review.',
        nextActiveDeadline: null,
        suggestedCardType: 'suggestion',
        spaceSuggestion: 'Security',
        sourceSummary: serviceName == null
            ? 'Account security alert'
            : '$serviceName security alert',
        evidenceSummary: 'The source text says: $evidence',
      );
    }

    if (_hasDocumentReviewAction(text)) {
      final title = _documentReviewTitleFromText(text);
      final evidence = _evidenceSnippet(text);

      return IntentionResult(
        intentionType: 'read',
        confidence: extraction.confidence.clamp(0.58, 0.84).toDouble(),
        title: 'Review $title',
        reason: 'The saved source appears to be a document worth reviewing.',
        nextActiveDeadline: null,
        suggestedCardType: 'suggestion',
        spaceSuggestion: _documentSpaceFromText(text),
        sourceSummary: title,
        evidenceSummary: 'The source text says: $evidence',
      );
    }

    if (_hasCallOrFeedbackRequestAction(text)) {
      final title = _callOrFeedbackTitleFromText(text);
      final deadline = _callOrFeedbackDeadlineFromText(text);
      final evidence = _evidenceSnippet(text);

      return IntentionResult(
        intentionType: 'follow_up',
        confidence: extraction.confidence.clamp(0.62, 0.86).toDouble(),
        title: title,
        reason: 'The saved source asks to arrange a call or provide feedback.',
        nextActiveDeadline: deadline,
        suggestedCardType: deadline == null ? 'suggestion' : 'urgent',
        spaceSuggestion: _callOrFeedbackSpaceFromText(text),
        sourceSummary: title,
        evidenceSummary: 'The source text says: $evidence',
      );
    }

    final purchaseLike = _hasPurchaseAction(text);
    if (purchaseLike) {
      final deadline = _deadlineFromEvidence(
        text: text,
        extraction: extraction,
      );
      if (deadline != null || allowTimelessPurchase) {
        final item = _purchaseItemFromText(text);
        final title = item == null ? 'Buy saved item' : 'Buy $item';
        final evidence = _evidenceSnippet(text);

        return IntentionResult(
          intentionType: 'buy',
          confidence: extraction.confidence.clamp(0.65, 0.9).toDouble(),
          title: title,
          reason: 'The saved source asks you to buy ${item ?? 'an item'}.',
          nextActiveDeadline: deadline,
          suggestedCardType: deadline == null ? 'suggestion' : 'urgent',
          spaceSuggestion: 'Errands',
          sourceSummary: source.sourceSummary?.trim().isNotEmpty == true
              ? source.sourceSummary!.trim()
              : title,
          evidenceSummary: 'The source text says: $evidence',
        );
      }

      return null;
    }

    if (_hasDirectRequestAction(text)) {
      final title = _directRequestTitleFromText(text);
      final deadline = _deadlineFromEvidence(
        text: text,
        extraction: extraction,
      );
      final evidence = _evidenceSnippet(text);

      return IntentionResult(
        intentionType: _directRequestIntentionType(text),
        confidence: extraction.confidence.clamp(0.62, 0.84).toDouble(),
        title: title,
        reason: 'The saved source contains a direct request to act on.',
        nextActiveDeadline: deadline,
        suggestedCardType: deadline == null ? 'suggestion' : 'urgent',
        spaceSuggestion: _directRequestSpaceFromText(text),
        sourceSummary: title,
        evidenceSummary: 'The source text says: $evidence',
      );
    }

    return null;
  }

  IntentionResult _intentionFromLocalEvidence({
    required SourceItemEntity source,
    required ExtractionResult extraction,
  }) {
    return _localActionableIntention(source: source, extraction: extraction) ??
        _passiveIntentionFromEvidence(extraction);
  }

  IntentionResult _passiveIntentionFromEvidence(ExtractionResult extraction) {
    final evidence = _evidenceSnippet(extraction.text);
    return IntentionResult(
      intentionType: 'remember',
      confidence: extraction.confidence.clamp(0.4, 0.75).toDouble(),
      title: 'Review saved source',
      reason: 'Tag found source evidence worth reviewing.',
      nextActiveDeadline: null,
      suggestedCardType: 'passive',
      spaceSuggestion: 'General',
      sourceSummary: 'Saved source',
      evidenceSummary: 'The source text says: $evidence',
    );
  }

  IntentionResult _withCardCreationThreshold(IntentionResult intention) {
    if (intention.suggestedCardType == 'passive' ||
        intention.confidence >= cardCreationConfidenceThreshold) {
      return intention;
    }

    return IntentionResult(
      intentionType: 'remember',
      confidence: intention.confidence,
      title: 'Review saved source',
      reason:
          'Tag did not detect enough source-backed confidence to create a card automatically.',
      nextActiveDeadline: null,
      suggestedCardType: 'passive',
      spaceSuggestion: intention.spaceSuggestion,
      sourceSummary: intention.sourceSummary,
      evidenceSummary: intention.evidenceSummary,
    );
  }

  bool _hasPurchaseAction(String text) {
    final normalized = text.toLowerCase();
    return RegExp(r'\b(buy|purchase|order|pick up)\b').hasMatch(normalized) ||
        _hasGetErrandItem(normalized);
  }

  bool _hasApplicationOpportunity(String text) {
    final normalized = text.toLowerCase();
    final hasApplicationWord = RegExp(
      r'\b(apply|application|job|role|position|opportunity|hiring)\b',
    ).hasMatch(normalized);
    final hasEmploymentSignal = RegExp(
      r'\b(full[- ]time|part[- ]time|remote|hybrid|onsite|salary|recruiter|hiring)\b',
    ).hasMatch(normalized);
    final hasRoleSignal = RegExp(
      r'\b(engineer|developer|designer|manager|analyst|scientist|specialist|lead|director|architect)\b',
    ).hasMatch(normalized);

    return hasApplicationWord || (hasEmploymentSignal && hasRoleSignal);
  }

  bool _hasCourseApplicationDeadline(String text) {
    final normalized = text.toLowerCase();
    final hasApplicationSignal =
        normalized.contains('application') ||
        normalized.contains('apply now') ||
        normalized.contains('final reminder');
    final hasLearningSignal = RegExp(
      r'\b(cohort|course|bootcamp|ai saturdays|tri ai|foundations|learning|training)\b',
    ).hasMatch(normalized);
    final hasDeadline = _courseApplicationDeadlineFromText(text) != null;

    return hasApplicationSignal && hasLearningSignal && hasDeadline;
  }

  String _courseApplicationTitleFromText(String text) {
    final normalized = text.toLowerCase();
    if (normalized.contains('ai saturdays') || normalized.contains('tri ai')) {
      return 'Complete TRI AI Saturdays Cohort 10 application';
    }

    return 'Submit learning application';
  }

  String _courseApplicationSpaceFromText(String text) {
    final normalized = text.toLowerCase();
    if (normalized.contains('ai saturdays') || normalized.contains('tri ai')) {
      return 'AI Saturdays';
    }

    return 'Learning';
  }

  String? _courseApplicationDeadlineFromText(String text) {
    final monthDayPattern = RegExp(
      r'\b([A-Za-z]{3,9})\s+(\d{1,2})(?:st|nd|rd|th)?(?:,?\s+(\d{4}))?',
      caseSensitive: false,
    );

    for (final match in monthDayPattern.allMatches(text)) {
      final date = _parseMonthDay(
        monthName: match.group(1),
        dayText: match.group(2),
        yearText: match.group(3),
      );
      if (date == null) {
        continue;
      }

      final localNow = _now().toLocal();
      final deadline = DateTime(date.year, date.month, date.day, 23, 59);
      if (deadline.isBefore(localNow)) {
        continue;
      }

      return _isoWithLocalOffset(deadline);
    }

    final relativeDaysMatch = RegExp(
      r'\bonly\s+(\d{1,2})\s+days?\s+left\b',
      caseSensitive: false,
    ).firstMatch(text);
    final relativeDays = int.tryParse(relativeDaysMatch?.group(1) ?? '');
    if (relativeDays == null) {
      return null;
    }

    final localNow = _now().toLocal();
    final date = localNow.add(Duration(days: relativeDays));
    return _isoWithLocalOffset(
      DateTime(date.year, date.month, date.day, 23, 59),
    );
  }

  bool _hasAiLearningResource(String text) {
    final normalized = text.toLowerCase();
    final hasAiTopic = RegExp(
      r'\b(llm|large language model|attention|tokenization|inference|q,\s*k,\s*v|query\(q\)|key\(k\)|value\(v\)|gpu fleets?|adaptive ml|ai systems?|ml systems?)\b',
    ).hasMatch(normalized);
    final hasLearningShape = RegExp(
      r'\b(learn|internals?|step by step|math behind|paper|blog|article|systems context|optimization|inference at scale|data pipelines?)\b',
    ).hasMatch(normalized);
    final explicitApplication = RegExp(
      r'\b(apply now|application|applications?\s+close|recruiter|opportunity)\b',
    ).hasMatch(normalized);

    return hasAiTopic && hasLearningShape && !explicitApplication;
  }

  String _aiLearningTitleFromText(String text) {
    final normalized = text.toLowerCase();
    if (normalized.contains('attention') ||
        normalized.contains('q, k, v') ||
        normalized.contains('query(q)')) {
      return 'Goal detected: Study attention math';
    }
    if (normalized.contains('tokenization') ||
        normalized.contains('internals')) {
      return 'Goal detected: Learn LLM internals';
    }
    if (normalized.contains('inference')) {
      return 'Goal detected: Study LLM inference systems';
    }

    return 'Goal detected: Learn AI systems';
  }

  bool _hasSavedReadingArticle(String text) {
    final normalized = text.toLowerCase();
    final hasReadingSurface = RegExp(
      r'\b(medium|daily digest|article|blog|story|stories for)\b',
    ).hasMatch(normalized);
    final hasUsefulTopic = RegExp(
      r'\b(system|systems|engineering|javascript|tracking|architecture|database|backend|frontend|concurrent|sub[- ]?100ms)\b',
    ).hasMatch(normalized);
    final explicitApplication = RegExp(
      r'\b(apply now|application|applications?\s+close|recruiter|opportunity|hiring)\b',
    ).hasMatch(normalized);

    return hasReadingSurface && hasUsefulTopic && !explicitApplication;
  }

  String _savedReadingTitleFromText(String text) {
    final lines = _meaningfulLines(text);
    for (final line in lines) {
      final lower = line.toLowerCase();
      if (!lower.contains('uber') && !lower.contains('tracking system')) {
        continue;
      }

      return 'Read ${_cleanReadingTitle(line)}';
    }

    return 'Read saved engineering article';
  }

  String _cleanReadingTitle(String value) {
    final cleaned = value
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'\s*\|\s*$'), '')
        .trim();
    if (cleaned.length <= 72) {
      return cleaned;
    }

    return '${cleaned.substring(0, 69).trim()}...';
  }

  String _savedReadingSpaceFromText(String text) {
    final normalized = text.toLowerCase();
    if (RegExp(
      r'\b(engineering|javascript|system|architecture|backend|frontend|concurrent|sub[- ]?100ms)\b',
    ).hasMatch(normalized)) {
      return 'Engineering Articles';
    }

    return 'Read Later';
  }

  bool _hasEventInvitationAction(String text) {
    final normalized = text.toLowerCase();
    final hasInvitationSignal = RegExp(
      r'\b(invitation|rsvp|calendar|organiser|organizer|event)\b',
    ).hasMatch(normalized);
    final hasResponseSignal = RegExp(
      r'\b(yes|no|maybe|reply all|directions)\b',
    ).hasMatch(normalized);
    final hasTimeSignal = RegExp(
      r'\b(today|tomorrow|mon|tue|wed|thu|fri|sat|sun|\d{1,2}:\d{2}\s*(?:am|pm)?)\b',
    ).hasMatch(normalized);

    return hasInvitationSignal && (hasResponseSignal || hasTimeSignal);
  }

  bool _hasStreakCompletionAction(String text) {
    final normalized = text.toLowerCase();
    final hasStreakSignal = RegExp(r'\bstreak\b').hasMatch(normalized);
    final hasActionSignal = RegExp(
      r"\b(keep|complete|continue|maintain|save|alive|don't lose|do not lose)\b",
    ).hasMatch(normalized);

    return hasStreakSignal && hasActionSignal;
  }

  bool _hasAccountSecurityAlert(String text) {
    final normalized = text.toLowerCase();
    final hasAccountSignal = RegExp(
      r'\b(account|signed in|sign[- ]?in|new device|device activity)\b',
    ).hasMatch(normalized);
    final hasSecuritySignal = RegExp(
      r'\b(new device|someone else|not you|review recent device activity|location may not be exact|using your account)\b',
    ).hasMatch(normalized);

    return hasAccountSignal && hasSecuritySignal;
  }

  bool _hasVerificationCodeAction(String text) {
    return RegExp(
      r'\b(sign[- ]?in code|verification code|enter this code|code will expire|one[- ]time code)\b',
      caseSensitive: false,
    ).hasMatch(text);
  }

  bool _hasDirectRequestAction(String text) {
    final normalized = text.toLowerCase();
    final hasRequestLanguage = RegExp(
      r"\b(please|pls|can you|could you|would you|will you|help me|help us|remind me|don't forget|do not forget|need you to|i need you to)\b",
    ).hasMatch(normalized);
    final hasActionVerb = RegExp(
      r'\b(help|make|cook|prepare|send|share|call|text|reply|review|check|book|schedule|arrange|bring|take|pick up|get|buy|order|finish|submit|pay|cancel|renew|choose|decide|compare|read|watch|listen)\b',
    ).hasMatch(normalized);
    final hasTodoPhrase = RegExp(
      r"\b(remind me to|don't forget to|do not forget to|need to|to do|todo)\b",
    ).hasMatch(normalized);

    return (hasRequestLanguage && hasActionVerb) || hasTodoPhrase;
  }

  bool _hasDocumentReviewAction(String text) {
    final normalized = text.toLowerCase();
    final hasDocumentSignal = RegExp(
      r'\b(docusign|envelope id|agreement|contract|lease|tenancy|pdf)\b',
    ).hasMatch(normalized);
    final hasReviewableSignal = RegExp(
      r'\b(sign|signed|dated|between|relating to|terms|conditions|document)\b',
    ).hasMatch(normalized);

    return hasDocumentSignal && hasReviewableSignal;
  }

  bool _hasCallOrFeedbackRequestAction(String text) {
    final normalized = text.toLowerCase();
    final hasCallAsk = RegExp(
      r'\b(?:can|could|would)\s+(?:we|you)\s+(?:do|have|schedule|book)\s+(?:a\s+)?(?:call|meeting|chat)\b|\b(?:do|have|schedule|arrange|fit)\s+(?:a\s+)?(?:call|meeting|chat)\b',
    ).hasMatch(normalized);
    final hasTalkAsk = RegExp(
      r'\b(?:need|needs|want|wants)\s+to\s+talk\b',
    ).hasMatch(normalized);
    final hasFeedbackAsk = RegExp(
      r'\b(?:get|give|share|provide)\s+(?:your\s+)?(?:general\s+)?feedback\b|\bfeedback\s+on\b',
    ).hasMatch(normalized);
    final hasCollaborationContext = RegExp(
      r'\b(implement|developer experience|setup|open[- ]source|human in the loop|project|feature|prototype|demo)\b',
    ).hasMatch(normalized);

    return hasCallAsk ||
        hasTalkAsk ||
        (hasFeedbackAsk && hasCollaborationContext);
  }

  String _callOrFeedbackTitleFromText(String text) {
    final normalized = text.toLowerCase();
    final hasWeekend = RegExp(r'\bweekend\b').hasMatch(normalized);
    final hasFeedback = RegExp(r'\bfeedback\b').hasMatch(normalized);
    final hasCall = RegExp(r'\b(call|meeting|chat)\b').hasMatch(normalized);

    if (hasWeekend && hasFeedback && hasCall) {
      return 'Plan weekend feedback call';
    }
    if (hasWeekend && hasCall && _hasFamilyMessageContext(text)) {
      return 'Call your sister this weekend';
    }
    if (hasWeekend && hasCall) {
      return 'Schedule weekend call';
    }
    if (hasFeedback && hasCall) {
      return 'Plan feedback call';
    }
    if (hasCall) {
      return 'Schedule call';
    }
    if (hasFeedback) {
      return 'Give feedback';
    }

    return 'Follow up on request';
  }

  String _callOrFeedbackSpaceFromText(String text) {
    final normalized = text.toLowerCase();
    if (_hasFamilyMessageContext(text)) {
      return 'Family';
    }
    if (RegExp(
      r'\b(developer experience|open[- ]source|human in the loop|implement|prototype|demo|code|setup)\b',
    ).hasMatch(normalized)) {
      return 'Work';
    }
    if (RegExp(r'\b(call|chat|message|talk|text)\b').hasMatch(normalized)) {
      return 'Messages';
    }

    return 'Projects';
  }

  String? _callOrFeedbackDeadlineFromText(String text) {
    final normalized = text.toLowerCase();
    if (!RegExp(r'\bweekend\b').hasMatch(normalized)) {
      return null;
    }
    if (!_hasFamilyMessageContext(text)) {
      return null;
    }

    return _isoWithLocalOffset(_endOfThisWeekend());
  }

  DateTime _endOfThisWeekend() {
    final today = _now().toLocal();
    final daysUntilSunday = DateTime.sunday - today.weekday;
    final sunday = today.add(
      Duration(days: daysUntilSunday < 0 ? 0 : daysUntilSunday),
    );
    return DateTime(sunday.year, sunday.month, sunday.day, 18);
  }

  bool _hasFamilyMessageContext(String text) {
    final normalized = text.toLowerCase();
    return RegExp(
      r'\b(sista|sister|brother|mum|mom|mama|dad|papa|family)\b',
    ).hasMatch(normalized);
  }

  String _streakCompletionTitleFromText(String text) {
    final normalized = text.toLowerCase();
    if (normalized.contains('chess.com') || normalized.contains('chess')) {
      return 'Complete Chess.com streak';
    }

    return 'Keep streak alive';
  }

  String _streakSpaceFromText(String text) {
    final normalized = text.toLowerCase();
    if (normalized.contains('chess.com') || normalized.contains('chess')) {
      return 'Chess';
    }

    return 'Personal Habits';
  }

  String? _accountServiceFromText(String text) {
    const knownServices = ['Netflix', 'Google', 'Apple', 'Microsoft'];
    final lower = text.toLowerCase();
    for (final service in knownServices) {
      if (lower.contains(service.toLowerCase())) {
        return service;
      }
    }

    return null;
  }

  String _documentReviewTitleFromText(String text) {
    final normalized = text.toLowerCase();
    if (normalized.contains('tenancy agreement') ||
        normalized.contains('assured shorthold tenancy')) {
      return 'tenancy agreement';
    }
    if (normalized.contains('lease')) {
      return 'lease document';
    }
    if (normalized.contains('contract')) {
      return 'contract';
    }
    if (normalized.contains('agreement')) {
      return 'agreement';
    }
    if (normalized.contains('docusign')) {
      return 'DocuSign document';
    }

    return 'document';
  }

  String _documentSpaceFromText(String text) {
    final normalized = text.toLowerCase();
    if (RegExp(
      r'\b(tenancy|lease|rent|landlord|property|address|home)\b',
    ).hasMatch(normalized)) {
      return 'Home';
    }

    return 'Documents';
  }

  String _directRequestTitleFromText(String text) {
    final action = _directRequestActionFromText(text);
    if (action == null || action.isEmpty) {
      return 'Follow up on request';
    }

    return _titleCaseFirst(action);
  }

  String? _directRequestActionFromText(String text) {
    final normalized = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    final patterns = [
      RegExp(
        r'(?:please\s*)?(?:can|could|would|will)\s+you\s+(?:please\s*)?(.+?)(?:[?.!]|$)',
        caseSensitive: false,
      ),
      RegExp(
        r'(?:please\s*)?(?:help\s+(?:me|us)\s+)(.+?)(?:[?.!]|$)',
        caseSensitive: false,
      ),
      RegExp(
        r"(?:remind me to|don't forget to|do not forget to|i need you to|need you to|need to)\s+(.+?)(?:[?.!]|$)",
        caseSensitive: false,
      ),
      RegExp(r'please\s+(.+?)(?:[?.!]|$)', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(normalized);
      final action = match?.group(1)?.trim();
      if (action != null && action.isNotEmpty) {
        return _cleanDirectRequestAction(action);
      }
    }

    return null;
  }

  String _cleanDirectRequestAction(String action) {
    final cleaned = action
        .replaceFirst(
          RegExp(r'^(?:help\s+(?:me|us)\s+)', caseSensitive: false),
          'help ',
        )
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (cleaned.length <= 64) {
      return cleaned;
    }

    return '${cleaned.substring(0, 61).trim()}...';
  }

  String _titleCaseFirst(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return trimmed;
    }

    return '${trimmed[0].toUpperCase()}${trimmed.substring(1)}';
  }

  String _directRequestIntentionType(String text) {
    final normalized = text.toLowerCase();
    if (RegExp(
      r'\b(reply|respond|text|message|email)\b',
    ).hasMatch(normalized)) {
      return 'reply';
    }
    if (RegExp(
      r'\b(read|review|check|look at|watch|listen)\b',
    ).hasMatch(normalized)) {
      return 'read';
    }
    if (RegExp(r'\b(buy|purchase|order|pick up)\b').hasMatch(normalized) ||
        _hasGetErrandItem(normalized)) {
      return 'buy';
    }
    if (RegExp(r'\b(choose|decide|compare)\b').hasMatch(normalized)) {
      return 'decide';
    }

    return 'follow_up';
  }

  String _directRequestSpaceFromText(String text) {
    final normalized = text.toLowerCase();
    if (RegExp(
      r'\b(chips|food|cook|make|meal|dinner|lunch|breakfast|kitchen|home)\b',
    ).hasMatch(normalized)) {
      return 'Home';
    }
    if (RegExp(
      r'\b(job|application|career|interview|cv|resume)\b',
    ).hasMatch(normalized)) {
      return 'Career';
    }
    if (RegExp(
      r'\b(pay|invoice|bank|card|bill|subscription|renew)\b',
    ).hasMatch(normalized)) {
      return 'Finance';
    }
    if (RegExp(r'\b(call|reply|email|text|message)\b').hasMatch(normalized)) {
      return 'Messages';
    }

    return 'General';
  }

  String? _verificationCodeFromText(String text) {
    final lines = _meaningfulLines(text);
    for (var index = 0; index < lines.length; index++) {
      final line = lines[index];
      final previous = index > 0 ? lines[index - 1].toLowerCase() : '';
      final next = index + 1 < lines.length
          ? lines[index + 1].toLowerCase()
          : '';
      final codeMatch = RegExp(r'^\d{4,8}$').firstMatch(line);
      if (codeMatch == null) {
        continue;
      }
      if (previous.contains('sign in') ||
          previous.contains('code') ||
          next.contains('enter the code') ||
          next.contains('code above')) {
        return codeMatch.group(0);
      }
    }

    return null;
  }

  String? _eventTitleFromText(String text) {
    final invitationMatch = RegExp(
      r'invitation:\s*(.+?)(?:\s*@|\s+(?:mon|tue|wed|thu|fri|sat|sun)\b|$)',
      caseSensitive: false,
      dotAll: true,
    ).firstMatch(text);
    final invitationTitle = invitationMatch?.group(1)?.trim();
    if (invitationTitle != null && invitationTitle.isNotEmpty) {
      return _cleanEventTitle(invitationTitle);
    }

    final lines = _meaningfulLines(text);
    for (final line in lines) {
      final lower = line.toLowerCase();
      if (lower.contains('invitation') ||
          lower.contains('inbox') ||
          lower.contains('today') ||
          lower.contains('calendar') ||
          lower.contains('organiser') ||
          lower.contains('organizer')) {
        continue;
      }
      if (RegExp(r'\d').hasMatch(line)) {
        continue;
      }
      if (line.length > 60) {
        continue;
      }

      return _cleanEventTitle(line);
    }

    return null;
  }

  String _cleanEventTitle(String value) {
    return value
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceFirst(RegExp(r'\s*[@:,-]+\s*$'), '')
        .trim();
  }

  String? _futureDeadlineFromEventEvidence(String text) {
    final dateTime = _eventDateTimeFromText(text);
    if (dateTime == null) {
      return null;
    }

    if (!dateTime.isAfter(_now().toLocal())) {
      return null;
    }

    return _isoWithLocalOffset(dateTime);
  }

  DateTime? _eventDateTimeFromText(String text) {
    final absoluteMatch = RegExp(
      r'\b(?:mon|tue|wed|thu|fri|sat|sun)\s+(\d{1,2}\s+[A-Za-z]{3,9}\s+\d{4})\s+(\d{1,2}:\d{2}\s*(?:am|pm))',
      caseSensitive: false,
    ).firstMatch(text);
    if (absoluteMatch != null) {
      final dateText = absoluteMatch.group(1);
      final timeText = absoluteMatch.group(2);
      final date = dateText == null ? null : _parseEvidenceDate(dateText);
      final time = timeText == null ? null : _firstEvidenceTime([timeText]);
      if (date != null && time != null) {
        return DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
      }
    }

    final relativeDate = _relativeDate(text);
    final time = _firstEvidenceTime([text]);
    if (relativeDate != null && time != null) {
      return DateTime(
        relativeDate.year,
        relativeDate.month,
        relativeDate.day,
        time.hour,
        time.minute,
      );
    }

    return null;
  }

  String? _applicationRoleFromText(String text) {
    final roleSignal = RegExp(
      r'\b(engineer|developer|designer|manager|analyst|scientist|specialist|lead|director|architect)\b',
      caseSensitive: false,
    );
    final metadataOnly = RegExp(
      r'\b(remote|hybrid|onsite|full[- ]time|part[- ]time|apply|saved|people clicked|reposted)\b',
      caseSensitive: false,
    );

    final lines = _meaningfulLines(text);
    for (var index = 0; index < lines.length; index++) {
      final line = lines[index];
      if (!roleSignal.hasMatch(line)) {
        continue;
      }
      if (metadataOnly.hasMatch(line) &&
          line.split(RegExp(r'\s+')).length < 4) {
        continue;
      }

      final previous = index > 0 ? lines[index - 1] : null;
      final shouldJoinPrevious =
          previous != null &&
          previous.length <= 60 &&
          !metadataOnly.hasMatch(previous) &&
          !RegExp(r'\d').hasMatch(previous) &&
          !roleSignal.hasMatch(previous);
      final role = shouldJoinPrevious ? '$previous $line' : line;

      return _cleanApplicationRole(role);
    }

    return null;
  }

  String? _applicationCompanyFromText(String text) {
    final actionOrJobLine = RegExp(
      r'\b(apply|application|job|role|position|opportunity|hiring|remote|hybrid|onsite|full[- ]time|part[- ]time|reposted|people clicked|engineer|developer|designer|manager|analyst|scientist|specialist|lead|director|architect)\b',
      caseSensitive: false,
    );

    for (final line in _meaningfulLines(text)) {
      if (line.length > 40 ||
          RegExp(r'\d').hasMatch(line) ||
          actionOrJobLine.hasMatch(line)) {
        continue;
      }

      return _cleanApplicationCompany(line);
    }

    return null;
  }

  String _cleanApplicationRole(String value) {
    return value
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceFirst(RegExp(r'\s+[O0]$'), '')
        .trim();
  }

  String _cleanApplicationCompany(String value) {
    final trimmed = value.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (trimmed.toLowerCase() == 'nvidia') {
      return 'NVIDIA';
    }

    return trimmed;
  }

  List<String> _meaningfulLines(String text) {
    return text
        .split(RegExp(r'[\n\r]+'))
        .map((line) => line.replaceAll(RegExp(r'\s+'), ' ').trim())
        .where((line) => line.length >= 3)
        .toList(growable: false);
  }

  ExtractionResult _extractionFromPlainText(
    String rawOutput, {
    LocalRecognizedText? recognizedText,
    String? sourceText,
  }) {
    final fallbackText = recognizedText?.text.trim();
    final localSourceText = sourceText?.trim();
    final rawText = _plainTextFromModelOutput(rawOutput);
    final text = fallbackText != null && fallbackText.isNotEmpty
        ? fallbackText
        : localSourceText != null && localSourceText.isNotEmpty
        ? localSourceText
        : rawText;

    if (text.isEmpty || !RegExp(r'[A-Za-z0-9]').hasMatch(text)) {
      throw AiSchemaValidationException(
        'Extraction fallback had no readable text.',
      );
    }

    final confidence = sourceText?.trim().isNotEmpty == true
        ? 0.9
        : recognizedText?.confidence?.clamp(0.55, 0.75) ?? 0.45;

    return ExtractionResult(
      text: text,
      visibleEntities: const [],
      dates: const [],
      times: const [],
      links: _linksFromText(text),
      contentType: _contentTypeFromLocalEvidence(text),
      language: sourceText?.trim().isNotEmpty == true ? 'en' : 'unknown',
      confidence: confidence.toDouble(),
    );
  }

  ExtractionResult _preserveLocalTextExtraction(
    ExtractionResult extraction, {
    required String sourceText,
  }) {
    final localText = sourceText.trim();
    if (localText.isEmpty) {
      return extraction;
    }

    return extraction.copyWith(
      text: localText,
      links: _mergeUniqueStrings(extraction.links, _linksFromText(localText)),
      contentType: extraction.contentType == 'unknown'
          ? _contentTypeFromLocalEvidence(localText)
          : extraction.contentType,
    );
  }

  String _contentTypeFromLocalEvidence(String text) {
    if (_hasApplicationOpportunity(text)) {
      return 'job_post';
    }
    if (_hasEventInvitationAction(text)) {
      return 'event';
    }

    return 'unknown';
  }

  String _plainTextFromModelOutput(String rawOutput) {
    final withoutFences = rawOutput
        .replaceAll(RegExp(r'```(?:json)?', caseSensitive: false), '')
        .replaceAll('```', '');
    return withoutFences.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  List<String> _linksFromText(String text) {
    return RegExp(
      r'https?://[^\s)"\]]+',
    ).allMatches(text).map((match) => match.group(0)!).toList(growable: false);
  }

  List<String> _mergeUniqueStrings(List<String> first, List<String> second) {
    final seen = <String>{};
    return [...first, ...second]
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty && seen.add(value))
        .toList(growable: false);
  }

  String? _purchaseItemFromText(String text) {
    final match = RegExp(
      r'\b(?:buy|purchase|order|pick up)\s+(.+?)(?=\s+(?:today|tonight|tomorrow|at|by|before|on)\b|[.!?]|$)',
      caseSensitive: false,
    ).firstMatch(text);
    final item = match?.group(1)?.trim();
    if (item != null && item.isNotEmpty) {
      return item.replaceAll(RegExp(r'\s+'), ' ');
    }

    final getMatch = RegExp(
      r'\bget\s+((?:some|the|a|an)\s+)?(milk|bread|groceries|food|snacks?|chips|medicine|medication|prescription|water|coffee|tea|rice|eggs|toilet paper|supplies|ingredients?)\b',
      caseSensitive: false,
    ).firstMatch(text);
    final getItem = getMatch?.group(2)?.trim();
    if (getItem == null || getItem.isEmpty) {
      return null;
    }

    return getItem.replaceAll(RegExp(r'\s+'), ' ');
  }

  bool _hasGetErrandItem(String text) {
    return RegExp(
      r'\bget\s+(?:some\s+|the\s+|a\s+|an\s+)?(?:milk|bread|groceries|food|snacks?|chips|medicine|medication|prescription|water|coffee|tea|rice|eggs|toilet paper|supplies|ingredients?)\b',
      caseSensitive: false,
    ).hasMatch(text);
  }

  String _evidenceSnippet(String text) {
    final normalized = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.length <= 120) {
      return '"$normalized"';
    }

    return '"${normalized.substring(0, 117).trim()}..."';
  }

  String? _deadlineFromEvidence({
    required String text,
    required ExtractionResult extraction,
  }) {
    final time = _firstEvidenceTime([text, ...extraction.times]);
    if (time == null) {
      return null;
    }

    final date = _firstEvidenceDate(extraction.dates) ?? _relativeDate(text);
    if (date == null) {
      return null;
    }

    return _isoWithLocalOffset(
      DateTime(date.year, date.month, date.day, time.hour, time.minute),
    );
  }

  String _endOfTodayDeadline() {
    final today = _now().toLocal();
    return _isoWithLocalOffset(
      DateTime(today.year, today.month, today.day, 23, 59),
    );
  }

  DateTime? _firstEvidenceDate(List<String> dates) {
    for (final value in dates) {
      if (_isUnknownEvidenceValue(value)) {
        continue;
      }

      final parsed = _parseEvidenceDate(value);
      if (parsed != null) {
        return parsed;
      }
    }

    return null;
  }

  DateTime? _parseEvidenceDate(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || _isUnknownEvidenceValue(trimmed)) {
      return null;
    }

    final withoutOrdinal = trimmed.replaceAllMapped(
      RegExp(r'\b(\d{1,2})(st|nd|rd|th)\b', caseSensitive: false),
      (match) => match.group(1)!,
    );

    final parsed = DateTime.tryParse(withoutOrdinal);
    if (parsed != null) {
      return parsed.toLocal();
    }

    for (final format in _dateFormats) {
      try {
        return format.parseStrict(withoutOrdinal).toLocal();
      } on FormatException {
        continue;
      }
    }

    return null;
  }

  DateTime? _parseMonthDay({
    required String? monthName,
    required String? dayText,
    required String? yearText,
  }) {
    if (monthName == null || dayText == null) {
      return null;
    }

    final month = _monthNumber(monthName);
    final day = int.tryParse(dayText);
    if (month == null || day == null || day < 1 || day > 31) {
      return null;
    }

    final localNow = _now().toLocal();
    var year = int.tryParse(yearText ?? '') ?? localNow.year;
    var candidate = DateTime(year, month, day);
    if (yearText == null &&
        candidate.isBefore(
          DateTime(localNow.year, localNow.month, localNow.day),
        )) {
      year += 1;
      candidate = DateTime(year, month, day);
    }

    return candidate;
  }

  int? _monthNumber(String value) {
    return switch (value.trim().toLowerCase()) {
      'jan' || 'january' => 1,
      'feb' || 'february' => 2,
      'mar' || 'march' => 3,
      'apr' || 'april' => 4,
      'may' => 5,
      'jun' || 'june' => 6,
      'jul' || 'july' => 7,
      'aug' || 'august' => 8,
      'sep' || 'sept' || 'september' => 9,
      'oct' || 'october' => 10,
      'nov' || 'november' => 11,
      'dec' || 'december' => 12,
      _ => null,
    };
  }

  DateTime? _relativeDate(String text) {
    final lower = text.toLowerCase();
    final today = _now().toLocal();
    if (lower.contains(RegExp(r'\b(today|tonight)\b'))) {
      return DateTime(today.year, today.month, today.day);
    }
    if (lower.contains(RegExp(r'\btomorrow\b'))) {
      final tomorrow = today.add(const Duration(days: 1));
      return DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
    }

    return null;
  }

  ({int hour, int minute})? _firstEvidenceTime(List<String> values) {
    for (final value in values) {
      if (_isUnknownEvidenceValue(value)) {
        continue;
      }

      final parsed = DateTime.tryParse(value);
      if (parsed != null) {
        return (hour: parsed.hour, minute: parsed.minute);
      }

      final twentyFourHourMatch = RegExp(
        r'\b([01]?\d|2[0-3]):([0-5]\d)\b',
      ).firstMatch(value);
      if (twentyFourHourMatch != null) {
        return (
          hour: int.parse(twentyFourHourMatch.group(1)!),
          minute: int.parse(twentyFourHourMatch.group(2)!),
        );
      }

      final meridiemMatch = RegExp(
        r'\b(1[0-2]|0?[1-9])(?::([0-5]\d))?\s*(am|pm)\b',
        caseSensitive: false,
      ).firstMatch(value);
      if (meridiemMatch == null) {
        continue;
      }

      var hour = int.parse(meridiemMatch.group(1)!);
      final minute = int.tryParse(meridiemMatch.group(2) ?? '') ?? 0;
      final meridiem = meridiemMatch.group(3)!.toLowerCase();
      if (meridiem == 'pm' && hour != 12) {
        hour += 12;
      }
      if (meridiem == 'am' && hour == 12) {
        hour = 0;
      }
      return (hour: hour, minute: minute);
    }

    return null;
  }

  String _isoWithLocalOffset(DateTime value) {
    final offset = value.timeZoneOffset;
    final sign = offset.isNegative ? '-' : '+';
    final offsetMinutes = offset.inMinutes.abs();
    final offsetHours = offsetMinutes ~/ 60;
    final remainingMinutes = offsetMinutes % 60;
    return '${DateFormat('yyyy-MM-ddTHH:mm:ss').format(value)}'
        '$sign${_twoDigits(offsetHours)}:${_twoDigits(remainingMinutes)}';
  }

  String _twoDigits(int value) => value.toString().padLeft(2, '0');

  bool _isUnknownEvidenceValue(String value) {
    return switch (value.trim().toLowerCase()) {
      '' || 'unknown' || 'none' || 'n/a' || 'null' => true,
      _ => false,
    };
  }

  String _dateOnly(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  String _timeOnly(int hour, int minute) {
    final hourText = hour.toString().padLeft(2, '0');
    final minuteText = minute.toString().padLeft(2, '0');
    return '$hourText:$minuteText';
  }

  static final _dateFormats = [
    DateFormat('d MMM yyyy', 'en_US'),
    DateFormat('d MMMM yyyy', 'en_US'),
    DateFormat('MMM d, yyyy', 'en_US'),
    DateFormat('MMMM d, yyyy', 'en_US'),
    DateFormat('MM/dd/yyyy', 'en_US'),
    DateFormat('dd/MM/yyyy', 'en_US'),
  ];
}
