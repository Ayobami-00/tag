import 'package:tag/features/cards/domain/entities/feedback_entities.dart';

abstract interface class FeedbackRepository {
  Future<FeedbackEventEntity> storeEvent({
    required FeedbackEventType eventType,
    required Map<String, Object?> details,
    String? cardId,
    String? spaceId,
    String? sourceId,
    String? goalPlanId,
  });

  Future<List<FeedbackEventEntity>> getEventsForCard(String cardId);

  Future<List<FeedbackEventEntity>> getRecentEvents({int limit = 50});
}
