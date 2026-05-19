import 'package:tag/core/use_cases/use_cases.dart';
import 'package:tag/features/beta_feedback/domain/entities/beta_feedback_entities.dart';
import 'package:tag/features/beta_feedback/domain/repositories/beta_feedback_repository.dart';

class PickBetaFeedbackScreenshot
    implements UseCase<BetaFeedbackAttachment?, NoParams> {
  const PickBetaFeedbackScreenshot(this._repository);

  final BetaFeedbackRepository _repository;

  @override
  Future<BetaFeedbackAttachment?> call(NoParams params) {
    return _repository.pickScreenshot();
  }
}
