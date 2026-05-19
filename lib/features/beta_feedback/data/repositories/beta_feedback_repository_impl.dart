import 'package:tag/features/beta_feedback/data/data_sources/supabase_beta_feedback_data_source.dart';
import 'package:tag/features/beta_feedback/domain/entities/beta_feedback_entities.dart';
import 'package:tag/features/beta_feedback/domain/repositories/beta_feedback_repository.dart';
import 'package:tag/features/beta_feedback/domain/services/beta_feedback_attachment_picker.dart';
import 'package:tag/features/beta_feedback/domain/services/beta_feedback_diagnostics_collector.dart';

class BetaFeedbackRepositoryImpl implements BetaFeedbackRepository {
  const BetaFeedbackRepositoryImpl({
    required SupabaseBetaFeedbackDataSource remoteDataSource,
    required BetaFeedbackAttachmentPicker attachmentPicker,
    required BetaFeedbackDiagnosticsCollector diagnosticsCollector,
  }) : _remoteDataSource = remoteDataSource,
       _attachmentPicker = attachmentPicker,
       _diagnosticsCollector = diagnosticsCollector;

  final SupabaseBetaFeedbackDataSource _remoteDataSource;
  final BetaFeedbackAttachmentPicker _attachmentPicker;
  final BetaFeedbackDiagnosticsCollector _diagnosticsCollector;

  @override
  Future<BetaFeedbackAttachment?> pickScreenshot() {
    return _attachmentPicker.pickScreenshot();
  }

  @override
  Future<BetaFeedbackSubmissionResult> submitReport(
    BetaFeedbackReportDraft draft, {
    required String currentSurface,
  }) async {
    final diagnostics = await _diagnosticsCollector.collect(
      currentSurface: currentSurface,
    );
    return _remoteDataSource.submit(draft: draft, diagnostics: diagnostics);
  }
}
