import 'package:drift/drift.dart';
import 'package:tag/core/local_storage/database/tag_database_connection_io.dart'
    if (dart.library.ui) 'package:tag/core/local_storage/database/tag_database_connection_flutter.dart'
    as connection;

QueryExecutor openTagDatabaseConnection({String fileName = 'tag.sqlite'}) {
  return connection.openTagDatabaseConnection(fileName: fileName);
}
