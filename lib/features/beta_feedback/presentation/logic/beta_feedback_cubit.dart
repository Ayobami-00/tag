import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tag/core/use_cases/use_cases.dart';
import 'package:tag/features/beta_feedback/domain/entities/beta_feedback_entities.dart';
import 'package:tag/features/beta_feedback/domain/use_cases/pick_beta_feedback_screenshot.dart';
import 'package:tag/features/beta_feedback/domain/use_cases/submit_beta_feedback_report.dart';
import 'package:tag/features/beta_feedback/presentation/logic/beta_feedback_state.dart';

class BetaFeedbackCubit extends Cubit<BetaFeedbackState> {
  BetaFeedbackCubit({
    required SubmitBetaFeedbackReport submitBetaFeedbackReport,
    required PickBetaFeedbackScreenshot pickBetaFeedbackScreenshot,
  }) : _submitBetaFeedbackReport = submitBetaFeedbackReport,
       _pickBetaFeedbackScreenshot = pickBetaFeedbackScreenshot,
       super(const BetaFeedbackState());

  final SubmitBetaFeedbackReport _submitBetaFeedbackReport;
  final PickBetaFeedbackScreenshot _pickBetaFeedbackScreenshot;

  void areaChanged(BetaFeedbackArea area) {
    emit(state.copyWith(area: area, status: BetaFeedbackSubmissionStatus.idle));
  }

  void consentChanged(bool value) {
    emit(
      state.copyWith(
        consentPrivateReview: value,
        status: BetaFeedbackSubmissionStatus.idle,
      ),
    );
  }

  void includeDiagnosticsChanged(bool value) {
    emit(
      state.copyWith(
        includeDiagnostics: value,
        status: BetaFeedbackSubmissionStatus.idle,
      ),
    );
  }

  Future<void> pickScreenshot() async {
    try {
      final attachment = await _pickBetaFeedbackScreenshot(const NoParams());
      if (attachment == null) {
        return;
      }
      emit(
        state.copyWith(
          attachment: attachment,
          status: BetaFeedbackSubmissionStatus.idle,
          clearError: true,
        ),
      );
    } on Object {
      emit(
        state.copyWith(
          status: BetaFeedbackSubmissionStatus.failure,
          errorMessage: 'Tag could not attach that screenshot.',
        ),
      );
    }
  }

  void removeScreenshot() {
    emit(
      state.copyWith(
        clearAttachment: true,
        status: BetaFeedbackSubmissionStatus.idle,
        clearError: true,
      ),
    );
  }

  Future<void> submit({
    required String summary,
    required String happened,
    required String expected,
    required String steps,
    String? contactEmail,
  }) async {
    emit(
      state.copyWith(
        status: BetaFeedbackSubmissionStatus.submitting,
        clearError: true,
        clearResult: true,
      ),
    );

    final draft = BetaFeedbackReportDraft(
      summary: summary,
      happened: happened,
      expected: expected,
      steps: steps,
      area: state.area,
      contactEmail: contactEmail,
      consentPrivateReview: state.consentPrivateReview,
      attachments: [if (state.attachment != null) state.attachment!],
      includeDiagnostics: state.includeDiagnostics,
    );

    try {
      final result = await _submitBetaFeedbackReport(
        SubmitBetaFeedbackReportParams(
          draft: draft,
          currentSurface: 'settings/beta-feedback',
        ),
      );
      emit(
        state.copyWith(
          status: BetaFeedbackSubmissionStatus.success,
          result: result,
          clearError: true,
        ),
      );
    } on BetaFeedbackException catch (error) {
      emit(
        state.copyWith(
          status: BetaFeedbackSubmissionStatus.failure,
          errorMessage: error.message,
        ),
      );
    } on Object {
      emit(
        state.copyWith(
          status: BetaFeedbackSubmissionStatus.failure,
          errorMessage: 'Tag could not send the beta report. Please try again.',
        ),
      );
    }
  }
}
