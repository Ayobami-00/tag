import 'package:drift/drift.dart';
import 'package:tag/core/local_storage/database/tag_database.dart'
    as database_models;
import 'package:tag/features/cards/domain/entities/card_entities.dart';
import 'package:tag/features/source_ingestion/data/data_sources/source_local_data_source.dart';
import 'package:tag/features/source_ingestion/domain/entities/source_item_entity.dart';
import 'package:tag/features/source_ingestion/domain/entities/source_preview_entity.dart';
import 'package:tag/features/source_ingestion/domain/repositories/source_repository.dart';

class SourceRepositoryImpl implements SourceRepository {
  const SourceRepositoryImpl({
    required SourceLocalDataSource localDataSource,
    DateTime Function()? now,
  }) : _localDataSource = localDataSource,
       _now = now ?? DateTime.now;

  final SourceLocalDataSource _localDataSource;
  final DateTime Function() _now;

  @override
  Future<SourceItemEntity> createSource(CreateSourceRequest request) async {
    final timestamp = _timestamp();
    final row = await _localDataSource.insertSource(
      database_models.SourceItemsCompanion.insert(
        id: request.id,
        type: request.type.storageValue,
        originalUri: _nullableValue(request.originalUri),
        localFilePath: _nullableValue(request.localFilePath),
        thumbnailFilePath: _nullableValue(request.thumbnailFilePath),
        rawText: _nullableValue(request.rawText),
        extractedText: _nullableValue(request.extractedText),
        sourceSummary: _nullableValue(request.sourceSummary),
        appSource: _nullableValue(request.appSource),
        contentType: Value(request.contentType),
        languageCode: _nullableValue(request.languageCode),
        detectedDatesJson: Value(request.detectedDatesJson),
        detectedTimesJson: Value(request.detectedTimesJson),
        detectedLinksJson: Value(request.detectedLinksJson),
        detectedEntitiesJson: Value(request.detectedEntitiesJson),
        visibleEntitiesJson: Value(request.visibleEntitiesJson),
        metadataJson: Value(request.metadataJson),
        processingState: Value(request.processingState.storageValue),
        extractionConfidence: _nullableValue(request.extractionConfidence),
        failureReason: _nullableValue(request.failureReason),
        createdAt: timestamp,
        updatedAt: timestamp,
      ),
    );

    return _mapSource(row);
  }

  @override
  Future<SourceItemEntity?> getSourceById(String id) async {
    final row = await _localDataSource.getSourceById(id);
    return row == null ? null : _mapSource(row);
  }

  @override
  Future<SourceItemEntity?> getSourceByOriginalUri(String originalUri) async {
    final row = await _localDataSource.getSourceByOriginalUri(originalUri);
    return row == null ? null : _mapSource(row);
  }

  @override
  Future<SourcePreviewEntity?> getSourcePreviewById(String sourceId) async {
    final record = await _localDataSource.getSourcePreviewById(sourceId);
    if (record == null) {
      return null;
    }

    return SourcePreviewEntity(
      source: _mapSource(record.source),
      relatedCards: record.relatedCards
          .map(_mapRelatedCard)
          .toList(growable: false),
    );
  }

  @override
  Stream<List<SourceItemEntity>> watchRecentSources({int limit = 10}) {
    return _localDataSource
        .watchRecentSources(limit: limit)
        .map((rows) => rows.map(_mapSource).toList(growable: false));
  }

  @override
  Future<SourceItemEntity> updateProcessingState({
    required String sourceId,
    required SourceProcessingState processingState,
    String? failureReason,
  }) async {
    final row = await _localDataSource.updateProcessingState(
      sourceId: sourceId,
      processingState: processingState.storageValue,
      failureReason: failureReason,
      updatedAt: _timestamp(),
    );

    return _mapSource(row);
  }

  @override
  Future<SourceItemEntity> updateExtractionResult({
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
    required SourceProcessingState processingState,
  }) async {
    final row = await _localDataSource.updateExtractionResult(
      sourceId: sourceId,
      extractedText: extractedText,
      sourceSummary: sourceSummary,
      contentType: contentType,
      languageCode: languageCode,
      detectedDatesJson: detectedDatesJson,
      detectedTimesJson: detectedTimesJson,
      detectedLinksJson: detectedLinksJson,
      detectedEntitiesJson: detectedEntitiesJson,
      visibleEntitiesJson: visibleEntitiesJson,
      metadataJson: metadataJson,
      extractionConfidence: extractionConfidence,
      processingState: processingState.storageValue,
      updatedAt: _timestamp(),
    );

    return _mapSource(row);
  }

  SourceItemEntity _mapSource(database_models.SourceItem row) {
    return SourceItemEntity(
      id: row.id,
      type: SourceItemType.fromStorageValue(row.type),
      originalUri: row.originalUri,
      localFilePath: row.localFilePath,
      thumbnailFilePath: row.thumbnailFilePath,
      rawText: row.rawText,
      extractedText: row.extractedText,
      sourceSummary: row.sourceSummary,
      appSource: row.appSource,
      contentType: row.contentType,
      languageCode: row.languageCode,
      detectedDatesJson: row.detectedDatesJson,
      detectedTimesJson: row.detectedTimesJson,
      detectedLinksJson: row.detectedLinksJson,
      detectedEntitiesJson: row.detectedEntitiesJson,
      visibleEntitiesJson: row.visibleEntitiesJson,
      metadataJson: row.metadataJson,
      extractionConfidence: row.extractionConfidence,
      processingState: SourceProcessingState.fromStorageValue(
        row.processingState,
      ),
      failureReason: row.failureReason,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  SourcePreviewRelatedCardEntity _mapRelatedCard(
    SourcePreviewRelatedCardRecord record,
  ) {
    final card = record.card;
    final space = record.space;
    final cardSource = record.cardSource;

    return SourcePreviewRelatedCardEntity(
      cardId: card.id,
      cardType: TagCardType.fromStorageValue(card.cardType),
      status: TagCardStatus.fromStorageValue(card.status),
      title: card.title,
      reason: card.reason,
      space: SpaceEntity(
        id: space.id,
        name: space.name,
        normalizedName: space.normalizedName,
        type: SpaceType.fromStorageValue(space.type),
        description: space.description,
        primaryIntentionType: space.primaryIntentionType,
        createdBy: space.createdBy,
        confidence: space.confidence,
        createdAt: space.createdAt,
        updatedAt: space.updatedAt,
      ),
      nextActiveDeadline: card.nextActiveDeadline,
      sourceSummary: card.sourceSummary,
      evidenceSummary: card.evidenceSummary,
      role: cardSource.role,
      evidenceText: cardSource.evidenceText,
      createdAt: card.createdAt,
    );
  }

  Value<T?> _nullableValue<T>(T? value) {
    return value == null ? const Value.absent() : Value(value);
  }

  int _timestamp() => _now().toUtc().millisecondsSinceEpoch;
}
