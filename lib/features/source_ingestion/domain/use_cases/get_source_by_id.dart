import 'package:equatable/equatable.dart';
import 'package:tag/core/use_cases/use_cases.dart';
import 'package:tag/features/source_ingestion/domain/entities/source_item_entity.dart';
import 'package:tag/features/source_ingestion/domain/repositories/source_repository.dart';

class GetSourceByIdParams extends Equatable {
  const GetSourceByIdParams(this.sourceId);

  final String sourceId;

  @override
  List<Object?> get props => [sourceId];
}

class GetSourceById with UseCases<SourceItemEntity?, GetSourceByIdParams> {
  const GetSourceById(this._sourceRepository);

  final SourceRepository _sourceRepository;

  @override
  Future<SourceItemEntity?> call(GetSourceByIdParams params) {
    return _sourceRepository.getSourceById(params.sourceId);
  }
}
