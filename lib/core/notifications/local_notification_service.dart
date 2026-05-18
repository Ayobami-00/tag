import 'package:equatable/equatable.dart';
import 'package:tag/core/notifications/local_notification_permission_service.dart';

typedef NotificationActionHandler =
    Future<void> Function(NotificationActionPayload payload);

abstract interface class LocalNotificationService
    implements LocalNotificationPermissionService {
  Future<void> initialize({NotificationActionHandler? onAction});

  Future<NotificationRequestEntity?> scheduleCardNotification(
    LocalNotificationCardSnapshot card,
  );

  Future<void> cancelCardNotifications(String cardId);

  Future<List<NotificationRequestEntity>> requestsForCard(String cardId);

  Future<void> showSourceProcessingFailureNotification(
    SourceProcessingFailureNotification notification,
  );

  Future<void> handleActionPayload(NotificationActionPayload payload);
}

class SourceProcessingFailureNotification extends Equatable {
  const SourceProcessingFailureNotification({
    required this.sourceId,
    required this.title,
    required this.body,
    this.sourceSummary,
  });

  final String sourceId;
  final String title;
  final String body;
  final String? sourceSummary;

  @override
  List<Object?> get props => [sourceId, title, body, sourceSummary];
}

class LocalNotificationCardSnapshot extends Equatable {
  const LocalNotificationCardSnapshot({
    required this.id,
    required this.cardType,
    required this.status,
    required this.title,
    required this.reason,
    required this.spaceName,
    required this.sourceSummary,
    required this.notificationEnabled,
    this.nextActiveDeadline,
    this.snoozedUntil,
  });

  final String id;
  final String cardType;
  final String status;
  final String title;
  final String reason;
  final String spaceName;
  final String sourceSummary;
  final bool notificationEnabled;
  final int? nextActiveDeadline;
  final int? snoozedUntil;

  int? get notificationTime {
    if (status == 'snoozed') {
      return snoozedUntil;
    }

    return nextActiveDeadline;
  }

  @override
  List<Object?> get props => [
    id,
    cardType,
    status,
    title,
    reason,
    spaceName,
    sourceSummary,
    notificationEnabled,
    nextActiveDeadline,
    snoozedUntil,
  ];
}

class NotificationRequestEntity extends Equatable {
  const NotificationRequestEntity({
    required this.id,
    required this.cardId,
    required this.platformNotificationId,
    required this.scheduledFor,
    required this.timezone,
    required this.status,
    required this.title,
    required this.body,
    required this.actions,
    required this.createdAt,
    required this.updatedAt,
    this.failureReason,
    this.cancelledAt,
  });

  final String id;
  final String cardId;
  final int platformNotificationId;
  final int scheduledFor;
  final String timezone;
  final String status;
  final String title;
  final String body;
  final List<String> actions;
  final String? failureReason;
  final int createdAt;
  final int updatedAt;
  final int? cancelledAt;

  bool get isScheduled => status == 'scheduled';

  @override
  List<Object?> get props => [
    id,
    cardId,
    platformNotificationId,
    scheduledFor,
    timezone,
    status,
    title,
    body,
    actions,
    failureReason,
    createdAt,
    updatedAt,
    cancelledAt,
  ];
}

class NotificationActionPayload extends Equatable {
  const NotificationActionPayload({
    required this.cardId,
    required this.actionId,
    this.notificationRequestId,
    this.platformNotificationId,
  });

  final String cardId;
  final String actionId;
  final String? notificationRequestId;
  final int? platformNotificationId;

  @override
  List<Object?> get props => [
    cardId,
    actionId,
    notificationRequestId,
    platformNotificationId,
  ];
}

class NotificationPlatformRequest extends Equatable {
  const NotificationPlatformRequest({
    required this.platformNotificationId,
    required this.categoryId,
    required this.scheduledFor,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int platformNotificationId;
  final String categoryId;
  final DateTime scheduledFor;
  final String title;
  final String body;
  final String payload;

  @override
  List<Object?> get props => [
    platformNotificationId,
    categoryId,
    scheduledFor,
    title,
    body,
    payload,
  ];
}

abstract interface class NotificationPlatformScheduler {
  Future<void> initialize({required NotificationActionHandler onAction});

  Future<NotificationPermissionState> requestPermission();

  Future<void> schedule(NotificationPlatformRequest request);

  Future<void> showNow(NotificationPlatformRequest request);

  Future<void> cancel(int platformNotificationId);
}
