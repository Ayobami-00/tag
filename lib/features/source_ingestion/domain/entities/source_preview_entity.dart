import 'package:equatable/equatable.dart';
import 'package:tag/features/cards/domain/entities/card_entities.dart';
import 'package:tag/features/source_ingestion/domain/entities/source_item_entity.dart';

class SourcePreviewEntity extends Equatable {
  const SourcePreviewEntity({required this.source, required this.relatedCards});

  final SourceItemEntity source;
  final List<SourcePreviewRelatedCardEntity> relatedCards;

  SourcePreviewRelatedCardEntity? relatedCardFor(String? cardId) {
    if (cardId == null || cardId.trim().isEmpty) {
      return relatedCards.isEmpty ? null : relatedCards.first;
    }

    for (final relatedCard in relatedCards) {
      if (relatedCard.cardId == cardId) {
        return relatedCard;
      }
    }

    return relatedCards.isEmpty ? null : relatedCards.first;
  }

  @override
  List<Object?> get props => [source, relatedCards];
}

class SourcePreviewRelatedCardEntity extends Equatable {
  const SourcePreviewRelatedCardEntity({
    required this.cardId,
    required this.cardType,
    required this.status,
    required this.title,
    required this.reason,
    required this.space,
    required this.sourceSummary,
    required this.evidenceSummary,
    required this.role,
    required this.createdAt,
    this.nextActiveDeadline,
    this.evidenceText,
  });

  final String cardId;
  final TagCardType cardType;
  final TagCardStatus status;
  final String title;
  final String reason;
  final SpaceEntity space;
  final int? nextActiveDeadline;
  final String sourceSummary;
  final String evidenceSummary;
  final String role;
  final String? evidenceText;
  final int createdAt;

  bool get isActive => status == TagCardStatus.active;

  @override
  List<Object?> get props => [
    cardId,
    cardType,
    status,
    title,
    reason,
    space,
    nextActiveDeadline,
    sourceSummary,
    evidenceSummary,
    role,
    evidenceText,
    createdAt,
  ];
}
