import 'package:equatable/equatable.dart';

enum TagCardType {
  urgent('urgent', 'Urgent'),
  goal('goal', 'Goal'),
  suggestion('suggestion', 'Suggestion');

  const TagCardType(this.storageValue, this.label);

  final String storageValue;
  final String label;

  static TagCardType fromStorageValue(String value) {
    return TagCardType.values.firstWhere(
      (type) => type.storageValue == value,
      orElse: () => TagCardType.suggestion,
    );
  }
}

enum TagCardStatus {
  active('active', 'Active'),
  processing('processing', 'Processing'),
  completed('completed', 'Completed'),
  snoozed('snoozed', 'Snoozed'),
  cancelled('cancelled', 'Cancelled'),
  dismissed('dismissed', 'Dismissed'),
  archived('archived', 'Archived');

  const TagCardStatus(this.storageValue, this.label);

  final String storageValue;
  final String label;

  static TagCardStatus fromStorageValue(String value) {
    return TagCardStatus.values.firstWhere(
      (status) => status.storageValue == value,
      orElse: () => TagCardStatus.active,
    );
  }
}

enum TagCardAction {
  complete('complete', 'Complete'),
  snooze('snooze', 'Snooze'),
  cancel('cancel', 'Cancel'),
  edit('edit', 'Edit'),
  viewSpace('view_space', 'View Space'),
  planThis('plan_this', 'Plan this'),
  dismiss('dismiss', 'Dismiss'),
  archive('archive', 'Archive');

  const TagCardAction(this.storageValue, this.label);

  final String storageValue;
  final String label;

  static TagCardAction fromStorageValue(String value) {
    return TagCardAction.values.firstWhere(
      (action) => action.storageValue == value,
      orElse: () => TagCardAction.edit,
    );
  }
}

enum SpaceType {
  specific('specific'),
  fallback('fallback');

  const SpaceType(this.storageValue);

  final String storageValue;

  static SpaceType fromStorageValue(String value) {
    return SpaceType.values.firstWhere(
      (type) => type.storageValue == value,
      orElse: () => SpaceType.fallback,
    );
  }
}

class SpaceEntity extends Equatable {
  const SpaceEntity({
    required this.id,
    required this.name,
    required this.normalizedName,
    required this.type,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.primaryIntentionType,
    this.confidence,
  });

  final String id;
  final String name;
  final String normalizedName;
  final SpaceType type;
  final String? description;
  final String? primaryIntentionType;
  final String createdBy;
  final double? confidence;
  final int createdAt;
  final int updatedAt;

  @override
  List<Object?> get props => [
    id,
    name,
    normalizedName,
    type,
    description,
    primaryIntentionType,
    createdBy,
    confidence,
    createdAt,
    updatedAt,
  ];
}

class TagCardEntity extends Equatable {
  const TagCardEntity({
    required this.id,
    required this.cardType,
    required this.status,
    required this.title,
    required this.reason,
    required this.space,
    required this.notificationEnabled,
    required this.actions,
    required this.sourceSummary,
    required this.evidenceSummary,
    required this.sourceIds,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.nextActiveDeadline,
    this.deadlineTimezone,
    this.snoozedUntil,
    this.confidence,
    this.parentGoalPlanId,
    this.modelSlug,
    this.modelOutputJson,
    this.metadataJson = '{}',
    this.completedAt,
    this.cancelledAt,
    this.dismissedAt,
    this.archivedAt,
  });

  final String id;
  final TagCardType cardType;
  final TagCardStatus status;
  final String title;
  final String reason;
  final SpaceEntity space;
  final int? nextActiveDeadline;
  final String? deadlineTimezone;
  final int? snoozedUntil;
  final bool notificationEnabled;
  final List<TagCardAction> actions;
  final double? confidence;
  final String sourceSummary;
  final String evidenceSummary;
  final List<String> sourceIds;
  final String createdBy;
  final String? parentGoalPlanId;
  final String? modelSlug;
  final String? modelOutputJson;
  final String metadataJson;
  final int createdAt;
  final int updatedAt;
  final int? completedAt;
  final int? cancelledAt;
  final int? dismissedAt;
  final int? archivedAt;

  int? get nextAttentionTime => snoozedUntil ?? nextActiveDeadline;

  bool get isActive => status == TagCardStatus.active;

  bool get isProcessingPlaceholder =>
      status == TagCardStatus.processing &&
      id.startsWith('processing_source_') &&
      sourceIds.isNotEmpty;

  bool get isTerminal =>
      status == TagCardStatus.completed ||
      status == TagCardStatus.cancelled ||
      status == TagCardStatus.dismissed ||
      status == TagCardStatus.archived;

  @override
  List<Object?> get props => [
    id,
    cardType,
    status,
    title,
    reason,
    space,
    nextActiveDeadline,
    deadlineTimezone,
    snoozedUntil,
    notificationEnabled,
    actions,
    confidence,
    sourceSummary,
    evidenceSummary,
    sourceIds,
    createdBy,
    parentGoalPlanId,
    modelSlug,
    modelOutputJson,
    metadataJson,
    createdAt,
    updatedAt,
    completedAt,
    cancelledAt,
    dismissedAt,
    archivedAt,
  ];
}

class CardActionResult extends Equatable {
  const CardActionResult({
    required this.previousCard,
    required this.card,
    required this.action,
    required this.actionAt,
  });

  final TagCardEntity previousCard;
  final TagCardEntity card;
  final TagCardAction action;
  final int actionAt;

  @override
  List<Object?> get props => [previousCard, card, action, actionAt];
}

class CardActionException implements Exception {
  const CardActionException(this.message);

  final String message;

  @override
  String toString() => message;
}
