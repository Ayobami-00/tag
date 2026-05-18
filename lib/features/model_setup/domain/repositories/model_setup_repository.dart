import 'package:equatable/equatable.dart';
import 'package:tag/core/ai/cactus/cactus_model_service.dart';

class ModelPreparationProgress extends Equatable {
  const ModelPreparationProgress({required this.statusMessage, this.progress});

  final String statusMessage;
  final double? progress;

  @override
  List<Object?> get props => [statusMessage, progress];
}

abstract interface class ModelSetupRepository {
  Future<List<LocalAiModelInfo>> discoverModels();

  Future<List<LocalAiModelInfo>> loadCachedModels();

  Future<void> prepareRequiredModels({
    void Function(ModelPreparationProgress progress)? onProgress,
  });

  Future<void> downloadModel(
    String slug, {
    void Function(ModelDownloadProgress progress)? onProgress,
  });

  Future<void> initializeModel(String slug);

  Future<String> loadSelectedEmbeddingModelSlug();

  Future<String> loadSelectedPrimaryModelSlug();

  Future<void> selectEmbeddingModel(String slug);

  Future<void> selectPrimaryModel(String slug);
}
