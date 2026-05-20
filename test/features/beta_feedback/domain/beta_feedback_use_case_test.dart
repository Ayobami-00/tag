import 'package:flutter_test/flutter_test.dart';
import 'package:tag/features/beta_feedback/index.dart';

void main() {
  test('submits a valid private beta report through the repository', () async {
    final repository = _FakeBetaFeedbackRepository();
    final useCase = SubmitBetaFeedbackReport(repository);
    final draft = _validDraft();

    final result = await useCase(
      SubmitBetaFeedbackReportParams(
        draft: draft,
        currentSurface: 'settings/beta-feedback',
      ),
    );

    expect(result.reportId, 'report_123');
    expect(repository.lastDraft, draft);
    expect(repository.lastSurface, 'settings/beta-feedback');
  });

  test('requires consent before private beta submission', () async {
    final useCase = SubmitBetaFeedbackReport(_FakeBetaFeedbackRepository());

    await expectLater(
      useCase(
        SubmitBetaFeedbackReportParams(
          draft: _validDraft(consentPrivateReview: false),
          currentSurface: 'settings/beta-feedback',
        ),
      ),
      throwsA(isA<BetaFeedbackException>()),
    );
  });

  test('rejects oversized screenshots before upload', () async {
    final useCase = SubmitBetaFeedbackReport(_FakeBetaFeedbackRepository());

    await expectLater(
      useCase(
        SubmitBetaFeedbackReportParams(
          draft: _validDraft(
            attachments: const [
              BetaFeedbackAttachment(
                path: '/tmp/large.png',
                fileName: 'large.png',
                contentType: 'image/png',
                byteSize: SubmitBetaFeedbackReport.maxAttachmentBytes + 1,
              ),
            ],
          ),
          currentSurface: 'settings/beta-feedback',
        ),
      ),
      throwsA(isA<BetaFeedbackException>()),
    );
  });
}

BetaFeedbackReportDraft _validDraft({
  bool consentPrivateReview = true,
  List<BetaFeedbackAttachment> attachments = const [],
}) {
  return BetaFeedbackReportDraft(
    summary: 'Source preview is blank',
    happened: 'The source preview opened without content.',
    expected: 'The source preview should show the saved screenshot.',
    steps: 'Import a screenshot, open the card, then open source.',
    area: BetaFeedbackArea.sourceEvidence,
    consentPrivateReview: consentPrivateReview,
    attachments: attachments,
  );
}

class _FakeBetaFeedbackRepository implements BetaFeedbackRepository {
  BetaFeedbackReportDraft? lastDraft;
  String? lastSurface;

  @override
  Future<BetaFeedbackAttachment?> pickScreenshot() async => null;

  @override
  Future<BetaFeedbackSubmissionResult> submitReport(
    BetaFeedbackReportDraft draft, {
    required String currentSurface,
  }) async {
    lastDraft = draft;
    lastSurface = currentSurface;
    return const BetaFeedbackSubmissionResult(
      reportId: 'report_123',
      publicIssueUrl: 'https://github.com/Ayobami-00/tag/issues/123',
      publicIssueNumber: 123,
    );
  }
}
