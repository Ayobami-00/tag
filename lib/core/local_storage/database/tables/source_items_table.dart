// ignore_for_file: recursive_getters

import 'package:drift/drift.dart';
import 'package:tag/core/local_storage/database/database_values.dart';

@TableIndex(name: 'idx_source_items_created_at', columns: {#createdAt})
@TableIndex(name: 'idx_source_items_type', columns: {#type})
@TableIndex(
  name: 'idx_source_items_processing_state',
  columns: {#processingState},
)
@TableIndex(name: 'idx_source_items_content_type', columns: {#contentType})
class SourceItems extends Table {
  @override
  String get tableName => 'source_items';

  TextColumn get id => text()();
  TextColumn get type =>
      text().check(type.isIn(TagDatabaseValues.sourceTypes))();
  TextColumn get originalUri => text().nullable()();
  TextColumn get localFilePath => text().nullable()();
  TextColumn get thumbnailFilePath => text().nullable()();
  TextColumn get rawText => text().nullable()();
  TextColumn get extractedText => text().nullable()();
  TextColumn get sourceSummary => text().nullable()();
  TextColumn get appSource => text().nullable()();
  TextColumn get contentType => text()
      .check(contentType.isIn(TagDatabaseValues.contentTypes))
      .withDefault(const Constant('unknown'))();
  TextColumn get languageCode => text().nullable()();
  TextColumn get detectedDatesJson =>
      text().withDefault(const Constant('[]'))();
  TextColumn get detectedTimesJson =>
      text().withDefault(const Constant('[]'))();
  TextColumn get detectedLinksJson =>
      text().withDefault(const Constant('[]'))();
  TextColumn get detectedEntitiesJson =>
      text().withDefault(const Constant('[]'))();
  TextColumn get visibleEntitiesJson =>
      text().withDefault(const Constant('[]'))();
  TextColumn get metadataJson => text().withDefault(const Constant('{}'))();
  TextColumn get processingState => text()
      .check(processingState.isIn(TagDatabaseValues.sourceProcessingStates))
      .withDefault(const Constant('saved'))();
  RealColumn get extractionConfidence => real().nullable()();
  TextColumn get failureReason => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get deletedAt => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK (extraction_confidence IS NULL OR '
        '(extraction_confidence >= 0.0 AND extraction_confidence <= 1.0))',
  ];
}
