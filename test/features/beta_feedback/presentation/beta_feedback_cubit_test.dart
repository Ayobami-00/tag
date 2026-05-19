import 'package:flutter_test/flutter_test.dart';
import 'package:tag/features/beta_feedback/index.dart';

void main() {
  test('attaches, removes, and submits a beta report', () async {
    final repository = _FakeBetaFeedbackRepository(
      attachment: const BetaFeedbackAttachment(
        path: '/tmp/screen.png',
        fileName: 'screen.png',
        contentType: 'image/png',
        byteSize: 12,
      ),
    );
    final cubit = BetaFeedbackCubit(
      submitBetaFeedbackReport: SubmitBetaFeedbackReport(repository),
      pickBetaFeedbackScreenshot: PickBetaFeedbackScreenshot(repository),
    );
    addTearDown(cubit.close);

    await cubit.pickScreenshot();
    expect(cubit.state.attachment?.fileName, 'screen.png');

    cubit.removeScreenshot();
    expect(cubit.state.attachment, isNull);

    cubit
      ..areaChanged(BetaFeedbackArea.notifications)
      ..consentChanged(true)
      ..includeDiagnosticsChanged(false);

    await cubit.submit(
      summary: 'Notification fired',
      happened: 'A suggestion scheduled a notification.',
      expected: 'Suggestions should stay in-app only.',
      steps: 'Create a suggestion, wait for notification.',
    );

    expect(cubit.state.status, BetaFeedbackSubmissionStatus.success);
    expect(cubit.state.result?.publicIssueNumber, 123);
    expect(repository.lastDraft?.area, BetaFeedbackArea.notifications);
    expect(repository.lastDraft?.includeDiagnostics, isFalse);
  });
}

class _FakeBetaFeedbackRepository implements BetaFeedbackRepository {
  _FakeBetaFeedbackRepository({this.attachment});

  final BetaFeedbackAttachment? attachment;
  BetaFeedbackReportDraft? lastDraft;

  @override
  Future<BetaFeedbackAttachment?> pickScreenshot() async => attachment;

  @override
  Future<BetaFeedbackSubmissionResult> submitReport(
    BetaFeedbackReportDraft draft, {
    required String currentSurface,
  }) async {
    lastDraft = draft;
    return const BetaFeedbackSubmissionResult(
      reportId: 'report_123',
      publicIssueUrl: 'https://github.com/Ayobami-00/tag/issues/123',
      publicIssueNumber: 123,
    );
  }
}
