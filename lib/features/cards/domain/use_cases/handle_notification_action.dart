import 'package:tag/core/notifications/local_notification_service.dart';
import 'package:tag/core/use_cases/use_cases.dart';
import 'package:tag/features/cards/domain/use_cases/cancel_card.dart';
import 'package:tag/features/cards/domain/use_cases/complete_card.dart';
import 'package:tag/features/cards/domain/use_cases/snooze_card.dart';

class HandleNotificationAction
    implements UseCase<void, NotificationActionPayload> {
  const HandleNotificationAction({
    required CompleteCard completeCard,
    required SnoozeCard snoozeCard,
    required CancelCard cancelCard,
    DateTime Function()? now,
  }) : _completeCard = completeCard,
       _snoozeCard = snoozeCard,
       _cancelCard = cancelCard,
       _now = now ?? DateTime.now;

  final CompleteCard _completeCard;
  final SnoozeCard _snoozeCard;
  final CancelCard _cancelCard;
  final DateTime Function() _now;

  @override
  Future<void> call(NotificationActionPayload params) async {
    switch (params.actionId) {
      case 'complete':
        await _completeCard(CompleteCardParams(cardId: params.cardId));
        return;
      case 'snooze':
        await _snoozeCard(
          SnoozeCardParams(
            cardId: params.cardId,
            snoozedUntil: _now().add(const Duration(minutes: 30)),
            optionLabel: 'Notification action',
          ),
        );
        return;
      case 'cancel':
        await _cancelCard(CancelCardParams(cardId: params.cardId));
        return;
      case 'edit':
      case 'open':
        return;
      default:
        return;
    }
  }
}
