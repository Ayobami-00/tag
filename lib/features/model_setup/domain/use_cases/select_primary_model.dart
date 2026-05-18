import 'package:equatable/equatable.dart';
import 'package:tag/core/use_cases/use_cases.dart';
import 'package:tag/features/model_setup/domain/repositories/model_setup_repository.dart';

class SelectPrimaryModel implements UseCase<void, SelectPrimaryModelParams> {
  const SelectPrimaryModel(this._repository);

  final ModelSetupRepository _repository;

  @override
  Future<void> call(SelectPrimaryModelParams params) {
    return _repository.selectPrimaryModel(params.slug);
  }
}

class SelectPrimaryModelParams extends Equatable {
  const SelectPrimaryModelParams(this.slug);

  final String slug;

  @override
  List<Object?> get props => [slug];
}
