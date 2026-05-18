import 'package:drift/drift.dart';
import 'package:tag/core/local_storage/database/tag_database.dart';

abstract interface class SpacesLocalDataSource {
  Stream<void> watchSpaceChanges();

  Future<List<SpaceSummaryRecord>> getSpaceSummaries();

  Future<SpaceDetailRecord?> getSpaceDetail(String spaceId);
}

class SpaceSummaryRecord {
  const SpaceSummaryRecord({
    required this.space,
    required this.cards,
    required this.sourceIds,
  });

  final Space space;
  final List<TagCard> cards;
  final List<String> sourceIds;
}

class SpaceDetailRecord {
  const SpaceDetailRecord({
    required this.space,
    required this.cards,
    required this.sources,
    required this.cardSourceIds,
  });

  final Space space;
  final List<TagCard> cards;
  final List<SourceItem> sources;
  final Map<String, List<String>> cardSourceIds;
}

class DriftSpacesLocalDataSource implements SpacesLocalDataSource {
  const DriftSpacesLocalDataSource(this._database);

  final TagDatabase _database;

  @override
  Stream<void> watchSpaceChanges() {
    return _database
        .customSelect(
          '''
          SELECT spaces.id
          FROM spaces
          LEFT JOIN tag_cards
            ON tag_cards.space_id = spaces.id
          LEFT JOIN card_sources
            ON card_sources.card_id = tag_cards.id
          LEFT JOIN source_items
            ON source_items.id = card_sources.source_id
          LEFT JOIN goal_plans
            ON goal_plans.space_id = spaces.id
          WHERE spaces.deleted_at IS NULL
          GROUP BY spaces.id
          ''',
          readsFrom: {
            _database.spaces,
            _database.tagCards,
            _database.cardSources,
            _database.sourceItems,
            _database.goalPlans,
          },
        )
        .watch()
        .map((_) {});
  }

  @override
  Future<List<SpaceSummaryRecord>> getSpaceSummaries() async {
    final spaces =
        await (_database.select(_database.spaces)..where(
              (space) => space.deletedAt.isNull() & space.archivedAt.isNull(),
            ))
            .get();

    final records = <SpaceSummaryRecord>[];
    for (final space in spaces) {
      final cards = await _cardsForSpace(space.id);
      final sourceIds = await _sourceIdsForSpace(space.id);
      records.add(
        SpaceSummaryRecord(space: space, cards: cards, sourceIds: sourceIds),
      );
    }

    return records;
  }

  @override
  Future<SpaceDetailRecord?> getSpaceDetail(String spaceId) async {
    final space =
        await (_database.select(_database.spaces)..where((space) {
              return space.id.equals(spaceId) &
                  space.deletedAt.isNull() &
                  space.archivedAt.isNull();
            }))
            .getSingleOrNull();

    if (space == null) {
      return null;
    }

    final cards = await _cardsForSpace(spaceId);
    final cardSourceIds = <String, List<String>>{};
    for (final card in cards) {
      cardSourceIds[card.id] = await _sourceIdsForCard(card.id);
    }

    final sourceRows = await _sourcesForSpace(spaceId);

    return SpaceDetailRecord(
      space: space,
      cards: cards,
      sources: sourceRows,
      cardSourceIds: cardSourceIds,
    );
  }

  Future<List<TagCard>> _cardsForSpace(String spaceId) async {
    final rows =
        await (_database.select(_database.tagCards)..where(
              (card) =>
                  card.spaceId.equals(spaceId) &
                  card.deletedAt.isNull() &
                  card.archivedAt.isNull(),
            ))
            .get();

    rows.sort((left, right) {
      final leftAttention = left.snoozedUntil ?? left.nextActiveDeadline;
      final rightAttention = right.snoozedUntil ?? right.nextActiveDeadline;
      final timeCompare = (leftAttention ?? 1 << 62).compareTo(
        rightAttention ?? 1 << 62,
      );
      if (timeCompare != 0) {
        return timeCompare;
      }

      final createdCompare = left.createdAt.compareTo(right.createdAt);
      if (createdCompare != 0) {
        return createdCompare;
      }

      return left.id.compareTo(right.id);
    });

    return rows;
  }

  Future<List<String>> _sourceIdsForSpace(String spaceId) async {
    final rows = await _database
        .customSelect(
          '''
          SELECT DISTINCT card_sources.source_id AS source_id
          FROM card_sources
          INNER JOIN tag_cards
            ON tag_cards.id = card_sources.card_id
          INNER JOIN source_items
            ON source_items.id = card_sources.source_id
          WHERE tag_cards.space_id = ?
            AND tag_cards.deleted_at IS NULL
            AND tag_cards.archived_at IS NULL
            AND source_items.deleted_at IS NULL
          ''',
          variables: [Variable<String>(spaceId)],
          readsFrom: {
            _database.cardSources,
            _database.tagCards,
            _database.sourceItems,
          },
        )
        .get();

    return rows
        .map((row) => row.read<String>('source_id'))
        .toList(growable: false);
  }

  Future<List<String>> _sourceIdsForCard(String cardId) async {
    final rows = await (_database.select(
      _database.cardSources,
    )..where((source) => source.cardId.equals(cardId))).get();

    rows.sort((left, right) {
      if (left.role == right.role) {
        return left.createdAt.compareTo(right.createdAt);
      }
      if (left.role == 'primary' || left.role == 'chat_created') {
        return -1;
      }
      if (right.role == 'primary' || right.role == 'chat_created') {
        return 1;
      }
      return left.role.compareTo(right.role);
    });

    return rows.map((row) => row.sourceId).toList(growable: false);
  }

  Future<List<SourceItem>> _sourcesForSpace(String spaceId) async {
    final joined =
        _database.select(_database.sourceItems).join([
          innerJoin(
            _database.cardSources,
            _database.cardSources.sourceId.equalsExp(_database.sourceItems.id),
          ),
          innerJoin(
            _database.tagCards,
            _database.tagCards.id.equalsExp(_database.cardSources.cardId),
          ),
        ])..where(
          _database.tagCards.spaceId.equals(spaceId) &
              _database.tagCards.deletedAt.isNull() &
              _database.tagCards.archivedAt.isNull() &
              _database.sourceItems.deletedAt.isNull(),
        );

    final rows = await joined.get();
    final byId = <String, SourceItem>{};
    for (final row in rows) {
      final source = row.readTable(_database.sourceItems);
      byId[source.id] = source;
    }

    final sources = byId.values.toList(growable: false);
    sources.sort((left, right) {
      final createdCompare = right.createdAt.compareTo(left.createdAt);
      if (createdCompare != 0) {
        return createdCompare;
      }

      return left.id.compareTo(right.id);
    });

    return sources;
  }
}
