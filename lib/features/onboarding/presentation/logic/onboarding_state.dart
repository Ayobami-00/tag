part of 'onboarding_cubit.dart';

enum OnboardingStatus { initial, loading, ready, saving, completed, failure }

enum OnboardingStep {
  welcome,
  nickname,
  avatar,
  localFirst,
  notifications,
  share,
}

class ProfileValue extends Equatable {
  const ProfileValue(this.value);

  final OnboardingUserProfile? value;

  @override
  List<Object?> get props => [value];
}

class OnboardingState extends Equatable {
  const OnboardingState({
    this.status = OnboardingStatus.initial,
    this.step = OnboardingStep.welcome,
    this.furthestStep = OnboardingStep.welcome,
    this.nickname = '',
    this.avatarValue = defaultAvatar,
    this.notificationPermissionState = NotificationPermissionState.unknown,
    this.profile,
    this.errorMessage = '',
  });

  static const defaultAvatar = 'memoji_02';

  final OnboardingStatus status;
  final OnboardingStep step;
  final OnboardingStep furthestStep;
  final String nickname;
  final String avatarValue;
  final NotificationPermissionState notificationPermissionState;
  final OnboardingUserProfile? profile;
  final String errorMessage;

  bool get isBusy =>
      status == OnboardingStatus.loading || status == OnboardingStatus.saving;

  OnboardingState copyWith({
    OnboardingStatus? status,
    OnboardingStep? step,
    OnboardingStep? furthestStep,
    String? nickname,
    String? avatarValue,
    NotificationPermissionState? notificationPermissionState,
    ProfileValue? profile,
    String? errorMessage,
  }) {
    return OnboardingState(
      status: status ?? this.status,
      step: step ?? this.step,
      furthestStep: furthestStep ?? this.furthestStep,
      nickname: nickname ?? this.nickname,
      avatarValue: avatarValue ?? this.avatarValue,
      notificationPermissionState:
          notificationPermissionState ?? this.notificationPermissionState,
      profile: profile == null ? this.profile : profile.value,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    step,
    furthestStep,
    nickname,
    avatarValue,
    notificationPermissionState,
    profile,
    errorMessage,
  ];
}
