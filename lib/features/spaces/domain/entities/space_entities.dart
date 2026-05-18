import 'package:equatable/equatable.dart';
import 'package:tag/features/cards/domain/entities/card_entities.dart';
import 'package:tag/features/source_ingestion/domain/entities/source_item_entity.dart';

class SpaceSummaryEntity extends Equatable {
  const SpaceSummaryEntity({
    required this.space,
    required this.activeCardCount,
    required this.sourceCount,
    required this.suggestedPlansCount,
    required this.urgentCount,
    required this.goalCount,
    required this.suggestionCount,
    required this.updatedAt,
    this.nextDeadline,
  });

  final SpaceEntity space;
  final int activeCardCount;
  final int sourceCount;
  final int suggestedPlansCount;
  final int urgentCount;
  final int goalCount;
  final int suggestionCount;
  final int updatedAt;
  final int? nextDeadline;

  bool get hasCardsOrSources => activeCardCount > 0 || sourceCount > 0;

  SpaceDominantSignal get dominantSignal {
    if (urgentCount > 0) {
      return SpaceDominantSignal.urgent;
    }
    if (goalCount > 0) {
      return SpaceDominantSignal.goal;
    }
    if (suggestionCount > 0) {
      return SpaceDominantSignal.suggestion;
    }
    return SpaceDominantSignal.neutral;
  }

  @override
  List<Object?> get props => [
    space,
    activeCardCount,
    sourceCount,
    suggestedPlansCount,
    urgentCount,
    goalCount,
    suggestionCount,
    updatedAt,
    nextDeadline,
  ];
}

enum SpaceDominantSignal { urgent, goal, suggestion, neutral }

class SpaceSourceSummaryEntity extends Equatable {
  const SpaceSourceSummaryEntity({
    required this.id,
    required this.type,
    required this.displaySummary,
    required this.contentType,
    required this.createdAt,
    this.appSource,
  });

  final String id;
  final SourceItemType type;
  final String displaySummary;
  final String contentType;
  final int createdAt;
  final String? appSource;

  String get displayTypeLabel {
    return switch (type) {
      SourceItemType.screenshot => 'Screenshot',
      SourceItemType.image => 'Image',
      SourceItemType.link => 'Link',
      SourceItemType.text => 'Text',
      SourceItemType.chat => 'Chat',
      SourceItemType.savedPost => 'Saved post',
      SourceItemType.emailText => 'Email text',
      SourceItemType.manual => 'Manual',
    };
  }

  @override
  List<Object?> get props => [
    id,
    type,
    displaySummary,
    contentType,
    createdAt,
    appSource,
  ];
}

class SpaceDetailEntity extends Equatable {
  const SpaceDetailEntity({
    required this.summary,
    required this.activeCards,
    required this.upcomingCards,
    required this.sources,
  });

  final SpaceSummaryEntity summary;
  final List<TagCardEntity> activeCards;
  final List<TagCardEntity> upcomingCards;
  final List<SpaceSourceSummaryEntity> sources;

  @override
  List<Object?> get props => [summary, activeCards, upcomingCards, sources];
}
