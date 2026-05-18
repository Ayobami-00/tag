import 'package:tag/core/use_cases/use_cases.dart';
import 'package:tag/features/onboarding/domain/entities/onboarding_user_profile.dart';
import 'package:tag/features/onboarding/domain/repositories/onboarding_repository.dart';

class CompleteOnboarding with UseCases<OnboardingUserProfile, NoParams> {
  const CompleteOnboarding(this._repository);

  final OnboardingRepository _repository;

  @override
  Future<OnboardingUserProfile> call(NoParams params) {
    return _repository.completeOnboarding();
  }
}
