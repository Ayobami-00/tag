import 'package:tag/features/cards/domain/entities/feedback_entities.dart';

abstract interface class PreferenceMemoryRepository {
  Future<PreferenceMemoryEntity> upsertPreference({
    required String category,
    required String key,
    required Object? value,
    required double confidence,
    required String evidenceEventId,
  });

  Future<PreferenceMemoryEntity?> getPreference({
    required String category,
    required String key,
  });
}
