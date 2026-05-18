import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tag/core/DI/di.dart';
import 'package:tag/core/ai/schemas/goal_plan_preview_schema.dart';
import 'package:tag/core/navigation/route_constants.dart';
import 'package:tag/features/chat/domain/entities/chat_entities.dart';
import 'package:tag/features/chat/domain/entities/guided_planning_entities.dart';
import 'package:tag/features/chat/presentation/logic/chat_cubit.dart';
import 'package:tag/utils/index.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key, this.chatSessionId});

  final String? chatSessionId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ChatCubit>(
      create: (_) => locator<ChatCubit>()..open(chatSessionId: chatSessionId),
      child: const _ChatView(),
    );
  }
}

class _ChatView extends StatelessWidget {
  const _ChatView();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<TagThemeColors>()!;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back to Today',
          onPressed: () => _goBack(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: BlocBuilder<ChatCubit, ChatState>(
          buildWhen: (previous, current) =>
              previous.session?.id != current.session?.id ||
              previous.session?.title != current.session?.title,
          builder: (context, state) {
            final session = state.session;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session?.title ?? 'Ask Tag',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  session?.purpose == ChatPurpose.planSuggestion
                      ? 'Guided planning'
                      : 'Saved context',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colors.textTertiary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            );
          },
        ),
      ),
      body: SafeArea(
        child: BlocConsumer<ChatCubit, ChatState>(
          listenWhen: (previous, current) =>
              previous.errorMessage != current.errorMessage ||
              previous.session?.id != current.session?.id,
          listener: (context, state) {
            _syncRouteToSession(context, state);

            if (state.errorMessage.isEmpty) {
              return;
            }

            final messenger = ScaffoldMessenger.of(context);
            messenger.hideCurrentSnackBar();
            messenger.showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          builder: (context, state) {
            return Column(
              children: [
                Expanded(
                  child: state.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _MessageList(state: state),
                ),
                _ChatComposer(
                  isBusy: state.status.isBusy,
                  onSend: (value) => context.read<ChatCubit>().ask(value),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(todayPath);
  }

  void _syncRouteToSession(BuildContext context, ChatState state) {
    final session = state.session;
    if (session == null) {
      return;
    }

    final currentPath = GoRouterState.of(context).uri.path;
    if (currentPath == chatPath) {
      context.go(chatSessionLocation(session.id));
    }
  }
}

class _MessageList extends StatelessWidget {
  const _MessageList({required this.state});

  final ChatState state;

  @override
  Widget build(BuildContext context) {
    if (state.messages.isEmpty) {
      return const _EmptyChatState();
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        TagSpacing.s4,
        TagSpacing.s3,
        TagSpacing.s4,
        TagSpacing.s6,
      ),
      itemCount: state.messages.length + (state.isSending ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= state.messages.length) {
          return const _ThinkingBubble();
        }

        final message = state.messages[index];
        return _AnimatedMessageEntry(
          index: index,
          child: Padding(
            padding: const EdgeInsets.only(bottom: TagSpacing.s3),
            child: message.role == ChatMessageRole.user
                ? _UserMessageBubble(message: message)
                : _AssistantMessageBubble(message: message),
          ),
        );
      },
    );
  }
}

class _AnimatedMessageEntry extends StatelessWidget {
  const _AnimatedMessageEntry({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (disableAnimations) {
      return child;
    }

    final lift = 8.0 + (index.clamp(0, 4).toDouble() * 0.8);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * lift),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class _EmptyChatState extends StatelessWidget {
  const _EmptyChatState();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<TagThemeColors>()!;
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        TagSpacing.s4,
        TagSpacing.s6,
        TagSpacing.s4,
        TagSpacing.s6,
      ),
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surfaceCard,
            borderRadius: BorderRadius.circular(TagRadii.card),
            border: Border.all(color: colors.borderDefault),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(TagSpacing.s5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.brandSoft,
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(TagSpacing.s3),
                    child: Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: colors.brandSoftText,
                    ),
                  ),
                ),
                const SizedBox(height: TagSpacing.s4),
                Text(
                  'Ask about what you saved.',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: TagSpacing.s2),
                Text(
                  'Answers stay grounded in local sources and cards.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: TagSpacing.s4),
                Wrap(
                  spacing: TagSpacing.s2,
                  runSpacing: TagSpacing.s2,
                  children: const [
                    _PromptChip(label: 'What CUDA resources have I saved?'),
                    _PromptChip(label: 'Show saved vacation ideas'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PromptChip extends StatelessWidget {
  const _PromptChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<TagThemeColors>()!;

    return ActionChip(
      label: Text(label),
      avatar: Icon(Icons.search_rounded, size: 16, color: colors.brandSoftText),
      backgroundColor: colors.brandSoft,
      side: BorderSide(color: colors.borderDefault),
      labelStyle: Theme.of(
        context,
      ).textTheme.labelSmall?.copyWith(color: colors.brandSoftText),
      onPressed: () => context.read<ChatCubit>().ask(label),
    );
  }
}

class _UserMessageBubble extends StatelessWidget {
  const _UserMessageBubble({required this.message});

  final ChatMessageEntity message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<TagThemeColors>()!;

    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.brandSoft,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(TagRadii.input),
              topRight: Radius.circular(TagRadii.input),
              bottomLeft: Radius.circular(TagRadii.input),
              bottomRight: Radius.circular(TagSpacing.s2),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: TagSpacing.s4,
              vertical: TagSpacing.s3,
            ),
            child: Text(
              message.content,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: colors.textPrimary),
            ),
          ),
        ),
      ),
    );
  }
}

class _AssistantMessageBubble extends StatelessWidget {
  const _AssistantMessageBubble({required this.message});

  final ChatMessageEntity message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<TagThemeColors>()!;
    final answer = message.structuredAnswer;
    final planningContent = _PlanningMessageContent.fromMessage(message);

    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surfaceCard,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(TagRadii.input),
              topRight: Radius.circular(TagRadii.input),
              bottomLeft: Radius.circular(TagSpacing.s2),
              bottomRight: Radius.circular(TagRadii.input),
            ),
            border: Border.all(color: colors.borderDefault),
          ),
          child: Padding(
            padding: const EdgeInsets.all(TagSpacing.s4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.content,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                if (answer?.reasoningSummary.isNotEmpty == true) ...[
                  const SizedBox(height: TagSpacing.s3),
                  Text(
                    answer!.reasoningSummary,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
                if (message.sourceCitations.isNotEmpty) ...[
                  const SizedBox(height: TagSpacing.s4),
                  _CitationWrap(citations: message.sourceCitations),
                ],
                if (answer?.optionalAction != null) ...[
                  const SizedBox(height: TagSpacing.s4),
                  _OptionalActionPreview(action: answer!.optionalAction!),
                ],
                if (planningContent != null) ...[
                  const SizedBox(height: TagSpacing.s4),
                  _PlanningContentView(content: planningContent),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CitationWrap extends StatelessWidget {
  const _CitationWrap({required this.citations});

  final List<ChatSourceCitationEntity> citations;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<TagThemeColors>()!;

    return Wrap(
      spacing: TagSpacing.s2,
      runSpacing: TagSpacing.s2,
      children: [
        for (final citation in citations)
          ActionChip(
            key: ValueKey('chat_citation_${citation.sourceId}'),
            avatar: Icon(
              Icons.source_outlined,
              color: colors.brandSoftText,
              size: 16,
            ),
            label: Text(citation.label),
            tooltip: citation.evidencePreview,
            backgroundColor: colors.backgroundSubtle,
            side: BorderSide(color: colors.borderDefault),
            labelStyle: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: colors.brandSoftText),
            onPressed: () => context.push(
              sourcePreviewLocation(
                citation.sourceId,
                fromCardId: citation.cardId,
              ),
            ),
          ),
      ],
    );
  }
}

class _OptionalActionPreview extends StatelessWidget {
  const _OptionalActionPreview({required this.action});

  final ChatOptionalActionPreviewEntity action;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<TagThemeColors>()!;
    final title = action.label.trim().isEmpty ? 'Preview' : action.label;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.backgroundSubtle,
        borderRadius: BorderRadius.circular(TagRadii.compactCard),
        border: Border.all(color: colors.borderDefault),
      ),
      child: Padding(
        padding: const EdgeInsets.all(TagSpacing.s3),
        child: Row(
          children: [
            Icon(Icons.fact_check_outlined, color: colors.brandSoftText),
            const SizedBox(width: TagSpacing.s2),
            Expanded(
              child: Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: colors.textPrimary),
              ),
            ),
            const SizedBox(width: TagSpacing.s2),
            Text(
              'Preview',
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: colors.textTertiary),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanningContentView extends StatelessWidget {
  const _PlanningContentView({required this.content});

  final _PlanningMessageContent content;

  @override
  Widget build(BuildContext context) {
    return switch (content.kind) {
      'plan_style_choices' => _PlanStyleChoices(choices: content.choices),
      'weekly_time_choices' => _WeeklyTimeChoices(choices: content.choices),
      'goal_plan_preview' =>
        content.preview == null
            ? const SizedBox.shrink()
            : _GoalPlanPreviewPanel(preview: content.preview!),
      _ => const SizedBox.shrink(),
    };
  }
}

class _PlanStyleChoices extends StatelessWidget {
  const _PlanStyleChoices({required this.choices});

  final List<_PlanningChoice> choices;

  @override
  Widget build(BuildContext context) {
    final effectiveChoices = choices.isEmpty
        ? PlanStyleChoice.values
              .map(
                (choice) => _PlanningChoice(
                  value: choice.storageValue,
                  label: choice.label,
                ),
              )
              .toList(growable: false)
        : choices;

    return _PlanningChoiceWrap(
      choices: effectiveChoices,
      icon: Icons.auto_awesome_rounded,
      onSelected: (choice) => context.read<ChatCubit>().selectPlanStyle(
        PlanStyleChoice.fromStorageValue(choice.value),
      ),
    );
  }
}

class _WeeklyTimeChoices extends StatelessWidget {
  const _WeeklyTimeChoices({required this.choices});

  final List<_PlanningChoice> choices;

  @override
  Widget build(BuildContext context) {
    final effectiveChoices = choices.isEmpty
        ? WeeklyTimeChoice.values
              .map(
                (choice) => _PlanningChoice(
                  value: choice.storageValue,
                  label: choice.label,
                ),
              )
              .toList(growable: false)
        : choices;

    return _PlanningChoiceWrap(
      choices: effectiveChoices,
      icon: Icons.schedule_rounded,
      onSelected: (choice) => context.read<ChatCubit>().selectWeeklyTime(
        WeeklyTimeChoice.fromStorageValue(choice.value),
      ),
    );
  }
}

class _PlanningChoiceWrap extends StatelessWidget {
  const _PlanningChoiceWrap({
    required this.choices,
    required this.icon,
    required this.onSelected,
  });

  final List<_PlanningChoice> choices;
  final IconData icon;
  final ValueChanged<_PlanningChoice> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<TagThemeColors>()!;

    return Wrap(
      spacing: TagSpacing.s2,
      runSpacing: TagSpacing.s2,
      children: [
        for (final choice in choices)
          ActionChip(
            key: ValueKey('planning_choice_${choice.value}'),
            label: Text(choice.label),
            avatar: Icon(icon, size: 16, color: colors.suggestionText),
            backgroundColor: colors.suggestionSoft,
            side: BorderSide(color: colors.borderDefault),
            labelStyle: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: colors.suggestionText),
            onPressed: () => onSelected(choice),
          ),
      ],
    );
  }
}

class _GoalPlanPreviewPanel extends StatelessWidget {
  const _GoalPlanPreviewPanel({required this.preview});

  final GoalPlanPreview preview;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<TagThemeColors>()!;
    final theme = Theme.of(context);
    final canCreate = context.select((ChatCubit cubit) {
      final state = cubit.state;
      return !state.status.isBusy &&
          state.session?.pendingConfirmationJson?.trim().isNotEmpty == true;
    });

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.backgroundSubtle,
        borderRadius: BorderRadius.circular(TagRadii.compactCard),
        border: Border.all(color: colors.borderDefault),
      ),
      child: Padding(
        padding: const EdgeInsets.all(TagSpacing.s3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.flag_outlined, color: colors.goalActiveText),
                const SizedBox(width: TagSpacing.s2),
                Expanded(
                  child: Text(
                    preview.goalName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: TagSpacing.s2),
            Text(
              '${preview.cards.length} cards · ${preview.durationWeeks} weeks',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: TagSpacing.s3),
            for (var index = 0; index < preview.cards.length; index++) ...[
              _PreviewCardRow(index: index + 1, card: preview.cards[index]),
              if (index != preview.cards.length - 1)
                Divider(height: TagSpacing.s4, color: colors.borderDefault),
            ],
            const SizedBox(height: TagSpacing.s3),
            Wrap(
              spacing: TagSpacing.s2,
              runSpacing: TagSpacing.s2,
              children: [
                FilledButton.icon(
                  key: const ValueKey('goal_plan_preview_create_cards_button'),
                  onPressed: canCreate
                      ? () => context.read<ChatCubit>().confirmGoalPlan()
                      : null,
                  icon: const Icon(Icons.add_task_rounded),
                  label: Text(canCreate ? 'Create cards' : 'Cards created'),
                ),
                OutlinedButton.icon(
                  key: const ValueKey('goal_plan_preview_edit_plan_button'),
                  onPressed: () => _showMilestone18Notice(
                    context,
                    'Tell me what to change before creating cards.',
                  ),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit plan'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showMilestone18Notice(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}

class _PreviewCardRow extends StatelessWidget {
  const _PreviewCardRow({required this.index, required this.card});

  final int index;
  final GoalPlanPreviewCard card;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<TagThemeColors>()!;
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.goalActiveSoft,
            shape: BoxShape.circle,
          ),
          child: SizedBox.square(
            dimension: 24,
            child: Center(
              child: Text(
                '$index',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.goalActiveText,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: TagSpacing.s2),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(card.title, style: theme.textTheme.bodyMedium),
              const SizedBox(height: TagSpacing.s1),
              Text(
                card.reason,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              if (card.scheduledFor != null) ...[
                const SizedBox(height: TagSpacing.s1),
                Text(
                  _formatSchedule(card.scheduledFor!),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.goalActiveText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _formatSchedule(String value) {
    final parsed = DateTime.tryParse(value);
    if (parsed == null) {
      return value;
    }

    final local = parsed.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '${local.year}-$month-$day $hour:$minute';
  }
}

class _PlanningMessageContent {
  const _PlanningMessageContent({
    required this.kind,
    this.choices = const [],
    this.preview,
  });

  final String kind;
  final List<_PlanningChoice> choices;
  final GoalPlanPreview? preview;

  static _PlanningMessageContent? fromMessage(ChatMessageEntity message) {
    final contentJson = message.contentJson;
    if (contentJson == null || contentJson.trim().isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(contentJson);
      final json = _mapValue(decoded);
      final kind = (json['kind'] ?? '').toString();
      if (kind == 'plan_style_choices' || kind == 'weekly_time_choices') {
        return _PlanningMessageContent(
          kind: kind,
          choices: _choiceList(json['choices']),
        );
      }
      if (kind == 'goal_plan_preview') {
        final previewJson = _mapValue(json['preview']);
        if (previewJson.isEmpty) {
          return null;
        }

        return _PlanningMessageContent(
          kind: kind,
          preview: GoalPlanPreview.fromJson(previewJson),
        );
      }
    } on Object {
      return null;
    }

    return null;
  }

  static List<_PlanningChoice> _choiceList(Object? value) {
    if (value is! List) {
      return const [];
    }

    return value
        .map(_mapValue)
        .where((json) => json.isNotEmpty)
        .map(
          (json) => _PlanningChoice(
            value: (json['value'] ?? '').toString(),
            label: (json['label'] ?? '').toString(),
          ),
        )
        .where((choice) => choice.value.isNotEmpty && choice.label.isNotEmpty)
        .toList(growable: false);
  }

  static Map<String, Object?> _mapValue(Object? value) {
    if (value is Map<String, Object?>) {
      return value;
    }
    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }

    return const {};
  }
}

class _PlanningChoice {
  const _PlanningChoice({required this.value, required this.label});

  final String value;
  final String label;
}

class _ThinkingBubble extends StatelessWidget {
  const _ThinkingBubble();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<TagThemeColors>()!;

    return Align(
      key: const ValueKey('chat_thinking_bubble'),
      alignment: Alignment.centerLeft,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surfaceCard,
          borderRadius: BorderRadius.circular(TagRadii.input),
          border: Border.all(color: colors.borderDefault),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: TagSpacing.s4,
            vertical: TagSpacing.s3,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox.square(
                dimension: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colors.brandPrimary,
                ),
              ),
              const SizedBox(width: TagSpacing.s2),
              Text(
                'Checking saved context',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatComposer extends StatefulWidget {
  const _ChatComposer({required this.isBusy, required this.onSend});

  final bool isBusy;
  final ValueChanged<String> onSend;

  @override
  State<_ChatComposer> createState() => _ChatComposerState();
}

class _ChatComposerState extends State<_ChatComposer> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<TagThemeColors>()!;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        border: Border(top: BorderSide(color: colors.borderDefault)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          TagSpacing.s4,
          TagSpacing.s3,
          TagSpacing.s4,
          TagSpacing.s3,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                key: const ValueKey('chat_composer_field'),
                controller: _controller,
                enabled: !widget.isBusy,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: widget.isBusy ? null : (_) => _send(),
                decoration: const InputDecoration(
                  hintText: 'Ask about saved context',
                ),
              ),
            ),
            const SizedBox(width: TagSpacing.s2),
            IconButton.filled(
              key: const ValueKey('chat_send_button'),
              onPressed: widget.isBusy ? null : _send,
              tooltip: 'Send',
              icon: widget.isBusy
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.arrow_upward_rounded),
            ),
          ],
        ),
      ),
    );
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      return;
    }

    _controller.clear();
    widget.onSend(text);
  }
}
