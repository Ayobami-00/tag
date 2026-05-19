import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tag/core/DI/di.dart';
import 'package:tag/core/config/app_config.dart';
import 'package:tag/features/beta_feedback/DI/di.dart';
import 'package:tag/features/beta_feedback/presentation/screens/beta_feedback_screen.dart';
import 'package:tag/utils/theme/tag_theme.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const runLive = bool.fromEnvironment('TAG_LIVE_BETA_FEEDBACK_E2E');
  const endpoint = String.fromEnvironment('TAG_BETA_FEEDBACK_ENDPOINT');
  const anonKey = String.fromEnvironment('TAG_BETA_FEEDBACK_ANON_KEY');

  tearDown(() async {
    await locator.reset();
  });

  testWidgets(
    'submits beta feedback from the Flutter UI to the live intake',
    (tester) async {
      await locator.reset();
      locator.registerSingleton<AppConfig>(
        AppConfig(
          betaFeedbackEnabled: true,
          betaFeedbackEndpoint: endpoint,
          betaFeedbackAnonKey: anonKey,
          appVersion: '1.0.0',
          buildNumber: '1',
          commitSha: 'live-app-e2e',
          autoDownloadRequiredModels: false,
        ),
      );
      setUpBetaFeedbackDependencies();

      await tester.pumpWidget(
        MaterialApp(
          theme: TagTheme.lightTheme,
          home: const BetaFeedbackScreen(),
        ),
      );
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.enterText(
        fields.at(0),
        'No internal beta debug icon near the Tag title',
      );
      await tester.enterText(
        fields.at(1),
        'The Today header has the Tag title, but there is no small beta feedback/debug icon near it.',
      );
      await tester.enterText(
        fields.at(2),
        'Internal beta builds should expose a small unobtrusive bug/report icon from Today.',
      );
      await tester.ensureVisible(fields.at(3));
      await tester.pumpAndSettle();
      await tester.enterText(
        fields.at(3),
        'Open an internal beta/debug build of Tag and look at the Today app bar.',
      );
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();

      final consentTile = find.byType(CheckboxListTile);
      await tester.ensureVisible(consentTile);
      await tester.pumpAndSettle();

      await tester.tap(consentTile);
      await tester.pumpAndSettle();

      final sendButton = find.text('Send report');
      await tester.dragUntilVisible(
        sendButton,
        find.byType(ListView),
        const Offset(0, -120),
        maxIteration: 20,
      );
      await tester.pumpAndSettle();
      await tester.tap(sendButton);
      await _pumpUntilFound(
        tester,
        find.text('Report received privately'),
        timeout: const Duration(seconds: 30),
      );

      expect(find.text('Report received privately'), findsOneWidget);
      expect(find.textContaining('Public issue:'), findsOneWidget);
    },
    skip: !runLive || endpoint.isEmpty || anonKey.isEmpty,
  );
}

Future<void> _pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  required Duration timeout,
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    await tester.pump(const Duration(milliseconds: 250));
    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }
  throw TestFailure('Timed out waiting for expected widget.');
}
