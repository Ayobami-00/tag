import 'dart:async';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tag/core/ai/schemas/card_proposal_schema.dart';
import 'package:tag/core/local_storage/database/data_sources/card_local_data_source.dart';
import 'package:tag/core/local_storage/database/tag_database.dart';
import 'package:tag/features/cards/data/repositories/card_repository_impl.dart';
import 'package:tag/features/cards/data/repositories/space_repository_impl.dart';
import 'package:tag/features/cards/domain/entities/card_entities.dart';
import 'package:tag/features/cards/domain/entities/card_query.dart';
import 'package:tag/features/cards/domain/repositories/card_repository.dart';

void main() {
  late TagDatabase database;
  late CardRepository repository;

  setUp(() {
    database = TagDatabase.forTesting(NativeDatabase.memory());
    final spaceRepository = SpaceRepositoryImpl(
      database: database,
      now: _fixedNow,
    );
    repository = CardRepositoryImpl(
      database: database,
      localDataSource: DriftCardLocalDataSource(database),
      spaceRepository: spaceRepository,
      now: _fixedNow,
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('Today sorting follows next active deadline priority', () async {
    await _createCard(
      repository,
      database,
      sourceId: 'src_unscheduled',
      title: 'Unscheduled task',
      deadline: null,
    );
    await _createCard(
      repository,
      database,
      sourceId: 'src_suggestion',
      title: 'Goal detected: Learn Rust',
      cardType: 'suggestion',
      actions: const ['plan_this', 'dismiss'],
      deadline: null,
    );
    await _createCard(
      repository,
      database,
      sourceId: 'src_week',
      title: 'This week card',
      deadline: _fixedNow().add(const Duration(days: 3)),
    );
    await _createCard(
      repository,
      database,
      sourceId: 'src_tomorrow',
      title: 'Tomorrow card',
      deadline: _fixedNow().add(const Duration(days: 1, hours: 2)),
    );
    await _createCard(
      repository,
      database,
      sourceId: 'src_today',
      title: 'Later today card',
      deadline: _fixedNow().add(const Duration(hours: 3)),
    );
    await _createCard(
      repository,
      database,
      sourceId: 'src_soon',
      title: 'Due soon card',
      deadline: _fixedNow().add(const Duration(minutes: 30)),
    );
    await _createCard(
      repository,
      database,
      sourceId: 'src_overdue',
      title: 'Overdue card',
      deadline: _fixedNow().subtract(const Duration(hours: 1)),
    );

    final cards = await repository.getCards(
      CardListQuery(
        viewMode: TodayViewMode.all,
        filter: TodayCardFilter.all,
        now: _fixedNow(),
      ),
    );

    expect(cards.map((card) => card.title), [
      'Overdue card',
      'Due soon card',
      'Later today card',
      'Tomorrow card',
      'This week card',
      'Goal detected: Learn Rust',
      'Unscheduled task',
    ]);
  });

  test('filters return correct cards', () async {
    final urgent = await _createCard(
      repository,
      database,
      sourceId: 'src_urgent',
      title: 'Buy bread',
    );
    await _createCard(
      repository,
      database,
      sourceId: 'src_goal',
      title: 'CUDA session',
      cardType: 'goal',
      actions: const ['complete', 'edit', 'snooze', 'view_space'],
    );
    await _createCard(
      repository,
      database,
      sourceId: 'src_suggestion',
      title: 'Goal detected: Learn Rust',
      cardType: 'suggestion',
      actions: const ['plan_this', 'dismiss'],
      deadline: null,
    );
    await (database.update(
      database.tagCards,
    )..where((card) => card.id.equals(urgent.id))).write(
      TagCardsCompanion(
        status: const Value('completed'),
        notificationEnabled: const Value(false),
        completedAt: Value(_fixedNow().millisecondsSinceEpoch),
      ),
    );

    final goalCards = await repository.getCards(
      CardListQuery(
        viewMode: TodayViewMode.all,
        filter: TodayCardFilter.goal,
        now: _fixedNow(),
      ),
    );
    final completedCards = await repository.getCards(
      CardListQuery(
        viewMode: TodayViewMode.all,
        filter: TodayCardFilter.completed,
        now: _fixedNow(),
      ),
    );
    final suggestionCards = await repository.getCards(
      CardListQuery(
        viewMode: TodayViewMode.all,
        filter: TodayCardFilter.suggestion,
        now: _fixedNow(),
      ),
    );

    expect(goalCards.map((card) => card.title), ['CUDA session']);
    expect(completedCards.map((card) => card.title), ['Buy bread']);
    expect(suggestionCards.map((card) => card.title), [
      'Goal detected: Learn Rust',
    ]);
  });

  test(
    'processing image sources appear in All and Processing filters',
    () async {
      await _insertProcessingImageSource(
        database,
        id: 'src_processing',
        summary: 'Manual image - receipt.png',
      );

      final allCards = await repository.getCards(
        CardListQuery(
          viewMode: TodayViewMode.today,
          filter: TodayCardFilter.all,
          now: _fixedNow(),
        ),
      );
      final processingCards = await repository.getCards(
        CardListQuery(
          viewMode: TodayViewMode.today,
          filter: TodayCardFilter.processing,
          now: _fixedNow(),
        ),
      );
      final suggestionCards = await repository.getCards(
        CardListQuery(
          viewMode: TodayViewMode.today,
          filter: TodayCardFilter.suggestion,
          now: _fixedNow(),
        ),
      );

      expect(allCards.map((card) => card.title), ['Processing receipt.png']);
      expect(processingCards, hasLength(1));
      expect(processingCards.single.isProcessingPlaceholder, isTrue);
      expect(processingCards.single.sourceIds, ['src_processing']);
      expect(processingCards.single.sourceSummary, 'receipt.png');
      expect(suggestionCards, isEmpty);
    },
  );

  test('watchCards emits when a processing image source is saved', () async {
    final processingCardCompleter = Completer<TagCardEntity>();
    final subscription = repository
        .watchCards(
          CardListQuery(
            viewMode: TodayViewMode.today,
            filter: TodayCardFilter.processing,
            now: _fixedNow(),
          ),
        )
        .listen((cards) {
          for (final card in cards) {
            if (card.isProcessingPlaceholder &&
                card.sourceIds.contains('src_processing')) {
              if (!processingCardCompleter.isCompleted) {
                processingCardCompleter.complete(card);
              }
              return;
            }
          }
        });
    addTearDown(subscription.cancel);

    await _insertProcessingImageSource(
      database,
      id: 'src_processing',
      summary: 'Manual image - receipt.png',
    );

    final processingCard = await processingCardCompleter.future.timeout(
      const Duration(seconds: 2),
    );

    expect(processingCard.title, 'Processing receipt.png');
    expect(processingCard.sourceIds, ['src_processing']);
  });

  test(
    'processing placeholders disappear once a card links the source',
    () async {
      await _insertProcessingImageSource(
        database,
        id: 'src_processing',
        summary: 'Manual image - receipt.png',
      );

      await repository.createFromProposal(
        proposal: CardProposal.fromJson({
          'card_type': 'urgent',
          'title': 'Submit receipt',
          'reason': 'Detected from a receipt screenshot.',
          'space_name': 'Expenses',
          'next_active_deadline': _fixedNow()
              .add(const Duration(hours: 2))
              .toIso8601String(),
          'source_ids': ['src_processing'],
          'actions': ['complete', 'snooze', 'cancel'],
          'confidence': 0.91,
        }),
      );

      final processingCards = await repository.getCards(
        CardListQuery(
          viewMode: TodayViewMode.today,
          filter: TodayCardFilter.processing,
          now: _fixedNow(),
        ),
      );
      final allCards = await repository.getCards(
        CardListQuery(
          viewMode: TodayViewMode.today,
          filter: TodayCardFilter.all,
          now: _fixedNow(),
        ),
      );

      expect(processingCards, isEmpty);
      expect(allCards.map((card) => card.title), ['Submit receipt']);
    },
  );

  test('Today view shows overdue, today, and suggestion cards only', () async {
    await _createCard(
      repository,
      database,
      sourceId: 'src_overdue',
      title: 'Overdue card',
      deadline: _fixedNow().subtract(const Duration(hours: 1)),
    );
    await _createCard(
      repository,
      database,
      sourceId: 'src_today',
      title: 'Later today card',
      deadline: _fixedNow().add(const Duration(hours: 2)),
    );
    await _createCard(
      repository,
      database,
      sourceId: 'src_tomorrow',
      title: 'Tomorrow card',
      deadline: _fixedNow().add(const Duration(days: 1, hours: 2)),
    );
    await _createCard(
      repository,
      database,
      sourceId: 'src_suggestion',
      title: 'Suggestion card',
      cardType: 'suggestion',
      actions: const ['plan_this', 'dismiss'],
      deadline: null,
    );

    final cards = await repository.getCards(
      CardListQuery(
        viewMode: TodayViewMode.today,
        filter: TodayCardFilter.all,
        now: _fixedNow(),
      ),
    );

    expect(cards.map((card) => card.title), [
      'Overdue card',
      'Later today card',
      'Suggestion card',
    ]);
  });
}

DateTime _fixedNow() => DateTime.utc(2026, 5, 10, 12);

Future<TagCardEntity> _createCard(
  CardRepository repository,
  TagDatabase database, {
  required String sourceId,
  required String title,
  String cardType = 'urgent',
  List<String> actions = const ['complete', 'snooze', 'cancel'],
  DateTime? deadline,
}) async {
  await _insertSource(database, id: sourceId);

  return repository.createFromProposal(
    proposal: CardProposal.fromJson({
      'card_type': cardType,
      'title': title,
      'reason': 'Created from a saved source.',
      'space_name': 'Household Tasks',
      'next_active_deadline': deadline?.toUtc().toIso8601String(),
      'source_ids': [sourceId],
      'actions': actions,
      'confidence': 0.91,
    }),
  );
}

Future<void> _insertSource(TagDatabase database, {required String id}) async {
  final now = _fixedNow().millisecondsSinceEpoch;

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
          createdAt: now,
          updatedAt: now,
        ),
      );
}

Future<void> _insertProcessingImageSource(
  TagDatabase database, {
  required String id,
  required String summary,
}) async {
  final now = _fixedNow().millisecondsSinceEpoch;

  await database
      .into(database.sourceItems)
      .insert(
        SourceItemsCompanion.insert(
          id: id,
          type: 'image',
          sourceSummary: Value(summary),
          contentType: const Value('unknown'),
          processingState: const Value('saved'),
          createdAt: now,
          updatedAt: now,
        ),
      );
}
