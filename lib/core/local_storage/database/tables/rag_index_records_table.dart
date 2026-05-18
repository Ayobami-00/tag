import 'package:drift/drift.dart';
import 'package:tag/core/local_storage/database/tables/source_text_chunks_table.dart';

@TableIndex(
  name: 'idx_rag_index_records_index_external',
  columns: {#indexName, #externalId},
  unique: true,
)
@TableIndex(name: 'idx_rag_index_records_chunk_id', columns: {#sourceChunkId})
class RagIndexRecords extends Table {
  @override
  String get tableName => 'rag_index_records';

  TextColumn get id => text()();
  TextColumn get indexName => text()();
  TextColumn get externalId => text()();
  TextColumn get sourceChunkId => text().references(SourceTextChunks, #id)();
  TextColumn get embeddingModelSlug => text()();
  IntColumn get embeddingDimension => integer()();
  TextColumn get documentTextHash => text()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
