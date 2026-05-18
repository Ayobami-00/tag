import 'package:tag/features/onboarding/domain/entities/onboarding_user_profile.dart';

abstract interface class OnboardingRepository {
  Future<OnboardingUserProfile?> loadUserProfile();

  Future<OnboardingUserProfile> saveNickname(String nickname);

  Future<OnboardingUserProfile> saveAvatar({
    required String avatarKind,
    required String avatarValue,
  });

  Future<OnboardingUserProfile> requestNotificationPermission();

  Future<OnboardingUserProfile> skipNotificationPermission();

  Future<OnboardingUserProfile> completeOnboarding();
}
