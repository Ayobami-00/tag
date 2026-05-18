import 'package:drift/drift.dart';
import 'package:tag/core/ai/cactus/cactus_model_registry.dart';

MigrationStrategy tagMigrationStrategy(GeneratedDatabase database) {
  return MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
      await _seedLocalOnlyDefaults(database);
    },
    onUpgrade: (migrator, from, to) async {
      if (from == to) {
        return;
      }

      if (from < 2) {
        await database.customStatement(
          "ALTER TABLE ai_model_assets ADD COLUMN download_status "
          "TEXT NOT NULL DEFAULT 'not_downloaded'",
        );
        await database.customStatement(
          'ALTER TABLE ai_model_assets ADD COLUMN download_progress REAL',
        );
        await database.customStatement(
          'ALTER TABLE ai_model_assets ADD COLUMN download_status_message TEXT',
        );
        await database.customStatement(
          'ALTER TABLE ai_model_assets ADD COLUMN download_started_at INTEGER',
        );
        await database.customStatement(
          'ALTER TABLE ai_model_assets ADD COLUMN download_completed_at INTEGER',
        );
      }

      if (to <= 2) {
        return;
      }

      throw StateError(
        'No Tag database migration is registered from schema $from to $to.',
      );
    },
    beforeOpen: (details) async {
      await database.customStatement('PRAGMA foreign_keys = ON');
    },
  );
}

Future<void> _seedLocalOnlyDefaults(GeneratedDatabase database) async {
  final now = DateTime.now().toUtc().millisecondsSinceEpoch;

  await database.customStatement(
    'INSERT OR IGNORE INTO app_settings '
    '(key, value_json, updated_at) VALUES (?, ?, ?)',
    ['local_only_mode', 'true', now],
  );
  await database.customStatement(
    'INSERT OR IGNORE INTO app_settings '
    '(key, value_json, updated_at) VALUES (?, ?, ?)',
    ['cactus_telemetry_enabled', 'false', now],
  );
  await database.customStatement(
    'INSERT OR IGNORE INTO app_settings '
    '(key, value_json, updated_at) VALUES (?, ?, ?)',
    [
      'selected_model_slug',
      '"${CactusModelRegistry.defaultPrimaryModelSlug}"',
      now,
    ],
  );
  await database.customStatement(
    'INSERT OR IGNORE INTO app_settings '
    '(key, value_json, updated_at) VALUES (?, ?, ?)',
    [
      'selected_embedding_model_slug',
      '"${CactusModelRegistry.defaultEmbeddingModelSlug}"',
      now,
    ],
  );
}
