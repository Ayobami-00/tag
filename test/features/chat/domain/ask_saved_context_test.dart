import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tag/core/ai/cactus/cactus_model_registry.dart';
import 'package:tag/core/ai/cactus/cactus_model_service.dart';
import 'package:tag/core/ai/rag/local_rag_service.dart';
import 'package:tag/core/ai/rag/rag_models.dart';
import 'package:tag/features/chat/domain/use_cases/ask_saved_context.dart';
import 'package:tag/features/model_setup/domain/repositories/model_setup_repository.dart';

void main() {
  test(
    'answers saved-context questions without waiting for Cactus by default',
    () async {
      final events = <String>[];
      final cactusService = _FakeCactusModelService(events: events);
      final useCase = AskSavedContext(
        localRagService: _FakeRagService(events: events),
        cactusModelService: cactusService,
        modelSetupRepository: const _FakeModelSetupRepository(),
      );

      final result = await useCase(
        const AskSavedContextParams(query: 'What CUDA resources have I saved?'),
      );

      expect(events, ['rag']);
      expect(cactusService.lastMessages, isEmpty);
      expect(result.rawModelOutput, isEmpty);
      expect(result.answer.answer, contains('CUDA memory hierarchy'));
      expect(result.answer.sourceIds, ['src_cuda']);
      expect(result.answer.cardIds, ['card_cuda']);
    },
  );

  test(
    'queries local RAG before asking Cactus for a source-backed answer',
    () async {
      final events = <String>[];
      final ragService = _FakeRagService(events: events);
      final cactusService = _FakeCactusModelService(
        events: events,
        response: jsonEncode({
          'answer': 'You saved a CUDA memory hierarchy article.',
          'reasoning_summary': 'The answer is grounded in the CUDA source.',
          'source_cards': ['card_cuda'],
          'source_ids': ['src_cuda'],
          'card_ids': ['card_cuda'],
          'optional_action': null,
        }),
      );
      final useCase = AskSavedContext(
        localRagService: ragService,
        cactusModelService: cactusService,
        modelSetupRepository: const _FakeModelSetupRepository(),
      );

      final result = await useCase(
        const AskSavedContextParams(
          query: 'What CUDA resources have I saved?',
          useModelSynthesis: true,
        ),
      );

      expect(events, ['rag', 'model']);
      expect(cactusService.lastOptions?.localOnly, isTrue);
      expect(cactusService.lastMessages.last.content, contains('src_cuda'));
      expect(cactusService.lastMessages.last.content, contains('card_cuda'));
      expect(result.answer.answer, contains('CUDA memory hierarchy'));
      expect(result.answer.sourceIds, ['src_cuda']);
      expect(result.answer.cardIds, ['card_cuda']);
      expect(
        result.answer.sourceCitations.single.label,
        'CUDA memory hierarchy',
      );
    },
  );

  test('repairs hallucinated citations instead of inventing one', () async {
    final events = <String>[];
    final cactusService = _FakeCactusModelService(
      events: events,
      responses: [
        jsonEncode({
          'answer': 'The CUDA resource is the strongest match.',
          'reasoning_summary': 'The local CUDA source supports the answer.',
          'source_cards': ['card_not_local'],
          'source_ids': ['src_not_local'],
          'card_ids': ['card_not_local'],
          'optional_action': null,
        }),
        jsonEncode({
          'answer': 'The CUDA resource is the saved note.',
          'reasoning_summary': 'The local CUDA source supports the answer.',
          'source_cards': ['card_cuda'],
          'source_ids': ['src_cuda'],
          'card_ids': ['card_cuda'],
          'optional_action': null,
        }),
      ],
    );
    final useCase = AskSavedContext(
      localRagService: _FakeRagService(events: events),
      cactusModelService: cactusService,
      modelSetupRepository: const _FakeModelSetupRepository(),
    );

    final result = await useCase(
      const AskSavedContextParams(
        query: 'What CUDA resources have I saved?',
        useModelSynthesis: true,
      ),
    );

    expect(events, ['rag', 'model', 'model']);
    expect(
      cactusService.lastMessages.last.content,
      contains('Source-backed answers must cite at least one local source.'),
    );
    expect(result.answer.sourceIds, ['src_cuda']);
    expect(result.answer.cardIds, ['card_cuda']);
  });

  test('repairs malformed local model JSON before accepting answer', () async {
    final events = <String>[];
    final cactusService = _FakeCactusModelService(
      events: events,
      responses: [
        '{ malformed',
        jsonEncode({
          'answer': 'The CUDA note is the saved resource.',
          'reasoning_summary': 'The local CUDA source supports the answer.',
          'source_cards': ['card_cuda'],
          'source_ids': ['src_cuda'],
          'card_ids': ['card_cuda'],
          'optional_action': null,
        }),
      ],
    );
    final useCase = AskSavedContext(
      localRagService: _FakeRagService(events: events),
      cactusModelService: cactusService,
      modelSetupRepository: const _FakeModelSetupRepository(),
    );

    final result = await useCase(
      const AskSavedContextParams(
        query: 'What CUDA resources have I saved?',
        useModelSynthesis: true,
      ),
    );

    expect(events, ['rag', 'model', 'model']);
    expect(cactusService.lastOptions?.localOnly, isTrue);
    expect(
      cactusService.lastMessages.last.content,
      contains('The previous output was invalid'),
    );
    expect(result.answer.sourceIds, ['src_cuda']);
    expect(result.rawModelOutput, contains('The CUDA note'));
  });

  test(
    'falls back to retrieved evidence when model repair remains invalid',
    () async {
      final events = <String>[];
      final useCase = AskSavedContext(
        localRagService: _FakeRagService(events: events),
        cactusModelService: _FakeCactusModelService(
          events: events,
          responses: ['not json', 'still not json'],
        ),
        modelSetupRepository: const _FakeModelSetupRepository(),
      );

      final result = await useCase(
        const AskSavedContextParams(
          query: 'What CUDA resources have I saved?',
          useModelSynthesis: true,
        ),
      );

      expect(events, ['rag', 'model', 'model']);
      expect(result.answer.answer, contains('CUDA memory hierarchy'));
      expect(result.answer.sourceIds, ['src_cuda']);
      expect(result.answer.cardIds, ['card_cuda']);
    },
  );

  test(
    'falls back to retrieved evidence when model synthesis times out',
    () async {
      final events = <String>[];
      final useCase = AskSavedContext(
        localRagService: _FakeRagService(events: events),
        cactusModelService: _FakeCactusModelService(
          events: events,
          delay: const Duration(milliseconds: 10),
          response: jsonEncode({
            'answer': 'The CUDA note is the saved resource.',
            'reasoning_summary': 'The local CUDA source supports the answer.',
            'source_ids': ['src_cuda'],
            'card_ids': ['card_cuda'],
            'optional_action': null,
          }),
        ),
        modelSetupRepository: const _FakeModelSetupRepository(),
        modelSynthesisTimeout: const Duration(milliseconds: 1),
      );

      final result = await useCase(
        const AskSavedContextParams(
          query: 'What should I do next for my saved CUDA resources?',
          useModelSynthesis: true,
        ),
      );

      expect(events, ['rag', 'model']);
      expect(result.rawModelOutput, isEmpty);
      expect(result.answer.answer, contains('CUDA memory hierarchy'));
      expect(result.answer.sourceIds, ['src_cuda']);
      expect(result.answer.cardIds, ['card_cuda']);
    },
  );

  test(
    'rejects generic model answers before falling back to citations',
    () async {
      final events = <String>[];
      final useCase = AskSavedContext(
        localRagService: _FakeRagService(events: events),
        cactusModelService: _FakeCactusModelService(
          events: events,
          responses: [
            jsonEncode({
              'answer': 'Saved source',
              'reasoning_summary': 'Saved source',
              'source_ids': ['src_cuda'],
              'card_ids': ['card_cuda'],
              'optional_action': null,
            }),
            'still not json',
          ],
        ),
        modelSetupRepository: const _FakeModelSetupRepository(),
      );

      final result = await useCase(
        const AskSavedContextParams(
          query: 'What CUDA resources have I saved?',
          useModelSynthesis: true,
        ),
      );

      expect(events, ['rag', 'model', 'model']);
      expect(result.answer.answer, contains('CUDA memory hierarchy'));
      expect(result.answer.answer, isNot(equals('Saved source')));
      expect(result.answer.sourceIds, ['src_cuda']);
    },
  );

  test(
    'why-create card questions are not treated as mutation requests',
    () async {
      final events = <String>[];
      final useCase = AskSavedContext(
        localRagService: _FakeRagService(events: events),
        cactusModelService: _FakeCactusModelService(
          events: events,
          responses: ['not json', 'still not json'],
        ),
        modelSetupRepository: const _FakeModelSetupRepository(),
      );

      final result = await useCase(
        const AskSavedContextParams(
          query: 'Why did you create the CUDA card?',
          useModelSynthesis: true,
        ),
      );

      expect(
        result.answer.answer,
        isNot(contains('without your confirmation')),
      );
      expect(result.answer.cardIds, ['card_cuda']);
    },
  );

  test(
    'returns honest no-result answer when retrieved context is irrelevant',
    () async {
      final events = <String>[];
      final useCase = AskSavedContext(
        localRagService: _FakeRagService(events: events),
        cactusModelService: _FakeCactusModelService(events: events),
        modelSetupRepository: const _FakeModelSetupRepository(),
      );

      final result = await useCase(
        const AskSavedContextParams(query: 'Do I have cooking recipes?'),
      );

      expect(events, ['rag']);
      expect(result.answer.sourceIds, isEmpty);
      expect(result.answer.answer, contains('could not find anything'));
    },
  );

  test(
    'filters unrelated weekend context from personal reminder answers',
    () async {
      final events = <String>[];
      final useCase = AskSavedContext(
        localRagService: _FakeRagService(
          events: events,
          results: [_ukCompanyWeekendResult(), _sisterCallResult()],
        ),
        cactusModelService: _FakeCactusModelService(
          events: events,
          responses: ['not json', 'still not json'],
        ),
        modelSetupRepository: const _FakeModelSetupRepository(),
      );

      final result = await useCase(
        const AskSavedContextParams(
          query: 'What personal reminders do I have this weekend?',
        ),
      );

      expect(result.answer.sourceIds, ['src_sister']);
      expect(result.answer.cardIds, ['card_sister']);
      expect(result.answer.answer, contains('Call your sister this weekend'));
      expect(result.answer.answer, isNot(contains('UK founder')));
    },
  );

  test(
    'keeps learning cohort applications out of job follow-up answers',
    () async {
      final events = <String>[];
      final ragService = _FakeRagService(
        events: events,
        results: [_aiSaturdaysApplicationResult(), _waveJobApplicationResult()],
      );
      final useCase = AskSavedContext(
        localRagService: ragService,
        cactusModelService: _FakeCactusModelService(
          events: events,
          responses: ['not json', 'still not json'],
        ),
        modelSetupRepository: const _FakeModelSetupRepository(),
      );

      final result = await useCase(
        const AskSavedContextParams(
          query: 'What job applications do I need to follow up on?',
        ),
      );

      expect(result.answer.sourceIds, ['src_wave']);
      expect(result.answer.cardIds, ['card_wave']);
      expect(result.answer.answer, contains('Senior Applied AI Scientist'));
      expect(result.answer.answer, isNot(contains('AI Saturdays')));
      expect(ragService.lastQuery, contains('linkedin'));
      expect(ragService.lastQuery, contains('recruiter'));
    },
  );

  test(
    'cleans screenshot chrome from deterministic fallback evidence',
    () async {
      final useCase = AskSavedContext(
        localRagService: _FakeRagService(results: [_noisyUkCompanyResult()]),
        cactusModelService: _FakeCactusModelService(),
        modelSetupRepository: const _FakeModelSetupRepository(),
      );

      final result = await useCase(
        const AskSavedContextParams(
          query: 'What UK company formation information have I saved?',
        ),
      );

      expect(result.answer.answer, contains('UK founder starter pack'));
      expect(result.answer.answer, contains('incorporate via Companies House'));
      expect(result.answer.answer, isNot(contains('21:05')));
      expect(result.answer.answer, isNot(contains('5G')));
      expect(result.answer.answer, isNot(contains('Post')));
    },
  );

  test('keeps internal source ids out of user-facing answer text', () async {
    final useCase = AskSavedContext(
      localRagService: _FakeRagService(
        results: [_ukCompanyReasonWithInternalIdResult()],
      ),
      cactusModelService: _FakeCactusModelService(),
      modelSetupRepository: const _FakeModelSetupRepository(),
    );

    final result = await useCase(
      const AskSavedContextParams(
        query: 'What UK company formation information have I saved?',
      ),
    );

    expect(result.answer.sourceIds, ['src_uk_internal']);
    expect(result.answer.answer, contains('UK company creation starter pack'));
    expect(result.answer.answer, isNot(contains('src_uk_internal')));
    expect(result.answer.answer, isNot(contains(RegExp(r'\bsrc_'))));
  });
}

class _FakeRagService implements LocalRagService {
  _FakeRagService({List<String>? events, List<LocalRagSearchResult>? results})
    : events = events ?? <String>[],
      results = results ?? [_ragResult()];

  final List<String> events;
  final List<LocalRagSearchResult> results;
  String? lastQuery;

  @override
  Future<List<LocalRagSearchResult>> search({
    required String query,
    int topK = 8,
    String? embeddingModelSlug,
  }) async {
    events.add('rag');
    lastQuery = query;
    return results;
  }

  @override
  Future<LocalRagIndexStatus> getIndexStatus({
    String? embeddingModelSlug,
  }) async {
    return LocalRagIndexStatus(
      indexName: 'tag_nomic2',
      embeddingModelSlug: CactusModelRegistry.defaultEmbeddingModelSlug,
      embeddingDimension: 256,
      chunkCount: 1,
      recordCount: 1,
      staleRecordCount: 0,
      updatedAt: DateTime.utc(2026, 5, 15),
    );
  }

  @override
  Future<LocalRagIndexResult> indexSource({
    required String sourceId,
    required String text,
    String? embeddingModelSlug,
  }) async {
    throw UnimplementedError();
  }
}

class _FakeCactusModelService implements CactusModelService {
  _FakeCactusModelService({
    String? response,
    List<String>? responses,
    List<String>? events,
    this.delay = Duration.zero,
  }) : responses = List<String>.from(responses ?? [response ?? '{}']),
       events = events ?? <String>[];

  final List<String> responses;
  final List<String> events;
  final Duration delay;
  List<AiChatMessage> lastMessages = const [];
  AiCompletionOptions? lastOptions;

  @override
  Future<AiCompletionResult> complete({
    required String modelSlug,
    required List<AiChatMessage> messages,
    List<AiToolSchema> tools = const [],
    AiCompletionOptions options = const AiCompletionOptions(),
  }) async {
    if (events.isNotEmpty) {
      expect(events, contains('rag'));
    }
    events.add('model');
    lastMessages = messages;
    lastOptions = options;
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    final nextResponse = responses.length > 1
        ? responses.removeAt(0)
        : responses.first;
    return AiCompletionResult(response: nextResponse);
  }

  @override
  Future<List<LocalAiModelInfo>> getAvailableModels() async => const [];

  @override
  Future<void> downloadModel(
    String slug, {
    void Function(ModelDownloadProgress progress)? onProgress,
  }) async {}

  @override
  Future<void> initializeModel(String slug) async {}

  @override
  Future<void> unloadModel(String slug) async {}

  @override
  Stream<String> streamComplete({
    required String modelSlug,
    required List<AiChatMessage> messages,
    List<AiToolSchema> tools = const [],
    AiCompletionOptions options = const AiCompletionOptions(),
  }) {
    throw UnimplementedError();
  }

  @override
  Future<AiEmbeddingResult> embedText({
    required String modelSlug,
    required String text,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<AiVisionResult> completeWithImage({
    required String modelSlug,
    required String imagePath,
    required List<AiChatMessage> messages,
    List<AiToolSchema> tools = const [],
    AiCompletionOptions options = const AiCompletionOptions(),
  }) {
    throw UnimplementedError();
  }
}

class _FakeModelSetupRepository implements ModelSetupRepository {
  const _FakeModelSetupRepository();

  @override
  Future<String> loadSelectedPrimaryModelSlug() async {
    return CactusModelRegistry.primaryModelSlug;
  }

  @override
  Future<String> loadSelectedEmbeddingModelSlug() async {
    return CactusModelRegistry.defaultEmbeddingModelSlug;
  }

  @override
  Future<List<LocalAiModelInfo>> discoverModels() async => const [];

  @override
  Future<List<LocalAiModelInfo>> loadCachedModels() async => const [];

  @override
  Future<void> prepareRequiredModels({
    void Function(ModelPreparationProgress progress)? onProgress,
  }) async {}

  @override
  Future<void> downloadModel(
    String slug, {
    void Function(ModelDownloadProgress progress)? onProgress,
  }) async {}

  @override
  Future<void> initializeModel(String slug) async {}

  @override
  Future<void> selectEmbeddingModel(String slug) async {}

  @override
  Future<void> selectPrimaryModel(String slug) async {}
}

LocalRagSearchResult _ragResult() {
  final now = DateTime.utc(2026, 5, 15, 10).millisecondsSinceEpoch;
  return LocalRagSearchResult(
    rank: 1,
    score: 0.91,
    chunk: RagSourceChunk(
      id: 'chunk_src_cuda_0',
      sourceId: 'src_cuda',
      chunkIndex: 0,
      chunkText: 'CUDA memory hierarchy notes and shared memory resources.',
      createdAt: now,
      updatedAt: now,
    ),
    source: RagSourceSnapshot(
      id: 'src_cuda',
      type: 'text',
      contentType: 'article',
      processingState: 'completed',
      sourceSummary: 'CUDA article notes',
      createdAt: now,
      updatedAt: now,
    ),
    relatedCards: [
      RagRelatedCardSnapshot(
        cardId: 'card_cuda',
        cardType: 'goal',
        status: 'active',
        title: 'CUDA memory hierarchy',
        spaceName: 'Learn CUDA',
        reason: 'Saved as part of CUDA learning.',
        sourceSummary: 'CUDA article notes',
        evidenceText: 'CUDA memory hierarchy notes',
      ),
    ],
  );
}

LocalRagSearchResult _ukCompanyWeekendResult() {
  final now = DateTime.utc(2026, 5, 15, 10).millisecondsSinceEpoch;
  return LocalRagSearchResult(
    rank: 1,
    score: 0.8,
    chunk: RagSourceChunk(
      id: 'chunk_src_uk_0',
      sourceId: 'src_uk',
      chunkIndex: 0,
      chunkText:
          'UK founder starter pack to incorporate a company in a weekend.',
      createdAt: now,
      updatedAt: now,
    ),
    source: RagSourceSnapshot(
      id: 'src_uk',
      type: 'screenshot',
      contentType: 'post',
      processingState: 'completed',
      sourceSummary: 'UK founder starter pack',
      createdAt: now,
      updatedAt: now,
    ),
  );
}

LocalRagSearchResult _noisyUkCompanyResult() {
  final now = DateTime.utc(2026, 5, 15, 10).millisecondsSinceEpoch;
  return LocalRagSearchResult(
    rank: 1,
    score: 0.84,
    chunk: RagSourceChunk(
      id: 'chunk_src_uk_noisy_0',
      sourceId: 'src_uk_noisy',
      chunkIndex: 0,
      chunkText:
          '21:05 •ll 5G 40 Post ••• Wiktoria Milczynska X.com UK founder starter pack: incorporate via Companies House, keep records, prepare a bank account.',
      createdAt: now,
      updatedAt: now,
    ),
    source: RagSourceSnapshot(
      id: 'src_uk_noisy',
      type: 'screenshot',
      contentType: 'post',
      processingState: 'completed',
      sourceSummary: 'Saved source',
      createdAt: now,
      updatedAt: now,
    ),
  );
}

LocalRagSearchResult _ukCompanyReasonWithInternalIdResult() {
  final now = DateTime.utc(2026, 5, 15, 10).millisecondsSinceEpoch;
  return LocalRagSearchResult(
    rank: 1,
    score: 0.84,
    chunk: RagSourceChunk(
      id: 'chunk_src_uk_internal_0',
      sourceId: 'src_uk_internal',
      chunkIndex: 0,
      chunkText:
          'UK founder starter pack: incorporate via Companies House, prepare a bank account, and keep company records.',
      createdAt: now,
      updatedAt: now,
    ),
    source: RagSourceSnapshot(
      id: 'src_uk_internal',
      type: 'screenshot',
      contentType: 'post',
      processingState: 'completed',
      sourceSummary: 'UK company creation starter pack',
      createdAt: now,
      updatedAt: now,
    ),
    relatedCards: [
      RagRelatedCardSnapshot(
        cardId: 'card_uk_internal',
        cardType: 'suggestion',
        status: 'active',
        title: 'Save UK company creation starter pack',
        spaceName: 'Company setup',
        reason:
            'The source explicitly says to save the UK company starter pack (src_uk_internal).',
        sourceSummary: 'UK company creation starter pack',
        evidenceText: 'UK founder starter pack',
      ),
    ],
  );
}

LocalRagSearchResult _sisterCallResult() {
  final now = DateTime.utc(2026, 5, 15, 10).millisecondsSinceEpoch;
  return LocalRagSearchResult(
    rank: 2,
    score: 0.74,
    chunk: RagSourceChunk(
      id: 'chunk_src_sister_0',
      sourceId: 'src_sister',
      chunkIndex: 0,
      chunkText: 'Message from sister asking to schedule a call this weekend.',
      createdAt: now,
      updatedAt: now,
    ),
    source: RagSourceSnapshot(
      id: 'src_sister',
      type: 'screenshot',
      contentType: 'message',
      processingState: 'completed',
      sourceSummary: 'Call your sister this weekend',
      createdAt: now,
      updatedAt: now,
    ),
    relatedCards: [
      RagRelatedCardSnapshot(
        cardId: 'card_sister',
        cardType: 'urgent',
        status: 'active',
        title: 'Call your sister this weekend',
        spaceName: 'Family',
        reason: 'The saved message asks you to schedule a family call.',
        sourceSummary: 'Call your sister this weekend',
        evidenceText: 'Schedule call for this weekend',
      ),
    ],
  );
}

LocalRagSearchResult _aiSaturdaysApplicationResult() {
  final now = DateTime.utc(2026, 5, 15, 10).millisecondsSinceEpoch;
  return LocalRagSearchResult(
    rank: 1,
    score: 0.81,
    chunk: RagSourceChunk(
      id: 'chunk_src_ai_saturdays_0',
      sourceId: 'src_ai_saturdays',
      chunkIndex: 0,
      chunkText: 'Final call for applications to an AI Saturdays cohort.',
      createdAt: now,
      updatedAt: now,
    ),
    source: RagSourceSnapshot(
      id: 'src_ai_saturdays',
      type: 'screenshot',
      contentType: 'job_post',
      processingState: 'completed',
      sourceSummary: 'Complete TRI AI Saturdays Cohort 10 application',
      createdAt: now,
      updatedAt: now,
    ),
    relatedCards: [
      RagRelatedCardSnapshot(
        cardId: 'card_ai_saturdays',
        cardType: 'urgent',
        status: 'active',
        title: 'Complete TRI AI Saturdays Cohort 10 application',
        spaceName: 'AI Saturdays',
        reason: 'The saved source shows an application deadline for a cohort.',
        sourceSummary: 'Complete TRI AI Saturdays Cohort 10 application',
        evidenceText: 'Applications close for the AI Saturdays cohort.',
      ),
    ],
  );
}

LocalRagSearchResult _waveJobApplicationResult() {
  final now = DateTime.utc(2026, 5, 15, 10).millisecondsSinceEpoch;
  return LocalRagSearchResult(
    rank: 2,
    score: 0.78,
    chunk: RagSourceChunk(
      id: 'chunk_src_wave_0',
      sourceId: 'src_wave',
      chunkIndex: 0,
      chunkText: 'LinkedIn Senior Applied AI Scientist Opportunity at Wave.',
      createdAt: now,
      updatedAt: now,
    ),
    source: RagSourceSnapshot(
      id: 'src_wave',
      type: 'screenshot',
      contentType: 'email',
      processingState: 'completed',
      sourceSummary: 'Senior Applied AI Scientist Opportunity at Wave',
      createdAt: now,
      updatedAt: now,
    ),
    relatedCards: [
      RagRelatedCardSnapshot(
        cardId: 'card_wave',
        cardType: 'goal',
        status: 'active',
        title: 'Apply to Senior Applied AI Scientist Opportunity at Wave',
        spaceName: 'Job search',
        reason:
            'The saved source appears to show a job application opportunity.',
        sourceSummary: 'Senior Applied AI Scientist Opportunity at Wave',
        evidenceText: 'LinkedIn Senior Applied AI Scientist Opportunity.',
      ),
    ],
  );
}
