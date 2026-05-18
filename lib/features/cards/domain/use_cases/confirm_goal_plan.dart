import 'package:equatable/equatable.dart';
import 'package:tag/features/cards/domain/entities/goal_plan_entities.dart';
import 'package:tag/features/cards/domain/use_cases/create_goal_cards_from_plan.dart';
import 'package:tag/features/chat/domain/entities/chat_entities.dart';
import 'package:tag/features/chat/domain/repositories/chat_repository.dart';

class ConfirmGoalPlan {
  const ConfirmGoalPlan({
    required ChatRepository chatRepository,
    required CreateGoalCardsFromPlan createGoalCardsFromPlan,
  }) : _chatRepository = chatRepository,
       _createGoalCardsFromPlan = createGoalCardsFromPlan;

  final ChatRepository _chatRepository;
  final CreateGoalCardsFromPlan _createGoalCardsFromPlan;

  Future<ConfirmGoalPlanResult> call(ConfirmGoalPlanParams params) async {
    final session = await _chatRepository.getSession(params.chatSessionId);
    if (session == null) {
      throw const GoalPlanException('Chat session was not found.');
    }

    final pendingConfirmationJson = session.pendingConfirmationJson;
    if (pendingConfirmationJson == null ||
        pendingConfirmationJson.trim().isEmpty) {
      throw const GoalPlanException(
        'There is no goal plan waiting for confirmation.',
      );
    }

    final decoded = decodeJsonObject(
      pendingConfirmationJson,
      'Pending goal plan confirmation',
    );
    final confirmation = GoalPlanConfirmation.fromJson(decoded);
    if (confirmation.chatSessionId != session.id) {
      throw const GoalPlanException(
        'Goal plan confirmation belongs to a different chat session.',
      );
    }

    final result = await _createGoalCardsFromPlan(
      CreateGoalCardsFromPlanParams(confirmation: confirmation),
    );
    final linkedSession = await _chatRepository.updateGoalPlanLink(
      sessionId: session.id,
      linkedGoalPlanId: result.goalPlan.id,
      pendingConfirmationJson: null,
    );

    return ConfirmGoalPlanResult(
      goalPlanResult: result,
      session: linkedSession,
    );
  }
}

class ConfirmGoalPlanParams extends Equatable {
  const ConfirmGoalPlanParams({required this.chatSessionId});

  final String chatSessionId;

  @override
  List<Object?> get props => [chatSessionId];
}

class ConfirmGoalPlanResult extends Equatable {
  const ConfirmGoalPlanResult({
    required this.goalPlanResult,
    required this.session,
  });

  final GoalPlanCreationResult goalPlanResult;
  final ChatSessionEntity session;

  @override
  List<Object?> get props => [goalPlanResult, session];
}
