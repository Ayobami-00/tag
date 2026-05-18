import 'package:drift/drift.dart';
import 'package:tag/core/local_storage/database/tag_database.dart';

abstract interface class CardLocalDataSource {
  Future<void> insertCardWithSources({
    required TagCardsCompanion card,
    required List<CardSourcesCompanion> sources,
  });

  Future<void> softDeleteCard({required String cardId, required int deletedAt});

  Future<void> updateCard({
    required String cardId,
    required TagCardsCompanion changes,
  });
}

class DriftCardLocalDataSource implements CardLocalDataSource {
  const DriftCardLocalDataSource(this._database);

  final TagDatabase _database;

  @override
  Future<void> insertCardWithSources({
    required TagCardsCompanion card,
    required List<CardSourcesCompanion> sources,
  }) async {
    if (sources.isEmpty) {
      throw ArgumentError.value(
        sources,
        'sources',
        'A Tag Card must link to source evidence.',
      );
    }

    final primaryEvidenceCount = sources.where((source) {
      if (!source.role.present) {
        return false;
      }

      return source.role.value == 'primary' ||
          source.role.value == 'chat_created';
    }).length;

    if (primaryEvidenceCount != 1) {
      throw StateError(
        'A Tag Card must have exactly one primary source evidence row.',
      );
    }

    await _database.transaction(() async {
      await _database.into(_database.tagCards).insert(card);
      await _database.batch((batch) {
        batch.insertAll(_database.cardSources, sources);
      });
    });
  }

  @override
  Future<void> softDeleteCard({
    required String cardId,
    required int deletedAt,
  }) async {
    final updatedRows =
        await (_database.update(_database.tagCards)..where((card) {
              return card.id.equals(cardId) & card.deletedAt.isNull();
            }))
            .write(
              TagCardsCompanion(
                deletedAt: Value(deletedAt),
                notificationEnabled: const Value(false),
                updatedAt: Value(deletedAt),
              ),
            );

    if (updatedRows == 0) {
      throw StateError('Tag Card was not found or was already deleted.');
    }
  }

  @override
  Future<void> updateCard({
    required String cardId,
    required TagCardsCompanion changes,
  }) async {
    final updatedRows =
        await (_database.update(_database.tagCards)..where((card) {
              return card.id.equals(cardId) & card.deletedAt.isNull();
            }))
            .write(changes);

    if (updatedRows == 0) {
      throw StateError('Tag Card was not found or was already deleted.');
    }
  }
}
