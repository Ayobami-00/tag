import 'package:tag/features/cards/domain/entities/card_entities.dart';

abstract interface class SpaceRepository {
  Future<SpaceEntity?> findByNormalizedName(String normalizedName);

  Future<SpaceEntity> createFallbackSpace({
    required String name,
    required List<String> sourceIds,
    double? confidence,
  });

  Future<SpaceEntity> createSpecificSpace({
    required String name,
    required List<String> sourceIds,
    String? description,
    String? primaryIntentionType,
    double? confidence,
  });

  Future<SpaceEntity> getOrCreateFallbackSpace({
    required String suggestedName,
    required List<String> sourceIds,
    double? confidence,
  });

  Future<SpaceEntity> getOrCreateSpecificSpace({
    required String suggestedName,
    required List<String> sourceIds,
    String? description,
    String? primaryIntentionType,
    double? confidence,
  });
}
