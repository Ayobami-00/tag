import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tag/core/ai/schemas/card_proposal_schema.dart';
import 'package:tag/core/ai/cactus/cactus_model_registry.dart';
import 'package:tag/core/ai/cactus/cactus_model_service.dart';
import 'package:tag/core/ai/rag/local_rag_service.dart';
import 'package:tag/core/ai/rag/rag_models.dart';
import 'package:tag/core/local_storage/database/data_sources/card_local_data_source.dart';
import 'package:tag/core/local_storage/database/tag_database.dart';
import 'package:tag/features/cards/data/repositories/card_repository_impl.dart';
import 'package:tag/features/cards/data/repositories/goal_plan_repository_impl.dart';
import 'package:tag/features/cards/data/repositories/space_repository_impl.dart';
import 'package:tag/features/cards/domain/entities/card_entities.dart';
import 'package:tag/features/cards/domain/repositories/goal_plan_repository.dart';
import 'package:tag/features/cards/domain/use_cases/confirm_goal_plan.dart';
import 'package:tag/features/cards/domain/use_cases/create_goal_cards_from_plan.dart';
import 'package:tag/features/cards/domain/use_cases/edit_goal_plan.dart';
import 'package:tag/features/cards/domain/use_cases/update_future_goal_cards.dart';
import 'package:tag/features/chat/data/data_sources/chat_local_data_source.dart';
import 'package:tag/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:tag/features/chat/domain/entities/chat_entities.dart';
import 'package:tag/features/chat/domain/entities/guided_planning_entities.dart';
import 'package:tag/features/chat/domain/repositories/chat_repository.dart';
import 'package:tag/features/chat/domain/use_cases/ask_saved_context.dart';
import 'package:tag/features/chat/domain/use_cases/generate_goal_plan_preview.dart';
import 'package:tag/features/chat/domain/use_cases/start_fab_chat.dart';
import 'package:tag/features/chat/domain/use_cases/start_plan_this_chat.dart';
import 'package:tag/features/chat/presentation/logic/chat_cubit.dart';
import 'package:tag/features/model_setup/domain/repositories/model_setup_repository.dart';
import 'package:tag/features/source_ingestion/data/data_sources/source_local_data_source.dart';
import 'package:tag/features/source_ingestion/data/repositories/source_repository_impl.dart';

void main() {
  late TagDatabase database;
  late ChatRepository chatRepository;
  late CardRepositoryImpl cardRepository;
  late GoalPlanRepository goalPlanRepository;
  late SourceRepositoryImpl sourceRepository;
  late StartPlanThisChat startPlanThisChat;
  late ChatCubit cubit;
  late _FakeCactusModelService cactusModelService;

  setUp(() {
    database = TagDatabase.forTesting(NativeDatabase.memory());
    chatRepository = ChatRepositoryImpl(
      localDataSource: DriftChatLocalDataSource(database),
      now: () => DateTime.utc(2026, 5, 15, 12),
    );
    final spaceRepository = SpaceRepositoryImpl(
      database: database,
      now: () => DateTime.utc(2026, 5, 15, 12),
    );
    cardRepository = CardRepositoryImpl(
      database: database,
      localDataSource: DriftCardLocalDataSource(database),
      spaceRepository: spaceRepository,
      now: () => DateTime.utc(2026, 5, 15, 12),
    );
    goalPlanRepository = GoalPlanRepositoryImpl(
      database: database,
      spaceRepository: spaceRepository,
      now: () => DateTime.utc(2026, 5, 15, 12),
    );
    sourceRepository = SourceRepositoryImpl(
      localDataSource: DriftSourceLocalDataSource(database),
      now: () => DateTime.utc(2026, 5, 15, 12),
    );
    startPlanThisChat = StartPlanThisChat(chatRepository);
    cactusModelService = _FakeCactusModelService();
    cubit = ChatCubit(
      startFabChat: StartFabChat(chatRepository),
      chatRepository: chatRepository,
      askSavedContext: AskSavedContext(
        localRagService: _FakeRagService(),
        cactusModelService: cactusModelService,
        modelSetupRepository: const _FakeModelSetupRepository(),
      ),
      generateGoalPlanPreview: GenerateGoalPlanPreview(
        chatRepository: chatRepository,
        cardRepository: cardRepository,
        sourceRepository: sourceRepository,
        cactusModelService: cactusModelService,
        modelSetupRepository: const _FakeModelSetupRepository(),
        now: () => DateTime.utc(2026, 5, 15, 12),
      ),
      confirmGoalPlan: ConfirmGoalPlan(
        chatRepository: chatRepository,
        createGoalCardsFromPlan: CreateGoalCardsFromPlan(
          goalPlanRepository: goalPlanRepository,
        ),
      ),
      editGoalPlan: EditGoalPlan(
        goalPlanRepository: goalPlanRepository,
        updateFutureGoalCards: UpdateFutureGoalCards(
          goalPlanRepository: goalPlanRepository,
        ),
      ),
    );
  });

  tearDown(() async {
    await cubit.close();
    await database.close();
  });

  test('opening FAB chat creates a persisted chat session', () async {
    await cubit.open();

    expect(cubit.state.session, isNotNull);
    expect(cubit.state.session!.title, 'Ask Tag');

    final sessions = await database.select(database.chatSessions).get();
    expect(sessions, hasLength(1));
    expect(sessions.single.purpose, 'general');
  });

  test('stores user and assistant messages without creating cards', () async {
    await cubit.open();

    await cubit.ask('What CUDA resources have I saved?');

    final messages = await database.select(database.chatMessages).get();
    final cards = await database.select(database.tagCards).get();

    expect(messages, hasLength(2));
    expect(messages.first.role, 'user');
    expect(messages.first.content, 'What CUDA resources have I saved?');
    expect(messages.last.role, 'assistant');
    expect(messages.last.content, contains('CUDA'));
    expect(messages.last.sourceIdsJson, contains('src_cuda'));
    expect(messages.last.cardIdsJson, contains('card_cuda'));
    expect(cactusModelService.lastOptions, isNull);
    expect(cards, isEmpty);
  });

  test(
    'uses local model synthesis for open-ended saved-context chat',
    () async {
      await cubit.open();

      await cubit.ask('What should I do next for my saved learning resources?');

      final messages = await database.select(database.chatMessages).get();

      expect(messages, hasLength(2));
      expect(messages.last.content, contains('CUDA'));
      expect(messages.last.sourceIdsJson, contains('src_cuda'));
      expect(cactusModelService.lastOptions?.localOnly, isTrue);
    },
  );

  test('Plan this creates a linked guided chat from a suggestion', () async {
    final suggestion = await _seedRustSuggestion(database, cardRepository);

    final session = await startPlanThisChat(
      StartPlanThisChatParams(suggestionCard: suggestion),
    );
    final messages = await chatRepository.loadMessages(session.id);

    expect(session.title, 'Plan this: Learn Rust');
    expect(session.purpose, ChatPurpose.planSuggestion);
    expect(session.linkedCardId, suggestion.id);
    expect(session.linkedSpaceId, suggestion.space.id);
    expect(messages, hasLength(1));
    expect(messages.single.content, contains('How would you like'));
    expect(messages.single.contentJson, contains('plan_style_choices'));
    expect(messages.single.contentJson, contains('4-week plan'));
  });

  test(
    'guided choices store pending preview without creating plans or cards',
    () async {
      cactusModelService.queueResponse(
        jsonEncode({
          'goal_name': 'Learn Rust',
          'space_name': 'Learn Rust',
          'duration_weeks': 4,
          'preferred_days': ['Saturday'],
          'cards': [
            {
              'title': 'Rust basics and ownership',
              'reason': 'Part of your Rust learning plan.',
              'scheduled_for': '2026-05-23T10:00:00+01:00',
              'source_ids': ['src_rust'],
            },
            {
              'title': 'Borrowing and lifetimes',
              'reason': 'Builds on the saved Rust resources.',
              'scheduled_for': '2026-05-30T10:00:00+01:00',
              'source_ids': ['src_rust'],
            },
          ],
        }),
      );
      final suggestion = await _seedRustSuggestion(database, cardRepository);
      final session = await startPlanThisChat(
        StartPlanThisChatParams(suggestionCard: suggestion),
      );

      await cubit.open(chatSessionId: session.id);
      await _waitForMessageCount(cubit, 1);
      await cubit.selectPlanStyle(PlanStyleChoice.fourWeek);
      await _waitForMessageCount(cubit, 3);

      expect(
        cubit.state.messages.last.content,
        'How much time can you spend each week?',
      );
      expect(cubit.state.messages.last.contentJson, contains('three_hours'));

      await cubit.selectWeeklyTime(WeeklyTimeChoice.threeHours);
      await _waitForMessageCount(cubit, 5);

      final updatedSession = await chatRepository.getSession(session.id);
      final pending =
          jsonDecode(updatedSession!.pendingConfirmationJson!)
              as Map<String, dynamic>;
      final goalPlans = await database.select(database.goalPlans).get();
      final goalPlanCards = await database.select(database.goalPlanCards).get();
      final goalCards = await (database.select(
        database.tagCards,
      )..where((card) => card.cardType.equals('goal'))).get();
      final notifications = await database
          .select(database.notificationRequests)
          .get();

      expect(cactusModelService.lastOptions?.localOnly, isTrue);
      expect(pending['type'], 'create_goal_plan');
      expect(pending['requires_confirmation'], isTrue);
      expect(pending['origin_card_id'], suggestion.id);
      expect(pending['plan_style'], 'four_week');
      expect(pending['weekly_time_minutes'], 180);
      expect(pending['preview'], isA<Map<String, dynamic>>());
      expect(cubit.state.messages.last.content, contains('2 Goal Cards'));
      expect(
        cubit.state.messages.last.contentJson,
        contains('goal_plan_preview'),
      );
      expect(goalPlans, isEmpty);
      expect(goalPlanCards, isEmpty);
      expect(goalCards, isEmpty);
      expect(notifications, isEmpty);
    },
  );

  test(
    'guided planning falls back to source-backed preview when model JSON fails',
    () async {
      cactusModelService.queueResponse('not json');
      cactusModelService.queueResponse('still not json');
      final suggestion = await _seedRustSuggestion(database, cardRepository);
      final session = await startPlanThisChat(
        StartPlanThisChatParams(suggestionCard: suggestion),
      );

      await cubit.open(chatSessionId: session.id);
      await _waitForMessageCount(cubit, 1);
      await cubit.selectPlanStyle(PlanStyleChoice.weekend);
      await _waitForMessageCount(cubit, 3);
      await cubit.selectWeeklyTime(WeeklyTimeChoice.oneHour);
      await _waitForMessageCount(cubit, 5);

      final updatedSession = await chatRepository.getSession(session.id);
      final pending =
          jsonDecode(updatedSession!.pendingConfirmationJson!)
              as Map<String, dynamic>;
      final preview = pending['preview'] as Map<String, dynamic>;
      final cards = preview['cards'] as List<dynamic>;
      final goalCards = await (database.select(
        database.tagCards,
      )..where((card) => card.cardType.equals('goal'))).get();

      expect(cubit.state.status, ChatLoadStatus.ready);
      expect(pending['requires_confirmation'], isTrue);
      expect(preview['duration_weeks'], 1);
      expect(cards, hasLength(1));
      expect(cards.single.toString(), contains('src_rust'));
      expect(
        cubit.state.messages.last.contentJson,
        contains('goal_plan_preview'),
      );
      expect(goalCards, isEmpty);
    },
  );
}

Future<TagCardEntity> _seedRustSuggestion(
  TagDatabase database,
  CardRepositoryImpl cardRepository,
) async {
  await _insertSource(database, id: 'src_rust');

  return cardRepository.createFromProposal(
    proposal: CardProposal.fromJson({
      'card_type': 'suggestion',
      'title': 'Goal detected: Learn Rust',
      'reason': '8 Rust resources saved this week.',
      'space_name': 'Learning',
      'next_active_deadline': null,
      'source_ids': ['src_rust'],
      'actions': ['plan_this', 'dismiss'],
      'confidence': 0.88,
    }),
    modelSlug: CactusModelRegistry.primaryModelSlug,
  );
}

Future<void> _insertSource(TagDatabase database, {required String id}) async {
  final now = DateTime.utc(2026, 5, 15, 12).millisecondsSinceEpoch;

  await database
      .into(database.sourceItems)
      .insert(
        SourceItemsCompanion.insert(
          id: id,
          type: 'text',
          sourceSummary: const Value('8 Rust resources'),
          appSource: const Value('Manual'),
          contentType: const Value('article'),
          rawText: const Value(
            'Rust ownership, borrowing, lifetimes, async Rust, and CLI notes.',
          ),
          extractedText: const Value(
            'Rust ownership, borrowing, lifetimes, async Rust, and CLI notes.',
          ),
          createdAt: now,
          updatedAt: now,
        ),
      );
}

Future<void> _waitForMessageCount(
  ChatCubit cubit,
  int count, {
  int attempts = 20,
}) async {
  for (var attempt = 0; attempt < attempts; attempt++) {
    if (cubit.state.messages.length >= count) {
      return;
    }
    await Future<void>.delayed(Duration.zero);
  }

  throw TestFailure('Expected at least $count chat messages.');
}

class _FakeRagService implements LocalRagService {
  @override
  Future<List<LocalRagSearchResult>> search({
    required String query,
    int topK = 8,
    String? embeddingModelSlug,
  }) async {
    final now = DateTime.utc(2026, 5, 15, 10).millisecondsSinceEpoch;
    return [
      LocalRagSearchResult(
        rank: 1,
        score: 0.91,
        chunk: RagSourceChunk(
          id: 'chunk_src_cuda_0',
          sourceId: 'src_cuda',
          chunkIndex: 0,
          chunkText: 'CUDA memory hierarchy notes.',
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
      ),
    ];
  }

  @override
  Future<LocalRagIndexStatus> getIndexStatus({String? embeddingModelSlug}) {
    throw UnimplementedError();
  }

  @override
  Future<LocalRagIndexResult> indexSource({
    required String sourceId,
    required String text,
    String? embeddingModelSlug,
  }) {
    throw UnimplementedError();
  }
}

class _FakeCactusModelService implements CactusModelService {
  final List<String> _queuedResponses = <String>[];
  AiCompletionOptions? lastOptions;

  void queueResponse(String response) {
    _queuedResponses.add(response);
  }

  @override
  Future<AiCompletionResult> complete({
    required String modelSlug,
    required List<AiChatMessage> messages,
    List<AiToolSchema> tools = const [],
    AiCompletionOptions options = const AiCompletionOptions(),
  }) async {
    lastOptions = options;
    if (_queuedResponses.isNotEmpty) {
      return AiCompletionResult(response: _queuedResponses.removeAt(0));
    }

    return AiCompletionResult(
      response: jsonEncode({
        'answer': 'You saved CUDA memory hierarchy notes.',
        'reasoning_summary':
            'The local CUDA source and related Goal Card match.',
        'source_cards': ['card_cuda'],
        'source_ids': ['src_cuda'],
        'card_ids': ['card_cuda'],
        'optional_action': null,
      }),
    );
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
