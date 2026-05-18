import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;

QueryExecutor openTagDatabaseConnection({String fileName = 'tag.sqlite'}) {
  return LazyDatabase(() async {
    final file = File(p.join(Directory.current.path, fileName));

    return NativeDatabase.createInBackground(file);
  });
}
