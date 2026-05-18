import 'package:tag/core/notifications/local_notification_service.dart';
import 'package:tag/features/cards/domain/entities/card_entities.dart';

LocalNotificationCardSnapshot notificationSnapshotFor(TagCardEntity card) {
  return LocalNotificationCardSnapshot(
    id: card.id,
    cardType: card.cardType.storageValue,
    status: card.status.storageValue,
    title: card.title,
    reason: card.reason,
    spaceName: card.space.name,
    sourceSummary: card.sourceSummary,
    notificationEnabled: card.notificationEnabled,
    nextActiveDeadline: card.nextActiveDeadline,
    snoozedUntil: card.snoozedUntil,
  );
}
