import 'package:tag/core/DI/di.dart';
import 'package:tag/core/config/app_config.dart';
import 'package:tag/features/beta_feedback/data/data_sources/supabase_beta_feedback_data_source.dart';
import 'package:tag/features/beta_feedback/data/repositories/beta_feedback_repository_impl.dart';
import 'package:tag/features/beta_feedback/data/services/file_picker_beta_feedback_attachment_picker.dart';
import 'package:tag/features/beta_feedback/data/services/local_beta_feedback_diagnostics_collector.dart';
import 'package:tag/features/beta_feedback/domain/repositories/beta_feedback_repository.dart';
import 'package:tag/features/beta_feedback/domain/services/beta_feedback_attachment_picker.dart';
import 'package:tag/features/beta_feedback/domain/services/beta_feedback_diagnostics_collector.dart';
import 'package:tag/features/beta_feedback/domain/use_cases/pick_beta_feedback_screenshot.dart';
import 'package:tag/features/beta_feedback/domain/use_cases/submit_beta_feedback_report.dart';
import 'package:tag/features/beta_feedback/presentation/logic/beta_feedback_cubit.dart';

void setUpBetaFeedbackDependencies() {
  if (!locator.isRegistered<SupabaseBetaFeedbackDataSource>()) {
    locator.registerLazySingleton(
      () => SupabaseBetaFeedbackDataSource(appConfig: locator<AppConfig>()),
    );
  }

  if (!locator.isRegistered<BetaFeedbackAttachmentPicker>()) {
    locator.registerLazySingleton<BetaFeedbackAttachmentPicker>(
      FilePickerBetaFeedbackAttachmentPicker.new,
    );
  }

  if (!locator.isRegistered<BetaFeedbackDiagnosticsCollector>()) {
    locator.registerLazySingleton<BetaFeedbackDiagnosticsCollector>(
      () => LocalBetaFeedbackDiagnosticsCollector(locator<AppConfig>()),
    );
  }

  if (!locator.isRegistered<BetaFeedbackRepository>()) {
    locator.registerLazySingleton<BetaFeedbackRepository>(
      () => BetaFeedbackRepositoryImpl(
        remoteDataSource: locator<SupabaseBetaFeedbackDataSource>(),
        attachmentPicker: locator<BetaFeedbackAttachmentPicker>(),
        diagnosticsCollector: locator<BetaFeedbackDiagnosticsCollector>(),
      ),
    );
  }

  if (!locator.isRegistered<SubmitBetaFeedbackReport>()) {
    locator.registerLazySingleton(
      () => SubmitBetaFeedbackReport(locator<BetaFeedbackRepository>()),
    );
  }

  if (!locator.isRegistered<PickBetaFeedbackScreenshot>()) {
    locator.registerLazySingleton(
      () => PickBetaFeedbackScreenshot(locator<BetaFeedbackRepository>()),
    );
  }

  if (!locator.isRegistered<BetaFeedbackCubit>()) {
    locator.registerFactory(
      () => BetaFeedbackCubit(
        submitBetaFeedbackReport: locator<SubmitBetaFeedbackReport>(),
        pickBetaFeedbackScreenshot: locator<PickBetaFeedbackScreenshot>(),
      ),
    );
  }
}
