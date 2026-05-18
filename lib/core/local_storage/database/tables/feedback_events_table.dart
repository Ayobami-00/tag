// ignore_for_file: recursive_getters

import 'package:drift/drift.dart';
import 'package:tag/core/local_storage/database/database_values.dart';
import 'package:tag/core/local_storage/database/tables/source_items_table.dart';
import 'package:tag/core/local_storage/database/tables/spaces_table.dart';
import 'package:tag/core/local_storage/database/tables/tag_cards_table.dart';

@TableIndex(name: 'idx_feedback_events_type', columns: {#eventType})
@TableIndex(name: 'idx_feedback_events_card_id', columns: {#cardId})
@TableIndex(name: 'idx_feedback_events_space_id', columns: {#spaceId})
@TableIndex(name: 'idx_feedback_events_created_at', columns: {#createdAt})
class FeedbackEvents extends Table {
  @override
  String get tableName => 'feedback_events';

  TextColumn get id => text()();
  TextColumn get eventType =>
      text().check(eventType.isIn(TagDatabaseValues.feedbackEventTypes))();
  TextColumn get cardId => text().nullable().references(TagCards, #id)();
  TextColumn get spaceId => text().nullable().references(Spaces, #id)();
  TextColumn get sourceId => text().nullable().references(SourceItems, #id)();
  TextColumn get goalPlanId => text().nullable()();
  TextColumn get detailsJson => text().withDefault(const Constant('{}'))();
  IntColumn get createdAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
