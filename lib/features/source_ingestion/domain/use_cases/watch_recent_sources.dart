import 'package:equatable/equatable.dart';
import 'package:tag/core/use_cases/use_cases.dart';
import 'package:tag/features/source_ingestion/domain/entities/source_item_entity.dart';
import 'package:tag/features/source_ingestion/domain/repositories/source_repository.dart';

class WatchRecentSourcesParams extends Equatable {
  const WatchRecentSourcesParams({this.limit = 10});

  final int limit;

  @override
  List<Object?> get props => [limit];
}

class WatchRecentSources
    with StreamUseCases<List<SourceItemEntity>, WatchRecentSourcesParams> {
  const WatchRecentSources(this._sourceRepository);

  final SourceRepository _sourceRepository;

  @override
  Stream<List<SourceItemEntity>> call(WatchRecentSourcesParams params) {
    return _sourceRepository.watchRecentSources(limit: params.limit);
  }
}
