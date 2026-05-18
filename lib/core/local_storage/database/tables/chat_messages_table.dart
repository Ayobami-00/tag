// ignore_for_file: recursive_getters

import 'package:drift/drift.dart';
import 'package:tag/core/local_storage/database/database_values.dart';
import 'package:tag/core/local_storage/database/tables/chat_sessions_table.dart';

@TableIndex(name: 'idx_chat_messages_session_id', columns: {#chatSessionId})
@TableIndex(name: 'idx_chat_messages_created_at', columns: {#createdAt})
class ChatMessages extends Table {
  @override
  String get tableName => 'chat_messages';

  TextColumn get id => text()();
  TextColumn get chatSessionId => text().references(ChatSessions, #id)();
  TextColumn get role => text().check(role.isIn(TagDatabaseValues.chatRoles))();
  TextColumn get content => text()();
  TextColumn get contentJson => text().nullable()();
  TextColumn get toolCallsJson => text().nullable()();
  TextColumn get sourceIdsJson => text().withDefault(const Constant('[]'))();
  TextColumn get cardIdsJson => text().withDefault(const Constant('[]'))();
  TextColumn get modelSlug => text().nullable()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
