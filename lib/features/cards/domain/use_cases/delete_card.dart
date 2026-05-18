import 'package:equatable/equatable.dart';
import 'package:tag/core/notifications/local_notification_service.dart';
import 'package:tag/core/use_cases/use_cases.dart';
import 'package:tag/features/cards/domain/repositories/card_repository.dart';

class DeleteCard implements UseCase<void, DeleteCardParams> {
  const DeleteCard(
    this._repository, {
    LocalNotificationService? notificationService,
  }) : _notificationService = notificationService;

  final CardRepository _repository;
  final LocalNotificationService? _notificationService;

  @override
  Future<void> call(DeleteCardParams params) async {
    await _repository.deleteCard(params.cardId);
    await _notificationService?.cancelCardNotifications(params.cardId);
  }
}

class DeleteCardParams extends Equatable {
  const DeleteCardParams({required this.cardId});

  final String cardId;

  @override
  List<Object?> get props => [cardId];
}
