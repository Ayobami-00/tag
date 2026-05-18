import 'package:tag/core/notifications/local_notification_service.dart';

class NotificationPolicy {
  const NotificationPolicy();

  bool isEligible(LocalNotificationCardSnapshot card) {
    if (!card.notificationEnabled) {
      return false;
    }

    if (!_isNotifiableType(card.cardType)) {
      return false;
    }

    if (_isTerminalStatus(card.status)) {
      return false;
    }

    if (card.status == 'active') {
      return card.nextActiveDeadline != null;
    }

    if (card.status == 'snoozed') {
      return card.snoozedUntil != null;
    }

    return false;
  }

  List<String> actionIdsFor(LocalNotificationCardSnapshot card) {
    return switch (card.cardType) {
      'urgent' => const ['complete', 'snooze', 'cancel'],
      'goal' => const ['complete', 'snooze', 'edit'],
      _ => const [],
    };
  }

  String categoryIdFor(LocalNotificationCardSnapshot card) {
    return switch (card.cardType) {
      'urgent' => NotificationCategoryIds.urgent,
      'goal' => NotificationCategoryIds.goal,
      _ => NotificationCategoryIds.passive,
    };
  }

  bool _isNotifiableType(String cardType) {
    return cardType == 'urgent' || cardType == 'goal';
  }

  bool _isTerminalStatus(String status) {
    return status == 'completed' ||
        status == 'cancelled' ||
        status == 'dismissed' ||
        status == 'archived';
  }
}

abstract final class NotificationCategoryIds {
  static const urgent = 'tag_urgent_card';
  static const goal = 'tag_goal_card';
  static const passive = 'tag_passive_card';
  static const sourceFailure = 'tag_source_processing_failure';
}
