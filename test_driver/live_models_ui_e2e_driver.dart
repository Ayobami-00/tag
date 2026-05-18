// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';
import 'package:path/path.dart' as p;

Future<void> main() async {
  final outputDirectory = Directory(p.join('artifacts', 'live_ui_e2e'));
  await outputDirectory.create(recursive: true);

  await integrationDriver(
    writeResponseOnFailure: true,
    onScreenshot:
        (String name, List<int> image, [Map<String, Object?>? args]) async {
          final file = File(p.join(outputDirectory.path, '$name.png'));
          await file.writeAsBytes(image, flush: true);
          print('TAG_LIVE_UI_E2E_HOST_SCREENSHOT ${file.path}');
          return true;
        },
    responseDataCallback: (data) async {
      final file = File(
        p.join(outputDirectory.path, 'integration_response_data.json'),
      );
      await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(data),
        flush: true,
      );
      print('TAG_LIVE_UI_E2E_HOST_RESPONSE ${file.path}');
    },
  );
}
