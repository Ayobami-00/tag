import 'package:equatable/equatable.dart';
import 'package:tag/core/use_cases/use_cases.dart';
import 'package:tag/features/onboarding/domain/entities/onboarding_user_profile.dart';
import 'package:tag/features/onboarding/domain/repositories/onboarding_repository.dart';

class SaveNicknameParams extends Equatable {
  const SaveNicknameParams(this.nickname);

  final String nickname;

  @override
  List<Object?> get props => [nickname];
}

class SaveNickname with UseCases<OnboardingUserProfile, SaveNicknameParams> {
  const SaveNickname(this._repository);

  final OnboardingRepository _repository;

  @override
  Future<OnboardingUserProfile> call(SaveNicknameParams params) {
    return _repository.saveNickname(params.nickname);
  }
}
