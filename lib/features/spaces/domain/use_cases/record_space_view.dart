import 'package:equatable/equatable.dart';
import 'package:tag/core/use_cases/use_cases.dart';
import 'package:tag/features/cards/domain/entities/card_entities.dart';
import 'package:tag/features/cards/domain/entities/feedback_entities.dart';
import 'package:tag/features/cards/domain/use_cases/store_feedback_event.dart';

class RecordSpaceView
    implements UseCase<FeedbackEventEntity, RecordSpaceViewParams> {
  const RecordSpaceView(this._storeFeedbackEvent);

  final StoreFeedbackEvent _storeFeedbackEvent;

  @override
  Future<FeedbackEventEntity> call(RecordSpaceViewParams params) {
    return _storeFeedbackEvent(
      StoreFeedbackEventParams(
        eventType: FeedbackEventType.viewSpace,
        cardId: params.cardId,
        spaceId: params.spaceId,
        sourceId: params.sourceId,
        details: {
          'action': TagCardAction.viewSpace.storageValue,
          'opened_from': params.openedFrom,
          if (params.cardType != null) 'card_type': params.cardType,
          if (params.cardStatus != null) 'card_status': params.cardStatus,
          ...params.details,
        },
      ),
    );
  }
}

class RecordSpaceViewParams extends Equatable {
  const RecordSpaceViewParams({
    required this.spaceId,
    required this.openedFrom,
    this.cardId,
    this.sourceId,
    this.cardType,
    this.cardStatus,
    this.details = const {},
  });

  final String spaceId;
  final String openedFrom;
  final String? cardId;
  final String? sourceId;
  final String? cardType;
  final String? cardStatus;
  final Map<String, Object?> details;

  @override
  List<Object?> get props => [
    spaceId,
    openedFrom,
    cardId,
    sourceId,
    cardType,
    cardStatus,
    details,
  ];
}
