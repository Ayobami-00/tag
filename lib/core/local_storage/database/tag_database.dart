import 'package:drift/drift.dart';
import 'package:tag/core/local_storage/database/tag_database_connection.dart';
import 'package:tag/core/local_storage/database/database_values.dart';
import 'package:tag/core/local_storage/database/tables/index.dart';
import 'package:tag/core/local_storage/migrations/migration_strategy.dart';

part 'tag_database.g.dart';

@DriftDatabase(
  tables: [
    UserProfiles,
    AppSettings,
    SourceItems,
    SourceTextChunks,
    Spaces,
    TagCards,
    CardSources,
    GoalPlans,
    GoalPlanCards,
    ChatSessions,
    ChatMessages,
    FeedbackEvents,
    PreferenceMemory,
    NotificationRequests,
    AiProcessingJobs,
    AiModelAssets,
    RagIndexRecords,
  ],
)
class TagDatabase extends _$TagDatabase {
  TagDatabase() : super(openTagDatabaseConnection());

  TagDatabase.forTesting(super.executor);

  static const currentSchemaVersion = 2;

  static const appTableNames = [
    'ai_model_assets',
    'ai_processing_jobs',
    'app_settings',
    'card_sources',
    'chat_messages',
    'chat_sessions',
    'feedback_events',
    'goal_plan_cards',
    'goal_plans',
    'notification_requests',
    'preference_memory',
    'rag_index_records',
    'source_items',
    'source_text_chunks',
    'spaces',
    'tag_cards',
    'user_profiles',
  ];

  @override
  int get schemaVersion => currentSchemaVersion;

  @override
  MigrationStrategy get migration => tagMigrationStrategy(this);

  Future<List<String>> listUserTables() async {
    final rows = await customSelect(
      "SELECT name FROM sqlite_master WHERE type = 'table' "
      "AND name NOT LIKE 'sqlite_%' ORDER BY name",
    ).get();

    return rows.map((row) => row.read<String>('name')).toList();
  }
}
