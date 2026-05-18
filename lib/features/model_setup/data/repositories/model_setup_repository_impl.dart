import 'package:tag/core/ai/cactus/cactus_model_registry.dart';
import 'package:tag/core/ai/cactus/cactus_model_service.dart';
import 'package:tag/core/config/app_config.dart';
import 'package:tag/core/error/app_error.dart';
import 'package:tag/core/local_storage/database/data_sources/ai_model_assets_local_data_source.dart';
import 'package:tag/core/platform/device_storage_service.dart';
import 'package:tag/features/model_setup/domain/repositories/model_setup_repository.dart';

class ModelSetupRepositoryImpl implements ModelSetupRepository {
  const ModelSetupRepositoryImpl({
    required AppConfig appConfig,
    required CactusModelService cactusModelService,
    required DeviceStorageService deviceStorageService,
    required AiModelAssetsLocalDataSource localDataSource,
  }) : _appConfig = appConfig,
       _cactusModelService = cactusModelService,
       _deviceStorageService = deviceStorageService,
       _localDataSource = localDataSource;

  final AppConfig _appConfig;
  final CactusModelService _cactusModelService;
  final DeviceStorageService _deviceStorageService;
  final AiModelAssetsLocalDataSource _localDataSource;

  @override
  Future<List<LocalAiModelInfo>> discoverModels() async {
    await _ensureConfiguredTargetsStored();

    final discoveredModels = await _cactusModelService.getAvailableModels();
    await _localDataSource.upsertModels(discoveredModels);
    await _ensureConfiguredTargetsStored();

    return _localDataSource.loadModels();
  }

  @override
  Future<List<LocalAiModelInfo>> loadCachedModels() async {
    await _ensureConfiguredTargetsStored();

    return _localDataSource.loadModels();
  }

  @override
  Future<void> prepareRequiredModels({
    void Function(ModelPreparationProgress progress)? onProgress,
  }) async {
    onProgress?.call(
      const ModelPreparationProgress(statusMessage: 'Checking local setup...'),
    );

    final discoveredModels = await discoverModels();
    var selectedPrimarySlug = await _loadValidSelectedPrimaryModelSlug();
    var selectedEmbeddingSlug = await _selectEmbeddingModelForDeviceStorage();
    final selectedPrimaryModel =
        _modelForSlug(discoveredModels, selectedPrimarySlug) ??
        await _localDataSource.loadModel(selectedPrimarySlug);
    final selectedEmbeddingModel =
        _modelForSlug(discoveredModels, selectedEmbeddingSlug) ??
        await _localDataSource.loadModel(selectedEmbeddingSlug);

    if (!_isDownloadable(selectedPrimaryModel)) {
      await _localDataSource.markModelFailure(
        slug: selectedPrimarySlug,
        failureReason: _unavailableModelMessage(selectedPrimarySlug),
      );
      selectedPrimarySlug = CactusModelRegistry.defaultPrimaryModelSlug;
      await _localDataSource.saveSelectedPrimaryModelSlug(selectedPrimarySlug);
    }

    if (selectedEmbeddingSlug ==
            CactusModelRegistry.qualityEmbeddingModelSlug &&
        !_isDownloadable(selectedEmbeddingModel)) {
      await _localDataSource.markModelFailure(
        slug: selectedEmbeddingSlug,
        failureReason: _unavailableModelMessage(selectedEmbeddingSlug),
      );
      selectedEmbeddingSlug = CactusModelRegistry.defaultEmbeddingModelSlug;
      await _localDataSource.saveSelectedEmbeddingModelSlug(
        selectedEmbeddingSlug,
      );
    }

    final requiredSlugs = CactusModelRegistry.requiredStartupModelSlugs(
      selectedPrimarySlug: selectedPrimarySlug,
      selectedEmbeddingSlug: selectedEmbeddingSlug,
    );
    final requiredModels = <String, LocalAiModelInfo?>{};

    for (final slug in requiredSlugs) {
      requiredModels[slug] =
          _modelForSlug(discoveredModels, slug) ??
          await _localDataSource.loadModel(slug);
    }

    final totalWeight = _totalPreparationWeight(requiredModels.values);
    var completedWeight = 0.0;

    void emitProgress({
      required String statusMessage,
      LocalAiModelInfo? activeModel,
      double? activeProgress,
      bool isIndeterminate = false,
    }) {
      final progress = isIndeterminate
          ? null
          : _overallPreparationProgress(
              completedWeight: completedWeight,
              totalWeight: totalWeight,
              activeModel: activeModel,
              activeProgress: activeProgress,
            );

      onProgress?.call(
        ModelPreparationProgress(
          progress: progress,
          statusMessage: statusMessage,
        ),
      );
    }

    emitProgress(statusMessage: 'Preparing local downloads...');

    final modelWeights = {
      for (final entry in requiredModels.entries)
        entry.key: _preparationWeight(entry.value),
    };
    final activeDownloadProgressBySlug = <String, double?>{};
    final downloadTasks = <Future<void>>[];

    void emitDownloadProgress(String statusMessage) {
      final activeWeight = activeDownloadProgressBySlug.entries.fold<double>(
        0,
        (sum, entry) {
          final progress = entry.value;
          if (progress == null) {
            return sum;
          }

          return sum + ((modelWeights[entry.key] ?? 1) * progress);
        },
      );
      final hasIndeterminateDownload = activeDownloadProgressBySlug.values.any(
        (progress) => progress == null,
      );

      onProgress?.call(
        ModelPreparationProgress(
          progress: hasIndeterminateDownload || totalWeight <= 0
              ? null
              : ((completedWeight + activeWeight) / totalWeight).clamp(0, 1),
          statusMessage: statusMessage,
        ),
      );
    }

    for (final slug in requiredSlugs) {
      final model = requiredModels[slug];
      final modelWeight = modelWeights[slug] ?? _preparationWeight(model);

      if (model?.isDownloaded == true) {
        completedWeight += modelWeight;
        emitProgress(statusMessage: 'Checking local files...');
        continue;
      }

      if (!_isDownloadable(model)) {
        await _localDataSource.markModelFailure(
          slug: slug,
          failureReason: _unavailableModelMessage(slug),
        );
        completedWeight += modelWeight;
        emitProgress(statusMessage: 'Skipping unavailable local model...');
        continue;
      }

      activeDownloadProgressBySlug[slug] = model?.downloadProgress;
      downloadTasks.add(
        downloadModel(
          slug,
          onProgress: (progress) {
            activeDownloadProgressBySlug[slug] = progress.progress
                ?.clamp(0, 1)
                .toDouble();
            emitDownloadProgress(_preparationProgressMessage(progress));
          },
        ).then((_) {
          activeDownloadProgressBySlug.remove(slug);
          completedWeight += modelWeight;
          emitDownloadProgress('Finalizing local setup...');
        }),
      );
    }

    if (downloadTasks.isNotEmpty) {
      await Future.wait(downloadTasks);
    }

    onProgress?.call(
      const ModelPreparationProgress(
        progress: 1,
        statusMessage: 'Local setup complete.',
      ),
    );
  }

  @override
  Future<void> downloadModel(
    String slug, {
    void Function(ModelDownloadProgress progress)? onProgress,
  }) async {
    final model = await _localDataSource.loadModel(slug);
    if (!_isDownloadable(model)) {
      final message = _unavailableModelMessage(slug);
      await _localDataSource.markModelFailure(
        slug: slug,
        failureReason: message,
      );
      throw AppError(message);
    }

    try {
      await _localDataSource.markModelDownloadStarted(slug);
      var progressWrite = Future<void>.value();
      var lastPersistedProgressAt = DateTime.fromMillisecondsSinceEpoch(0);
      double? lastPersistedProgress;
      await _cactusModelService.downloadModel(
        slug,
        onProgress: (progress) {
          onProgress?.call(progress);
          if (_shouldPersistDownloadProgress(
            progress,
            lastPersistedProgress: lastPersistedProgress,
            lastPersistedAt: lastPersistedProgressAt,
          )) {
            lastPersistedProgress = progress.progress;
            lastPersistedProgressAt = DateTime.now();
            progressWrite = _chainDownloadProgressWrite(
              progressWrite,
              progress,
            );
          }
        },
      );
      await progressWrite;
      await _localDataSource.markModelDownloaded(slug);
      onProgress?.call(
        ModelDownloadProgress(
          slug: slug,
          progress: 1,
          statusMessage: 'Download complete.',
        ),
      );
    } on Object catch (error) {
      await _localDataSource.markModelFailure(
        slug: slug,
        failureReason: _userFacingErrorMessage(error),
      );
      rethrow;
    }
  }

  @override
  Future<void> initializeModel(String slug) async {
    try {
      await _localDataSource.markModelInitializing(slug);
      await _cactusModelService.initializeModel(slug);
      await _localDataSource.markModelInitialized(slug);
    } on Object catch (error) {
      await _localDataSource.markModelInitializationFailure(
        slug: slug,
        failureReason: _userFacingErrorMessage(error),
      );
      rethrow;
    }
  }

  Future<String> _selectEmbeddingModelForDeviceStorage() async {
    try {
      final storageInfo = await _deviceStorageService.loadStorageInfo();
      final selectedSlug = CactusModelRegistry.embeddingSlugForStorage(
        availableBytes: storageInfo.availableBytes,
        totalBytes: storageInfo.totalBytes,
        minAvailableBytes: _appConfig.qualityEmbeddingMinAvailableBytes,
        minTotalBytes: _appConfig.qualityEmbeddingMinTotalBytes,
      );

      await _localDataSource.saveSelectedEmbeddingModelSlug(selectedSlug);
      return selectedSlug;
    } on Object {
      await _localDataSource.saveSelectedEmbeddingModelSlug(
        CactusModelRegistry.defaultEmbeddingModelSlug,
      );
      return CactusModelRegistry.defaultEmbeddingModelSlug;
    }
  }

  Future<String> _loadValidSelectedPrimaryModelSlug() async {
    final selectedSlug = await _localDataSource.loadSelectedPrimaryModelSlug();
    final config = CactusModelRegistry.primaryModelConfigForSlug(selectedSlug);
    if (config.modelSlug != selectedSlug) {
      await _localDataSource.saveSelectedPrimaryModelSlug(config.modelSlug);
    }

    return config.modelSlug;
  }

  @override
  Future<String> loadSelectedEmbeddingModelSlug() {
    return _localDataSource.loadSelectedEmbeddingModelSlug();
  }

  @override
  Future<String> loadSelectedPrimaryModelSlug() async {
    return _loadValidSelectedPrimaryModelSlug();
  }

  @override
  Future<void> selectEmbeddingModel(String slug) async {
    final config = CactusModelRegistry.embeddingConfigForSlug(slug);
    await _localDataSource.saveSelectedEmbeddingModelSlug(config.modelSlug);
  }

  @override
  Future<void> selectPrimaryModel(String slug) async {
    final config = CactusModelRegistry.primaryModelConfigForSlug(slug);
    await _localDataSource.saveSelectedPrimaryModelSlug(config.modelSlug);
  }

  Future<void> _ensureConfiguredTargetsStored() async {
    final cachedModels = await _localDataSource.loadModels();
    final cachedBySlug = {for (final model in cachedModels) model.slug: model};

    final targets = CactusModelRegistry.requiredModelTargets
        .map((target) {
          final existing = cachedBySlug[target.slug];
          if (existing == null) {
            return _initialTarget(target);
          }

          if (_shouldRefreshDirectDownloadTarget(existing, target)) {
            return target.copyWith(
              isDownloaded: existing.isDownloaded,
              isInitialized: existing.isInitialized,
              localPath: existing.localPath,
              lastCheckedAt: DateTime.now().toUtc(),
              lastInitializedAt: existing.lastInitializedAt,
              downloadStatus: existing.isDownloaded
                  ? existing.downloadStatus
                  : AiModelDownloadStatus.notDownloaded,
              downloadProgress: existing.isDownloaded
                  ? existing.downloadProgress
                  : null,
              downloadStatusMessage: existing.isDownloaded
                  ? existing.downloadStatusMessage
                  : 'Available from ${CactusModelRegistry.directDownloadAssetForSlug(target.slug)!.sourceLabel}.',
              downloadStartedAt: existing.downloadStartedAt,
              downloadCompletedAt: existing.downloadCompletedAt,
              clearFailureReason: !existing.isDownloaded,
            );
          }

          return existing;
        })
        .toList(growable: false);

    await _localDataSource.upsertModels(targets);
    final selectedPrimarySlug = await _localDataSource
        .loadSelectedPrimaryModelSlug();
    if (!CactusModelRegistry.isKnownPrimaryModel(selectedPrimarySlug)) {
      await _localDataSource.saveSelectedPrimaryModelSlug(
        CactusModelRegistry.defaultPrimaryModelSlug,
      );
    }

    final selectedEmbeddingSlug = await _localDataSource
        .loadSelectedEmbeddingModelSlug();
    if (!CactusModelRegistry.isKnownEmbeddingModel(selectedEmbeddingSlug)) {
      await _localDataSource.saveSelectedEmbeddingModelSlug(
        CactusModelRegistry.defaultEmbeddingModelSlug,
      );
    }
  }

  LocalAiModelInfo _initialTarget(LocalAiModelInfo target) {
    final directAsset = CactusModelRegistry.directDownloadAssetForSlug(
      target.slug,
    );
    if (directAsset != null) {
      return target.copyWith(
        lastCheckedAt: DateTime.now().toUtc(),
        downloadStatusMessage: 'Available from ${directAsset.sourceLabel}.',
      );
    }

    return target.copyWith(
      capabilities: const {},
      lastCheckedAt: DateTime.now().toUtc(),
      failureReason: 'Waiting for local Cactus discovery.',
    );
  }

  bool _shouldRefreshDirectDownloadTarget(
    LocalAiModelInfo existing,
    LocalAiModelInfo target,
  ) {
    final directAsset = CactusModelRegistry.directDownloadAssetForSlug(
      existing.slug,
    );
    if (directAsset == null) {
      return false;
    }

    final hasOldCatalogFailure =
        existing.failureReason?.contains('local Cactus model registry') ==
            true ||
        existing.downloadStatusMessage?.contains(
              'local Cactus model registry',
            ) ==
            true;

    return existing.capabilities != target.capabilities ||
        existing.displayName != target.displayName ||
        existing.sizeMb != target.sizeMb ||
        existing.quantization != target.quantization ||
        hasOldCatalogFailure;
  }

  LocalAiModelInfo? _modelForSlug(List<LocalAiModelInfo> models, String slug) {
    for (final model in models) {
      if (model.slug == slug) {
        return model;
      }
    }

    return null;
  }

  bool _isDownloadable(LocalAiModelInfo? model) {
    return model != null && model.capabilities.isNotEmpty;
  }

  double _totalPreparationWeight(Iterable<LocalAiModelInfo?> models) {
    final total = models.fold<double>(0, (sum, model) {
      return sum + _preparationWeight(model);
    });

    return total <= 0 ? 1 : total;
  }

  double _preparationWeight(LocalAiModelInfo? model) {
    final sizeMb = model?.sizeMb;
    if (sizeMb == null || sizeMb <= 0) {
      return 1;
    }

    return sizeMb;
  }

  double _overallPreparationProgress({
    required double completedWeight,
    required double totalWeight,
    LocalAiModelInfo? activeModel,
    double? activeProgress,
  }) {
    final activeWeight = activeModel == null || activeProgress == null
        ? 0
        : _preparationWeight(activeModel) * activeProgress.clamp(0, 1);

    return ((completedWeight + activeWeight) / totalWeight)
        .clamp(0, 1)
        .toDouble();
  }

  String _preparationProgressMessage(ModelDownloadProgress progress) {
    if (progress.progress == null) {
      return 'Starting local download...';
    }

    if (progress.progress! >= 1) {
      return 'Finalizing local files...';
    }

    return 'Downloading local models...';
  }

  Future<void> _chainDownloadProgressWrite(
    Future<void> previousWrite,
    ModelDownloadProgress progress,
  ) {
    return previousWrite
        .catchError((_) {
          return null;
        })
        .then((_) {
          return _localDataSource
              .updateModelDownloadProgress(progress)
              .catchError((_) {
                return null;
              });
        });
  }

  bool _shouldPersistDownloadProgress(
    ModelDownloadProgress progress, {
    required double? lastPersistedProgress,
    required DateTime lastPersistedAt,
  }) {
    if (progress.isError || progress.progress == null) {
      return true;
    }

    final nextProgress = progress.progress!.clamp(0, 1).toDouble();
    if (nextProgress >= 1 || lastPersistedProgress == null) {
      return true;
    }

    if ((nextProgress - lastPersistedProgress).abs() >= 0.005) {
      return true;
    }

    return DateTime.now().difference(lastPersistedAt) >=
        const Duration(seconds: 1);
  }

  String _unavailableModelMessage(String slug) {
    return '$slug is not available from the local Cactus model registry on '
        'this build. Refresh after updating the Cactus catalog or check the '
        'configured model slug.';
  }

  String _userFacingErrorMessage(Object error) {
    return error is AppError ? error.message : error.toString();
  }
}
