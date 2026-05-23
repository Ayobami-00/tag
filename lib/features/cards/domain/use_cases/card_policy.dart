import 'package:tag/features/cards/domain/entities/card_entities.dart';

abstract final class CardPolicy {
  static List<TagCardAction> actionsFor(TagCardType cardType) {
    return switch (cardType) {
      TagCardType.urgent => const [
        TagCardAction.complete,
        TagCardAction.snooze,
        TagCardAction.cancel,
        TagCardAction.viewSpace,
      ],
      TagCardType.goal => const [
        TagCardAction.complete,
        TagCardAction.edit,
        TagCardAction.snooze,
        TagCardAction.viewSpace,
      ],
      TagCardType.suggestion => const [
        TagCardAction.planThis,
        TagCardAction.dismiss,
        TagCardAction.viewSpace,
      ],
    };
  }

  static List<TagCardAction> availableActionsFor(TagCardEntity card) {
    if (card.status == TagCardStatus.processing) {
      return const [];
    }
    if (card.isTerminal) {
      return const [];
    }

    final policyActions = actionsFor(card.cardType);
    final storedActions = card.actions
        .where((action) => policyActions.contains(action))
        .toList(growable: false);

    return storedActions.isEmpty ? policyActions : storedActions;
  }

  static bool supportsAction({
    required TagCardType cardType,
    required TagCardAction action,
  }) {
    return actionsFor(cardType).contains(action);
  }

  static bool notificationEligible({
    required TagCardType cardType,
    required TagCardStatus status,
    required int? nextActiveDeadline,
  }) {
    if (status != TagCardStatus.active || nextActiveDeadline == null) {
      return false;
    }

    return cardType == TagCardType.urgent || cardType == TagCardType.goal;
  }
}
