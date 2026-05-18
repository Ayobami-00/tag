import 'package:drift/drift.dart';
import 'package:tag/core/local_storage/database/tables/goal_plans_table.dart';
import 'package:tag/core/local_storage/database/tables/tag_cards_table.dart';

@TableIndex(name: 'idx_goal_plan_cards_goal_plan_id', columns: {#goalPlanId})
@TableIndex(
  name: 'idx_goal_plan_cards_sequence',
  columns: {#goalPlanId, #sequenceIndex},
  unique: true,
)
class GoalPlanCards extends Table {
  @override
  String get tableName => 'goal_plan_cards';

  TextColumn get goalPlanId => text().references(GoalPlans, #id)();
  TextColumn get cardId => text().references(TagCards, #id)();
  IntColumn get sequenceIndex => integer()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {goalPlanId, cardId};
}
