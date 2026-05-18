import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:tag/core/error/app_error.dart';

class DeviceStorageInfo extends Equatable {
  const DeviceStorageInfo({
    required this.availableBytes,
    required this.totalBytes,
  });

  const DeviceStorageInfo.unknown() : availableBytes = null, totalBytes = null;

  final int? availableBytes;
  final int? totalBytes;

  bool get isKnown => availableBytes != null && totalBytes != null;

  @override
  List<Object?> get props => [availableBytes, totalBytes];
}

abstract interface class DeviceStorageService {
  Future<DeviceStorageInfo> loadStorageInfo();
}

class MethodChannelDeviceStorageService implements DeviceStorageService {
  const MethodChannelDeviceStorageService({
    MethodChannel channel = const MethodChannel('tag/device_storage'),
  }) : _channel = channel;

  final MethodChannel _channel;

  @override
  Future<DeviceStorageInfo> loadStorageInfo() async {
    try {
      final result = await _channel.invokeMapMethod<String, Object?>(
        'getStorageInfo',
      );

      return DeviceStorageInfo(
        availableBytes: _asInt(result?['availableBytes']),
        totalBytes: _asInt(result?['totalBytes']),
      );
    } on MissingPluginException {
      return const DeviceStorageInfo.unknown();
    } on Object catch (error) {
      throw AppError('Device storage lookup failed.', cause: error);
    }
  }

  int? _asInt(Object? value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return null;
  }
}
