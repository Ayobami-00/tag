import 'dart:convert';

import 'package:tag/core/local_storage/database/tag_database.dart'
    as database_models;
import 'package:tag/features/cards/domain/entities/card_entities.dart';
import 'package:tag/features/cards/domain/use_cases/card_policy.dart';
import 'package:tag/features/source_ingestion/domain/entities/source_item_entity.dart';
import 'package:tag/features/spaces/data/data_sources/spaces_local_data_source.dart';
import 'package:tag/features/spaces/domain/entities/space_entities.dart';
import 'package:tag/features/spaces/domain/repositories/spaces_repository.dart';

class SpacesRepositoryImpl implements SpacesRepository {
  SpacesRepositoryImpl({
    required SpacesLocalDataSource localDataSource,
    DateTime Function()? now,
  }) : _localDataSource = localDataSource,
       _now = now ?? DateTime.now;

  final SpacesLocalDataSource _localDataSource;
  final DateTime Function() _now;

  @override
  Stream<List<SpaceSummaryEntity>> watchSpaceSummaries() {
    return _localDataSource.watchSpaceChanges().asyncMap((_) {
      return getSpaceSummaries();
    });
  }

  @override
  Future<List<SpaceSummaryEntity>> getSpaceSummaries() async {
    final records = await _localDataSource.getSpaceSummaries();
    final summaries = records
        .map(_mapSummary)
        .where((summary) => summary.hasCardsOrSources)
        .toList(growable: false);

    return [...summaries]..sort(_compareSummaries);
  }

  @override
  Future<SpaceDetailEntity?> getSpaceDetail(String spaceId) async {
    final record = await _localDataSource.getSpaceDetail(spaceId);
    if (record == null) {
      return null;
    }

    final summary = _mapSummary(
      SpaceSummaryRecord(
        space: record.space,
        cards: record.cards,
        sourceIds: record.sources.map((source) => source.id).toList(),
      ),
    );
    final cards = record.cards
        .map(
          (card) => _mapCard(
            card,
            record.space,
            sourceIds: record.cardSourceIds[card.id] ?? const [],
          ),
        )
        .toList(growable: false);
    final nowMs = _now().toUtc().millisecondsSinceEpoch;
    final activeCards = cards
        .where((card) {
          if (card.status != TagCardStatus.active) {
            return false;
          }

          final attention = card.nextAttentionTime;
          return attention == null || attention <= nowMs;
        })
        .toList(growable: false);
    final upcomingCards = cards
        .where((card) {
          if (card.isTerminal) {
            return false;
          }

          final attention = card.nextAttentionTime;
          return attention != null && attention > nowMs;
        })
        .toList(growable: false);

    return SpaceDetailEntity(
      summary: summary,
      activeCards: activeCards,
      upcomingCards: upcomingCards,
      sources: record.sources.map(_mapSource).toList(growable: false),
    );
  }

  SpaceSummaryEntity _mapSummary(SpaceSummaryRecord record) {
    var activeCardCount = 0;
    var urgentCount = 0;
    var goalCount = 0;
    var suggestionCount = 0;
    int? nextDeadline;
    var updatedAt = record.space.updatedAt;

    for (final card in record.cards) {
      if (card.updatedAt > updatedAt) {
        updatedAt = card.updatedAt;
      }

      final isActive = card.status == TagCardStatus.active.storageValue;
      if (isActive && card.cardType == TagCardType.urgent.storageValue) {
        activeCardCount++;
        urgentCount++;
      } else if (isActive && card.cardType == TagCardType.goal.storageValue) {
        activeCardCount++;
        goalCount++;
      } else if (isActive &&
          card.cardType == TagCardType.suggestion.storageValue) {
        suggestionCount++;
      }

      if (_canCompeteForNextDeadline(card)) {
        final attention = card.snoozedUntil ?? card.nextActiveDeadline;
        if (attention != null &&
            (nextDeadline == null || attention < nextDeadline)) {
          nextDeadline = attention;
        }
      }
    }

    return SpaceSummaryEntity(
      space: _mapSpace(record.space),
      activeCardCount: activeCardCount,
      sourceCount: record.sourceIds.length,
      suggestedPlansCount: suggestionCount,
      urgentCount: urgentCount,
      goalCount: goalCount,
      suggestionCount: suggestionCount,
      nextDeadline: nextDeadline,
      updatedAt: updatedAt,
    );
  }

  TagCardEntity _mapCard(
    database_models.TagCard card,
    database_models.Space space, {
    required List<String> sourceIds,
  }) {
    final cardType = TagCardType.fromStorageValue(card.cardType);
    return TagCardEntity(
      id: card.id,
      cardType: cardType,
      status: TagCardStatus.fromStorageValue(card.status),
      title: card.title,
      reason: card.reason,
      space: _mapSpace(space),
      nextActiveDeadline: card.nextActiveDeadline,
      deadlineTimezone: card.deadlineTimezone,
      snoozedUntil: card.snoozedUntil,
      notificationEnabled: card.notificationEnabled,
      actions: _actionsFromJson(card.actionsJson, cardType),
      confidence: card.confidence,
      sourceSummary: card.sourceSummary,
      evidenceSummary: card.evidenceSummary,
      sourceIds: sourceIds,
      createdBy: card.createdBy,
      parentGoalPlanId: card.parentGoalPlanId,
      modelSlug: card.modelSlug,
      modelOutputJson: card.modelOutputJson,
      metadataJson: card.metadataJson,
      createdAt: card.createdAt,
      updatedAt: card.updatedAt,
      completedAt: card.completedAt,
      cancelledAt: card.cancelledAt,
      dismissedAt: card.dismissedAt,
      archivedAt: card.archivedAt,
    );
  }

  SpaceEntity _mapSpace(database_models.Space row) {
    return SpaceEntity(
      id: row.id,
      name: row.name,
      normalizedName: row.normalizedName,
      type: SpaceType.fromStorageValue(row.type),
      description: row.description,
      primaryIntentionType: row.primaryIntentionType,
      createdBy: row.createdBy,
      confidence: row.confidence,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  SpaceSourceSummaryEntity _mapSource(database_models.SourceItem row) {
    return SpaceSourceSummaryEntity(
      id: row.id,
      type: SourceItemType.fromStorageValue(row.type),
      displaySummary: _sourceDisplaySummary(row),
      appSource: row.appSource,
      contentType: row.contentType,
      createdAt: row.createdAt,
    );
  }

  String _sourceDisplaySummary(database_models.SourceItem row) {
    final summary = row.sourceSummary?.trim();
    if (summary != null && summary.isNotEmpty) {
      return summary;
    }

    final appSource = row.appSource?.trim();
    if (appSource != null && appSource.isNotEmpty) {
      return appSource;
    }

    return switch (SourceItemType.fromStorageValue(row.type)) {
      SourceItemType.image || SourceItemType.screenshot => 'Saved image',
      SourceItemType.text || SourceItemType.chat => 'Saved text',
      SourceItemType.link => 'Saved link',
      SourceItemType.savedPost => 'Saved post',
      SourceItemType.emailText => 'Saved email text',
      SourceItemType.manual => 'Saved source',
    };
  }

  List<TagCardAction> _actionsFromJson(String actionsJson, TagCardType type) {
    try {
      final decoded = jsonDecode(actionsJson);
      if (decoded is List) {
        final actions = decoded
            .whereType<String>()
            .map(TagCardAction.fromStorageValue)
            .toList(growable: false);
        if (actions.isNotEmpty) {
          return actions;
        }
      }
    } on FormatException {
      return CardPolicy.actionsFor(type);
    }

    return CardPolicy.actionsFor(type);
  }

  bool _canCompeteForNextDeadline(database_models.TagCard card) {
    if (card.cardType == TagCardType.suggestion.storageValue) {
      return false;
    }

    return card.status == TagCardStatus.active.storageValue ||
        card.status == TagCardStatus.snoozed.storageValue;
  }

  int _compareSummaries(SpaceSummaryEntity left, SpaceSummaryEntity right) {
    final leftDeadline = left.nextDeadline;
    final rightDeadline = right.nextDeadline;
    if (leftDeadline != null && rightDeadline != null) {
      final deadlineCompare = leftDeadline.compareTo(rightDeadline);
      if (deadlineCompare != 0) {
        return deadlineCompare;
      }
    } else if (leftDeadline != null) {
      return -1;
    } else if (rightDeadline != null) {
      return 1;
    }

    final suggestionCompare = right.suggestedPlansCount.compareTo(
      left.suggestedPlansCount,
    );
    if (suggestionCompare != 0) {
      return suggestionCompare;
    }

    final activeCompare = right.activeCardCount.compareTo(left.activeCardCount);
    if (activeCompare != 0) {
      return activeCompare;
    }

    final sourceCompare = right.sourceCount.compareTo(left.sourceCount);
    if (sourceCompare != 0) {
      return sourceCompare;
    }

    final updatedCompare = right.updatedAt.compareTo(left.updatedAt);
    if (updatedCompare != 0) {
      return updatedCompare;
    }

    return left.space.name.compareTo(right.space.name);
  }
}
