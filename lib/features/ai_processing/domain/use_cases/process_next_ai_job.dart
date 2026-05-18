import 'package:tag/core/use_cases/use_cases.dart';
import 'package:tag/features/ai_processing/domain/entities/ai_processing_job_entity.dart';
import 'package:tag/features/ai_processing/domain/processors/ai_job_processor.dart';
import 'package:tag/features/ai_processing/domain/repositories/ai_job_repository.dart';
import 'package:tag/features/source_ingestion/domain/entities/source_item_entity.dart';
import 'package:tag/features/source_ingestion/domain/repositories/source_repository.dart';

class ProcessNextAiJob with UseCases<AiProcessingJobEntity?, NoParams> {
  const ProcessNextAiJob({
    required AiJobRepository aiJobRepository,
    required AiJobProcessor aiJobProcessor,
    SourceRepository? sourceRepository,
  }) : _aiJobRepository = aiJobRepository,
       _aiJobProcessor = aiJobProcessor,
       _sourceRepository = sourceRepository;

  final AiJobRepository _aiJobRepository;
  final AiJobProcessor _aiJobProcessor;
  final SourceRepository? _sourceRepository;

  @override
  Future<AiProcessingJobEntity?> call(NoParams params) async {
    final nextJob = await _aiJobRepository.getNextRunnableJob();
    if (nextJob == null) {
      return null;
    }

    final runningJob = await _aiJobRepository.startJob(nextJob.id);
    if (runningJob == null) {
      return null;
    }

    await _updateSourceState(
      runningJob,
      processingState: SourceProcessingState.extracting,
    );

    try {
      final result = await _aiJobProcessor.process(runningJob);
      final completedJob = await _aiJobRepository.completeJob(
        id: runningJob.id,
        outputJson: result.outputJson,
        modelSlug: result.modelSlug,
      );
      await _updateSourceState(
        completedJob,
        processingState: SourceProcessingState.completed,
      );

      return completedJob;
    } on AiJobProcessingDeferredException catch (error) {
      final deferredJob = await _aiJobRepository.deferJob(
        id: runningJob.id,
        errorMessage: error.message,
      );
      await _updateSourceState(
        deferredJob,
        processingState: SourceProcessingState.saved,
        failureReason: error.message,
      );

      return null;
    } on Object catch (error) {
      final failedJob = await _aiJobRepository.failJob(
        id: runningJob.id,
        errorMessage: _messageFor(error),
      );
      await _updateSourceState(
        failedJob,
        processingState: SourceProcessingState.failed,
        failureReason: failedJob.errorMessage,
      );

      return failedJob;
    }
  }

  Future<void> _updateSourceState(
    AiProcessingJobEntity job, {
    required SourceProcessingState processingState,
    String? failureReason,
  }) async {
    final sourceRepository = _sourceRepository;
    final sourceId = job.sourceId;

    if (sourceRepository == null ||
        sourceId == null ||
        job.jobType != AiJobType.extractSource) {
      return;
    }

    await sourceRepository.updateProcessingState(
      sourceId: sourceId,
      processingState: processingState,
      failureReason: failureReason,
    );
  }

  String _messageFor(Object error) {
    if (error is AiJobProcessingException) {
      return error.message;
    }

    return error.toString();
  }
}
