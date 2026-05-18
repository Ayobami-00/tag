import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tag/core/local_storage/database/tag_database.dart'
    as database_models;
import 'package:tag/core/notifications/local_notification_permission_service.dart';
import 'package:tag/core/notifications/local_notification_service.dart';
import 'package:tag/core/notifications/notification_policy.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:uuid/uuid.dart';

class LocalNotificationServiceImpl implements LocalNotificationService {
  LocalNotificationServiceImpl({
    required database_models.TagDatabase database,
    required NotificationPolicy policy,
    NotificationPlatformScheduler? scheduler,
    DateTime Function()? now,
    Uuid? uuid,
  }) : _database = database,
       _policy = policy,
       _scheduler = scheduler ?? FlutterLocalNotificationScheduler(),
       _now = now ?? DateTime.now,
       _uuid = uuid ?? const Uuid();

  static const schedulingTimezone = 'UTC';

  final database_models.TagDatabase _database;
  final NotificationPolicy _policy;
  final NotificationPlatformScheduler _scheduler;
  final DateTime Function() _now;
  final Uuid _uuid;

  NotificationActionHandler? _onAction;
  bool _initialized = false;

  @override
  Future<void> initialize({NotificationActionHandler? onAction}) async {
    if (onAction != null) {
      _onAction = onAction;
    }

    if (_initialized) {
      return;
    }

    await _scheduler.initialize(onAction: handleActionPayload);
    _initialized = true;
  }

  @override
  Future<NotificationPermissionState> requestPermission() async {
    await initialize();

    return _scheduler.requestPermission();
  }

  @override
  Future<NotificationRequestEntity?> scheduleCardNotification(
    LocalNotificationCardSnapshot card,
  ) async {
    await initialize();

    if (!_policy.isEligible(card)) {
      await cancelCardNotifications(card.id);
      return null;
    }

    final notificationTime = card.notificationTime;
    if (notificationTime == null) {
      await cancelCardNotifications(card.id);
      return null;
    }

    final timestamp = _timestamp();
    if (card.status == 'snoozed' &&
        notificationTime <=
            timestamp + const Duration(seconds: 5).inMilliseconds) {
      await cancelCardNotifications(card.id);
      return null;
    }

    final scheduledFor = _safeScheduledFor(notificationTime, timestamp);
    final actions = _policy.actionIdsFor(card);
    final title = _titleFor(card);
    final body = _bodyFor(card);
    final actionsJson = jsonEncode(actions);
    final matchingRequest = await _matchingActiveRequest(
      cardId: card.id,
      scheduledFor: scheduledFor,
      title: title,
      actionsJson: actionsJson,
    );
    if (matchingRequest != null) {
      return matchingRequest;
    }

    await cancelCardNotifications(card.id);

    final requestId = 'notification_${_uuid.v4()}';
    final platformNotificationId = await _nextPlatformNotificationId();

    await _database
        .into(_database.notificationRequests)
        .insert(
          database_models.NotificationRequestsCompanion.insert(
            id: requestId,
            cardId: card.id,
            platformNotificationId: platformNotificationId,
            scheduledFor: scheduledFor,
            timezone: schedulingTimezone,
            status: 'pending',
            title: title,
            body: body,
            actionsJson: Value(actionsJson),
            createdAt: timestamp,
            updatedAt: timestamp,
          ),
        );

    try {
      await _scheduler.schedule(
        NotificationPlatformRequest(
          platformNotificationId: platformNotificationId,
          categoryId: _policy.categoryIdFor(card),
          scheduledFor: DateTime.fromMillisecondsSinceEpoch(
            scheduledFor,
            isUtc: true,
          ),
          title: title,
          body: body,
          payload: jsonEncode({
            'card_id': card.id,
            'notification_request_id': requestId,
          }),
        ),
      );

      await _updateRequestStatus(
        requestId: requestId,
        status: 'scheduled',
        timestamp: _timestamp(),
      );
    } on Object catch (error) {
      await _updateRequestStatus(
        requestId: requestId,
        status: 'failed',
        timestamp: _timestamp(),
        failureReason: error.toString(),
      );
    }

    final request = await _requestById(requestId);
    if (request == null) {
      throw StateError('Notification request was not readable after insert.');
    }

    return request;
  }

  @override
  Future<void> cancelCardNotifications(String cardId) async {
    await initialize();

    final scheduledRows =
        await (_database.select(_database.notificationRequests)..where(
              (request) =>
                  request.cardId.equals(cardId) &
                  request.status.isIn(const ['pending', 'scheduled']),
            ))
            .get();

    final timestamp = _timestamp();
    for (final row in scheduledRows) {
      try {
        await _scheduler.cancel(row.platformNotificationId);
        await _updateRequestStatus(
          requestId: row.id,
          status: 'cancelled',
          timestamp: timestamp,
          cancelledAt: timestamp,
        );
      } on Object catch (error) {
        await _updateRequestStatus(
          requestId: row.id,
          status: 'failed',
          timestamp: timestamp,
          failureReason: error.toString(),
        );
      }
    }
  }

  @override
  Future<List<NotificationRequestEntity>> requestsForCard(String cardId) async {
    final rows =
        await (_database.select(_database.notificationRequests)
              ..where((request) => request.cardId.equals(cardId))
              ..orderBy([(request) => OrderingTerm.desc(request.scheduledFor)]))
            .get();

    return rows.map(_mapRequest).toList(growable: false);
  }

  @override
  Future<void> showSourceProcessingFailureNotification(
    SourceProcessingFailureNotification notification,
  ) async {
    await initialize();

    final sourceId = notification.sourceId.trim();
    if (sourceId.isEmpty) {
      return;
    }

    final sourceSummary = notification.sourceSummary?.trim();
    try {
      await _scheduler.showNow(
        NotificationPlatformRequest(
          platformNotificationId: _immediatePlatformNotificationId(sourceId),
          categoryId: NotificationCategoryIds.sourceFailure,
          scheduledFor: _now().toUtc(),
          title: _trimmedOrFallback(
            notification.title,
            'Image was saved, but no card was made',
          ),
          body: _trimmedOrFallback(
            notification.body,
            'Re-add the image with a short note about what you want Tag to do.',
          ),
          payload: jsonEncode({
            'event': 'source_processing_failure',
            'source_id': sourceId,
            if (sourceSummary != null && sourceSummary.isNotEmpty)
              'source_summary': sourceSummary,
          }),
        ),
      );
    } on Object {
      // Notification delivery should not change local source processing state.
    }
  }

  @override
  Future<void> handleActionPayload(NotificationActionPayload payload) async {
    final timestamp = _timestamp();
    final requestId = payload.notificationRequestId;
    if (requestId != null && requestId.isNotEmpty) {
      await _updateRequestStatus(
        requestId: requestId,
        status: 'delivered',
        timestamp: timestamp,
      );
    }

    await _onAction?.call(payload);
  }

  Future<NotificationRequestEntity?> _requestById(String requestId) async {
    final row = await (_database.select(
      _database.notificationRequests,
    )..where((request) => request.id.equals(requestId))).getSingleOrNull();

    return row == null ? null : _mapRequest(row);
  }

  Future<NotificationRequestEntity?> _matchingActiveRequest({
    required String cardId,
    required int scheduledFor,
    required String title,
    required String actionsJson,
  }) async {
    final rows =
        await (_database.select(_database.notificationRequests)..where(
              (request) =>
                  request.cardId.equals(cardId) &
                  request.status.isIn(const ['pending', 'scheduled']),
            ))
            .get();
    if (rows.length != 1) {
      return null;
    }

    final row = rows.single;
    if (row.scheduledFor != scheduledFor ||
        row.title != title ||
        row.actionsJson != actionsJson) {
      return null;
    }

    return _mapRequest(row);
  }

  Future<void> _updateRequestStatus({
    required String requestId,
    required String status,
    required int timestamp,
    String? failureReason,
    int? cancelledAt,
  }) {
    return (_database.update(
      _database.notificationRequests,
    )..where((request) => request.id.equals(requestId))).write(
      database_models.NotificationRequestsCompanion(
        status: Value(status),
        failureReason: Value(failureReason),
        updatedAt: Value(timestamp),
        cancelledAt: cancelledAt == null
            ? const Value.absent()
            : Value(cancelledAt),
      ),
    );
  }

  Future<int> _nextPlatformNotificationId() async {
    final rows = await _database.select(_database.notificationRequests).get();
    if (rows.isEmpty) {
      return 1000;
    }

    final maxExisting = rows
        .map((row) => row.platformNotificationId)
        .reduce(max);

    return maxExisting >= 2147483000 ? 1000 : maxExisting + 1;
  }

  int _immediatePlatformNotificationId(String sourceId) {
    final sourceHash = sourceId.codeUnits.fold<int>(
      17,
      (value, unit) => (value * 37 + unit) & 0x3fffffff,
    );
    final timeHash = _timestamp() & 0x3fffffff;

    return 1000000000 + ((sourceHash ^ timeHash) % 1000000000);
  }

  int _safeScheduledFor(int requestedUtcMs, int nowUtcMs) {
    if (requestedUtcMs > nowUtcMs + const Duration(seconds: 5).inMilliseconds) {
      return requestedUtcMs;
    }

    return nowUtcMs + const Duration(seconds: 5).inMilliseconds;
  }

  NotificationRequestEntity _mapRequest(
    database_models.NotificationRequest row,
  ) {
    return NotificationRequestEntity(
      id: row.id,
      cardId: row.cardId,
      platformNotificationId: row.platformNotificationId,
      scheduledFor: row.scheduledFor,
      timezone: row.timezone,
      status: row.status,
      title: row.title,
      body: row.body,
      actions: _actionsFromJson(row.actionsJson),
      failureReason: row.failureReason,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      cancelledAt: row.cancelledAt,
    );
  }

  List<String> _actionsFromJson(String actionsJson) {
    try {
      final decoded = jsonDecode(actionsJson);
      if (decoded is List) {
        return decoded.whereType<String>().toList(growable: false);
      }
    } on FormatException {
      return const [];
    }

    return const [];
  }

  String _titleFor(LocalNotificationCardSnapshot card) {
    final prefix = card.cardType == 'goal' ? 'Goal' : 'Urgent';
    final title = card.title.trim();

    return title.isEmpty ? '$prefix card needs attention' : title;
  }

  String _bodyFor(LocalNotificationCardSnapshot card) {
    final spaceName = card.spaceName.trim();
    final sourceSummary = card.sourceSummary.trim();
    final reason = card.reason.trim();

    if (spaceName.isNotEmpty && sourceSummary.isNotEmpty) {
      return '${card.cardType == 'goal' ? 'Goal' : 'Urgent'} · $spaceName. Source: $sourceSummary.';
    }

    if (reason.isNotEmpty) {
      return reason;
    }

    return 'Open Tag to act from the saved source evidence.';
  }

  String _trimmedOrFallback(String value, String fallback) {
    final trimmed = value.trim();

    return trimmed.isEmpty ? fallback : trimmed;
  }

  int _timestamp() => _now().toUtc().millisecondsSinceEpoch;
}

class FlutterLocalNotificationScheduler
    implements NotificationPlatformScheduler {
  FlutterLocalNotificationScheduler({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  @override
  Future<void> initialize({required NotificationActionHandler onAction}) async {
    if (_initialized) {
      return;
    }

    tz_data.initializeTimeZones();
    tz.setLocalLocation(
      tz.getLocation(LocalNotificationServiceImpl.schedulingTimezone),
    );

    if (!Platform.isIOS) {
      _initialized = true;
      return;
    }

    final initializationSettings = InitializationSettings(
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        notificationCategories: [
          DarwinNotificationCategory(
            NotificationCategoryIds.urgent,
            actions: [
              DarwinNotificationAction.plain(
                'complete',
                'Complete',
                options: {DarwinNotificationActionOption.foreground},
              ),
              DarwinNotificationAction.plain(
                'snooze',
                'Snooze',
                options: {DarwinNotificationActionOption.foreground},
              ),
              DarwinNotificationAction.plain(
                'cancel',
                'Cancel',
                options: {
                  DarwinNotificationActionOption.destructive,
                  DarwinNotificationActionOption.foreground,
                },
              ),
            ],
            options: {DarwinNotificationCategoryOption.hiddenPreviewShowTitle},
          ),
          DarwinNotificationCategory(
            NotificationCategoryIds.goal,
            actions: [
              DarwinNotificationAction.plain(
                'complete',
                'Complete',
                options: {DarwinNotificationActionOption.foreground},
              ),
              DarwinNotificationAction.plain(
                'snooze',
                'Snooze',
                options: {DarwinNotificationActionOption.foreground},
              ),
              DarwinNotificationAction.plain(
                'edit',
                'Edit',
                options: {DarwinNotificationActionOption.foreground},
              ),
            ],
            options: {DarwinNotificationCategoryOption.hiddenPreviewShowTitle},
          ),
          DarwinNotificationCategory(
            NotificationCategoryIds.sourceFailure,
            options: {DarwinNotificationCategoryOption.hiddenPreviewShowTitle},
          ),
        ],
      ),
    );

    await _plugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (response) async {
        final payload = _parseResponse(response);
        if (payload != null) {
          await onAction(payload);
        }
      },
      onDidReceiveBackgroundNotificationResponse: tagNotificationTapBackground,
    );

    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    final launchResponse = launchDetails?.notificationResponse;
    if (launchDetails?.didNotificationLaunchApp == true &&
        launchResponse != null) {
      final payload = _parseResponse(launchResponse);
      if (payload != null) {
        await onAction(payload);
      }
    }

    _initialized = true;
  }

  @override
  Future<NotificationPermissionState> requestPermission() async {
    if (!Platform.isIOS) {
      return NotificationPermissionState.denied;
    }

    await initialize(onAction: (_) async {});

    final result = await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    return result == true
        ? NotificationPermissionState.granted
        : NotificationPermissionState.denied;
  }

  @override
  Future<void> schedule(NotificationPlatformRequest request) {
    if (!Platform.isIOS) {
      return Future<void>.value();
    }

    return _plugin.zonedSchedule(
      id: request.platformNotificationId,
      title: request.title,
      body: request.body,
      scheduledDate: tz.TZDateTime.from(request.scheduledFor, tz.UTC),
      notificationDetails: NotificationDetails(
        iOS: DarwinNotificationDetails(
          categoryIdentifier: request.categoryId,
          threadIdentifier: 'tag_cards',
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: request.payload,
    );
  }

  @override
  Future<void> showNow(NotificationPlatformRequest request) {
    if (!Platform.isIOS) {
      return Future<void>.value();
    }

    return _plugin.show(
      id: request.platformNotificationId,
      title: request.title,
      body: request.body,
      notificationDetails: NotificationDetails(
        iOS: DarwinNotificationDetails(
          categoryIdentifier: request.categoryId,
          threadIdentifier: 'tag_source_processing',
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: request.payload,
    );
  }

  @override
  Future<void> cancel(int platformNotificationId) {
    if (!Platform.isIOS) {
      return Future<void>.value();
    }

    return _plugin.cancel(id: platformNotificationId);
  }

  static NotificationActionPayload? _parseResponse(
    NotificationResponse response,
  ) {
    final payload = response.payload;
    if (payload == null || payload.trim().isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(payload);
      if (decoded is! Map) {
        return null;
      }

      final cardId = decoded['card_id'];
      if (cardId is! String || cardId.trim().isEmpty) {
        return null;
      }
      final requestId = decoded['notification_request_id'];

      return NotificationActionPayload(
        cardId: cardId,
        actionId: _normalizedActionId(response.actionId),
        notificationRequestId: requestId is String ? requestId : null,
        platformNotificationId: response.id,
      );
    } on FormatException {
      return null;
    }
  }

  static String _normalizedActionId(String? actionId) {
    final value = actionId?.trim();
    if (value == null || value.isEmpty) {
      return 'open';
    }

    return value;
  }
}

@pragma('vm:entry-point')
void tagNotificationTapBackground(NotificationResponse response) {}
