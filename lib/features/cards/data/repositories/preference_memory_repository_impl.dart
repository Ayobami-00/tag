import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:tag/core/local_storage/database/tag_database.dart'
    as database_models;
import 'package:tag/features/cards/domain/entities/feedback_entities.dart';
import 'package:tag/features/cards/domain/repositories/preference_memory_repository.dart';
import 'package:uuid/uuid.dart';

class PreferenceMemoryRepositoryImpl implements PreferenceMemoryRepository {
  PreferenceMemoryRepositoryImpl({
    required database_models.TagDatabase database,
    DateTime Function()? now,
    Uuid? uuid,
  }) : _database = database,
       _now = now ?? DateTime.now,
       _uuid = uuid ?? const Uuid();

  final database_models.TagDatabase _database;
  final DateTime Function() _now;
  final Uuid _uuid;

  @override
  Future<PreferenceMemoryEntity?> getPreference({
    required String category,
    required String key,
  }) async {
    final row =
        await (_database.select(_database.preferenceMemory)..where((memory) {
              return memory.category.equals(category) & memory.key.equals(key);
            }))
            .getSingleOrNull();

    return row == null ? null : _mapPreference(row);
  }

  @override
  Future<PreferenceMemoryEntity> upsertPreference({
    required String category,
    required String key,
    required Object? value,
    required double confidence,
    required String evidenceEventId,
  }) async {
    final timestamp = _timestamp();
    final existing = await getPreference(category: category, key: key);

    if (existing == null) {
      final id = 'pref_${_uuid.v4()}';
      await _database
          .into(_database.preferenceMemory)
          .insert(
            database_models.PreferenceMemoryCompanion.insert(
              id: id,
              category: category,
              key: key,
              valueJson: jsonEncode(value),
              confidence: confidence.clamp(0.0, 1.0).toDouble(),
              evidenceEventIdsJson: Value(jsonEncode([evidenceEventId])),
              createdAt: timestamp,
              updatedAt: timestamp,
            ),
          );

      final row = await (_database.select(
        _database.preferenceMemory,
      )..where((memory) => memory.id.equals(id))).getSingle();

      return _mapPreference(row);
    }

    final evidenceIds = {
      ...existing.evidenceEventIds,
      evidenceEventId,
    }.toList(growable: false);
    final nextConfidence = confidence > existing.confidence
        ? confidence
        : (existing.confidence + 0.05).clamp(0.0, 0.95).toDouble();

    await (_database.update(
      _database.preferenceMemory,
    )..where((memory) => memory.id.equals(existing.id))).write(
      database_models.PreferenceMemoryCompanion(
        valueJson: Value(jsonEncode(value)),
        confidence: Value(nextConfidence),
        evidenceEventIdsJson: Value(jsonEncode(evidenceIds)),
        updatedAt: Value(timestamp),
      ),
    );

    final row = await (_database.select(
      _database.preferenceMemory,
    )..where((memory) => memory.id.equals(existing.id))).getSingle();

    return _mapPreference(row);
  }

  PreferenceMemoryEntity _mapPreference(
    database_models.PreferenceMemoryData row,
  ) {
    return PreferenceMemoryEntity(
      id: row.id,
      category: row.category,
      key: row.key,
      valueJson: row.valueJson,
      confidence: row.confidence,
      evidenceEventIds: _decodeEvidenceIds(row.evidenceEventIdsJson),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  List<String> _decodeEvidenceIds(String value) {
    try {
      final decoded = jsonDecode(value);
      if (decoded is List) {
        return decoded.whereType<String>().toList(growable: false);
      }
    } on FormatException {
      return const [];
    }

    return const [];
  }

  int _timestamp() => _now().toUtc().millisecondsSinceEpoch;
}
