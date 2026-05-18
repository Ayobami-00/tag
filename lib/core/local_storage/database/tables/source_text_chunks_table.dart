import 'package:drift/drift.dart';
import 'package:tag/core/local_storage/database/tables/source_items_table.dart';

@TableIndex(name: 'idx_source_text_chunks_source_id', columns: {#sourceId})
@TableIndex(
  name: 'idx_source_text_chunks_source_chunk',
  columns: {#sourceId, #chunkIndex},
  unique: true,
)
@TableIndex(
  name: 'idx_source_text_chunks_vector_external_id',
  columns: {#vectorExternalId},
)
class SourceTextChunks extends Table {
  @override
  String get tableName => 'source_text_chunks';

  TextColumn get id => text()();
  TextColumn get sourceId => text().references(SourceItems, #id)();
  IntColumn get chunkIndex => integer()();
  TextColumn get chunkText => text()();
  IntColumn get charStart => integer().nullable()();
  IntColumn get charEnd => integer().nullable()();
  IntColumn get tokenCountEstimate => integer().nullable()();
  TextColumn get embeddingModelSlug => text().nullable()();
  TextColumn get vectorIndexName => text().nullable()();
  TextColumn get vectorExternalId => text().nullable()();
  IntColumn get embeddingDimension => integer().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
