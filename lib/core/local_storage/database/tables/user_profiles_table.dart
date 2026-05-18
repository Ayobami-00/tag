// ignore_for_file: recursive_getters

import 'package:drift/drift.dart';
import 'package:tag/core/local_storage/database/database_values.dart';

class UserProfiles extends Table {
  @override
  String get tableName => 'user_profiles';

  TextColumn get id => text()();
  TextColumn get nickname => text()();
  TextColumn get avatarKind =>
      text().check(avatarKind.isIn(TagDatabaseValues.avatarKinds))();
  TextColumn get avatarValue => text()();
  BoolColumn get localOnly => boolean().withDefault(const Constant(true))();
  IntColumn get onboardingCompletedAt => integer().nullable()();
  TextColumn get notificationPermissionState => text()
      .check(
        notificationPermissionState.isIn(
          TagDatabaseValues.notificationPermissionStates,
        ),
      )
      .withDefault(const Constant('unknown'))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => ['CHECK (local_only = 1)'];
}
