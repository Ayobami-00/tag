import 'package:equatable/equatable.dart';
import 'package:tag/core/use_cases/use_cases.dart';
import 'package:tag/features/cards/domain/entities/card_entities.dart';
import 'package:tag/features/cards/domain/entities/feedback_entities.dart';
import 'package:tag/features/cards/domain/repositories/card_repository.dart';
import 'package:tag/features/cards/domain/use_cases/store_feedback_event.dart';
import 'package:tag/features/cards/domain/use_cases/update_preference_memory.dart';

class OpenSourceForCard
    implements UseCase<OpenSourceForCardResult, OpenSourceForCardParams> {
  const OpenSourceForCard({
    required CardRepository cardRepository,
    required StoreFeedbackEvent storeFeedbackEvent,
    required UpdatePreferenceMemory updatePreferenceMemory,
  }) : _cardRepository = cardRepository,
       _storeFeedbackEvent = storeFeedbackEvent,
       _updatePreferenceMemory = updatePreferenceMemory;

  final CardRepository _cardRepository;
  final StoreFeedbackEvent _storeFeedbackEvent;
  final UpdatePreferenceMemory _updatePreferenceMemory;

  @override
  Future<OpenSourceForCardResult> call(OpenSourceForCardParams params) async {
    final card = await _cardRepository.getCardById(params.cardId);
    if (card == null) {
      throw const CardActionException('Tag Card was not found.');
    }

    final sourceId = _resolveSourceId(card, params.sourceId);
    final event = await _storeFeedbackEvent(
      StoreFeedbackEventParams(
        eventType: FeedbackEventType.openSource,
        cardId: card.id,
        spaceId: card.space.id,
        sourceId: sourceId,
        details: {
          'action': FeedbackEventType.openSource.storageValue,
          'card_type': card.cardType.storageValue,
          'status': card.status.storageValue,
          'source_ids': card.sourceIds,
          'opened_source_id': sourceId,
          'opened_from': params.openedFrom,
        },
      ),
    );
    await _updatePreferenceMemory(
      UpdatePreferenceMemoryParams(event: event, card: card),
    );

    return OpenSourceForCardResult(
      sourceId: sourceId,
      card: card,
      feedbackEvent: event,
    );
  }

  String _resolveSourceId(TagCardEntity card, String? requestedSourceId) {
    final normalizedRequested = requestedSourceId?.trim();
    if (normalizedRequested != null && normalizedRequested.isNotEmpty) {
      if (!card.sourceIds.contains(normalizedRequested)) {
        throw const CardActionException(
          'That source is not linked to this Tag Card.',
        );
      }

      return normalizedRequested;
    }

    if (card.sourceIds.isEmpty) {
      throw const CardActionException(
        'This Tag Card does not have source evidence.',
      );
    }

    return card.sourceIds.first;
  }
}

class OpenSourceForCardParams extends Equatable {
  const OpenSourceForCardParams({
    required this.cardId,
    this.sourceId,
    this.openedFrom = 'card_detail',
  });

  final String cardId;
  final String? sourceId;
  final String openedFrom;

  @override
  List<Object?> get props => [cardId, sourceId, openedFrom];
}

class OpenSourceForCardResult extends Equatable {
  const OpenSourceForCardResult({
    required this.sourceId,
    required this.card,
    required this.feedbackEvent,
  });

  final String sourceId;
  final TagCardEntity card;
  final FeedbackEventEntity feedbackEvent;

  @override
  List<Object?> get props => [sourceId, card, feedbackEvent];
}
