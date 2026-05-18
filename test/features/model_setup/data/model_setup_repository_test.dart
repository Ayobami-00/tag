import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tag/core/ai/cactus/cactus_model_registry.dart';
import 'package:tag/core/ai/cactus/cactus_model_service.dart';
import 'package:tag/core/config/app_config.dart';
import 'package:tag/core/error/app_error.dart';
import 'package:tag/core/local_storage/database/data_sources/ai_model_assets_local_data_source.dart';
import 'package:tag/core/local_storage/database/tag_database.dart';
import 'package:tag/core/platform/device_storage_service.dart';
import 'package:tag/features/model_setup/data/repositories/model_setup_repository_impl.dart';

const _compactStorageInfo = DeviceStorageInfo(
  availableBytes: 4 * 1024 * 1024 * 1024,
  totalBytes: 64 * 1024 * 1024 * 1024,
);

const _roomyStorageInfo = DeviceStorageInfo(
  availableBytes: 16 * 1024 * 1024 * 1024,
  totalBytes: 256 * 1024 * 1024 * 1024,
);

void main() {
  late TagDatabase database;
  late DriftAiModelAssetsLocalDataSource dataSource;
  late FakeCactusModelService cactusService;
  late ModelSetupRepositoryImpl repository;

  setUp(() {
    database = TagDatabase.forTesting(NativeDatabase.memory());
    dataSource = DriftAiModelAssetsLocalDataSource(
      database,
      now: () => DateTime.utc(2026, 5, 9, 12),
    );
    cactusService = FakeCactusModelService(
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
        ),
      ],
    );
    repository = ModelSetupRepositoryImpl(
      appConfig: AppConfig(),
      cactusModelService: cactusService,
      deviceStorageService: const FakeDeviceStorageService(_compactStorageInfo),
      localDataSource: dataSource,
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('discovers fake Cactus models and persists metadata', () async {
    final models = await repository.discoverModels();

    expect(cactusService.discoveryCount, 1);
    expect(
      models.map((model) => model.slug),
      contains(CactusModelRegistry.primaryVisionToolModelSlug),
    );

    final storedPrimary = await dataSource.loadModel(
      CactusModelRegistry.primaryVisionToolModelSlug,
    );

    expect(storedPrimary, isNotNull);
    expect(storedPrimary!.isDownloaded, isTrue);
    expect(storedPrimary.supports(AiModelCapability.tools), isTrue);
    expect(storedPrimary.supports(AiModelCapability.vision), isTrue);
  });

  test('download and initialize update local model asset state', () async {
    await repository.discoverModels();

    await repository.downloadModel(
      CactusModelRegistry.defaultEmbeddingModelSlug,
    );
    await repository.initializeModel(
      CactusModelRegistry.defaultEmbeddingModelSlug,
    );

    final embedding = await dataSource.loadModel(
      CactusModelRegistry.defaultEmbeddingModelSlug,
    );

    expect(embedding!.isDownloaded, isTrue);
    expect(embedding.isInitialized, isTrue);
    expect(embedding.downloadStatus, AiModelDownloadStatus.ready);
    expect(embedding.downloadProgress, 1);
    expect(cactusService.downloadedSlugs, [
      CactusModelRegistry.defaultEmbeddingModelSlug,
    ]);
    expect(cactusService.initializedSlugs, [
      CactusModelRegistry.defaultEmbeddingModelSlug,
    ]);
  });

  test(
    'stores embedding model selection for compact and quality modes',
    () async {
      await repository.selectEmbeddingModel(
        CactusModelRegistry.qualityEmbeddingModelSlug,
      );

      expect(
        await repository.loadSelectedEmbeddingModelSlug(),
        CactusModelRegistry.qualityEmbeddingModelSlug,
      );
    },
  );

  test('quiet preparation uses compact embedding on smaller devices', () async {
    cactusService = FakeCactusModelService(
      models: [
        const LocalAiModelInfo(
          slug: CactusModelRegistry.primaryVisionToolModelSlug,
          displayName: 'Gemma 4 E2B IT',
          capabilities: {
            AiModelCapability.completion,
            AiModelCapability.tools,
            AiModelCapability.vision,
          },
        ),
        const LocalAiModelInfo(
          slug: CactusModelRegistry.defaultEmbeddingModelSlug,
          displayName: 'Nomic Embed Text v2 MoE',
          capabilities: {AiModelCapability.embedding},
        ),
        const LocalAiModelInfo(
          slug: CactusModelRegistry.qualityEmbeddingModelSlug,
          displayName: 'Qwen3 Embedding 0.6B',
          capabilities: {AiModelCapability.embedding},
        ),
      ],
    );
    repository = ModelSetupRepositoryImpl(
      appConfig: AppConfig(),
      cactusModelService: cactusService,
      deviceStorageService: const FakeDeviceStorageService(_compactStorageInfo),
      localDataSource: dataSource,
    );

    await repository.prepareRequiredModels();

    expect(cactusService.downloadedSlugs, [
      CactusModelRegistry.primaryVisionToolModelSlug,
      CactusModelRegistry.defaultEmbeddingModelSlug,
    ]);
    expect(
      cactusService.downloadedSlugs,
      isNot(contains(CactusModelRegistry.qualityEmbeddingModelSlug)),
    );
  });

  test('quiet preparation uses Qwen embedding on larger devices', () async {
    cactusService = FakeCactusModelService(
      models: [
        const LocalAiModelInfo(
          slug: CactusModelRegistry.primaryVisionToolModelSlug,
          displayName: 'Gemma 4 E2B IT',
          capabilities: {
            AiModelCapability.completion,
            AiModelCapability.tools,
            AiModelCapability.vision,
          },
        ),
        const LocalAiModelInfo(
          slug: CactusModelRegistry.defaultEmbeddingModelSlug,
          displayName: 'Nomic Embed Text v2 MoE',
          capabilities: {AiModelCapability.embedding},
        ),
        const LocalAiModelInfo(
          slug: CactusModelRegistry.qualityEmbeddingModelSlug,
          displayName: 'Qwen3 Embedding 0.6B',
          capabilities: {AiModelCapability.embedding},
        ),
      ],
    );
    repository = ModelSetupRepositoryImpl(
      appConfig: AppConfig(),
      cactusModelService: cactusService,
      deviceStorageService: const FakeDeviceStorageService(_roomyStorageInfo),
      localDataSource: dataSource,
    );

    await repository.prepareRequiredModels();

    expect(cactusService.downloadedSlugs, [
      CactusModelRegistry.primaryVisionToolModelSlug,
      CactusModelRegistry.qualityEmbeddingModelSlug,
    ]);
    expect(
      cactusService.downloadedSlugs,
      isNot(contains(CactusModelRegistry.defaultEmbeddingModelSlug)),
    );
  });

  test(
    'quiet preparation downloads Qwen on roomy devices through direct asset metadata',
    () async {
      cactusService = FakeCactusModelService(
        models: [
          const LocalAiModelInfo(
            slug: CactusModelRegistry.primaryVisionToolModelSlug,
            displayName: 'Gemma 4 E2B IT',
            capabilities: {
              AiModelCapability.completion,
              AiModelCapability.tools,
              AiModelCapability.vision,
            },
          ),
          const LocalAiModelInfo(
            slug: CactusModelRegistry.defaultEmbeddingModelSlug,
            displayName: 'Nomic Embed Text v2 MoE',
            capabilities: {AiModelCapability.embedding},
          ),
        ],
      );
      repository = ModelSetupRepositoryImpl(
        appConfig: AppConfig(),
        cactusModelService: cactusService,
        deviceStorageService: const FakeDeviceStorageService(_roomyStorageInfo),
        localDataSource: dataSource,
      );

      await repository.prepareRequiredModels();

      expect(cactusService.downloadedSlugs, [
        CactusModelRegistry.primaryVisionToolModelSlug,
        CactusModelRegistry.qualityEmbeddingModelSlug,
      ]);
      expect(
        await repository.loadSelectedEmbeddingModelSlug(),
        CactusModelRegistry.qualityEmbeddingModelSlug,
      );
    },
  );

  test('quiet preparation starts required downloads in parallel', () async {
    final parallelService = ParallelProbeCactusModelService(
      models: const [
        LocalAiModelInfo(
          slug: CactusModelRegistry.primaryVisionToolModelSlug,
          displayName: 'LFM2 VL 450M',
          capabilities: {
            AiModelCapability.completion,
            AiModelCapability.tools,
            AiModelCapability.vision,
          },
        ),
        LocalAiModelInfo(
          slug: CactusModelRegistry.qualityEmbeddingModelSlug,
          displayName: 'Qwen3 Embedding 0.6B',
          capabilities: {AiModelCapability.embedding},
        ),
      ],
      expectedStarts: 2,
    );
    repository = ModelSetupRepositoryImpl(
      appConfig: AppConfig(),
      cactusModelService: parallelService,
      deviceStorageService: const FakeDeviceStorageService(_roomyStorageInfo),
      localDataSource: dataSource,
    );

    final preparation = repository.prepareRequiredModels();
    await parallelService.waitForAllDownloadsToStart();

    expect(parallelService.startedSlugs.toSet(), {
      CactusModelRegistry.primaryVisionToolModelSlug,
      CactusModelRegistry.qualityEmbeddingModelSlug,
    });
    expect(parallelService.maxConcurrentDownloads, 2);
    expect(parallelService.completedSlugs, isEmpty);

    parallelService.completeAllDownloads();
    await preparation;

    expect(parallelService.completedSlugs.toSet(), {
      CactusModelRegistry.primaryVisionToolModelSlug,
      CactusModelRegistry.qualityEmbeddingModelSlug,
    });
  });

  test('download progress is stored for setup visibility', () async {
    cactusService.progressEvents = const [
      ModelDownloadProgress(
        slug: CactusModelRegistry.defaultEmbeddingModelSlug,
        progress: 0.25,
        statusMessage: 'Downloaded 82 MB...',
      ),
      ModelDownloadProgress(
        slug: CactusModelRegistry.defaultEmbeddingModelSlug,
        progress: 0.75,
        statusMessage: 'Downloaded 246 MB...',
      ),
    ];
    await repository.discoverModels();

    await repository.downloadModel(
      CactusModelRegistry.defaultEmbeddingModelSlug,
    );

    final embedding = await dataSource.loadModel(
      CactusModelRegistry.defaultEmbeddingModelSlug,
    );

    expect(embedding!.downloadStatus, AiModelDownloadStatus.downloaded);
    expect(embedding.downloadProgress, 1);
    expect(embedding.downloadStatusMessage, 'Download complete.');
  });

  test('download continues when a transient progress write fails', () async {
    cactusService.progressEvents = const [
      ModelDownloadProgress(
        slug: CactusModelRegistry.defaultEmbeddingModelSlug,
        progress: 0.25,
        statusMessage: 'Downloaded 82 MB...',
      ),
      ModelDownloadProgress(
        slug: CactusModelRegistry.defaultEmbeddingModelSlug,
        progress: 0.75,
        statusMessage: 'Downloaded 246 MB...',
      ),
    ];
    final flakyDataSource = _FlakyProgressDataSource(dataSource);
    repository = ModelSetupRepositoryImpl(
      appConfig: AppConfig(),
      cactusModelService: cactusService,
      deviceStorageService: const FakeDeviceStorageService(_compactStorageInfo),
      localDataSource: flakyDataSource,
    );
    await repository.discoverModels();

    await repository.downloadModel(
      CactusModelRegistry.defaultEmbeddingModelSlug,
    );

    final embedding = await dataSource.loadModel(
      CactusModelRegistry.defaultEmbeddingModelSlug,
    );

    expect(flakyDataSource.progressWriteAttempts, 2);
    expect(embedding!.downloadStatus, AiModelDownloadStatus.downloaded);
    expect(embedding.downloadProgress, 1);
    expect(embedding.downloadStatusMessage, 'Download complete.');
  });

  test('initialization failure keeps downloaded state visible', () async {
    await repository.discoverModels();
    cactusService.initializationError = AppError(
      'Cactus model initialization failed for gemma.',
    );

    await expectLater(
      repository.initializeModel(
        CactusModelRegistry.primaryVisionToolModelSlug,
      ),
      throwsA(isA<AppError>()),
    );

    final primary = await dataSource.loadModel(
      CactusModelRegistry.primaryVisionToolModelSlug,
    );

    expect(primary!.isDownloaded, isTrue);
    expect(primary.isInitialized, isFalse);
    expect(primary.downloadStatus, AiModelDownloadStatus.initializationFailed);
    expect(primary.failureReason, contains('initialization failed'));
  });

  test(
    'primary Gemma target remains downloadable through direct asset metadata',
    () async {
      cactusService = FakeCactusModelService(models: const []);
      repository = ModelSetupRepositoryImpl(
        appConfig: AppConfig(),
        cactusModelService: cactusService,
        deviceStorageService: const FakeDeviceStorageService(
          _compactStorageInfo,
        ),
        localDataSource: dataSource,
      );

      await repository.discoverModels();

      final primary = await dataSource.loadModel(
        CactusModelRegistry.primaryVisionToolModelSlug,
      );

      expect(primary!.supports(AiModelCapability.completion), isTrue);
      expect(primary.supports(AiModelCapability.tools), isTrue);
      expect(primary.supports(AiModelCapability.vision), isTrue);
      expect(primary.failureReason, isNull);
      expect(primary.downloadStatusMessage, contains('Cactus-Compute'));
    },
  );

  test('refresh repairs stale old-catalog rows for direct v1.14 assets', () async {
    await dataSource.upsertModel(
      const LocalAiModelInfo(
        slug: CactusModelRegistry.primaryVisionToolModelSlug,
        displayName: 'Gemma 4 E2B IT',
        capabilities: {},
        failureReason:
            'gemma-4-E2B-it is not available from the local Cactus model registry.',
        downloadStatus: AiModelDownloadStatus.failed,
        downloadStatusMessage:
            'gemma-4-E2B-it is not available from the local Cactus model registry.',
      ),
    );

    cactusService = FakeCactusModelService(models: const []);
    repository = ModelSetupRepositoryImpl(
      appConfig: AppConfig(),
      cactusModelService: cactusService,
      deviceStorageService: const FakeDeviceStorageService(_compactStorageInfo),
      localDataSource: dataSource,
    );

    await repository.discoverModels();

    final primary = await dataSource.loadModel(
      CactusModelRegistry.primaryVisionToolModelSlug,
    );

    expect(primary!.supports(AiModelCapability.completion), isTrue);
    expect(primary.supports(AiModelCapability.tools), isTrue);
    expect(primary.supports(AiModelCapability.vision), isTrue);
    expect(primary.downloadStatus, AiModelDownloadStatus.notDownloaded);
    expect(primary.failureReason, isNull);
    expect(primary.downloadStatusMessage, contains('Cactus-Compute'));
  });

  test('unavailable configured model gets a clear failure state', () async {
    const missingSlug = 'missing-model';
    cactusService = FakeCactusModelService(models: const []);
    repository = ModelSetupRepositoryImpl(
      appConfig: AppConfig(),
      cactusModelService: cactusService,
      deviceStorageService: const FakeDeviceStorageService(_compactStorageInfo),
      localDataSource: dataSource,
    );
    await repository.discoverModels();

    await expectLater(
      repository.downloadModel(missingSlug),
      throwsA(isA<AppError>()),
    );

    final primary = await dataSource.loadModel(missingSlug);

    expect(primary!.downloadStatus, AiModelDownloadStatus.failed);
    expect(primary.failureReason, contains('local Cactus model registry'));
  });
}

class _FlakyProgressDataSource implements AiModelAssetsLocalDataSource {
  _FlakyProgressDataSource(this._delegate);

  final AiModelAssetsLocalDataSource _delegate;
  int progressWriteAttempts = 0;

  @override
  Future<List<LocalAiModelInfo>> loadModels() => _delegate.loadModels();

  @override
  Future<LocalAiModelInfo?> loadModel(String slug) {
    return _delegate.loadModel(slug);
  }

  @override
  Future<void> upsertModel(LocalAiModelInfo model) {
    return _delegate.upsertModel(model);
  }

  @override
  Future<void> upsertModels(List<LocalAiModelInfo> models) {
    return _delegate.upsertModels(models);
  }

  @override
  Future<void> markModelDownloadStarted(String slug) {
    return _delegate.markModelDownloadStarted(slug);
  }

  @override
  Future<void> updateModelDownloadProgress(ModelDownloadProgress progress) {
    progressWriteAttempts++;
    if (progressWriteAttempts == 1) {
      throw StateError('database is locked');
    }

    return _delegate.updateModelDownloadProgress(progress);
  }

  @override
  Future<void> markModelDownloaded(String slug) {
    return _delegate.markModelDownloaded(slug);
  }

  @override
  Future<void> markModelInitializing(String slug) {
    return _delegate.markModelInitializing(slug);
  }

  @override
  Future<void> markModelInitialized(String slug) {
    return _delegate.markModelInitialized(slug);
  }

  @override
  Future<void> markModelInitializationFailure({
    required String slug,
    required String failureReason,
  }) {
    return _delegate.markModelInitializationFailure(
      slug: slug,
      failureReason: failureReason,
    );
  }

  @override
  Future<void> markModelFailure({
    required String slug,
    required String failureReason,
  }) {
    return _delegate.markModelFailure(slug: slug, failureReason: failureReason);
  }

  @override
  Future<String> loadSelectedEmbeddingModelSlug() {
    return _delegate.loadSelectedEmbeddingModelSlug();
  }

  @override
  Future<String> loadSelectedPrimaryModelSlug() {
    return _delegate.loadSelectedPrimaryModelSlug();
  }

  @override
  Future<void> saveSelectedEmbeddingModelSlug(String slug) {
    return _delegate.saveSelectedEmbeddingModelSlug(slug);
  }

  @override
  Future<void> saveSelectedPrimaryModelSlug(String slug) {
    return _delegate.saveSelectedPrimaryModelSlug(slug);
  }
}

class FakeCactusModelService implements CactusModelService {
  FakeCactusModelService({required List<LocalAiModelInfo> models})
    : _models = models;

  List<LocalAiModelInfo> _models;
  int discoveryCount = 0;
  final downloadedSlugs = <String>[];
  final initializedSlugs = <String>[];
  List<ModelDownloadProgress> progressEvents = const [];
  Object? initializationError;

  @override
  Future<List<LocalAiModelInfo>> getAvailableModels() async {
    discoveryCount++;
    return _models;
  }

  @override
  Future<void> downloadModel(
    String slug, {
    void Function(ModelDownloadProgress progress)? onProgress,
  }) async {
    downloadedSlugs.add(slug);
    for (final event in progressEvents) {
      onProgress?.call(event);
    }
    _models = _models
        .map((model) {
          return model.slug == slug
              ? model.copyWith(isDownloaded: true)
              : model;
        })
        .toList(growable: false);
  }

  @override
  Future<void> initializeModel(String slug) async {
    initializedSlugs.add(slug);
    final error = initializationError;
    if (error != null) {
      throw error;
    }
  }

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

class ParallelProbeCactusModelService implements CactusModelService {
  ParallelProbeCactusModelService({
    required List<LocalAiModelInfo> models,
    required this.expectedStarts,
  }) : _models = models;

  List<LocalAiModelInfo> _models;
  final int expectedStarts;
  final startedSlugs = <String>[];
  final completedSlugs = <String>[];
  final _downloadCompleters = <String, Completer<void>>{};
  final _allStarted = Completer<void>();
  var _activeDownloads = 0;
  var maxConcurrentDownloads = 0;

  Future<void> waitForAllDownloadsToStart() => _allStarted.future;

  void completeAllDownloads() {
    for (final completer in _downloadCompleters.values) {
      if (!completer.isCompleted) {
        completer.complete();
      }
    }
  }

  @override
  Future<List<LocalAiModelInfo>> getAvailableModels() async => _models;

  @override
  Future<void> downloadModel(
    String slug, {
    void Function(ModelDownloadProgress progress)? onProgress,
  }) async {
    startedSlugs.add(slug);
    _activeDownloads++;
    maxConcurrentDownloads = maxConcurrentDownloads < _activeDownloads
        ? _activeDownloads
        : maxConcurrentDownloads;
    onProgress?.call(
      ModelDownloadProgress(
        slug: slug,
        progress: 0.1,
        statusMessage: 'Started $slug',
      ),
    );
    _downloadCompleters[slug] = Completer<void>();
    if (startedSlugs.length == expectedStarts && !_allStarted.isCompleted) {
      _allStarted.complete();
    }

    await _downloadCompleters[slug]!.future;
    _activeDownloads--;
    completedSlugs.add(slug);
    _models = _models
        .map((model) {
          return model.slug == slug
              ? model.copyWith(isDownloaded: true)
              : model;
        })
        .toList(growable: false);
  }

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
  const FakeDeviceStorageService(this.storageInfo);

  final DeviceStorageInfo storageInfo;

  @override
  Future<DeviceStorageInfo> loadStorageInfo() async => storageInfo;
}
