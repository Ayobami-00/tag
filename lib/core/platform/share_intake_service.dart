import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:tag/core/error/app_error.dart';

enum PendingSharedSourceType {
  image('image'),
  text('text'),
  url('url');

  const PendingSharedSourceType(this.storageValue);

  final String storageValue;

  static PendingSharedSourceType fromStorageValue(String value) {
    return PendingSharedSourceType.values.firstWhere(
      (type) => type.storageValue == value,
      orElse: () => PendingSharedSourceType.text,
    );
  }
}

class PendingSharedSource extends Equatable {
  const PendingSharedSource({
    required this.id,
    required this.type,
    this.filePath,
    this.text,
    this.url,
    this.suggestedName,
    this.sourceApplication,
    this.receivedAt,
    this.uti,
  });

  final String id;
  final PendingSharedSourceType type;
  final String? filePath;
  final String? text;
  final String? url;
  final String? suggestedName;
  final String? sourceApplication;
  final int? receivedAt;
  final String? uti;

  @override
  List<Object?> get props => [
    id,
    type,
    filePath,
    text,
    url,
    suggestedName,
    sourceApplication,
    receivedAt,
    uti,
  ];
}

abstract interface class ShareIntakeService {
  Future<List<PendingSharedSource>> getPendingSharedSources();

  Future<void> markPendingSharedSourceImported(String id);
}

class MethodChannelShareIntakeService implements ShareIntakeService {
  const MethodChannelShareIntakeService({
    MethodChannel channel = const MethodChannel('tag/share_intake'),
  }) : _channel = channel;

  final MethodChannel _channel;

  @override
  Future<List<PendingSharedSource>> getPendingSharedSources() async {
    try {
      final result = await _channel.invokeListMethod<Object?>(
        'getPendingSharedSources',
      );

      return (result ?? const <Object?>[])
          .whereType<Map<Object?, Object?>>()
          .map(_mapPendingSource)
          .where((source) => source.id.trim().isNotEmpty)
          .toList(growable: false);
    } on MissingPluginException {
      return const [];
    } on Object catch (error) {
      throw AppError('Pending shared source lookup failed.', cause: error);
    }
  }

  @override
  Future<void> markPendingSharedSourceImported(String id) async {
    try {
      await _channel.invokeMethod<void>(
        'markPendingSharedSourceImported',
        <String, Object?>{'id': id},
      );
    } on MissingPluginException {
      return;
    } on Object catch (error) {
      throw AppError('Pending shared source cleanup failed.', cause: error);
    }
  }

  PendingSharedSource _mapPendingSource(Map<Object?, Object?> value) {
    return PendingSharedSource(
      id: _asString(value['id']) ?? '',
      type: PendingSharedSourceType.fromStorageValue(
        _asString(value['type']) ?? 'text',
      ),
      filePath: _asString(value['filePath'] ?? value['file_path']),
      text: _asString(value['text']),
      url: _asString(value['url']),
      suggestedName: _asString(
        value['suggestedName'] ?? value['suggested_name'],
      ),
      sourceApplication: _asString(
        value['sourceApplication'] ?? value['source_application'],
      ),
      receivedAt: _asInt(value['receivedAt'] ?? value['received_at']),
      uti: _asString(value['uti']),
    );
  }

  String? _asString(Object? value) {
    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }

    return null;
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
