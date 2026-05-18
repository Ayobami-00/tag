// ignore_for_file: recursive_getters

import 'package:drift/drift.dart';
import 'package:tag/core/local_storage/database/database_values.dart';

@TableIndex(name: 'idx_spaces_type', columns: {#type})
@TableIndex(name: 'idx_spaces_updated_at', columns: {#updatedAt})
@TableIndex(name: 'idx_spaces_normalized_name', columns: {#normalizedName})
class Spaces extends Table {
  @override
  String get tableName => 'spaces';

  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get normalizedName => text()();
  TextColumn get type =>
      text().check(type.isIn(TagDatabaseValues.spaceTypes))();
  TextColumn get description => text().nullable()();
  TextColumn get primaryIntentionType => text().nullable()();
  TextColumn get createdBy =>
      text().check(createdBy.isIn(TagDatabaseValues.spaceCreatedBy))();
  RealColumn get confidence => real().nullable()();
  TextColumn get sourceIdsSnapshotJson =>
      text().withDefault(const Constant('[]'))();
  TextColumn get metadataJson => text().withDefault(const Constant('{}'))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get archivedAt => integer().nullable()();
  IntColumn get deletedAt => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {normalizedName},
  ];

  @override
  List<String> get customConstraints => [
    'CHECK (confidence IS NULL OR (confidence >= 0.0 AND confidence <= 1.0))',
  ];
}
