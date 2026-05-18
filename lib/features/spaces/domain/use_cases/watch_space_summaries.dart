import 'package:tag/core/use_cases/use_cases.dart';
import 'package:tag/features/spaces/domain/entities/space_entities.dart';
import 'package:tag/features/spaces/domain/repositories/spaces_repository.dart';

class WatchSpaceSummaries
    with StreamUseCases<List<SpaceSummaryEntity>, NoParams> {
  const WatchSpaceSummaries(this._repository);

  final SpacesRepository _repository;

  @override
  Stream<List<SpaceSummaryEntity>> call(NoParams params) {
    return _repository.watchSpaceSummaries();
  }
}
