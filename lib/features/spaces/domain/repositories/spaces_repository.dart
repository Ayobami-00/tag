import 'package:tag/features/spaces/domain/entities/space_entities.dart';

abstract interface class SpacesRepository {
  Stream<List<SpaceSummaryEntity>> watchSpaceSummaries();

  Future<List<SpaceSummaryEntity>> getSpaceSummaries();

  Future<SpaceDetailEntity?> getSpaceDetail(String spaceId);
}
