import 'package:drift/drift.dart';
import 'package:tag/core/local_storage/database/tag_database.dart';

abstract interface class SourceLocalDataSource {
  Future<SourceItem> insertSource(SourceItemsCompanion source);

  Future<SourceItem?> getSourceById(String id);

  Future<SourceItem?> getSourceByOriginalUri(String originalUri);

  Future<SourcePreviewRecord?> getSourcePreviewById(String sourceId);

  Stream<List<SourceItem>> watchRecentSources({int limit = 10});

  Future<SourceItem> updateProcessingState({
    required String sourceId,
    required String processingState,
    required int updatedAt,
    String? failureReason,
  });

  Future<SourceItem> updateExtractionResult({
    required String sourceId,
    required String extractedText,
    required String sourceSummary,
    required String contentType,
    required String languageCode,
    required String detectedDatesJson,
    required String detectedTimesJson,
    required String detectedLinksJson,
    required String detectedEntitiesJson,
    required String visibleEntitiesJson,
    required String metadataJson,
    required double extractionConfidence,
    required String processingState,
    required int updatedAt,
  });
}

class SourcePreviewRecord {
  const SourcePreviewRecord({required this.source, required this.relatedCards});

  final SourceItem source;
  final List<SourcePreviewRelatedCardRecord> relatedCards;
}

class SourcePreviewRelatedCardRecord {
  const SourcePreviewRelatedCardRecord({
    required this.card,
    required this.space,
    required this.cardSource,
  });

  final TagCard card;
  final Space space;
  final CardSource cardSource;
}

class DriftSourceLocalDataSource implements SourceLocalDataSource {
  const DriftSourceLocalDataSource(this._database);

  final TagDatabase _database;

  @override
  Future<SourceItem> insertSource(SourceItemsCompanion source) async {
    await _database.into(_database.sourceItems).insert(source);
    final inserted = await getSourceById(source.id.value);

    if (inserted == null) {
      throw StateError('Source row was not readable after insert.');
    }

    return inserted;
  }

  @override
  Future<SourceItem?> getSourceById(String id) {
    return (_database.select(
      _database.sourceItems,
    )..where((source) => source.id.equals(id))).getSingleOrNull();
  }

  @override
  Future<SourceItem?> getSourceByOriginalUri(String originalUri) {
    return (_database.select(_database.sourceItems)
          ..where(
            (source) =>
                source.originalUri.equals(originalUri) &
                source.deletedAt.isNull(),
          )
          ..orderBy([
            (source) => OrderingTerm(
              expression: source.createdAt,
              mode: OrderingMode.asc,
            ),
          ])
          ..limit(1))
        .getSingleOrNull();
  }

  @override
  Future<SourcePreviewRecord?> getSourcePreviewById(String sourceId) async {
    final source =
        await (_database.select(_database.sourceItems)..where((source) {
              return source.id.equals(sourceId) & source.deletedAt.isNull();
            }))
            .getSingleOrNull();

    if (source == null) {
      return null;
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
          _database.cardSources.sourceId.equals(sourceId) &
              _database.tagCards.deletedAt.isNull() &
              _database.spaces.deletedAt.isNull(),
        );

    final rows = await joined.get();
    final relatedCards = rows.map((row) {
      return SourcePreviewRelatedCardRecord(
        card: row.readTable(_database.tagCards),
        space: row.readTable(_database.spaces),
        cardSource: row.readTable(_database.cardSources),
      );
    }).toList();

    relatedCards.sort(_compareRelatedCards);

    return SourcePreviewRecord(source: source, relatedCards: relatedCards);
  }

  @override
  Stream<List<SourceItem>> watchRecentSources({int limit = 10}) {
    final query = _database.select(_database.sourceItems)
      ..where((source) => source.deletedAt.isNull())
      ..orderBy([
        (source) =>
            OrderingTerm(expression: source.createdAt, mode: OrderingMode.desc),
      ])
      ..limit(limit);

    return query.watch();
  }

  @override
  Future<SourceItem> updateProcessingState({
    required String sourceId,
    required String processingState,
    required int updatedAt,
    String? failureReason,
  }) async {
    await (_database.update(
      _database.sourceItems,
    )..where((source) => source.id.equals(sourceId))).write(
      SourceItemsCompanion(
        processingState: Value(processingState),
        failureReason: Value(failureReason),
        updatedAt: Value(updatedAt),
      ),
    );

    final updated = await getSourceById(sourceId);
    if (updated == null) {
      throw StateError('Source row was not readable after update.');
    }

    return updated;
  }

  @override
  Future<SourceItem> updateExtractionResult({
    required String sourceId,
    required String extractedText,
    required String sourceSummary,
    required String contentType,
    required String languageCode,
    required String detectedDatesJson,
    required String detectedTimesJson,
    required String detectedLinksJson,
    required String detectedEntitiesJson,
    required String visibleEntitiesJson,
    required String metadataJson,
    required double extractionConfidence,
    required String processingState,
    required int updatedAt,
  }) async {
    await (_database.update(
      _database.sourceItems,
    )..where((source) => source.id.equals(sourceId))).write(
      SourceItemsCompanion(
        extractedText: Value(extractedText),
        sourceSummary: Value(sourceSummary),
        contentType: Value(contentType),
        languageCode: Value(languageCode),
        detectedDatesJson: Value(detectedDatesJson),
        detectedTimesJson: Value(detectedTimesJson),
        detectedLinksJson: Value(detectedLinksJson),
        detectedEntitiesJson: Value(detectedEntitiesJson),
        visibleEntitiesJson: Value(visibleEntitiesJson),
        metadataJson: Value(metadataJson),
        extractionConfidence: Value(extractionConfidence),
        processingState: Value(processingState),
        failureReason: const Value(null),
        updatedAt: Value(updatedAt),
      ),
    );

    final updated = await getSourceById(sourceId);
    if (updated == null) {
      throw StateError('Source row was not readable after update.');
    }

    return updated;
  }

  int _compareRelatedCards(
    SourcePreviewRelatedCardRecord left,
    SourcePreviewRelatedCardRecord right,
  ) {
    final statusCompare = _statusRank(
      left.card.status,
    ).compareTo(_statusRank(right.card.status));
    if (statusCompare != 0) {
      return statusCompare;
    }

    final leftDeadline = left.card.nextActiveDeadline ?? 1 << 62;
    final rightDeadline = right.card.nextActiveDeadline ?? 1 << 62;
    if (leftDeadline != rightDeadline) {
      return leftDeadline.compareTo(rightDeadline);
    }

    final createdCompare = left.card.createdAt.compareTo(right.card.createdAt);
    if (createdCompare != 0) {
      return createdCompare;
    }

    return left.card.id.compareTo(right.card.id);
  }

  int _statusRank(String status) {
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
