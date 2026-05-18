import 'package:equatable/equatable.dart';
import 'package:tag/core/use_cases/use_cases.dart';
import 'package:tag/features/cards/domain/entities/card_entities.dart';
import 'package:tag/features/cards/domain/entities/feedback_entities.dart';
import 'package:tag/features/cards/domain/repositories/feedback_repository.dart';

class StoreFeedbackEvent
    implements UseCase<FeedbackEventEntity, StoreFeedbackEventParams> {
  const StoreFeedbackEvent(this._repository);

  final FeedbackRepository _repository;

  @override
  Future<FeedbackEventEntity> call(StoreFeedbackEventParams params) {
    return _repository.storeEvent(
      eventType: params.eventType,
      cardId: params.cardId,
      spaceId: params.spaceId,
      sourceId: params.sourceId,
      goalPlanId: params.goalPlanId,
      details: params.details,
    );
  }
}

class StoreFeedbackEventParams extends Equatable {
  const StoreFeedbackEventParams({
    required this.eventType,
    required this.details,
    this.cardId,
    this.spaceId,
    this.sourceId,
    this.goalPlanId,
  });

  factory StoreFeedbackEventParams.fromCardAction(
    CardActionResult result, {
    Map<String, Object?> extraDetails = const {},
  }) {
    final previous = result.previousCard;
    final card = result.card;

    return StoreFeedbackEventParams(
      eventType: _eventTypeForAction(result.action),
      cardId: card.id,
      spaceId: card.space.id,
      sourceId: card.sourceIds.isEmpty ? null : card.sourceIds.first,
      details: {
        'action': result.action.storageValue,
        'card_type': card.cardType.storageValue,
        'previous_status': previous.status.storageValue,
        'new_status': card.status.storageValue,
        'source_ids': card.sourceIds,
        'action_at': result.actionAt,
        ...extraDetails,
      },
    );
  }

  final FeedbackEventType eventType;
  final String? cardId;
  final String? spaceId;
  final String? sourceId;
  final String? goalPlanId;
  final Map<String, Object?> details;

  @override
  List<Object?> get props => [
    eventType,
    cardId,
    spaceId,
    sourceId,
    goalPlanId,
    details,
  ];
}

FeedbackEventType _eventTypeForAction(TagCardAction action) {
  return switch (action) {
    TagCardAction.complete => FeedbackEventType.complete,
    TagCardAction.snooze => FeedbackEventType.snooze,
    TagCardAction.cancel => FeedbackEventType.cancel,
    TagCardAction.dismiss => FeedbackEventType.dismiss,
    TagCardAction.planThis => FeedbackEventType.planThis,
    TagCardAction.archive => FeedbackEventType.archive,
    TagCardAction.edit => FeedbackEventType.editTitle,
    TagCardAction.viewSpace => FeedbackEventType.viewSpace,
  };
}
