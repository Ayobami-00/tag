import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tag/core/ai/schemas/card_proposal_schema.dart';
import 'package:tag/core/local_storage/database/data_sources/card_local_data_source.dart';
import 'package:tag/core/local_storage/database/tag_database.dart';
import 'package:tag/features/cards/data/repositories/card_repository_impl.dart';
import 'package:tag/features/cards/data/repositories/feedback_repository_impl.dart';
import 'package:tag/features/cards/data/repositories/preference_memory_repository_impl.dart';
import 'package:tag/features/cards/data/repositories/space_repository_impl.dart';
import 'package:tag/features/cards/domain/entities/feedback_entities.dart';
import 'package:tag/features/cards/domain/entities/card_entities.dart';
import 'package:tag/features/cards/domain/repositories/card_repository.dart';
import 'package:tag/features/cards/domain/use_cases/open_source_for_card.dart';
import 'package:tag/features/cards/domain/use_cases/store_feedback_event.dart';
import 'package:tag/features/cards/domain/use_cases/update_preference_memory.dart';
import 'package:tag/features/source_ingestion/data/data_sources/source_local_data_source.dart';
import 'package:tag/features/source_ingestion/data/repositories/source_repository_impl.dart';
import 'package:tag/features/source_ingestion/domain/repositories/source_repository.dart';

void main() {
  late TagDatabase database;
  late CardRepository cardRepository;
  late SourceRepository sourceRepository;
  late OpenSourceForCard openSourceForCard;

  setUp(() {
    database = TagDatabase.forTesting(NativeDatabase.memory());
    cardRepository = CardRepositoryImpl(
      database: database,
      localDataSource: DriftCardLocalDataSource(database),
      spaceRepository: SpaceRepositoryImpl(database: database, now: _fixedNow),
      now: _fixedNow,
    );
    sourceRepository = SourceRepositoryImpl(
      localDataSource: DriftSourceLocalDataSource(database),
      now: _fixedNow,
    );
    final storeFeedbackEvent = StoreFeedbackEvent(
      FeedbackRepositoryImpl(database: database, now: _fixedNow),
    );
    openSourceForCard = OpenSourceForCard(
      cardRepository: cardRepository,
      storeFeedbackEvent: storeFeedbackEvent,
      updatePreferenceMemory: UpdatePreferenceMemory(
        PreferenceMemoryRepositoryImpl(database: database, now: _fixedNow),
      ),
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('card source opens the primary source and writes feedback', () async {
    await _insertSource(database, id: 'src_primary');
    await _insertSource(database, id: 'src_supporting');
    final card = await _createCard(
      cardRepository,
      sourceIds: const ['src_primary', 'src_supporting'],
      title: 'Buy bread',
      spaceName: 'Household Tasks',
    );

    final result = await openSourceForCard(
      OpenSourceForCardParams(cardId: card.id),
    );

    final events = await database.select(database.feedbackEvents).get();

    expect(result.sourceId, 'src_primary');
    expect(events.single.eventType, FeedbackEventType.openSource.storageValue);
    expect(events.single.cardId, card.id);
    expect(events.single.sourceId, 'src_primary');
    expect(events.single.detailsJson, contains('"opened_from":"card_detail"'));
    expect(events.single.detailsJson, contains('"source_ids"'));
  });

  test(
    'source preview returns related cards with Spaces and evidence',
    () async {
      await _insertSource(database, id: 'src_shared');
      await _createCard(
        cardRepository,
        sourceIds: const ['src_shared'],
        title: 'Buy bread',
        spaceName: 'Household Tasks',
        deadline: _fixedNow().add(const Duration(hours: 2)),
      );
      await _createCard(
        cardRepository,
        sourceIds: const ['src_shared'],
        title: 'Review CUDA article',
        spaceName: 'Learn CUDA',
        deadline: _fixedNow().add(const Duration(days: 1)),
      );

      final preview = await sourceRepository.getSourcePreviewById('src_shared');

      expect(preview, isNotNull);
      expect(preview!.source.id, 'src_shared');
      expect(preview.relatedCards.map((card) => card.title), [
        'Buy bread',
        'Review CUDA article',
      ]);
      expect(preview.relatedCards.map((card) => card.space.name), [
        'Household Tasks',
        'Learn CUDA',
      ]);
      expect(preview.relatedCards.first.evidenceText, contains('Evidence for'));
    },
  );

  test('requesting an unrelated source for a card is rejected', () async {
    await _insertSource(database, id: 'src_card');
    await _insertSource(database, id: 'src_other');
    final card = await _createCard(
      cardRepository,
      sourceIds: const ['src_card'],
      title: 'Buy bread',
      spaceName: 'Household Tasks',
    );

    await expectLater(
      openSourceForCard(
        OpenSourceForCardParams(cardId: card.id, sourceId: 'src_other'),
      ),
      throwsA(isA<CardActionException>()),
    );

    expect(await database.select(database.feedbackEvents).get(), isEmpty);
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
  DateTime? deadline,
}) {
  return repository.createFromProposal(
    proposal: CardProposal.fromJson({
      'card_type': 'urgent',
      'title': title,
      'reason': 'Detected an action from the saved evidence.',
      'space_name': spaceName,
      'next_active_deadline': deadline?.toUtc().toIso8601String(),
      'source_ids': sourceIds,
      'actions': const ['complete', 'snooze', 'cancel'],
      'confidence': 0.91,
    }),
  );
}
