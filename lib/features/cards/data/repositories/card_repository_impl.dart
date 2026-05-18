import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:tag/core/ai/schemas/card_proposal_schema.dart';
import 'package:tag/core/local_storage/database/data_sources/card_local_data_source.dart';
import 'package:tag/core/local_storage/database/tag_database.dart'
    as database_models;
import 'package:tag/features/cards/data/repositories/space_repository_impl.dart';
import 'package:tag/features/cards/domain/entities/card_entities.dart';
import 'package:tag/features/cards/domain/entities/card_query.dart';
import 'package:tag/features/cards/domain/repositories/card_repository.dart';
import 'package:tag/features/cards/domain/repositories/space_repository.dart';
import 'package:tag/features/cards/domain/use_cases/card_title_normalizer.dart';
import 'package:tag/features/cards/domain/use_cases/card_policy.dart';
import 'package:tag/features/cards/domain/use_cases/create_card_from_proposal.dart';
import 'package:uuid/uuid.dart';

class CardRepositoryImpl implements CardRepository {
  CardRepositoryImpl({
    required database_models.TagDatabase database,
    required CardLocalDataSource localDataSource,
    required SpaceRepository spaceRepository,
    DateTime Function()? now,
    Uuid? uuid,
  }) : _database = database,
       _localDataSource = localDataSource,
       _spaceRepository = spaceRepository,
       _now = now ?? DateTime.now,
       _uuid = uuid ?? const Uuid();

  final database_models.TagDatabase _database;
  final CardLocalDataSource _localDataSource;
  final SpaceRepository _spaceRepository;
  final DateTime Function() _now;
  final Uuid _uuid;

  @override
  Future<TagCardEntity> createFromProposal({
    required CardProposal proposal,
    String? modelSlug,
  }) async {
    if (proposal.cardType == 'passive') {
      throw const CardCreationException(
        'Passive proposals do not create Tag Cards.',
      );
    }

    final cardType = TagCardType.fromStorageValue(proposal.cardType);
    final sourceIds = _uniqueNonEmpty(proposal.sourceIds);
    if (sourceIds.isEmpty) {
      throw const CardCreationException(
        'A Tag Card must link to source evidence.',
      );
    }

    final sources = await _loadSources(sourceIds);
    if (sources.length != sourceIds.length) {
      throw const CardCreationException(
        'Card proposal source_ids must reference existing local sources.',
      );
    }

    final space = await _spaceRepository.getOrCreateFallbackSpace(
      suggestedName: proposal.spaceName,
      sourceIds: sourceIds,
      confidence: proposal.confidence,
    );
    final title = normalizeTagCardTitle(proposal.title);
    final nextActiveDeadline = _deadlineMillis(proposal.nextActiveDeadline);
    final status = TagCardStatus.active;
    final actions = CardPolicy.actionsFor(cardType);
    final notificationEnabled = CardPolicy.notificationEligible(
      cardType: cardType,
      status: status,
      nextActiveDeadline: nextActiveDeadline,
    );
    final timestamp = _timestamp();
    final duplicate = await _findEquivalentAttentionCard(
      cardType: cardType,
      title: title,
      spaceId: space.id,
      nextActiveDeadline: nextActiveDeadline,
    );
    if (duplicate != null) {
      await _attachSourcesToExistingCard(
        card: duplicate,
        sourceIds: sourceIds,
        sources: sources,
        timestamp: timestamp,
      );
      final existing = await _loadCardById(duplicate.id);
      if (existing == null) {
        throw const CardCreationException(
          'Existing duplicate card was not readable.',
        );
      }

      return existing;
    }

    final cardId = 'card_${_uuid.v4()}';

    await _localDataSource.insertCardWithSources(
      card: database_models.TagCardsCompanion.insert(
        id: cardId,
        cardType: cardType.storageValue,
        status: Value(status.storageValue),
        title: title,
        reason: proposal.reason,
        spaceId: space.id,
        nextActiveDeadline: _nullableValue(nextActiveDeadline),
        deadlineTimezone: _nullableValue(
          nextActiveDeadline == null ? null : _now().timeZoneName,
        ),
        notificationEnabled: Value(notificationEnabled),
        actionsJson: Value(
          jsonEncode(actions.map((action) => action.storageValue).toList()),
        ),
        confidence: Value(proposal.confidence),
        sourceSummary: _sourceSummary(sources),
        evidenceSummary: _evidenceSummary(sources),
        createdBy: 'ai',
        modelSlug: _nullableValue(modelSlug),
        modelOutputJson: Value(jsonEncode(proposal.toJson())),
        metadataJson: Value(
          jsonEncode({
            'created_from': 'validated_card_proposal',
            'space_normalized_name': normalizeSpaceName(space.name),
          }),
        ),
        createdAt: timestamp,
        updatedAt: timestamp,
      ),
      sources: [
        for (var index = 0; index < sourceIds.length; index++)
          database_models.CardSourcesCompanion.insert(
            cardId: cardId,
            sourceId: sourceIds[index],
            role: index == 0 ? 'primary' : 'supporting',
            evidenceText: _nullableValue(_evidenceTextFor(sources[index])),
            createdAt: timestamp,
          ),
      ],
    );

    final created = await _loadCardById(cardId);
    if (created == null) {
      throw const CardCreationException(
        'Created card was not readable after insert.',
      );
    }

    return created;
  }

  Future<database_models.TagCard?> _findEquivalentAttentionCard({
    required TagCardType cardType,
    required String title,
    required String spaceId,
    required int? nextActiveDeadline,
  }) {
    final query = _database.select(_database.tagCards)
      ..where((card) {
        final sameCard =
            card.cardType.equals(cardType.storageValue) &
            card.status.isIn([
              TagCardStatus.active.storageValue,
              TagCardStatus.snoozed.storageValue,
            ]) &
            card.title.equals(title) &
            card.spaceId.equals(spaceId) &
            card.deletedAt.isNull() &
            card.archivedAt.isNull();

        if (nextActiveDeadline == null) {
          return sameCard & card.nextActiveDeadline.isNull();
        }

        return sameCard & card.nextActiveDeadline.equals(nextActiveDeadline);
      })
      ..orderBy([
        (card) =>
            OrderingTerm(expression: card.createdAt, mode: OrderingMode.asc),
      ])
      ..limit(1);

    return query.getSingleOrNull();
  }

  Future<void> _attachSourcesToExistingCard({
    required database_models.TagCard card,
    required List<String> sourceIds,
    required List<database_models.SourceItem> sources,
    required int timestamp,
  }) async {
    final existingSourceIds = await _sourceIdsForCard(card.id);
    final existingSet = existingSourceIds.toSet();
    final sourceById = {for (final source in sources) source.id: source};
    final missingSourceIds = [
      for (final sourceId in sourceIds)
        if (!existingSet.contains(sourceId) && sourceById[sourceId] != null)
          sourceId,
    ];
    if (missingSourceIds.isEmpty) {
      return;
    }

    await _database.transaction(() async {
      await _database.batch((batch) {
        batch.insertAll(_database.cardSources, [
          for (final sourceId in missingSourceIds)
            database_models.CardSourcesCompanion.insert(
              cardId: card.id,
              sourceId: sourceId,
              role: 'supporting',
              evidenceText: _nullableValue(
                _evidenceTextFor(sourceById[sourceId]!),
              ),
              createdAt: timestamp,
            ),
        ]);
      });

      final allSources = await _loadSources([
        ...existingSourceIds,
        ...missingSourceIds,
      ]);
      await (_database.update(
        _database.tagCards,
      )..where((row) => row.id.equals(card.id))).write(
        database_models.TagCardsCompanion(
          sourceSummary: Value(_sourceSummary(allSources)),
          evidenceSummary: Value(_evidenceSummary(allSources)),
          updatedAt: Value(timestamp),
        ),
      );
    });
  }

  @override
  Future<void> deleteCard(String id) {
    return _localDataSource.softDeleteCard(cardId: id, deletedAt: _timestamp());
  }

  @override
  Future<List<TagCardEntity>> getCards(CardListQuery query) async {
    final cards = await _loadCards();
    return _applyQuery(cards, query);
  }

  @override
  Future<TagCardEntity?> getCardById(String id) {
    return _loadCardById(id);
  }

  @override
  Future<CardActionResult> completeCard(String id) {
    return _mutateCardForAction(
      id: id,
      action: TagCardAction.complete,
      buildChanges: (timestamp) => database_models.TagCardsCompanion(
        status: const Value('completed'),
        snoozedUntil: const Value(null),
        notificationEnabled: const Value(false),
        updatedAt: Value(timestamp),
        completedAt: Value(timestamp),
      ),
    );
  }

  @override
  Future<CardActionResult> snoozeCard({
    required String id,
    required DateTime snoozedUntil,
  }) {
    return _mutateCardForAction(
      id: id,
      action: TagCardAction.snooze,
      validate: (card, timestamp) {
        final snoozedUntilMs = snoozedUntil.toUtc().millisecondsSinceEpoch;
        if (snoozedUntilMs <= timestamp) {
          throw const CardActionException('Snooze time must be in the future.');
        }
      },
      buildChanges: (timestamp) => database_models.TagCardsCompanion(
        status: const Value('snoozed'),
        snoozedUntil: Value(snoozedUntil.toUtc().millisecondsSinceEpoch),
        notificationEnabled: const Value(true),
        updatedAt: Value(timestamp),
      ),
    );
  }

  @override
  Future<CardActionResult> cancelCard(String id) {
    return _mutateCardForAction(
      id: id,
      action: TagCardAction.cancel,
      buildChanges: (timestamp) => database_models.TagCardsCompanion(
        status: const Value('cancelled'),
        snoozedUntil: const Value(null),
        notificationEnabled: const Value(false),
        updatedAt: Value(timestamp),
        cancelledAt: Value(timestamp),
      ),
    );
  }

  @override
  Future<CardActionResult> dismissSuggestion(String id) {
    return _mutateCardForAction(
      id: id,
      action: TagCardAction.dismiss,
      buildChanges: (timestamp) => database_models.TagCardsCompanion(
        status: const Value('dismissed'),
        snoozedUntil: const Value(null),
        notificationEnabled: const Value(false),
        updatedAt: Value(timestamp),
        dismissedAt: Value(timestamp),
      ),
    );
  }

  @override
  Future<CardActionResult> archiveCard(String id) {
    return _mutateCardForAction(
      id: id,
      action: TagCardAction.archive,
      buildChanges: (timestamp) => database_models.TagCardsCompanion(
        status: const Value('archived'),
        snoozedUntil: const Value(null),
        notificationEnabled: const Value(false),
        updatedAt: Value(timestamp),
        archivedAt: Value(timestamp),
      ),
    );
  }

  @override
  Stream<List<TagCardEntity>> watchCards(CardListQuery query) {
    final joined =
        _database.select(_database.tagCards).join([
          innerJoin(
            _database.spaces,
            _database.spaces.id.equalsExp(_database.tagCards.spaceId),
          ),
        ])..where(
          _database.tagCards.deletedAt.isNull() &
              _database.tagCards.archivedAt.isNull() &
              _database.spaces.deletedAt.isNull(),
        );

    return joined.watch().asyncMap((rows) async {
      final cardRows = rows
          .map((row) => row.readTable(_database.tagCards))
          .toList(growable: false);
      final sourceIdsByCardId = await _sourceIdsByCardId(
        cardRows.map((card) => card.id).toList(growable: false),
      );
      final cards = <TagCardEntity>[];
      for (var index = 0; index < rows.length; index++) {
        final card = cardRows[index];
        cards.add(
          await _mapCard(
            card,
            rows[index].readTable(_database.spaces),
            sourceIds: sourceIdsByCardId[card.id] ?? const [],
          ),
        );
      }

      return _applyQuery(cards, query);
    });
  }

  Future<TagCardEntity?> _loadCardById(String id) async {
    final joined =
        _database.select(_database.tagCards).join([
          innerJoin(
            _database.spaces,
            _database.spaces.id.equalsExp(_database.tagCards.spaceId),
          ),
        ])..where(
          _database.tagCards.id.equals(id) &
              _database.tagCards.deletedAt.isNull(),
        );

    final row = await joined.getSingleOrNull();
    if (row == null) {
      return null;
    }
    final card = row.readTable(_database.tagCards);

    return _mapCard(
      card,
      row.readTable(_database.spaces),
      sourceIds: await _sourceIdsForCard(card.id),
    );
  }

  Future<List<TagCardEntity>> _loadCards() async {
    final joined =
        _database.select(_database.tagCards).join([
          innerJoin(
            _database.spaces,
            _database.spaces.id.equalsExp(_database.tagCards.spaceId),
          ),
        ])..where(
          _database.tagCards.deletedAt.isNull() &
              _database.tagCards.archivedAt.isNull() &
              _database.spaces.deletedAt.isNull(),
        );
    final rows = await joined.get();
    final cardRows = rows
        .map((row) => row.readTable(_database.tagCards))
        .toList(growable: false);
    final sourceIdsByCardId = await _sourceIdsByCardId(
      cardRows.map((card) => card.id).toList(growable: false),
    );
    final cards = <TagCardEntity>[];

    for (var index = 0; index < rows.length; index++) {
      final card = cardRows[index];
      cards.add(
        await _mapCard(
          card,
          rows[index].readTable(_database.spaces),
          sourceIds: sourceIdsByCardId[card.id] ?? const [],
        ),
      );
    }

    return cards;
  }

  Future<TagCardEntity> _mapCard(
    database_models.TagCard card,
    database_models.Space space, {
    required List<String> sourceIds,
  }) async {
    final cardType = TagCardType.fromStorageValue(card.cardType);
    return TagCardEntity(
      id: card.id,
      cardType: cardType,
      status: TagCardStatus.fromStorageValue(card.status),
      title: normalizeTagCardTitle(card.title),
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

  Future<CardActionResult> _mutateCardForAction({
    required String id,
    required TagCardAction action,
    required database_models.TagCardsCompanion Function(int timestamp)
    buildChanges,
    void Function(TagCardEntity card, int timestamp)? validate,
  }) async {
    final previousCard = await _loadCardById(id);
    if (previousCard == null) {
      throw const CardActionException('Tag Card was not found.');
    }

    final timestamp = _timestamp();
    _validateAction(previousCard, action);
    validate?.call(previousCard, timestamp);

    await _localDataSource.updateCard(
      cardId: id,
      changes: buildChanges(timestamp),
    );

    final card = await _loadCardById(id);
    if (card == null) {
      throw const CardActionException(
        'Updated card was not readable after action.',
      );
    }

    return CardActionResult(
      previousCard: previousCard,
      card: card,
      action: action,
      actionAt: timestamp,
    );
  }

  void _validateAction(TagCardEntity card, TagCardAction action) {
    if (action == TagCardAction.archive) {
      if (card.status == TagCardStatus.archived) {
        throw const CardActionException('Card is already archived.');
      }
      return;
    }

    if (card.isTerminal) {
      throw CardActionException(
        '${card.status.label} cards cannot be acted on.',
      );
    }

    if (!CardPolicy.supportsAction(cardType: card.cardType, action: action)) {
      throw CardActionException(
        '${action.label} is not available for ${card.cardType.label} cards.',
      );
    }
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

  List<TagCardEntity> _applyQuery(
    List<TagCardEntity> cards,
    CardListQuery query,
  ) {
    final filtered = cards
        .where((card) {
          return _matchesFilter(card, query.filter) &&
              _matchesViewMode(card, query);
        })
        .toList(growable: false);

    return [...filtered]
      ..sort((left, right) => _compareCards(left, right, query));
  }

  bool _matchesFilter(TagCardEntity card, TodayCardFilter filter) {
    return switch (filter) {
      TodayCardFilter.all => card.status != TagCardStatus.dismissed,
      TodayCardFilter.urgent => card.cardType == TagCardType.urgent,
      TodayCardFilter.goal => card.cardType == TagCardType.goal,
      TodayCardFilter.suggestion => card.cardType == TagCardType.suggestion,
      TodayCardFilter.completed => card.status == TagCardStatus.completed,
      TodayCardFilter.snoozed => card.status == TagCardStatus.snoozed,
      TodayCardFilter.cancelled => card.status == TagCardStatus.cancelled,
    };
  }

  bool _matchesViewMode(TagCardEntity card, CardListQuery query) {
    if (query.viewMode == TodayViewMode.spaces) {
      return false;
    }
    if (query.viewMode == TodayViewMode.all) {
      return true;
    }

    final bounds = _dayBounds(query.now);
    final attentionTime = card.nextAttentionTime;

    return switch (query.viewMode) {
      TodayViewMode.today =>
        card.cardType == TagCardType.suggestion &&
                card.status == TagCardStatus.active &&
                attentionTime == null
            ? true
            : attentionTime != null && attentionTime < bounds.tomorrowStart,
      TodayViewMode.tomorrow =>
        attentionTime != null &&
            attentionTime >= bounds.tomorrowStart &&
            attentionTime < bounds.afterTomorrowStart,
      TodayViewMode.thisWeek =>
        attentionTime != null && attentionTime < bounds.weekEnd,
      TodayViewMode.all || TodayViewMode.spaces => true,
    };
  }

  int _compareCards(
    TagCardEntity left,
    TagCardEntity right,
    CardListQuery query,
  ) {
    final leftBucket = _sortBucket(left, query.now);
    final rightBucket = _sortBucket(right, query.now);
    if (leftBucket != rightBucket) {
      return leftBucket.compareTo(rightBucket);
    }

    final leftTime = left.nextAttentionTime ?? 1 << 62;
    final rightTime = right.nextAttentionTime ?? 1 << 62;
    if (leftTime != rightTime) {
      return leftTime.compareTo(rightTime);
    }

    final createdCompare = left.createdAt.compareTo(right.createdAt);
    if (createdCompare != 0) {
      return createdCompare;
    }

    return left.id.compareTo(right.id);
  }

  int _sortBucket(TagCardEntity card, DateTime now) {
    if (card.status == TagCardStatus.completed) {
      return 8;
    }
    if (card.status == TagCardStatus.cancelled ||
        card.status == TagCardStatus.dismissed) {
      return 9;
    }

    final attentionTime = card.nextAttentionTime;
    if (attentionTime == null) {
      return card.cardType == TagCardType.suggestion ? 5 : 6;
    }

    final nowMs = now.toUtc().millisecondsSinceEpoch;
    final bounds = _dayBounds(now);
    if (attentionTime < nowMs) {
      return 0;
    }
    if (attentionTime <= nowMs + const Duration(hours: 1).inMilliseconds) {
      return 1;
    }
    if (attentionTime < bounds.tomorrowStart) {
      return 2;
    }
    if (attentionTime < bounds.afterTomorrowStart) {
      return 3;
    }
    if (attentionTime < bounds.weekEnd) {
      return 4;
    }

    return 6;
  }

  _DayBounds _dayBounds(DateTime now) {
    final local = now.toLocal();
    final today = DateTime(local.year, local.month, local.day);
    return _DayBounds(
      todayStart: today.toUtc().millisecondsSinceEpoch,
      tomorrowStart: today
          .add(const Duration(days: 1))
          .toUtc()
          .millisecondsSinceEpoch,
      afterTomorrowStart: today
          .add(const Duration(days: 2))
          .toUtc()
          .millisecondsSinceEpoch,
      weekEnd: today
          .add(const Duration(days: 7))
          .toUtc()
          .millisecondsSinceEpoch,
    );
  }

  Future<List<database_models.SourceItem>> _loadSources(
    List<String> sourceIds,
  ) async {
    final rows =
        await (_database.select(_database.sourceItems)..where((source) {
              return source.id.isIn(sourceIds) & source.deletedAt.isNull();
            }))
            .get();
    final rowById = {for (final row in rows) row.id: row};

    return [
      for (final sourceId in sourceIds)
        if (rowById[sourceId] != null) rowById[sourceId]!,
    ];
  }

  Future<List<String>> _sourceIdsForCard(String cardId) async {
    final rows = await (_database.select(
      _database.cardSources,
    )..where((source) => source.cardId.equals(cardId))).get();

    rows.sort(_compareCardSourceRows);

    return rows.map((row) => row.sourceId).toList(growable: false);
  }

  Future<Map<String, List<String>>> _sourceIdsByCardId(
    List<String> cardIds,
  ) async {
    if (cardIds.isEmpty) {
      return const {};
    }

    final rows = await (_database.select(
      _database.cardSources,
    )..where((source) => source.cardId.isIn(cardIds))).get();
    rows.sort(_compareCardSourceRows);

    final grouped = <String, List<String>>{};
    for (final row in rows) {
      grouped.putIfAbsent(row.cardId, () => <String>[]).add(row.sourceId);
    }

    return grouped;
  }

  int _compareCardSourceRows(
    database_models.CardSource left,
    database_models.CardSource right,
  ) {
    final cardOrder = left.cardId.compareTo(right.cardId);
    if (cardOrder != 0) {
      return cardOrder;
    }
    if (left.role == right.role) {
      return left.createdAt.compareTo(right.createdAt);
    }
    if (left.role == 'primary' || left.role == 'chat_created') {
      return -1;
    }
    if (right.role == 'primary' || right.role == 'chat_created') {
      return 1;
    }
    return left.role.compareTo(right.role);
  }

  List<String> _uniqueNonEmpty(List<String> values) {
    final seen = <String>{};
    return [
      for (final value in values)
        if (value.trim().isNotEmpty && seen.add(value.trim())) value.trim(),
    ];
  }

  int? _deadlineMillis(String? value) {
    if (value == null) {
      return null;
    }

    return DateTime.parse(value).toUtc().millisecondsSinceEpoch;
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

  String _sourceSummary(List<database_models.SourceItem> sources) {
    if (sources.length > 1) {
      return '${sources.length} saved sources';
    }

    final source = sources.single;
    final summary = source.sourceSummary?.trim();
    if (summary != null && summary.isNotEmpty) {
      return summary;
    }

    final appSource = source.appSource?.trim();
    if (appSource != null && appSource.isNotEmpty) {
      return '$appSource ${_sourceTypeLabel(source.type).toLowerCase()}';
    }

    return _sourceTypeLabel(source.type);
  }

  String _evidenceSummary(List<database_models.SourceItem> sources) {
    if (sources.length > 1) {
      return 'Created from ${sources.length} linked saved sources.';
    }

    final evidence = _evidenceTextFor(sources.single);
    if (evidence == null || evidence.isEmpty) {
      return 'Created from local source evidence.';
    }

    return evidence.length <= 140
        ? evidence
        : '${evidence.substring(0, 140)}...';
  }

  String? _evidenceTextFor(database_models.SourceItem source) {
    final extracted = source.extractedText?.trim();
    if (extracted != null && extracted.isNotEmpty) {
      return extracted;
    }

    final rawText = source.rawText?.trim();
    if (rawText != null && rawText.isNotEmpty) {
      return rawText;
    }

    return source.sourceSummary?.trim();
  }

  String _sourceTypeLabel(String type) {
    return switch (type) {
      'screenshot' => 'Screenshot',
      'image' => 'Image',
      'link' => 'Link',
      'text' => 'Text',
      'chat' => 'Chat',
      'saved_post' => 'Saved post',
      'email_text' => 'Email text',
      _ => 'Saved source',
    };
  }

  Value<T?> _nullableValue<T>(T? value) {
    return value == null ? const Value.absent() : Value(value);
  }

  int _timestamp() => _now().toUtc().millisecondsSinceEpoch;
}

class _DayBounds {
  const _DayBounds({
    required this.todayStart,
    required this.tomorrowStart,
    required this.afterTomorrowStart,
    required this.weekEnd,
  });

  final int todayStart;
  final int tomorrowStart;
  final int afterTomorrowStart;
  final int weekEnd;
}
