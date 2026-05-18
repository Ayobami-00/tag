import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tag/core/DI/di.dart';
import 'package:tag/core/navigation/route_constants.dart';
import 'package:tag/core/presentation/top_signal_banner.dart';
import 'package:tag/features/cards/domain/entities/card_entities.dart';
import 'package:tag/features/cards/domain/use_cases/card_policy.dart';
import 'package:tag/features/cards/presentation/logic/card_detail_cubit.dart';
import 'package:tag/utils/index.dart';

class CardDetailScreen extends StatelessWidget {
  const CardDetailScreen({required this.cardId, super.key});

  final String cardId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CardDetailCubit>(
      create: (_) => locator<CardDetailCubit>()..load(cardId),
      child: const _CardDetailView(),
    );
  }
}

class _CardDetailView extends StatelessWidget {
  const _CardDetailView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CardDetailCubit, CardDetailState>(
      listenWhen: (previous, current) =>
          previous.actionMessage != current.actionMessage ||
          previous.errorMessage != current.errorMessage,
      listener: (context, state) {
        if (state.actionMessage.isNotEmpty) {
          showTopSignalBanner(
            context,
            message: state.actionMessage,
            icon: _signalIconForMessage(state.actionMessage),
            tone: _signalToneForMessage(state.actionMessage),
          );
          context.read<CardDetailCubit>().clearActionMessage();
          return;
        }

        if (state.errorMessage.isNotEmpty) {
          _showSnack(context, state.errorMessage);
          context.read<CardDetailCubit>().clearActionMessage();
        }
      },
      builder: (context, state) {
        final card = state.card;

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              tooltip: 'Back to Today',
              onPressed: () => _goBack(context),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            title: const Text('Card'),
            actions: [
              if (card != null && card.status != TagCardStatus.archived)
                IconButton(
                  tooltip: 'Archive card',
                  onPressed: () => _archive(context),
                  icon: const Icon(Icons.archive_outlined),
                ),
            ],
          ),
          body: SafeArea(child: _bodyFor(context, state)),
        );
      },
    );
  }

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(todayPath);
  }

  Widget _bodyFor(BuildContext context, CardDetailState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == CardDetailStatus.error ||
        state.status == CardDetailStatus.notFound ||
        state.card == null) {
      return _DetailMessage(
        icon: Icons.info_outline_rounded,
        title: 'Card unavailable',
        message: state.errorMessage.isEmpty
            ? 'This Tag Card could not be loaded from local storage.'
            : state.errorMessage,
      );
    }

    return _LoadedCardDetail(
      card: state.card!,
      onAction: (action) => _handleAction(context, action),
      onOpenSource: () => _openSource(context),
    );
  }

  Future<void> _handleAction(BuildContext context, TagCardAction action) async {
    switch (action) {
      case TagCardAction.complete:
        await context.read<CardDetailCubit>().complete();
      case TagCardAction.snooze:
        await _showSnoozeSheet(context);
      case TagCardAction.cancel:
        await context.read<CardDetailCubit>().cancel();
      case TagCardAction.dismiss:
        await context.read<CardDetailCubit>().dismiss();
      case TagCardAction.planThis:
        final recorded = await context.read<CardDetailCubit>().recordPlanThis();
        if (context.mounted && recorded) {
          context.go(chatPath);
        }
      case TagCardAction.edit:
        final card = context.read<CardDetailCubit>().state.card;
        if (card?.cardType != TagCardType.goal) {
          context.go(chatPath);
          return;
        }
        final session = await context
            .read<CardDetailCubit>()
            .startEditingGoal();
        if (!context.mounted) {
          return;
        }
        if (session != null) {
          context.go(chatSessionLocation(session.id));
        } else {
          _showSnack(context, 'Could not open the goal edit chat.');
        }
      case TagCardAction.viewSpace:
        final card = context.read<CardDetailCubit>().state.card;
        if (card == null) {
          return;
        }
        await context.read<CardDetailCubit>().recordViewSpace();
        if (!context.mounted) {
          return;
        }
        context.push(spaceDetailLocation(card.space.id));
      case TagCardAction.archive:
        await _archive(context);
    }
  }

  Future<void> _openSource(BuildContext context) async {
    final card = context.read<CardDetailCubit>().state.card;
    if (card == null) {
      return;
    }

    final sourceId = await context.read<CardDetailCubit>().openPrimarySource();
    if (!context.mounted || sourceId == null) {
      return;
    }

    context.push(sourcePreviewLocation(sourceId, fromCardId: card.id));
  }

  Future<void> _archive(BuildContext context) async {
    final archived = await context.read<CardDetailCubit>().archive();
    if (!context.mounted || !archived) {
      return;
    }

    if (context.canPop()) {
      context.pop();
    } else {
      context.go(todayPath);
    }
  }

  Future<void> _showSnoozeSheet(BuildContext context) async {
    final card = context.read<CardDetailCubit>().state.card;
    if (card == null) {
      return;
    }

    final selected = await showModalBottomSheet<_DetailSnoozeOption>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        final colors = Theme.of(sheetContext).extension<TagThemeColors>()!;
        final options = _snoozeOptions(DateTime.now());

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              TagSpacing.s5,
              0,
              TagSpacing.s5,
              TagSpacing.s5,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Snooze',
                  style: Theme.of(sheetContext).textTheme.titleMedium,
                ),
                const SizedBox(height: TagSpacing.s1),
                Text(
                  card.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    sheetContext,
                  ).textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
                ),
                const SizedBox(height: TagSpacing.s4),
                for (final option in options)
                  ListTile(
                    onTap: () => Navigator.of(sheetContext).pop(option),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(TagRadii.input),
                    ),
                    leading: Icon(
                      Icons.schedule_rounded,
                      color: colors.snoozedText,
                    ),
                    title: Text(option.label),
                    subtitle: Text(_formatDateTime(option.until)),
                  ),
              ],
            ),
          ),
        );
      },
    );

    if (selected == null || !context.mounted) {
      return;
    }

    await context.read<CardDetailCubit>().snooze(
      selected.until,
      optionLabel: selected.label,
    );
  }

  List<_DetailSnoozeOption> _snoozeOptions(DateTime now) {
    final localNow = now.toLocal();
    final evening = DateTime(localNow.year, localNow.month, localNow.day, 18);
    final tomorrowMorning = DateTime(
      localNow.year,
      localNow.month,
      localNow.day + 1,
      9,
    );

    return [
      _DetailSnoozeOption(
        label: 'In 30 minutes',
        until: localNow.add(const Duration(minutes: 30)),
      ),
      _DetailSnoozeOption(
        label: evening.isAfter(localNow) ? 'This evening' : 'In 4 hours',
        until: evening.isAfter(localNow)
            ? evening
            : localNow.add(const Duration(hours: 4)),
      ),
      _DetailSnoozeOption(label: 'Tomorrow morning', until: tomorrowMorning),
    ];
  }

  void _showSnack(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  IconData _signalIconForMessage(String message) {
    if (message.startsWith('Completed')) {
      return Icons.check_rounded;
    }
    if (message.startsWith('Snoozed')) {
      return Icons.schedule_rounded;
    }
    if (message.startsWith('Cancelled')) {
      return Icons.close_rounded;
    }
    if (message.startsWith('Dismissed')) {
      return Icons.visibility_off_outlined;
    }
    if (message.startsWith('Archived')) {
      return Icons.archive_outlined;
    }
    if (message.startsWith('Plan')) {
      return Icons.auto_awesome_rounded;
    }

    return Icons.check_rounded;
  }

  TopSignalTone _signalToneForMessage(String message) {
    if (message.startsWith('Completed')) {
      return TopSignalTone.success;
    }
    if (message.startsWith('Snoozed')) {
      return TopSignalTone.snoozed;
    }
    if (message.startsWith('Cancelled') || message.startsWith('Archived')) {
      return TopSignalTone.muted;
    }
    if (message.startsWith('Dismissed') || message.startsWith('Plan')) {
      return TopSignalTone.suggestion;
    }

    return TopSignalTone.neutral;
  }
}

class _LoadedCardDetail extends StatelessWidget {
  const _LoadedCardDetail({
    required this.card,
    required this.onAction,
    required this.onOpenSource,
  });

  final TagCardEntity card;
  final ValueChanged<TagCardAction> onAction;
  final VoidCallback onOpenSource;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<TagThemeColors>()!;
    final theme = Theme.of(context);
    final style = _CardDetailStyle.forCard(colors, card);
    final actions = CardPolicy.availableActionsFor(card);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        TagSpacing.s5,
        TagSpacing.s4,
        TagSpacing.s5,
        TagSpacing.s8,
      ),
      children: [
        Row(
          children: [
            _DetailTypeChip(label: _chipLabel(card), style: style),
            const SizedBox(width: TagSpacing.s2),
            Expanded(
              child: Text(
                card.space.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: TagSpacing.s4),
        Text(
          card.title,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: TagSpacing.s3),
        Text(
          card.reason,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: TagSpacing.s6),
        _DetailInfoRow(
          icon: _typeIcon(card),
          iconColor: style.accent,
          label: _timeLabel(card),
        ),
        const SizedBox(height: TagSpacing.s3),
        _DetailInfoRow(
          icon: Icons.space_dashboard_outlined,
          iconColor: colors.brandSoftText,
          label: 'Space: ${card.space.name}',
        ),
        const SizedBox(height: TagSpacing.s6),
        _DetailSection(
          title: 'Why this exists',
          icon: Icons.fact_check_outlined,
          child: Text(
            card.evidenceSummary.trim().isEmpty
                ? card.reason
                : card.evidenceSummary,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: TagSpacing.s4),
        _DetailSection(
          title: 'Source evidence',
          icon: Icons.source_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                card.sourceSummary,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (card.sourceIds.isNotEmpty) ...[
                const SizedBox(height: TagSpacing.s2),
                Text(
                  'Linked source: ${card.sourceIds.first}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.textTertiary,
                  ),
                ),
                const SizedBox(height: TagSpacing.s4),
                OutlinedButton.icon(
                  onPressed: onOpenSource,
                  icon: const Icon(Icons.source_outlined, size: 18),
                  label: const Text('Open Source'),
                ),
              ],
            ],
          ),
        ),
        if (actions.isNotEmpty) ...[
          const SizedBox(height: TagSpacing.s6),
          Text('Actions', style: theme.textTheme.titleSmall),
          const SizedBox(height: TagSpacing.s3),
          Wrap(
            spacing: TagSpacing.s2,
            runSpacing: TagSpacing.s2,
            children: [
              for (final action in actions)
                _DetailActionButton(action: action, onPressed: onAction),
            ],
          ),
        ],
      ],
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<TagThemeColors>()!;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(TagRadii.card),
        border: Border.all(color: colors.borderDefault),
      ),
      child: Padding(
        padding: const EdgeInsets.all(TagSpacing.s4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: colors.textTertiary),
                const SizedBox(width: TagSpacing.s2),
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: TagSpacing.s3),
            child,
          ],
        ),
      ),
    );
  }
}

class _DetailInfoRow extends StatelessWidget {
  const _DetailInfoRow({
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: TagSpacing.s2),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: iconColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailActionButton extends StatelessWidget {
  const _DetailActionButton({required this.action, required this.onPressed});

  final TagCardAction action;
  final ValueChanged<TagCardAction> onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => onPressed(action),
      icon: Icon(_iconFor(action), size: 18),
      label: Text(action.label),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(44, 40),
        padding: const EdgeInsets.symmetric(horizontal: TagSpacing.s3),
      ),
    );
  }

  IconData _iconFor(TagCardAction action) {
    return switch (action) {
      TagCardAction.complete => Icons.check_circle_outline_rounded,
      TagCardAction.snooze => Icons.schedule_rounded,
      TagCardAction.cancel => Icons.cancel_outlined,
      TagCardAction.dismiss => Icons.visibility_off_outlined,
      TagCardAction.planThis => Icons.auto_awesome_rounded,
      TagCardAction.edit => Icons.edit_outlined,
      TagCardAction.viewSpace => Icons.space_dashboard_outlined,
      TagCardAction.archive => Icons.archive_outlined,
    };
  }
}

class _DetailTypeChip extends StatelessWidget {
  const _DetailTypeChip({required this.label, required this.style});

  final String label;
  final _CardDetailStyle style;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: style.chipBackground,
        borderRadius: BorderRadius.circular(TagRadii.chip),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: TagSpacing.s3,
          vertical: TagSpacing.s1,
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: style.chipText,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _DetailMessage extends StatelessWidget {
  const _DetailMessage({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<TagThemeColors>()!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(TagSpacing.s5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: colors.textTertiary, size: 28),
            const SizedBox(height: TagSpacing.s3),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: TagSpacing.s2),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardDetailStyle {
  const _CardDetailStyle({
    required this.accent,
    required this.chipBackground,
    required this.chipText,
  });

  factory _CardDetailStyle.forCard(TagThemeColors colors, TagCardEntity card) {
    if (card.status == TagCardStatus.completed) {
      return _CardDetailStyle(
        accent: colors.completed,
        chipBackground: colors.completedSoft,
        chipText: colors.completedText,
      );
    }
    if (card.status == TagCardStatus.snoozed) {
      return _CardDetailStyle(
        accent: colors.snoozed,
        chipBackground: colors.snoozedSoft,
        chipText: colors.snoozedText,
      );
    }
    if (card.status == TagCardStatus.cancelled ||
        card.status == TagCardStatus.dismissed ||
        card.status == TagCardStatus.archived) {
      return _CardDetailStyle(
        accent: colors.cancelled,
        chipBackground: colors.cancelledSoft,
        chipText: colors.cancelledText,
      );
    }

    return switch (card.cardType) {
      TagCardType.urgent => _CardDetailStyle(
        accent: colors.urgent,
        chipBackground: colors.urgentSoft,
        chipText: colors.urgentText,
      ),
      TagCardType.goal => _CardDetailStyle(
        accent: colors.goalActive,
        chipBackground: colors.goalActiveSoft,
        chipText: colors.goalActiveText,
      ),
      TagCardType.suggestion => _CardDetailStyle(
        accent: colors.suggestion,
        chipBackground: colors.suggestionSoft,
        chipText: colors.suggestionText,
      ),
    };
  }

  final Color accent;
  final Color chipBackground;
  final Color chipText;
}

class _DetailSnoozeOption {
  const _DetailSnoozeOption({required this.label, required this.until});

  final String label;
  final DateTime until;
}

String _chipLabel(TagCardEntity card) {
  if (card.status != TagCardStatus.active) {
    return card.status.label.toUpperCase();
  }

  return card.cardType.label.toUpperCase();
}

IconData _typeIcon(TagCardEntity card) {
  if (card.status == TagCardStatus.snoozed) {
    return Icons.schedule_rounded;
  }

  return switch (card.cardType) {
    TagCardType.urgent => Icons.alarm_rounded,
    TagCardType.goal => Icons.flag_outlined,
    TagCardType.suggestion => Icons.auto_awesome_rounded,
  };
}

String _timeLabel(TagCardEntity card) {
  if (card.status == TagCardStatus.snoozed && card.snoozedUntil != null) {
    return 'Snoozed until ${_formatTimestamp(card.snoozedUntil!)}';
  }

  final deadline = card.nextActiveDeadline;
  if (deadline == null) {
    return card.cardType == TagCardType.suggestion
        ? 'In-app suggestion'
        : 'No active deadline';
  }

  final localDeadline = DateTime.fromMillisecondsSinceEpoch(
    deadline,
    isUtc: true,
  ).toLocal();
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final deadlineDay = DateTime(
    localDeadline.year,
    localDeadline.month,
    localDeadline.day,
  );
  final time = DateFormat('h:mm a').format(localDeadline);

  if (localDeadline.isBefore(now)) {
    return 'Overdue · $time';
  }
  if (deadlineDay == today) {
    return 'Due today · $time';
  }
  if (deadlineDay == today.add(const Duration(days: 1))) {
    return 'Due tomorrow · $time';
  }

  return 'Due ${DateFormat('MMM d').format(localDeadline)} · $time';
}

String _formatTimestamp(int timestamp) {
  return _formatDateTime(
    DateTime.fromMillisecondsSinceEpoch(timestamp, isUtc: true).toLocal(),
  );
}

String _formatDateTime(DateTime dateTime) {
  return DateFormat('MMM d, h:mm a').format(dateTime);
}
