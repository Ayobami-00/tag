import 'package:drift/drift.dart';
import 'package:tag/core/local_storage/database/tag_database.dart';

abstract interface class RagLocalDataSource {
  Future<List<RagChunkIndexRecord>> loadChunksForSource(String sourceId);

  Future<SourceTextChunk> upsertSourceChunk(SourceTextChunksCompanion chunk);

  Future<RagIndexRecord> upsertRagIndexRecord(RagIndexRecordsCompanion record);

  Future<List<RemovedRagChunkRecord>> deleteChunksOutsideIds({
    required String sourceId,
    required Set<String> retainedChunkIds,
  });

  Future<List<RemovedRagChunkRecord>> deleteChunksForSource(String sourceId);

  Future<List<RagSearchContextRecord>> loadSearchContexts({
    required String indexName,
    required List<String> externalIds,
  });

  Future<List<RagKeywordSearchContextRecord>> loadKeywordSearchCorpus({
    int limit = 200,
  });

  Future<RagIndexCounts> loadIndexCounts(String indexName);

  Future<List<RagChunkIndexRecord>> loadIndexedChunks(String indexName);
}

class RagChunkIndexRecord {
  const RagChunkIndexRecord({required this.chunk, this.indexRecord});

  final SourceTextChunk chunk;
  final RagIndexRecord? indexRecord;
}

class RemovedRagChunkRecord {
  const RemovedRagChunkRecord({required this.chunk, this.indexRecord});

  final SourceTextChunk chunk;
  final RagIndexRecord? indexRecord;
}

class RagSearchContextRecord {
  const RagSearchContextRecord({
    required this.chunk,
    required this.indexRecord,
    required this.source,
    required this.relatedCards,
  });

  final SourceTextChunk chunk;
  final RagIndexRecord indexRecord;
  final SourceItem source;
  final List<RagRelatedCardRecord> relatedCards;
}

class RagRelatedCardRecord {
  const RagRelatedCardRecord({
    required this.card,
    required this.space,
    required this.cardSource,
  });

  final TagCard card;
  final Space space;
  final CardSource cardSource;
}

class RagKeywordSearchContextRecord {
  const RagKeywordSearchContextRecord({
    required this.source,
    required this.relatedCards,
    this.chunk,
  });

  final SourceItem source;
  final SourceTextChunk? chunk;
  final List<RagRelatedCardRecord> relatedCards;
}

class RagIndexCounts {
  const RagIndexCounts({required this.chunkCount, required this.recordCount});

  final int chunkCount;
  final int recordCount;
}

class DriftRagLocalDataSource implements RagLocalDataSource {
  const DriftRagLocalDataSource(this._database);

  final TagDatabase _database;

  @override
  Future<List<RagChunkIndexRecord>> loadChunksForSource(String sourceId) async {
    final query =
        _database.select(_database.sourceTextChunks).join([
            leftOuterJoin(
              _database.ragIndexRecords,
              _database.ragIndexRecords.sourceChunkId.equalsExp(
                _database.sourceTextChunks.id,
              ),
            ),
          ])
          ..where(_database.sourceTextChunks.sourceId.equals(sourceId))
          ..orderBy([OrderingTerm.asc(_database.sourceTextChunks.chunkIndex)]);

    final rows = await query.get();
    return rows
        .map((row) {
          return RagChunkIndexRecord(
            chunk: row.readTable(_database.sourceTextChunks),
            indexRecord: row.readTableOrNull(_database.ragIndexRecords),
          );
        })
        .toList(growable: false);
  }

  @override
  Future<SourceTextChunk> upsertSourceChunk(
    SourceTextChunksCompanion chunk,
  ) async {
    await _database
        .into(_database.sourceTextChunks)
        .insertOnConflictUpdate(chunk);

    return (_database.select(
      _database.sourceTextChunks,
    )..where((table) => table.id.equals(chunk.id.value))).getSingle();
  }

  @override
  Future<RagIndexRecord> upsertRagIndexRecord(
    RagIndexRecordsCompanion record,
  ) async {
    await _database
        .into(_database.ragIndexRecords)
        .insertOnConflictUpdate(record);

    return (_database.select(
      _database.ragIndexRecords,
    )..where((table) => table.id.equals(record.id.value))).getSingle();
  }

  @override
  Future<List<RemovedRagChunkRecord>> deleteChunksOutsideIds({
    required String sourceId,
    required Set<String> retainedChunkIds,
  }) async {
    final existing = await loadChunksForSource(sourceId);
    final removed = existing
        .where((record) {
          return !retainedChunkIds.contains(record.chunk.id);
        })
        .map((record) {
          return RemovedRagChunkRecord(
            chunk: record.chunk,
            indexRecord: record.indexRecord,
          );
        })
        .toList(growable: false);

    await _deleteRecords(removed);
    return removed;
  }

  @override
  Future<List<RemovedRagChunkRecord>> deleteChunksForSource(
    String sourceId,
  ) async {
    final removed = (await loadChunksForSource(sourceId))
        .map((record) {
          return RemovedRagChunkRecord(
            chunk: record.chunk,
            indexRecord: record.indexRecord,
          );
        })
        .toList(growable: false);

    await _deleteRecords(removed);
    return removed;
  }

  @override
  Future<List<RagSearchContextRecord>> loadSearchContexts({
    required String indexName,
    required List<String> externalIds,
  }) async {
    if (externalIds.isEmpty) {
      return const [];
    }

    final records =
        await (_database.select(_database.ragIndexRecords)..where((record) {
              return record.indexName.equals(indexName) &
                  record.externalId.isIn(externalIds);
            }))
            .get();
    if (records.isEmpty) {
      return const [];
    }

    final chunkIds = records
        .map((record) => record.sourceChunkId)
        .toSet()
        .toList(growable: false);
    final chunks =
        await (_database.select(_database.sourceTextChunks)..where((chunk) {
              return chunk.id.isIn(chunkIds);
            }))
            .get();
    final chunksById = {for (final chunk in chunks) chunk.id: chunk};

    final sourceIds = chunks
        .map((chunk) => chunk.sourceId)
        .toSet()
        .toList(growable: false);
    final sources =
        await (_database.select(_database.sourceItems)..where((source) {
              return source.id.isIn(sourceIds) & source.deletedAt.isNull();
            }))
            .get();
    final sourcesById = {for (final source in sources) source.id: source};

    final relatedCardsBySourceId = await _loadRelatedCards(sourceIds);
    final contexts = <RagSearchContextRecord>[];
    for (final record in records) {
      final chunk = chunksById[record.sourceChunkId];
      final source = chunk == null ? null : sourcesById[chunk.sourceId];
      if (chunk == null || source == null) {
        continue;
      }

      contexts.add(
        RagSearchContextRecord(
          chunk: chunk,
          indexRecord: record,
          source: source,
          relatedCards: relatedCardsBySourceId[source.id] ?? const [],
        ),
      );
    }

    final order = <String, int>{
      for (var index = 0; index < externalIds.length; index++)
        externalIds[index]: index,
    };
    contexts.sort((left, right) {
      return (order[left.indexRecord.externalId] ?? 1 << 30).compareTo(
        order[right.indexRecord.externalId] ?? 1 << 30,
      );
    });

    return contexts;
  }

  @override
  Future<List<RagKeywordSearchContextRecord>> loadKeywordSearchCorpus({
    int limit = 200,
  }) async {
    final sourceLimit = limit < 1 ? 1 : limit;
    final sources =
        await (_database.select(_database.sourceItems)
              ..where((source) => source.deletedAt.isNull())
              ..orderBy([
                (source) => OrderingTerm(
                  expression: source.updatedAt,
                  mode: OrderingMode.desc,
                ),
              ])
              ..limit(sourceLimit))
            .get();
    if (sources.isEmpty) {
      return const [];
    }

    final sourceIds = sources.map((source) => source.id).toList();
    final chunks =
        await (_database.select(_database.sourceTextChunks)
              ..where((chunk) => chunk.sourceId.isIn(sourceIds))
              ..orderBy([
                (chunk) => OrderingTerm.asc(chunk.sourceId),
                (chunk) => OrderingTerm.asc(chunk.chunkIndex),
              ]))
            .get();
    final firstChunkBySourceId = <String, SourceTextChunk>{};
    for (final chunk in chunks) {
      firstChunkBySourceId.putIfAbsent(chunk.sourceId, () => chunk);
    }

    final relatedCardsBySourceId = await _loadRelatedCards(sourceIds);
    return [
      for (final source in sources)
        RagKeywordSearchContextRecord(
          source: source,
          chunk: firstChunkBySourceId[source.id],
          relatedCards: relatedCardsBySourceId[source.id] ?? const [],
        ),
    ];
  }

  @override
  Future<RagIndexCounts> loadIndexCounts(String indexName) async {
    final recordCountExpression = _database.ragIndexRecords.id.count();
    final recordCountRow =
        await (_database.selectOnly(_database.ragIndexRecords)
              ..addColumns([recordCountExpression])
              ..where(_database.ragIndexRecords.indexName.equals(indexName)))
            .getSingle();

    final chunkCountExpression = _database.sourceTextChunks.id.count();
    final chunkCountRow =
        await (_database.selectOnly(_database.sourceTextChunks)
              ..addColumns([chunkCountExpression])
              ..where(
                _database.sourceTextChunks.vectorIndexName.equals(indexName),
              ))
            .getSingle();

    return RagIndexCounts(
      chunkCount: chunkCountRow.read(chunkCountExpression) ?? 0,
      recordCount: recordCountRow.read(recordCountExpression) ?? 0,
    );
  }

  @override
  Future<List<RagChunkIndexRecord>> loadIndexedChunks(String indexName) async {
    final query = _database.select(_database.sourceTextChunks).join([
      innerJoin(
        _database.ragIndexRecords,
        _database.ragIndexRecords.sourceChunkId.equalsExp(
          _database.sourceTextChunks.id,
        ),
      ),
    ])..where(_database.ragIndexRecords.indexName.equals(indexName));

    final rows = await query.get();
    return rows
        .map((row) {
          return RagChunkIndexRecord(
            chunk: row.readTable(_database.sourceTextChunks),
            indexRecord: row.readTable(_database.ragIndexRecords),
          );
        })
        .toList(growable: false);
  }

  Future<Map<String, List<RagRelatedCardRecord>>> _loadRelatedCards(
    List<String> sourceIds,
  ) async {
    if (sourceIds.isEmpty) {
      return const {};
    }

    final joined =
        _database.select(_database.cardSources).join([
          innerJoin(
            _database.tagCards,
            _database.tagCards.id.equalsExp(_database.cardSources.cardId),
          ),
          innerJoin(
            _database.spaces,
            _database.spaces.id.equalsExp(_database.tagCards.spaceId),
          ),
        ])..where(
          _database.cardSources.sourceId.isIn(sourceIds) &
              _database.tagCards.deletedAt.isNull() &
              _database.spaces.deletedAt.isNull(),
        );

    final rows = await joined.get();
    final bySourceId = <String, List<RagRelatedCardRecord>>{};
    for (final row in rows) {
      final cardSource = row.readTable(_database.cardSources);
      bySourceId
          .putIfAbsent(cardSource.sourceId, () => [])
          .add(
            RagRelatedCardRecord(
              card: row.readTable(_database.tagCards),
              space: row.readTable(_database.spaces),
              cardSource: cardSource,
            ),
          );
    }

    for (final records in bySourceId.values) {
      records.sort(_compareRelatedCards);
    }

    return bySourceId;
  }

  Future<void> _deleteRecords(List<RemovedRagChunkRecord> records) async {
    if (records.isEmpty) {
      return;
    }

    final chunkIds = records.map((record) => record.chunk.id).toList();
    await _database.transaction(() async {
      await (_database.delete(_database.ragIndexRecords)..where((record) {
            return record.sourceChunkId.isIn(chunkIds);
          }))
          .go();
      await (_database.delete(_database.sourceTextChunks)..where((chunk) {
            return chunk.id.isIn(chunkIds);
          }))
          .go();
    });
  }

  int _compareRelatedCards(
    RagRelatedCardRecord left,
    RagRelatedCardRecord right,
  ) {
    final activeCompare = _activeRank(
      left.card.status,
    ).compareTo(_activeRank(right.card.status));
    if (activeCompare != 0) {
      return activeCompare;
    }

    final leftDeadline = left.card.nextActiveDeadline ?? 1 << 62;
    final rightDeadline = right.card.nextActiveDeadline ?? 1 << 62;
    if (leftDeadline != rightDeadline) {
      return leftDeadline.compareTo(rightDeadline);
    }

    return left.card.createdAt.compareTo(right.card.createdAt);
  }

  int _activeRank(String status) {
    return switch (status) {
      'active' => 0,
      'snoozed' => 1,
      'completed' => 2,
      'cancelled' || 'dismissed' => 3,
      'archived' => 4,
      _ => 5,
    };
  }
}
