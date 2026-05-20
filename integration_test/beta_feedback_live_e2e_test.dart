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
        'Local runner issue creation queue smoke test ${DateTime.now().millisecondsSinceEpoch}',
      );
      await tester.enterText(
        fields.at(1),
        'The live app test submitted feedback that should stay private until the local runner creates a sanitized issue.',
      );
      await tester.enterText(
        fields.at(2),
        'The report should be stored privately and queued for the local runner.',
      );
      await tester.ensureVisible(fields.at(3));
      await tester.pumpAndSettle();
      await tester.enterText(
        fields.at(3),
        'Open beta feedback, complete required fields, consent, submit, then run the local Codex runner.',
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
      expect(
        find.text(
          'A local runner will create the sanitized GitHub issue from this private report.',
        ),
        findsOneWidget,
      );
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
