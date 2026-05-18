import 'package:equatable/equatable.dart';
import 'package:tag/core/use_cases/use_cases.dart';
import 'package:tag/features/cards/domain/entities/card_entities.dart';
import 'package:tag/features/cards/domain/entities/feedback_entities.dart';
import 'package:tag/features/cards/domain/repositories/preference_memory_repository.dart';

class UpdatePreferenceMemory
    implements UseCase<PreferenceMemoryEntity?, UpdatePreferenceMemoryParams> {
  const UpdatePreferenceMemory(this._repository);

  final PreferenceMemoryRepository _repository;

  @override
  Future<PreferenceMemoryEntity?> call(UpdatePreferenceMemoryParams params) {
    final event = params.event;
    final card = params.card;

    return switch (event.eventType) {
      FeedbackEventType.snooze => _storeDefaultSnooze(event, card),
      FeedbackEventType.dismiss => _storeDismissedSuggestion(event, card),
      FeedbackEventType.complete => _storeCompletedCard(event, card),
      FeedbackEventType.cancel => _storeCancelledCard(event, card),
      FeedbackEventType.planThis => _storePlannedSuggestion(event, card),
      _ => Future<PreferenceMemoryEntity?>.value(),
    };
  }

  Future<PreferenceMemoryEntity?> _storeDefaultSnooze(
    FeedbackEventEntity event,
    TagCardEntity? card,
  ) {
    final minutes = event.details['snooze_minutes'];
    if (minutes is! int) {
      return Future<PreferenceMemoryEntity?>.value();
    }

    return _repository.upsertPreference(
      category: 'reminders',
      key: 'default_snooze_minutes',
      value: {
        'minutes': minutes,
        'last_card_type': card?.cardType.storageValue,
      },
      confidence: 0.45,
      evidenceEventId: event.id,
    );
  }

  Future<PreferenceMemoryEntity?> _storeDismissedSuggestion(
    FeedbackEventEntity event,
    TagCardEntity? card,
  ) {
    if (card?.cardType != TagCardType.suggestion) {
      return Future<PreferenceMemoryEntity?>.value();
    }

    return _repository.upsertPreference(
      category: 'learning',
      key: 'last_dismissed_suggestion_space',
      value: {
        'space_id': card!.space.id,
        'space_name': card.space.name,
        'card_title': card.title,
      },
      confidence: 0.35,
      evidenceEventId: event.id,
    );
  }

  Future<PreferenceMemoryEntity?> _storeCompletedCard(
    FeedbackEventEntity event,
    TagCardEntity? card,
  ) {
    if (card == null) {
      return Future<PreferenceMemoryEntity?>.value();
    }

    return _repository.upsertPreference(
      category: 'learning',
      key: 'last_completed_card_type',
      value: {
        'card_type': card.cardType.storageValue,
        'space_id': card.space.id,
        'space_name': card.space.name,
      },
      confidence: 0.30,
      evidenceEventId: event.id,
    );
  }

  Future<PreferenceMemoryEntity?> _storeCancelledCard(
    FeedbackEventEntity event,
    TagCardEntity? card,
  ) {
    if (card == null) {
      return Future<PreferenceMemoryEntity?>.value();
    }

    return _repository.upsertPreference(
      category: 'learning',
      key: 'last_cancelled_card_type',
      value: {
        'card_type': card.cardType.storageValue,
        'space_id': card.space.id,
        'space_name': card.space.name,
      },
      confidence: 0.30,
      evidenceEventId: event.id,
    );
  }

  Future<PreferenceMemoryEntity?> _storePlannedSuggestion(
    FeedbackEventEntity event,
    TagCardEntity? card,
  ) {
    if (card?.cardType != TagCardType.suggestion) {
      return Future<PreferenceMemoryEntity?>.value();
    }

    return _repository.upsertPreference(
      category: 'learning',
      key: 'last_planned_suggestion_space',
      value: {
        'space_id': card!.space.id,
        'space_name': card.space.name,
        'card_title': card.title,
      },
      confidence: 0.40,
      evidenceEventId: event.id,
    );
  }
}

class UpdatePreferenceMemoryParams extends Equatable {
  const UpdatePreferenceMemoryParams({
    required this.event,
    this.card,
    this.previousCard,
  });

  final FeedbackEventEntity event;
  final TagCardEntity? card;
  final TagCardEntity? previousCard;

  @override
  List<Object?> get props => [event, card, previousCard];
}
