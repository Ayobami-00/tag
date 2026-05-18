import 'package:tag/core/DI/di.dart';
import 'package:tag/core/ai/cactus/cactus_model_service.dart';
import 'package:tag/core/config/app_config.dart';
import 'package:tag/core/local_storage/database/data_sources/ai_model_assets_local_data_source.dart';
import 'package:tag/core/local_storage/database/tag_database.dart';
import 'package:tag/core/platform/device_storage_service.dart';
import 'package:tag/features/model_setup/data/repositories/model_setup_repository_impl.dart';
import 'package:tag/features/model_setup/domain/repositories/model_setup_repository.dart';
import 'package:tag/features/model_setup/domain/use_cases/discover_cactus_models.dart';
import 'package:tag/features/model_setup/domain/use_cases/download_cactus_model.dart';
import 'package:tag/features/model_setup/domain/use_cases/initialize_cactus_model.dart';
import 'package:tag/features/model_setup/domain/use_cases/load_cached_ai_models.dart';
import 'package:tag/features/model_setup/domain/use_cases/load_selected_embedding_model.dart';
import 'package:tag/features/model_setup/domain/use_cases/load_selected_primary_model.dart';
import 'package:tag/features/model_setup/domain/use_cases/prepare_required_local_models.dart';
import 'package:tag/features/model_setup/domain/use_cases/select_embedding_model.dart';
import 'package:tag/features/model_setup/domain/use_cases/select_primary_model.dart';
import 'package:tag/features/model_setup/presentation/logic/model_setup_cubit.dart';

void setUpModelSetupDependencies() {
  if (!locator.isRegistered<AiModelAssetsLocalDataSource>()) {
    locator.registerLazySingleton<AiModelAssetsLocalDataSource>(
      () => DriftAiModelAssetsLocalDataSource(locator<TagDatabase>()),
    );
  }

  if (!locator.isRegistered<ModelSetupRepository>()) {
    locator.registerLazySingleton<ModelSetupRepository>(
      () => ModelSetupRepositoryImpl(
        appConfig: locator<AppConfig>(),
        cactusModelService: locator<CactusModelService>(),
        deviceStorageService: locator<DeviceStorageService>(),
        localDataSource: locator<AiModelAssetsLocalDataSource>(),
      ),
    );
  }

  if (!locator.isRegistered<DiscoverCactusModels>()) {
    locator.registerLazySingleton(
      () => DiscoverCactusModels(locator<ModelSetupRepository>()),
    );
  }

  if (!locator.isRegistered<LoadCachedAiModels>()) {
    locator.registerLazySingleton(
      () => LoadCachedAiModels(locator<ModelSetupRepository>()),
    );
  }

  if (!locator.isRegistered<PrepareRequiredLocalModels>()) {
    locator.registerLazySingleton(
      () => PrepareRequiredLocalModels(locator<ModelSetupRepository>()),
    );
  }

  if (!locator.isRegistered<DownloadCactusModel>()) {
    locator.registerLazySingleton(
      () => DownloadCactusModel(locator<ModelSetupRepository>()),
    );
  }

  if (!locator.isRegistered<InitializeCactusModel>()) {
    locator.registerLazySingleton(
      () => InitializeCactusModel(locator<ModelSetupRepository>()),
    );
  }

  if (!locator.isRegistered<LoadSelectedEmbeddingModel>()) {
    locator.registerLazySingleton(
      () => LoadSelectedEmbeddingModel(locator<ModelSetupRepository>()),
    );
  }

  if (!locator.isRegistered<LoadSelectedPrimaryModel>()) {
    locator.registerLazySingleton(
      () => LoadSelectedPrimaryModel(locator<ModelSetupRepository>()),
    );
  }

  if (!locator.isRegistered<SelectEmbeddingModel>()) {
    locator.registerLazySingleton(
      () => SelectEmbeddingModel(locator<ModelSetupRepository>()),
    );
  }

  if (!locator.isRegistered<SelectPrimaryModel>()) {
    locator.registerLazySingleton(
      () => SelectPrimaryModel(locator<ModelSetupRepository>()),
    );
  }

  if (!locator.isRegistered<ModelSetupCubit>()) {
    locator.registerFactory(
      () => ModelSetupCubit(
        discoverCactusModels: locator<DiscoverCactusModels>(),
        loadCachedAiModels: locator<LoadCachedAiModels>(),
        downloadCactusModel: locator<DownloadCactusModel>(),
        initializeCactusModel: locator<InitializeCactusModel>(),
        loadSelectedEmbeddingModel: locator<LoadSelectedEmbeddingModel>(),
        loadSelectedPrimaryModel: locator<LoadSelectedPrimaryModel>(),
        selectEmbeddingModel: locator<SelectEmbeddingModel>(),
        selectPrimaryModel: locator<SelectPrimaryModel>(),
      ),
    );
  }
}
