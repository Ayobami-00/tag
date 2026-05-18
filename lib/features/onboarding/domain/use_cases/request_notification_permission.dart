import 'package:equatable/equatable.dart';
import 'package:tag/core/use_cases/use_cases.dart';
import 'package:tag/features/onboarding/domain/entities/onboarding_user_profile.dart';
import 'package:tag/features/onboarding/domain/repositories/onboarding_repository.dart';

class RequestNotificationPermissionParams extends Equatable {
  const RequestNotificationPermissionParams({this.skip = false});

  final bool skip;

  @override
  List<Object?> get props => [skip];
}

class RequestNotificationPermission
    with UseCases<OnboardingUserProfile, RequestNotificationPermissionParams> {
  const RequestNotificationPermission(this._repository);

  final OnboardingRepository _repository;

  @override
  Future<OnboardingUserProfile> call(
    RequestNotificationPermissionParams params,
  ) {
    if (params.skip) {
      return _repository.skipNotificationPermission();
    }

    return _repository.requestNotificationPermission();
  }
}
