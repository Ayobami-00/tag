import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:tag/core/local_storage/database/tag_database.dart'
    as database_models;
import 'package:tag/features/cards/domain/entities/feedback_entities.dart';
import 'package:tag/features/cards/domain/repositories/feedback_repository.dart';
import 'package:uuid/uuid.dart';

class FeedbackRepositoryImpl implements FeedbackRepository {
  FeedbackRepositoryImpl({
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
  Future<FeedbackEventEntity> storeEvent({
    required FeedbackEventType eventType,
    required Map<String, Object?> details,
    String? cardId,
    String? spaceId,
    String? sourceId,
    String? goalPlanId,
  }) async {
    final id = 'fb_${_uuid.v4()}';
    final createdAt = _timestamp();

    await _database
        .into(_database.feedbackEvents)
        .insert(
          database_models.FeedbackEventsCompanion.insert(
            id: id,
            eventType: eventType.storageValue,
            cardId: _nullableValue(cardId),
            spaceId: _nullableValue(spaceId),
            sourceId: _nullableValue(sourceId),
            goalPlanId: _nullableValue(goalPlanId),
            detailsJson: Value(jsonEncode(details)),
            createdAt: createdAt,
          ),
        );

    final row = await (_database.select(
      _database.feedbackEvents,
    )..where((event) => event.id.equals(id))).getSingle();

    return _mapEvent(row);
  }

  @override
  Future<List<FeedbackEventEntity>> getEventsForCard(String cardId) async {
    final rows =
        await (_database.select(_database.feedbackEvents)
              ..where((event) => event.cardId.equals(cardId))
              ..orderBy([(event) => OrderingTerm.desc(event.createdAt)]))
            .get();

    return rows.map(_mapEvent).toList(growable: false);
  }

  @override
  Future<List<FeedbackEventEntity>> getRecentEvents({int limit = 50}) async {
    final rows =
        await (_database.select(_database.feedbackEvents)
              ..orderBy([(event) => OrderingTerm.desc(event.createdAt)])
              ..limit(limit))
            .get();

    return rows.map(_mapEvent).toList(growable: false);
  }

  FeedbackEventEntity _mapEvent(database_models.FeedbackEvent row) {
    return FeedbackEventEntity(
      id: row.id,
      eventType: FeedbackEventType.fromStorageValue(row.eventType),
      cardId: row.cardId,
      spaceId: row.spaceId,
      sourceId: row.sourceId,
      goalPlanId: row.goalPlanId,
      details: _decodeDetails(row.detailsJson),
      createdAt: row.createdAt,
    );
  }

  Map<String, Object?> _decodeDetails(String detailsJson) {
    try {
      final decoded = jsonDecode(detailsJson);
      if (decoded is Map<String, dynamic>) {
        return Map<String, Object?>.from(decoded);
      }
    } on FormatException {
      return {'raw': detailsJson};
    }

    return const {};
  }

  Value<T?> _nullableValue<T>(T? value) {
    return value == null ? const Value.absent() : Value(value);
  }

  int _timestamp() => _now().toUtc().millisecondsSinceEpoch;
}
