import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:tag/core/ai/cactus/cactus_model_registry.dart';
import 'package:tag/core/ai/cactus/cactus_model_service.dart';
import 'package:tag/core/local_storage/database/tag_database.dart';

abstract interface class AiModelAssetsLocalDataSource {
  Future<List<LocalAiModelInfo>> loadModels();

  Future<LocalAiModelInfo?> loadModel(String slug);

  Future<void> upsertModel(LocalAiModelInfo model);

  Future<void> upsertModels(List<LocalAiModelInfo> models);

  Future<void> markModelDownloadStarted(String slug);

  Future<void> updateModelDownloadProgress(ModelDownloadProgress progress);

  Future<void> markModelDownloaded(String slug);

  Future<void> markModelInitializing(String slug);

  Future<void> markModelInitialized(String slug);

  Future<void> markModelInitializationFailure({
    required String slug,
    required String failureReason,
  });

  Future<void> markModelFailure({
    required String slug,
    required String failureReason,
  });

  Future<String> loadSelectedEmbeddingModelSlug();

  Future<String> loadSelectedPrimaryModelSlug();

  Future<void> saveSelectedEmbeddingModelSlug(String slug);

  Future<void> saveSelectedPrimaryModelSlug(String slug);
}

class DriftAiModelAssetsLocalDataSource
    implements AiModelAssetsLocalDataSource {
  const DriftAiModelAssetsLocalDataSource(
    this._database, {
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final TagDatabase _database;
  final DateTime Function() _now;

  @override
  Future<List<LocalAiModelInfo>> loadModels() async {
    final rows = await (_database.select(
      _database.aiModelAssets,
    )..orderBy([(table) => OrderingTerm.asc(table.slug)])).get();

    return rows.map(_mapModel).toList(growable: false);
  }

  @override
  Future<LocalAiModelInfo?> loadModel(String slug) async {
    final row = await (_database.select(
      _database.aiModelAssets,
    )..where((table) => table.slug.equals(slug))).getSingleOrNull();

    return row == null ? null : _mapModel(row);
  }

  @override
  Future<void> upsertModel(LocalAiModelInfo model) {
    return _database
        .into(_database.aiModelAssets)
        .insertOnConflictUpdate(_companionFor(model));
  }

  @override
  Future<void> upsertModels(List<LocalAiModelInfo> models) async {
    await _database.batch((batch) {
      batch.insertAllOnConflictUpdate(
        _database.aiModelAssets,
        models.map(_companionFor).toList(growable: false),
      );
    });
  }

  @override
  Future<void> markModelDownloadStarted(String slug) async {
    final timestamp = _timestamp();
    final existing = await _fallbackModel(slug);

    await upsertModel(
      existing.copyWith(
        isDownloaded: false,
        isInitialized: false,
        lastCheckedAt: _now().toUtc(),
        clearFailureReason: true,
        downloadStatus: AiModelDownloadStatus.downloading,
        downloadProgress: 0,
        downloadStatusMessage: 'Starting local download...',
        downloadStartedAt: DateTime.fromMillisecondsSinceEpoch(
          timestamp,
          isUtc: true,
        ),
        clearDownloadCompletedAt: true,
      ),
    );
  }

  @override
  Future<void> updateModelDownloadProgress(
    ModelDownloadProgress progress,
  ) async {
    final existing = await _fallbackModel(progress.slug);
    final status = progress.isError
        ? AiModelDownloadStatus.failed
        : AiModelDownloadStatus.downloading;

    await upsertModel(
      existing.copyWith(
        lastCheckedAt: _now().toUtc(),
        failureReason: progress.isError ? progress.statusMessage : null,
        clearFailureReason: !progress.isError,
        downloadStatus: status,
        downloadProgress: progress.progress,
        downloadStatusMessage: progress.statusMessage,
      ),
    );
  }

  @override
  Future<void> markModelDownloaded(String slug) async {
    final existing = await _fallbackModel(slug);

    await upsertModel(
      existing.copyWith(
        isDownloaded: true,
        lastCheckedAt: _now().toUtc(),
        clearFailureReason: true,
        downloadStatus: AiModelDownloadStatus.downloaded,
        downloadProgress: 1,
        downloadStatusMessage: 'Download complete.',
        downloadCompletedAt: _now().toUtc(),
      ),
    );
  }

  @override
  Future<void> markModelInitializing(String slug) async {
    final timestamp = _timestamp();
    await (_database.update(
      _database.aiModelAssets,
    )..where((table) => table.slug.equals(slug))).write(
      AiModelAssetsCompanion(
        downloadStatus: Value(AiModelDownloadStatus.initializing.storageValue),
        downloadProgress: const Value(1),
        downloadStatusMessage: const Value('Initializing locally...'),
        lastCheckedAt: Value(timestamp),
        failureReason: const Value(null),
      ),
    );
  }

  @override
  Future<void> markModelInitialized(String slug) async {
    final timestamp = _timestamp();
    await (_database.update(
      _database.aiModelAssets,
    )..where((table) => table.slug.equals(slug))).write(
      AiModelAssetsCompanion(
        isDownloaded: const Value(true),
        isInitialized: const Value(true),
        lastInitializedAt: Value(timestamp),
        failureReason: const Value(null),
        downloadStatus: Value(AiModelDownloadStatus.ready.storageValue),
        downloadProgress: const Value(1),
        downloadStatusMessage: const Value('Ready locally.'),
      ),
    );
  }

  @override
  Future<void> markModelInitializationFailure({
    required String slug,
    required String failureReason,
  }) async {
    final existing = await _fallbackModel(slug);

    await upsertModel(
      existing.copyWith(
        isDownloaded: true,
        isInitialized: false,
        lastCheckedAt: _now().toUtc(),
        failureReason: failureReason,
        downloadStatus: AiModelDownloadStatus.initializationFailed,
        downloadProgress: 1,
        downloadStatusMessage: failureReason,
      ),
    );
  }

  @override
  Future<void> markModelFailure({
    required String slug,
    required String failureReason,
  }) async {
    final existing = await loadModel(slug);
    final failedModel =
        existing ??
        CactusModelRegistry.requiredModelTargets.firstWhere(
          (model) => model.slug == slug,
          orElse: () => LocalAiModelInfo(
            slug: slug,
            displayName: slug,
            capabilities: const {},
          ),
        );

    await upsertModel(
      failedModel.copyWith(
        lastCheckedAt: _now().toUtc(),
        failureReason: failureReason,
        downloadStatus: AiModelDownloadStatus.failed,
        downloadStatusMessage: failureReason,
      ),
    );
  }

  @override
  Future<String> loadSelectedEmbeddingModelSlug() async {
    final row =
        await (_database.select(_database.appSettings)..where(
              (table) => table.key.equals('selected_embedding_model_slug'),
            ))
            .getSingleOrNull();

    if (row == null) {
      return CactusModelRegistry.defaultEmbeddingModelSlug;
    }

    final decoded = jsonDecode(row.valueJson);
    return decoded is String
        ? decoded
        : CactusModelRegistry.defaultEmbeddingModelSlug;
  }

  @override
  Future<String> loadSelectedPrimaryModelSlug() async {
    final row =
        await (_database.select(_database.appSettings)
              ..where((table) => table.key.equals('selected_model_slug')))
            .getSingleOrNull();

    if (row == null) {
      return CactusModelRegistry.defaultPrimaryModelSlug;
    }

    final decoded = jsonDecode(row.valueJson);
    return decoded is String
        ? decoded
        : CactusModelRegistry.defaultPrimaryModelSlug;
  }

  @override
  Future<void> saveSelectedEmbeddingModelSlug(String slug) {
    return _upsertSetting('selected_embedding_model_slug', jsonEncode(slug));
  }

  @override
  Future<void> saveSelectedPrimaryModelSlug(String slug) {
    return _upsertSetting('selected_model_slug', jsonEncode(slug));
  }

  Future<void> _upsertSetting(String key, String valueJson) {
    return _database
        .into(_database.appSettings)
        .insertOnConflictUpdate(
          AppSettingsCompanion.insert(
            key: key,
            valueJson: valueJson,
            updatedAt: _timestamp(),
          ),
        );
  }

  AiModelAssetsCompanion _companionFor(LocalAiModelInfo model) {
    final downloadStatus = _effectiveDownloadStatus(model);

    return AiModelAssetsCompanion.insert(
      slug: model.slug,
      displayName: model.displayName,
      capabilitiesJson: Value(
        jsonEncode(
          model.capabilities
              .map((capability) {
                return capability.storageValue;
              })
              .toList(growable: false),
        ),
      ),
      sizeMb: Value(model.sizeMb),
      quantization: Value(model.quantization),
      isDownloaded: Value(model.isDownloaded),
      isInitialized: Value(model.isInitialized),
      localPath: Value(model.localPath),
      lastCheckedAt: Value(_millis(model.lastCheckedAt)),
      lastInitializedAt: Value(_millis(model.lastInitializedAt)),
      failureReason: Value(model.failureReason),
      downloadStatus: Value(downloadStatus.storageValue),
      downloadProgress: Value(model.downloadProgress),
      downloadStatusMessage: Value(model.downloadStatusMessage),
      downloadStartedAt: Value(_millis(model.downloadStartedAt)),
      downloadCompletedAt: Value(_millis(model.downloadCompletedAt)),
    );
  }

  LocalAiModelInfo _mapModel(AiModelAsset row) {
    final decodedCapabilities = jsonDecode(row.capabilitiesJson);
    final capabilities = decodedCapabilities is List
        ? decodedCapabilities
              .whereType<String>()
              .map(AiModelCapability.fromStorageValue)
              .toSet()
        : <AiModelCapability>{};

    final storedDownloadStatus = AiModelDownloadStatus.fromStorageValue(
      row.downloadStatus,
    );
    final downloadStatus =
        row.isDownloaded &&
            !row.isInitialized &&
            storedDownloadStatus == AiModelDownloadStatus.failed
        ? AiModelDownloadStatus.initializationFailed
        : storedDownloadStatus;
    final failureReason = _friendlyStoredMessage(
      slug: row.slug,
      status: downloadStatus,
      message: row.failureReason,
    );
    final downloadStatusMessage = _friendlyStoredMessage(
      slug: row.slug,
      status: downloadStatus,
      message: row.downloadStatusMessage,
    );

    return LocalAiModelInfo(
      slug: row.slug,
      displayName: row.displayName,
      capabilities: capabilities,
      sizeMb: row.sizeMb,
      quantization: row.quantization,
      isDownloaded: row.isDownloaded,
      isInitialized: row.isInitialized,
      localPath: row.localPath,
      lastCheckedAt: _dateTime(row.lastCheckedAt),
      lastInitializedAt: _dateTime(row.lastInitializedAt),
      failureReason: failureReason,
      downloadStatus: downloadStatus,
      downloadProgress: row.downloadProgress,
      downloadStatusMessage: downloadStatusMessage,
      downloadStartedAt: _dateTime(row.downloadStartedAt),
      downloadCompletedAt: _dateTime(row.downloadCompletedAt),
    );
  }

  Future<LocalAiModelInfo> _fallbackModel(String slug) async {
    final existing = await loadModel(slug);
    if (existing != null) {
      return existing;
    }

    return CactusModelRegistry.requiredModelTargets.firstWhere(
      (model) => model.slug == slug,
      orElse: () => LocalAiModelInfo(
        slug: slug,
        displayName: slug,
        capabilities: const {},
      ),
    );
  }

  AiModelDownloadStatus _effectiveDownloadStatus(LocalAiModelInfo model) {
    if (model.isInitialized) {
      return AiModelDownloadStatus.ready;
    }

    if (model.isDownloaded &&
        model.downloadStatus == AiModelDownloadStatus.notDownloaded) {
      return AiModelDownloadStatus.downloaded;
    }

    return model.downloadStatus;
  }

  int _timestamp() => _now().toUtc().millisecondsSinceEpoch;

  int? _millis(DateTime? dateTime) => dateTime?.toUtc().millisecondsSinceEpoch;

  DateTime? _dateTime(int? millis) {
    if (millis == null) {
      return null;
    }

    return DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true);
  }

  String? _friendlyStoredMessage({
    required String slug,
    required AiModelDownloadStatus status,
    required String? message,
  }) {
    if (message == null) {
      return null;
    }

    if (status == AiModelDownloadStatus.initializationFailed) {
      return CactusModelRegistry.directDownloadInitializationMessage(slug) ??
          message;
    }

    return message;
  }
}
