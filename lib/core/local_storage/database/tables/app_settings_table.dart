import 'package:drift/drift.dart';

class AppSettings extends Table {
  @override
  String get tableName => 'app_settings';

  TextColumn get key => text()();
  TextColumn get valueJson => text()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}
