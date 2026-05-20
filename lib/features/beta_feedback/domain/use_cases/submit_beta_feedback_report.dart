import 'package:equatable/equatable.dart';
import 'package:tag/core/use_cases/use_cases.dart';
import 'package:tag/features/beta_feedback/domain/entities/beta_feedback_entities.dart';
import 'package:tag/features/beta_feedback/domain/repositories/beta_feedback_repository.dart';

class SubmitBetaFeedbackReport
    implements
        UseCase<BetaFeedbackSubmissionResult, SubmitBetaFeedbackReportParams> {
  const SubmitBetaFeedbackReport(this._repository);

  static const int maxAttachmentCount = 1;
  static const int maxAttachmentBytes = 8 * 1024 * 1024;

  final BetaFeedbackRepository _repository;

  @override
  Future<BetaFeedbackSubmissionResult> call(
    SubmitBetaFeedbackReportParams params,
  ) async {
    final draft = params.draft;
    _validateText('Summary', draft.summary);
    _validateText('What happened', draft.happened);
    _validateText('What you expected', draft.expected);
    _validateText('Steps to reproduce', draft.steps);

    if (!draft.consentPrivateReview) {
      throw const BetaFeedbackException(
        'Please confirm the private beta review notice before sending.',
      );
    }

    if (draft.attachments.length > maxAttachmentCount) {
      throw const BetaFeedbackException(
        'Attach one screenshot at most for a beta report.',
      );
    }

    for (final attachment in draft.attachments) {
      if (!attachment.isImage) {
        throw const BetaFeedbackException(
          'Only image screenshots can be attached to beta reports.',
        );
      }
      if (attachment.byteSize > maxAttachmentBytes) {
        throw const BetaFeedbackException(
          'The screenshot is over 8 MB. Please choose a smaller image.',
        );
      }
    }

    return _repository.submitReport(
      draft,
      currentSurface: params.currentSurface,
    );
  }

  void _validateText(String label, String value) {
    if (value.trim().length < 3) {
      throw BetaFeedbackException('$label needs a little more detail.');
    }
  }
}

class SubmitBetaFeedbackReportParams extends Equatable {
  const SubmitBetaFeedbackReportParams({
    required this.draft,
    required this.currentSurface,
  });

  final BetaFeedbackReportDraft draft;
  final String currentSurface;

  @override
  List<Object?> get props => [draft, currentSurface];
}
