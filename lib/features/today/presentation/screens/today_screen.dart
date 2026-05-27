import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tag/core/DI/di.dart';
import 'package:tag/core/config/app_config.dart';
import 'package:tag/core/navigation/route_constants.dart';
import 'package:tag/core/presentation/top_signal_banner.dart';
import 'package:tag/core/startup/app_cubit.dart';
import 'package:tag/features/cards/domain/entities/card_entities.dart';
import 'package:tag/features/cards/domain/entities/card_query.dart';
import 'package:tag/features/model_setup/domain/repositories/model_setup_repository.dart';
import 'package:tag/features/source_ingestion/domain/services/manual_source_picker.dart';
import 'package:tag/features/source_ingestion/presentation/logic/source_ingestion_cubit.dart';
import 'package:tag/features/spaces/presentation/screens/spaces_overview.dart';
import 'package:tag/features/today/presentation/logic/today_cubit.dart';
import 'package:tag/features/today/presentation/widgets/tag_card_list_item.dart';
import 'package:tag/utils/index.dart';

const bool _showTodayDebugActions =
    kDebugMode && bool.fromEnvironment('TAG_SHOW_TODAY_DEBUG_ACTIONS');

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SourceIngestionCubit>(
          create: (_) => locator<SourceIngestionCubit>()..load(),
        ),
        BlocProvider<TodayCubit>(create: (_) => locator<TodayCubit>()..load()),
      ],
      child: const _TodayView(),
    );
  }
}

class _TodayView extends StatelessWidget {
  const _TodayView();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<TagThemeColors>()!;
    final isPreparingLocalModels = context.select(
      (AppCubit cubit) => cubit.state.isPreparingLocalModels,
    );
    final localModelPreparationProgress = context.select(
      (AppCubit cubit) => cubit.state.localModelPreparationProgress,
    );
    final showBetaFeedbackAction =
        kDebugMode || locator<AppConfig>().betaFeedbackEnabled;

    return BlocListener<SourceIngestionCubit, SourceIngestionState>(
      listenWhen: (previous, current) =>
          previous.actionMessage != current.actionMessage ||
          previous.errorMessage != current.errorMessage,
      listener: (context, state) {
        if (state.actionMessage.isNotEmpty) {
          showTopSignalBanner(
            context,
            message: state.actionMessage,
            icon: Icons.bookmark_added_outlined,
          );
          context.read<SourceIngestionCubit>().clearActionMessage();
          return;
        }

        if (state.errorMessage.isNotEmpty) {
          _showSnack(context, state.errorMessage);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppConstants.appName),
          actions: [
            if (showBetaFeedbackAction)
              IconButton(
                onPressed: () => context.push(betaFeedbackPath),
                tooltip: 'Beta feedback',
                icon: const Icon(Icons.bug_report_outlined),
              ),
            if (_showTodayDebugActions) ...[
              IconButton(
                onPressed: () => context.go(ragSearchDebugPath),
                tooltip: 'RAG search',
                icon: const Icon(Icons.saved_search_rounded),
              ),
              IconButton(
                onPressed: () => context.go(aiQueueDebugPath),
                tooltip: 'AI queue',
                icon: const Icon(Icons.manage_search_rounded),
              ),
              IconButton(
                onPressed: () => context.go(modelSetupPath),
                tooltip: 'Model setup',
                icon: const Icon(Icons.memory_rounded),
              ),
            ],
          ],
        ),
        floatingActionButton:
            BlocBuilder<SourceIngestionCubit, SourceIngestionState>(
              buildWhen: (previous, current) =>
                  previous.isSaving != current.isSaving,
              builder: (context, sourceState) {
                return _TodaySpeedDialFab(
                  isSavingImage: sourceState.isSaving,
                  onAskTag: () => context.go(chatPath),
                  onAttachImage: () => _importImageWithDescription(context),
                );
              },
            ),
        body: SafeArea(
          child: BlocBuilder<TodayCubit, TodayState>(
            builder: (context, todayState) {
              return ListView(
                padding: const EdgeInsets.fromLTRB(
                  TagSpacing.s4,
                  TagSpacing.s3,
                  TagSpacing.s4,
                  88,
                ),
                children: [
                  Row(
                    children: [
                      _ViewSwitchPill(
                        colors: colors,
                        viewMode: todayState.viewMode,
                        onTap: () =>
                            _showViewSwitcher(context, todayState.viewMode),
                      ),
                      const Spacer(),
                      _FilterButton(
                        colors: colors,
                        filter: todayState.filter,
                        onPressed: () =>
                            _showFilterSheet(context, todayState.filter),
                      ),
                    ],
                  ),
                  const SizedBox(height: TagSpacing.s2),
                  Text(
                    todayState.viewMode == TodayViewMode.spaces
                        ? 'Source-backed contexts, not folders'
                        : 'Sorted by next active deadline',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colors.textTertiary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  if (isPreparingLocalModels) ...[
                    const SizedBox(height: TagSpacing.s3),
                    _LocalModelSetupBanner(
                      progress: localModelPreparationProgress,
                    ),
                  ],
                  if (todayState.hasActiveFilter) ...[
                    const SizedBox(height: TagSpacing.s3),
                    _ActiveFilterChip(
                      filter: todayState.filter,
                      onClear: context.read<TodayCubit>().clearFilter,
                    ),
                  ],
                  const SizedBox(height: TagSpacing.s5),
                  if (todayState.status == TodayStatus.error)
                    _TodayErrorCard(message: todayState.errorMessage)
                  else if (todayState.viewMode == TodayViewMode.spaces)
                    const SpacesOverview()
                  else if (todayState.cards.isEmpty)
                    _EmptyTodayCard(
                      onTrySavingSomething: () =>
                          _importImageWithDescription(context),
                    )
                  else
                    ..._buildCardItems(context, todayState.cards),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCardItems(
    BuildContext context,
    List<TagCardEntity> cards,
  ) {
    final widgets = <Widget>[];

    for (var index = 0; index < cards.length; index++) {
      final card = cards[index];
      widgets
        ..add(
          _DismissibleTodayCard(
            card: card,
            index: index,
            onOpenDetails: (selectedCard) {
              if (selectedCard.isProcessingPlaceholder) {
                context.push(
                  sourcePreviewLocation(selectedCard.sourceIds.first),
                );
                return;
              }

              context.push(cardDetailLocation(selectedCard.id));
            },
            onActionSelected: (selectedCard, action) =>
                _handleCardAction(context, selectedCard, action),
          ),
        )
        ..add(const SizedBox(height: TagSpacing.s3));
    }

    return widgets;
  }

  Future<void> _importImageWithDescription(BuildContext context) async {
    await context.read<SourceIngestionCubit>().importImage(
      requestDescription: (pickedImage) async {
        if (!context.mounted) {
          return null;
        }

        return _showManualImageDescriptionSheet(context, pickedImage);
      },
    );
  }

  Future<String?> _showManualImageDescriptionSheet(
    BuildContext context,
    PickedImageSource pickedImage,
  ) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return _ManualImageDescriptionSheet(pickedImage: pickedImage);
      },
    );
  }

  Future<void> _handleCardAction(
    BuildContext context,
    TagCardEntity card,
    TagCardAction action,
  ) async {
    switch (action) {
      case TagCardAction.complete:
        await _runCardAction(
          context,
          action: () => context.read<TodayCubit>().completeCard(card.id),
          signalAction: action,
          successMessage: 'Completed "${card.title}".',
        );
      case TagCardAction.snooze:
        await _showSnoozeSheet(context, card);
      case TagCardAction.cancel:
        await _runCardAction(
          context,
          action: () => context.read<TodayCubit>().cancelCard(card.id),
          signalAction: action,
          successMessage: 'Cancelled "${card.title}".',
        );
      case TagCardAction.dismiss:
        await _runCardAction(
          context,
          action: () => context.read<TodayCubit>().dismissSuggestion(card.id),
          signalAction: action,
          successMessage: 'Dismissed "${card.title}".',
        );
      case TagCardAction.planThis:
        final session = await context
            .read<TodayCubit>()
            .startPlanningFromSuggestion(card);
        if (!context.mounted) {
          return;
        }
        if (session != null) {
          context.go(chatSessionLocation(session.id));
        } else {
          _showSnack(context, 'Could not start planning for this card.');
        }
      case TagCardAction.edit:
        if (card.cardType != TagCardType.goal) {
          context.go(chatPath);
          return;
        }
        final session = await context.read<TodayCubit>().startEditingGoal(card);
        if (!context.mounted) {
          return;
        }
        if (session != null) {
          context.go(chatSessionLocation(session.id));
        } else {
          _showSnack(context, 'Could not open the goal edit chat.');
        }
      case TagCardAction.viewSpace:
        await context.read<TodayCubit>().recordViewSpace(card);
        if (!context.mounted) {
          return;
        }
        context.push(spaceDetailLocation(card.space.id));
      case TagCardAction.archive:
        _showSnack(context, 'Open the detail screen to archive a card.');
    }
  }

  Future<void> _showSnoozeSheet(
    BuildContext context,
    TagCardEntity card,
  ) async {
    final selected = await showModalBottomSheet<_SnoozeOption>(
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
                  _SelectionTile(
                    label: option.label,
                    icon: Icons.schedule_rounded,
                    isSelected: false,
                    selectedColor: colors.snoozedText,
                    selectedBackground: colors.snoozedSoft,
                    onTap: () => Navigator.of(sheetContext).pop(option),
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

    await _runCardAction(
      context,
      action: () => context.read<TodayCubit>().snoozeCard(
        cardId: card.id,
        snoozedUntil: selected.until,
        optionLabel: selected.label,
      ),
      signalAction: TagCardAction.snooze,
      successMessage: 'Snoozed "${card.title}".',
    );
  }

  List<_SnoozeOption> _snoozeOptions(DateTime now) {
    final localNow = now.toLocal();
    final tomorrowMorning = DateTime(
      localNow.year,
      localNow.month,
      localNow.day + 1,
      9,
    );
    final evening = DateTime(localNow.year, localNow.month, localNow.day, 18);

    return [
      _SnoozeOption(
        label: 'In 30 minutes',
        until: localNow.add(const Duration(minutes: 30)),
      ),
      _SnoozeOption(
        label: evening.isAfter(localNow) ? 'This evening' : 'In 4 hours',
        until: evening.isAfter(localNow)
            ? evening
            : localNow.add(const Duration(hours: 4)),
      ),
      _SnoozeOption(label: 'Tomorrow morning', until: tomorrowMorning),
    ];
  }

  Future<void> _runCardAction(
    BuildContext context, {
    required Future<bool> Function() action,
    required TagCardAction signalAction,
    required String successMessage,
  }) async {
    final succeeded = await action();
    if (!context.mounted) {
      return;
    }

    if (succeeded) {
      _showActionSignal(context, action: signalAction, message: successMessage);
      return;
    }

    _showSnack(context, 'That action is not available for this card.');
  }

  void _showActionSignal(
    BuildContext context, {
    required TagCardAction action,
    required String message,
  }) {
    showTopSignalBanner(
      context,
      message: message,
      icon: _signalIcon(action),
      tone: _signalTone(action),
    );
  }

  IconData _signalIcon(TagCardAction action) {
    return switch (action) {
      TagCardAction.complete => Icons.check_rounded,
      TagCardAction.snooze => Icons.schedule_rounded,
      TagCardAction.cancel => Icons.close_rounded,
      TagCardAction.dismiss => Icons.visibility_off_outlined,
      TagCardAction.planThis => Icons.auto_awesome_rounded,
      TagCardAction.edit => Icons.edit_outlined,
      TagCardAction.viewSpace => Icons.space_dashboard_outlined,
      TagCardAction.archive => Icons.archive_outlined,
    };
  }

  TopSignalTone _signalTone(TagCardAction action) {
    return switch (action) {
      TagCardAction.complete => TopSignalTone.success,
      TagCardAction.snooze => TopSignalTone.snoozed,
      TagCardAction.cancel || TagCardAction.archive => TopSignalTone.muted,
      TagCardAction.dismiss => TopSignalTone.suggestion,
      TagCardAction.planThis => TopSignalTone.suggestion,
      TagCardAction.edit || TagCardAction.viewSpace => TopSignalTone.neutral,
    };
  }

  void _showSnack(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  void _showViewSwitcher(BuildContext context, TodayViewMode activeViewMode) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        final colors = Theme.of(sheetContext).extension<TagThemeColors>()!;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              TagSpacing.s5,
              0,
              TagSpacing.s5,
              TagSpacing.s5,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final mode in TodayViewMode.values)
                    _SelectionTile(
                      label: mode.label,
                      icon: _viewModeIcon(mode),
                      isSelected: mode == activeViewMode,
                      selectedColor: colors.brandSoftText,
                      selectedBackground: colors.brandSoft,
                      onTap: () {
                        context.read<TodayCubit>().setViewMode(mode);
                        Navigator.of(sheetContext).pop();
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showFilterSheet(BuildContext context, TodayCardFilter activeFilter) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        final colors = Theme.of(sheetContext).extension<TagThemeColors>()!;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              TagSpacing.s5,
              0,
              TagSpacing.s5,
              TagSpacing.s5,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final filter in TodayCardFilter.values)
                    _SelectionTile(
                      label: filter.label,
                      icon: _filterIcon(filter),
                      isSelected: filter == activeFilter,
                      selectedColor: _filterColor(colors, filter),
                      selectedBackground: _filterBackground(colors, filter),
                      onTap: () {
                        context.read<TodayCubit>().setFilter(filter);
                        Navigator.of(sheetContext).pop();
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _viewModeIcon(TodayViewMode mode) {
    return switch (mode) {
      TodayViewMode.today => Icons.today_outlined,
      TodayViewMode.tomorrow => Icons.event_outlined,
      TodayViewMode.thisWeek => Icons.date_range_rounded,
      TodayViewMode.all => Icons.view_agenda_outlined,
      TodayViewMode.spaces => Icons.space_dashboard_outlined,
    };
  }

  IconData _filterIcon(TodayCardFilter filter) {
    return switch (filter) {
      TodayCardFilter.all => Icons.layers_outlined,
      TodayCardFilter.processing => Icons.hourglass_empty_rounded,
      TodayCardFilter.urgent => Icons.alarm_rounded,
      TodayCardFilter.goal => Icons.flag_outlined,
      TodayCardFilter.suggestion => Icons.auto_awesome_rounded,
      TodayCardFilter.completed => Icons.check_circle_outline_rounded,
      TodayCardFilter.snoozed => Icons.schedule_rounded,
      TodayCardFilter.cancelled => Icons.cancel_outlined,
    };
  }

  Color _filterColor(TagThemeColors colors, TodayCardFilter filter) {
    return switch (filter) {
      TodayCardFilter.all => colors.brandSoftText,
      TodayCardFilter.processing => colors.brandSoftText,
      TodayCardFilter.urgent => colors.urgentText,
      TodayCardFilter.goal => colors.goalActiveText,
      TodayCardFilter.suggestion => colors.suggestionText,
      TodayCardFilter.completed => colors.completedText,
      TodayCardFilter.snoozed => colors.snoozedText,
      TodayCardFilter.cancelled => colors.cancelledText,
    };
  }

  Color _filterBackground(TagThemeColors colors, TodayCardFilter filter) {
    return switch (filter) {
      TodayCardFilter.all => colors.brandSoft,
      TodayCardFilter.processing => colors.brandSoft,
      TodayCardFilter.urgent => colors.urgentSoft,
      TodayCardFilter.goal => colors.goalActiveSoft,
      TodayCardFilter.suggestion => colors.suggestionSoft,
      TodayCardFilter.completed => colors.completedSoft,
      TodayCardFilter.snoozed => colors.snoozedSoft,
      TodayCardFilter.cancelled => colors.cancelledSoft,
    };
  }
}

class _DismissibleTodayCard extends StatelessWidget {
  const _DismissibleTodayCard({
    required this.card,
    required this.index,
    required this.onOpenDetails,
    required this.onActionSelected,
  });

  final TagCardEntity card;
  final int index;
  final ValueChanged<TagCardEntity> onOpenDetails;
  final Future<void> Function(TagCardEntity card, TagCardAction action)
  onActionSelected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<TagThemeColors>()!;
    final cardEntry = _AnimatedTodayCardEntry(
      index: index,
      child: TagCardListItem(
        key: PageStorageKey<String>('today_card_item_${card.id}'),
        card: card,
        onOpenDetails: onOpenDetails,
        onActionSelected: onActionSelected,
      ),
    );

    if (card.isProcessingPlaceholder) {
      return cardEntry;
    }

    return Dismissible(
      key: ValueKey('today_card_${card.id}'),
      direction: DismissDirection.endToStart,
      background: const SizedBox.shrink(),
      secondaryBackground: _DeleteCardBackground(colors: colors),
      confirmDismiss: (_) => _deleteCard(context),
      child: cardEntry,
    );
  }

  Future<bool> _deleteCard(BuildContext context) async {
    final deleted = await context.read<TodayCubit>().deleteCard(card.id);
    if (!context.mounted) {
      return deleted;
    }

    if (deleted) {
      showTopSignalBanner(
        context,
        message: 'Deleted "${card.title}".',
        icon: Icons.delete_outline_rounded,
        tone: TopSignalTone.muted,
      );
    } else {
      final messenger = ScaffoldMessenger.of(context);
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Could not delete this card.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    return deleted;
  }
}

class _SnoozeOption {
  const _SnoozeOption({required this.label, required this.until});

  final String label;
  final DateTime until;
}

class _AnimatedTodayCardEntry extends StatefulWidget {
  const _AnimatedTodayCardEntry({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  State<_AnimatedTodayCardEntry> createState() =>
      _AnimatedTodayCardEntryState();
}

class _AnimatedTodayCardEntryState extends State<_AnimatedTodayCardEntry> {
  Timer? _entranceTimer;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _scheduleEntrance();
  }

  @override
  void dispose() {
    _entranceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      offset: _isVisible ? Offset.zero : const Offset(0, 0.08),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        opacity: _isVisible ? 1 : 0,
        child: widget.child,
      ),
    );
  }

  void _scheduleEntrance() {
    final delayIndex = widget.index > 6 ? 6 : widget.index;
    _entranceTimer = Timer(Duration(milliseconds: delayIndex * 45), () {
      if (!mounted) {
        return;
      }

      setState(() {
        _isVisible = true;
      });
    });
  }
}

class _DeleteCardBackground extends StatelessWidget {
  const _DeleteCardBackground({required this.colors});

  final TagThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.urgentSoft,
        borderRadius: BorderRadius.circular(TagRadii.card),
        border: Border.all(color: colors.urgent.withValues(alpha: 0.24)),
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: TagSpacing.s5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.delete_outline_rounded, color: colors.urgentText),
              const SizedBox(width: TagSpacing.s2),
              Text(
                'Delete',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: colors.urgentText,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectionTile extends StatelessWidget {
  const _SelectionTile({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.selectedColor,
    required this.selectedBackground,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final Color selectedColor;
  final Color selectedBackground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<TagThemeColors>()!;

    return Padding(
      padding: const EdgeInsets.only(bottom: TagSpacing.s2),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TagRadii.input),
        ),
        tileColor: isSelected ? selectedBackground : Colors.transparent,
        leading: Icon(
          icon,
          color: isSelected ? selectedColor : colors.textSecondary,
        ),
        title: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: isSelected ? selectedColor : colors.textPrimary,
          ),
        ),
        trailing: isSelected
            ? Icon(Icons.check_rounded, color: selectedColor)
            : null,
      ),
    );
  }
}

class _LocalModelSetupBanner extends StatelessWidget {
  const _LocalModelSetupBanner({this.progress});

  final ModelPreparationProgress? progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = Theme.of(context).extension<TagThemeColors>()!;

    return Semantics(
      container: true,
      label: 'Local model setup is in progress',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surfaceElevated,
          borderRadius: BorderRadius.circular(TagRadii.card),
          border: Border.all(color: colors.borderDefault),
          boxShadow: [
            BoxShadow(
              color: colors.textPrimary.withValues(alpha: 0.06),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(TagSpacing.s4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.brandSoft,
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(TagSpacing.s2),
                      child: Icon(
                        Icons.auto_awesome_rounded,
                        color: colors.brandSoftText,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: TagSpacing.s3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Local models are getting ready',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: TagSpacing.s1),
                        Text(
                          'Keep saving while this finishes. Tag will process '
                          'queued sources on this device as soon as the local '
                          'models are ready.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: TagSpacing.s4),
              _LocalModelSetupProgress(progress: progress, colors: colors),
              const SizedBox(height: TagSpacing.s3),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => context.go(modelSetupPath),
                  icon: const Icon(Icons.memory_rounded, size: 18),
                  label: const Text('Model setup'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocalModelSetupProgress extends StatelessWidget {
  const _LocalModelSetupProgress({required this.colors, this.progress});

  final TagThemeColors colors;
  final ModelPreparationProgress? progress;

  @override
  Widget build(BuildContext context) {
    final rawProgress = progress?.progress;
    final normalizedProgress = rawProgress?.clamp(0, 1).toDouble();
    final percentLabel = normalizedProgress == null
        ? null
        : '${(normalizedProgress * 100).round()}%';
    final statusMessage = progress?.statusMessage ?? 'Starting local setup...';

    return Semantics(
      label: 'Local model setup progress',
      value: percentLabel ?? statusMessage,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  statusMessage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (percentLabel != null) ...[
                const SizedBox(width: TagSpacing.s3),
                Text(
                  percentLabel,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colors.brandSoftText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: TagSpacing.s2),
          ClipRRect(
            borderRadius: BorderRadius.circular(TagRadii.chip),
            child: LinearProgressIndicator(
              value: normalizedProgress,
              minHeight: 8,
              backgroundColor: colors.borderDefault,
              color: colors.brandPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TodaySpeedDialFab extends StatefulWidget {
  const _TodaySpeedDialFab({
    required this.isSavingImage,
    required this.onAskTag,
    required this.onAttachImage,
  });

  final bool isSavingImage;
  final VoidCallback onAskTag;
  final VoidCallback onAttachImage;

  @override
  State<_TodaySpeedDialFab> createState() => _TodaySpeedDialFabState();
}

class _TodaySpeedDialFabState extends State<_TodaySpeedDialFab> {
  static const _animationDuration = Duration(milliseconds: 180);
  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<TagThemeColors>()!;

    return SizedBox(
      width: 128,
      height: 150,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomRight,
        children: [
          _SpeedDialIconAction(
            key: const ValueKey('today_fab_attach_image'),
            visible: _isOpen,
            right: 4,
            bottom: 72,
            colors: colors,
            tooltip: 'Attach image',
            icon: Icons.add_photo_alternate_outlined,
            isBusy: widget.isSavingImage,
            onPressed: widget.isSavingImage
                ? null
                : () => _runAction(widget.onAttachImage),
          ),
          _SpeedDialIconAction(
            key: const ValueKey('today_fab_ask_tag'),
            visible: _isOpen,
            right: 58,
            bottom: 40,
            colors: colors,
            tooltip: 'Ask Tag',
            icon: Icons.auto_awesome_rounded,
            onPressed: () => _runAction(widget.onAskTag),
          ),
          FloatingActionButton(
            key: const ValueKey('today_fab_toggle'),
            heroTag: 'today_speed_dial_toggle',
            onPressed: _toggleOpen,
            tooltip: _isOpen ? 'Close actions' : 'Open actions',
            child: AnimatedSwitcher(
              duration: _animationDuration,
              transitionBuilder: (child, animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Icon(
                _isOpen ? Icons.close_rounded : Icons.add_rounded,
                key: ValueKey(_isOpen),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleOpen() {
    setState(() => _isOpen = !_isOpen);
  }

  void _runAction(VoidCallback action) {
    if (_isOpen) {
      setState(() => _isOpen = false);
    }
    action();
  }
}

class _SpeedDialIconAction extends StatelessWidget {
  const _SpeedDialIconAction({
    required this.visible,
    required this.right,
    required this.bottom,
    required this.colors,
    required this.tooltip,
    required this.icon,
    this.isBusy = false,
    this.onPressed,
    super.key,
  });

  final bool visible;
  final double right;
  final double bottom;
  final TagThemeColors colors;
  final String tooltip;
  final IconData icon;
  final bool isBusy;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: right,
      bottom: bottom,
      child: ExcludeSemantics(
        excluding: !visible,
        child: IgnorePointer(
          ignoring: !visible,
          child: AnimatedOpacity(
            opacity: visible ? 1 : 0,
            duration: _TodaySpeedDialFabState._animationDuration,
            curve: Curves.easeOut,
            child: AnimatedScale(
              scale: visible ? 1 : 0.72,
              duration: _TodaySpeedDialFabState._animationDuration,
              curve: Curves.easeOutBack,
              child: FloatingActionButton.small(
                heroTag: 'today_speed_dial_$tooltip',
                onPressed: onPressed,
                tooltip: tooltip,
                elevation: 2,
                backgroundColor: colors.surfaceElevated,
                foregroundColor: colors.brandSoftText,
                shape: CircleBorder(
                  side: BorderSide(color: colors.borderDefault),
                ),
                child: isBusy
                    ? SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colors.brandSoftText,
                        ),
                      )
                    : Icon(icon, size: 22),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ManualImageDescriptionSheet extends StatefulWidget {
  const _ManualImageDescriptionSheet({required this.pickedImage});

  final PickedImageSource pickedImage;

  @override
  State<_ManualImageDescriptionSheet> createState() =>
      _ManualImageDescriptionSheetState();
}

class _ManualImageDescriptionSheetState
    extends State<_ManualImageDescriptionSheet> {
  static const int _descriptionMaxLength = 280;

  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = Theme.of(context).extension<TagThemeColors>()!;
    final fileName = _displayName(widget.pickedImage);

    return SafeArea(
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
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
                'Add source description',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: TagSpacing.s1),
              Row(
                children: [
                  Icon(
                    Icons.image_outlined,
                    size: 18,
                    color: colors.textSecondary,
                  ),
                  const SizedBox(width: TagSpacing.s2),
                  Expanded(
                    child: Text(
                      fileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: TagSpacing.s4),
              TextField(
                key: const ValueKey('manual_image_description_field'),
                controller: _controller,
                autofocus: true,
                minLines: 3,
                maxLines: 5,
                maxLength: _descriptionMaxLength,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'What should Tag know about this image?',
                  alignLabelWithHint: true,
                ),
                onSubmitted: (_) => _save(),
              ),
              const SizedBox(height: TagSpacing.s3),
              Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(''),
                    child: const Text('Skip'),
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: const Text('Save source'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _displayName(PickedImageSource pickedImage) {
    final displayName = pickedImage.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }

    return 'Selected image';
  }

  void _save() {
    Navigator.of(context).pop(_controller.text.trim());
  }
}

class _ViewSwitchPill extends StatelessWidget {
  const _ViewSwitchPill({
    required this.colors,
    required this.viewMode,
    required this.onTap,
  });

  final TagThemeColors colors;
  final TodayViewMode viewMode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      key: const ValueKey('today_view_switch'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(TagRadii.chip),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.brandSoft,
          borderRadius: BorderRadius.circular(TagRadii.chip),
          border: Border.all(color: colors.borderDefault),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: TagSpacing.s4,
            vertical: TagSpacing.s2,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                viewMode.label,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colors.brandSoftText,
                  fontSize: 24,
                ),
              ),
              const SizedBox(width: TagSpacing.s2),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: colors.brandSoftText,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.colors,
    required this.filter,
    required this.onPressed,
  });

  final TagThemeColors colors;
  final TodayCardFilter filter;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      key: const ValueKey('today_filter_button'),
      onPressed: onPressed,
      icon: const Icon(Icons.tune_rounded, size: 18),
      label: Text(filter == TodayCardFilter.all ? 'Filter' : filter.label),
      style: OutlinedButton.styleFrom(
        foregroundColor: filter == TodayCardFilter.all
            ? colors.textSecondary
            : colors.brandSoftText,
        side: BorderSide(color: colors.borderDefault),
      ),
    );
  }
}

class _ActiveFilterChip extends StatelessWidget {
  const _ActiveFilterChip({required this.filter, required this.onClear});

  final TodayCardFilter filter;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<TagThemeColors>()!;

    return Align(
      alignment: Alignment.centerLeft,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.brandSoft,
          borderRadius: BorderRadius.circular(TagRadii.chip),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: TagSpacing.s2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Filter: ${filter.label}',
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: colors.brandSoftText),
              ),
              TextButton(onPressed: onClear, child: const Text('Clear')),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyTodayCard extends StatelessWidget {
  const _EmptyTodayCard({required this.onTrySavingSomething});

  final VoidCallback onTrySavingSomething;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = Theme.of(context).extension<TagThemeColors>()!;

    return Card(
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
                  Icons.auto_awesome_outlined,
                  color: colors.brandSoftText,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(height: TagSpacing.s4),
            Text(
              'Nothing needs your attention today.',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: TagSpacing.s2),
            Text(
              "Save a screenshot, link, or note to Tag and I'll turn it into a card when it matters.",
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: TagSpacing.s4),
            OutlinedButton.icon(
              onPressed: onTrySavingSomething,
              icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
              label: const Text('Try saving something'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayErrorCard extends StatelessWidget {
  const _TodayErrorCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<TagThemeColors>()!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(TagSpacing.s5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline_rounded, color: colors.snoozedText),
            const SizedBox(width: TagSpacing.s3),
            Expanded(
              child: Text(
                message.isEmpty
                    ? 'Cards could not be loaded from local storage.'
                    : message,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: colors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
