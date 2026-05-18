import 'package:equatable/equatable.dart';
import 'package:tag/core/notifications/local_notification_service.dart';
import 'package:tag/core/use_cases/use_cases.dart';
import 'package:tag/features/cards/domain/entities/card_entities.dart';
import 'package:tag/features/cards/domain/repositories/card_repository.dart';
import 'package:tag/features/cards/domain/use_cases/card_notification_snapshot.dart';
import 'package:tag/features/cards/domain/use_cases/store_feedback_event.dart';
import 'package:tag/features/cards/domain/use_cases/update_preference_memory.dart';

class SnoozeCard implements UseCase<TagCardEntity, SnoozeCardParams> {
  const SnoozeCard({
    required CardRepository cardRepository,
    required StoreFeedbackEvent storeFeedbackEvent,
    required UpdatePreferenceMemory updatePreferenceMemory,
    LocalNotificationService? notificationService,
  }) : _cardRepository = cardRepository,
       _storeFeedbackEvent = storeFeedbackEvent,
       _updatePreferenceMemory = updatePreferenceMemory,
       _notificationService = notificationService;

  final CardRepository _cardRepository;
  final StoreFeedbackEvent _storeFeedbackEvent;
  final UpdatePreferenceMemory _updatePreferenceMemory;
  final LocalNotificationService? _notificationService;

  @override
  Future<TagCardEntity> call(SnoozeCardParams params) async {
    final result = await _cardRepository.snoozeCard(
      id: params.cardId,
      snoozedUntil: params.snoozedUntil,
    );
    final snoozeMinutes = params.snoozedUntil
        .toUtc()
        .difference(
          DateTime.fromMillisecondsSinceEpoch(result.actionAt, isUtc: true),
        )
        .inMinutes;
    final event = await _storeFeedbackEvent(
      StoreFeedbackEventParams.fromCardAction(
        result,
        extraDetails: {
          'snoozed_until': params.snoozedUntil.toUtc().millisecondsSinceEpoch,
          'snooze_minutes': snoozeMinutes,
          if (params.optionLabel != null) 'option_label': params.optionLabel,
        },
      ),
    );
    await _updatePreferenceMemory(
      UpdatePreferenceMemoryParams(
        event: event,
        card: result.card,
        previousCard: result.previousCard,
      ),
    );
    await _notificationService?.scheduleCardNotification(
      notificationSnapshotFor(result.card),
    );

    return result.card;
  }
}

class SnoozeCardParams extends Equatable {
  const SnoozeCardParams({
    required this.cardId,
    required this.snoozedUntil,
    this.optionLabel,
  });

  final String cardId;
  final DateTime snoozedUntil;
  final String? optionLabel;

  @override
  List<Object?> get props => [cardId, snoozedUntil, optionLabel];
}
