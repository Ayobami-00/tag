import 'package:equatable/equatable.dart';
import 'package:tag/core/ai/validation/ai_schema_validation_exception.dart';

abstract final class IntentionSchemaValues {
  static const intentionTypes = [
    'learn',
    'apply',
    'buy',
    'attend',
    'reply',
    'follow_up',
    'plan',
    'decide',
    'read',
    'remember',
    'compare',
  ];

  static const suggestedCardTypes = ['urgent', 'goal', 'suggestion', 'passive'];
}

class IntentionResult extends Equatable {
  const IntentionResult({
    required this.intentionType,
    required this.confidence,
    required this.title,
    required this.reason,
    required this.nextActiveDeadline,
    required this.suggestedCardType,
    required this.spaceSuggestion,
    required this.sourceSummary,
    required this.evidenceSummary,
  });

  factory IntentionResult.fromJson(Map<String, Object?> json) {
    final intentionType = _stringOrDefault(
      json,
      'intention_type',
      fallback: 'remember',
    );
    if (!IntentionSchemaValues.intentionTypes.contains(intentionType)) {
      throw AiSchemaValidationException(
        'Intention type "$intentionType" is not supported.',
      );
    }

    final suggestedCardType = _stringOrDefault(
      json,
      'suggested_card_type',
      fallback: 'passive',
    );
    if (!IntentionSchemaValues.suggestedCardTypes.contains(suggestedCardType)) {
      throw AiSchemaValidationException(
        'Suggested card type "$suggestedCardType" is not supported.',
      );
    }

    final deadline = _nullableString(json, 'next_active_deadline');
    if (deadline != null && DateTime.tryParse(deadline) == null) {
      throw AiSchemaValidationException(
        'next_active_deadline must be null or an ISO-8601 date/time.',
      );
    }

    return IntentionResult(
      intentionType: intentionType,
      confidence: _confidenceOrDefault(json, 'confidence', fallback: 0.5),
      title: _nonEmptyStringOrFallback(
        json,
        'title',
        fallbackKeys: const ['reason', 'evidence_summary', 'source_summary'],
        fallback: 'Review saved source',
      ),
      reason: _nonEmptyStringOrFallback(
        json,
        'reason',
        fallbackKeys: const ['evidence_summary', 'title', 'source_summary'],
        fallback: 'Tag found source evidence worth reviewing.',
      ),
      nextActiveDeadline: deadline,
      suggestedCardType: suggestedCardType,
      spaceSuggestion: _nonEmptyStringOrFallback(
        json,
        'space_suggestion',
        fallback: 'General',
      ),
      sourceSummary: _nonEmptyStringOrFallback(
        json,
        'source_summary',
        fallback: 'Saved source',
      ),
      evidenceSummary: _nonEmptyStringOrFallback(
        json,
        'evidence_summary',
        fallbackKeys: const ['reason', 'title', 'source_summary'],
        fallback: 'Saved source evidence.',
      ),
    );
  }

  final String intentionType;
  final double confidence;
  final String title;
  final String reason;
  final String? nextActiveDeadline;
  final String suggestedCardType;
  final String spaceSuggestion;
  final String sourceSummary;
  final String evidenceSummary;

  Map<String, Object?> toJson() {
    return {
      'intention_type': intentionType,
      'confidence': confidence,
      'title': title,
      'reason': reason,
      'next_active_deadline': nextActiveDeadline,
      'suggested_card_type': suggestedCardType,
      'space_suggestion': spaceSuggestion,
      'source_summary': sourceSummary,
      'evidence_summary': evidenceSummary,
    };
  }

  @override
  List<Object?> get props => [
    intentionType,
    confidence,
    title,
    reason,
    nextActiveDeadline,
    suggestedCardType,
    spaceSuggestion,
    sourceSummary,
    evidenceSummary,
  ];
}

String _requiredString(Map<String, Object?> json, String key) {
  if (!json.containsKey(key)) {
    throw AiSchemaValidationException('Intention JSON is missing "$key".');
  }

  final value = json[key];
  if (value is! String) {
    throw AiSchemaValidationException(
      'Intention field "$key" must be a string.',
    );
  }

  return value.trim();
}

String _stringOrDefault(
  Map<String, Object?> json,
  String key, {
  required String fallback,
}) {
  if (!json.containsKey(key)) {
    return fallback;
  }

  return _requiredString(json, key);
}

String _nonEmptyStringOrFallback(
  Map<String, Object?> json,
  String key, {
  List<String> fallbackKeys = const [],
  required String fallback,
}) {
  if (json.containsKey(key)) {
    final value = _requiredString(json, key);
    if (value.isNotEmpty) {
      return value;
    }
  }

  for (final fallbackKey in fallbackKeys) {
    if (!json.containsKey(fallbackKey)) {
      continue;
    }

    final value = _requiredString(json, fallbackKey);
    if (value.isNotEmpty) {
      return value;
    }
  }

  return fallback;
}

String? _nullableString(Map<String, Object?> json, String key) {
  if (!json.containsKey(key)) {
    return null;
  }

  final value = json[key];
  if (value == null) {
    return null;
  }
  if (value is! String) {
    throw AiSchemaValidationException(
      'Intention field "$key" must be a string or null.',
    );
  }

  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

double _confidenceOrDefault(
  Map<String, Object?> json,
  String key, {
  required double fallback,
}) {
  if (!json.containsKey(key)) {
    return fallback;
  }

  final value = json[key];
  final confidence = value is num ? value.toDouble() : null;
  if (confidence == null || confidence < 0 || confidence > 1) {
    throw AiSchemaValidationException(
      'Intention field "$key" must be between 0 and 1.',
    );
  }

  return confidence;
}
