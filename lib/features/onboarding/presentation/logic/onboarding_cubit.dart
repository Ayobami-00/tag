import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tag/core/notifications/local_notification_permission_service.dart';
import 'package:tag/core/use_cases/use_cases.dart';
import 'package:tag/core/ai/cactus/cactus_model_registry.dart';
import 'package:tag/features/model_setup/domain/use_cases/select_primary_model.dart';
import 'package:tag/features/onboarding/domain/entities/onboarding_user_profile.dart';
import 'package:tag/features/onboarding/domain/use_cases/complete_onboarding.dart';
import 'package:tag/features/onboarding/domain/use_cases/load_user_profile.dart';
import 'package:tag/features/onboarding/domain/use_cases/request_notification_permission.dart';
import 'package:tag/features/onboarding/domain/use_cases/save_avatar.dart';
import 'package:tag/features/onboarding/domain/use_cases/save_nickname.dart';

part 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit({
    required LoadUserProfile loadUserProfile,
    required SaveNickname saveNickname,
    required SaveAvatar saveAvatar,
    required RequestNotificationPermission requestNotificationPermission,
    required CompleteOnboarding completeOnboarding,
    required SelectPrimaryModel selectPrimaryModel,
  }) : _loadUserProfile = loadUserProfile,
       _saveNickname = saveNickname,
       _saveAvatar = saveAvatar,
       _requestNotificationPermission = requestNotificationPermission,
       _completeOnboarding = completeOnboarding,
       _selectPrimaryModel = selectPrimaryModel,
       super(const OnboardingState());

  final LoadUserProfile _loadUserProfile;
  final SaveNickname _saveNickname;
  final SaveAvatar _saveAvatar;
  final RequestNotificationPermission _requestNotificationPermission;
  final CompleteOnboarding _completeOnboarding;
  final SelectPrimaryModel _selectPrimaryModel;

  Future<void> load() async {
    emit(state.copyWith(status: OnboardingStatus.loading, errorMessage: ''));

    try {
      final profile = await _loadUserProfile(const NoParams());
      final avatarValue = profile?.avatarValue == 'push_pin'
          ? OnboardingState.defaultAvatar
          : profile?.avatarValue ?? OnboardingState.defaultAvatar;
      emit(
        state.copyWith(
          status: OnboardingStatus.ready,
          profile: ProfileValue(profile),
          nickname: profile?.nickname ?? '',
          avatarValue: avatarValue,
          notificationPermissionState:
              profile?.notificationPermissionState ??
              NotificationPermissionState.unknown,
        ),
      );
    } on Object {
      emit(
        state.copyWith(
          status: OnboardingStatus.failure,
          errorMessage: 'Onboarding could not load. Please try again.',
        ),
      );
    }
  }

  void goToStep(OnboardingStep step) {
    final targetIndex = OnboardingStep.values.indexOf(step);
    final furthestIndex = OnboardingStep.values.indexOf(state.furthestStep);

    if (targetIndex > furthestIndex + 1) {
      return;
    }

    emit(
      state.copyWith(
        step: step,
        furthestStep: targetIndex > furthestIndex ? step : state.furthestStep,
        errorMessage: '',
      ),
    );
  }

  void updateNickname(String nickname) {
    emit(state.copyWith(nickname: nickname, errorMessage: ''));
  }

  void updateAvatar(String avatarValue) {
    emit(state.copyWith(avatarValue: avatarValue, errorMessage: ''));
  }

  Future<void> saveNicknameAndContinue() async {
    final nickname = state.nickname.trim();
    if (nickname.isEmpty) {
      emit(state.copyWith(errorMessage: 'Choose a nickname to continue.'));
      return;
    }

    emit(state.copyWith(status: OnboardingStatus.saving, errorMessage: ''));

    try {
      final profile = await _saveNickname(SaveNicknameParams(nickname));
      emit(
        state.copyWith(
          status: OnboardingStatus.ready,
          step: OnboardingStep.avatar,
          furthestStep: OnboardingStep.avatar,
          profile: ProfileValue(profile),
          nickname: profile.nickname,
        ),
      );
    } on Object {
      emit(
        state.copyWith(
          status: OnboardingStatus.failure,
          errorMessage: 'Nickname could not be saved. Please try again.',
        ),
      );
    }
  }

  Future<void> saveAvatarAndContinue() async {
    emit(state.copyWith(status: OnboardingStatus.saving, errorMessage: ''));

    try {
      final profile = await _saveAvatar(
        SaveAvatarParams(avatarKind: 'asset', avatarValue: state.avatarValue),
      );
      emit(
        state.copyWith(
          status: OnboardingStatus.ready,
          step: OnboardingStep.localFirst,
          furthestStep: OnboardingStep.localFirst,
          profile: ProfileValue(profile),
          avatarValue: profile.avatarValue,
        ),
      );
    } on Object {
      emit(
        state.copyWith(
          status: OnboardingStatus.failure,
          errorMessage: 'Avatar could not be saved. Please try again.',
        ),
      );
    }
  }

  Future<void> requestNotifications() {
    return _setNotificationPreference(skip: false);
  }

  Future<void> chooseFastLocalSetup() {
    return _selectLocalSetupAndContinue(
      CactusModelRegistry.fastPrimary.modelSlug,
    );
  }

  Future<void> chooseBestQualityLocalSetup() {
    return _selectLocalSetupAndContinue(
      CactusModelRegistry.qualityPrimary.modelSlug,
    );
  }

  Future<void> _selectLocalSetupAndContinue(String modelSlug) async {
    emit(state.copyWith(status: OnboardingStatus.saving, errorMessage: ''));

    try {
      await _selectPrimaryModel(SelectPrimaryModelParams(modelSlug));
      emit(
        state.copyWith(
          status: OnboardingStatus.ready,
          step: OnboardingStep.notifications,
          furthestStep: OnboardingStep.notifications,
        ),
      );
    } on Object {
      emit(
        state.copyWith(
          status: OnboardingStatus.failure,
          errorMessage: 'Local model setup could not be saved. Try again.',
        ),
      );
    }
  }

  Future<void> skipNotifications() {
    return _setNotificationPreference(skip: true);
  }

  Future<void> _setNotificationPreference({required bool skip}) async {
    emit(state.copyWith(status: OnboardingStatus.saving, errorMessage: ''));

    try {
      final profile = await _requestNotificationPermission(
        RequestNotificationPermissionParams(skip: skip),
      );
      emit(
        state.copyWith(
          status: OnboardingStatus.ready,
          step: OnboardingStep.share,
          furthestStep: OnboardingStep.share,
          profile: ProfileValue(profile),
          notificationPermissionState: profile.notificationPermissionState,
        ),
      );
    } on Object {
      emit(
        state.copyWith(
          status: OnboardingStatus.failure,
          errorMessage:
              'Notification preference could not be saved. Please try again.',
        ),
      );
    }
  }

  Future<void> complete() async {
    emit(state.copyWith(status: OnboardingStatus.saving, errorMessage: ''));

    try {
      final profile = await _completeOnboarding(const NoParams());
      emit(
        state.copyWith(
          status: OnboardingStatus.completed,
          profile: ProfileValue(profile),
        ),
      );
    } on Object {
      emit(
        state.copyWith(
          status: OnboardingStatus.failure,
          errorMessage: 'Onboarding could not finish. Please try again.',
        ),
      );
    }
  }
}
