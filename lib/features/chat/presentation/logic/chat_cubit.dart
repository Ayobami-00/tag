import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tag/features/cards/domain/use_cases/confirm_goal_plan.dart';
import 'package:tag/features/cards/domain/use_cases/edit_goal_plan.dart';
import 'package:tag/features/chat/domain/entities/chat_entities.dart';
import 'package:tag/features/chat/domain/entities/guided_planning_entities.dart';
import 'package:tag/features/chat/domain/repositories/chat_repository.dart';
import 'package:tag/features/chat/domain/use_cases/ask_saved_context.dart';
import 'package:tag/features/chat/domain/use_cases/generate_goal_plan_preview.dart';
import 'package:tag/features/chat/domain/use_cases/start_fab_chat.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit({
    required StartFabChat startFabChat,
    required ChatRepository chatRepository,
    required AskSavedContext askSavedContext,
    required GenerateGoalPlanPreview generateGoalPlanPreview,
    required ConfirmGoalPlan confirmGoalPlan,
    required EditGoalPlan editGoalPlan,
  }) : _startFabChat = startFabChat,
       _chatRepository = chatRepository,
       _askSavedContext = askSavedContext,
       _generateGoalPlanPreview = generateGoalPlanPreview,
       _confirmGoalPlan = confirmGoalPlan,
       _editGoalPlan = editGoalPlan,
       super(const ChatState());

  final StartFabChat _startFabChat;
  final ChatRepository _chatRepository;
  final AskSavedContext _askSavedContext;
  final GenerateGoalPlanPreview _generateGoalPlanPreview;
  final ConfirmGoalPlan _confirmGoalPlan;
  final EditGoalPlan _editGoalPlan;
  StreamSubscription<List<ChatMessageEntity>>? _messagesSubscription;

  Future<void> open({String? chatSessionId}) async {
    emit(state.copyWith(status: ChatLoadStatus.loading, errorMessage: ''));

    try {
      final session = chatSessionId == null || chatSessionId.trim().isEmpty
          ? await _startFabChat(const StartFabChatParams())
          : await _loadExistingSession(chatSessionId.trim());

      await _messagesSubscription?.cancel();
      _messagesSubscription = _chatRepository
          .watchMessages(session.id)
          .listen(
            (messages) {
              if (isClosed) {
                return;
              }

              final nextStatus = state.status == ChatLoadStatus.sending
                  ? ChatLoadStatus.sending
                  : ChatLoadStatus.ready;
              final currentSession = state.session?.id == session.id
                  ? state.session
                  : session;
              emit(
                state.copyWith(
                  status: nextStatus,
                  session: currentSession,
                  messages: messages,
                  errorMessage: '',
                ),
              );
            },
            onError: (Object error) {
              if (isClosed) {
                return;
              }

              emit(
                state.copyWith(
                  status: ChatLoadStatus.error,
                  errorMessage: _messageFor(error),
                ),
              );
            },
          );

      final messages = await _chatRepository.loadMessages(session.id);
      emit(
        state.copyWith(
          status: ChatLoadStatus.ready,
          session: session,
          messages: messages,
          errorMessage: '',
        ),
      );
    } on Object catch (error) {
      emit(
        state.copyWith(
          status: ChatLoadStatus.error,
          errorMessage: _messageFor(error),
        ),
      );
    }
  }

  Future<void> ask(String value) async {
    final session = state.session;
    final query = value.trim();
    if (session == null || query.isEmpty || state.status.isBusy) {
      return;
    }

    emit(state.copyWith(status: ChatLoadStatus.sending, errorMessage: ''));

    try {
      if (session.purpose == ChatPurpose.editGoal) {
        await _askGoalEditChat(session, query);
        return;
      }

      final historyBeforeQuestion = state.messages;
      await _chatRepository.addMessage(
        ChatMessageDraft(
          chatSessionId: session.id,
          role: ChatMessageRole.user,
          content: query,
        ),
      );
      final answer = await _askSavedContext(
        AskSavedContextParams(
          query: query,
          history: historyBeforeQuestion,
          useModelSynthesis: _shouldUseModelSynthesis(query),
        ),
      );

      await _chatRepository.addMessage(
        ChatMessageDraft(
          chatSessionId: session.id,
          role: ChatMessageRole.assistant,
          content: answer.answer.answer,
          contentJson: jsonEncode(answer.answer.toJson()),
          sourceIds: answer.answer.sourceIds,
          cardIds: answer.answer.cardIds,
          modelSlug: answer.modelSlug,
        ),
      );

      emit(state.copyWith(status: ChatLoadStatus.ready, errorMessage: ''));
    } on Object catch (error) {
      emit(
        state.copyWith(
          status: ChatLoadStatus.error,
          errorMessage: _messageFor(error),
        ),
      );
    }
  }

  Future<void> confirmGoalPlan() async {
    final session = state.session;
    if (session == null || state.status.isBusy) {
      return;
    }

    emit(state.copyWith(status: ChatLoadStatus.sending, errorMessage: ''));

    try {
      final result = await _confirmGoalPlan(
        ConfirmGoalPlanParams(chatSessionId: session.id),
      );
      final goalResult = result.goalPlanResult;
      await _chatRepository.addMessage(
        ChatMessageDraft(
          chatSessionId: session.id,
          role: ChatMessageRole.assistant,
          content:
              'Done. I created ${goalResult.cards.length} Goal Cards for '
              '${goalResult.goalPlan.name}.',
          contentJson: jsonEncode({
            'kind': 'goal_plan_created',
            'goal_plan_id': goalResult.goalPlan.id,
            'card_ids': goalResult.cards
                .map((card) => card.id)
                .toList(growable: false),
          }),
          sourceIds: goalResult.sourceIds,
          cardIds: goalResult.cards
              .map((card) => card.id)
              .toList(growable: false),
        ),
      );

      emit(
        state.copyWith(
          status: ChatLoadStatus.ready,
          session: result.session,
          errorMessage: '',
        ),
      );
    } on Object catch (error) {
      emit(
        state.copyWith(
          status: ChatLoadStatus.error,
          errorMessage: _messageFor(error),
        ),
      );
    }
  }

  Future<void> selectPlanStyle(PlanStyleChoice choice) async {
    final session = state.session;
    if (!_canUseGuidedPlanning(session)) {
      return;
    }

    emit(state.copyWith(status: ChatLoadStatus.sending, errorMessage: ''));

    try {
      await _chatRepository.addMessage(
        ChatMessageDraft(
          chatSessionId: session!.id,
          role: ChatMessageRole.user,
          content: choice.label,
        ),
      );

      if (choice == PlanStyleChoice.custom) {
        await _chatRepository.addMessage(
          ChatMessageDraft(
            chatSessionId: session.id,
            role: ChatMessageRole.assistant,
            content:
                'Tell me the shape you want, and I can turn it into a preview.',
            contentJson: jsonEncode({'kind': 'custom_plan_style'}),
          ),
        );
      } else {
        await _chatRepository.addMessage(
          ChatMessageDraft(
            chatSessionId: session.id,
            role: ChatMessageRole.assistant,
            content: 'How much time can you spend each week?',
            contentJson: jsonEncode({
              'kind': 'weekly_time_choices',
              'plan_style': choice.storageValue,
              'choices': WeeklyTimeChoice.values
                  .map(
                    (timeChoice) => {
                      'value': timeChoice.storageValue,
                      'label': timeChoice.label,
                    },
                  )
                  .toList(growable: false),
            }),
          ),
        );
      }

      emit(state.copyWith(status: ChatLoadStatus.ready, errorMessage: ''));
    } on Object catch (error) {
      emit(
        state.copyWith(
          status: ChatLoadStatus.error,
          errorMessage: _messageFor(error),
        ),
      );
    }
  }

  Future<void> selectWeeklyTime(WeeklyTimeChoice choice) async {
    final session = state.session;
    if (!_canUseGuidedPlanning(session)) {
      return;
    }

    final planStyle = _latestSelectedPlanStyle();
    if (planStyle == null) {
      emit(
        state.copyWith(
          status: ChatLoadStatus.error,
          errorMessage: 'Choose a plan style first.',
        ),
      );
      return;
    }

    emit(state.copyWith(status: ChatLoadStatus.sending, errorMessage: ''));

    try {
      await _chatRepository.addMessage(
        ChatMessageDraft(
          chatSessionId: session!.id,
          role: ChatMessageRole.user,
          content: choice.label,
        ),
      );

      if (choice == WeeklyTimeChoice.custom) {
        await _chatRepository.addMessage(
          ChatMessageDraft(
            chatSessionId: session.id,
            role: ChatMessageRole.assistant,
            content:
                'Tell me your weekly time budget, and I can shape the preview around it.',
            contentJson: jsonEncode({'kind': 'custom_weekly_time'}),
          ),
        );
        emit(state.copyWith(status: ChatLoadStatus.ready, errorMessage: ''));
        return;
      }

      final result = await _generateGoalPlanPreview(
        GenerateGoalPlanPreviewParams(
          session: session,
          planStyle: planStyle,
          weeklyTime: choice,
        ),
      );
      final pendingConfirmation = jsonDecode(result.pendingConfirmationJson);

      await _chatRepository.addMessage(
        ChatMessageDraft(
          chatSessionId: session.id,
          role: ChatMessageRole.assistant,
          content:
              "I'll create ${result.preview.cards.length} Goal Cards over "
              '${result.preview.durationWeeks} weeks:',
          contentJson: jsonEncode({
            'kind': 'goal_plan_preview',
            'preview': result.preview.toJson(),
            'pending_confirmation': pendingConfirmation,
          }),
          sourceIds: result.preview.cards
              .expand((card) => card.sourceIds)
              .toSet()
              .toList(growable: false),
          cardIds: [if (session.linkedCardId != null) session.linkedCardId!],
          modelSlug: result.modelSlug,
        ),
      );

      emit(
        state.copyWith(
          status: ChatLoadStatus.ready,
          session: result.updatedSession,
          errorMessage: '',
        ),
      );
    } on Object catch (error) {
      emit(
        state.copyWith(
          status: ChatLoadStatus.error,
          errorMessage: _messageFor(error),
        ),
      );
    }
  }

  bool _canUseGuidedPlanning(ChatSessionEntity? session) {
    return session != null &&
        session.purpose == ChatPurpose.planSuggestion &&
        !state.status.isBusy;
  }

  Future<void> _askGoalEditChat(ChatSessionEntity session, String query) async {
    await _chatRepository.addMessage(
      ChatMessageDraft(
        chatSessionId: session.id,
        role: ChatMessageRole.user,
        content: query,
      ),
    );

    final result = await _editGoalPlan(
      EditGoalPlanParams(session: session, request: query),
    );
    final update = result.update;
    final updatedCount = update.updatedCards.length;
    final skippedCount = update.skippedCompletedCards.length;
    final suffix = skippedCount == 0
        ? ''
        : ' I left $skippedCount completed card${skippedCount == 1 ? '' : 's'} unchanged.';

    await _chatRepository.addMessage(
      ChatMessageDraft(
        chatSessionId: session.id,
        role: ChatMessageRole.assistant,
        content: updatedCount == 0
            ? 'No future Goal Cards needed changes.$suffix'
            : 'Done. I updated $updatedCount remaining Goal Card${updatedCount == 1 ? '' : 's'}.$suffix',
        contentJson: jsonEncode({
          'kind': 'goal_plan_edit_result',
          'goal_plan_id': update.goalPlan.id,
          'updated_card_ids': update.updatedCards
              .map((card) => card.id)
              .toList(growable: false),
          'skipped_completed_card_ids': update.skippedCompletedCards
              .map((card) => card.id)
              .toList(growable: false),
        }),
        sourceIds: update.updatedCards
            .expand((card) => card.sourceIds)
            .toSet()
            .toList(growable: false),
        cardIds: update.updatedCards
            .map((card) => card.id)
            .toList(growable: false),
      ),
    );

    emit(state.copyWith(status: ChatLoadStatus.ready, errorMessage: ''));
  }

  PlanStyleChoice? _latestSelectedPlanStyle() {
    for (final message in state.messages.reversed) {
      final json = _contentJsonMap(message);
      if (json['kind'] != 'weekly_time_choices') {
        continue;
      }

      return PlanStyleChoice.fromStorageValue(
        (json['plan_style'] ?? '').toString(),
      );
    }

    return null;
  }

  Map<String, Object?> _contentJsonMap(ChatMessageEntity message) {
    final contentJson = message.contentJson;
    if (contentJson == null || contentJson.trim().isEmpty) {
      return const {};
    }

    try {
      final decoded = jsonDecode(contentJson);
      if (decoded is Map<String, Object?>) {
        return decoded;
      }
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry(key.toString(), value));
      }
    } on FormatException {
      return const {};
    }

    return const {};
  }

  Future<ChatSessionEntity> _loadExistingSession(String chatSessionId) async {
    final session = await _chatRepository.getSession(chatSessionId);
    if (session == null) {
      throw StateError('Chat session was not found.');
    }

    return session;
  }

  String _messageFor(Object error) {
    final message = error.toString();
    if (message.startsWith('Exception: ')) {
      return message.substring('Exception: '.length);
    }
    if (message.startsWith('Bad state: ')) {
      return message.substring('Bad state: '.length);
    }

    return message;
  }

  bool _shouldUseModelSynthesis(String query) {
    final normalized = query.toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
    if (_looksLikeMutationRequest(normalized)) {
      return false;
    }

    if (_hasAnyPhrase(normalized, const [
      'what should',
      'what can i do',
      'what do i do',
      'do next',
      'next step',
      'next for',
      'why ',
      'how ',
      'summarize',
      'summarise',
      'explain',
      'compare',
      'plan',
      'recommend',
      'help me',
      'make sense',
    ])) {
      return true;
    }

    if (_hasAnyPhrase(normalized, const [
      'show me',
      'source for',
      'what have i saved',
      'what did i save',
      'have i saved',
      'do i have anything',
      'what job applications',
      'what personal reminders',
      'reminders do i have',
    ])) {
      return false;
    }

    return normalized.split(' ').length >= 10;
  }

  bool _looksLikeMutationRequest(String normalizedQuery) {
    if (normalizedQuery.startsWith('why ') ||
        normalizedQuery.startsWith('what ') ||
        normalizedQuery.startsWith('how ')) {
      return false;
    }

    return _hasAnyPhrase(normalizedQuery, const [
      'create ',
      'remind ',
      'schedule ',
      'make ',
      'add ',
      'turn this into a reminder',
    ]);
  }

  bool _hasAnyPhrase(String value, List<String> phrases) {
    return phrases.any(value.contains);
  }

  @override
  Future<void> close() async {
    await _messagesSubscription?.cancel();
    return super.close();
  }
}
