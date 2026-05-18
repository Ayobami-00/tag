import 'package:tag/core/use_cases/use_cases.dart';
import 'package:tag/features/model_setup/domain/repositories/model_setup_repository.dart';

class PrepareRequiredLocalModels implements UseCase<void, NoParams> {
  const PrepareRequiredLocalModels(this._repository);

  final ModelSetupRepository _repository;

  @override
  Future<void> call(NoParams params) {
    return _repository.prepareRequiredModels();
  }

  Future<void> withProgress({
    void Function(ModelPreparationProgress progress)? onProgress,
  }) {
    return _repository.prepareRequiredModels(onProgress: onProgress);
  }
}
