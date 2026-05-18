import 'package:drift/drift.dart';

class AiModelAssets extends Table {
  @override
  String get tableName => 'ai_model_assets';

  TextColumn get slug => text()();
  TextColumn get displayName => text()();
  TextColumn get capabilitiesJson => text().withDefault(const Constant('[]'))();
  RealColumn get sizeMb => real().nullable()();
  TextColumn get quantization => text().nullable()();
  BoolColumn get isDownloaded => boolean().withDefault(const Constant(false))();
  BoolColumn get isInitialized =>
      boolean().withDefault(const Constant(false))();
  TextColumn get localPath => text().nullable()();
  IntColumn get lastCheckedAt => integer().nullable()();
  IntColumn get lastInitializedAt => integer().nullable()();
  TextColumn get failureReason => text().nullable()();
  TextColumn get downloadStatus =>
      text().withDefault(const Constant('not_downloaded'))();
  RealColumn get downloadProgress => real().nullable()();
  TextColumn get downloadStatusMessage => text().nullable()();
  IntColumn get downloadStartedAt => integer().nullable()();
  IntColumn get downloadCompletedAt => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {slug};
}
