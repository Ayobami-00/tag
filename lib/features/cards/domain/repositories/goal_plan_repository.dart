import 'package:tag/core/ai/schemas/goal_plan_preview_schema.dart';
import 'package:tag/features/cards/domain/entities/goal_plan_entities.dart';

abstract interface class GoalPlanRepository {
  Future<GoalPlanCreationResult> createFromConfirmation(
    GoalPlanConfirmation confirmation,
  );

  Future<GoalPlanEntity?> getGoalPlanById(String id);

  Future<List<GoalPlanCardEntity>> getGoalPlanCards(String goalPlanId);

  Future<GoalPlanFutureUpdateResult> updateFutureGoalCards({
    required String goalPlanId,
    required GoalPlanPreview preview,
    int? sessionLengthMinutes,
    String? editSummary,
    bool includeCompleted = false,
  });
}
