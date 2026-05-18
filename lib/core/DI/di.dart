import 'package:get_it/get_it.dart';
import 'package:tag/core/ai/cactus/cactus_model_service.dart';
import 'package:tag/core/ai/cactus/cactus_model_service_impl.dart';
import 'package:tag/core/config/app_config.dart';
import 'package:tag/core/local_storage/database/data_sources/ai_model_assets_local_data_source.dart';
import 'package:tag/core/local_storage/database/data_sources/card_local_data_source.dart';
import 'package:tag/core/local_storage/database/database_health_check.dart';
import 'package:tag/core/local_storage/database/tag_database.dart';
import 'package:tag/core/local_storage/file_store/local_file_store.dart';
import 'package:tag/core/local_storage/file_store/local_file_store_impl.dart';
import 'package:tag/core/navigation/navigation_service.dart';
import 'package:tag/core/notifications/local_notification_permission_service.dart';
import 'package:tag/core/notifications/local_notification_service.dart';
import 'package:tag/core/notifications/local_notification_service_impl.dart';
import 'package:tag/core/notifications/notification_policy.dart';
import 'package:tag/core/platform/device_storage_service.dart';
import 'package:tag/core/platform/local_text_recognition_service.dart';
import 'package:tag/core/startup/app_cubit.dart';
import 'package:tag/features/ai_processing/DI/di.dart';
import 'package:tag/features/cards/DI/di.dart';
import 'package:tag/features/ai_processing/domain/services/ai_job_queue_runner.dart';
import 'package:tag/features/chat/DI/di.dart';
import 'package:tag/features/model_setup/DI/di.dart';
import 'package:tag/features/model_setup/domain/use_cases/prepare_required_local_models.dart';
import 'package:tag/features/onboarding/DI/di.dart';
import 'package:tag/features/onboarding/domain/use_cases/load_user_profile.dart';
import 'package:tag/features/rag/DI/di.dart';
import 'package:tag/features/spaces/DI/di.dart';
import 'package:tag/features/source_ingestion/DI/di.dart';
import 'package:tag/features/today/DI/di.dart';

final GetIt locator = GetIt.I;

void setupBaseDI({
  AppConfig? appConfig,
  TagDatabase? tagDatabase,
  LocalFileStore? localFileStore,
  CactusModelService? cactusModelService,
  DeviceStorageService? deviceStorageService,
  LocalTextRecognitionService? localTextRecognitionService,
}) {
  CactusModelServiceImpl.configureLocalOnly();

  if (!locator.isRegistered<AppConfig>()) {
    if (appConfig != null) {
      locator.registerSingleton<AppConfig>(appConfig);
    } else {
      locator.registerLazySingleton(AppConfig.new);
    }
  }

  if (!locator.isRegistered<TagDatabase>()) {
    if (tagDatabase != null) {
      locator.registerSingleton<TagDatabase>(
        tagDatabase,
        dispose: (database) => database.close(),
      );
    } else {
      locator.registerLazySingleton<TagDatabase>(
        TagDatabase.new,
        dispose: (database) => database.close(),
      );
    }
  }

  if (!locator.isRegistered<DatabaseHealthCheck>()) {
    locator.registerLazySingleton<DatabaseHealthCheck>(
      () => DriftDatabaseHealthCheck(locator<TagDatabase>()),
    );
  }

  if (!locator.isRegistered<LocalFileStore>()) {
    if (localFileStore != null) {
      locator.registerSingleton<LocalFileStore>(localFileStore);
    } else {
      locator.registerLazySingleton<LocalFileStore>(LocalFileStoreImpl.new);
    }
  }

  if (!locator.isRegistered<CardLocalDataSource>()) {
    locator.registerLazySingleton<CardLocalDataSource>(
      () => DriftCardLocalDataSource(locator<TagDatabase>()),
    );
  }

  if (!locator.isRegistered<AiModelAssetsLocalDataSource>()) {
    locator.registerLazySingleton<AiModelAssetsLocalDataSource>(
      () => DriftAiModelAssetsLocalDataSource(locator<TagDatabase>()),
    );
  }

  if (!locator.isRegistered<CactusModelService>()) {
    if (cactusModelService != null) {
      locator.registerSingleton<CactusModelService>(cactusModelService);
    } else {
      locator.registerLazySingleton<CactusModelService>(
        CactusModelServiceImpl.new,
      );
    }
  }

  if (!locator.isRegistered<DeviceStorageService>()) {
    if (deviceStorageService != null) {
      locator.registerSingleton<DeviceStorageService>(deviceStorageService);
    } else {
      locator.registerLazySingleton<DeviceStorageService>(
        MethodChannelDeviceStorageService.new,
      );
    }
  }

  if (!locator.isRegistered<LocalTextRecognitionService>()) {
    if (localTextRecognitionService != null) {
      locator.registerSingleton<LocalTextRecognitionService>(
        localTextRecognitionService,
      );
    } else {
      locator.registerLazySingleton<LocalTextRecognitionService>(
        MethodChannelLocalTextRecognitionService.new,
      );
    }
  }

  if (!locator.isRegistered<NavigationService>()) {
    locator.registerLazySingleton(NavigationService.new);
  }

  if (!locator.isRegistered<NotificationPolicy>()) {
    locator.registerLazySingleton(NotificationPolicy.new);
  }

  if (!locator.isRegistered<LocalNotificationService>()) {
    locator.registerLazySingleton<LocalNotificationService>(
      () => LocalNotificationServiceImpl(
        database: locator<TagDatabase>(),
        policy: locator<NotificationPolicy>(),
      ),
    );
  }
}

void setUpAppLocator({
  AppConfig? appConfig,
  TagDatabase? tagDatabase,
  LocalFileStore? localFileStore,
  CactusModelService? cactusModelService,
  DeviceStorageService? deviceStorageService,
  LocalTextRecognitionService? localTextRecognitionService,
  LocalNotificationPermissionService? notificationPermissionService,
}) {
  setupBaseDI(
    appConfig: appConfig,
    tagDatabase: tagDatabase,
    localFileStore: localFileStore,
    cactusModelService: cactusModelService,
    deviceStorageService: deviceStorageService,
    localTextRecognitionService: localTextRecognitionService,
  );
  setUpOnboardingDependencies(
    notificationPermissionService: notificationPermissionService,
  );
  setUpModelSetupDependencies();
  setUpCardsDependencies();
  setUpSpacesDependencies();
  setUpSourceIngestionDependencies();
  setUpRagDependencies();
  setUpChatDependencies();
  setUpAiProcessingDependencies();
  setUpTodayDependencies();

  if (!locator.isRegistered<AppCubit>()) {
    locator.registerFactory(
      () => AppCubit(
        appConfig: locator<AppConfig>(),
        loadUserProfile: locator<LoadUserProfile>(),
        prepareRequiredLocalModels: locator<PrepareRequiredLocalModels>(),
        aiJobQueueRunner: locator<AiJobQueueRunner>(),
      ),
    );
  }
}
