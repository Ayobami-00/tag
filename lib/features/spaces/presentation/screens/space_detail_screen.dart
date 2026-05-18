import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tag/core/DI/di.dart';
import 'package:tag/core/navigation/route_constants.dart';
import 'package:tag/features/cards/domain/entities/card_entities.dart';
import 'package:tag/features/source_ingestion/domain/entities/source_item_entity.dart';
import 'package:tag/features/spaces/domain/entities/space_entities.dart';
import 'package:tag/features/spaces/presentation/logic/space_detail_cubit.dart';
import 'package:tag/utils/index.dart';

class SpaceDetailScreen extends StatelessWidget {
  const SpaceDetailScreen({required this.spaceId, super.key});

  final String spaceId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SpaceDetailCubit>(
      create: (_) => locator<SpaceDetailCubit>()..load(spaceId),
      child: const _SpaceDetailView(),
    );
  }
}

class _SpaceDetailView extends StatelessWidget {
  const _SpaceDetailView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back to Today',
          onPressed: () => _goBack(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Space'),
      ),
      body: SafeArea(
        child: BlocBuilder<SpaceDetailCubit, SpaceDetailState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == SpaceDetailStatus.error ||
                state.status == SpaceDetailStatus.notFound ||
                state.detail == null) {
              return _SpaceDetailMessage(
                icon: Icons.space_dashboard_outlined,
                title: 'Space unavailable',
                message: state.errorMessage.isEmpty
                    ? 'This Space could not be loaded from local storage.'
                    : state.errorMessage,
              );
            }

            return _LoadedSpaceDetail(detail: state.detail!);
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
}

class _LoadedSpaceDetail extends StatelessWidget {
  const _LoadedSpaceDetail({required this.detail});

  final SpaceDetailEntity detail;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        TagSpacing.s5,
        TagSpacing.s4,
        TagSpacing.s5,
        TagSpacing.s8,
      ),
      children: [
        _SpaceHeader(summary: detail.summary),
        const SizedBox(height: TagSpacing.s5),
        _SpaceSection(
          title: 'Active cards',
          icon: Icons.view_agenda_outlined,
          child: _CardsSection(
            cards: detail.activeCards,
            emptyMessage: 'No active cards need attention in this Space.',
          ),
        ),
        const SizedBox(height: TagSpacing.s4),
        _SpaceSection(
          title: 'Upcoming',
          icon: Icons.schedule_rounded,
          child: _CardsSection(
            cards: detail.upcomingCards,
            emptyMessage: 'No upcoming cards are scheduled here.',
          ),
        ),
        const SizedBox(height: TagSpacing.s4),
        _SpaceSection(
          title: 'Sources',
          icon: Icons.source_outlined,
          child: _SourcesSection(sources: detail.sources),
        ),
      ],
    );
  }
}

class _SpaceHeader extends StatelessWidget {
  const _SpaceHeader({required this.summary});

  final SpaceSummaryEntity summary;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<TagThemeColors>()!;
    final theme = Theme.of(context);
    final accent = _signalColor(summary.dominantSignal, colors);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _HeaderChip(
              label: summary.space.type == SpaceType.specific
                  ? 'Specific Space'
                  : 'Fallback Space',
              icon: Icons.space_dashboard_outlined,
              accent: colors.brandSoftText,
              background: colors.brandSoft,
            ),
            const SizedBox(width: TagSpacing.s2),
            _HeaderChip(
              label: 'Local',
              icon: Icons.lock_outline_rounded,
              accent: colors.textSecondary,
              background: colors.surfaceSunken,
            ),
          ],
        ),
        const SizedBox(height: TagSpacing.s4),
        Text(
          summary.space.name,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: colors.textPrimary,
          ),
        ),
        if (summary.space.description?.trim().isNotEmpty == true) ...[
          const SizedBox(height: TagSpacing.s2),
          Text(
            summary.space.description!.trim(),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ],
        const SizedBox(height: TagSpacing.s4),
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surfaceElevated,
            border: Border.all(color: colors.borderDefault),
            borderRadius: BorderRadius.circular(TagRadii.compactCard),
          ),
          child: Padding(
            padding: const EdgeInsets.all(TagSpacing.s4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _summaryLine(summary),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: TagSpacing.s3),
                Row(
                  children: [
                    Icon(Icons.schedule_rounded, color: accent, size: 18),
                    const SizedBox(width: TagSpacing.s2),
                    Expanded(
                      child: Text(
                        _nextLine(summary),
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: accent,
                        ),
                      ),
                    ),
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

class _SpaceSection extends StatelessWidget {
  const _SpaceSection({
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 19, color: colors.textSecondary),
            const SizedBox(width: TagSpacing.s2),
            Text(title, style: Theme.of(context).textTheme.titleSmall),
          ],
        ),
        const SizedBox(height: TagSpacing.s3),
        child,
      ],
    );
  }
}

class _CardsSection extends StatelessWidget {
  const _CardsSection({required this.cards, required this.emptyMessage});

  final List<TagCardEntity> cards;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) {
      return _QuietMessage(message: emptyMessage);
    }

    return Column(
      children: [
        for (var index = 0; index < cards.length; index++) ...[
          if (index > 0) const SizedBox(height: TagSpacing.s3),
          _SpaceCardTile(card: cards[index]),
        ],
      ],
    );
  }
}

class _SpaceCardTile extends StatelessWidget {
  const _SpaceCardTile({required this.card});

  final TagCardEntity card;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<TagThemeColors>()!;
    final theme = Theme.of(context);
    final style = _cardStyle(card, colors);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: BorderRadius.circular(TagRadii.compactCard),
        border: Border.all(color: colors.borderDefault),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(TagRadii.compactCard),
          onTap: () => context.push(cardDetailLocation(card.id)),
          child: Padding(
            padding: const EdgeInsets.all(TagSpacing.s4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 4,
                  height: 60,
                  decoration: BoxDecoration(
                    color: style.accent,
                    borderRadius: BorderRadius.circular(TagRadii.chip),
                  ),
                ),
                const SizedBox(width: TagSpacing.s3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _TypeChip(label: card.cardType.label, style: style),
                      const SizedBox(height: TagSpacing.s2),
                      Text(
                        card.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: TagSpacing.s1),
                      Text(
                        _cardTimeLabel(card),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: TagSpacing.s2),
                Icon(Icons.chevron_right_rounded, color: colors.textTertiary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SourcesSection extends StatelessWidget {
  const _SourcesSection({required this.sources});

  final List<SpaceSourceSummaryEntity> sources;

  @override
  Widget build(BuildContext context) {
    if (sources.isEmpty) {
      return const _QuietMessage(
        message: 'No source evidence is linked to this Space yet.',
      );
    }

    return Column(
      children: [
        for (var index = 0; index < sources.length; index++) ...[
          if (index > 0) const SizedBox(height: TagSpacing.s3),
          _SourceTile(source: sources[index]),
        ],
      ],
    );
  }
}

class _SourceTile extends StatelessWidget {
  const _SourceTile({required this.source});

  final SpaceSourceSummaryEntity source;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<TagThemeColors>()!;
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: BorderRadius.circular(TagRadii.compactCard),
        border: Border.all(color: colors.borderDefault),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(TagRadii.compactCard),
          onTap: () => context.push(sourcePreviewLocation(source.id)),
          child: Padding(
            padding: const EdgeInsets.all(TagSpacing.s4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(_sourceIcon(source.type), color: colors.brandSoftText),
                const SizedBox(width: TagSpacing.s3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        source.displaySummary,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: TagSpacing.s1),
                      Text(
                        _sourceSubtitle(source),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: TagSpacing.s2),
                Icon(Icons.chevron_right_rounded, color: colors.textTertiary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuietMessage extends StatelessWidget {
  const _QuietMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<TagThemeColors>()!;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.backgroundSubtle,
        borderRadius: BorderRadius.circular(TagRadii.compactCard),
        border: Border.all(color: colors.borderDefault),
      ),
      child: Padding(
        padding: const EdgeInsets.all(TagSpacing.s4),
        child: Text(
          message,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
        ),
      ),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  const _HeaderChip({
    required this.label,
    required this.icon,
    required this.accent,
    required this.background,
  });

  final String label;
  final IconData icon;
  final Color accent;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(TagRadii.chip),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: TagSpacing.s3,
          vertical: TagSpacing.s1,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: accent),
            const SizedBox(width: TagSpacing.s1),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: accent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.label, required this.style});

  final String label;
  final _CardStyle style;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: style.soft,
        borderRadius: BorderRadius.circular(TagRadii.chip),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: TagSpacing.s2,
          vertical: TagSpacing.s1,
        ),
        child: Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: style.text,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _SpaceDetailMessage extends StatelessWidget {
  const _SpaceDetailMessage({
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

String _summaryLine(SpaceSummaryEntity summary) {
  final parts = <String>[
    if (summary.activeCardCount > 0)
      '${summary.activeCardCount} active ${_plural(summary.activeCardCount, 'card')}',
    if (summary.sourceCount > 0)
      '${summary.sourceCount} ${_plural(summary.sourceCount, 'source')}',
    if (summary.suggestedPlansCount > 0)
      '${summary.suggestedPlansCount} suggested ${_plural(summary.suggestedPlansCount, 'plan')}',
  ];

  return parts.isEmpty ? 'No source-backed cards yet' : parts.join(' · ');
}

String _nextLine(SpaceSummaryEntity summary) {
  final nextDeadline = summary.nextDeadline;
  if (nextDeadline == null) {
    return summary.suggestedPlansCount > 0
        ? 'Plans suggested from saved sources'
        : 'No next deadline';
  }

  final local = DateTime.fromMillisecondsSinceEpoch(
    nextDeadline,
    isUtc: true,
  ).toLocal();
  return 'Next: ${DateFormat('EEE, MMM d, h:mm a').format(local)}';
}

String _cardTimeLabel(TagCardEntity card) {
  final attention = card.nextAttentionTime;
  if (attention == null) {
    return card.sourceSummary;
  }

  final local = DateTime.fromMillisecondsSinceEpoch(
    attention,
    isUtc: true,
  ).toLocal();
  return DateFormat('EEE, MMM d, h:mm a').format(local);
}

String _sourceSubtitle(SpaceSourceSummaryEntity source) {
  final created = DateFormat('MMM d, h:mm a').format(
    DateTime.fromMillisecondsSinceEpoch(
      source.createdAt,
      isUtc: true,
    ).toLocal(),
  );
  final appSource = source.appSource?.trim();

  if (appSource != null && appSource.isNotEmpty) {
    return '$appSource · ${source.displayTypeLabel} · $created';
  }

  return '${source.displayTypeLabel} · $created';
}

String _plural(int count, String word) => count == 1 ? word : '${word}s';

IconData _sourceIcon(SourceItemType type) {
  return switch (type) {
    SourceItemType.screenshot => Icons.screenshot_monitor_outlined,
    SourceItemType.image => Icons.image_outlined,
    SourceItemType.link => Icons.link_rounded,
    SourceItemType.text => Icons.notes_rounded,
    SourceItemType.chat => Icons.chat_bubble_outline_rounded,
    SourceItemType.savedPost => Icons.bookmark_border_rounded,
    SourceItemType.emailText => Icons.mail_outline_rounded,
    SourceItemType.manual => Icons.edit_note_rounded,
  };
}

Color _signalColor(SpaceDominantSignal signal, TagThemeColors colors) {
  return switch (signal) {
    SpaceDominantSignal.urgent => colors.urgentText,
    SpaceDominantSignal.goal => colors.goalActiveText,
    SpaceDominantSignal.suggestion => colors.suggestionText,
    SpaceDominantSignal.neutral => colors.brandSoftText,
  };
}

_CardStyle _cardStyle(TagCardEntity card, TagThemeColors colors) {
  return switch (card.cardType) {
    TagCardType.urgent => _CardStyle(
      accent: colors.urgent,
      soft: colors.urgentSoft,
      text: colors.urgentText,
    ),
    TagCardType.goal => _CardStyle(
      accent: colors.goalActive,
      soft: colors.goalActiveSoft,
      text: colors.goalActiveText,
    ),
    TagCardType.suggestion => _CardStyle(
      accent: colors.suggestion,
      soft: colors.suggestionSoft,
      text: colors.suggestionText,
    ),
  };
}

class _CardStyle {
  const _CardStyle({
    required this.accent,
    required this.soft,
    required this.text,
  });

  final Color accent;
  final Color soft;
  final Color text;
}
