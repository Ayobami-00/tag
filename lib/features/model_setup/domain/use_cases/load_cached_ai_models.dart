import 'package:tag/core/ai/cactus/cactus_model_service.dart';
import 'package:tag/core/use_cases/use_cases.dart';
import 'package:tag/features/model_setup/domain/repositories/model_setup_repository.dart';

class LoadCachedAiModels implements UseCase<List<LocalAiModelInfo>, NoParams> {
  const LoadCachedAiModels(this._repository);

  final ModelSetupRepository _repository;

  @override
  Future<List<LocalAiModelInfo>> call(NoParams params) {
    return _repository.loadCachedModels();
  }
}
