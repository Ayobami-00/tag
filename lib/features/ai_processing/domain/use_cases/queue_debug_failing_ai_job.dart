import 'dart:convert';

import 'package:tag/core/use_cases/use_cases.dart';
import 'package:tag/features/ai_processing/domain/entities/ai_processing_job_entity.dart';
import 'package:tag/features/ai_processing/domain/repositories/ai_job_repository.dart';
import 'package:tag/features/ai_processing/domain/services/ai_job_queue_runner.dart';
import 'package:uuid/uuid.dart';

class QueueDebugFailingAiJob with UseCases<AiProcessingJobEntity, NoParams> {
  QueueDebugFailingAiJob({
    required AiJobRepository aiJobRepository,
    required AiJobQueueRunner aiJobQueueRunner,
    Uuid? uuid,
  }) : _aiJobRepository = aiJobRepository,
       _aiJobQueueRunner = aiJobQueueRunner,
       _uuid = uuid ?? const Uuid();

  final AiJobRepository _aiJobRepository;
  final AiJobQueueRunner _aiJobQueueRunner;
  final Uuid _uuid;

  @override
  Future<AiProcessingJobEntity> call(NoParams params) async {
    final job = await _aiJobRepository.createJob(
      CreateAiJobRequest(
        id: 'job_debug_${_uuid.v4()}',
        jobType: AiJobType.extractSource,
        priority: 10,
        maxAttempts: 2,
        inputJson: jsonEncode({
          'debug': true,
          'force_failure': true,
          'reason': 'manual_debug_queue_failure',
        }),
      ),
    );
    _aiJobQueueRunner.requestProcessing();
    return job;
  }
}
