import 'dart:convert';

import 'package:equatable/equatable.dart';

enum FeedbackEventType {
  planThis('plan_this'),
  dismiss('dismiss'),
  complete('complete'),
  snooze('snooze'),
  cancel('cancel'),
  editTitle('edit_title'),
  editDeadline('edit_deadline'),
  editSpace('edit_space'),
  editGoalCadence('edit_goal_cadence'),
  openSource('open_source'),
  viewSpace('view_space'),
  archive('archive');

  const FeedbackEventType(this.storageValue);

  final String storageValue;

  static FeedbackEventType fromStorageValue(String value) {
    return FeedbackEventType.values.firstWhere(
      (eventType) => eventType.storageValue == value,
      orElse: () => FeedbackEventType.complete,
    );
  }
}

class FeedbackEventEntity extends Equatable {
  const FeedbackEventEntity({
    required this.id,
    required this.eventType,
    required this.details,
    required this.createdAt,
    this.cardId,
    this.spaceId,
    this.sourceId,
    this.goalPlanId,
  });

  final String id;
  final FeedbackEventType eventType;
  final String? cardId;
  final String? spaceId;
  final String? sourceId;
  final String? goalPlanId;
  final Map<String, Object?> details;
  final int createdAt;

  String get detailsJson => jsonEncode(details);

  @override
  List<Object?> get props => [
    id,
    eventType,
    cardId,
    spaceId,
    sourceId,
    goalPlanId,
    details,
    createdAt,
  ];
}

class PreferenceMemoryEntity extends Equatable {
  const PreferenceMemoryEntity({
    required this.id,
    required this.category,
    required this.key,
    required this.valueJson,
    required this.confidence,
    required this.evidenceEventIds,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String category;
  final String key;
  final String valueJson;
  final double confidence;
  final List<String> evidenceEventIds;
  final int createdAt;
  final int updatedAt;

  Object? get value {
    try {
      return jsonDecode(valueJson);
    } on FormatException {
      return valueJson;
    }
  }

  @override
  List<Object?> get props => [
    id,
    category,
    key,
    valueJson,
    confidence,
    evidenceEventIds,
    createdAt,
    updatedAt,
  ];
}
