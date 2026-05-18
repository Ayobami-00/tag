import 'package:equatable/equatable.dart';
import 'package:tag/core/use_cases/use_cases.dart';
import 'package:tag/features/model_setup/domain/repositories/model_setup_repository.dart';

class InitializeCactusModel
    implements UseCase<void, InitializeCactusModelParams> {
  const InitializeCactusModel(this._repository);

  final ModelSetupRepository _repository;

  @override
  Future<void> call(InitializeCactusModelParams params) {
    return _repository.initializeModel(params.slug);
  }
}

class InitializeCactusModelParams extends Equatable {
  const InitializeCactusModelParams(this.slug);

  final String slug;

  @override
  List<Object?> get props => [slug];
}
