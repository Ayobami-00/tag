import 'package:equatable/equatable.dart';

enum SourceItemType {
  screenshot('screenshot'),
  image('image'),
  link('link'),
  text('text'),
  chat('chat'),
  savedPost('saved_post'),
  emailText('email_text'),
  manual('manual');

  const SourceItemType(this.storageValue);

  final String storageValue;

  static SourceItemType fromStorageValue(String value) {
    return SourceItemType.values.firstWhere(
      (type) => type.storageValue == value,
      orElse: () => SourceItemType.manual,
    );
  }
}

enum SourceProcessingState {
  saved('saved'),
  extracting('extracting'),
  extracted('extracted'),
  classifying('classifying'),
  proposed('proposed'),
  completed('completed'),
  failed('failed');

  const SourceProcessingState(this.storageValue);

  final String storageValue;

  static SourceProcessingState fromStorageValue(String value) {
    return SourceProcessingState.values.firstWhere(
      (state) => state.storageValue == value,
      orElse: () => SourceProcessingState.saved,
    );
  }
}

class SourceItemEntity extends Equatable {
  const SourceItemEntity({
    required this.id,
    required this.type,
    required this.contentType,
    required this.processingState,
    required this.createdAt,
    required this.updatedAt,
    this.originalUri,
    this.localFilePath,
    this.thumbnailFilePath,
    this.rawText,
    this.extractedText,
    this.sourceSummary,
    this.appSource,
    this.languageCode,
    this.detectedDatesJson = '[]',
    this.detectedTimesJson = '[]',
    this.detectedLinksJson = '[]',
    this.detectedEntitiesJson = '[]',
    this.visibleEntitiesJson = '[]',
    this.metadataJson = '{}',
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
  final double? extractionConfidence;
  final SourceProcessingState processingState;
  final String? failureReason;
  final int createdAt;
  final int updatedAt;

  String get displaySummary {
    final trimmedSummary = sourceSummary?.trim();
    if (trimmedSummary != null && trimmedSummary.isNotEmpty) {
      return trimmedSummary;
    }

    return switch (type) {
      SourceItemType.image || SourceItemType.screenshot => 'Manual image',
      SourceItemType.text || SourceItemType.chat => 'Manual text',
      _ => 'Saved source',
    };
  }

  String get displayTypeLabel {
    return switch (type) {
      SourceItemType.screenshot => 'Screenshot',
      SourceItemType.image => 'Image',
      SourceItemType.link => 'Link',
      SourceItemType.text => 'Text',
      SourceItemType.chat => 'Chat',
      SourceItemType.savedPost => 'Saved post',
      SourceItemType.emailText => 'Email text',
      SourceItemType.manual => 'Manual',
    };
  }

  SourceItemEntity copyWith({
    String? id,
    SourceItemType? type,
    String? originalUri,
    String? localFilePath,
    String? thumbnailFilePath,
    String? rawText,
    String? extractedText,
    String? sourceSummary,
    String? appSource,
    String? contentType,
    String? languageCode,
    String? detectedDatesJson,
    String? detectedTimesJson,
    String? detectedLinksJson,
    String? detectedEntitiesJson,
    String? visibleEntitiesJson,
    String? metadataJson,
    double? extractionConfidence,
    SourceProcessingState? processingState,
    String? failureReason,
    int? createdAt,
    int? updatedAt,
  }) {
    return SourceItemEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      originalUri: originalUri ?? this.originalUri,
      localFilePath: localFilePath ?? this.localFilePath,
      thumbnailFilePath: thumbnailFilePath ?? this.thumbnailFilePath,
      rawText: rawText ?? this.rawText,
      extractedText: extractedText ?? this.extractedText,
      sourceSummary: sourceSummary ?? this.sourceSummary,
      appSource: appSource ?? this.appSource,
      contentType: contentType ?? this.contentType,
      languageCode: languageCode ?? this.languageCode,
      detectedDatesJson: detectedDatesJson ?? this.detectedDatesJson,
      detectedTimesJson: detectedTimesJson ?? this.detectedTimesJson,
      detectedLinksJson: detectedLinksJson ?? this.detectedLinksJson,
      detectedEntitiesJson: detectedEntitiesJson ?? this.detectedEntitiesJson,
      visibleEntitiesJson: visibleEntitiesJson ?? this.visibleEntitiesJson,
      metadataJson: metadataJson ?? this.metadataJson,
      extractionConfidence: extractionConfidence ?? this.extractionConfidence,
      processingState: processingState ?? this.processingState,
      failureReason: failureReason ?? this.failureReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

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
    extractionConfidence,
    processingState,
    failureReason,
    createdAt,
    updatedAt,
  ];
}
