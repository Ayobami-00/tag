import 'package:equatable/equatable.dart';
import 'package:tag/core/notifications/local_notification_permission_service.dart';

class OnboardingUserProfile extends Equatable {
  const OnboardingUserProfile({
    required this.id,
    required this.nickname,
    required this.avatarKind,
    required this.avatarValue,
    required this.localOnly,
    required this.notificationPermissionState,
    required this.createdAt,
    required this.updatedAt,
    this.onboardingCompletedAt,
  });

  final String id;
  final String nickname;
  final String avatarKind;
  final String avatarValue;
  final bool localOnly;
  final int? onboardingCompletedAt;
  final NotificationPermissionState notificationPermissionState;
  final int createdAt;
  final int updatedAt;

  bool get isOnboardingComplete => onboardingCompletedAt != null;

  @override
  List<Object?> get props => [
    id,
    nickname,
    avatarKind,
    avatarValue,
    localOnly,
    onboardingCompletedAt,
    notificationPermissionState,
    createdAt,
    updatedAt,
  ];
}
