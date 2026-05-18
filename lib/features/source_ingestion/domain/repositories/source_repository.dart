import 'package:equatable/equatable.dart';
import 'package:tag/features/source_ingestion/domain/entities/source_item_entity.dart';
import 'package:tag/features/source_ingestion/domain/entities/source_preview_entity.dart';

class CreateSourceRequest extends Equatable {
  const CreateSourceRequest({
    required this.id,
    required this.type,
    this.originalUri,
    this.localFilePath,
    this.thumbnailFilePath,
    this.rawText,
    this.extractedText,
    this.sourceSummary,
    this.appSource = 'Manual',
    this.contentType = 'unknown',
    this.languageCode,
    this.detectedDatesJson = '[]',
    this.detectedTimesJson = '[]',
    this.detectedLinksJson = '[]',
    this.detectedEntitiesJson = '[]',
    this.visibleEntitiesJson = '[]',
    this.metadataJson = '{}',
    this.processingState = SourceProcessingState.saved,
    this.extractionConfidence,
    this.failureReason,
  });

  final String id;
  final SourceItemType type;
  final String? originalUri;
  final String? localFilePath;
  final String? thumbnailFilePath;
  final String? rawText;
  final String? extractedText;
  final String? sourceSummary;
  final String? appSource;
  final String contentType;
  final String? languageCode;
  final String detectedDatesJson;
  final String detectedTimesJson;
  final String detectedLinksJson;
  final String detectedEntitiesJson;
  final String visibleEntitiesJson;
  final String metadataJson;
  final SourceProcessingState processingState;
  final double? extractionConfidence;
  final String? failureReason;

  @override
  List<Object?> get props => [
    id,
    type,
    originalUri,
    localFilePath,
    thumbnailFilePath,
    rawText,
    extractedText,
    sourceSummary,
    appSource,
    contentType,
    languageCode,
    detectedDatesJson,
    detectedTimesJson,
    detectedLinksJson,
    detectedEntitiesJson,
    visibleEntitiesJson,
    metadataJson,
    processingState,
    extractionConfidence,
    failureReason,
  ];
}

abstract interface class SourceRepository {
  Future<SourceItemEntity> createSource(CreateSourceRequest request);

  Future<SourceItemEntity?> getSourceById(String id);

  Future<SourceItemEntity?> getSourceByOriginalUri(String originalUri);

  Future<SourcePreviewEntity?> getSourcePreviewById(String sourceId);

  Stream<List<SourceItemEntity>> watchRecentSources({int limit = 10});

  Future<SourceItemEntity> updateProcessingState({
    required String sourceId,
    required SourceProcessingState processingState,
    String? failureReason,
  });

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
  });
}
