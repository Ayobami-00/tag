import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tag/core/DI/di.dart';
import 'package:tag/core/config/app_config.dart';
import 'package:tag/features/beta_feedback/index.dart';
import 'package:tag/utils/theme/tag_theme.dart';

void main() {
  late _FakeBetaFeedbackRepository repository;

  setUp(() async {
    await locator.reset();
    repository = _FakeBetaFeedbackRepository();
    locator
      ..registerSingleton<AppConfig>(
        AppConfig(
          betaFeedbackEnabled: true,
          betaFeedbackEndpoint:
              'https://example.supabase.co/functions/v1/submit-beta-report',
          betaFeedbackAnonKey: 'anon-key',
          autoDownloadRequiredModels: false,
        ),
      )
      ..registerSingleton<SubmitBetaFeedbackReport>(
        SubmitBetaFeedbackReport(repository),
      )
      ..registerSingleton<PickBetaFeedbackScreenshot>(
        PickBetaFeedbackScreenshot(repository),
      )
      ..registerFactory(
        () => BetaFeedbackCubit(
          submitBetaFeedbackReport: locator<SubmitBetaFeedbackReport>(),
          pickBetaFeedbackScreenshot: locator<PickBetaFeedbackScreenshot>(),
        ),
      );
  });

  tearDown(locator.reset);

  testWidgets('does not expose GitHub details on the submission page', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: TagTheme.lightTheme, home: const BetaFeedbackScreen()),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('GitHub', findRichText: true), findsNothing);
    expect(
      find.textContaining('Public issue', findRichText: true),
      findsNothing,
    );

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Debug copy mentions tracker details');
    await tester.enterText(fields.at(1), 'The screen should stay private.');
    await tester.enterText(fields.at(2), 'No public tracker details.');
    await tester.ensureVisible(fields.at(3));
    await tester.enterText(fields.at(3), 'Open the beta feedback form.');

    await tester.ensureVisible(find.byType(CheckboxListTile));
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pumpAndSettle();

    final sendButton = find.text('Send report');
    await tester.dragUntilVisible(
      sendButton,
      find.byType(ListView),
      const Offset(0, -120),
      maxIteration: 20,
    );
    await tester.tap(sendButton);
    await tester.pumpAndSettle();

    expect(repository.submitted, isTrue);
    expect(find.text('Report received privately'), findsOneWidget);
    expect(
      find.text('The Tag team will triage it from the private beta queue.'),
      findsOneWidget,
    );
    expect(find.textContaining('GitHub', findRichText: true), findsNothing);
    expect(
      find.textContaining('Public issue', findRichText: true),
      findsNothing,
    );
  });
}

class _FakeBetaFeedbackRepository implements BetaFeedbackRepository {
  bool submitted = false;

  @override
  Future<BetaFeedbackAttachment?> pickScreenshot() async => null;

  @override
  Future<BetaFeedbackSubmissionResult> submitReport(
    BetaFeedbackReportDraft draft, {
    required String currentSurface,
  }) async {
    submitted = true;
    return const BetaFeedbackSubmissionResult(
      reportId: 'report_123',
      publicIssueUrl: 'https://github.com/Ayobami-00/tag/issues/123',
      publicIssueNumber: 123,
    );
  }
}
