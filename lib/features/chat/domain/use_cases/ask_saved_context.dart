import 'dart:convert';
import 'dart:math' as math;

import 'package:equatable/equatable.dart';
import 'package:tag/core/ai/cactus/cactus_model_service.dart';
import 'package:tag/core/ai/rag/local_rag_service.dart';
import 'package:tag/core/ai/rag/rag_models.dart';
import 'package:tag/core/ai/validation/ai_json_validator.dart';
import 'package:tag/core/ai/validation/ai_schema_validation_exception.dart';
import 'package:tag/core/use_cases/use_cases.dart';
import 'package:tag/features/chat/domain/entities/chat_entities.dart';
import 'package:tag/features/model_setup/domain/repositories/model_setup_repository.dart';

class AskSavedContextParams extends Equatable {
  const AskSavedContextParams({
    required this.query,
    this.history = const [],
    this.topK = 4,
    this.useModelSynthesis = false,
  });

  final String query;
  final List<ChatMessageEntity> history;
  final int topK;
  final bool useModelSynthesis;

  @override
  List<Object?> get props => [query, history, topK, useModelSynthesis];
}

class AskSavedContextResult extends Equatable {
  const AskSavedContextResult({
    required this.answer,
    required this.modelSlug,
    required this.contextResults,
    required this.rawModelOutput,
  });

  final ChatAnswerEntity answer;
  final String modelSlug;
  final List<LocalRagSearchResult> contextResults;
  final String rawModelOutput;

  @override
  List<Object?> get props => [
    answer,
    modelSlug,
    contextResults,
    rawModelOutput,
  ];
}

class AskSavedContext
    with UseCases<AskSavedContextResult, AskSavedContextParams> {
  const AskSavedContext({
    required LocalRagService localRagService,
    required CactusModelService cactusModelService,
    required ModelSetupRepository modelSetupRepository,
    AiJsonValidator jsonValidator = const AiJsonValidator(),
    Duration modelSynthesisTimeout = const Duration(seconds: 20),
  }) : _localRagService = localRagService,
       _cactusModelService = cactusModelService,
       _modelSetupRepository = modelSetupRepository,
       _jsonValidator = jsonValidator,
       _modelSynthesisTimeout = modelSynthesisTimeout;

  final LocalRagService _localRagService;
  final CactusModelService _cactusModelService;
  final ModelSetupRepository _modelSetupRepository;
  final AiJsonValidator _jsonValidator;
  final Duration _modelSynthesisTimeout;

  @override
  Future<AskSavedContextResult> call(AskSavedContextParams params) async {
    final query = params.query.trim();
    if (query.isEmpty) {
      throw const AiSchemaValidationException('Question cannot be empty.');
    }

    final rawContextResults = await _localRagService.search(
      query: _retrievalQueryFor(query),
      topK: math.max(params.topK, 8),
    );
    final contextResults = _relevantContextResults(
      query: query,
      results: rawContextResults,
    );
    final modelSlug = await _modelSetupRepository
        .loadSelectedPrimaryModelSlug();
    if (contextResults.isEmpty) {
      return AskSavedContextResult(
        answer: _noResultAnswer(query),
        modelSlug: modelSlug,
        contextResults: const [],
        rawModelOutput: '',
      );
    }
    if (!params.useModelSynthesis) {
      return AskSavedContextResult(
        answer: _fallbackAnswer(query: query, contextResults: contextResults),
        modelSlug: modelSlug,
        contextResults: contextResults,
        rawModelOutput: '',
      );
    }

    final userPrompt = _userPrompt(
      query: query,
      contextResults: contextResults,
      history: params.history,
    );
    AiCompletionResult? completion;
    late ChatAnswerEntity groundedAnswer;

    try {
      completion = await _complete(
        modelSlug: modelSlug,
        systemPrompt: _systemPrompt,
        userPrompt: userPrompt,
        maxTokens: 500,
        temperature: 0,
      ).timeout(_modelSynthesisTimeout);
      groundedAnswer = _parseGroundedAnswer(
        completion.response,
        contextResults,
      );
      _validateAnswer(groundedAnswer, contextResults);
    } on AiSchemaValidationException catch (error) {
      try {
        completion = await _repairAnswer(
          modelSlug: modelSlug,
          query: query,
          contextResults: contextResults,
          validationError: error,
        ).timeout(_modelSynthesisTimeout);
        groundedAnswer = _parseGroundedAnswer(
          completion.response,
          contextResults,
        );
        _validateAnswer(groundedAnswer, contextResults);
      } on Object {
        groundedAnswer = _fallbackAnswer(
          query: query,
          contextResults: contextResults,
        );
      }
    } on Object {
      groundedAnswer = _fallbackAnswer(
        query: query,
        contextResults: contextResults,
      );
    }

    return AskSavedContextResult(
      answer: groundedAnswer,
      modelSlug: modelSlug,
      contextResults: contextResults,
      rawModelOutput: completion?.response ?? '',
    );
  }

  ChatAnswerEntity _parseGroundedAnswer(
    String rawOutput,
    List<LocalRagSearchResult> contextResults,
  ) {
    final parsed = _jsonValidator.parseObject<ChatAnswerEntity>(
      rawOutput: rawOutput,
      decoder: ChatAnswerEntity.fromJson,
    );

    return _sanitizeAnswer(parsed.groundedBy(contextResults));
  }

  ChatAnswerEntity _sanitizeAnswer(ChatAnswerEntity answer) {
    return ChatAnswerEntity(
      answer: _cleanUserFacingText(answer.answer),
      reasoningSummary: _cleanUserFacingText(answer.reasoningSummary),
      sourceCitations: answer.sourceCitations,
      sourceIds: answer.sourceIds,
      cardIds: answer.cardIds,
      optionalAction: answer.optionalAction,
    );
  }

  Future<AiCompletionResult> _complete({
    required String modelSlug,
    required String systemPrompt,
    required String userPrompt,
    required int maxTokens,
    required double temperature,
  }) {
    return _cactusModelService.complete(
      modelSlug: modelSlug,
      messages: [
        AiChatMessage(role: 'system', content: systemPrompt),
        AiChatMessage(role: 'user', content: userPrompt),
      ],
      options: AiCompletionOptions(
        temperature: temperature,
        maxTokens: maxTokens,
        localOnly: true,
      ),
    );
  }

  Future<AiCompletionResult> _repairAnswer({
    required String modelSlug,
    required String query,
    required List<LocalRagSearchResult> contextResults,
    required AiSchemaValidationException validationError,
  }) {
    return _complete(
      modelSlug: modelSlug,
      systemPrompt: _repairSystemPrompt,
      userPrompt: _repairPrompt(
        query: query,
        contextResults: contextResults,
        validationError: validationError,
      ),
      maxTokens: 600,
      temperature: 0,
    );
  }

  void _validateAnswer(
    ChatAnswerEntity answer,
    List<LocalRagSearchResult> contextResults,
  ) {
    if (answer.answer.trim().isEmpty) {
      throw const AiSchemaValidationException(
        'Chat answer must include an answer.',
      );
    }
    if (_isGenericAnswer(answer.answer)) {
      throw const AiSchemaValidationException(
        'Chat answer was too generic to be useful.',
      );
    }

    if (contextResults.isNotEmpty && answer.sourceIds.isEmpty) {
      throw const AiSchemaValidationException(
        'Source-backed answers must cite at least one local source.',
      );
    }
  }

  ChatAnswerEntity _noResultAnswer(String query) {
    return ChatAnswerEntity(
      answer: 'I could not find anything saved about ${_plainTopic(query)}.',
      reasoningSummary: 'No retrieved local source matched the question.',
    );
  }

  ChatAnswerEntity _fallbackAnswer({
    required String query,
    required List<LocalRagSearchResult> contextResults,
  }) {
    final topResults = contextResults.take(3).toList(growable: false);
    final citations = topResults
        .map(ChatSourceCitationEntity.fromRagResult)
        .toList(growable: false);
    final labels = topResults
        .map((result) => _answerLabelForResult(query, result))
        .toList();
    final sourceList = _joinLabels(labels);
    final sourceListSentence = _endsWithTerminalPunctuation(sourceList)
        ? sourceList
        : '$sourceList.';
    final evidence = _groundedEvidenceSentence(
      query: query,
      result: topResults.first,
    );
    final actionPrefix = _looksLikeMutationRequest(query)
        ? 'I found relevant saved context, but I will not create or schedule anything without your confirmation. '
        : '';

    return ChatAnswerEntity(
      answer:
          '${actionPrefix}I found saved context for this in $sourceListSentence '
          '$evidence',
      reasoningSummary:
          'Tag used local retrieved sources and kept the answer citation-backed.',
      sourceCitations: citations,
      sourceIds: citations.map((citation) => citation.sourceId).toList(),
      cardIds: _uniqueStrings(
        citations.map((citation) => citation.cardId).whereType<String>(),
      ),
    );
  }

  List<LocalRagSearchResult> _relevantContextResults({
    required String query,
    required List<LocalRagSearchResult> results,
  }) {
    final queryTokens = _expandedQueryTokens(query);
    if (queryTokens.isEmpty) {
      return results.take(1).toList(growable: false);
    }

    final scored = <_ScoredContextResult>[];
    for (final result in results) {
      final score = _contextRelevanceScore(
        query: query,
        queryTokens: queryTokens,
        result: result,
      );
      if (score >= 0.14) {
        scored.add(_ScoredContextResult(result: result, score: score));
      }
    }

    scored.sort((left, right) {
      final scoreOrder = right.score.compareTo(left.score);
      if (scoreOrder != 0) {
        return scoreOrder;
      }

      return right.result.score.compareTo(left.result.score);
    });

    return scored.map((scored) => scored.result).toList(growable: false);
  }

  double _contextRelevanceScore({
    required String query,
    required Set<String> queryTokens,
    required LocalRagSearchResult result,
  }) {
    if (!_passesDomainGuards(query: query, result: result)) {
      return 0;
    }

    final searchableTokens = _tokens(_searchableText(result));
    final matches = queryTokens.intersection(searchableTokens);
    if (matches.isEmpty) {
      return 0;
    }

    final exactTokens = _tokens(query).difference(_stopWords);
    final labelTokens = _tokens(_resultLabelText(result));
    final labelMatches = exactTokens.intersection(labelTokens);
    var score = matches.length / queryTokens.length;
    score += math.min(0.36, labelMatches.length * 0.12);
    if (result.relatedCards.isNotEmpty) {
      score += 0.08;
    }
    if (_looksLikeCardReasonQuery(query) && labelMatches.isNotEmpty) {
      score += 0.2;
    }

    return score;
  }

  bool _passesDomainGuards({
    required String query,
    required LocalRagSearchResult result,
  }) {
    final queryTokens = _tokens(query);
    if (_hasAny(queryTokens, _cookingQuerySignals)) {
      return _hasContextSignal(result, _cookingContextSignals);
    }
    if (_hasCompanyQuery(queryTokens)) {
      return _hasContextSignal(result, _companyContextSignals);
    }
    if (_hasPersonalReminderQuery(queryTokens)) {
      return _passesPersonalReminderGuard(
        queryTokens: queryTokens,
        result: result,
      );
    }
    if (_hasJobFollowUpQuery(queryTokens)) {
      return _passesJobFollowUpGuard(result);
    }
    if (_hasLlmQuery(queryTokens)) {
      return _hasContextSignal(result, _llmContextSignals);
    }

    return true;
  }

  Set<String> _expandedQueryTokens(String query) {
    final baseTokens = _tokens(query);
    final expanded = {...baseTokens.difference(_stopWords)};
    if (baseTokens.contains('weekend')) {
      expanded.addAll(const ['saturday', 'sunday']);
    }
    if (baseTokens.contains('reminder') || baseTokens.contains('reminders')) {
      expanded.addAll(const ['urgent', 'call', 'message', 'deadline']);
    }
    if (baseTokens.contains('application') ||
        baseTokens.contains('applications')) {
      expanded.addAll(const ['job', 'linkedin', 'apply', 'follow']);
    }
    if (baseTokens.contains('company')) {
      expanded.addAll(const ['companies', 'house', 'formation', 'ltd', 'uk']);
    }
    if (baseTokens.contains('learning') || baseTokens.contains('resources')) {
      expanded.addAll(const [
        'llm',
        'attention',
        'inference',
        'optimization',
        'article',
      ]);
    }
    return expanded;
  }

  String _retrievalQueryFor(String query) {
    final baseTokens = _tokens(query);
    final expansions = <String>{};
    if (baseTokens.contains('weekend')) {
      expansions.addAll(const ['saturday', 'sunday']);
    }
    if (baseTokens.contains('reminder') || baseTokens.contains('reminders')) {
      expansions.addAll(const ['urgent', 'call', 'message', 'deadline']);
    }
    if (baseTokens.contains('application') ||
        baseTokens.contains('applications') ||
        baseTokens.contains('job')) {
      expansions.addAll(const [
        'linkedin',
        'recruiter',
        'opportunity',
        'interview',
        'apply',
      ]);
    }
    if (_hasCompanyQuery(baseTokens)) {
      expansions.addAll(const [
        'uk',
        'companies',
        'house',
        'formation',
        'incorporate',
        'ltd',
        'bank',
      ]);
    }
    if (baseTokens.contains('learning') ||
        baseTokens.contains('resources') ||
        _hasLlmQuery(baseTokens)) {
      expansions.addAll(const [
        'llm',
        'attention',
        'inference',
        'optimization',
        'transformer',
        'article',
      ]);
    }

    final novelExpansions = expansions.difference(baseTokens).toList()..sort();
    if (novelExpansions.isEmpty) {
      return query;
    }

    return '$query ${novelExpansions.join(' ')}';
  }

  bool _hasCompanyQuery(Set<String> queryTokens) {
    return queryTokens.contains('company') ||
        queryTokens.contains('formation') ||
        queryTokens.contains('founder') ||
        queryTokens.contains('incorporate') ||
        queryTokens.contains('companies');
  }

  bool _hasPersonalReminderQuery(Set<String> queryTokens) {
    return queryTokens.contains('personal') ||
        queryTokens.contains('sister') ||
        queryTokens.contains('family') ||
        (queryTokens.contains('weekend') &&
            (queryTokens.contains('reminder') ||
                queryTokens.contains('reminders') ||
                queryTokens.contains('call')));
  }

  bool _hasJobFollowUpQuery(Set<String> queryTokens) {
    return queryTokens.contains('job') ||
        queryTokens.contains('follow') ||
        queryTokens.contains('followup') ||
        queryTokens.contains('follow-up');
  }

  bool _hasLlmQuery(Set<String> queryTokens) {
    return queryTokens.contains('llm') ||
        queryTokens.contains('internals') ||
        queryTokens.contains('attention') ||
        queryTokens.contains('inference') ||
        queryTokens.contains('optimization');
  }

  bool _looksLikeCardReasonQuery(String query) {
    final normalized = query.toLowerCase();
    return normalized.contains('why') &&
        (normalized.contains('card') || normalized.contains('create'));
  }

  bool _passesPersonalReminderGuard({
    required Set<String> queryTokens,
    required LocalRagSearchResult result,
  }) {
    final contextTokens = _tokens(_searchableText(result));
    if (queryTokens.contains('sister')) {
      return contextTokens.contains('sister') ||
          contextTokens.contains('sista');
    }
    if (queryTokens.contains('brother')) {
      return contextTokens.contains('brother');
    }
    if (queryTokens.contains('family')) {
      return contextTokens.contains('family');
    }

    return _hasAny(contextTokens, _personalIdentityContextSignals) ||
        (contextTokens.contains('message') && contextTokens.contains('call'));
  }

  bool _passesJobFollowUpGuard(LocalRagSearchResult result) {
    final hasActionableCard = result.relatedCards.any((card) {
      return card.cardType != 'suggestion' && card.status != 'archived';
    });
    if (!hasActionableCard) {
      return false;
    }

    final evidenceTokens = _tokens(
      [
        result.source.sourceSummary ?? '',
        for (final card in result.relatedCards) ...[
          card.title,
          card.reason ?? '',
          card.sourceSummary ?? '',
          card.evidenceText ?? '',
          card.spaceName,
        ],
      ].join(' '),
    );
    return _hasAny(evidenceTokens, _jobFollowUpContextSignals);
  }

  bool _hasContextSignal(
    LocalRagSearchResult result,
    Set<String> allowedSignals,
  ) {
    return _hasAny(_tokens(_searchableText(result)), allowedSignals);
  }

  bool _hasAny(Set<String> tokens, Set<String> allowedSignals) {
    return tokens.any(allowedSignals.contains);
  }

  Set<String> _tokens(String text) {
    return RegExp(r"[a-z0-9']+")
        .allMatches(text.toLowerCase())
        .map((match) => match.group(0)!.replaceAll("'", ''))
        .where((token) => token.length > 2)
        .toSet();
  }

  String _searchableText(LocalRagSearchResult result) {
    return [
      result.chunk.chunkText,
      result.source.sourceSummary,
      result.source.contentType,
      result.source.type,
      for (final card in result.relatedCards) ...[
        card.cardType,
        card.title,
        card.spaceName,
        card.reason,
        card.sourceSummary,
        card.evidenceText,
      ],
    ].whereType<String>().join(' ');
  }

  String _resultLabelText(LocalRagSearchResult result) {
    return [
      result.source.displaySummary,
      for (final card in result.relatedCards) ...[card.title, card.spaceName],
    ].join(' ');
  }

  String _plainTopic(String query) {
    final trimmed = query.trim().replaceAll(RegExp(r'[?.!]+$'), '');
    return trimmed.isEmpty ? 'that' : '"$trimmed"';
  }

  bool _looksLikeMutationRequest(String query) {
    final normalized = query.toLowerCase();
    if (normalized.startsWith('why ') ||
        normalized.startsWith('what ') ||
        normalized.contains('why did you create')) {
      return false;
    }

    return normalized.contains('create ') ||
        normalized.contains('remind ') ||
        normalized.contains('schedule ') ||
        normalized.contains('make ');
  }

  String _joinLabels(List<String> labels) {
    final unique = _uniqueStrings(labels).take(3).toList(growable: false);
    if (unique.isEmpty) {
      return 'your saved sources';
    }
    if (unique.length == 1) {
      return unique.single;
    }
    if (unique.length == 2) {
      return '${unique.first} and ${unique.last}';
    }
    return '${unique.take(unique.length - 1).join(', ')}, and ${unique.last}';
  }

  String _answerLabelForResult(String query, LocalRagSearchResult result) {
    final card = result.relatedCards.isEmpty ? null : result.relatedCards.first;
    final cardTitle = card?.title.trim();
    if (cardTitle != null && cardTitle.isNotEmpty) {
      return cardTitle;
    }

    final summary = result.source.displaySummary.trim();
    if (summary.isNotEmpty && !_isGenericSummary(summary)) {
      return summary;
    }

    final preview = _labelFromEvidencePreview(
      query: query,
      text: result.chunk.preview,
    );
    if (preview.isNotEmpty) {
      return preview;
    }

    return result.source.displaySummary;
  }

  String _labelFromEvidencePreview({
    required String query,
    required String text,
  }) {
    final preview = _relevantEvidencePreview(
      query: query,
      text: text,
      maxLength: 120,
    );
    if (preview.isEmpty) {
      return '';
    }

    final phrase = preview.split(RegExp(r'\s*(?:→|:|\s-\s)\s*')).first.trim();
    if (phrase.length >= 12) {
      return _shortText(phrase, 72);
    }

    return _shortText(preview, 72);
  }

  String _groundedEvidenceSentence({
    required String query,
    required LocalRagSearchResult result,
  }) {
    final card = result.relatedCards.isEmpty ? null : result.relatedCards.first;
    final reason = card?.reason?.trim();
    if (reason != null && reason.isNotEmpty) {
      return 'The card reason is: ${_shortText(reason, 150)}';
    }

    final sourceSummary = result.source.sourceSummary?.trim();
    if (sourceSummary != null &&
        sourceSummary.isNotEmpty &&
        !_isGenericSummary(sourceSummary)) {
      return 'The saved summary is: ${_shortText(sourceSummary, 150)}';
    }

    final evidence = card?.evidenceText?.trim();
    if (evidence != null && evidence.isNotEmpty) {
      return 'The cited evidence is available in the source preview.';
    }

    final preview = result.chunk.preview.trim();
    if (preview.isNotEmpty) {
      return 'The source preview mentions: ${_relevantEvidencePreview(query: query, text: preview, maxLength: 150)}';
    }

    return 'The cited source has the supporting evidence.';
  }

  bool _isGenericAnswer(String answer) {
    final normalized = answer.trim().toLowerCase().replaceAll(
      RegExp(r'[.!?]+$'),
      '',
    );
    return normalized == 'saved source' ||
        normalized == 'source' ||
        normalized == 'saved context' ||
        normalized == 'local source';
  }

  bool _isGenericSummary(String summary) {
    final normalized = summary.trim().toLowerCase().replaceAll(
      RegExp(r'[.!?]+$'),
      '',
    );
    return normalized == 'saved source' ||
        normalized == 'saved image' ||
        normalized == 'saved screenshot';
  }

  String _relevantEvidencePreview({
    required String query,
    required String text,
    required int maxLength,
  }) {
    final cleaned = _cleanEvidenceText(text);
    if (cleaned.isEmpty) {
      return '';
    }

    final index = _earliestQuerySignalIndex(query: query, text: cleaned);
    final relevant = index == null ? cleaned : cleaned.substring(index).trim();
    return _shortText(relevant, maxLength);
  }

  String _cleanEvidenceText(String value) {
    var cleaned = value.replaceAll(RegExp(r'\s+'), ' ').trim();
    cleaned = cleaned.replaceAll(RegExp(r'[•·]{2,}'), ' ');
    cleaned = cleaned.replaceFirst(
      RegExp(
        r'^\d{1,2}:\d{2}\s*(?:[|Il1]{1,4}\s*)?(?:5g|4g|lte|wifi|wi-fi)?\s*\d{1,3}\s*',
        caseSensitive: false,
      ),
      '',
    );
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();
    return cleaned;
  }

  int? _earliestQuerySignalIndex({
    required String query,
    required String text,
  }) {
    final signals = {
      ..._expandedQueryTokens(query),
      if (_hasCompanyQuery(_tokens(query))) ...[
        'uk',
        'founder',
        'starter',
        'incorporate',
        'companies',
        'house',
      ],
    };
    final lower = text.toLowerCase();
    int? earliest;
    for (final signal in signals) {
      if (signal.length < 3 && signal != 'uk') {
        continue;
      }
      final pattern = RegExp(
        r'(^|[^a-z0-9])' + RegExp.escape(signal) + r'([^a-z0-9]|$)',
      );
      final match = pattern.firstMatch(lower);
      if (match == null) {
        continue;
      }
      final start = match.start + (match.group(1)?.length ?? 0);
      if (earliest == null || start < earliest) {
        earliest = start;
      }
    }

    return earliest;
  }

  String _shortText(String value, int maxLength) {
    final collapsed = _cleanUserFacingText(value);
    if (collapsed.length <= maxLength) {
      return collapsed;
    }

    return '${collapsed.substring(0, maxLength).trim()}...';
  }

  String _cleanUserFacingText(String value) {
    var cleaned = value.replaceAll(RegExp(r'\s+'), ' ').trim();
    cleaned = cleaned.replaceAll(
      RegExp(r'\s*\((?:src|card|job|chat)_[^)]*(?:\)|$)', caseSensitive: false),
      '',
    );
    cleaned = cleaned.replaceAll(
      RegExp(
        r'\b(?:source|card|job|chat)_ids?\s*[:=]\s*\[[^\]]*\]',
        caseSensitive: false,
      ),
      '',
    );
    cleaned = cleaned.replaceAll(
      RegExp(
        r'\b(?:src|card|job|chat)_[A-Za-z0-9-]{2,}(?:\.\.\.)?',
        caseSensitive: false,
      ),
      '',
    );
    cleaned = cleaned.replaceAll(
      RegExp(r'\s*\(as per the text:[^)]*(?:\)|$)', caseSensitive: false),
      '',
    );
    cleaned = cleaned.replaceAll(RegExp(r'\(\s*\)'), '');
    cleaned = cleaned.replaceAllMapped(
      RegExp(r'\s+([,.;:!?])'),
      (match) => match.group(1)!,
    );
    cleaned = cleaned.replaceAll(RegExp(r'\.{2,}'), '...');
    cleaned = cleaned.replaceAll(RegExp(r'\s{2,}'), ' ').trim();

    return cleaned;
  }

  bool _endsWithTerminalPunctuation(String value) {
    return RegExp(r'(?:[.!?]|\.{3})$').hasMatch(value.trim());
  }

  List<String> _uniqueStrings(Iterable<String> values) {
    final seen = <String>{};
    return [
      for (final value in values)
        if (value.trim().isNotEmpty && seen.add(value.trim())) value.trim(),
    ];
  }

  String _userPrompt({
    required String query,
    required List<LocalRagSearchResult> contextResults,
    required List<ChatMessageEntity> history,
  }) {
    final contextJson = contextResults
        .map(_contextResultJson)
        .toList(growable: false);
    final historyJson = history
        .where((message) {
          return message.role == ChatMessageRole.user ||
              message.role == ChatMessageRole.assistant;
        })
        .take(8)
        .map((message) {
          return {
            'role': message.role.storageValue,
            'content': message.content,
            'source_ids': message.sourceIds,
            'card_ids': message.cardIds,
          };
        })
        .toList(growable: false);
    final historyBlock = historyJson.isEmpty
        ? ''
        : '''

Previous messages:
${const JsonEncoder.withIndent('  ').convert(historyJson)}
''';

    return '''
Question: $query

Context:
${const JsonEncoder.withIndent('  ').convert(contextJson)}
$historyBlock

Return exactly this JSON shape:
{"answer":"...","reasoning_summary":"...","source_ids":["..."],"card_ids":["..."],"optional_action":null}
''';
  }

  Map<String, Object?> _contextResultJson(LocalRagSearchResult result) {
    return {
      'source_id': result.source.id,
      'source_summary': result.source.displaySummary,
      'content_type': result.source.contentType,
      'chunk': result.chunk.preview,
      'cards': result.relatedCards
          .map((card) {
            return {
              'card_id': card.cardId,
              'card_type': card.cardType,
              'status': card.status,
              'title': card.title,
              'space': card.spaceName,
              'reason': card.reason,
              'evidence': card.evidenceText,
            };
          })
          .toList(growable: false),
    };
  }

  String _repairPrompt({
    required String query,
    required List<LocalRagSearchResult> contextResults,
    required AiSchemaValidationException validationError,
  }) {
    final contextJson = contextResults
        .map(_contextResultJson)
        .toList(growable: false);

    return '''
The previous output was invalid: ${validationError.message}

Question: $query

Context:
${const JsonEncoder.withIndent('  ').convert(contextJson)}

Return exactly this JSON shape:
{"answer":"...","reasoning_summary":"...","source_ids":["..."],"card_ids":["..."],"optional_action":null}
''';
  }

  static const _systemPrompt = '''
You are Tag chat. Answer only from retrieved local context.
Return only valid JSON with answer, reasoning_summary, source_ids, card_ids, optional_action.
Do not mention source ids or card ids inside answer prose.
Every saved-context claim must be supported by cited source_ids from the provided context.
If the context is insufficient, say you could not find enough saved evidence.
Do not create, schedule, edit, or imply app mutations. optional_action must be null unless a separate confirmation flow is explicitly requested by the app.
''';

  static const _repairSystemPrompt = '''
Repair Tag chat output. Return only one valid JSON object.
No markdown. No extra text. Use only retrieved local context.
Use only source_ids and card_ids that appear in the provided context.
Do not mention source ids or card ids inside answer prose.
Do not mutate app data. optional_action is usually null.
''';

  static const _stopWords = {
    'what',
    'have',
    'saved',
    'about',
    'anything',
    'with',
    'from',
    'need',
    'this',
    'that',
    'your',
    'you',
    'for',
    'the',
    'and',
    'did',
    'why',
    'show',
    'source',
    'create',
    'reminder',
    'reminders',
    'next',
    'card',
    'cards',
  };

  static const _companyContextSignals = {
    'uk',
    'company',
    'companies',
    'formation',
    'founder',
    'incorporate',
    'house',
    'ltd',
    'legals',
    'bank',
  };

  static const _personalIdentityContextSignals = {
    'sister',
    'sista',
    'brother',
    'family',
    'mum',
    'mom',
    'dad',
    'whatsapp',
  };

  static const _jobFollowUpContextSignals = {
    'job',
    'linkedin',
    'opportunity',
    'interview',
    'recruiter',
  };

  static const _llmContextSignals = {
    'llm',
    'attention',
    'inference',
    'optimization',
    'tokenization',
    'transformer',
    'gpu',
    'model',
    'internals',
  };

  static const _cookingQuerySignals = {'cooking', 'recipe', 'recipes', 'cook'};

  static const _cookingContextSignals = {
    'cooking',
    'recipe',
    'recipes',
    'cook',
    'food',
    'meal',
  };
}

class _ScoredContextResult {
  const _ScoredContextResult({required this.result, required this.score});

  final LocalRagSearchResult result;
  final double score;
}
