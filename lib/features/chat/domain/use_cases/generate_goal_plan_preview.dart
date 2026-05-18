import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:tag/core/ai/cactus/cactus_model_service.dart';
import 'package:tag/core/ai/schemas/goal_plan_preview_schema.dart';
import 'package:tag/core/ai/validation/ai_json_validator.dart';
import 'package:tag/core/ai/validation/ai_schema_validation_exception.dart';
import 'package:tag/core/use_cases/use_cases.dart';
import 'package:tag/features/cards/domain/entities/card_entities.dart';
import 'package:tag/features/cards/domain/repositories/card_repository.dart';
import 'package:tag/features/chat/domain/entities/chat_entities.dart';
import 'package:tag/features/chat/domain/entities/guided_planning_entities.dart';
import 'package:tag/features/chat/domain/repositories/chat_repository.dart';
import 'package:tag/features/model_setup/domain/repositories/model_setup_repository.dart';
import 'package:tag/features/source_ingestion/domain/entities/source_item_entity.dart';
import 'package:tag/features/source_ingestion/domain/repositories/source_repository.dart';

class GenerateGoalPlanPreviewParams extends Equatable {
  const GenerateGoalPlanPreviewParams({
    required this.session,
    required this.planStyle,
    required this.weeklyTime,
  });

  final ChatSessionEntity session;
  final PlanStyleChoice planStyle;
  final WeeklyTimeChoice weeklyTime;

  @override
  List<Object?> get props => [session, planStyle, weeklyTime];
}

class GenerateGoalPlanPreview
    with
        UseCases<GenerateGoalPlanPreviewResult, GenerateGoalPlanPreviewParams> {
  const GenerateGoalPlanPreview({
    required ChatRepository chatRepository,
    required CardRepository cardRepository,
    required SourceRepository sourceRepository,
    required CactusModelService cactusModelService,
    required ModelSetupRepository modelSetupRepository,
    AiJsonValidator jsonValidator = const AiJsonValidator(),
    DateTime Function()? now,
  }) : _chatRepository = chatRepository,
       _cardRepository = cardRepository,
       _sourceRepository = sourceRepository,
       _cactusModelService = cactusModelService,
       _modelSetupRepository = modelSetupRepository,
       _jsonValidator = jsonValidator,
       _now = now ?? DateTime.now;

  final ChatRepository _chatRepository;
  final CardRepository _cardRepository;
  final SourceRepository _sourceRepository;
  final CactusModelService _cactusModelService;
  final ModelSetupRepository _modelSetupRepository;
  final AiJsonValidator _jsonValidator;
  final DateTime Function() _now;

  @override
  Future<GenerateGoalPlanPreviewResult> call(
    GenerateGoalPlanPreviewParams params,
  ) async {
    if (params.session.purpose != ChatPurpose.planSuggestion) {
      throw const AiSchemaValidationException(
        'Goal plan previews require a suggestion planning chat.',
      );
    }

    final linkedCardId = params.session.linkedCardId;
    if (linkedCardId == null || linkedCardId.trim().isEmpty) {
      throw const AiSchemaValidationException(
        'Suggestion planning chat must be linked to a Suggestion Card.',
      );
    }

    final suggestion = await _cardRepository.getCardById(linkedCardId);
    if (suggestion == null) {
      throw const AiSchemaValidationException(
        'Linked Suggestion Card was not found.',
      );
    }
    _validateSuggestion(suggestion);

    final sources = await _loadSources(suggestion.sourceIds);
    final modelSlug = await _modelSetupRepository
        .loadSelectedPrimaryModelSlug();
    var completion = await _complete(
      modelSlug: modelSlug,
      systemPrompt: _systemPrompt,
      userPrompt: _previewPrompt(
        suggestion: suggestion,
        sources: sources,
        planStyle: params.planStyle,
        weeklyTime: params.weeklyTime,
      ),
    );
    late GoalPlanPreview preview;

    try {
      preview = _parseAndValidatePreview(
        completion.response,
        suggestion: suggestion,
        planStyle: params.planStyle,
      );
    } on AiSchemaValidationException catch (error) {
      try {
        completion = await _complete(
          modelSlug: modelSlug,
          systemPrompt: _repairSystemPrompt,
          userPrompt: _repairPrompt(
            validationError: error,
            previousOutput: completion.response,
            suggestion: suggestion,
            sources: sources,
            planStyle: params.planStyle,
            weeklyTime: params.weeklyTime,
          ),
        );
        preview = _parseAndValidatePreview(
          completion.response,
          suggestion: suggestion,
          planStyle: params.planStyle,
        );
      } on AiSchemaValidationException {
        preview = _fallbackPreview(
          suggestion: suggestion,
          planStyle: params.planStyle,
        );
      }
    }

    final pendingConfirmationJson = jsonEncode(
      _pendingConfirmation(
        session: params.session,
        suggestion: suggestion,
        planStyle: params.planStyle,
        weeklyTime: params.weeklyTime,
        preview: preview,
        modelSlug: modelSlug,
      ),
    );
    final updatedSession = await _chatRepository.updatePendingConfirmation(
      sessionId: params.session.id,
      pendingConfirmationJson: pendingConfirmationJson,
    );

    return GenerateGoalPlanPreviewResult(
      preview: preview,
      pendingConfirmationJson: pendingConfirmationJson,
      updatedSession: updatedSession,
      modelSlug: modelSlug,
      rawModelOutput: completion.response,
    );
  }

  GoalPlanPreview _parseAndValidatePreview(
    String rawOutput, {
    required TagCardEntity suggestion,
    required PlanStyleChoice planStyle,
  }) {
    final preview = _jsonValidator.parseObject<GoalPlanPreview>(
      rawOutput: rawOutput,
      decoder: GoalPlanPreview.fromJson,
    );

    return preview.validateForSourceBackedSuggestion(
      allowedSourceIds: suggestion.sourceIds.toSet(),
      expectedDurationWeeks: planStyle.durationWeeks,
    );
  }

  Future<List<SourceItemEntity>> _loadSources(List<String> sourceIds) async {
    final sources = <SourceItemEntity>[];
    for (final sourceId in sourceIds) {
      final source = await _sourceRepository.getSourceById(sourceId);
      if (source != null) {
        sources.add(source);
      }
    }

    return sources;
  }

  Future<AiCompletionResult> _complete({
    required String modelSlug,
    required String systemPrompt,
    required String userPrompt,
  }) {
    return _cactusModelService.complete(
      modelSlug: modelSlug,
      messages: [
        AiChatMessage(role: 'system', content: systemPrompt),
        AiChatMessage(role: 'user', content: userPrompt),
      ],
      options: const AiCompletionOptions(
        temperature: 0.1,
        maxTokens: 900,
        localOnly: true,
      ),
    );
  }

  void _validateSuggestion(TagCardEntity suggestion) {
    if (suggestion.cardType != TagCardType.suggestion) {
      throw const AiSchemaValidationException(
        'Goal plan previews can only start from Suggestion Cards.',
      );
    }
    if (suggestion.status != TagCardStatus.active) {
      throw const AiSchemaValidationException(
        'Goal plan previews can only start from active suggestions.',
      );
    }
    if (suggestion.notificationEnabled) {
      throw const AiSchemaValidationException(
        'Suggestion Cards must never be notification enabled.',
      );
    }
  }

  GoalPlanPreview _fallbackPreview({
    required TagCardEntity suggestion,
    required PlanStyleChoice planStyle,
  }) {
    final durationWeeks = planStyle.durationWeeks ?? 4;
    final cardCount = durationWeeks.clamp(1, 4).toInt();
    final goalName = _goalNameFromSuggestion(suggestion.title);
    final sourceIds = suggestion.sourceIds.toList(growable: false);

    return GoalPlanPreview(
      goalName: goalName,
      spaceName: suggestion.space.name,
      durationWeeks: durationWeeks,
      preferredDays: const ['Saturday'],
      cards: [
        for (var index = 0; index < cardCount; index++)
          GoalPlanPreviewCard(
            title: _fallbackCardTitle(goalName, index, cardCount),
            reason: _fallbackCardReason(suggestion, index, cardCount),
            scheduledFor: _fallbackScheduledFor(index),
            sourceIds: sourceIds,
          ),
      ],
    ).validateForSourceBackedSuggestion(
      allowedSourceIds: suggestion.sourceIds.toSet(),
      expectedDurationWeeks: planStyle.durationWeeks,
    );
  }

  String _goalNameFromSuggestion(String title) {
    final trimmed = title.trim();
    const prefix = 'Goal detected:';
    if (trimmed.toLowerCase().startsWith(prefix.toLowerCase())) {
      final goal = trimmed.substring(prefix.length).trim();
      if (goal.isNotEmpty) {
        return goal;
      }
    }

    return trimmed.isEmpty ? 'Plan saved suggestion' : trimmed;
  }

  String _fallbackCardTitle(String goalName, int index, int cardCount) {
    if (cardCount == 1) {
      return 'Start $goalName';
    }

    return switch (index) {
      0 => 'Set up $goalName',
      1 => 'Make progress on $goalName',
      2 => 'Review progress on $goalName',
      _ => 'Wrap up $goalName',
    };
  }

  String _fallbackCardReason(
    TagCardEntity suggestion,
    int index,
    int cardCount,
  ) {
    final evidence = suggestion.evidenceSummary.trim().isNotEmpty
        ? suggestion.evidenceSummary.trim()
        : suggestion.reason.trim();
    final phase = cardCount == 1 ? 'a focused first step' : 'step ${index + 1}';

    return 'Create $phase from the saved source evidence: $evidence';
  }

  String _fallbackScheduledFor(int weekIndex) {
    final localNow = _now().toLocal();
    final daysUntilSaturday =
        (DateTime.saturday - localNow.weekday + DateTime.daysPerWeek) %
        DateTime.daysPerWeek;
    var firstSaturday = DateTime(
      localNow.year,
      localNow.month,
      localNow.day,
      10,
    ).add(Duration(days: daysUntilSaturday));
    if (!firstSaturday.isAfter(localNow)) {
      firstSaturday = firstSaturday.add(const Duration(days: 7));
    }

    return firstSaturday.add(Duration(days: 7 * weekIndex)).toIso8601String();
  }

  Map<String, Object?> _pendingConfirmation({
    required ChatSessionEntity session,
    required TagCardEntity suggestion,
    required PlanStyleChoice planStyle,
    required WeeklyTimeChoice weeklyTime,
    required GoalPlanPreview preview,
    required String modelSlug,
  }) {
    return {
      'type': 'create_goal_plan',
      'origin': 'plan_suggestion',
      'requires_confirmation': true,
      'chat_session_id': session.id,
      'origin_card_id': suggestion.id,
      'space_id': suggestion.space.id,
      'source_ids': suggestion.sourceIds,
      'plan_style': planStyle.storageValue,
      'weekly_time': weeklyTime.storageValue,
      'weekly_time_minutes': weeklyTime.minutes,
      'model_slug': modelSlug,
      'created_at': _now().toUtc().toIso8601String(),
      'preview': preview.toJson(),
    };
  }

  String _previewPrompt({
    required TagCardEntity suggestion,
    required List<SourceItemEntity> sources,
    required PlanStyleChoice planStyle,
    required WeeklyTimeChoice weeklyTime,
  }) {
    return '''
Suggestion Card:
${const JsonEncoder.withIndent('  ').convert(_suggestionJson(suggestion))}

Source evidence:
${const JsonEncoder.withIndent('  ').convert(sources.map(_sourceJson).toList(growable: false))}

User choices:
${const JsonEncoder.withIndent('  ').convert({'plan_style': planStyle.label, 'plan_style_value': planStyle.storageValue, 'duration_weeks': planStyle.durationWeeks, 'weekly_time': weeklyTime.label, 'weekly_time_minutes': weeklyTime.minutes, 'now': _now().toLocal().toIso8601String()})}

Create a preview only. Do not claim cards have been created.
Use only the cited local source_ids. Every preview card must cite at least one source_id.
Return exactly this JSON shape:
{"goal_name":"...","space_name":"...","duration_weeks":${planStyle.durationWeeks ?? 4},"preferred_days":["Saturday"],"cards":[{"title":"...","reason":"...","scheduled_for":"2026-05-23T10:00:00+01:00","source_ids":["src_..."]}]}
''';
  }

  String _repairPrompt({
    required AiSchemaValidationException validationError,
    required String previousOutput,
    required TagCardEntity suggestion,
    required List<SourceItemEntity> sources,
    required PlanStyleChoice planStyle,
    required WeeklyTimeChoice weeklyTime,
  }) {
    return '''
The previous goal plan preview was invalid: ${validationError.message}

Previous output:
$previousOutput

Repair it using this same local context:
${_previewPrompt(suggestion: suggestion, sources: sources, planStyle: planStyle, weeklyTime: weeklyTime)}
''';
  }

  Map<String, Object?> _suggestionJson(TagCardEntity suggestion) {
    return {
      'id': suggestion.id,
      'title': suggestion.title,
      'reason': suggestion.reason,
      'space_name': suggestion.space.name,
      'source_summary': suggestion.sourceSummary,
      'evidence_summary': suggestion.evidenceSummary,
      'source_ids': suggestion.sourceIds,
    };
  }

  Map<String, Object?> _sourceJson(SourceItemEntity source) {
    return {
      'source_id': source.id,
      'type': source.type.storageValue,
      'summary': source.displaySummary,
      'content_type': source.contentType,
      'text': _sourceText(source),
    };
  }

  String _sourceText(SourceItemEntity source) {
    final text = source.extractedText?.trim().isNotEmpty == true
        ? source.extractedText!.trim()
        : source.rawText?.trim().isNotEmpty == true
        ? source.rawText!.trim()
        : source.originalUri?.trim() ?? '';

    if (text.length <= 900) {
      return text;
    }

    return '${text.substring(0, 900)}...';
  }

  static const _systemPrompt = '''
You generate local-only Tag goal plan previews from source-backed Suggestion Cards.
Return one valid JSON object only. Do not create cards. Do not schedule notifications.
''';

  static const _repairSystemPrompt = '''
Repair the Tag goal plan preview. Return one valid JSON object only.
Use only supplied source ids. Do not create cards. Do not schedule notifications.
''';
}
