import 'package:tag/core/DI/di.dart';
import 'package:tag/core/local_storage/database/tag_database.dart';
import 'package:tag/core/local_storage/file_store/local_file_store.dart';
import 'package:tag/core/platform/share_intake_service.dart';
import 'package:tag/features/ai_processing/domain/repositories/ai_job_repository.dart';
import 'package:tag/features/ai_processing/domain/services/ai_job_queue_runner.dart';
import 'package:tag/features/source_ingestion/data/data_sources/source_local_data_source.dart';
import 'package:tag/features/source_ingestion/data/repositories/source_repository_impl.dart';
import 'package:tag/features/source_ingestion/data/services/file_picker_manual_source_picker.dart';
import 'package:tag/features/source_ingestion/domain/repositories/source_repository.dart';
import 'package:tag/features/source_ingestion/domain/services/manual_source_picker.dart';
import 'package:tag/features/source_ingestion/domain/use_cases/create_text_source.dart';
import 'package:tag/features/source_ingestion/domain/use_cases/get_source_by_id.dart';
import 'package:tag/features/source_ingestion/domain/use_cases/get_source_preview.dart';
import 'package:tag/features/source_ingestion/domain/use_cases/import_image_source.dart';
import 'package:tag/features/source_ingestion/domain/use_cases/import_pending_shared_sources.dart';
import 'package:tag/features/source_ingestion/domain/use_cases/ingest_shared_source.dart';
import 'package:tag/features/source_ingestion/domain/use_cases/queue_source_processing.dart';
import 'package:tag/features/source_ingestion/domain/use_cases/store_source_file.dart';
import 'package:tag/features/source_ingestion/domain/use_cases/update_source_processing_state.dart';
import 'package:tag/features/source_ingestion/domain/use_cases/watch_recent_sources.dart';
import 'package:tag/features/source_ingestion/presentation/logic/source_ingestion_cubit.dart';
import 'package:tag/features/source_ingestion/presentation/logic/source_preview_cubit.dart';
import 'package:tag/features/spaces/domain/use_cases/record_space_view.dart';

void setUpSourceIngestionDependencies() {
  if (!locator.isRegistered<SourceLocalDataSource>()) {
    locator.registerLazySingleton<SourceLocalDataSource>(
      () => DriftSourceLocalDataSource(locator<TagDatabase>()),
    );
  }

  if (!locator.isRegistered<ManualSourcePicker>()) {
    locator.registerLazySingleton<ManualSourcePicker>(
      FilePickerManualSourcePicker.new,
    );
  }

  if (!locator.isRegistered<ShareIntakeService>()) {
    locator.registerLazySingleton<ShareIntakeService>(
      MethodChannelShareIntakeService.new,
    );
  }

  if (!locator.isRegistered<SourceRepository>()) {
    locator.registerLazySingleton<SourceRepository>(
      () => SourceRepositoryImpl(
        localDataSource: locator<SourceLocalDataSource>(),
      ),
    );
  }

  if (!locator.isRegistered<StoreSourceFile>()) {
    locator.registerLazySingleton(
      () => StoreSourceFile(locator<LocalFileStore>()),
    );
  }

  if (!locator.isRegistered<QueueSourceProcessing>()) {
    locator.registerLazySingleton(
      () => QueueSourceProcessing(
        aiJobRepositoryProvider: () => locator.isRegistered<AiJobRepository>()
            ? locator<AiJobRepository>()
            : null,
        aiJobQueueRunnerProvider: () => locator.isRegistered<AiJobQueueRunner>()
            ? locator<AiJobQueueRunner>()
            : null,
      ),
    );
  }

  if (!locator.isRegistered<ImportImageSource>()) {
    locator.registerLazySingleton(
      () => ImportImageSource(
        manualSourcePicker: locator<ManualSourcePicker>(),
        storeSourceFile: locator<StoreSourceFile>(),
        sourceRepository: locator<SourceRepository>(),
        queueSourceProcessing: locator<QueueSourceProcessing>(),
      ),
    );
  }

  if (!locator.isRegistered<CreateTextSource>()) {
    locator.registerLazySingleton(
      () => CreateTextSource(
        storeSourceFile: locator<StoreSourceFile>(),
        sourceRepository: locator<SourceRepository>(),
        queueSourceProcessing: locator<QueueSourceProcessing>(),
      ),
    );
  }

  if (!locator.isRegistered<IngestSharedSource>()) {
    locator.registerLazySingleton(
      () => IngestSharedSource(
        storeSourceFile: locator<StoreSourceFile>(),
        sourceRepository: locator<SourceRepository>(),
        queueSourceProcessing: locator<QueueSourceProcessing>(),
      ),
    );
  }

  if (!locator.isRegistered<ImportPendingSharedSources>()) {
    locator.registerLazySingleton(
      () => ImportPendingSharedSources(
        shareIntakeService: locator<ShareIntakeService>(),
        ingestSharedSource: locator<IngestSharedSource>(),
      ),
    );
  }

  if (!locator.isRegistered<GetSourceById>()) {
    locator.registerLazySingleton(
      () => GetSourceById(locator<SourceRepository>()),
    );
  }

  if (!locator.isRegistered<GetSourcePreview>()) {
    locator.registerLazySingleton(
      () => GetSourcePreview(locator<SourceRepository>()),
    );
  }

  if (!locator.isRegistered<WatchRecentSources>()) {
    locator.registerLazySingleton(
      () => WatchRecentSources(locator<SourceRepository>()),
    );
  }

  if (!locator.isRegistered<UpdateSourceProcessingState>()) {
    locator.registerLazySingleton(
      () => UpdateSourceProcessingState(locator<SourceRepository>()),
    );
  }

  if (!locator.isRegistered<SourceIngestionCubit>()) {
    locator.registerFactory(
      () => SourceIngestionCubit(
        importImageSource: locator<ImportImageSource>(),
        createTextSource: locator<CreateTextSource>(),
        watchRecentSources: locator<WatchRecentSources>(),
      ),
    );
  }

  if (!locator.isRegistered<SourcePreviewCubit>()) {
    locator.registerFactory(
      () => SourcePreviewCubit(
        getSourcePreview: locator<GetSourcePreview>(),
        recordSpaceView: locator<RecordSpaceView>(),
      ),
    );
  }
}
