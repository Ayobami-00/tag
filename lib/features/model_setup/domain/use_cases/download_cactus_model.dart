import 'package:equatable/equatable.dart';
import 'package:tag/core/use_cases/use_cases.dart';
import 'package:tag/features/model_setup/domain/repositories/model_setup_repository.dart';

class DownloadCactusModel implements UseCase<void, DownloadCactusModelParams> {
  const DownloadCactusModel(this._repository);

  final ModelSetupRepository _repository;

  @override
  Future<void> call(DownloadCactusModelParams params) {
    return _repository.downloadModel(params.slug);
  }
}

class DownloadCactusModelParams extends Equatable {
  const DownloadCactusModelParams(this.slug);

  final String slug;

  @override
  List<Object?> get props => [slug];
}
