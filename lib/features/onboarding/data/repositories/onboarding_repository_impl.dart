import 'package:tag/core/local_storage/database/tag_database.dart'
    as database_models;
import 'package:tag/core/notifications/local_notification_permission_service.dart';
import 'package:tag/features/onboarding/data/data_sources/onboarding_local_data_source.dart';
import 'package:tag/features/onboarding/domain/entities/onboarding_user_profile.dart';
import 'package:tag/features/onboarding/domain/repositories/onboarding_repository.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  const OnboardingRepositoryImpl({
    required OnboardingLocalDataSource localDataSource,
    required LocalNotificationPermissionService notificationPermissionService,
  }) : _localDataSource = localDataSource,
       _notificationPermissionService = notificationPermissionService;

  final OnboardingLocalDataSource _localDataSource;
  final LocalNotificationPermissionService _notificationPermissionService;

  @override
  Future<OnboardingUserProfile?> loadUserProfile() async {
    final profile = await _localDataSource.loadUserProfile();

    return profile == null ? null : _mapProfile(profile);
  }

  @override
  Future<OnboardingUserProfile> saveNickname(String nickname) async {
    final profile = await _localDataSource.saveNickname(nickname);

    return _mapProfile(profile);
  }

  @override
  Future<OnboardingUserProfile> saveAvatar({
    required String avatarKind,
    required String avatarValue,
  }) async {
    final profile = await _localDataSource.saveAvatar(
      avatarKind: avatarKind,
      avatarValue: avatarValue,
    );

    return _mapProfile(profile);
  }

  @override
  Future<OnboardingUserProfile> requestNotificationPermission() async {
    final permissionState = await _notificationPermissionService
        .requestPermission();
    final profile = await _localDataSource.saveNotificationPermissionState(
      permissionState.storageValue,
    );

    return _mapProfile(profile);
  }

  @override
  Future<OnboardingUserProfile> skipNotificationPermission() async {
    final profile = await _localDataSource.saveNotificationPermissionState(
      NotificationPermissionState.unknown.storageValue,
    );

    return _mapProfile(profile);
  }

  @override
  Future<OnboardingUserProfile> completeOnboarding() async {
    final profile = await _localDataSource.completeOnboarding();

    return _mapProfile(profile);
  }

  OnboardingUserProfile _mapProfile(database_models.UserProfile profile) {
    return OnboardingUserProfile(
      id: profile.id,
      nickname: profile.nickname,
      avatarKind: profile.avatarKind,
      avatarValue: profile.avatarValue,
      localOnly: profile.localOnly,
      onboardingCompletedAt: profile.onboardingCompletedAt,
      notificationPermissionState: NotificationPermissionState.fromStorageValue(
        profile.notificationPermissionState,
      ),
      createdAt: profile.createdAt,
      updatedAt: profile.updatedAt,
    );
  }
}
