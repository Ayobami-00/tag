import 'package:equatable/equatable.dart';
import 'package:tag/core/notifications/local_notification_service.dart';
import 'package:tag/core/use_cases/use_cases.dart';
import 'package:tag/features/cards/domain/entities/goal_plan_entities.dart';
import 'package:tag/features/cards/domain/repositories/goal_plan_repository.dart';
import 'package:tag/features/cards/domain/use_cases/card_notification_snapshot.dart';

class CreateGoalCardsFromPlan
    with UseCases<GoalPlanCreationResult, CreateGoalCardsFromPlanParams> {
  const CreateGoalCardsFromPlan({
    required GoalPlanRepository goalPlanRepository,
    LocalNotificationService? notificationService,
  }) : _goalPlanRepository = goalPlanRepository,
       _notificationService = notificationService;

  final GoalPlanRepository _goalPlanRepository;
  final LocalNotificationService? _notificationService;

  @override
  Future<GoalPlanCreationResult> call(
    CreateGoalCardsFromPlanParams params,
  ) async {
    final result = await _goalPlanRepository.createFromConfirmation(
      params.confirmation,
    );

    for (final card in result.cards) {
      await _notificationService?.scheduleCardNotification(
        notificationSnapshotFor(card),
      );
    }

    return result;
  }
}

class CreateGoalCardsFromPlanParams extends Equatable {
  const CreateGoalCardsFromPlanParams({required this.confirmation});

  final GoalPlanConfirmation confirmation;

  @override
  List<Object?> get props => [confirmation];
}
