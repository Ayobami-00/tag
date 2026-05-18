part of 'ai_job_queue_cubit.dart';

enum AiJobQueueViewStatus { initial, loading, ready, failure }

class AiJobQueueState extends Equatable {
  const AiJobQueueState({
    this.status = AiJobQueueViewStatus.initial,
    this.jobs = const [],
    this.actionMessage = '',
    this.errorMessage = '',
  });

  final AiJobQueueViewStatus status;
  final List<AiProcessingJobEntity> jobs;
  final String actionMessage;
  final String errorMessage;

  AiJobQueueState copyWith({
    AiJobQueueViewStatus? status,
    List<AiProcessingJobEntity>? jobs,
    String? actionMessage,
    String? errorMessage,
  }) {
    return AiJobQueueState(
      status: status ?? this.status,
      jobs: jobs ?? this.jobs,
      actionMessage: actionMessage ?? this.actionMessage,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, jobs, actionMessage, errorMessage];
}
