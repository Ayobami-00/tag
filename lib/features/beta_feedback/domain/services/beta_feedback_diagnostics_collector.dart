import 'package:tag/features/beta_feedback/domain/entities/beta_feedback_entities.dart';

abstract class BetaFeedbackDiagnosticsCollector {
  Future<BetaFeedbackDiagnostics> collect({required String currentSurface});
}
