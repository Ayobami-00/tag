import 'package:equatable/equatable.dart';
import 'package:tag/core/use_cases/use_cases.dart';
import 'package:tag/features/source_ingestion/domain/entities/source_item_entity.dart';
import 'package:tag/features/source_ingestion/domain/repositories/source_repository.dart';

class UpdateSourceProcessingStateParams extends Equatable {
  const UpdateSourceProcessingStateParams({
    required this.sourceId,
    required this.processingState,
    this.failureReason,
  });

  final String sourceId;
  final SourceProcessingState processingState;
  final String? failureReason;

  @override
  List<Object?> get props => [sourceId, processingState, failureReason];
}

class UpdateSourceProcessingState
    with UseCases<SourceItemEntity, UpdateSourceProcessingStateParams> {
  const UpdateSourceProcessingState(this._sourceRepository);

  final SourceRepository _sourceRepository;

  @override
  Future<SourceItemEntity> call(UpdateSourceProcessingStateParams params) {
    return _sourceRepository.updateProcessingState(
      sourceId: params.sourceId,
      processingState: params.processingState,
      failureReason: params.failureReason,
    );
  }
}
