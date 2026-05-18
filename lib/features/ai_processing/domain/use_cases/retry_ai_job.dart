import 'package:equatable/equatable.dart';
import 'package:tag/core/use_cases/use_cases.dart';
import 'package:tag/features/ai_processing/domain/entities/ai_processing_job_entity.dart';
import 'package:tag/features/ai_processing/domain/repositories/ai_job_repository.dart';
import 'package:tag/features/ai_processing/domain/services/ai_job_queue_runner.dart';

class RetryAiJobParams extends Equatable {
  const RetryAiJobParams(this.jobId);

  final String jobId;

  @override
  List<Object?> get props => [jobId];
}

class RetryAiJob with UseCases<AiProcessingJobEntity, RetryAiJobParams> {
  const RetryAiJob({
    required AiJobRepository aiJobRepository,
    required AiJobQueueRunner aiJobQueueRunner,
  }) : _aiJobRepository = aiJobRepository,
       _aiJobQueueRunner = aiJobQueueRunner;

  final AiJobRepository _aiJobRepository;
  final AiJobQueueRunner _aiJobQueueRunner;

  @override
  Future<AiProcessingJobEntity> call(RetryAiJobParams params) async {
    final job = await _aiJobRepository.retryJob(params.jobId);
    _aiJobQueueRunner.requestProcessing();
    return job;
  }
}
