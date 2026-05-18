import 'package:equatable/equatable.dart';
import 'package:tag/core/use_cases/use_cases.dart';
import 'package:tag/features/source_ingestion/domain/entities/source_preview_entity.dart';
import 'package:tag/features/source_ingestion/domain/repositories/source_repository.dart';

class GetSourcePreviewParams extends Equatable {
  const GetSourcePreviewParams({required this.sourceId});

  final String sourceId;

  @override
  List<Object?> get props => [sourceId];
}

class GetSourcePreview
    with UseCases<SourcePreviewEntity?, GetSourcePreviewParams> {
  const GetSourcePreview(this._sourceRepository);

  final SourceRepository _sourceRepository;

  @override
  Future<SourcePreviewEntity?> call(GetSourcePreviewParams params) {
    return _sourceRepository.getSourcePreviewById(params.sourceId);
  }
}
