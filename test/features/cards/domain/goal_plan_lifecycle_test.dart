import 'dart:convert';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tag/core/ai/cactus/cactus_model_registry.dart';
import 'package:tag/core/ai/schemas/card_proposal_schema.dart';
import 'package:tag/core/notifications/local_notification_permission_service.dart';
import 'package:tag/core/notifications/local_notification_service.dart';
import 'package:tag/core/notifications/local_notification_service_impl.dart';
import 'package:tag/core/notifications/notification_policy.dart';
import 'package:tag/core/local_storage/database/data_sources/card_local_data_source.dart';
import 'package:tag/core/local_storage/database/tag_database.dart';
import 'package:tag/features/cards/data/repositories/card_repository_impl.dart';
import 'package:tag/features/cards/data/repositories/goal_plan_repository_impl.dart';
import 'package:tag/features/cards/data/repositories/space_repository_impl.dart';
import 'package:tag/features/cards/domain/entities/card_entities.dart';
import 'package:tag/features/cards/domain/entities/card_query.dart';
import 'package:tag/features/cards/domain/repositories/goal_plan_repository.dart';
import 'package:tag/features/cards/domain/use_cases/confirm_goal_plan.dart';
import 'package:tag/features/cards/domain/use_cases/create_goal_cards_from_plan.dart';
import 'package:tag/features/cards/domain/use_cases/edit_goal_plan.dart';
import 'package:tag/features/cards/domain/use_cases/update_future_goal_cards.dart';
import 'package:tag/features/chat/data/data_sources/chat_local_data_source.dart';
import 'package:tag/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:tag/features/chat/domain/entities/chat_entities.dart';
import 'package:tag/features/chat/domain/repositories/chat_repository.dart';

void main() {
  late TagDatabase database;
  late CardRepositoryImpl cardRepository;
  late GoalPlanRepository goalPlanRepository;
  late ChatRepository chatRepository;
  late _RecordingNotificationScheduler scheduler;
  late LocalNotificationServiceImpl notificationService;
  late ConfirmGoalPlan confirmGoalPlan;
  late EditGoalPlan editGoalPlan;

  setUp(() {
    database = TagDatabase.forTesting(NativeDatabase.memory());
    final spaceRepository = SpaceRepositoryImpl(
      database: database,
      now: _fixedNow,
    );
    cardRepository = CardRepositoryImpl(
      database: database,
      localDataSource: DriftCardLocalDataSource(database),
      spaceRepository: spaceRepository,
      now: _fixedNow,
    );
    goalPlanRepository = GoalPlanRepositoryImpl(
      database: database,
      spaceRepository: spaceRepository,
      now: _fixedNow,
    );
    chatRepository = ChatRepositoryImpl(
      localDataSource: DriftChatLocalDataSource(database),
      now: _fixedNow,
    );
    scheduler = _RecordingNotificationScheduler();
    notificationService = LocalNotificationServiceImpl(
      database: database,
      policy: const NotificationPolicy(),
      scheduler: scheduler,
      now: _fixedNow,
    );
    final createGoalCardsFromPlan = CreateGoalCardsFromPlan(
      goalPlanRepository: goalPlanRepository,
      notificationService: notificationService,
    );
    confirmGoalPlan = ConfirmGoalPlan(
      chatRepository: chatRepository,
      createGoalCardsFromPlan: createGoalCardsFromPlan,
    );
    editGoalPlan = EditGoalPlan(
      goalPlanRepository: goalPlanRepository,
      updateFutureGoalCards: UpdateFutureGoalCards(
        goalPlanRepository: goalPlanRepository,
        notificationService: notificationService,
      ),
    );
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'confirming preview creates GoalPlan, child Goal Cards, source links, and notifications',
    () async {
      final session = await _seedPendingGoalPlan(
        database: database,
        cardRepository: cardRepository,
        chatRepository: chatRepository,
        cards: [
          _previewCard(
            title: 'Rust basics and ownership',
            scheduledFor: DateTime.utc(2026, 5, 15, 14),
          ),
          _previewCard(
            title: 'Borrowing and lifetimes',
            scheduledFor: DateTime.utc(2026, 5, 22, 10),
          ),
        ],
      );

      final result = await confirmGoalPlan(
        ConfirmGoalPlanParams(chatSessionId: session.id),
      );

      final goalPlans = await database.select(database.goalPlans).get();
      final goalPlanCards = await database.select(database.goalPlanCards).get();
      final goalCards = await (database.select(
        database.tagCards,
      )..where((card) => card.cardType.equals('goal'))).get();
      final cardSources = await database.select(database.cardSources).get();
      final notifications = await database
          .select(database.notificationRequests)
          .get();
      final suggestion = await (database.select(
        database.tagCards,
      )..where((card) => card.cardType.equals('suggestion'))).getSingle();
      final todayCards = await cardRepository.getCards(
        CardListQuery(
          viewMode: TodayViewMode.today,
          filter: TodayCardFilter.goal,
          now: _fixedNow(),
        ),
      );

      expect(result.goalPlanResult.goalPlan.name, 'Learn Rust');
      expect(result.session.pendingConfirmationJson, isNull);
      expect(
        result.session.linkedGoalPlanId,
        result.goalPlanResult.goalPlan.id,
      );
      expect(goalPlans, hasLength(1));
      expect(goalPlans.single.status, 'active');
      expect(goalPlans.single.createdBy, 'suggestion');
      expect(goalPlanCards, hasLength(2));
      expect(goalPlanCards.map((row) => row.sequenceIndex), [0, 1]);
      expect(goalCards, hasLength(2));
      expect(
        goalCards.every((row) => row.parentGoalPlanId == goalPlans.single.id),
        isTrue,
      );
      expect(
        goalCards.every((row) => row.spaceId == goalPlans.single.spaceId),
        isTrue,
      );
      expect(goalCards.every((row) => row.notificationEnabled), isTrue);
      expect(
        cardSources
            .where(
              (row) => goalCards.map((card) => card.id).contains(row.cardId),
            )
            .map((row) => row.role),
        everyElement(anyOf('primary', 'supporting')),
      );
      expect(suggestion.status, 'dismissed');
      expect(suggestion.metadataJson, contains('accepted_goal_plan_id'));
      expect(notifications, hasLength(2));
      expect(notifications.every((row) => row.status == 'scheduled'), isTrue);
      expect(scheduler.scheduled, hasLength(2));
      expect(
        scheduler.scheduled.every(
          (request) => request.categoryId == NotificationCategoryIds.goal,
        ),
        isTrue,
      );
      expect(
        todayCards.map((card) => card.title),
        contains('Rust basics and ownership'),
      );
    },
  );

  test(
    'editing goal updates future incomplete cards and leaves completed cards untouched',
    () async {
      final session = await _seedPendingGoalPlan(
        database: database,
        cardRepository: cardRepository,
        chatRepository: chatRepository,
        cards: [
          _previewCard(
            title: 'Session 1: Rust setup',
            scheduledFor: DateTime.utc(2026, 5, 18, 10),
          ),
          _previewCard(
            title: 'Session 2: Ownership',
            scheduledFor: DateTime.utc(2026, 5, 19, 10),
          ),
          _previewCard(
            title: 'Session 3: Borrowing',
            scheduledFor: DateTime.utc(2026, 5, 20, 10),
          ),
        ],
      );
      final created = await confirmGoalPlan(
        ConfirmGoalPlanParams(chatSessionId: session.id),
      );
      final firstCard = created.goalPlanResult.cards.first;
      final secondCard = created.goalPlanResult.cards[1];
      final completed = await cardRepository.completeCard(firstCard.id);
      final editSession = await chatRepository.startEditGoalSession(
        title: 'Editing: Learn Rust',
        linkedCardId: secondCard.id,
        linkedSpaceId: secondCard.space.id,
        linkedGoalPlanId: created.goalPlanResult.goalPlan.id,
      );

      final result = await editGoalPlan(
        EditGoalPlanParams(
          session: editSession,
          request:
              'Make it weekend-only and reduce it to 45 minutes per session.',
        ),
      );

      final links = await goalPlanRepository.getGoalPlanCards(
        created.goalPlanResult.goalPlan.id,
      );
      final plan = await goalPlanRepository.getGoalPlanById(
        created.goalPlanResult.goalPlan.id,
      );
      final completedAfter = links.first.card;
      final updatedDeadlines = links
          .skip(1)
          .map((link) {
            return DateTime.fromMillisecondsSinceEpoch(
              link.card.nextActiveDeadline!,
              isUtc: true,
            ).toLocal().weekday;
          })
          .toList(growable: false);

      expect(result.update.updatedCards, hasLength(2));
      expect(result.update.skippedCompletedCards.map((card) => card.id), [
        firstCard.id,
      ]);
      expect(completed.card.status, TagCardStatus.completed);
      expect(completedAfter.title, 'Session 1: Rust setup');
      expect(completedAfter.status, TagCardStatus.completed);
      expect(
        updatedDeadlines,
        everyElement(anyOf(DateTime.saturday, DateTime.sunday)),
      );
      expect(plan!.preferredDays, ['Saturday', 'Sunday']);
      expect(plan.sessionLengthMinutes, 45);
      expect(scheduler.cancelled.length, greaterThanOrEqualTo(2));
    },
  );
}

DateTime _fixedNow() => DateTime.utc(2026, 5, 15, 12);

Map<String, Object?> _previewCard({
  required String title,
  required DateTime scheduledFor,
}) {
  return {
    'title': title,
    'reason': 'Part of your Rust learning plan.',
    'scheduled_for': scheduledFor.toIso8601String(),
    'source_ids': ['src_rust'],
  };
}

Future<ChatSessionEntity> _seedPendingGoalPlan({
  required TagDatabase database,
  required CardRepositoryImpl cardRepository,
  required ChatRepository chatRepository,
  required List<Map<String, Object?>> cards,
}) async {
  await _insertSource(database, id: 'src_rust');
  final suggestion = await cardRepository.createFromProposal(
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
  final session = await chatRepository.startPlanThisSession(
    title: 'Plan this: Learn Rust',
    linkedCardId: suggestion.id,
    linkedSpaceId: suggestion.space.id,
  );
  final pendingConfirmationJson = jsonEncode({
    'type': 'create_goal_plan',
    'origin': 'plan_suggestion',
    'requires_confirmation': true,
    'chat_session_id': session.id,
    'origin_card_id': suggestion.id,
    'space_id': suggestion.space.id,
    'source_ids': ['src_rust'],
    'plan_style': 'four_week',
    'weekly_time': 'three_hours',
    'weekly_time_minutes': 180,
    'model_slug': CactusModelRegistry.primaryModelSlug,
    'created_at': _fixedNow().toIso8601String(),
    'preview': {
      'goal_name': 'Learn Rust',
      'space_name': 'Learn Rust',
      'duration_weeks': 4,
      'preferred_days': ['Saturday'],
      'cards': cards,
    },
  });

  return chatRepository.updatePendingConfirmation(
    sessionId: session.id,
    pendingConfirmationJson: pendingConfirmationJson,
  );
}

Future<void> _insertSource(TagDatabase database, {required String id}) async {
  final existing = await (database.select(
    database.sourceItems,
  )..where((source) => source.id.equals(id))).getSingleOrNull();
  if (existing != null) {
    return;
  }

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
          createdAt: _fixedNow().millisecondsSinceEpoch,
          updatedAt: _fixedNow().millisecondsSinceEpoch,
        ),
      );
}

class _RecordingNotificationScheduler implements NotificationPlatformScheduler {
  final scheduled = <NotificationPlatformRequest>[];
  final cancelled = <int>[];

  @override
  Future<void> initialize({
    required NotificationActionHandler onAction,
  }) async {}

  @override
  Future<NotificationPermissionState> requestPermission() async {
    return NotificationPermissionState.granted;
  }

  @override
  Future<void> schedule(NotificationPlatformRequest request) async {
    scheduled.add(request);
  }

  @override
  Future<void> showNow(NotificationPlatformRequest request) async {}

  @override
  Future<void> cancel(int platformNotificationId) async {
    cancelled.add(platformNotificationId);
  }
}
