import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:tag/core/use_cases/use_cases.dart';
import 'package:tag/features/cards/domain/entities/card_entities.dart';
import 'package:tag/features/chat/domain/entities/chat_entities.dart';
import 'package:tag/features/chat/domain/entities/guided_planning_entities.dart';
import 'package:tag/features/chat/domain/repositories/chat_repository.dart';

class StartPlanThisChatParams extends Equatable {
  const StartPlanThisChatParams({required this.suggestionCard});

  final TagCardEntity suggestionCard;

  @override
  List<Object?> get props => [suggestionCard];
}

class StartPlanThisChat
    with UseCases<ChatSessionEntity, StartPlanThisChatParams> {
  const StartPlanThisChat(this._chatRepository);

  final ChatRepository _chatRepository;

  @override
  Future<ChatSessionEntity> call(StartPlanThisChatParams params) async {
    final card = params.suggestionCard;
    if (card.cardType != TagCardType.suggestion) {
      throw const StartPlanThisChatException(
        'Only Suggestion Cards can start guided planning.',
      );
    }
    if (card.status != TagCardStatus.active) {
      throw const StartPlanThisChatException(
        'Only active suggestions can be planned.',
      );
    }

    final goalName = _goalNameFrom(card.title);
    final session = await _chatRepository.startPlanThisSession(
      title: 'Plan this: $goalName',
      linkedCardId: card.id,
      linkedSpaceId: card.space.id,
    );

    await _chatRepository.addMessage(
      ChatMessageDraft(
        chatSessionId: session.id,
        role: ChatMessageRole.assistant,
        content:
            'I found ${_sourcePhrase(card)} and it looks like you may want to '
            '${_goalVerb(goalName)}. How would you like to approach this?',
        contentJson: jsonEncode({
          'kind': 'plan_style_choices',
          'suggestion_card_id': card.id,
          'goal_name': goalName,
          'choices': PlanStyleChoice.values
              .map(
                (choice) => {
                  'value': choice.storageValue,
                  'label': choice.label,
                },
              )
              .toList(growable: false),
        }),
        sourceIds: card.sourceIds,
        cardIds: [card.id],
      ),
    );

    return session;
  }

  String _goalNameFrom(String title) {
    final trimmed = title.trim();
    const prefix = 'Goal detected:';
    if (trimmed.toLowerCase().startsWith(prefix.toLowerCase())) {
      final goal = trimmed.substring(prefix.length).trim();
      if (goal.isNotEmpty) {
        return goal;
      }
    }

    return trimmed.isEmpty ? 'this goal' : trimmed;
  }

  String _sourcePhrase(TagCardEntity card) {
    final summary = card.sourceSummary.trim();
    if (summary.isNotEmpty) {
      return summary;
    }

    final sourceCount = card.sourceIds.length;
    if (sourceCount == 1) {
      return 'one saved source';
    }
    if (sourceCount > 1) {
      return '$sourceCount saved sources';
    }

    return 'this suggestion';
  }

  String _goalVerb(String goalName) {
    final trimmed = goalName.trim();
    if (trimmed.isEmpty) {
      return 'plan this';
    }

    return trimmed[0].toLowerCase() + trimmed.substring(1);
  }
}

class StartPlanThisChatException implements Exception {
  const StartPlanThisChatException(this.message);

  final String message;

  @override
  String toString() => message;
}
