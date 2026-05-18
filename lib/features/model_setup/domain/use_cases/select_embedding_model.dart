import 'package:equatable/equatable.dart';
import 'package:tag/core/use_cases/use_cases.dart';
import 'package:tag/features/model_setup/domain/repositories/model_setup_repository.dart';

class SelectEmbeddingModel
    implements UseCase<void, SelectEmbeddingModelParams> {
  const SelectEmbeddingModel(this._repository);

  final ModelSetupRepository _repository;

  @override
  Future<void> call(SelectEmbeddingModelParams params) {
    return _repository.selectEmbeddingModel(params.slug);
  }
}

class SelectEmbeddingModelParams extends Equatable {
  const SelectEmbeddingModelParams(this.slug);

  final String slug;

  @override
  List<Object?> get props => [slug];
}
