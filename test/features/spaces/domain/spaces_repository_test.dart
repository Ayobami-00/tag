import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tag/core/ai/schemas/card_proposal_schema.dart';
import 'package:tag/core/local_storage/database/data_sources/card_local_data_source.dart';
import 'package:tag/core/local_storage/database/tag_database.dart';
import 'package:tag/features/cards/data/repositories/card_repository_impl.dart';
import 'package:tag/features/cards/data/repositories/feedback_repository_impl.dart';
import 'package:tag/features/cards/data/repositories/space_repository_impl.dart';
import 'package:tag/features/cards/domain/entities/card_entities.dart';
import 'package:tag/features/cards/domain/entities/feedback_entities.dart';
import 'package:tag/features/cards/domain/repositories/card_repository.dart';
import 'package:tag/features/cards/domain/use_cases/store_feedback_event.dart';
import 'package:tag/features/spaces/data/data_sources/spaces_local_data_source.dart';
import 'package:tag/features/spaces/data/repositories/spaces_repository_impl.dart';
import 'package:tag/features/spaces/domain/repositories/spaces_repository.dart';
import 'package:tag/features/spaces/domain/use_cases/record_space_view.dart';

void main() {
  late TagDatabase database;
  late CardRepository cardRepository;
  late SpacesRepository spacesRepository;
  late RecordSpaceView recordSpaceView;

  setUp(() {
    database = TagDatabase.forTesting(NativeDatabase.memory());
    cardRepository = CardRepositoryImpl(
      database: database,
      localDataSource: DriftCardLocalDataSource(database),
      spaceRepository: SpaceRepositoryImpl(database: database, now: _fixedNow),
      now: _fixedNow,
    );
    spacesRepository = SpacesRepositoryImpl(
      localDataSource: DriftSpacesLocalDataSource(database),
      now: _fixedNow,
    );
    recordSpaceView = RecordSpaceView(
      StoreFeedbackEvent(
        FeedbackRepositoryImpl(database: database, now: _fixedNow),
      ),
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('every created card belongs to exactly one Space', () async {
    await _insertSource(database, id: 'src_card');
    final card = await _createCard(
      cardRepository,
      sourceIds: const ['src_card'],
      title: 'Buy bread',
      spaceName: 'Household Tasks',
    );

    final rows = await database.select(database.tagCards).get();

    expect(rows.single.id, card.id);
    expect(rows.single.spaceId, isNotEmpty);
    expect(card.space.name, 'Household Tasks');
    expect(card.sourceIds, ['src_card']);
  });

  test(
    'Space summary counts active cards, sources, suggestions, and next',
    () async {
      await _insertSource(database, id: 'src_cuda_1');
      await _insertSource(database, id: 'src_cuda_2');
      await _createCard(
        cardRepository,
        sourceIds: const ['src_cuda_1'],
        title: 'Review CUDA memory notes',
        spaceName: 'Learn CUDA',
        deadline: _fixedNow().add(const Duration(hours: 2)),
      );
      await _createCard(
        cardRepository,
        sourceIds: const ['src_cuda_2'],
        title: 'Practice kernels',
        spaceName: 'Learn CUDA',
        cardType: 'goal',
        deadline: _fixedNow().add(const Duration(days: 1)),
      );
      await _createCard(
        cardRepository,
        sourceIds: const ['src_cuda_1', 'src_cuda_2'],
        title: 'Plan CUDA learning',
        spaceName: 'Learn CUDA',
        cardType: 'suggestion',
        deadline: null,
      );

      final summaries = await spacesRepository.getSpaceSummaries();
      final cuda = summaries.singleWhere(
        (summary) => summary.space.name == 'Learn CUDA',
      );

      expect(cuda.activeCardCount, 2);
      expect(cuda.sourceCount, 2);
      expect(cuda.suggestedPlansCount, 1);
      expect(
        cuda.nextDeadline,
        _fixedNow().add(const Duration(hours: 2)).millisecondsSinceEpoch,
      );
    },
  );

  test(
    'Space detail groups active cards, upcoming cards, and sources',
    () async {
      await _insertSource(database, id: 'src_active');
      await _insertSource(database, id: 'src_upcoming');
      final active = await _createCard(
        cardRepository,
        sourceIds: const ['src_active'],
        title: 'Summarize CUDA notes',
        spaceName: 'Learn CUDA',
        deadline: null,
      );
      await _createCard(
        cardRepository,
        sourceIds: const ['src_upcoming'],
        title: 'Watch Nsight profiler intro',
        spaceName: 'Learn CUDA',
        cardType: 'goal',
        deadline: _fixedNow().add(const Duration(days: 2)),
      );

      final detail = await spacesRepository.getSpaceDetail(active.space.id);

      expect(detail, isNotNull);
      expect(detail!.activeCards.map((card) => card.title), [
        'Summarize CUDA notes',
      ]);
      expect(detail.upcomingCards.map((card) => card.title), [
        'Watch Nsight profiler intro',
      ]);
      expect(detail.sources.map((source) => source.id), [
        'src_active',
        'src_upcoming',
      ]);
    },
  );

  test('opening Space writes a view_space feedback event', () async {
    await _insertSource(database, id: 'src_space_view');
    final card = await _createCard(
      cardRepository,
      sourceIds: const ['src_space_view'],
      title: 'Buy bread',
      spaceName: 'Household Tasks',
    );

    final event = await recordSpaceView(
      RecordSpaceViewParams(
        spaceId: card.space.id,
        cardId: card.id,
        sourceId: 'src_space_view',
        cardType: card.cardType.storageValue,
        cardStatus: card.status.storageValue,
        openedFrom: 'test',
      ),
    );

    final rows = await database.select(database.feedbackEvents).get();

    expect(event.eventType, FeedbackEventType.viewSpace);
    expect(rows.single.eventType, 'view_space');
    expect(rows.single.spaceId, card.space.id);
    expect(rows.single.cardId, card.id);
    expect(rows.single.sourceId, 'src_space_view');
    expect(rows.single.detailsJson, contains('"opened_from":"test"'));
  });
}

DateTime _fixedNow() => DateTime.utc(2026, 5, 10, 12);

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

Future<TagCardEntity> _createCard(
  CardRepository repository, {
  required List<String> sourceIds,
  required String title,
  required String spaceName,
  String cardType = 'urgent',
  DateTime? deadline,
}) {
  return repository.createFromProposal(
    proposal: CardProposal.fromJson({
      'card_type': cardType,
      'title': title,
      'reason': 'Detected an action from saved evidence.',
      'space_name': spaceName,
      'next_active_deadline': deadline?.toUtc().toIso8601String(),
      'source_ids': sourceIds,
      'actions': _actionsFor(cardType),
      'confidence': 0.91,
    }),
  );
}

List<String> _actionsFor(String cardType) {
  return switch (cardType) {
    'goal' => const ['complete', 'edit', 'snooze', 'view_space'],
    'suggestion' => const ['plan_this', 'dismiss'],
    _ => const ['complete', 'snooze', 'cancel'],
  };
}
