import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:tag/core/local_storage/database/tag_database.dart'
    as database_models;
import 'package:tag/features/cards/domain/entities/card_entities.dart';
import 'package:tag/features/cards/domain/repositories/space_repository.dart';
import 'package:uuid/uuid.dart';

class SpaceRepositoryImpl implements SpaceRepository {
  SpaceRepositoryImpl({
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
  Future<SpaceEntity?> findByNormalizedName(String normalizedName) async {
    final row =
        await (_database.select(_database.spaces)..where((space) {
              return space.normalizedName.equals(normalizedName) &
                  space.deletedAt.isNull() &
                  space.archivedAt.isNull();
            }))
            .getSingleOrNull();

    return row == null ? null : _mapSpace(row);
  }

  @override
  Future<SpaceEntity> createFallbackSpace({
    required String name,
    required List<String> sourceIds,
    double? confidence,
  }) async {
    final sanitizedName = _displayName(name);
    final normalizedName = normalizeSpaceName(sanitizedName);
    final existing = await findByNormalizedName(normalizedName);
    if (existing != null) {
      return existing;
    }

    final timestamp = _timestamp();
    final id = 'space_${_uuid.v4()}';
    const description = 'Local fallback Space for source-backed cards.';

    await _database
        .into(_database.spaces)
        .insert(
          database_models.SpacesCompanion.insert(
            id: id,
            name: sanitizedName,
            normalizedName: normalizedName,
            type: SpaceType.fallback.storageValue,
            description: const Value(description),
            createdBy: 'ai',
            confidence: _nullableValue(confidence),
            sourceIdsSnapshotJson: Value(jsonEncode(sourceIds)),
            createdAt: timestamp,
            updatedAt: timestamp,
          ),
        );

    return SpaceEntity(
      id: id,
      name: sanitizedName,
      normalizedName: normalizedName,
      type: SpaceType.fallback,
      description: description,
      createdBy: 'ai',
      confidence: confidence,
      createdAt: timestamp,
      updatedAt: timestamp,
    );
  }

  @override
  Future<SpaceEntity> createSpecificSpace({
    required String name,
    required List<String> sourceIds,
    String? description,
    String? primaryIntentionType,
    double? confidence,
  }) async {
    final sanitizedName = _displayName(name);
    final normalizedName = normalizeSpaceName(sanitizedName);
    final existing = await findByNormalizedName(normalizedName);
    if (existing != null) {
      return existing;
    }

    final timestamp = _timestamp();
    final id = 'space_${_uuid.v4()}';
    final spaceDescription = _nullableTrimmed(description);
    final intentionType = _nullableTrimmed(primaryIntentionType);

    await _database
        .into(_database.spaces)
        .insert(
          database_models.SpacesCompanion.insert(
            id: id,
            name: sanitizedName,
            normalizedName: normalizedName,
            type: SpaceType.specific.storageValue,
            description: _nullableValue(spaceDescription),
            primaryIntentionType: _nullableValue(intentionType),
            createdBy: 'ai',
            confidence: _nullableValue(confidence),
            sourceIdsSnapshotJson: Value(jsonEncode(sourceIds)),
            createdAt: timestamp,
            updatedAt: timestamp,
          ),
        );

    return SpaceEntity(
      id: id,
      name: sanitizedName,
      normalizedName: normalizedName,
      type: SpaceType.specific,
      description: spaceDescription,
      primaryIntentionType: intentionType,
      createdBy: 'ai',
      confidence: confidence,
      createdAt: timestamp,
      updatedAt: timestamp,
    );
  }

  @override
  Future<SpaceEntity> getOrCreateFallbackSpace({
    required String suggestedName,
    required List<String> sourceIds,
    double? confidence,
  }) async {
    final normalizedName = normalizeSpaceName(_displayName(suggestedName));
    final existing = await findByNormalizedName(normalizedName);
    if (existing != null) {
      return existing;
    }

    return createFallbackSpace(
      name: suggestedName,
      sourceIds: sourceIds,
      confidence: confidence,
    );
  }

  @override
  Future<SpaceEntity> getOrCreateSpecificSpace({
    required String suggestedName,
    required List<String> sourceIds,
    String? description,
    String? primaryIntentionType,
    double? confidence,
  }) async {
    final normalizedName = normalizeSpaceName(_displayName(suggestedName));
    final existing = await findByNormalizedName(normalizedName);
    if (existing != null) {
      return existing;
    }

    return createSpecificSpace(
      name: suggestedName,
      sourceIds: sourceIds,
      description: description,
      primaryIntentionType: primaryIntentionType,
      confidence: confidence,
    );
  }

  SpaceEntity _mapSpace(database_models.Space row) {
    return SpaceEntity(
      id: row.id,
      name: row.name,
      normalizedName: row.normalizedName,
      type: SpaceType.fromStorageValue(row.type),
      description: row.description,
      primaryIntentionType: row.primaryIntentionType,
      createdBy: row.createdBy,
      confidence: row.confidence,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  Value<T?> _nullableValue<T>(T? value) {
    return value == null ? const Value.absent() : Value(value);
  }

  int _timestamp() => _now().toUtc().millisecondsSinceEpoch;
}

String? _nullableTrimmed(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }

  return trimmed;
}

String normalizeSpaceName(String name) {
  final normalized = name.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();
  return normalized.isEmpty ? 'general' : normalized;
}

String _displayName(String name) {
  final normalized = name.trim().replaceAll(RegExp(r'\s+'), ' ');
  return normalized.isEmpty ? 'General' : normalized;
}
