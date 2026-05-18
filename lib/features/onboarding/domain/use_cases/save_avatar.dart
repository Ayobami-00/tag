import 'package:equatable/equatable.dart';
import 'package:tag/core/use_cases/use_cases.dart';
import 'package:tag/features/onboarding/domain/entities/onboarding_user_profile.dart';
import 'package:tag/features/onboarding/domain/repositories/onboarding_repository.dart';

class SaveAvatarParams extends Equatable {
  const SaveAvatarParams({required this.avatarKind, required this.avatarValue});

  final String avatarKind;
  final String avatarValue;

  @override
  List<Object?> get props => [avatarKind, avatarValue];
}

class SaveAvatar with UseCases<OnboardingUserProfile, SaveAvatarParams> {
  const SaveAvatar(this._repository);

  final OnboardingRepository _repository;

  @override
  Future<OnboardingUserProfile> call(SaveAvatarParams params) {
    return _repository.saveAvatar(
      avatarKind: params.avatarKind,
      avatarValue: params.avatarValue,
    );
  }
}
