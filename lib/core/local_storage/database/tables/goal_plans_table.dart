// ignore_for_file: recursive_getters

import 'package:drift/drift.dart';
import 'package:tag/core/local_storage/database/database_values.dart';
import 'package:tag/core/local_storage/database/tables/spaces_table.dart';

@TableIndex(name: 'idx_goal_plans_space_id', columns: {#spaceId})
@TableIndex(name: 'idx_goal_plans_status', columns: {#status})
class GoalPlans extends Table {
  @override
  String get tableName => 'goal_plans';

  TextColumn get id => text()();
  TextColumn get spaceId => text().references(Spaces, #id)();
  TextColumn get originCardId => text().nullable()();
  TextColumn get chatSessionId => text().nullable()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  IntColumn get durationWeeks => integer().nullable()();
  TextColumn get preferredDaysJson =>
      text().withDefault(const Constant('[]'))();
  IntColumn get sessionLengthMinutes => integer().nullable()();
  TextColumn get reminderPreferenceJson =>
      text().withDefault(const Constant('{}'))();
  TextColumn get status =>
      text().check(status.isIn(TagDatabaseValues.goalPlanStatuses))();
  TextColumn get createdBy =>
      text().check(createdBy.isIn(TagDatabaseValues.goalPlanCreatedBy))();
  TextColumn get modelSlug => text().nullable()();
  TextColumn get planPreviewJson => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get completedAt => integer().nullable()();
  IntColumn get cancelledAt => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
