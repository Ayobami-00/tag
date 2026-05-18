import 'dart:io';

import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:tag/core/local_storage/database/tag_database.dart';

Future<void> main(List<String> args) async {
  final outputPath = args.isEmpty
      ? 'artifacts/milestone_03_drift_database_schema_migrations/'
            'schema_tables.txt'
      : args.first;
  final output = File(outputPath);
  final tempDirectory = await Directory.systemTemp.createTemp(
    'tag_schema_dump_',
  );
  final database = TagDatabase.forTesting(
    NativeDatabase(File(p.join(tempDirectory.path, 'tag.sqlite'))),
  );

  try {
    final tables = await database.listUserTables();
    final appTables = tables.where(TagDatabase.appTableNames.contains).toList()
      ..sort();

    await output.parent.create(recursive: true);
    await output.writeAsString('${appTables.join('\n')}\n');
  } finally {
    await database.close();
    await tempDirectory.delete(recursive: true);
  }
}
