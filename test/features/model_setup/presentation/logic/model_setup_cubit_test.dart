import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tag/core/ai/cactus/cactus_model_registry.dart';
import 'package:tag/core/ai/cactus/cactus_model_service.dart';
import 'package:tag/core/config/app_config.dart';
import 'package:tag/core/local_storage/database/data_sources/ai_model_assets_local_data_source.dart';
import 'package:tag/core/local_storage/database/tag_database.dart';
import 'package:tag/core/platform/device_storage_service.dart';
import 'package:tag/features/model_setup/data/repositories/model_setup_repository_impl.dart';
import 'package:tag/features/model_setup/domain/use_cases/discover_cactus_models.dart';
import 'package:tag/features/model_setup/domain/use_cases/download_cactus_model.dart';
import 'package:tag/features/model_setup/domain/use_cases/initialize_cactus_model.dart';
import 'package:tag/features/model_setup/domain/use_cases/load_cached_ai_models.dart';
import 'package:tag/features/model_setup/domain/use_cases/load_selected_embedding_model.dart';
import 'package:tag/features/model_setup/domain/use_cases/load_selected_primary_model.dart';
import 'package:tag/features/model_setup/domain/use_cases/select_embedding_model.dart';
import 'package:tag/features/model_setup/domain/use_cases/select_primary_model.dart';
import 'package:tag/features/model_setup/presentation/logic/model_setup_cubit.dart';

void main() {
  late TagDatabase database;
  late ModelSetupCubit cubit;

  setUp(() {
    database = TagDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await cubit.close();
    await database.close();
  });

  test('loads fake Gemma and embedding capability checks', () async {
    cubit = _buildCubit(
      database,
      FakeCactusModelService(
        models: [
          const LocalAiModelInfo(
            slug: CactusModelRegistry.primaryVisionToolModelSlug,
            displayName: 'Gemma 4 E2B IT',
            capabilities: {
              AiModelCapability.completion,
              AiModelCapability.tools,
              AiModelCapability.vision,
            },
            isDownloaded: true,
          ),
          const LocalAiModelInfo(
            slug: CactusModelRegistry.defaultEmbeddingModelSlug,
            displayName: 'Nomic Embed Text v2 MoE',
            capabilities: {AiModelCapability.embedding},
            isDownloaded: true,
          ),
        ],
      ),
    );

    await cubit.load();

    expect(cubit.state.status, ModelSetupStatus.ready);
    expect(cubit.state.effectivePrimaryCheck.isPassed, isTrue);
    expect(cubit.state.effectiveEmbeddingCheck.isPassed, isTrue);
  });

  test('keeps v1.14 Gemma capabilities visible during setup load', () async {
    cubit = _buildCubit(database, FakeCactusModelService(models: const []));

    expect(cubit.state.effectivePrimaryCheck.isPassed, isFalse);
    expect(cubit.state.effectivePrimaryCheck.isModelReady, isFalse);
    expect(
      cubit.state.primaryModel.supports(AiModelCapability.completion),
      isTrue,
    );
    expect(cubit.state.primaryModel.supports(AiModelCapability.tools), isTrue);
    expect(cubit.state.primaryModel.supports(AiModelCapability.vision), isTrue);
  });
}

ModelSetupCubit _buildCubit(
  TagDatabase database,
  CactusModelService cactusModelService,
) {
  final dataSource = DriftAiModelAssetsLocalDataSource(database);
  final repository = ModelSetupRepositoryImpl(
    appConfig: AppConfig(),
    cactusModelService: cactusModelService,
    deviceStorageService: const FakeDeviceStorageService(),
    localDataSource: dataSource,
  );

  return ModelSetupCubit(
    discoverCactusModels: DiscoverCactusModels(repository),
    loadCachedAiModels: LoadCachedAiModels(repository),
    downloadCactusModel: DownloadCactusModel(repository),
    initializeCactusModel: InitializeCactusModel(repository),
    loadSelectedEmbeddingModel: LoadSelectedEmbeddingModel(repository),
    loadSelectedPrimaryModel: LoadSelectedPrimaryModel(repository),
    selectEmbeddingModel: SelectEmbeddingModel(repository),
    selectPrimaryModel: SelectPrimaryModel(repository),
  );
}

class FakeCactusModelService implements CactusModelService {
  const FakeCactusModelService({required this.models});

  final List<LocalAiModelInfo> models;

  @override
  Future<List<LocalAiModelInfo>> getAvailableModels() async => models;

  @override
  Future<void> downloadModel(
    String slug, {
    void Function(ModelDownloadProgress progress)? onProgress,
  }) async {}

  @override
  Future<void> initializeModel(String slug) async {}

  @override
  Future<void> unloadModel(String slug) async {}

  @override
  Future<AiCompletionResult> complete({
    required String modelSlug,
    required List<AiChatMessage> messages,
    List<AiToolSchema> tools = const [],
    AiCompletionOptions options = const AiCompletionOptions(),
  }) {
    throw UnimplementedError();
  }

  @override
  Stream<String> streamComplete({
    required String modelSlug,
    required List<AiChatMessage> messages,
    List<AiToolSchema> tools = const [],
    AiCompletionOptions options = const AiCompletionOptions(),
  }) {
    throw UnimplementedError();
  }

  @override
  Future<AiEmbeddingResult> embedText({
    required String modelSlug,
    required String text,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<AiVisionResult> completeWithImage({
    required String modelSlug,
    required String imagePath,
    required List<AiChatMessage> messages,
    List<AiToolSchema> tools = const [],
    AiCompletionOptions options = const AiCompletionOptions(),
  }) {
    throw UnimplementedError();
  }
}

class FakeDeviceStorageService implements DeviceStorageService {
  const FakeDeviceStorageService();

  @override
  Future<DeviceStorageInfo> loadStorageInfo() async {
    return const DeviceStorageInfo(
      availableBytes: 4 * 1024 * 1024 * 1024,
      totalBytes: 64 * 1024 * 1024 * 1024,
    );
  }
}
