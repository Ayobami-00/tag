import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tag/core/config/app_config.dart';
import 'package:tag/core/navigation/route_constants.dart';
import 'package:tag/core/use_cases/use_cases.dart';
import 'package:tag/features/ai_processing/domain/services/ai_job_queue_runner.dart';
import 'package:tag/features/model_setup/domain/repositories/model_setup_repository.dart';
import 'package:tag/features/model_setup/domain/use_cases/prepare_required_local_models.dart';
import 'package:tag/features/onboarding/domain/use_cases/load_user_profile.dart';

enum AppStartupStatus { initial, ready }

class AppState extends Equatable {
  const AppState({
    this.status = AppStartupStatus.initial,
    this.initialLocation = todayPath,
    this.isLocalFirst = true,
    this.isPreparingLocalModels = false,
    this.localModelPreparationProgress,
  });

  final AppStartupStatus status;
  final String initialLocation;
  final bool isLocalFirst;
  final bool isPreparingLocalModels;
  final ModelPreparationProgress? localModelPreparationProgress;

  AppState copyWith({
    AppStartupStatus? status,
    String? initialLocation,
    bool? isLocalFirst,
    bool? isPreparingLocalModels,
    ModelPreparationProgress? localModelPreparationProgress,
    bool clearLocalModelPreparationProgress = false,
  }) {
    return AppState(
      status: status ?? this.status,
      initialLocation: initialLocation ?? this.initialLocation,
      isLocalFirst: isLocalFirst ?? this.isLocalFirst,
      isPreparingLocalModels:
          isPreparingLocalModels ?? this.isPreparingLocalModels,
      localModelPreparationProgress: clearLocalModelPreparationProgress
          ? null
          : localModelPreparationProgress ?? this.localModelPreparationProgress,
    );
  }

  @override
  List<Object?> get props => [
    status,
    initialLocation,
    isLocalFirst,
    isPreparingLocalModels,
    localModelPreparationProgress,
  ];
}

class AppCubit extends Cubit<AppState> {
  AppCubit({
    required AppConfig appConfig,
    required LoadUserProfile loadUserProfile,
    required PrepareRequiredLocalModels prepareRequiredLocalModels,
    required AiJobQueueRunner aiJobQueueRunner,
    Duration minimumModelPreparationVisibility =
        _defaultMinimumModelPreparationVisibility,
  }) : _appConfig = appConfig,
       _loadUserProfile = loadUserProfile,
       _prepareRequiredLocalModels = prepareRequiredLocalModels,
       _aiJobQueueRunner = aiJobQueueRunner,
       _minimumModelPreparationVisibility = minimumModelPreparationVisibility,
       super(AppState(isLocalFirst: appConfig.localFirst));

  final AppConfig _appConfig;
  final LoadUserProfile _loadUserProfile;
  final PrepareRequiredLocalModels _prepareRequiredLocalModels;
  final AiJobQueueRunner _aiJobQueueRunner;
  final Duration _minimumModelPreparationVisibility;
  bool _hasStartedModelPreparation = false;
  static const Duration _defaultMinimumModelPreparationVisibility = Duration(
    milliseconds: 2500,
  );

  Future<void> start() async {
    if (state.status == AppStartupStatus.ready) {
      return;
    }

    var initialLocation = onboardingPath;

    try {
      final profile = await _loadUserProfile(const NoParams());
      initialLocation = profile?.isOnboardingComplete == true
          ? todayPath
          : onboardingPath;
    } on Object {
      initialLocation = onboardingPath;
    }

    emit(
      state.copyWith(
        status: AppStartupStatus.ready,
        initialLocation: initialLocation,
        isLocalFirst: _appConfig.localFirst,
      ),
    );

    _aiJobQueueRunner.start();
    if (initialLocation == todayPath) {
      startModelPreparation();
    }
  }

  void startModelPreparation() {
    if (!_appConfig.autoDownloadRequiredModels || _hasStartedModelPreparation) {
      return;
    }

    _hasStartedModelPreparation = true;
    final startedAt = DateTime.now();
    emit(
      state.copyWith(
        isPreparingLocalModels: true,
        localModelPreparationProgress: const ModelPreparationProgress(
          statusMessage: 'Checking local setup...',
        ),
      ),
    );
    unawaited(
      _prepareRequiredLocalModels
          .withProgress(
            onProgress: (progress) {
              if (!isClosed) {
                emit(state.copyWith(localModelPreparationProgress: progress));
              }
            },
          )
          .then((_) {
            _aiJobQueueRunner.requestProcessing();
          })
          .catchError((Object _) {})
          .whenComplete(() {
            return _finishModelPreparationState(startedAt);
          }),
    );
  }

  Future<void> _finishModelPreparationState(DateTime startedAt) async {
    final remainingVisibility =
        _minimumModelPreparationVisibility -
        DateTime.now().difference(startedAt);
    if (remainingVisibility > Duration.zero) {
      await Future<void>.delayed(remainingVisibility);
    }

    if (!isClosed) {
      emit(
        state.copyWith(
          isPreparingLocalModels: false,
          clearLocalModelPreparationProgress: true,
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _aiJobQueueRunner.stop();
    return super.close();
  }
}
