import 'dart:io';

import 'package:flutter/services.dart';

enum NotificationPermissionState {
  unknown,
  granted,
  denied,
  provisional;

  static NotificationPermissionState fromStorageValue(String value) {
    return NotificationPermissionState.values.firstWhere(
      (state) => state.storageValue == value,
      orElse: () => NotificationPermissionState.unknown,
    );
  }

  String get storageValue => name;
}

abstract interface class LocalNotificationPermissionService {
  Future<NotificationPermissionState> requestPermission();
}

class MethodChannelLocalNotificationPermissionService
    implements LocalNotificationPermissionService {
  MethodChannelLocalNotificationPermissionService({
    MethodChannel channel = const MethodChannel(
      'tag/local_notification_permission',
    ),
  }) : _channel = channel;

  final MethodChannel _channel;

  @override
  Future<NotificationPermissionState> requestPermission() async {
    if (!Platform.isIOS) {
      return NotificationPermissionState.denied;
    }

    try {
      final value = await _channel.invokeMethod<String>('requestPermission');
      return NotificationPermissionState.fromStorageValue(value ?? 'unknown');
    } on PlatformException {
      return NotificationPermissionState.denied;
    } on MissingPluginException {
      return NotificationPermissionState.denied;
    }
  }
}
