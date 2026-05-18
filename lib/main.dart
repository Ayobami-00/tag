import 'package:flutter/widgets.dart';

import 'package:tag/app.dart';
import 'package:tag/core/index.dart';
import 'package:tag/features/cards/domain/use_cases/handle_notification_action.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setUpAppLocator();
  await locator<LocalNotificationService>().initialize(
    onAction: locator<HandleNotificationAction>(),
  );

  runApp(const App());
}
