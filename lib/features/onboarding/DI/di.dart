import 'package:tag/core/DI/di.dart';
import 'package:tag/core/local_storage/database/tag_database.dart';
import 'package:tag/core/notifications/local_notification_permission_service.dart';
import 'package:tag/core/notifications/local_notification_service.dart';
import 'package:tag/features/onboarding/data/data_sources/onboarding_local_data_source.dart';
import 'package:tag/features/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'package:tag/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:tag/features/onboarding/domain/use_cases/complete_onboarding.dart';
import 'package:tag/features/onboarding/domain/use_cases/load_user_profile.dart';
import 'package:tag/features/onboarding/domain/use_cases/request_notification_permission.dart';
import 'package:tag/features/onboarding/domain/use_cases/save_avatar.dart';
import 'package:tag/features/onboarding/domain/use_cases/save_nickname.dart';
import 'package:tag/features/onboarding/presentation/logic/onboarding_cubit.dart';
import 'package:tag/features/model_setup/domain/use_cases/select_primary_model.dart';

void setUpOnboardingDependencies({
  LocalNotificationPermissionService? notificationPermissionService,
}) {
  if (!locator.isRegistered<LocalNotificationPermissionService>()) {
    if (notificationPermissionService != null) {
      locator.registerSingleton<LocalNotificationPermissionService>(
        notificationPermissionService,
      );
    } else {
      locator.registerLazySingleton<LocalNotificationPermissionService>(
        () => locator<LocalNotificationService>(),
      );
    }
  }

  if (!locator.isRegistered<OnboardingLocalDataSource>()) {
    locator.registerLazySingleton<OnboardingLocalDataSource>(
      () => DriftOnboardingLocalDataSource(locator<TagDatabase>()),
    );
  }

  if (!locator.isRegistered<OnboardingRepository>()) {
    locator.registerLazySingleton<OnboardingRepository>(
      () => OnboardingRepositoryImpl(
        localDataSource: locator<OnboardingLocalDataSource>(),
        notificationPermissionService:
            locator<LocalNotificationPermissionService>(),
      ),
    );
  }

  if (!locator.isRegistered<LoadUserProfile>()) {
    locator.registerLazySingleton(
      () => LoadUserProfile(locator<OnboardingRepository>()),
    );
  }

  if (!locator.isRegistered<SaveNickname>()) {
    locator.registerLazySingleton(
      () => SaveNickname(locator<OnboardingRepository>()),
    );
  }

  if (!locator.isRegistered<SaveAvatar>()) {
    locator.registerLazySingleton(
      () => SaveAvatar(locator<OnboardingRepository>()),
    );
  }

  if (!locator.isRegistered<RequestNotificationPermission>()) {
    locator.registerLazySingleton(
      () => RequestNotificationPermission(locator<OnboardingRepository>()),
    );
  }

  if (!locator.isRegistered<CompleteOnboarding>()) {
    locator.registerLazySingleton(
      () => CompleteOnboarding(locator<OnboardingRepository>()),
    );
  }

  if (!locator.isRegistered<OnboardingCubit>()) {
    locator.registerFactory(
      () => OnboardingCubit(
        loadUserProfile: locator<LoadUserProfile>(),
        saveNickname: locator<SaveNickname>(),
        saveAvatar: locator<SaveAvatar>(),
        requestNotificationPermission: locator<RequestNotificationPermission>(),
        completeOnboarding: locator<CompleteOnboarding>(),
        selectPrimaryModel: locator<SelectPrimaryModel>(),
      ),
    );
  }
}
