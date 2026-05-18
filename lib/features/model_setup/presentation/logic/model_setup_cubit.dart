import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tag/core/ai/cactus/cactus_model_registry.dart';
import 'package:tag/core/ai/cactus/cactus_model_service.dart';
import 'package:tag/core/error/app_error.dart';
import 'package:tag/core/use_cases/use_cases.dart';
import 'package:tag/features/model_setup/domain/use_cases/discover_cactus_models.dart';
import 'package:tag/features/model_setup/domain/use_cases/download_cactus_model.dart';
import 'package:tag/features/model_setup/domain/use_cases/initialize_cactus_model.dart';
import 'package:tag/features/model_setup/domain/use_cases/load_cached_ai_models.dart';
import 'package:tag/features/model_setup/domain/use_cases/load_selected_embedding_model.dart';
import 'package:tag/features/model_setup/domain/use_cases/load_selected_primary_model.dart';
import 'package:tag/features/model_setup/domain/use_cases/select_embedding_model.dart';
import 'package:tag/features/model_setup/domain/use_cases/select_primary_model.dart';

part 'model_setup_state.dart';

class ModelSetupCubit extends Cubit<ModelSetupState> {
  ModelSetupCubit({
    required DiscoverCactusModels discoverCactusModels,
    required LoadCachedAiModels loadCachedAiModels,
    required DownloadCactusModel downloadCactusModel,
    required InitializeCactusModel initializeCactusModel,
    required LoadSelectedEmbeddingModel loadSelectedEmbeddingModel,
    required LoadSelectedPrimaryModel loadSelectedPrimaryModel,
    required SelectEmbeddingModel selectEmbeddingModel,
    required SelectPrimaryModel selectPrimaryModel,
  }) : _discoverCactusModels = discoverCactusModels,
       _loadCachedAiModels = loadCachedAiModels,
       _downloadCactusModel = downloadCactusModel,
       _initializeCactusModel = initializeCactusModel,
       _loadSelectedEmbeddingModel = loadSelectedEmbeddingModel,
       _loadSelectedPrimaryModel = loadSelectedPrimaryModel,
       _selectEmbeddingModel = selectEmbeddingModel,
       _selectPrimaryModel = selectPrimaryModel,
       super(const ModelSetupState());

  final DiscoverCactusModels _discoverCactusModels;
  final LoadCachedAiModels _loadCachedAiModels;
  final DownloadCactusModel _downloadCactusModel;
  final InitializeCactusModel _initializeCactusModel;
  final LoadSelectedEmbeddingModel _loadSelectedEmbeddingModel;
  final LoadSelectedPrimaryModel _loadSelectedPrimaryModel;
  final SelectEmbeddingModel _selectEmbeddingModel;
  final SelectPrimaryModel _selectPrimaryModel;
  Timer? _pollTimer;
  bool _isRefreshingCachedModels = false;

  Future<void> load() async {
    emit(state.copyWith(status: ModelSetupStatus.loading, errorMessage: ''));

    try {
      final models = await _discoverCactusModels(const NoParams());
      final selectedEmbeddingSlug = await _loadSelectedEmbeddingModel(
        const NoParams(),
      );
      final selectedPrimarySlug = await _loadSelectedPrimaryModel(
        const NoParams(),
      );
      if (isClosed) {
        return;
      }
      _emitReady(
        models: models,
        selectedPrimarySlug: selectedPrimarySlug,
        selectedEmbeddingSlug: selectedEmbeddingSlug,
      );
      _startStatusPolling();
    } on Object catch (error) {
      final cachedModels = await _loadCachedAiModels(const NoParams());
      final selectedEmbeddingSlug = await _loadSelectedEmbeddingModel(
        const NoParams(),
      );
      final selectedPrimarySlug = await _loadSelectedPrimaryModel(
        const NoParams(),
      );
      if (isClosed) {
        return;
      }
      _emitReady(
        models: cachedModels,
        selectedPrimarySlug: selectedPrimarySlug,
        selectedEmbeddingSlug: selectedEmbeddingSlug,
        errorMessage:
            'Cactus model discovery is unavailable. Existing local data still works.',
        actionMessage: _userFacingErrorMessage(error),
      );
      _startStatusPolling();
    }
  }

  Future<void> refresh() => load();

  Future<void> download(String slug) async {
    emit(
      state.copyWith(
        status: ModelSetupStatus.busy,
        activeModelSlug: slug,
        actionMessage: 'Downloading $slug locally...',
        errorMessage: '',
      ),
    );

    try {
      await _downloadCactusModel(DownloadCactusModelParams(slug));
      await _reloadAfterAction('$slug is downloaded.');
    } on Object catch (error) {
      await _reloadAfterAction(
        '$slug could not be downloaded.',
        errorMessage: _userFacingErrorMessage(error),
      );
    }
  }

  Future<void> initialize(String slug) async {
    emit(
      state.copyWith(
        status: ModelSetupStatus.busy,
        activeModelSlug: slug,
        actionMessage: 'Initializing $slug locally...',
        errorMessage: '',
      ),
    );

    try {
      await _initializeCactusModel(InitializeCactusModelParams(slug));
      await _reloadAfterAction('$slug is initialized.');
    } on Object catch (error) {
      await _reloadAfterAction(
        '$slug could not be initialized.',
        errorMessage: _userFacingErrorMessage(error),
      );
    }
  }

  Future<void> selectEmbedding(String slug) async {
    await _selectEmbeddingModel(SelectEmbeddingModelParams(slug));

    emit(
      state.copyWith(
        selectedEmbeddingSlug: CactusModelRegistry.embeddingConfigForSlug(
          slug,
        ).modelSlug,
        actionMessage: 'Embedding profile updated.',
        errorMessage: '',
      ),
    );
    await _refreshCachedModels();
  }

  Future<void> selectPrimary(String slug) async {
    await _selectPrimaryModel(SelectPrimaryModelParams(slug));
    final selectedSlug = CactusModelRegistry.primaryModelConfigForSlug(
      slug,
    ).modelSlug;

    emit(
      state.copyWith(
        selectedPrimarySlug: selectedSlug,
        primaryCapabilityCheck: CactusModelRegistry.checkPrimaryModel(
          _modelForSlug(state.models, selectedSlug),
          modelSlug: selectedSlug,
        ),
        actionMessage: 'Card quality profile updated.',
        errorMessage: '',
      ),
    );
    await _refreshCachedModels();

    final selectedModel = _modelForSlug(state.models, selectedSlug);
    if (selectedModel != null && !selectedModel.isDownloaded && !isClosed) {
      await download(selectedSlug);
    }
  }

  Future<void> _reloadAfterAction(
    String actionMessage, {
    String errorMessage = '',
  }) async {
    final models = await _loadCachedAiModels(const NoParams());
    final selectedEmbeddingSlug = await _loadSelectedEmbeddingModel(
      const NoParams(),
    );
    final selectedPrimarySlug = await _loadSelectedPrimaryModel(
      const NoParams(),
    );

    if (isClosed) {
      return;
    }

    _emitReady(
      models: models,
      selectedPrimarySlug: selectedPrimarySlug,
      selectedEmbeddingSlug: selectedEmbeddingSlug,
      actionMessage: actionMessage,
      errorMessage: errorMessage,
    );
  }

  void _emitReady({
    required List<LocalAiModelInfo> models,
    required String selectedPrimarySlug,
    required String selectedEmbeddingSlug,
    String actionMessage = '',
    String errorMessage = '',
  }) {
    final primarySlug = CactusModelRegistry.primaryModelConfigForSlug(
      selectedPrimarySlug,
    ).modelSlug;
    final primaryModel = _modelForSlug(models, primarySlug);
    final embeddingSlug = CactusModelRegistry.embeddingConfigForSlug(
      selectedEmbeddingSlug,
    ).modelSlug;
    final embeddingModel = _modelForSlug(models, embeddingSlug);

    emit(
      state.copyWith(
        status: ModelSetupStatus.ready,
        models: models,
        selectedPrimarySlug: primarySlug,
        selectedEmbeddingSlug: embeddingSlug,
        primaryCapabilityCheck: CactusModelRegistry.checkPrimaryModel(
          primaryModel,
          modelSlug: primarySlug,
        ),
        embeddingCapabilityCheck: CactusModelRegistry.checkEmbeddingModel(
          embeddingModel,
        ),
        activeModelSlug: '',
        actionMessage: actionMessage,
        errorMessage: errorMessage,
      ),
    );
  }

  void _startStatusPolling() {
    _pollTimer ??= Timer.periodic(
      const Duration(seconds: 2),
      (_) => _refreshCachedModels(),
    );
  }

  Future<void> _refreshCachedModels() async {
    if (isClosed || _isRefreshingCachedModels) {
      return;
    }

    _isRefreshingCachedModels = true;
    try {
      final models = await _loadCachedAiModels(const NoParams());
      final selectedEmbeddingSlug = await _loadSelectedEmbeddingModel(
        const NoParams(),
      );
      final selectedPrimarySlug = await _loadSelectedPrimaryModel(
        const NoParams(),
      );

      if (isClosed) {
        return;
      }

      _emitCachedSnapshot(
        models: models,
        selectedPrimarySlug: selectedPrimarySlug,
        selectedEmbeddingSlug: selectedEmbeddingSlug,
      );
    } finally {
      _isRefreshingCachedModels = false;
    }
  }

  void _emitCachedSnapshot({
    required List<LocalAiModelInfo> models,
    required String selectedPrimarySlug,
    required String selectedEmbeddingSlug,
  }) {
    final primarySlug = CactusModelRegistry.primaryModelConfigForSlug(
      selectedPrimarySlug,
    ).modelSlug;
    final primaryModel = _modelForSlug(models, primarySlug);
    final embeddingSlug = CactusModelRegistry.embeddingConfigForSlug(
      selectedEmbeddingSlug,
    ).modelSlug;
    final embeddingModel = _modelForSlug(models, embeddingSlug);

    emit(
      state.copyWith(
        status: state.status == ModelSetupStatus.loading
            ? ModelSetupStatus.ready
            : state.status,
        models: models,
        selectedPrimarySlug: primarySlug,
        selectedEmbeddingSlug: embeddingSlug,
        primaryCapabilityCheck: CactusModelRegistry.checkPrimaryModel(
          primaryModel,
          modelSlug: primarySlug,
        ),
        embeddingCapabilityCheck: CactusModelRegistry.checkEmbeddingModel(
          embeddingModel,
        ),
      ),
    );
  }

  @override
  Future<void> close() {
    _pollTimer?.cancel();
    return super.close();
  }

  LocalAiModelInfo? _modelForSlug(List<LocalAiModelInfo> models, String slug) {
    for (final model in models) {
      if (model.slug == slug) {
        return model;
      }
    }

    return null;
  }

  String _userFacingErrorMessage(Object error) {
    return error is AppError ? error.message : error.toString();
  }
}
