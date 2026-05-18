// ignore_for_file: recursive_getters

import 'package:drift/drift.dart';
import 'package:tag/core/local_storage/database/database_values.dart';
import 'package:tag/core/local_storage/database/tables/chat_sessions_table.dart';
import 'package:tag/core/local_storage/database/tables/source_items_table.dart';
import 'package:tag/core/local_storage/database/tables/spaces_table.dart';
import 'package:tag/core/local_storage/database/tables/tag_cards_table.dart';

@TableIndex(
  name: 'idx_ai_processing_jobs_status_priority',
  columns: {#status, #priority},
)
@TableIndex(name: 'idx_ai_processing_jobs_source_id', columns: {#sourceId})
@TableIndex(
  name: 'idx_ai_processing_jobs_chat_session_id',
  columns: {#chatSessionId},
)
class AiProcessingJobs extends Table {
  @override
  String get tableName => 'ai_processing_jobs';

  TextColumn get id => text()();
  TextColumn get jobType =>
      text().check(jobType.isIn(TagDatabaseValues.aiJobTypes))();
  TextColumn get status =>
      text().check(status.isIn(TagDatabaseValues.aiJobStatuses))();
  TextColumn get sourceId => text().nullable().references(SourceItems, #id)();
  TextColumn get cardId => text().nullable().references(TagCards, #id)();
  TextColumn get spaceId => text().nullable().references(Spaces, #id)();
  TextColumn get chatSessionId =>
      text().nullable().references(ChatSessions, #id)();
  IntColumn get priority => integer().withDefault(const Constant(100))();
  IntColumn get attemptCount => integer().withDefault(const Constant(0))();
  IntColumn get maxAttempts => integer().withDefault(const Constant(3))();
  TextColumn get inputJson => text().withDefault(const Constant('{}'))();
  TextColumn get outputJson => text().nullable()();
  TextColumn get errorMessage => text().nullable()();
  TextColumn get modelSlug => text().nullable()();
  IntColumn get queuedAt => integer()();
  IntColumn get startedAt => integer().nullable()();
  IntColumn get completedAt => integer().nullable()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
