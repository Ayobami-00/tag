import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:tag/core/ai/schemas/goal_plan_preview_schema.dart';
import 'package:tag/core/local_storage/database/tag_database.dart'
    as database_models;
import 'package:tag/features/cards/data/repositories/space_repository_impl.dart';
import 'package:tag/features/cards/domain/entities/card_entities.dart';
import 'package:tag/features/cards/domain/entities/goal_plan_entities.dart';
import 'package:tag/features/cards/domain/repositories/goal_plan_repository.dart';
import 'package:tag/features/cards/domain/repositories/space_repository.dart';
import 'package:tag/features/cards/domain/use_cases/card_title_normalizer.dart';
import 'package:tag/features/cards/domain/use_cases/card_policy.dart';
import 'package:uuid/uuid.dart';

class GoalPlanRepositoryImpl implements GoalPlanRepository {
  GoalPlanRepositoryImpl({
    required database_models.TagDatabase database,
    required SpaceRepository spaceRepository,
    DateTime Function()? now,
    Uuid? uuid,
  }) : _database = database,
       _spaceRepository = spaceRepository,
       _now = now ?? DateTime.now,
       _uuid = uuid ?? const Uuid();

  final database_models.TagDatabase _database;
  final SpaceRepository _spaceRepository;
  final DateTime Function() _now;
  final Uuid _uuid;
  int? _lastTimestamp;

  @override
  Future<GoalPlanCreationResult> createFromConfirmation(
    GoalPlanConfirmation confirmation,
  ) async {
    final preview = confirmation.preview.validateForSourceBackedSuggestion(
      allowedSourceIds: confirmation.sourceIds.toSet(),
      expectedDurationWeeks: _durationWeeksFor(confirmation.planStyle),
    );
    final allSourceIds = _sourceIdsForPreview(preview, confirmation.sourceIds);
    if (allSourceIds.isEmpty) {
      throw const GoalPlanException('Goal Cards must link to source evidence.');
    }

    final sources = await _loadSources(allSourceIds);
    if (sources.length != allSourceIds.length) {
      throw const GoalPlanException(
        'Goal plan source ids must reference existing local sources.',
      );
    }

    final space = await _spaceRepository.getOrCreateSpecificSpace(
      suggestedName: preview.spaceName,
      sourceIds: allSourceIds,
      description: 'Goal plan created from saved source evidence.',
      primaryIntentionType: 'goal',
      confidence: null,
    );
    final goalPlanId = 'goal_${_uuid.v4()}';
    final timestamp = _timestamp();
    final planPreviewJson = jsonEncode(preview.toJson());
    final childCardIds = [
      for (var index = 0; index < preview.cards.length; index++)
        'card_${_uuid.v4()}',
    ];
    TagCardEntity? dismissedSuggestion;

    await _database.transaction(() async {
      await _database
          .into(_database.goalPlans)
          .insert(
            database_models.GoalPlansCompanion.insert(
              id: goalPlanId,
              spaceId: space.id,
              originCardId: _nullableValue(confirmation.originCardId),
              chatSessionId: Value(confirmation.chatSessionId),
              name: preview.goalName,
              description: Value(
                'Created from ${_sourceCountLabel(allSourceIds.length)}.',
              ),
              durationWeeks: Value(preview.durationWeeks),
              preferredDaysJson: Value(jsonEncode(preview.preferredDays)),
              sessionLengthMinutes: _nullableValue(
                confirmation.weeklyTimeMinutes,
              ),
              reminderPreferenceJson: Value(
                jsonEncode({
                  'source': 'guided_planning',
                  'plan_style': confirmation.planStyle,
                  'weekly_time': confirmation.weeklyTime,
                }),
              ),
              status: GoalPlanStatus.active.storageValue,
              createdBy: confirmation.createdBy.storageValue,
              modelSlug: _nullableValue(confirmation.modelSlug),
              planPreviewJson: Value(planPreviewJson),
              createdAt: timestamp,
              updatedAt: timestamp,
            ),
          );

      for (var index = 0; index < preview.cards.length; index++) {
        final previewCard = preview.cards[index];
        final cardId = childCardIds[index];
        final cardSourceIds = _cardSourceIds(previewCard, allSourceIds);
        final cardSources = _sourcesForIds(cardSourceIds, sources);
        final nextActiveDeadline = _deadlineMillis(previewCard.scheduledFor);
        final status = TagCardStatus.active;
        final notificationEnabled = CardPolicy.notificationEligible(
          cardType: TagCardType.goal,
          status: status,
          nextActiveDeadline: nextActiveDeadline,
        );

        await _database
            .into(_database.tagCards)
            .insert(
              database_models.TagCardsCompanion.insert(
                id: cardId,
                cardType: TagCardType.goal.storageValue,
                status: Value(status.storageValue),
                title: previewCard.title,
                reason: previewCard.reason,
                spaceId: space.id,
                nextActiveDeadline: _nullableValue(nextActiveDeadline),
                deadlineTimezone: _nullableValue(
                  nextActiveDeadline == null ? null : _now().timeZoneName,
                ),
                notificationEnabled: Value(notificationEnabled),
                actionsJson: Value(jsonEncode(_goalActionIds())),
                sourceSummary: _sourceSummary(cardSources),
                evidenceSummary: _evidenceSummary(cardSources),
                parentGoalPlanId: Value(goalPlanId),
                createdBy: 'chat',
                modelSlug: _nullableValue(confirmation.modelSlug),
                modelOutputJson: Value(planPreviewJson),
                metadataJson: Value(
                  jsonEncode({
                    'created_from': 'confirmed_goal_plan',
                    'goal_plan_id': goalPlanId,
                    'goal_sequence_index': index,
                    'space_normalized_name': normalizeSpaceName(space.name),
                  }),
                ),
                createdAt: timestamp,
                updatedAt: timestamp,
              ),
            );

        await _insertCardSources(
          cardId: cardId,
          sourceIds: cardSourceIds,
          sourceRows: sources,
          timestamp: timestamp,
        );
        await _database
            .into(_database.goalPlanCards)
            .insert(
              database_models.GoalPlanCardsCompanion.insert(
                goalPlanId: goalPlanId,
                cardId: cardId,
                sequenceIndex: index,
                createdAt: timestamp,
              ),
            );
      }

      if (confirmation.originCardId?.trim().isNotEmpty == true) {
        await _dismissOriginSuggestion(
          cardId: confirmation.originCardId!,
          goalPlanId: goalPlanId,
          timestamp: timestamp,
        );
      }
    });

    if (confirmation.originCardId?.trim().isNotEmpty == true) {
      dismissedSuggestion = await _loadCardById(confirmation.originCardId!);
    }

    final goalPlan = await getGoalPlanById(goalPlanId);
    if (goalPlan == null) {
      throw const GoalPlanException(
        'Created GoalPlan was not readable after insert.',
      );
    }

    final cards = <TagCardEntity>[];
    for (final cardId in childCardIds) {
      final card = await _loadCardById(cardId);
      if (card == null) {
        throw const GoalPlanException(
          'Created Goal Card was not readable after insert.',
        );
      }
      cards.add(card);
    }

    return GoalPlanCreationResult(
      goalPlan: goalPlan,
      cards: cards,
      sourceIds: allSourceIds,
      dismissedSuggestion: dismissedSuggestion,
    );
  }

  @override
  Future<GoalPlanEntity?> getGoalPlanById(String id) async {
    final joined =
        _database.select(_database.goalPlans).join([
          innerJoin(
            _database.spaces,
            _database.spaces.id.equalsExp(_database.goalPlans.spaceId),
          ),
        ])..where(
          _database.goalPlans.id.equals(id) &
              _database.spaces.deletedAt.isNull(),
        );

    final row = await joined.getSingleOrNull();
    if (row == null) {
      return null;
    }

    return _mapGoalPlan(
      row.readTable(_database.goalPlans),
      row.readTable(_database.spaces),
    );
  }

  @override
  Future<List<GoalPlanCardEntity>> getGoalPlanCards(String goalPlanId) async {
    final rows =
        await (_database.select(_database.goalPlanCards)
              ..where((link) => link.goalPlanId.equals(goalPlanId))
              ..orderBy([(link) => OrderingTerm.asc(link.sequenceIndex)]))
            .get();
    final cards = <GoalPlanCardEntity>[];

    for (final row in rows) {
      final card = await _loadCardById(row.cardId);
      if (card == null) {
        continue;
      }
      cards.add(
        GoalPlanCardEntity(
          goalPlanId: row.goalPlanId,
          card: card,
          sequenceIndex: row.sequenceIndex,
          createdAt: row.createdAt,
        ),
      );
    }

    return cards;
  }

  @override
  Future<GoalPlanFutureUpdateResult> updateFutureGoalCards({
    required String goalPlanId,
    required GoalPlanPreview preview,
    int? sessionLengthMinutes,
    String? editSummary,
    bool includeCompleted = false,
  }) async {
    final currentGoalPlan = await getGoalPlanById(goalPlanId);
    if (currentGoalPlan == null) {
      throw const GoalPlanException('GoalPlan was not found.');
    }

    final links = await getGoalPlanCards(goalPlanId);
    final previewSourceIds = _sourceIdsForPreview(preview, const []);
    if (previewSourceIds.isEmpty) {
      throw const GoalPlanException(
        'Edited Goal Cards must keep source evidence.',
      );
    }

    final sourceRows = await _loadSources(previewSourceIds);
    if (sourceRows.length != previewSourceIds.length) {
      throw const GoalPlanException(
        'Edited goal plan source ids must reference existing local sources.',
      );
    }

    final timestamp = _timestamp();
    final nowMs = timestamp;
    final updatedCardIds = <String>[];
    final unchangedCards = <TagCardEntity>[];
    final skippedCompletedCards = <TagCardEntity>[];
    final planPreviewJson = jsonEncode(preview.toJson());

    await _database.transaction(() async {
      await (_database.update(
        _database.goalPlans,
      )..where((plan) => plan.id.equals(goalPlanId))).write(
        database_models.GoalPlansCompanion(
          name: Value(preview.goalName),
          durationWeeks: Value(preview.durationWeeks),
          preferredDaysJson: Value(jsonEncode(preview.preferredDays)),
          sessionLengthMinutes: sessionLengthMinutes == null
              ? const Value.absent()
              : Value(sessionLengthMinutes),
          planPreviewJson: Value(planPreviewJson),
          updatedAt: Value(timestamp),
        ),
      );

      for (final link in links) {
        final previewCard = link.sequenceIndex < preview.cards.length
            ? preview.cards[link.sequenceIndex]
            : null;
        final card = link.card;

        if (card.status == TagCardStatus.completed && !includeCompleted) {
          skippedCompletedCards.add(card);
          continue;
        }

        if (previewCard == null || _shouldKeepCardUnchanged(card, nowMs)) {
          unchangedCards.add(card);
          continue;
        }

        final cardSourceIds = _cardSourceIds(previewCard, previewSourceIds);
        final cardSources = _sourcesForIds(cardSourceIds, sourceRows);
        final nextActiveDeadline = _deadlineMillis(previewCard.scheduledFor);
        final notificationEnabled = CardPolicy.notificationEligible(
          cardType: TagCardType.goal,
          status: card.status,
          nextActiveDeadline: nextActiveDeadline,
        );

        await (_database.update(
          _database.tagCards,
        )..where((tagCard) => tagCard.id.equals(card.id))).write(
          database_models.TagCardsCompanion(
            title: Value(previewCard.title),
            reason: Value(previewCard.reason),
            nextActiveDeadline: Value(nextActiveDeadline),
            deadlineTimezone: Value(
              nextActiveDeadline == null ? null : _now().timeZoneName,
            ),
            notificationEnabled: Value(notificationEnabled),
            sourceSummary: Value(_sourceSummary(cardSources)),
            evidenceSummary: Value(_evidenceSummary(cardSources)),
            modelOutputJson: Value(planPreviewJson),
            metadataJson: Value(
              _updatedMetadata(
                card.metadataJson,
                goalPlanId: goalPlanId,
                sequenceIndex: link.sequenceIndex,
                editSummary: editSummary,
              ),
            ),
            updatedAt: Value(timestamp),
          ),
        );

        await (_database.delete(
          _database.cardSources,
        )..where((source) => source.cardId.equals(card.id))).go();
        await _insertCardSources(
          cardId: card.id,
          sourceIds: cardSourceIds,
          sourceRows: sourceRows,
          timestamp: timestamp,
        );
        updatedCardIds.add(card.id);
      }
    });

    final updatedGoalPlan = await getGoalPlanById(goalPlanId);
    if (updatedGoalPlan == null) {
      throw const GoalPlanException(
        'Updated GoalPlan was not readable after edit.',
      );
    }

    final updatedCards = <TagCardEntity>[];
    for (final cardId in updatedCardIds) {
      final card = await _loadCardById(cardId);
      if (card != null) {
        updatedCards.add(card);
      }
    }

    return GoalPlanFutureUpdateResult(
      goalPlan: updatedGoalPlan,
      updatedCards: updatedCards,
      unchangedCards: unchangedCards,
      skippedCompletedCards: skippedCompletedCards,
    );
  }

  Future<void> _dismissOriginSuggestion({
    required String cardId,
    required String goalPlanId,
    required int timestamp,
  }) async {
    final row = await (_database.select(
      _database.tagCards,
    )..where((card) => card.id.equals(cardId))).getSingleOrNull();
    if (row == null || row.cardType != TagCardType.suggestion.storageValue) {
      return;
    }

    await (_database.update(
      _database.tagCards,
    )..where((card) => card.id.equals(cardId))).write(
      database_models.TagCardsCompanion(
        status: const Value('dismissed'),
        notificationEnabled: const Value(false),
        metadataJson: Value(
          _acceptedSuggestionMetadata(row.metadataJson, goalPlanId),
        ),
        updatedAt: Value(timestamp),
        dismissedAt: Value(timestamp),
      ),
    );
  }

  bool _shouldKeepCardUnchanged(TagCardEntity card, int nowMs) {
    if (card.isTerminal) {
      return true;
    }

    final attention = card.nextAttentionTime;
    return attention != null && attention < nowMs;
  }

  GoalPlanEntity _mapGoalPlan(
    database_models.GoalPlan row,
    database_models.Space space,
  ) {
    return GoalPlanEntity(
      id: row.id,
      space: _mapSpace(space),
      originCardId: row.originCardId,
      chatSessionId: row.chatSessionId,
      name: row.name,
      description: row.description,
      durationWeeks: row.durationWeeks,
      preferredDays: _decodeStringList(row.preferredDaysJson),
      sessionLengthMinutes: row.sessionLengthMinutes,
      reminderPreferenceJson: row.reminderPreferenceJson,
      status: GoalPlanStatus.fromStorageValue(row.status),
      createdBy: GoalPlanCreatedBy.fromStorageValue(row.createdBy),
      modelSlug: row.modelSlug,
      planPreviewJson: row.planPreviewJson,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      completedAt: row.completedAt,
      cancelledAt: row.cancelledAt,
    );
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

    return _mapCard(
      row.readTable(_database.tagCards),
      row.readTable(_database.spaces),
    );
  }

  Future<TagCardEntity> _mapCard(
    database_models.TagCard card,
    database_models.Space space,
  ) async {
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
      sourceIds: await _sourceIdsForCard(card.id),
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

  Future<void> _insertCardSources({
    required String cardId,
    required List<String> sourceIds,
    required List<database_models.SourceItem> sourceRows,
    required int timestamp,
  }) async {
    final sourceById = {for (final row in sourceRows) row.id: row};
    await _database.batch((batch) {
      batch.insertAll(_database.cardSources, [
        for (var index = 0; index < sourceIds.length; index++)
          database_models.CardSourcesCompanion.insert(
            cardId: cardId,
            sourceId: sourceIds[index],
            role: index == 0 ? 'primary' : 'supporting',
            evidenceText: _nullableValue(
              _evidenceTextFor(sourceById[sourceIds[index]]),
            ),
            createdAt: timestamp,
          ),
      ]);
    });
  }

  Future<List<String>> _sourceIdsForCard(String cardId) async {
    final rows = await (_database.select(
      _database.cardSources,
    )..where((source) => source.cardId.equals(cardId))).get();

    rows.sort((left, right) {
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
    });

    return rows.map((row) => row.sourceId).toList(growable: false);
  }

  List<String> _sourceIdsForPreview(
    GoalPlanPreview preview,
    List<String> fallbackSourceIds,
  ) {
    final seen = <String>{};
    return [
      for (final sourceId in fallbackSourceIds)
        if (sourceId.trim().isNotEmpty && seen.add(sourceId.trim()))
          sourceId.trim(),
      for (final card in preview.cards)
        for (final sourceId in card.sourceIds)
          if (sourceId.trim().isNotEmpty && seen.add(sourceId.trim()))
            sourceId.trim(),
    ];
  }

  List<String> _cardSourceIds(
    GoalPlanPreviewCard card,
    List<String> fallbackSourceIds,
  ) {
    final seen = <String>{};
    final ids = [
      for (final sourceId in card.sourceIds)
        if (sourceId.trim().isNotEmpty && seen.add(sourceId.trim()))
          sourceId.trim(),
    ];

    if (ids.isNotEmpty) {
      return ids;
    }

    return fallbackSourceIds;
  }

  List<database_models.SourceItem> _sourcesForIds(
    List<String> sourceIds,
    List<database_models.SourceItem> sources,
  ) {
    final sourceById = {for (final source in sources) source.id: source};
    return [
      for (final sourceId in sourceIds)
        if (sourceById[sourceId] != null) sourceById[sourceId]!,
    ];
  }

  int? _deadlineMillis(String? value) {
    if (value == null) {
      return null;
    }

    return DateTime.parse(value).toUtc().millisecondsSinceEpoch;
  }

  List<String> _goalActionIds() {
    return CardPolicy.actionsFor(
      TagCardType.goal,
    ).map((action) => action.storageValue).toList(growable: false);
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

  List<String> _decodeStringList(String jsonValue) {
    try {
      final decoded = jsonDecode(jsonValue);
      if (decoded is List) {
        return decoded
            .whereType<String>()
            .where((value) => value.trim().isNotEmpty)
            .toList(growable: false);
      }
    } on FormatException {
      return const [];
    }

    return const [];
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
      return appSource;
    }

    return 'Saved source';
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

  String? _evidenceTextFor(database_models.SourceItem? source) {
    if (source == null) {
      return null;
    }

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

  String _acceptedSuggestionMetadata(String metadataJson, String goalPlanId) {
    final metadata = _decodeMetadata(metadataJson)
      ..['accepted_goal_plan_id'] = goalPlanId
      ..['accepted_at'] = _now().toUtc().toIso8601String();
    return jsonEncode(metadata);
  }

  String _updatedMetadata(
    String metadataJson, {
    required String goalPlanId,
    required int sequenceIndex,
    String? editSummary,
  }) {
    final metadata = _decodeMetadata(metadataJson)
      ..['goal_plan_id'] = goalPlanId
      ..['goal_sequence_index'] = sequenceIndex
      ..['updated_from'] = 'goal_plan_edit'
      ..['goal_plan_edited_at'] = _now().toUtc().toIso8601String();
    final summary = editSummary?.trim();
    if (summary != null && summary.isNotEmpty) {
      metadata['goal_plan_edit_summary'] = summary;
    }

    return jsonEncode(metadata);
  }

  Map<String, Object?> _decodeMetadata(String metadataJson) {
    try {
      final decoded = jsonDecode(metadataJson);
      if (decoded is Map<String, Object?>) {
        return Map<String, Object?>.from(decoded);
      }
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry(key.toString(), value));
      }
    } on FormatException {
      return <String, Object?>{};
    }

    return <String, Object?>{};
  }

  String _sourceCountLabel(int sourceCount) {
    return sourceCount == 1 ? '1 saved source' : '$sourceCount saved sources';
  }

  int? _durationWeeksFor(String planStyle) {
    return switch (planStyle) {
      'weekend' => 1,
      'four_week' => 4,
      'light_reading' => 4,
      _ => null,
    };
  }

  Value<T?> _nullableValue<T>(T? value) {
    return value == null ? const Value.absent() : Value(value);
  }

  int _timestamp() {
    final current = _now().toUtc().millisecondsSinceEpoch;
    final previous = _lastTimestamp;
    final next = previous == null || current > previous
        ? current
        : previous + 1;
    _lastTimestamp = next;

    return next;
  }
}
