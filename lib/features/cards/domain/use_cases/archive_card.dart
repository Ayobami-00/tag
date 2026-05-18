import 'package:equatable/equatable.dart';
import 'package:tag/core/notifications/local_notification_service.dart';
import 'package:tag/core/use_cases/use_cases.dart';
import 'package:tag/features/cards/domain/entities/card_entities.dart';
import 'package:tag/features/cards/domain/repositories/card_repository.dart';
import 'package:tag/features/cards/domain/use_cases/store_feedback_event.dart';
import 'package:tag/features/cards/domain/use_cases/update_preference_memory.dart';

class ArchiveCard implements UseCase<TagCardEntity, ArchiveCardParams> {
  const ArchiveCard({
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
  Future<TagCardEntity> call(ArchiveCardParams params) async {
    final result = await _cardRepository.archiveCard(params.cardId);
    final event = await _storeFeedbackEvent(
      StoreFeedbackEventParams.fromCardAction(result),
    );
    await _updatePreferenceMemory(
      UpdatePreferenceMemoryParams(
        event: event,
        card: result.card,
        previousCard: result.previousCard,
      ),
    );
    await _notificationService?.cancelCardNotifications(result.card.id);

    return result.card;
  }
}

class ArchiveCardParams extends Equatable {
  const ArchiveCardParams({required this.cardId});

  final String cardId;

  @override
  List<Object?> get props => [cardId];
}
