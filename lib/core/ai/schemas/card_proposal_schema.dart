import 'package:equatable/equatable.dart';
import 'package:tag/core/ai/schemas/intention_result_schema.dart';
import 'package:tag/core/ai/validation/ai_schema_validation_exception.dart';

abstract final class CardProposalValues {
  static const cardTypes = ['urgent', 'goal', 'suggestion', 'passive'];
  static const urgentActions = ['complete', 'snooze', 'cancel'];
  static const goalActions = ['complete', 'edit', 'snooze', 'view_space'];
  static const suggestionActions = ['plan_this', 'dismiss'];
  static const passiveActions = <String>[];
}

class CardProposal extends Equatable {
  const CardProposal({
    required this.cardType,
    required this.title,
    required this.reason,
    required this.spaceName,
    required this.nextActiveDeadline,
    required this.sourceIds,
    required this.actions,
    required this.confidence,
    required this.notificationEligible,
  });

  factory CardProposal.fromJson(Map<String, Object?> json) {
    final cardType = _requiredString(json, 'card_type');
    if (!CardProposalValues.cardTypes.contains(cardType)) {
      throw AiSchemaValidationException(
        'Card proposal type "$cardType" is not supported.',
      );
    }

    final deadline = _nullableString(json, 'next_active_deadline');
    if (deadline != null && DateTime.tryParse(deadline) == null) {
      throw AiSchemaValidationException(
        'Card proposal deadline must be null or an ISO-8601 date/time.',
      );
    }

    final actions = _requiredStringList(json, 'actions');
    _validateActionSet(cardType, actions);

    return CardProposal(
      cardType: cardType,
      title: _requiredNonEmptyString(json, 'title'),
      reason: _requiredNonEmptyString(json, 'reason'),
      spaceName: _requiredNonEmptyString(json, 'space_name'),
      nextActiveDeadline: deadline,
      sourceIds: _requiredStringList(json, 'source_ids'),
      actions: actions,
      confidence: _requiredConfidence(json, 'confidence'),
      notificationEligible: _notificationEligible(cardType, deadline),
    );
  }

  factory CardProposal.fromIntention({
    required IntentionResult intention,
    required String sourceId,
  }) {
    final actions = _actionsFor(intention.suggestedCardType);
    return CardProposal(
      cardType: intention.suggestedCardType,
      title: intention.title,
      reason: intention.reason,
      spaceName: intention.spaceSuggestion,
      nextActiveDeadline: intention.nextActiveDeadline,
      sourceIds: [sourceId],
      actions: actions,
      confidence: intention.confidence,
      notificationEligible: _notificationEligible(
        intention.suggestedCardType,
        intention.nextActiveDeadline,
      ),
    );
  }

  final String cardType;
  final String title;
  final String reason;
  final String spaceName;
  final String? nextActiveDeadline;
  final List<String> sourceIds;
  final List<String> actions;
  final double confidence;
  final bool notificationEligible;

  Map<String, Object?> toJson() {
    return {
      'card_type': cardType,
      'title': title,
      'reason': reason,
      'space_name': spaceName,
      'next_active_deadline': nextActiveDeadline,
      'source_ids': sourceIds,
      'actions': actions,
      'confidence': confidence,
      'notification_eligible': notificationEligible,
    };
  }

  @override
  List<Object?> get props => [
    cardType,
    title,
    reason,
    spaceName,
    nextActiveDeadline,
    sourceIds,
    actions,
    confidence,
    notificationEligible,
  ];
}

List<String> _actionsFor(String cardType) {
  return switch (cardType) {
    'urgent' => CardProposalValues.urgentActions,
    'goal' => CardProposalValues.goalActions,
    'suggestion' => CardProposalValues.suggestionActions,
    'passive' => CardProposalValues.passiveActions,
    _ => throw AiSchemaValidationException(
      'Card proposal type "$cardType" is not supported.',
    ),
  };
}

void _validateActionSet(String cardType, List<String> actions) {
  final expected = _actionsFor(cardType);
  if (actions.length != expected.length ||
      actions.any((action) => !expected.contains(action))) {
    throw AiSchemaValidationException(
      'Card proposal actions do not match "$cardType".',
    );
  }
}

bool _notificationEligible(String cardType, String? nextActiveDeadline) {
  return (cardType == 'urgent' || cardType == 'goal') &&
      nextActiveDeadline != null;
}

String _requiredString(Map<String, Object?> json, String key) {
  if (!json.containsKey(key)) {
    throw AiSchemaValidationException('Card proposal JSON is missing "$key".');
  }

  final value = json[key];
  if (value is! String) {
    throw AiSchemaValidationException(
      'Card proposal field "$key" must be a string.',
    );
  }

  return value.trim();
}

String _requiredNonEmptyString(Map<String, Object?> json, String key) {
  final value = _requiredString(json, key);
  if (value.isEmpty) {
    throw AiSchemaValidationException(
      'Card proposal field "$key" must not be empty.',
    );
  }

  return value;
}

String? _nullableString(Map<String, Object?> json, String key) {
  if (!json.containsKey(key)) {
    throw AiSchemaValidationException('Card proposal JSON is missing "$key".');
  }

  final value = json[key];
  if (value == null) {
    return null;
  }
  if (value is! String) {
    throw AiSchemaValidationException(
      'Card proposal field "$key" must be a string or null.',
    );
  }

  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

List<String> _requiredStringList(Map<String, Object?> json, String key) {
  if (!json.containsKey(key)) {
    throw AiSchemaValidationException('Card proposal JSON is missing "$key".');
  }

  final value = json[key];
  if (value is! List) {
    throw AiSchemaValidationException(
      'Card proposal field "$key" must be a list.',
    );
  }

  final values = value
      .map((item) {
        if (item is! String) {
          throw AiSchemaValidationException(
            'Card proposal field "$key" must contain only strings.',
          );
        }
        return item.trim();
      })
      .where((item) => item.isNotEmpty)
      .toList(growable: false);

  if (key == 'source_ids' && values.isEmpty && json['card_type'] != 'passive') {
    throw const AiSchemaValidationException(
      'Card proposal must cite at least one source.',
    );
  }

  return values;
}

double _requiredConfidence(Map<String, Object?> json, String key) {
  if (!json.containsKey(key)) {
    throw AiSchemaValidationException('Card proposal JSON is missing "$key".');
  }

  final value = json[key];
  final confidence = value is num ? value.toDouble() : null;
  if (confidence == null || confidence < 0 || confidence > 1) {
    throw AiSchemaValidationException(
      'Card proposal field "$key" must be between 0 and 1.',
    );
  }

  return confidence;
}
