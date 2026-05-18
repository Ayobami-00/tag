import 'package:equatable/equatable.dart';
import 'package:tag/core/use_cases/use_cases.dart';
import 'package:tag/features/ai_processing/domain/entities/ai_processing_job_entity.dart';
import 'package:tag/features/ai_processing/domain/repositories/ai_job_repository.dart';

class CancelAiJobParams extends Equatable {
  const CancelAiJobParams(this.jobId);

  final String jobId;

  @override
  List<Object?> get props => [jobId];
}

class CancelAiJob with UseCases<AiProcessingJobEntity, CancelAiJobParams> {
  const CancelAiJob(this._aiJobRepository);

  final AiJobRepository _aiJobRepository;

  @override
  Future<AiProcessingJobEntity> call(CancelAiJobParams params) {
    return _aiJobRepository.cancelJob(params.jobId);
  }
}
