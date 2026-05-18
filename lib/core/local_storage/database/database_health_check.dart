import 'package:tag/core/local_storage/database/tag_database.dart';

class DatabaseHealthStatus {
  const DatabaseHealthStatus({
    required this.isHealthy,
    required this.schemaVersion,
    required this.tableNames,
    this.errorMessage,
  });

  final bool isHealthy;
  final int schemaVersion;
  final List<String> tableNames;
  final String? errorMessage;

  bool get hasAllAppTables {
    return TagDatabase.appTableNames.every(tableNames.contains);
  }
}

abstract interface class DatabaseHealthCheck {
  Future<DatabaseHealthStatus> check();
}

class DriftDatabaseHealthCheck implements DatabaseHealthCheck {
  const DriftDatabaseHealthCheck(this._database);

  final TagDatabase _database;

  @override
  Future<DatabaseHealthStatus> check() async {
    try {
      final integrityRows = await _database
          .customSelect('PRAGMA integrity_check')
          .get();
      final integrityValue = integrityRows.first.data.values.first;
      final tableNames = await _database.listUserTables();
      final hasAllTables = TagDatabase.appTableNames.every(tableNames.contains);

      return DatabaseHealthStatus(
        isHealthy: integrityValue == 'ok' && hasAllTables,
        schemaVersion: _database.schemaVersion,
        tableNames: tableNames,
        errorMessage: hasAllTables ? null : 'Missing required app tables.',
      );
    } catch (error) {
      return DatabaseHealthStatus(
        isHealthy: false,
        schemaVersion: _database.schemaVersion,
        tableNames: const [],
        errorMessage: error.toString(),
      );
    }
  }
}
