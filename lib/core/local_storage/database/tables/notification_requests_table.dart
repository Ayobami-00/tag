// ignore_for_file: recursive_getters

import 'package:drift/drift.dart';
import 'package:tag/core/local_storage/database/database_values.dart';
import 'package:tag/core/local_storage/database/tables/tag_cards_table.dart';

@TableIndex(name: 'idx_notification_requests_card_id', columns: {#cardId})
@TableIndex(name: 'idx_notification_requests_status', columns: {#status})
@TableIndex(
  name: 'idx_notification_requests_scheduled_for',
  columns: {#scheduledFor},
)
class NotificationRequests extends Table {
  @override
  String get tableName => 'notification_requests';

  TextColumn get id => text()();
  TextColumn get cardId => text().references(TagCards, #id)();
  IntColumn get platformNotificationId => integer()();
  IntColumn get scheduledFor => integer()();
  TextColumn get timezone => text()();
  TextColumn get status =>
      text().check(status.isIn(TagDatabaseValues.notificationStatuses))();
  TextColumn get title => text()();
  TextColumn get body => text()();
  TextColumn get actionsJson => text().withDefault(const Constant('[]'))();
  TextColumn get failureReason => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get cancelledAt => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
