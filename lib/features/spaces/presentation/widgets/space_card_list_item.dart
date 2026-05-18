import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tag/features/spaces/domain/entities/space_entities.dart';
import 'package:tag/utils/index.dart';

class SpaceCardListItem extends StatelessWidget {
  const SpaceCardListItem({
    required this.summary,
    required this.onTap,
    super.key,
  });

  final SpaceSummaryEntity summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<TagThemeColors>()!;
    final theme = Theme.of(context);
    final style = _SpaceCardStyle.forSummary(summary, colors);

    return Card(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(TagRadii.card),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(TagSpacing.s4),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 4,
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
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                summary.space.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: colors.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(width: TagSpacing.s2),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: colors.textTertiary,
                            ),
                          ],
                        ),
                        const SizedBox(height: TagSpacing.s2),
                        Text(
                          _summaryLine(summary),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: TagSpacing.s3),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              summary.nextDeadline == null
                                  ? Icons.auto_awesome_outlined
                                  : Icons.schedule_rounded,
                              size: 17,
                              color: style.accent,
                            ),
                            const SizedBox(width: TagSpacing.s2),
                            Expanded(
                              child: Text(
                                _nextLine(summary),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: style.text,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_chips(summary).isNotEmpty) ...[
                          const SizedBox(height: TagSpacing.s3),
                          Wrap(
                            spacing: TagSpacing.s2,
                            runSpacing: TagSpacing.s2,
                            children: [
                              for (final chip in _chips(summary))
                                _MiniSignalChip(chip: chip),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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

    if (parts.isEmpty) {
      return 'Space is waiting for source-backed cards.';
    }

    return parts.join(' · ');
  }

  String _nextLine(SpaceSummaryEntity summary) {
    final nextDeadline = summary.nextDeadline;
    if (nextDeadline != null) {
      final local = DateTime.fromMillisecondsSinceEpoch(
        nextDeadline,
        isUtc: true,
      ).toLocal();
      return 'Next: ${DateFormat('EEE, MMM d, h:mm a').format(local)}';
    }

    if (summary.suggestedPlansCount > 0) {
      return 'Suggested plans from saved sources';
    }

    return 'No deadline competing for Today';
  }

  List<_MiniSignalChipData> _chips(SpaceSummaryEntity summary) {
    return [
      if (summary.urgentCount > 0)
        _MiniSignalChipData(
          label: '${summary.urgentCount} urgent',
          signal: SpaceDominantSignal.urgent,
        ),
      if (summary.goalCount > 0)
        _MiniSignalChipData(
          label: '${summary.goalCount} goal',
          signal: SpaceDominantSignal.goal,
        ),
      if (summary.suggestionCount > 0)
        _MiniSignalChipData(
          label: '${summary.suggestionCount} suggestion',
          signal: SpaceDominantSignal.suggestion,
        ),
    ];
  }

  String _plural(int count, String word) => count == 1 ? word : '${word}s';
}

class _MiniSignalChip extends StatelessWidget {
  const _MiniSignalChip({required this.chip});

  final _MiniSignalChipData chip;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<TagThemeColors>()!;
    final style = _SpaceCardStyle.forSignal(chip.signal, colors);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: style.soft,
        borderRadius: BorderRadius.circular(TagRadii.chip),
        border: Border.all(color: style.accent.withValues(alpha: 0.28)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: TagSpacing.s3,
          vertical: TagSpacing.s1,
        ),
        child: Text(
          chip.label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: style.text,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _MiniSignalChipData {
  const _MiniSignalChipData({required this.label, required this.signal});

  final String label;
  final SpaceDominantSignal signal;
}

class _SpaceCardStyle {
  const _SpaceCardStyle({
    required this.accent,
    required this.soft,
    required this.text,
  });

  final Color accent;
  final Color soft;
  final Color text;

  factory _SpaceCardStyle.forSummary(
    SpaceSummaryEntity summary,
    TagThemeColors colors,
  ) {
    return _SpaceCardStyle.forSignal(summary.dominantSignal, colors);
  }

  factory _SpaceCardStyle.forSignal(
    SpaceDominantSignal signal,
    TagThemeColors colors,
  ) {
    return switch (signal) {
      SpaceDominantSignal.urgent => _SpaceCardStyle(
        accent: colors.urgent,
        soft: colors.urgentSoft,
        text: colors.urgentText,
      ),
      SpaceDominantSignal.goal => _SpaceCardStyle(
        accent: colors.goalActive,
        soft: colors.goalActiveSoft,
        text: colors.goalActiveText,
      ),
      SpaceDominantSignal.suggestion => _SpaceCardStyle(
        accent: colors.suggestion,
        soft: colors.suggestionSoft,
        text: colors.suggestionText,
      ),
      SpaceDominantSignal.neutral => _SpaceCardStyle(
        accent: colors.brandPrimary,
        soft: colors.brandSoft,
        text: colors.brandSoftText,
      ),
    };
  }
}
