import 'package:tag/features/beta_feedback/domain/entities/beta_feedback_entities.dart';

abstract class BetaFeedbackAttachmentPicker {
  Future<BetaFeedbackAttachment?> pickScreenshot();
}
