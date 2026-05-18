import 'package:equatable/equatable.dart';
import 'package:tag/core/use_cases/use_cases.dart';
import 'package:tag/features/spaces/domain/entities/space_entities.dart';
import 'package:tag/features/spaces/domain/repositories/spaces_repository.dart';

class GetSpaceDetail
    implements UseCase<SpaceDetailEntity?, GetSpaceDetailParams> {
  const GetSpaceDetail(this._repository);

  final SpacesRepository _repository;

  @override
  Future<SpaceDetailEntity?> call(GetSpaceDetailParams params) {
    return _repository.getSpaceDetail(params.spaceId);
  }
}

class GetSpaceDetailParams extends Equatable {
  const GetSpaceDetailParams({required this.spaceId});

  final String spaceId;

  @override
  List<Object?> get props => [spaceId];
}
