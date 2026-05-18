import 'package:tag/core/DI/di.dart';
import 'package:tag/core/ai/cactus/cactus_model_service.dart';
import 'package:tag/core/ai/orchestrator/ai_orchestrator.dart';
import 'package:tag/core/ai/rag/local_rag_service.dart';
import 'package:tag/core/local_storage/database/tag_database.dart';
import 'package:tag/core/notifications/local_notification_service.dart';
import 'package:tag/core/platform/local_text_recognition_service.dart';
import 'package:tag/features/ai_processing/data/data_sources/ai_job_local_data_source.dart';
import 'package:tag/features/ai_processing/data/processors/cactus_ai_job_processor.dart';
import 'package:tag/features/ai_processing/data/processors/fake_ai_job_processor.dart';
import 'package:tag/features/ai_processing/data/repositories/ai_job_repository_impl.dart';
import 'package:tag/features/ai_processing/domain/processors/ai_job_processor.dart';
import 'package:tag/features/ai_processing/domain/repositories/ai_job_repository.dart';
import 'package:tag/features/ai_processing/domain/services/ai_job_queue_runner.dart';
import 'package:tag/features/ai_processing/domain/services/local_ai_job_queue_runner.dart';
import 'package:tag/features/ai_processing/domain/use_cases/cancel_ai_job.dart';
import 'package:tag/features/ai_processing/domain/use_cases/process_next_ai_job.dart';
import 'package:tag/features/ai_processing/domain/use_cases/queue_debug_failing_ai_job.dart';
import 'package:tag/features/ai_processing/domain/use_cases/retry_ai_job.dart';
import 'package:tag/features/ai_processing/domain/use_cases/watch_ai_jobs.dart';
import 'package:tag/features/ai_processing/presentation/logic/ai_job_queue_cubit.dart';
import 'package:tag/features/cards/domain/use_cases/create_card_from_proposal.dart';
import 'package:tag/features/model_setup/domain/repositories/model_setup_repository.dart';
import 'package:tag/features/source_ingestion/domain/repositories/source_repository.dart';

void setUpAiProcessingDependencies() {
  if (!locator.isRegistered<AiJobLocalDataSource>()) {
    locator.registerLazySingleton<AiJobLocalDataSource>(
      () => DriftAiJobLocalDataSource(locator<TagDatabase>()),
    );
  }

  if (!locator.isRegistered<AiJobRepository>()) {
    locator.registerLazySingleton<AiJobRepository>(
      () =>
          AiJobRepositoryImpl(localDataSource: locator<AiJobLocalDataSource>()),
    );
  }

  if (!locator.isRegistered<FakeAiJobProcessor>()) {
    locator.registerLazySingleton(FakeAiJobProcessor.new);
  }

  if (!locator.isRegistered<AiOrchestrator>()) {
    locator.registerLazySingleton(
      () => AiOrchestrator(
        cactusModelService: locator<CactusModelService>(),
        localTextRecognitionService:
            locator.isRegistered<LocalTextRecognitionService>()
            ? locator<LocalTextRecognitionService>()
            : null,
        modelSlugProvider: locator.isRegistered<ModelSetupRepository>()
            ? () =>
                  locator<ModelSetupRepository>().loadSelectedPrimaryModelSlug()
            : null,
      ),
    );
  }

  if (!locator.isRegistered<CactusAiJobProcessor>() &&
      locator.isRegistered<SourceRepository>()) {
    locator.registerLazySingleton(
      () => CactusAiJobProcessor(
        aiOrchestrator: locator<AiOrchestrator>(),
        sourceRepository: locator<SourceRepository>(),
        createCardFromProposal: locator.isRegistered<CreateCardFromProposal>()
            ? locator<CreateCardFromProposal>()
            : null,
        notificationService: locator.isRegistered<LocalNotificationService>()
            ? locator<LocalNotificationService>()
            : null,
        localRagService: locator.isRegistered<LocalRagService>()
            ? locator<LocalRagService>()
            : null,
      ),
    );
  }

  if (!locator.isRegistered<AiJobProcessor>()) {
    locator.registerLazySingleton<AiJobProcessor>(() {
      if (locator.isRegistered<CactusAiJobProcessor>()) {
        return locator<CactusAiJobProcessor>();
      }

      return locator<FakeAiJobProcessor>();
    });
  }

  if (!locator.isRegistered<ProcessNextAiJob>()) {
    locator.registerLazySingleton(
      () => ProcessNextAiJob(
        aiJobRepository: locator<AiJobRepository>(),
        aiJobProcessor: locator<AiJobProcessor>(),
        sourceRepository: locator.isRegistered<SourceRepository>()
            ? locator<SourceRepository>()
            : null,
      ),
    );
  }

  if (!locator.isRegistered<AiJobQueueRunner>()) {
    locator.registerLazySingleton<AiJobQueueRunner>(
      () =>
          LocalAiJobQueueRunner(processNextAiJob: locator<ProcessNextAiJob>()),
    );
  }

  if (!locator.isRegistered<WatchAiJobs>()) {
    locator.registerLazySingleton(
      () => WatchAiJobs(locator<AiJobRepository>()),
    );
  }

  if (!locator.isRegistered<RetryAiJob>()) {
    locator.registerLazySingleton(
      () => RetryAiJob(
        aiJobRepository: locator<AiJobRepository>(),
        aiJobQueueRunner: locator<AiJobQueueRunner>(),
      ),
    );
  }

  if (!locator.isRegistered<CancelAiJob>()) {
    locator.registerLazySingleton(
      () => CancelAiJob(locator<AiJobRepository>()),
    );
  }

  if (!locator.isRegistered<QueueDebugFailingAiJob>()) {
    locator.registerLazySingleton(
      () => QueueDebugFailingAiJob(
        aiJobRepository: locator<AiJobRepository>(),
        aiJobQueueRunner: locator<AiJobQueueRunner>(),
      ),
    );
  }

  if (!locator.isRegistered<AiJobQueueCubit>()) {
    locator.registerFactory(
      () => AiJobQueueCubit(
        watchAiJobs: locator<WatchAiJobs>(),
        retryAiJob: locator<RetryAiJob>(),
        cancelAiJob: locator<CancelAiJob>(),
        queueDebugFailingAiJob: locator<QueueDebugFailingAiJob>(),
      ),
    );
  }
}
