// ignore_for_file: recursive_getters

import 'package:drift/drift.dart';
import 'package:tag/core/local_storage/database/database_values.dart';

@TableIndex(
  name: 'idx_preference_memory_category_key',
  columns: {#category, #key},
  unique: true,
)
@TableIndex(name: 'idx_preference_memory_confidence', columns: {#confidence})
class PreferenceMemory extends Table {
  @override
  String get tableName => 'preference_memory';

  TextColumn get id => text()();
  TextColumn get category =>
      text().check(category.isIn(TagDatabaseValues.preferenceCategories))();
  TextColumn get key => text()();
  TextColumn get valueJson => text()();
  RealColumn get confidence => real()();
  TextColumn get evidenceEventIdsJson =>
      text().withDefault(const Constant('[]'))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK (confidence >= 0.0 AND confidence <= 1.0)',
  ];
}
