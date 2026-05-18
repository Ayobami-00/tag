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
import 'package:tag/features/cards/domain/use_cases/create_card_from_proposal.dart';
import 'package:tag/features/cards/domain/use_cases/delete_card.dart';

void main() {
  late TagDatabase database;
  late CardRepositoryImpl cardRepository;
  late CreateCardFromProposal createCardFromProposal;
  late DeleteCard deleteCard;

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
    createCardFromProposal = CreateCardFromProposal(cardRepository);
    deleteCard = DeleteCard(cardRepository);
  });

  tearDown(() async {
    await database.close();
  });

  test('card proposal creates a source-backed Tag Card', () async {
    await _insertSource(database, id: 'src_bread');

    final card = await createCardFromProposal(
      CreateCardFromProposalParams(
        proposal: _proposal(
          sourceIds: const ['src_bread'],
          nextActiveDeadline: '2026-05-10T20:00:00+01:00',
        ),
        modelSlug: 'gemma-4-local',
      ),
    );

    final cardSources = await database.select(database.cardSources).get();

    expect(card.title, 'Buy bread');
    expect(card.cardType, TagCardType.urgent);
    expect(card.space.name, 'Household Tasks');
    expect(card.sourceIds, ['src_bread']);
    expect(card.sourceSummary, 'WhatsApp screenshot');
    expect(card.actions, [
      TagCardAction.complete,
      TagCardAction.snooze,
      TagCardAction.cancel,
      TagCardAction.viewSpace,
    ]);
    expect(card.notificationEnabled, isTrue);
    expect(cardSources.single.role, 'primary');
  });

  test('missing source evidence is rejected', () async {
    await expectLater(
      createCardFromProposal(
        CreateCardFromProposalParams(
          proposal: _proposal(sourceIds: const ['src_missing']),
        ),
      ),
      throwsA(isA<CardCreationException>()),
    );

    expect(await database.select(database.tagCards).get(), isEmpty);
  });

  test('missing Space creates a fallback Space', () async {
    await _insertSource(database, id: 'src_bread');

    final card = await createCardFromProposal(
      CreateCardFromProposalParams(
        proposal: _proposal(sourceIds: const ['src_bread']),
      ),
    );
    final spaces = await database.select(database.spaces).get();

    expect(spaces, hasLength(1));
    expect(spaces.single.name, 'Household Tasks');
    expect(spaces.single.type, 'fallback');
    expect(card.space.type, SpaceType.fallback);
  });

  test('suggestion notification flag is false', () async {
    await _insertSource(database, id: 'src_rust');

    final card = await createCardFromProposal(
      CreateCardFromProposalParams(
        proposal: _proposal(
          cardType: 'suggestion',
          title: 'Goal detected: Learn Rust',
          sourceIds: const ['src_rust'],
          nextActiveDeadline: null,
          actions: const ['plan_this', 'dismiss'],
        ),
      ),
    );
    final row = await database.select(database.tagCards).getSingle();

    expect(card.cardType, TagCardType.suggestion);
    expect(card.notificationEnabled, isFalse);
    expect(row.notificationEnabled, isFalse);
  });

  test('OCR-noisy AI titles are cleaned before storing cards', () async {
    await _insertSource(database, id: 'src_wave');

    final card = await createCardFromProposal(
      CreateCardFromProposalParams(
        proposal: _proposal(
          title:
              'Apply to •..: Jordan - Senior Applied Al Scientist Opportunity @ Wave',
          sourceIds: const ['src_wave'],
          nextActiveDeadline: null,
        ),
      ),
    );

    expect(
      card.title,
      'Apply to Jordan - Senior Applied AI Scientist Opportunity @ Wave',
    );
  });

  test('screenshot chrome is trimmed from OCR-derived titles', () async {
    await _insertSource(database, id: 'src_company');

    final card = await createCardFromProposal(
      CreateCardFromProposalParams(
        proposal: _proposal(
          title:
              '21:05 •ll 5G 40 Post ••• X.com UK founder starter pack: incorporate via Companies House',
          sourceIds: const ['src_company'],
          nextActiveDeadline: null,
        ),
      ),
    );

    expect(
      card.title,
      'UK founder starter pack: incorporate via Companies House',
    );
  });

  test('equivalent active proposal reuses card and links new source', () async {
    await _insertSource(database, id: 'src_bread');
    await _insertSource(database, id: 'src_bread_duplicate');

    final first = await createCardFromProposal(
      CreateCardFromProposalParams(
        proposal: _proposal(sourceIds: const ['src_bread']),
      ),
    );
    final second = await createCardFromProposal(
      CreateCardFromProposalParams(
        proposal: _proposal(sourceIds: const ['src_bread_duplicate']),
      ),
    );
    final cards = await database.select(database.tagCards).get();
    final cardSources = await database.select(database.cardSources).get();

    expect(second.id, first.id);
    expect(cards, hasLength(1));
    expect(second.sourceIds, ['src_bread', 'src_bread_duplicate']);
    expect(cardSources.map((source) => source.role), ['primary', 'supporting']);
  });

  test(
    'equivalent snoozed proposal reuses card and preserves snooze',
    () async {
      await _insertSource(database, id: 'src_bread');
      await _insertSource(database, id: 'src_bread_duplicate');

      final first = await createCardFromProposal(
        CreateCardFromProposalParams(
          proposal: _proposal(sourceIds: const ['src_bread']),
        ),
      );
      await cardRepository.snoozeCard(
        id: first.id,
        snoozedUntil: DateTime.utc(2026, 5, 10, 21),
      );

      final second = await createCardFromProposal(
        CreateCardFromProposalParams(
          proposal: _proposal(sourceIds: const ['src_bread_duplicate']),
        ),
      );
      final cards = await database.select(database.tagCards).get();

      expect(second.id, first.id);
      expect(second.status, TagCardStatus.snoozed);
      expect(
        second.snoozedUntil,
        DateTime.utc(2026, 5, 10, 21).millisecondsSinceEpoch,
      );
      expect(cards, hasLength(1));
      expect(second.sourceIds, ['src_bread', 'src_bread_duplicate']);
    },
  );

  test('delete card soft-deletes it from active card queries', () async {
    await _insertSource(database, id: 'src_bread');
    final card = await createCardFromProposal(
      CreateCardFromProposalParams(
        proposal: _proposal(sourceIds: const ['src_bread']),
      ),
    );

    await deleteCard(DeleteCardParams(cardId: card.id));

    final visibleCards = await cardRepository.getCards(
      CardListQuery(
        viewMode: TodayViewMode.all,
        filter: TodayCardFilter.all,
        now: _fixedNow(),
      ),
    );
    final row = await database.select(database.tagCards).getSingle();

    expect(visibleCards, isEmpty);
    expect(row.deletedAt, isA<int>());
    expect(row.notificationEnabled, isFalse);
  });
}

DateTime _fixedNow() => DateTime.utc(2026, 5, 10, 12);

CardProposal _proposal({
  String cardType = 'urgent',
  String title = 'Buy bread',
  List<String> sourceIds = const ['src_bread'],
  String? nextActiveDeadline = '2026-05-10T20:00:00+01:00',
  List<String> actions = const ['complete', 'snooze', 'cancel'],
}) {
  return CardProposal.fromJson({
    'card_type': cardType,
    'title': title,
    'reason': 'Detected from a message screenshot.',
    'space_name': 'Household Tasks',
    'next_active_deadline': nextActiveDeadline,
    'source_ids': sourceIds,
    'actions': actions,
    'confidence': 0.91,
  });
}

Future<void> _insertSource(TagDatabase database, {required String id}) async {
  final now = _fixedNow().millisecondsSinceEpoch;

  await database
      .into(database.sourceItems)
      .insert(
        SourceItemsCompanion.insert(
          id: id,
          type: 'screenshot',
          sourceSummary: const Value('WhatsApp screenshot'),
          appSource: const Value('WhatsApp'),
          contentType: const Value('message'),
          rawText: const Value('Please buy bread at 8pm'),
          extractedText: const Value('Please buy bread at 8pm'),
          createdAt: now,
          updatedAt: now,
        ),
      );
}
