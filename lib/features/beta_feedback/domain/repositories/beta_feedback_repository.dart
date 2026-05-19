import 'package:tag/features/beta_feedback/domain/entities/beta_feedback_entities.dart';

abstract class BetaFeedbackRepository {
  Future<BetaFeedbackSubmissionResult> submitReport(
    BetaFeedbackReportDraft draft, {
    required String currentSurface,
  });

  Future<BetaFeedbackAttachment?> pickScreenshot();
}
