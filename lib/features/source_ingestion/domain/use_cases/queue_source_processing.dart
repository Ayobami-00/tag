import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:tag/core/use_cases/use_cases.dart';
import 'package:tag/features/ai_processing/domain/entities/ai_processing_job_entity.dart';
import 'package:tag/features/ai_processing/domain/repositories/ai_job_repository.dart';
import 'package:tag/features/ai_processing/domain/services/ai_job_queue_runner.dart';
import 'package:uuid/uuid.dart';

class QueueSourceProcessingParams extends Equatable {
  const QueueSourceProcessingParams(this.sourceId);

  final String sourceId;

  @override
  List<Object?> get props => [sourceId];
}

typedef AiJobIdFactory = String Function();
typedef AiJobRepositoryProvider = AiJobRepository? Function();
typedef AiJobQueueRunnerProvider = AiJobQueueRunner? Function();

String defaultAiJobIdFactory() => 'job_${const Uuid().v4()}';

class QueueSourceProcessing with UseCases<void, QueueSourceProcessingParams> {
  QueueSourceProcessing({
    AiJobRepository? aiJobRepository,
    AiJobQueueRunner? aiJobQueueRunner,
    AiJobRepositoryProvider? aiJobRepositoryProvider,
    AiJobQueueRunnerProvider? aiJobQueueRunnerProvider,
    AiJobIdFactory? aiJobIdFactory,
    Duration processingKickoffDelay = const Duration(milliseconds: 250),
  }) : _aiJobRepositoryProvider =
           aiJobRepositoryProvider ?? (() => aiJobRepository),
       _aiJobQueueRunnerProvider =
           aiJobQueueRunnerProvider ?? (() => aiJobQueueRunner),
       _aiJobIdFactory = aiJobIdFactory ?? defaultAiJobIdFactory,
       _processingKickoffDelay = processingKickoffDelay;

  final AiJobRepositoryProvider _aiJobRepositoryProvider;
  final AiJobQueueRunnerProvider _aiJobQueueRunnerProvider;
  final AiJobIdFactory _aiJobIdFactory;
  final Duration _processingKickoffDelay;

  @override
  Future<void> call(QueueSourceProcessingParams params) async {
    final aiJobRepository = _aiJobRepositoryProvider();
    if (aiJobRepository == null) {
      return;
    }

    await aiJobRepository.createJob(
      CreateAiJobRequest(
        id: _aiJobIdFactory(),
        jobType: AiJobType.extractSource,
        sourceId: params.sourceId,
        inputJson: jsonEncode({
          'source_id': params.sourceId,
          'pipeline': 'source_ingestion',
        }),
      ),
    );
    if (_processingKickoffDelay > Duration.zero) {
      await Future<void>.delayed(_processingKickoffDelay);
    }
    _aiJobQueueRunnerProvider()?.requestProcessing();
  }
}
