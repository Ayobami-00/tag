import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:tag/core/config/app_config.dart';
import 'package:tag/core/navigation/route_constants.dart';
import 'package:tag/core/notifications/local_notification_permission_service.dart';
import 'package:tag/core/startup/app_cubit.dart';
import 'package:tag/features/ai_processing/domain/services/ai_job_queue_runner.dart';
import 'package:tag/features/model_setup/domain/use_cases/prepare_required_local_models.dart';
import 'package:tag/features/model_setup/domain/repositories/model_setup_repository.dart';
import 'package:tag/core/ai/cactus/cactus_model_service.dart';
import 'package:tag/features/onboarding/domain/entities/onboarding_user_profile.dart';
import 'package:tag/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:tag/features/onboarding/domain/use_cases/load_user_profile.dart';

void main() {
  test(
    'tracks local model preparation while background work is running',
    () async {
      final preparationCompleter = Completer<void>();
      final prepareRepository = _FakeModelPreparationRepository(
        preparationFuture: preparationCompleter.future,
      );
      final cubit = AppCubit(
        appConfig: AppConfig(),
        loadUserProfile: LoadUserProfile(
          _FakeOnboardingRepository(_completedProfile()),
        ),
        prepareRequiredLocalModels: PrepareRequiredLocalModels(
          prepareRepository,
        ),
        aiJobQueueRunner: _FakeAiJobQueueRunner(),
        minimumModelPreparationVisibility: Duration.zero,
      );

      await cubit.start();

      expect(cubit.state.status, AppStartupStatus.ready);
      expect(cubit.state.isPreparingLocalModels, isTrue);
      expect(cubit.state.localModelPreparationProgress?.progress, 0.42);

      preparationCompleter.complete();
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.isPreparingLocalModels, isFalse);
      expect(cubit.state.localModelPreparationProgress, isNull);

      await cubit.close();
    },
  );

  test(
    'starts required model preparation after startup without blocking',
    () async {
      final prepareRepository = _FakeModelPreparationRepository();
      final aiJobQueueRunner = _FakeAiJobQueueRunner();
      final cubit = AppCubit(
        appConfig: AppConfig(),
        loadUserProfile: LoadUserProfile(
          _FakeOnboardingRepository(_completedProfile()),
        ),
        prepareRequiredLocalModels: PrepareRequiredLocalModels(
          prepareRepository,
        ),
        aiJobQueueRunner: aiJobQueueRunner,
        minimumModelPreparationVisibility: Duration.zero,
      );

      await cubit.start();
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.status, AppStartupStatus.ready);
      expect(cubit.state.initialLocation, todayPath);
      expect(prepareRepository.prepareCount, 1);
      expect(aiJobQueueRunner.startCount, 1);

      await cubit.close();
    },
  );

  test(
    'waits for first-run onboarding before preparing required models',
    () async {
      final prepareRepository = _FakeModelPreparationRepository();
      final aiJobQueueRunner = _FakeAiJobQueueRunner();
      final cubit = AppCubit(
        appConfig: AppConfig(),
        loadUserProfile: LoadUserProfile(const _FakeOnboardingRepository(null)),
        prepareRequiredLocalModels: PrepareRequiredLocalModels(
          prepareRepository,
        ),
        aiJobQueueRunner: aiJobQueueRunner,
        minimumModelPreparationVisibility: Duration.zero,
      );

      await cubit.start();
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.status, AppStartupStatus.ready);
      expect(cubit.state.initialLocation, onboardingPath);
      expect(prepareRepository.prepareCount, 0);
      expect(aiJobQueueRunner.startCount, 1);

      cubit.startModelPreparation();
      await Future<void>.delayed(Duration.zero);

      expect(prepareRepository.prepareCount, 1);

      await cubit.close();
    },
  );

  test('can disable automatic model preparation for tests or debug', () async {
    final prepareRepository = _FakeModelPreparationRepository();
    final cubit = AppCubit(
      appConfig: AppConfig(autoDownloadRequiredModels: false),
      loadUserProfile: LoadUserProfile(
        _FakeOnboardingRepository(_completedProfile()),
      ),
      prepareRequiredLocalModels: PrepareRequiredLocalModels(prepareRepository),
      aiJobQueueRunner: _FakeAiJobQueueRunner(),
      minimumModelPreparationVisibility: Duration.zero,
    );

    await cubit.start();
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.status, AppStartupStatus.ready);
    expect(prepareRepository.prepareCount, 0);

    await cubit.close();
  });
}

class _FakeAiJobQueueRunner implements AiJobQueueRunner {
  int startCount = 0;
  int stopCount = 0;

  @override
  bool get isProcessing => false;

  @override
  void start() {
    startCount++;
  }

  @override
  void stop() {
    stopCount++;
  }

  @override
  void requestProcessing() {}

  @override
  Future<void> drain() async {}
}

OnboardingUserProfile _completedProfile() {
  final now = DateTime.utc(2026, 5, 9, 10).millisecondsSinceEpoch;

  return OnboardingUserProfile(
    id: 'local_user',
    nickname: 'Alex',
    avatarKind: 'asset',
    avatarValue: 'memoji_02',
    localOnly: true,
    onboardingCompletedAt: now,
    notificationPermissionState: NotificationPermissionState.unknown,
    createdAt: now,
    updatedAt: now,
  );
}

class _FakeModelPreparationRepository implements ModelSetupRepository {
  _FakeModelPreparationRepository({this.preparationFuture});

  final Future<void>? preparationFuture;
  int prepareCount = 0;

  @override
  Future<void> prepareRequiredModels({
    void Function(ModelPreparationProgress progress)? onProgress,
  }) {
    prepareCount++;
    onProgress?.call(
      const ModelPreparationProgress(
        progress: 0.42,
        statusMessage: 'Downloading local models...',
      ),
    );
    return preparationFuture ?? Future<void>.value();
  }

  @override
  Future<List<LocalAiModelInfo>> discoverModels() {
    throw UnimplementedError();
  }

  @override
  Future<List<LocalAiModelInfo>> loadCachedModels() {
    throw UnimplementedError();
  }

  @override
  Future<void> downloadModel(
    String slug, {
    void Function(ModelDownloadProgress progress)? onProgress,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> initializeModel(String slug) {
    throw UnimplementedError();
  }

  @override
  Future<String> loadSelectedEmbeddingModelSlug() {
    throw UnimplementedError();
  }

  @override
  Future<String> loadSelectedPrimaryModelSlug() {
    throw UnimplementedError();
  }

  @override
  Future<void> selectEmbeddingModel(String slug) {
    throw UnimplementedError();
  }

  @override
  Future<void> selectPrimaryModel(String slug) {
    throw UnimplementedError();
  }
}

class _FakeOnboardingRepository implements OnboardingRepository {
  const _FakeOnboardingRepository(this.profile);

  final OnboardingUserProfile? profile;

  @override
  Future<OnboardingUserProfile?> loadUserProfile() async => profile;

  @override
  Future<OnboardingUserProfile> saveNickname(String nickname) {
    throw UnimplementedError();
  }

  @override
  Future<OnboardingUserProfile> saveAvatar({
    required String avatarKind,
    required String avatarValue,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<OnboardingUserProfile> requestNotificationPermission() {
    throw UnimplementedError();
  }

  @override
  Future<OnboardingUserProfile> skipNotificationPermission() {
    throw UnimplementedError();
  }

  @override
  Future<OnboardingUserProfile> completeOnboarding() {
    throw UnimplementedError();
  }
}
