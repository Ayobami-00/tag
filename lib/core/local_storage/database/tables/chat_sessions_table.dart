// ignore_for_file: recursive_getters

import 'package:drift/drift.dart';
import 'package:tag/core/local_storage/database/database_values.dart';
import 'package:tag/core/local_storage/database/tables/spaces_table.dart';

@TableIndex(name: 'idx_chat_sessions_purpose', columns: {#purpose})
@TableIndex(name: 'idx_chat_sessions_linked_card_id', columns: {#linkedCardId})
@TableIndex(name: 'idx_chat_sessions_updated_at', columns: {#updatedAt})
class ChatSessions extends Table {
  @override
  String get tableName => 'chat_sessions';

  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get purpose =>
      text().check(purpose.isIn(TagDatabaseValues.chatPurposes))();
  TextColumn get linkedCardId => text().nullable()();
  TextColumn get linkedSpaceId => text().nullable().references(Spaces, #id)();
  TextColumn get linkedGoalPlanId => text().nullable()();
  TextColumn get status =>
      text().check(status.isIn(TagDatabaseValues.chatStatuses))();
  TextColumn get pendingConfirmationJson => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get archivedAt => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
