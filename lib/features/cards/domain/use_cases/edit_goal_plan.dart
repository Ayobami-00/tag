import 'package:equatable/equatable.dart';
import 'package:tag/core/ai/schemas/goal_plan_preview_schema.dart';
import 'package:tag/features/cards/domain/entities/feedback_entities.dart';
import 'package:tag/features/cards/domain/entities/goal_plan_entities.dart';
import 'package:tag/features/cards/domain/repositories/goal_plan_repository.dart';
import 'package:tag/features/cards/domain/use_cases/store_feedback_event.dart';
import 'package:tag/features/cards/domain/use_cases/update_future_goal_cards.dart';
import 'package:tag/features/chat/domain/entities/chat_entities.dart';

class EditGoalPlan {
  const EditGoalPlan({
    required GoalPlanRepository goalPlanRepository,
    required UpdateFutureGoalCards updateFutureGoalCards,
    StoreFeedbackEvent? storeFeedbackEvent,
  }) : _goalPlanRepository = goalPlanRepository,
       _updateFutureGoalCards = updateFutureGoalCards,
       _storeFeedbackEvent = storeFeedbackEvent;

  final GoalPlanRepository _goalPlanRepository;
  final UpdateFutureGoalCards _updateFutureGoalCards;
  final StoreFeedbackEvent? _storeFeedbackEvent;

  Future<EditGoalPlanResult> call(EditGoalPlanParams params) async {
    final session = params.session;
    if (session.purpose != ChatPurpose.editGoal) {
      throw const GoalPlanException('Goal edits require a linked goal chat.');
    }

    final goalPlanId = session.linkedGoalPlanId;
    if (goalPlanId == null || goalPlanId.trim().isEmpty) {
      throw const GoalPlanException('Goal edit chat is not linked to a plan.');
    }

    final goalPlan = await _goalPlanRepository.getGoalPlanById(goalPlanId);
    if (goalPlan == null) {
      throw const GoalPlanException('GoalPlan was not found.');
    }

    final childCards = await _goalPlanRepository.getGoalPlanCards(goalPlanId);
    if (childCards.isEmpty) {
      throw const GoalPlanException('GoalPlan has no linked Goal Cards.');
    }

    final patch = _patchFromRequest(params.request, goalPlan);
    final preview = _previewForEdit(
      goalPlan: goalPlan,
      childCards: childCards,
      patch: patch,
    );
    final update = await _updateFutureGoalCards(
      UpdateFutureGoalCardsParams(
        goalPlanId: goalPlanId,
        preview: preview,
        sessionLengthMinutes: patch.sessionLengthMinutes,
        editSummary: params.request,
        includeCompleted: params.includeCompleted,
      ),
    );

    await _storeFeedbackEvent?.call(
      StoreFeedbackEventParams(
        eventType: FeedbackEventType.editGoalCadence,
        cardId: session.linkedCardId,
        spaceId: goalPlan.space.id,
        sourceId: childCards.first.card.sourceIds.isEmpty
            ? null
            : childCards.first.card.sourceIds.first,
        goalPlanId: goalPlanId,
        details: {
          'request': params.request,
          'preferred_days': patch.preferredDays,
          if (patch.sessionLengthMinutes != null)
            'session_length_minutes': patch.sessionLengthMinutes,
          'updated_card_count': update.updatedCards.length,
          'skipped_completed_count': update.skippedCompletedCards.length,
        },
      ),
    );

    return EditGoalPlanResult(update: update, request: params.request);
  }

  GoalPlanPreview _previewForEdit({
    required GoalPlanEntity goalPlan,
    required List<GoalPlanCardEntity> childCards,
    required _GoalPlanEditPatch patch,
  }) {
    return GoalPlanPreview(
      goalName: goalPlan.name,
      spaceName: goalPlan.space.name,
      durationWeeks: goalPlan.durationWeeks ?? 1,
      preferredDays: patch.preferredDays,
      cards: [
        for (final child in childCards)
          GoalPlanPreviewCard(
            title: child.card.title,
            reason: child.card.reason,
            scheduledFor: _scheduledFor(child, patch),
            sourceIds: child.card.sourceIds,
          ),
      ],
    );
  }

  String? _scheduledFor(GoalPlanCardEntity child, _GoalPlanEditPatch patch) {
    final deadline = child.card.nextActiveDeadline;
    if (deadline == null) {
      return null;
    }

    final current = DateTime.fromMillisecondsSinceEpoch(
      deadline,
      isUtc: true,
    ).toLocal();

    if (!patch.weekendOnly) {
      return current.toIso8601String();
    }

    return _moveToWeekend(
      current,
      sequenceIndex: child.sequenceIndex,
    ).toIso8601String();
  }

  DateTime _moveToWeekend(DateTime current, {required int sequenceIndex}) {
    if (current.weekday == DateTime.saturday ||
        current.weekday == DateTime.sunday) {
      return current;
    }

    final targetWeekday = sequenceIndex.isEven
        ? DateTime.saturday
        : DateTime.sunday;
    final daysUntilTarget =
        (targetWeekday - current.weekday + DateTime.daysPerWeek) %
        DateTime.daysPerWeek;
    final offset = daysUntilTarget == 0
        ? DateTime.daysPerWeek
        : daysUntilTarget;

    return current.add(Duration(days: offset));
  }

  _GoalPlanEditPatch _patchFromRequest(
    String request,
    GoalPlanEntity goalPlan,
  ) {
    final lower = request.toLowerCase();
    final weekendOnly = lower.contains('weekend');
    final preferredDays = weekendOnly
        ? const ['Saturday', 'Sunday']
        : goalPlan.preferredDays.isEmpty
        ? const ['Saturday']
        : goalPlan.preferredDays;

    return _GoalPlanEditPatch(
      weekendOnly: weekendOnly,
      preferredDays: preferredDays,
      sessionLengthMinutes:
          _sessionLengthMinutes(request) ?? goalPlan.sessionLengthMinutes,
    );
  }

  int? _sessionLengthMinutes(String request) {
    final match = RegExp(
      r'(\d{1,3})\s*(minute|minutes|min|mins)\b',
      caseSensitive: false,
    ).firstMatch(request);
    if (match == null) {
      return null;
    }

    return int.tryParse(match.group(1)!);
  }
}

class EditGoalPlanParams extends Equatable {
  const EditGoalPlanParams({
    required this.session,
    required this.request,
    this.includeCompleted = false,
  });

  final ChatSessionEntity session;
  final String request;
  final bool includeCompleted;

  @override
  List<Object?> get props => [session, request, includeCompleted];
}

class EditGoalPlanResult extends Equatable {
  const EditGoalPlanResult({required this.update, required this.request});

  final GoalPlanFutureUpdateResult update;
  final String request;

  @override
  List<Object?> get props => [update, request];
}

class _GoalPlanEditPatch {
  const _GoalPlanEditPatch({
    required this.weekendOnly,
    required this.preferredDays,
    this.sessionLengthMinutes,
  });

  final bool weekendOnly;
  final List<String> preferredDays;
  final int? sessionLengthMinutes;
}
