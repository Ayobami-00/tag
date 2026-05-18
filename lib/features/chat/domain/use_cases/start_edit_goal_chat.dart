import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:tag/core/use_cases/use_cases.dart';
import 'package:tag/features/cards/domain/entities/card_entities.dart';
import 'package:tag/features/cards/domain/entities/goal_plan_entities.dart';
import 'package:tag/features/cards/domain/repositories/goal_plan_repository.dart';
import 'package:tag/features/chat/domain/entities/chat_entities.dart';
import 'package:tag/features/chat/domain/repositories/chat_repository.dart';

class StartEditGoalChatParams extends Equatable {
  const StartEditGoalChatParams({required this.goalCard});

  final TagCardEntity goalCard;

  @override
  List<Object?> get props => [goalCard];
}

class StartEditGoalChat
    with UseCases<ChatSessionEntity, StartEditGoalChatParams> {
  const StartEditGoalChat({
    required ChatRepository chatRepository,
    required GoalPlanRepository goalPlanRepository,
  }) : _chatRepository = chatRepository,
       _goalPlanRepository = goalPlanRepository;

  final ChatRepository _chatRepository;
  final GoalPlanRepository _goalPlanRepository;

  @override
  Future<ChatSessionEntity> call(StartEditGoalChatParams params) async {
    final card = params.goalCard;
    if (card.cardType != TagCardType.goal) {
      throw const GoalPlanException('Only Goal Cards can edit a goal plan.');
    }

    final goalPlanId = card.parentGoalPlanId;
    if (goalPlanId == null || goalPlanId.trim().isEmpty) {
      throw const GoalPlanException(
        'This Goal Card is not linked to a parent plan.',
      );
    }

    final goalPlan = await _goalPlanRepository.getGoalPlanById(goalPlanId);
    if (goalPlan == null) {
      throw const GoalPlanException('GoalPlan was not found.');
    }

    final session = await _chatRepository.startEditGoalSession(
      title: 'Editing: ${goalPlan.name}',
      linkedCardId: card.id,
      linkedSpaceId: card.space.id,
      linkedGoalPlanId: goalPlan.id,
    );

    await _chatRepository.addMessage(
      ChatMessageDraft(
        chatSessionId: session.id,
        role: ChatMessageRole.assistant,
        content: 'What would you like to change?',
        contentJson: jsonEncode({
          'kind': 'goal_edit_prompt',
          'goal_plan_id': goalPlan.id,
          'goal_name': goalPlan.name,
        }),
        sourceIds: card.sourceIds,
        cardIds: [card.id],
      ),
    );

    return session;
  }
}
