import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tag/features/cards/domain/entities/card_entities.dart';
import 'package:tag/features/cards/domain/use_cases/card_policy.dart';
import 'package:tag/utils/index.dart';

class TagCardListItem extends StatefulWidget {
  const TagCardListItem({
    required this.card,
    this.onOpenDetails,
    this.onActionSelected,
    super.key,
  });

  final TagCardEntity card;
  final ValueChanged<TagCardEntity>? onOpenDetails;
  final Future<void> Function(TagCardEntity card, TagCardAction action)?
  onActionSelected;

  @override
  State<TagCardListItem> createState() => _TagCardListItemState();
}

class _TagCardListItemState extends State<TagCardListItem> {
  bool _isExpanded = false;

  TagCardEntity get card => widget.card;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<TagThemeColors>()!;
    final theme = Theme.of(context);
    final style = _styleFor(colors);
    final inactive = card.status != TagCardStatus.active;
    final availableActions = _availableActions;
    final metadata = _metadataChips;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: inactive
            ? colors.surfaceCard.withValues(alpha: 0.76)
            : colors.surfaceCard,
        borderRadius: BorderRadius.circular(TagRadii.card),
        border: Border.all(
          color: _isExpanded
              ? style.accent.withValues(alpha: 0.34)
              : colors.borderDefault,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.textPrimary.withValues(
              alpha: inactive ? 0.03 : (_isExpanded ? 0.08 : 0.05),
            ),
            blurRadius: _isExpanded ? 18 : 10,
            offset: Offset(0, _isExpanded ? 10 : 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(TagRadii.card),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              final onOpenDetails = widget.onOpenDetails;
              if (onOpenDetails == null) {
                _toggleExpanded();
                return;
              }

              onOpenDetails(card);
            },
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutCubic,
                    width: _isExpanded ? 6 : 4,
                    color: style.accent,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    TagSpacing.s4,
                    TagSpacing.s4,
                    TagSpacing.s3,
                    TagSpacing.s4,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _TypeIconBubble(
                            icon: _timeIcon(),
                            style: style,
                            isEmphasized:
                                card.cardType == TagCardType.urgent &&
                                card.status == TagCardStatus.active,
                          ),
                          const SizedBox(width: TagSpacing.s3),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _TypeChip(label: _chipLabel(), style: style),
                                const SizedBox(height: TagSpacing.s2),
                                Text(
                                  card.title,
                                  maxLines: _isExpanded ? 2 : 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: colors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: TagSpacing.s2),
                          if (availableActions.isNotEmpty)
                            IconButton(
                              key: ValueKey('tag_card_expand_${card.id}'),
                              onPressed: _toggleExpanded,
                              tooltip: _isExpanded
                                  ? 'Collapse card'
                                  : 'Expand card',
                              icon: AnimatedRotation(
                                turns: _isExpanded ? 0.5 : 0,
                                duration: const Duration(milliseconds: 180),
                                curve: Curves.easeOutCubic,
                                child: Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: colors.textSecondary,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: TagSpacing.s3),
                      Text(
                        card.reason,
                        maxLines: _isExpanded ? 3 : 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: inactive
                              ? colors.textTertiary
                              : colors.textSecondary,
                        ),
                      ),
                      if (metadata.isNotEmpty) ...[
                        const SizedBox(height: TagSpacing.s3),
                        Wrap(
                          spacing: TagSpacing.s2,
                          runSpacing: TagSpacing.s2,
                          children: [
                            for (final chip in metadata)
                              _MetadataPill(chip: chip, style: style),
                          ],
                        ),
                      ],
                      AnimatedSize(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        alignment: Alignment.topCenter,
                        child: _isExpanded && availableActions.isNotEmpty
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: TagSpacing.s4),
                                  Divider(
                                    height: 1,
                                    color: colors.borderDefault,
                                  ),
                                  const SizedBox(height: TagSpacing.s4),
                                  Wrap(
                                    spacing: TagSpacing.s2,
                                    runSpacing: TagSpacing.s2,
                                    children: [
                                      for (final action in availableActions)
                                        _CardActionButton(
                                          key: ValueKey(
                                            'tag_card_action_${card.id}_${action.storageValue}',
                                          ),
                                          action: action,
                                          onPressed: () => widget
                                              .onActionSelected
                                              ?.call(card, action),
                                        ),
                                    ],
                                  ),
                                ],
                              )
                            : const SizedBox(width: double.infinity),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _toggleExpanded() {
    if (_availableActions.isEmpty) {
      return;
    }

    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  List<TagCardAction> get _availableActions {
    return CardPolicy.availableActionsFor(card);
  }

  _CardVisualStyle _styleFor(TagThemeColors colors) {
    if (card.status == TagCardStatus.completed) {
      return _CardVisualStyle(
        accent: colors.completed,
        chipBackground: colors.completedSoft,
        chipText: colors.completedText,
      );
    }
    if (card.status == TagCardStatus.snoozed) {
      return _CardVisualStyle(
        accent: colors.snoozed,
        chipBackground: colors.snoozedSoft,
        chipText: colors.snoozedText,
      );
    }
    if (card.status == TagCardStatus.cancelled ||
        card.status == TagCardStatus.dismissed) {
      return _CardVisualStyle(
        accent: colors.cancelled,
        chipBackground: colors.cancelledSoft,
        chipText: colors.cancelledText,
      );
    }

    return switch (card.cardType) {
      TagCardType.urgent => _CardVisualStyle(
        accent: colors.urgent,
        chipBackground: colors.urgentSoft,
        chipText: colors.urgentText,
      ),
      TagCardType.goal => _CardVisualStyle(
        accent: colors.goalActive,
        chipBackground: colors.goalActiveSoft,
        chipText: colors.goalActiveText,
      ),
      TagCardType.suggestion => _CardVisualStyle(
        accent: colors.suggestion,
        chipBackground: colors.suggestionSoft,
        chipText: colors.suggestionText,
      ),
    };
  }

  String _chipLabel() {
    if (card.status != TagCardStatus.active) {
      return card.status.label.toUpperCase();
    }

    return card.cardType.label.toUpperCase();
  }

  IconData _timeIcon() {
    if (card.status == TagCardStatus.snoozed) {
      return Icons.schedule_rounded;
    }

    return switch (card.cardType) {
      TagCardType.urgent => Icons.alarm_rounded,
      TagCardType.goal => Icons.flag_outlined,
      TagCardType.suggestion => Icons.auto_awesome_rounded,
    };
  }

  List<_CardMetadataChip> get _metadataChips {
    final chips = <_CardMetadataChip>[
      _CardMetadataChip(
        icon: Icons.space_dashboard_outlined,
        label: card.space.name,
      ),
    ];

    final nextAttention = card.nextAttentionTime;
    if (nextAttention != null) {
      chips.add(
        _CardMetadataChip(
          icon: card.status == TagCardStatus.snoozed
              ? Icons.schedule_rounded
              : Icons.event_outlined,
          label: _formatAttentionTime(nextAttention),
        ),
      );
    }

    final source = card.sourceSummary.trim();
    if (source.isNotEmpty) {
      chips.add(_CardMetadataChip(icon: Icons.source_outlined, label: source));
    } else if (card.sourceIds.isNotEmpty) {
      chips.add(
        _CardMetadataChip(
          icon: Icons.source_outlined,
          label:
              '${card.sourceIds.length} source${card.sourceIds.length == 1 ? '' : 's'}',
        ),
      );
    }

    return chips;
  }

  String _formatAttentionTime(int millis) {
    final local = DateTime.fromMillisecondsSinceEpoch(millis).toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final date = DateTime(local.year, local.month, local.day);
    final time = DateFormat('HH:mm').format(local);

    if (date == today) {
      return 'Today $time';
    }
    if (date == tomorrow) {
      return 'Tomorrow $time';
    }

    return DateFormat('MMM d, HH:mm').format(local);
  }
}

class _TypeIconBubble extends StatelessWidget {
  const _TypeIconBubble({
    required this.icon,
    required this.style,
    required this.isEmphasized,
  });

  final IconData icon;
  final _CardVisualStyle style;
  final bool isEmphasized;

  @override
  Widget build(BuildContext context) {
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final bubble = DecoratedBox(
      decoration: BoxDecoration(
        color: style.chipBackground,
        shape: BoxShape.circle,
      ),
      child: SizedBox.square(
        dimension: 42,
        child: Icon(icon, size: 21, color: style.chipText),
      ),
    );

    if (!isEmphasized || disableAnimations) {
      return bubble;
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.92, end: 1),
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: bubble,
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.label, required this.style});

  final String label;
  final _CardVisualStyle style;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: style.chipBackground,
        borderRadius: BorderRadius.circular(TagRadii.chip),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: TagSpacing.s2,
          vertical: TagSpacing.s1,
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: style.chipText,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _CardActionButton extends StatelessWidget {
  const _CardActionButton({required this.action, this.onPressed, super.key});

  final TagCardAction action;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(44, 36),
        padding: const EdgeInsets.symmetric(horizontal: TagSpacing.s3),
      ),
      child: Text(action.label),
    );
  }
}

class _MetadataPill extends StatelessWidget {
  const _MetadataPill({required this.chip, required this.style});

  final _CardMetadataChip chip;
  final _CardVisualStyle style;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<TagThemeColors>()!;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.backgroundSubtle,
        borderRadius: BorderRadius.circular(TagRadii.chip),
        border: Border.all(color: colors.borderDefault),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: TagSpacing.s2,
          vertical: TagSpacing.s1,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(chip.icon, size: 14, color: style.chipText),
            const SizedBox(width: TagSpacing.s1),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 190),
              child: Text(
                chip.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardMetadataChip {
  const _CardMetadataChip({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

class _CardVisualStyle {
  const _CardVisualStyle({
    required this.accent,
    required this.chipBackground,
    required this.chipText,
  });

  final Color accent;
  final Color chipBackground;
  final Color chipText;
}
