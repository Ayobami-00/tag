import 'package:flutter/foundation.dart';

class AppErrorLogger {
  const AppErrorLogger._();

  static void log(Object error, StackTrace stackTrace) {
    if (kDebugMode) {
      FlutterError.reportError(
        FlutterErrorDetails(exception: error, stack: stackTrace),
      );
    }
  }
}
