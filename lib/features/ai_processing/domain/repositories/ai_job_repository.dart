import 'package:equatable/equatable.dart';
import 'package:tag/features/ai_processing/domain/entities/ai_processing_job_entity.dart';

class CreateAiJobRequest extends Equatable {
  const CreateAiJobRequest({
    required this.id,
    required this.jobType,
    this.sourceId,
    this.cardId,
    this.spaceId,
    this.chatSessionId,
    this.priority = 100,
    this.maxAttempts = 3,
    this.inputJson = '{}',
    this.modelSlug,
  });

  final String id;
  final AiJobType jobType;
  final String? sourceId;
  final String? cardId;
  final String? spaceId;
  final String? chatSessionId;
  final int priority;
  final int maxAttempts;
  final String inputJson;
  final String? modelSlug;

  @override
  List<Object?> get props => [
    id,
    jobType,
    sourceId,
    cardId,
    spaceId,
    chatSessionId,
    priority,
    maxAttempts,
    inputJson,
    modelSlug,
  ];
}

abstract interface class AiJobRepository {
  Future<AiProcessingJobEntity> createJob(CreateAiJobRequest request);

  Future<AiProcessingJobEntity?> getJobById(String id);

  Future<AiProcessingJobEntity?> getNextRunnableJob();

  Future<int> recoverStaleRunningJobs();

  Stream<List<AiProcessingJobEntity>> watchJobs({int limit = 50});

  Future<AiProcessingJobEntity?> startJob(String id);

  Future<AiProcessingJobEntity> completeJob({
    required String id,
    required String outputJson,
    String? modelSlug,
  });

  Future<AiProcessingJobEntity> failJob({
    required String id,
    required String errorMessage,
  });

  Future<AiProcessingJobEntity> deferJob({
    required String id,
    required String errorMessage,
  });

  Future<AiProcessingJobEntity> retryJob(String id);

  Future<AiProcessingJobEntity> cancelJob(String id);
}
