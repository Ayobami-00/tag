import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tag/core/ai/schemas/card_proposal_schema.dart';
import 'package:tag/core/local_storage/database/data_sources/card_local_data_source.dart';
import 'package:tag/core/local_storage/database/tag_database.dart';
import 'package:tag/core/notifications/local_notification_permission_service.dart';
import 'package:tag/core/notifications/local_notification_service.dart';
import 'package:tag/core/notifications/local_notification_service_impl.dart';
import 'package:tag/core/notifications/notification_policy.dart';
import 'package:tag/features/cards/data/repositories/card_repository_impl.dart';
import 'package:tag/features/cards/data/repositories/feedback_repository_impl.dart';
import 'package:tag/features/cards/data/repositories/preference_memory_repository_impl.dart';
import 'package:tag/features/cards/data/repositories/space_repository_impl.dart';
import 'package:tag/features/cards/domain/entities/card_entities.dart';
import 'package:tag/features/cards/domain/use_cases/card_notification_snapshot.dart';
import 'package:tag/features/cards/domain/use_cases/complete_card.dart';
import 'package:tag/features/cards/domain/use_cases/create_card_from_proposal.dart';
import 'package:tag/features/cards/domain/use_cases/snooze_card.dart';
import 'package:tag/features/cards/domain/use_cases/store_feedback_event.dart';
import 'package:tag/features/cards/domain/use_cases/update_preference_memory.dart';

void main() {
  group('NotificationPolicy', () {
    const policy = NotificationPolicy();

    test('active urgent with deadline is eligible', () {
      expect(policy.isEligible(_snapshot(cardType: 'urgent')), isTrue);
    });

    test('active goal with deadline is eligible', () {
      expect(policy.isEligible(_snapshot(cardType: 'goal')), isTrue);
    });

    test('suggestion is never eligible', () {
      expect(policy.isEligible(_snapshot(cardType: 'suggestion')), isFalse);
    });

    test('completed/cancelled/dismissed/archived are never eligible', () {
      for (final status in [
        'completed',
        'cancelled',
        'dismissed',
        'archived',
      ]) {
        expect(policy.isEligible(_snapshot(status: status)), isFalse);
      }
    });

    test('snoozed urgent card is eligible only for its return time', () {
      expect(
        policy.isEligible(
          _snapshot(status: 'snoozed', snoozedUntil: _futureMs),
        ),
        isTrue,
      );
      expect(policy.isEligible(_snapshot(status: 'snoozed')), isFalse);
    });
  });

  group('LocalNotificationServiceImpl', () {
    late TagDatabase database;
    late _RecordingNotificationScheduler scheduler;
    late LocalNotificationServiceImpl notificationService;
    late CreateCardFromProposal createCardFromProposal;
    late CompleteCard completeCard;
    late SnoozeCard snoozeCard;

    setUp(() {
      database = TagDatabase.forTesting(NativeDatabase.memory());
      scheduler = _RecordingNotificationScheduler();
      notificationService = LocalNotificationServiceImpl(
        database: database,
        policy: const NotificationPolicy(),
        scheduler: scheduler,
        now: _fixedNow,
      );

      final cardRepository = CardRepositoryImpl(
        database: database,
        localDataSource: DriftCardLocalDataSource(database),
        spaceRepository: SpaceRepositoryImpl(
          database: database,
          now: _fixedNow,
        ),
        now: _fixedNow,
      );
      final storeFeedbackEvent = StoreFeedbackEvent(
        FeedbackRepositoryImpl(database: database, now: _fixedNow),
      );
      final updatePreferenceMemory = UpdatePreferenceMemory(
        PreferenceMemoryRepositoryImpl(database: database, now: _fixedNow),
      );

      createCardFromProposal = CreateCardFromProposal(
        cardRepository,
        notificationService: notificationService,
      );
      completeCard = CompleteCard(
        cardRepository: cardRepository,
        storeFeedbackEvent: storeFeedbackEvent,
        updatePreferenceMemory: updatePreferenceMemory,
        notificationService: notificationService,
      );
      snoozeCard = SnoozeCard(
        cardRepository: cardRepository,
        storeFeedbackEvent: storeFeedbackEvent,
        updatePreferenceMemory: updatePreferenceMemory,
        notificationService: notificationService,
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('card creation schedules an eligible urgent notification', () async {
      await _createCard(
        database,
        createCardFromProposal,
        sourceId: 'src_urgent',
      );

      final rows = await database.select(database.notificationRequests).get();

      expect(rows, hasLength(1));
      expect(rows.single.status, 'scheduled');
      expect(rows.single.scheduledFor, _futureMs);
      expect(rows.single.actionsJson, contains('complete'));
      expect(scheduler.scheduled, hasLength(1));
      expect(
        scheduler.scheduled.single.categoryId,
        NotificationCategoryIds.urgent,
      );
    });

    test('unchanged card notification scheduling is idempotent', () async {
      final card = await _createCard(
        database,
        createCardFromProposal,
        sourceId: 'src_duplicate_schedule',
      );
      final firstRow = await database
          .select(database.notificationRequests)
          .getSingle();

      final second = await notificationService.scheduleCardNotification(
        notificationSnapshotFor(card),
      );
      final rows = await database.select(database.notificationRequests).get();

      expect(second?.id, firstRow.id);
      expect(rows, hasLength(1));
      expect(rows.single.status, 'scheduled');
      expect(scheduler.scheduled, hasLength(1));
      expect(scheduler.cancelled, isEmpty);
    });

    test('suggestion creation never schedules notification rows', () async {
      await _createCard(
        database,
        createCardFromProposal,
        sourceId: 'src_suggestion',
        cardType: 'suggestion',
        title: 'Goal detected: Learn Rust',
        deadline: null,
      );

      expect(
        await database.select(database.notificationRequests).get(),
        isEmpty,
      );
      expect(scheduler.scheduled, isEmpty);
    });

    test(
      'source failure notification shows immediately without card rows',
      () async {
        await notificationService.showSourceProcessingFailureNotification(
          const SourceProcessingFailureNotification(
            sourceId: 'src_image',
            title: 'Image was saved, but no card was made',
            body: 'No clear action was detected. Re-add it with a note.',
            sourceSummary: 'Uploaded image',
          ),
        );

        expect(
          await database.select(database.notificationRequests).get(),
          isEmpty,
        );
        expect(scheduler.shownNow, hasLength(1));
        expect(
          scheduler.shownNow.single.categoryId,
          NotificationCategoryIds.sourceFailure,
        );
        expect(scheduler.shownNow.single.payload, contains('src_image'));
      },
    );

    test('complete cancels pending notification', () async {
      final card = await _createCard(
        database,
        createCardFromProposal,
        sourceId: 'src_complete',
      );
      final scheduledRow = await database
          .select(database.notificationRequests)
          .getSingle();

      await completeCard(CompleteCardParams(cardId: card.id));

      final rows = await database.select(database.notificationRequests).get();

      expect(rows.single.status, 'cancelled');
      expect(rows.single.cancelledAt, _fixedNowMs);
      expect(scheduler.cancelled, [scheduledRow.platformNotificationId]);
    });

    test('snooze reschedules notification for the snooze return', () async {
      final card = await _createCard(
        database,
        createCardFromProposal,
        sourceId: 'src_snooze',
      );
      final firstRow = await database
          .select(database.notificationRequests)
          .getSingle();
      final snoozedUntil = _fixedNow().add(const Duration(minutes: 30));

      final updated = await snoozeCard(
        SnoozeCardParams(cardId: card.id, snoozedUntil: snoozedUntil),
      );

      final rows = await database.select(database.notificationRequests).get();
      final scheduledRows = rows.where((row) => row.status == 'scheduled');
      final cancelledRows = rows.where((row) => row.status == 'cancelled');

      expect(updated.status, TagCardStatus.snoozed);
      expect(
        cancelledRows.single.platformNotificationId,
        firstRow.platformNotificationId,
      );
      expect(
        scheduledRows.single.scheduledFor,
        snoozedUntil.toUtc().millisecondsSinceEpoch,
      );
      expect(scheduler.cancelled, [firstRow.platformNotificationId]);
      expect(scheduler.scheduled, hasLength(2));
    });

    test('stale snoozed return cancels without scheduling now', () async {
      final card = await _createCard(
        database,
        createCardFromProposal,
        sourceId: 'src_stale_snooze',
      );
      final firstRow = await database
          .select(database.notificationRequests)
          .getSingle();
      final snoozedUntil = _fixedNow().add(const Duration(minutes: 30));
      final updated = await snoozeCard(
        SnoozeCardParams(cardId: card.id, snoozedUntil: snoozedUntil),
      );
      final secondRow =
          (await database.select(database.notificationRequests).get())
              .firstWhere((row) => row.status == 'scheduled');
      final laterService = LocalNotificationServiceImpl(
        database: database,
        policy: const NotificationPolicy(),
        scheduler: scheduler,
        now: () => snoozedUntil.add(const Duration(minutes: 1)),
      );

      final stale = await laterService.scheduleCardNotification(
        notificationSnapshotFor(updated),
      );
      final rows = await database.select(database.notificationRequests).get();

      expect(stale, null);
      expect(rows, hasLength(2));
      expect(rows.where((row) => row.status == 'scheduled'), isEmpty);
      expect(scheduler.cancelled, [
        firstRow.platformNotificationId,
        secondRow.platformNotificationId,
      ]);
      expect(scheduler.scheduled, hasLength(2));
    });
  });
}

DateTime _fixedNow() => DateTime.utc(2026, 5, 10, 12);

int get _fixedNowMs => _fixedNow().millisecondsSinceEpoch;

int get _futureMs =>
    _fixedNow().add(const Duration(hours: 1)).millisecondsSinceEpoch;

LocalNotificationCardSnapshot _snapshot({
  String cardType = 'urgent',
  String status = 'active',
  int? nextActiveDeadline,
  int? snoozedUntil,
  bool notificationEnabled = true,
}) {
  return LocalNotificationCardSnapshot(
    id: 'card_test',
    cardType: cardType,
    status: status,
    title: 'Buy bread',
    reason: 'Detected from a message screenshot.',
    spaceName: 'Household Tasks',
    sourceSummary: 'WhatsApp screenshot',
    notificationEnabled: notificationEnabled,
    nextActiveDeadline: nextActiveDeadline ?? _futureMs,
    snoozedUntil: snoozedUntil,
  );
}

Future<TagCardEntity> _createCard(
  TagDatabase database,
  CreateCardFromProposal createCardFromProposal, {
  required String sourceId,
  String cardType = 'urgent',
  String title = 'Buy bread',
  DateTime? deadline,
}) async {
  await _insertSource(database, id: sourceId);

  return createCardFromProposal(
    CreateCardFromProposalParams(
      proposal: CardProposal.fromJson({
        'card_type': cardType,
        'title': title,
        'reason': 'Detected from a saved local source.',
        'space_name': cardType == 'goal' ? 'Learn CUDA' : 'Household Tasks',
        'next_active_deadline':
            (deadline ?? _fixedNow().add(const Duration(hours: 1)))
                .toUtc()
                .toIso8601String(),
        'source_ids': [sourceId],
        'actions': _actionsFor(cardType),
        'confidence': 0.91,
      }),
    ),
  );
}

Future<void> _insertSource(TagDatabase database, {required String id}) async {
  await database
      .into(database.sourceItems)
      .insert(
        SourceItemsCompanion.insert(
          id: id,
          type: 'text',
          sourceSummary: Value('Source $id'),
          contentType: const Value('message'),
          rawText: Value('Evidence for $id'),
          extractedText: Value('Evidence for $id'),
          createdAt: _fixedNowMs,
          updatedAt: _fixedNowMs,
        ),
      );
}

List<String> _actionsFor(String cardType) {
  return switch (cardType) {
    'goal' => const ['complete', 'edit', 'snooze'],
    'suggestion' => const ['plan_this', 'dismiss'],
    _ => const ['complete', 'snooze', 'cancel'],
  };
}

class _RecordingNotificationScheduler implements NotificationPlatformScheduler {
  final scheduled = <NotificationPlatformRequest>[];
  final shownNow = <NotificationPlatformRequest>[];
  final cancelled = <int>[];
  NotificationActionHandler? onAction;

  @override
  Future<void> initialize({required NotificationActionHandler onAction}) async {
    this.onAction = onAction;
  }

  @override
  Future<NotificationPermissionState> requestPermission() async {
    return NotificationPermissionState.granted;
  }

  @override
  Future<void> schedule(NotificationPlatformRequest request) async {
    scheduled.add(request);
  }

  @override
  Future<void> showNow(NotificationPlatformRequest request) async {
    shownNow.add(request);
  }

  @override
  Future<void> cancel(int platformNotificationId) async {
    cancelled.add(platformNotificationId);
  }
}
