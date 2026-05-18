import 'package:tag/core/ai/schemas/card_proposal_schema.dart';
import 'package:tag/features/cards/domain/entities/card_entities.dart';
import 'package:tag/features/cards/domain/entities/card_query.dart';

abstract interface class CardRepository {
  Future<TagCardEntity> createFromProposal({
    required CardProposal proposal,
    String? modelSlug,
  });

  Future<void> deleteCard(String id);

  Future<TagCardEntity?> getCardById(String id);

  Stream<List<TagCardEntity>> watchCards(CardListQuery query);

  Future<List<TagCardEntity>> getCards(CardListQuery query);

  Future<CardActionResult> completeCard(String id);

  Future<CardActionResult> snoozeCard({
    required String id,
    required DateTime snoozedUntil,
  });

  Future<CardActionResult> cancelCard(String id);

  Future<CardActionResult> dismissSuggestion(String id);

  Future<CardActionResult> archiveCard(String id);
}
