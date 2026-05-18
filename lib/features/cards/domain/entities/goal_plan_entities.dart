import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:tag/core/ai/schemas/goal_plan_preview_schema.dart';
import 'package:tag/core/ai/validation/ai_schema_validation_exception.dart';
import 'package:tag/features/cards/domain/entities/card_entities.dart';

enum GoalPlanStatus {
  draft('draft'),
  active('active'),
  completed('completed'),
  cancelled('cancelled'),
  archived('archived');

  const GoalPlanStatus(this.storageValue);

  final String storageValue;

  static GoalPlanStatus fromStorageValue(String value) {
    return GoalPlanStatus.values.firstWhere(
      (status) => status.storageValue == value,
      orElse: () => GoalPlanStatus.active,
    );
  }
}

enum GoalPlanCreatedBy {
  suggestion('suggestion'),
  chat('chat'),
  manual('manual');

  const GoalPlanCreatedBy(this.storageValue);

  final String storageValue;

  static GoalPlanCreatedBy fromStorageValue(String value) {
    return GoalPlanCreatedBy.values.firstWhere(
      (createdBy) => createdBy.storageValue == value,
      orElse: () => GoalPlanCreatedBy.chat,
    );
  }
}

class GoalPlanEntity extends Equatable {
  const GoalPlanEntity({
    required this.id,
    required this.space,
    required this.name,
    required this.preferredDays,
    required this.reminderPreferenceJson,
    required this.status,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.originCardId,
    this.chatSessionId,
    this.description,
    this.durationWeeks,
    this.sessionLengthMinutes,
    this.modelSlug,
    this.planPreviewJson,
    this.completedAt,
    this.cancelledAt,
  });

  final String id;
  final SpaceEntity space;
  final String? originCardId;
  final String? chatSessionId;
  final String name;
  final String? description;
  final int? durationWeeks;
  final List<String> preferredDays;
  final int? sessionLengthMinutes;
  final String reminderPreferenceJson;
  final GoalPlanStatus status;
  final GoalPlanCreatedBy createdBy;
  final String? modelSlug;
  final String? planPreviewJson;
  final int createdAt;
  final int updatedAt;
  final int? completedAt;
  final int? cancelledAt;

  @override
  List<Object?> get props => [
    id,
    space,
    originCardId,
    chatSessionId,
    name,
    description,
    durationWeeks,
    preferredDays,
    sessionLengthMinutes,
    reminderPreferenceJson,
    status,
    createdBy,
    modelSlug,
    planPreviewJson,
    createdAt,
    updatedAt,
    completedAt,
    cancelledAt,
  ];
}

class GoalPlanCardEntity extends Equatable {
  const GoalPlanCardEntity({
    required this.goalPlanId,
    required this.card,
    required this.sequenceIndex,
    required this.createdAt,
  });

  final String goalPlanId;
  final TagCardEntity card;
  final int sequenceIndex;
  final int createdAt;

  @override
  List<Object?> get props => [goalPlanId, card, sequenceIndex, createdAt];
}

class GoalPlanConfirmation extends Equatable {
  const GoalPlanConfirmation({
    required this.chatSessionId,
    required this.sourceIds,
    required this.preview,
    required this.planStyle,
    required this.weeklyTime,
    required this.createdBy,
    this.originCardId,
    this.spaceId,
    this.weeklyTimeMinutes,
    this.modelSlug,
    this.createdAtIso,
  });

  factory GoalPlanConfirmation.fromJson(Map<String, Object?> json) {
    final type = _stringValue(json['type']).trim();
    if (type != 'create_goal_plan') {
      throw AiSchemaValidationException(
        'Unsupported goal plan confirmation type "$type".',
      );
    }

    if (json['requires_confirmation'] != true) {
      throw const AiSchemaValidationException(
        'Goal plan mutation must require confirmation.',
      );
    }

    final previewJson = _mapValue(json['preview']);
    if (previewJson.isEmpty) {
      throw const AiSchemaValidationException(
        'Goal plan confirmation is missing a preview.',
      );
    }

    final sourceIds = _stringList(json['source_ids']);
    final preview = GoalPlanPreview.fromJson(previewJson)
        .validateForSourceBackedSuggestion(
          allowedSourceIds: sourceIds.toSet(),
          expectedDurationWeeks: _expectedDurationWeeks(json['plan_style']),
        );

    final chatSessionId = _stringValue(json['chat_session_id']).trim();
    if (chatSessionId.isEmpty) {
      throw const AiSchemaValidationException(
        'Goal plan confirmation must include chat_session_id.',
      );
    }

    return GoalPlanConfirmation(
      chatSessionId: chatSessionId,
      originCardId: _nullableString(json['origin_card_id']),
      spaceId: _nullableString(json['space_id']),
      sourceIds: sourceIds,
      planStyle: _stringValue(json['plan_style']).trim(),
      weeklyTime: _stringValue(json['weekly_time']).trim(),
      weeklyTimeMinutes: _nullableInt(json['weekly_time_minutes']),
      modelSlug: _nullableString(json['model_slug']),
      createdAtIso: _nullableString(json['created_at']),
      createdBy: _createdByFor(_stringValue(json['origin'])),
      preview: preview,
    );
  }

  final String chatSessionId;
  final String? originCardId;
  final String? spaceId;
  final List<String> sourceIds;
  final String planStyle;
  final String weeklyTime;
  final int? weeklyTimeMinutes;
  final String? modelSlug;
  final String? createdAtIso;
  final GoalPlanCreatedBy createdBy;
  final GoalPlanPreview preview;

  Map<String, Object?> toJson() {
    return {
      'type': 'create_goal_plan',
      'requires_confirmation': true,
      'chat_session_id': chatSessionId,
      if (originCardId != null) 'origin_card_id': originCardId,
      if (spaceId != null) 'space_id': spaceId,
      'source_ids': sourceIds,
      'plan_style': planStyle,
      'weekly_time': weeklyTime,
      if (weeklyTimeMinutes != null) 'weekly_time_minutes': weeklyTimeMinutes,
      if (modelSlug != null) 'model_slug': modelSlug,
      if (createdAtIso != null) 'created_at': createdAtIso,
      'created_by': createdBy.storageValue,
      'preview': preview.toJson(),
    };
  }

  @override
  List<Object?> get props => [
    chatSessionId,
    originCardId,
    spaceId,
    sourceIds,
    planStyle,
    weeklyTime,
    weeklyTimeMinutes,
    modelSlug,
    createdAtIso,
    createdBy,
    preview,
  ];
}

class GoalPlanCreationResult extends Equatable {
  const GoalPlanCreationResult({
    required this.goalPlan,
    required this.cards,
    required this.sourceIds,
    this.dismissedSuggestion,
  });

  final GoalPlanEntity goalPlan;
  final List<TagCardEntity> cards;
  final List<String> sourceIds;
  final TagCardEntity? dismissedSuggestion;

  @override
  List<Object?> get props => [goalPlan, cards, sourceIds, dismissedSuggestion];
}

class GoalPlanFutureUpdateResult extends Equatable {
  const GoalPlanFutureUpdateResult({
    required this.goalPlan,
    required this.updatedCards,
    required this.unchangedCards,
    required this.skippedCompletedCards,
  });

  final GoalPlanEntity goalPlan;
  final List<TagCardEntity> updatedCards;
  final List<TagCardEntity> unchangedCards;
  final List<TagCardEntity> skippedCompletedCards;

  @override
  List<Object?> get props => [
    goalPlan,
    updatedCards,
    unchangedCards,
    skippedCompletedCards,
  ];
}

class GoalPlanException implements Exception {
  const GoalPlanException(this.message);

  final String message;

  @override
  String toString() => message;
}

Map<String, Object?> decodeJsonObject(String value, String description) {
  try {
    final decoded = jsonDecode(value);
    return _mapValue(decoded);
  } on FormatException catch (error) {
    throw AiSchemaValidationException(
      '$description must be valid JSON: ${error.message}',
    );
  }
}

GoalPlanCreatedBy _createdByFor(String origin) {
  return switch (origin.trim()) {
    'plan_suggestion' || 'suggestion' => GoalPlanCreatedBy.suggestion,
    'manual' => GoalPlanCreatedBy.manual,
    _ => GoalPlanCreatedBy.chat,
  };
}

int? _expectedDurationWeeks(Object? planStyle) {
  return switch (_stringValue(planStyle)) {
    'weekend' => 1,
    'four_week' => 4,
    'light_reading' => 4,
    _ => null,
  };
}

String _stringValue(Object? value) => value is String ? value : '';

String? _nullableString(Object? value) {
  if (value is! String) {
    return null;
  }

  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

int? _nullableInt(Object? value) => value is int ? value : null;

Map<String, Object?> _mapValue(Object? value) {
  if (value is Map<String, Object?>) {
    return value;
  }
  if (value is Map) {
    return value.map((key, value) => MapEntry(key.toString(), value));
  }

  return const {};
}

List<String> _stringList(Object? value) {
  if (value is! List) {
    return const [];
  }

  final seen = <String>{};
  return [
    for (final item in value)
      if (item is String && item.trim().isNotEmpty && seen.add(item.trim()))
        item.trim(),
  ];
}
