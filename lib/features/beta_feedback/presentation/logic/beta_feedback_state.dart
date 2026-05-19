import 'package:equatable/equatable.dart';
import 'package:tag/features/beta_feedback/domain/entities/beta_feedback_entities.dart';

enum BetaFeedbackSubmissionStatus { idle, submitting, success, failure }

class BetaFeedbackState extends Equatable {
  const BetaFeedbackState({
    this.status = BetaFeedbackSubmissionStatus.idle,
    this.area = BetaFeedbackArea.todayCards,
    this.attachment,
    this.includeDiagnostics = true,
    this.consentPrivateReview = false,
    this.errorMessage,
    this.result,
  });

  final BetaFeedbackSubmissionStatus status;
  final BetaFeedbackArea area;
  final BetaFeedbackAttachment? attachment;
  final bool includeDiagnostics;
  final bool consentPrivateReview;
  final String? errorMessage;
  final BetaFeedbackSubmissionResult? result;

  bool get isSubmitting => status == BetaFeedbackSubmissionStatus.submitting;

  BetaFeedbackState copyWith({
    BetaFeedbackSubmissionStatus? status,
    BetaFeedbackArea? area,
    BetaFeedbackAttachment? attachment,
    bool clearAttachment = false,
    bool? includeDiagnostics,
    bool? consentPrivateReview,
    String? errorMessage,
    bool clearError = false,
    BetaFeedbackSubmissionResult? result,
    bool clearResult = false,
  }) {
    return BetaFeedbackState(
      status: status ?? this.status,
      area: area ?? this.area,
      attachment: clearAttachment ? null : attachment ?? this.attachment,
      includeDiagnostics: includeDiagnostics ?? this.includeDiagnostics,
      consentPrivateReview: consentPrivateReview ?? this.consentPrivateReview,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      result: clearResult ? null : result ?? this.result,
    );
  }

  @override
  List<Object?> get props => [
    status,
    area,
    attachment,
    includeDiagnostics,
    consentPrivateReview,
    errorMessage,
    result,
  ];
}
