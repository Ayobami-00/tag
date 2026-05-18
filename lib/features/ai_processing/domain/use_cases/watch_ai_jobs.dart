import 'package:equatable/equatable.dart';
import 'package:tag/core/use_cases/use_cases.dart';
import 'package:tag/features/ai_processing/domain/entities/ai_processing_job_entity.dart';
import 'package:tag/features/ai_processing/domain/repositories/ai_job_repository.dart';

class WatchAiJobsParams extends Equatable {
  const WatchAiJobsParams({this.limit = 50});

  final int limit;

  @override
  List<Object?> get props => [limit];
}

class WatchAiJobs
    with StreamUseCases<List<AiProcessingJobEntity>, WatchAiJobsParams> {
  const WatchAiJobs(this._aiJobRepository);

  final AiJobRepository _aiJobRepository;

  @override
  Stream<List<AiProcessingJobEntity>> call(WatchAiJobsParams params) {
    return _aiJobRepository.watchJobs(limit: params.limit);
  }
}
