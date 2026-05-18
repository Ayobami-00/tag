import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tag/features/cards/domain/entities/card_entities.dart';
import 'package:tag/features/cards/domain/entities/feedback_entities.dart';
import 'package:tag/features/cards/domain/entities/card_query.dart';
import 'package:tag/features/cards/domain/use_cases/cancel_card.dart';
import 'package:tag/features/cards/domain/use_cases/complete_card.dart';
import 'package:tag/features/cards/domain/use_cases/delete_card.dart';
import 'package:tag/features/cards/domain/use_cases/dismiss_suggestion.dart';
import 'package:tag/features/cards/domain/use_cases/snooze_card.dart';
import 'package:tag/features/cards/domain/use_cases/store_feedback_event.dart';
import 'package:tag/features/cards/domain/use_cases/update_preference_memory.dart';
import 'package:tag/features/chat/domain/entities/chat_entities.dart';
import 'package:tag/features/chat/domain/use_cases/start_edit_goal_chat.dart';
import 'package:tag/features/chat/domain/use_cases/start_plan_this_chat.dart';
import 'package:tag/features/today/domain/use_cases/watch_today_cards.dart';

part 'today_state.dart';

class TodayCubit extends Cubit<TodayState> {
  TodayCubit({
    required WatchTodayCards watchTodayCards,
    required DeleteCard deleteCard,
    required CompleteCard completeCard,
    required SnoozeCard snoozeCard,
    required CancelCard cancelCard,
    required DismissSuggestion dismissSuggestion,
    required StoreFeedbackEvent storeFeedbackEvent,
    required UpdatePreferenceMemory updatePreferenceMemory,
    required StartPlanThisChat startPlanThisChat,
    required StartEditGoalChat startEditGoalChat,
    DateTime Function()? now,
  }) : _watchTodayCards = watchTodayCards,
       _deleteCard = deleteCard,
       _completeCard = completeCard,
       _snoozeCard = snoozeCard,
       _cancelCard = cancelCard,
       _dismissSuggestion = dismissSuggestion,
       _storeFeedbackEvent = storeFeedbackEvent,
       _updatePreferenceMemory = updatePreferenceMemory,
       _startPlanThisChat = startPlanThisChat,
       _startEditGoalChat = startEditGoalChat,
       _now = now ?? DateTime.now,
       super(const TodayState());

  final WatchTodayCards _watchTodayCards;
  final DeleteCard _deleteCard;
  final CompleteCard _completeCard;
  final SnoozeCard _snoozeCard;
  final CancelCard _cancelCard;
  final DismissSuggestion _dismissSuggestion;
  final StoreFeedbackEvent _storeFeedbackEvent;
  final UpdatePreferenceMemory _updatePreferenceMemory;
  final StartPlanThisChat _startPlanThisChat;
  final StartEditGoalChat _startEditGoalChat;
  final DateTime Function() _now;
  StreamSubscription<List<TagCardEntity>>? _cardsSubscription;

  void load() {
    _watchCurrentQuery();
  }

  void setViewMode(TodayViewMode viewMode) {
    if (state.viewMode == viewMode) {
      return;
    }

    emit(state.copyWith(viewMode: viewMode, status: TodayStatus.loading));
    _watchCurrentQuery();
  }

  void setFilter(TodayCardFilter filter) {
    if (state.filter == filter) {
      return;
    }

    emit(state.copyWith(filter: filter, status: TodayStatus.loading));
    _watchCurrentQuery();
  }

  void clearFilter() {
    setFilter(TodayCardFilter.all);
  }

  Future<bool> deleteCard(String cardId) async {
    try {
      await _deleteCard(DeleteCardParams(cardId: cardId));
      return true;
    } on Object {
      return false;
    }
  }

  Future<bool> completeCard(String cardId) async {
    try {
      await _completeCard(CompleteCardParams(cardId: cardId));
      return true;
    } on Object {
      return false;
    }
  }

  Future<bool> snoozeCard({
    required String cardId,
    required DateTime snoozedUntil,
    String? optionLabel,
  }) async {
    try {
      await _snoozeCard(
        SnoozeCardParams(
          cardId: cardId,
          snoozedUntil: snoozedUntil,
          optionLabel: optionLabel,
        ),
      );
      return true;
    } on Object {
      return false;
    }
  }

  Future<bool> cancelCard(String cardId) async {
    try {
      await _cancelCard(CancelCardParams(cardId: cardId));
      return true;
    } on Object {
      return false;
    }
  }

  Future<bool> dismissSuggestion(String cardId) async {
    try {
      await _dismissSuggestion(DismissSuggestionParams(cardId: cardId));
      return true;
    } on Object {
      return false;
    }
  }

  Future<bool> recordPlanThis(TagCardEntity card) async {
    try {
      final event = await _storeFeedbackEvent(
        StoreFeedbackEventParams(
          eventType: FeedbackEventType.planThis,
          cardId: card.id,
          spaceId: card.space.id,
          sourceId: card.sourceIds.isEmpty ? null : card.sourceIds.first,
          details: {
            'action': TagCardAction.planThis.storageValue,
            'card_type': card.cardType.storageValue,
            'status': card.status.storageValue,
            'source_ids': card.sourceIds,
          },
        ),
      );
      await _updatePreferenceMemory(
        UpdatePreferenceMemoryParams(event: event, card: card),
      );
      return true;
    } on Object {
      return false;
    }
  }

  Future<ChatSessionEntity?> startPlanningFromSuggestion(
    TagCardEntity card,
  ) async {
    try {
      await recordPlanThis(card);
      return _startPlanThisChat(StartPlanThisChatParams(suggestionCard: card));
    } on Object {
      return null;
    }
  }

  Future<ChatSessionEntity?> startEditingGoal(TagCardEntity card) async {
    try {
      return _startEditGoalChat(StartEditGoalChatParams(goalCard: card));
    } on Object {
      return null;
    }
  }

  Future<bool> recordViewSpace(TagCardEntity card) async {
    try {
      final event = await _storeFeedbackEvent(
        StoreFeedbackEventParams(
          eventType: FeedbackEventType.viewSpace,
          cardId: card.id,
          spaceId: card.space.id,
          sourceId: card.sourceIds.isEmpty ? null : card.sourceIds.first,
          details: {
            'action': TagCardAction.viewSpace.storageValue,
            'opened_from': 'today_card_action',
            'card_type': card.cardType.storageValue,
            'status': card.status.storageValue,
            'source_ids': card.sourceIds,
          },
        ),
      );
      await _updatePreferenceMemory(
        UpdatePreferenceMemoryParams(event: event, card: card),
      );
      return true;
    } on Object {
      return false;
    }
  }

  void _watchCurrentQuery() {
    _cardsSubscription?.cancel();
    emit(state.copyWith(status: TodayStatus.loading, errorMessage: ''));

    _cardsSubscription =
        _watchTodayCards(
          CardListQuery(
            viewMode: state.viewMode,
            filter: state.filter,
            now: _now(),
          ),
        ).listen(
          (cards) {
            if (isClosed) {
              return;
            }
            emit(state.copyWith(status: TodayStatus.ready, cards: cards));
          },
          onError: (Object error) {
            if (isClosed) {
              return;
            }
            emit(
              state.copyWith(
                status: TodayStatus.error,
                errorMessage: error.toString(),
              ),
            );
          },
        );
  }

  @override
  Future<void> close() async {
    await _cardsSubscription?.cancel();
    return super.close();
  }
}
