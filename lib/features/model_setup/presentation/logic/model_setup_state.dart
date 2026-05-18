part of 'model_setup_cubit.dart';

enum ModelSetupStatus { initial, loading, ready, busy }

class ModelSetupState extends Equatable {
  const ModelSetupState({
    this.status = ModelSetupStatus.initial,
    this.models = const [],
    this.selectedPrimarySlug = CactusModelRegistry.defaultPrimaryModelSlug,
    this.selectedEmbeddingSlug = CactusModelRegistry.defaultEmbeddingModelSlug,
    this.primaryCapabilityCheck,
    this.embeddingCapabilityCheck,
    this.activeModelSlug = '',
    this.actionMessage = '',
    this.errorMessage = '',
  });

  final ModelSetupStatus status;
  final List<LocalAiModelInfo> models;
  final String selectedPrimarySlug;
  final String selectedEmbeddingSlug;
  final ModelCapabilityCheck? primaryCapabilityCheck;
  final ModelCapabilityCheck? embeddingCapabilityCheck;
  final String activeModelSlug;
  final String actionMessage;
  final String errorMessage;

  bool get isBusy =>
      status == ModelSetupStatus.loading || status == ModelSetupStatus.busy;

  LocalAiModelInfo get primaryModel {
    final target =
        selectedPrimarySlug == CactusModelRegistry.qualityVisionModelSlug
        ? CactusModelRegistry.qualityPrimaryModelTarget
        : CactusModelRegistry.compactPrimaryModelTarget;

    return _modelForSlug(selectedPrimarySlug) ??
        target.copyWith(failureReason: 'Waiting for local Cactus discovery.');
  }

  PrimaryModelConfig get selectedPrimaryConfig {
    return CactusModelRegistry.primaryModelConfigForSlug(selectedPrimarySlug);
  }

  LocalAiModelInfo get embeddingModel {
    return _modelForSlug(selectedEmbeddingSlug) ??
        (selectedEmbeddingSlug == CactusModelRegistry.qualityEmbeddingModelSlug
                ? CactusModelRegistry.qualityEmbeddingTarget
                : CactusModelRegistry.compactEmbeddingTarget)
            .copyWith(failureReason: 'Waiting for local Cactus discovery.');
  }

  EmbeddingModelConfig get selectedEmbeddingConfig {
    return CactusModelRegistry.embeddingConfigForSlug(selectedEmbeddingSlug);
  }

  ModelCapabilityCheck get effectivePrimaryCheck {
    return primaryCapabilityCheck ??
        CactusModelRegistry.checkPrimaryModel(
          primaryModel,
          modelSlug: selectedPrimarySlug,
        );
  }

  ModelCapabilityCheck get effectiveEmbeddingCheck {
    return embeddingCapabilityCheck ??
        CactusModelRegistry.checkEmbeddingModel(embeddingModel);
  }

  LocalAiModelInfo? _modelForSlug(String slug) {
    for (final model in models) {
      if (model.slug == slug) {
        return model;
      }
    }

    return null;
  }

  ModelSetupState copyWith({
    ModelSetupStatus? status,
    List<LocalAiModelInfo>? models,
    String? selectedPrimarySlug,
    String? selectedEmbeddingSlug,
    ModelCapabilityCheck? primaryCapabilityCheck,
    ModelCapabilityCheck? embeddingCapabilityCheck,
    String? activeModelSlug,
    String? actionMessage,
    String? errorMessage,
  }) {
    return ModelSetupState(
      status: status ?? this.status,
      models: models ?? this.models,
      selectedPrimarySlug: selectedPrimarySlug ?? this.selectedPrimarySlug,
      selectedEmbeddingSlug:
          selectedEmbeddingSlug ?? this.selectedEmbeddingSlug,
      primaryCapabilityCheck:
          primaryCapabilityCheck ?? this.primaryCapabilityCheck,
      embeddingCapabilityCheck:
          embeddingCapabilityCheck ?? this.embeddingCapabilityCheck,
      activeModelSlug: activeModelSlug ?? this.activeModelSlug,
      actionMessage: actionMessage ?? this.actionMessage,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    models,
    selectedPrimarySlug,
    selectedEmbeddingSlug,
    primaryCapabilityCheck,
    embeddingCapabilityCheck,
    activeModelSlug,
    actionMessage,
    errorMessage,
  ];
}
