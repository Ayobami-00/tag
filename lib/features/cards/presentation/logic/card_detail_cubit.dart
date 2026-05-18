import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tag/features/cards/domain/entities/card_entities.dart';
import 'package:tag/features/cards/domain/entities/feedback_entities.dart';
import 'package:tag/features/cards/domain/use_cases/archive_card.dart';
import 'package:tag/features/cards/domain/use_cases/cancel_card.dart';
import 'package:tag/features/cards/domain/use_cases/complete_card.dart';
import 'package:tag/features/cards/domain/use_cases/dismiss_suggestion.dart';
import 'package:tag/features/cards/domain/use_cases/get_card_by_id.dart';
import 'package:tag/features/cards/domain/use_cases/open_source_for_card.dart';
import 'package:tag/features/cards/domain/use_cases/snooze_card.dart';
import 'package:tag/features/cards/domain/use_cases/store_feedback_event.dart';
import 'package:tag/features/cards/domain/use_cases/update_preference_memory.dart';
import 'package:tag/features/chat/domain/entities/chat_entities.dart';
import 'package:tag/features/chat/domain/use_cases/start_edit_goal_chat.dart';

part 'card_detail_state.dart';

class CardDetailCubit extends Cubit<CardDetailState> {
  CardDetailCubit({
    required GetCardById getCardById,
    required CompleteCard completeCard,
    required SnoozeCard snoozeCard,
    required CancelCard cancelCard,
    required DismissSuggestion dismissSuggestion,
    required ArchiveCard archiveCard,
    required OpenSourceForCard openSourceForCard,
    required StoreFeedbackEvent storeFeedbackEvent,
    required UpdatePreferenceMemory updatePreferenceMemory,
    required StartEditGoalChat startEditGoalChat,
  }) : _getCardById = getCardById,
       _completeCard = completeCard,
       _snoozeCard = snoozeCard,
       _cancelCard = cancelCard,
       _dismissSuggestion = dismissSuggestion,
       _archiveCard = archiveCard,
       _openSourceForCard = openSourceForCard,
       _storeFeedbackEvent = storeFeedbackEvent,
       _updatePreferenceMemory = updatePreferenceMemory,
       _startEditGoalChat = startEditGoalChat,
       super(const CardDetailState());

  final GetCardById _getCardById;
  final CompleteCard _completeCard;
  final SnoozeCard _snoozeCard;
  final CancelCard _cancelCard;
  final DismissSuggestion _dismissSuggestion;
  final ArchiveCard _archiveCard;
  final OpenSourceForCard _openSourceForCard;
  final StoreFeedbackEvent _storeFeedbackEvent;
  final UpdatePreferenceMemory _updatePreferenceMemory;
  final StartEditGoalChat _startEditGoalChat;

  Future<void> load(String cardId) async {
    emit(state.copyWith(status: CardDetailStatus.loading, errorMessage: ''));
    try {
      final card = await _getCardById(GetCardByIdParams(cardId: cardId));
      if (card == null) {
        emit(
          state.copyWith(
            status: CardDetailStatus.notFound,
            errorMessage: 'This Tag Card is no longer available.',
          ),
        );
        return;
      }

      emit(state.copyWith(status: CardDetailStatus.ready, card: card));
    } on Object catch (error) {
      emit(
        state.copyWith(
          status: CardDetailStatus.error,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<bool> complete() {
    final card = state.card;
    if (card == null) {
      return Future<bool>.value(false);
    }

    return _runAction(
      () => _completeCard(CompleteCardParams(cardId: card.id)),
      successMessage: 'Completed "${card.title}".',
    );
  }

  Future<bool> snooze(DateTime snoozedUntil, {String? optionLabel}) {
    final card = state.card;
    if (card == null) {
      return Future<bool>.value(false);
    }

    return _runAction(
      () => _snoozeCard(
        SnoozeCardParams(
          cardId: card.id,
          snoozedUntil: snoozedUntil,
          optionLabel: optionLabel,
        ),
      ),
      successMessage: 'Snoozed "${card.title}".',
    );
  }

  Future<bool> cancel() {
    final card = state.card;
    if (card == null) {
      return Future<bool>.value(false);
    }

    return _runAction(
      () => _cancelCard(CancelCardParams(cardId: card.id)),
      successMessage: 'Cancelled "${card.title}".',
    );
  }

  Future<bool> dismiss() {
    final card = state.card;
    if (card == null) {
      return Future<bool>.value(false);
    }

    return _runAction(
      () => _dismissSuggestion(DismissSuggestionParams(cardId: card.id)),
      successMessage: 'Dismissed "${card.title}".',
    );
  }

  Future<bool> archive() {
    final card = state.card;
    if (card == null) {
      return Future<bool>.value(false);
    }

    return _runAction(
      () => _archiveCard(ArchiveCardParams(cardId: card.id)),
      successMessage: 'Archived "${card.title}".',
    );
  }

  Future<String?> openPrimarySource() async {
    final card = state.card;
    if (card == null) {
      return null;
    }

    try {
      final result = await _openSourceForCard(
        OpenSourceForCardParams(cardId: card.id),
      );
      return result.sourceId;
    } on Object catch (error) {
      emit(state.copyWith(errorMessage: error.toString(), actionMessage: ''));
      return null;
    }
  }

  Future<bool> recordPlanThis() async {
    final card = state.card;
    if (card == null) {
      return false;
    }

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
      emit(state.copyWith(actionMessage: 'Plan request noted locally.'));
      return true;
    } on Object catch (error) {
      emit(state.copyWith(errorMessage: error.toString()));
      return false;
    }
  }

  Future<bool> recordViewSpace() async {
    final card = state.card;
    if (card == null) {
      return false;
    }

    try {
      final event = await _storeFeedbackEvent(
        StoreFeedbackEventParams(
          eventType: FeedbackEventType.viewSpace,
          cardId: card.id,
          spaceId: card.space.id,
          sourceId: card.sourceIds.isEmpty ? null : card.sourceIds.first,
          details: {
            'action': TagCardAction.viewSpace.storageValue,
            'opened_from': 'card_detail_action',
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
    } on Object catch (error) {
      emit(state.copyWith(errorMessage: error.toString()));
      return false;
    }
  }

  Future<ChatSessionEntity?> startEditingGoal() async {
    final card = state.card;
    if (card == null) {
      return null;
    }

    try {
      return _startEditGoalChat(StartEditGoalChatParams(goalCard: card));
    } on Object catch (error) {
      emit(state.copyWith(errorMessage: error.toString()));
      return null;
    }
  }

  void clearActionMessage() {
    if (state.actionMessage.isEmpty && state.errorMessage.isEmpty) {
      return;
    }

    emit(state.copyWith(actionMessage: '', errorMessage: ''));
  }

  Future<bool> _runAction(
    Future<TagCardEntity> Function() action, {
    required String successMessage,
  }) async {
    try {
      final card = await action();
      emit(
        state.copyWith(
          status: CardDetailStatus.ready,
          card: card,
          actionMessage: successMessage,
          errorMessage: '',
        ),
      );
      return true;
    } on Object catch (error) {
      emit(state.copyWith(errorMessage: error.toString(), actionMessage: ''));
      return false;
    }
  }
}
