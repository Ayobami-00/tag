import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tag/core/ai/schemas/card_proposal_schema.dart';
import 'package:tag/core/local_storage/database/data_sources/card_local_data_source.dart';
import 'package:tag/core/local_storage/database/tag_database.dart';
import 'package:tag/features/cards/data/repositories/card_repository_impl.dart';
import 'package:tag/features/cards/data/repositories/feedback_repository_impl.dart';
import 'package:tag/features/cards/data/repositories/preference_memory_repository_impl.dart';
import 'package:tag/features/cards/data/repositories/space_repository_impl.dart';
import 'package:tag/features/cards/domain/entities/card_entities.dart';
import 'package:tag/features/cards/domain/entities/feedback_entities.dart';
import 'package:tag/features/cards/domain/use_cases/cancel_card.dart';
import 'package:tag/features/cards/domain/use_cases/complete_card.dart';
import 'package:tag/features/cards/domain/use_cases/create_card_from_proposal.dart';
import 'package:tag/features/cards/domain/use_cases/dismiss_suggestion.dart';
import 'package:tag/features/cards/domain/use_cases/snooze_card.dart';
import 'package:tag/features/cards/domain/use_cases/store_feedback_event.dart';
import 'package:tag/features/cards/domain/use_cases/update_preference_memory.dart';

void main() {
  late TagDatabase database;
  late CreateCardFromProposal createCardFromProposal;
  late CompleteCard completeCard;
  late SnoozeCard snoozeCard;
  late CancelCard cancelCard;
  late DismissSuggestion dismissSuggestion;

  setUp(() {
    database = TagDatabase.forTesting(NativeDatabase.memory());
    final cardRepository = CardRepositoryImpl(
      database: database,
      localDataSource: DriftCardLocalDataSource(database),
      spaceRepository: SpaceRepositoryImpl(database: database, now: _fixedNow),
      now: _fixedNow,
    );
    final storeFeedbackEvent = StoreFeedbackEvent(
      FeedbackRepositoryImpl(database: database, now: _fixedNow),
    );
    final updatePreferenceMemory = UpdatePreferenceMemory(
      PreferenceMemoryRepositoryImpl(database: database, now: _fixedNow),
    );

    createCardFromProposal = CreateCardFromProposal(cardRepository);
    completeCard = CompleteCard(
      cardRepository: cardRepository,
      storeFeedbackEvent: storeFeedbackEvent,
      updatePreferenceMemory: updatePreferenceMemory,
    );
    snoozeCard = SnoozeCard(
      cardRepository: cardRepository,
      storeFeedbackEvent: storeFeedbackEvent,
      updatePreferenceMemory: updatePreferenceMemory,
    );
    cancelCard = CancelCard(
      cardRepository: cardRepository,
      storeFeedbackEvent: storeFeedbackEvent,
      updatePreferenceMemory: updatePreferenceMemory,
    );
    dismissSuggestion = DismissSuggestion(
      cardRepository: cardRepository,
      storeFeedbackEvent: storeFeedbackEvent,
      updatePreferenceMemory: updatePreferenceMemory,
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('completing a card sets completed_at and writes feedback', () async {
    final card = await _createCard(
      database,
      createCardFromProposal,
      sourceId: 'src_complete',
    );

    final updated = await completeCard(CompleteCardParams(cardId: card.id));

    final row = await database.select(database.tagCards).getSingle();
    final events = await database.select(database.feedbackEvents).get();

    expect(updated.status, TagCardStatus.completed);
    expect(row.status, 'completed');
    expect(row.completedAt, _fixedNowMs);
    expect(row.notificationEnabled, isFalse);
    expect(events.single.eventType, FeedbackEventType.complete.storageValue);
    expect(events.single.cardId, card.id);
    expect(events.single.detailsJson, contains('"previous_status":"active"'));
    expect(events.single.detailsJson, contains('"new_status":"completed"'));
  });

  test('snoozing a card sets snoozed_until and updates memory', () async {
    final card = await _createCard(
      database,
      createCardFromProposal,
      sourceId: 'src_snooze',
    );
    final snoozedUntil = _fixedNow().add(const Duration(minutes: 30));

    final updated = await snoozeCard(
      SnoozeCardParams(
        cardId: card.id,
        snoozedUntil: snoozedUntil,
        optionLabel: 'In 30 minutes',
      ),
    );

    final row = await database.select(database.tagCards).getSingle();
    final event = await database.select(database.feedbackEvents).getSingle();
    final memory = await database.select(database.preferenceMemory).getSingle();

    expect(updated.status, TagCardStatus.snoozed);
    expect(row.status, 'snoozed');
    expect(row.snoozedUntil, snoozedUntil.toUtc().millisecondsSinceEpoch);
    expect(row.notificationEnabled, isTrue);
    expect(event.eventType, FeedbackEventType.snooze.storageValue);
    expect(event.detailsJson, contains('"snooze_minutes":30'));
    expect(memory.category, 'reminders');
    expect(memory.key, 'default_snooze_minutes');
    expect(memory.valueJson, contains('"minutes":30'));
    expect(memory.evidenceEventIdsJson, contains(event.id));
  });

  test(
    'cancelling an urgent card sets cancelled_at and writes feedback',
    () async {
      final card = await _createCard(
        database,
        createCardFromProposal,
        sourceId: 'src_cancel',
      );

      final updated = await cancelCard(CancelCardParams(cardId: card.id));

      final row = await database.select(database.tagCards).getSingle();
      final event = await database.select(database.feedbackEvents).getSingle();

      expect(updated.status, TagCardStatus.cancelled);
      expect(row.status, 'cancelled');
      expect(row.cancelledAt, _fixedNowMs);
      expect(row.notificationEnabled, isFalse);
      expect(event.eventType, FeedbackEventType.cancel.storageValue);
    },
  );

  test(
    'dismissing a suggestion sets dismissed_at and writes feedback',
    () async {
      final card = await _createCard(
        database,
        createCardFromProposal,
        sourceId: 'src_dismiss',
        cardType: 'suggestion',
        title: 'Goal detected: Learn Rust',
        deadline: null,
      );

      final updated = await dismissSuggestion(
        DismissSuggestionParams(cardId: card.id),
      );

      final row = await database.select(database.tagCards).getSingle();
      final event = await database.select(database.feedbackEvents).getSingle();

      expect(updated.status, TagCardStatus.dismissed);
      expect(row.status, 'dismissed');
      expect(row.dismissedAt, _fixedNowMs);
      expect(row.notificationEnabled, isFalse);
      expect(event.eventType, FeedbackEventType.dismiss.storageValue);
    },
  );

  test('invalid actions for card type are rejected before feedback', () async {
    final goal = await _createCard(
      database,
      createCardFromProposal,
      sourceId: 'src_goal',
      cardType: 'goal',
      title: 'CUDA session',
    );

    await expectLater(
      cancelCard(CancelCardParams(cardId: goal.id)),
      throwsA(isA<CardActionException>()),
    );

    final urgent = await _createCard(
      database,
      createCardFromProposal,
      sourceId: 'src_urgent',
    );

    await expectLater(
      dismissSuggestion(DismissSuggestionParams(cardId: urgent.id)),
      throwsA(isA<CardActionException>()),
    );

    expect(await database.select(database.feedbackEvents).get(), isEmpty);
  });
}

DateTime _fixedNow() => DateTime.utc(2026, 5, 10, 12);

int get _fixedNowMs => _fixedNow().millisecondsSinceEpoch;

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
        'next_active_deadline': deadline?.toUtc().toIso8601String(),
        'source_ids': [sourceId],
        'actions': _actionsFor(cardType),
        'confidence': 0.91,
      }),
    ),
  );
}

List<String> _actionsFor(String cardType) {
  return switch (cardType) {
    'goal' => const ['complete', 'edit', 'snooze', 'view_space'],
    'suggestion' => const ['plan_this', 'dismiss'],
    _ => const ['complete', 'snooze', 'cancel'],
  };
}
