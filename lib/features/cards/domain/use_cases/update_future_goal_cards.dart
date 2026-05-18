import 'package:equatable/equatable.dart';
import 'package:tag/core/ai/schemas/goal_plan_preview_schema.dart';
import 'package:tag/core/notifications/local_notification_service.dart';
import 'package:tag/core/use_cases/use_cases.dart';
import 'package:tag/features/cards/domain/entities/goal_plan_entities.dart';
import 'package:tag/features/cards/domain/repositories/goal_plan_repository.dart';
import 'package:tag/features/cards/domain/use_cases/card_notification_snapshot.dart';

class UpdateFutureGoalCards
    with UseCases<GoalPlanFutureUpdateResult, UpdateFutureGoalCardsParams> {
  const UpdateFutureGoalCards({
    required GoalPlanRepository goalPlanRepository,
    LocalNotificationService? notificationService,
  }) : _goalPlanRepository = goalPlanRepository,
       _notificationService = notificationService;

  final GoalPlanRepository _goalPlanRepository;
  final LocalNotificationService? _notificationService;

  @override
  Future<GoalPlanFutureUpdateResult> call(
    UpdateFutureGoalCardsParams params,
  ) async {
    final result = await _goalPlanRepository.updateFutureGoalCards(
      goalPlanId: params.goalPlanId,
      preview: params.preview,
      sessionLengthMinutes: params.sessionLengthMinutes,
      editSummary: params.editSummary,
      includeCompleted: params.includeCompleted,
    );

    for (final card in result.updatedCards) {
      await _notificationService?.scheduleCardNotification(
        notificationSnapshotFor(card),
      );
    }

    return result;
  }
}

class UpdateFutureGoalCardsParams extends Equatable {
  const UpdateFutureGoalCardsParams({
    required this.goalPlanId,
    required this.preview,
    this.sessionLengthMinutes,
    this.editSummary,
    this.includeCompleted = false,
  });

  final String goalPlanId;
  final GoalPlanPreview preview;
  final int? sessionLengthMinutes;
  final String? editSummary;
  final bool includeCompleted;

  @override
  List<Object?> get props => [
    goalPlanId,
    preview,
    sessionLengthMinutes,
    editSummary,
    includeCompleted,
  ];
}
