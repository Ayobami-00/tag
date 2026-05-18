import 'package:tag/core/use_cases/use_cases.dart';
import 'package:tag/features/model_setup/domain/repositories/model_setup_repository.dart';

class LoadSelectedPrimaryModel implements UseCase<String, NoParams> {
  const LoadSelectedPrimaryModel(this._repository);

  final ModelSetupRepository _repository;

  @override
  Future<String> call(NoParams params) {
    return _repository.loadSelectedPrimaryModelSlug();
  }
}
