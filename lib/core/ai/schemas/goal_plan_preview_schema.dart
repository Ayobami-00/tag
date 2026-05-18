import 'package:equatable/equatable.dart';
import 'package:tag/core/ai/validation/ai_schema_validation_exception.dart';

class GoalPlanPreview extends Equatable {
  const GoalPlanPreview({
    required this.goalName,
    required this.spaceName,
    required this.durationWeeks,
    required this.preferredDays,
    required this.cards,
  });

  factory GoalPlanPreview.fromJson(Map<String, Object?> json) {
    final cards = _requiredMapList(
      json,
      'cards',
    ).map(GoalPlanPreviewCard.fromJson).toList(growable: false);
    if (cards.isEmpty) {
      throw const AiSchemaValidationException(
        'Goal plan preview must include at least one card.',
      );
    }

    return GoalPlanPreview(
      goalName: _requiredNonEmptyString(json, 'goal_name'),
      spaceName: _requiredNonEmptyString(json, 'space_name'),
      durationWeeks: _requiredPositiveInt(json, 'duration_weeks'),
      preferredDays: _stringList(json['preferred_days']),
      cards: cards,
    );
  }

  final String goalName;
  final String spaceName;
  final int durationWeeks;
  final List<String> preferredDays;
  final List<GoalPlanPreviewCard> cards;

  GoalPlanPreview validateForSourceBackedSuggestion({
    required Set<String> allowedSourceIds,
    required int? expectedDurationWeeks,
  }) {
    if (expectedDurationWeeks != null &&
        durationWeeks != expectedDurationWeeks) {
      throw AiSchemaValidationException(
        'Goal plan preview duration must be $expectedDurationWeeks weeks.',
      );
    }

    for (final card in cards) {
      if (allowedSourceIds.isNotEmpty && card.sourceIds.isEmpty) {
        throw const AiSchemaValidationException(
          'Each source-backed Goal Card preview must cite at least one source.',
        );
      }

      final unknownSourceIds = card.sourceIds
          .where((sourceId) => !allowedSourceIds.contains(sourceId))
          .toList(growable: false);
      if (unknownSourceIds.isNotEmpty) {
        throw AiSchemaValidationException(
          'Goal plan preview cited unknown source ids: '
          '${unknownSourceIds.join(', ')}.',
        );
      }
    }

    return this;
  }

  Map<String, Object?> toJson() {
    return {
      'goal_name': goalName,
      'space_name': spaceName,
      'duration_weeks': durationWeeks,
      'preferred_days': preferredDays,
      'cards': cards.map((card) => card.toJson()).toList(growable: false),
    };
  }

  @override
  List<Object?> get props => [
    goalName,
    spaceName,
    durationWeeks,
    preferredDays,
    cards,
  ];
}

class GoalPlanPreviewCard extends Equatable {
  const GoalPlanPreviewCard({
    required this.title,
    required this.reason,
    required this.scheduledFor,
    required this.sourceIds,
  });

  factory GoalPlanPreviewCard.fromJson(Map<String, Object?> json) {
    final scheduledFor = _nullableString(json, 'scheduled_for');
    if (scheduledFor != null && DateTime.tryParse(scheduledFor) == null) {
      throw const AiSchemaValidationException(
        'Goal Card preview scheduled_for must be an ISO-8601 date/time.',
      );
    }

    return GoalPlanPreviewCard(
      title: _requiredNonEmptyString(json, 'title'),
      reason: _requiredNonEmptyString(json, 'reason'),
      scheduledFor: scheduledFor,
      sourceIds: _stringList(json['source_ids']),
    );
  }

  final String title;
  final String reason;
  final String? scheduledFor;
  final List<String> sourceIds;

  Map<String, Object?> toJson() {
    return {
      'title': title,
      'reason': reason,
      'scheduled_for': scheduledFor,
      'source_ids': sourceIds,
    };
  }

  @override
  List<Object?> get props => [title, reason, scheduledFor, sourceIds];
}

String _requiredNonEmptyString(Map<String, Object?> json, String key) {
  final value = _requiredString(json, key).trim();
  if (value.isEmpty) {
    throw AiSchemaValidationException(
      'Goal plan preview field "$key" must not be empty.',
    );
  }

  return value;
}

String _requiredString(Map<String, Object?> json, String key) {
  if (!json.containsKey(key)) {
    throw AiSchemaValidationException(
      'Goal plan preview JSON is missing "$key".',
    );
  }

  final value = json[key];
  if (value is! String) {
    throw AiSchemaValidationException(
      'Goal plan preview field "$key" must be a string.',
    );
  }

  return value;
}

String? _nullableString(Map<String, Object?> json, String key) {
  if (!json.containsKey(key)) {
    throw AiSchemaValidationException(
      'Goal plan preview JSON is missing "$key".',
    );
  }

  final value = json[key];
  if (value == null) {
    return null;
  }
  if (value is! String) {
    throw AiSchemaValidationException(
      'Goal plan preview field "$key" must be a string or null.',
    );
  }

  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

int _requiredPositiveInt(Map<String, Object?> json, String key) {
  if (!json.containsKey(key)) {
    throw AiSchemaValidationException(
      'Goal plan preview JSON is missing "$key".',
    );
  }

  final value = json[key];
  final intValue = value is int ? value : null;
  if (intValue == null || intValue < 1 || intValue > 52) {
    throw AiSchemaValidationException(
      'Goal plan preview field "$key" must be between 1 and 52.',
    );
  }

  return intValue;
}

List<Map<String, Object?>> _requiredMapList(
  Map<String, Object?> json,
  String key,
) {
  if (!json.containsKey(key)) {
    throw AiSchemaValidationException(
      'Goal plan preview JSON is missing "$key".',
    );
  }

  final value = json[key];
  if (value is! List) {
    throw AiSchemaValidationException(
      'Goal plan preview field "$key" must be a list.',
    );
  }

  return value
      .map((item) {
        if (item is Map<String, Object?>) {
          return item;
        }
        if (item is Map) {
          return item.map((key, value) => MapEntry(key.toString(), value));
        }
        throw AiSchemaValidationException(
          'Goal plan preview field "$key" must contain objects.',
        );
      })
      .toList(growable: false);
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
