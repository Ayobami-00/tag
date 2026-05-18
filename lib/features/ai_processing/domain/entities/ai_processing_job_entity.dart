import 'package:equatable/equatable.dart';

enum AiJobStatus {
  queued('queued'),
  running('running'),
  awaitingConfirmation('awaiting_confirmation'),
  completed('completed'),
  failed('failed'),
  cancelled('cancelled');

  const AiJobStatus(this.storageValue);

  final String storageValue;

  static AiJobStatus fromStorageValue(String value) {
    return AiJobStatus.values.firstWhere(
      (status) => status.storageValue == value,
      orElse: () => AiJobStatus.queued,
    );
  }

  String get displayLabel {
    return switch (this) {
      AiJobStatus.queued => 'Queued',
      AiJobStatus.running => 'Running',
      AiJobStatus.awaitingConfirmation => 'Needs confirmation',
      AiJobStatus.completed => 'Completed',
      AiJobStatus.failed => 'Failed',
      AiJobStatus.cancelled => 'Cancelled',
    };
  }
}

enum AiJobType {
  extractSource('extract_source'),
  detectIntention('detect_intention'),
  generateCard('generate_card'),
  generateSuggestion('generate_suggestion'),
  planGoal('plan_goal'),
  answerChat('answer_chat'),
  embedSource('embed_source'),
  clusterSources('cluster_sources');

  const AiJobType(this.storageValue);

  final String storageValue;

  static AiJobType fromStorageValue(String value) {
    return AiJobType.values.firstWhere(
      (type) => type.storageValue == value,
      orElse: () => AiJobType.extractSource,
    );
  }

  String get displayLabel {
    return switch (this) {
      AiJobType.extractSource => 'Extract source',
      AiJobType.detectIntention => 'Detect intention',
      AiJobType.generateCard => 'Generate card',
      AiJobType.generateSuggestion => 'Generate suggestion',
      AiJobType.planGoal => 'Plan goal',
      AiJobType.answerChat => 'Answer chat',
      AiJobType.embedSource => 'Embed source',
      AiJobType.clusterSources => 'Cluster sources',
    };
  }
}

class AiProcessingJobEntity extends Equatable {
  const AiProcessingJobEntity({
    required this.id,
    required this.jobType,
    required this.status,
    required this.priority,
    required this.attemptCount,
    required this.maxAttempts,
    required this.inputJson,
    required this.queuedAt,
    required this.updatedAt,
    this.sourceId,
    this.cardId,
    this.spaceId,
    this.chatSessionId,
    this.outputJson,
    this.errorMessage,
    this.modelSlug,
    this.startedAt,
    this.completedAt,
  });

  final String id;
  final AiJobType jobType;
  final AiJobStatus status;
  final String? sourceId;
  final String? cardId;
  final String? spaceId;
  final String? chatSessionId;
  final int priority;
  final int attemptCount;
  final int maxAttempts;
  final String inputJson;
  final String? outputJson;
  final String? errorMessage;
  final String? modelSlug;
  final int queuedAt;
  final int? startedAt;
  final int? completedAt;
  final int updatedAt;

  bool get canRun => status == AiJobStatus.queued;

  bool get canRetry =>
      status == AiJobStatus.failed && attemptCount < maxAttempts;

  bool get canCancel =>
      status == AiJobStatus.queued || status == AiJobStatus.running;

  @override
  List<Object?> get props => [
    id,
    jobType,
    status,
    sourceId,
    cardId,
    spaceId,
    chatSessionId,
    priority,
    attemptCount,
    maxAttempts,
    inputJson,
    outputJson,
    errorMessage,
    modelSlug,
    queuedAt,
    startedAt,
    completedAt,
    updatedAt,
  ];
}
