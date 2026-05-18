import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:tag/core/DI/di.dart';
import 'package:tag/core/local_storage/file_store/local_file_store.dart';
import 'package:tag/core/navigation/route_constants.dart';
import 'package:tag/features/cards/domain/entities/card_entities.dart';
import 'package:tag/features/source_ingestion/domain/entities/source_item_entity.dart';
import 'package:tag/features/source_ingestion/domain/entities/source_preview_entity.dart';
import 'package:tag/features/source_ingestion/presentation/logic/source_preview_cubit.dart';
import 'package:tag/utils/index.dart';

class SourcePreviewScreen extends StatelessWidget {
  const SourcePreviewScreen({
    required this.sourceId,
    this.focusCardId,
    super.key,
  });

  final String sourceId;
  final String? focusCardId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SourcePreviewCubit>(
      create: (_) =>
          locator<SourcePreviewCubit>()
            ..load(sourceId: sourceId, focusCardId: focusCardId),
      child: const _SourcePreviewView(),
    );
  }
}

class _SourcePreviewView extends StatelessWidget {
  const _SourcePreviewView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => _goBack(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Source'),
      ),
      body: SafeArea(
        child: BlocBuilder<SourcePreviewCubit, SourcePreviewState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == SourcePreviewStatus.error ||
                state.status == SourcePreviewStatus.notFound ||
                state.preview == null) {
              return _PreviewMessage(
                icon: Icons.source_outlined,
                title: 'Source unavailable',
                message: state.errorMessage.isEmpty
                    ? 'This local source could not be loaded.'
                    : state.errorMessage,
              );
            }

            return _LoadedSourcePreview(state: state);
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

class _LoadedSourcePreview extends StatefulWidget {
  const _LoadedSourcePreview({required this.state});

  final SourcePreviewState state;

  @override
  State<_LoadedSourcePreview> createState() => _LoadedSourcePreviewState();
}

class _LoadedSourcePreviewState extends State<_LoadedSourcePreview> {
  @override
  Widget build(BuildContext context) {
    final preview = widget.state.preview!;
    final focusedCard = widget.state.focusedCard;
    final colors = Theme.of(context).extension<TagThemeColors>()!;
    final theme = Theme.of(context);

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
            _SourceTypeChip(source: preview.source),
            const SizedBox(width: TagSpacing.s2),
            _LocalChip(colors: colors),
          ],
        ),
        const SizedBox(height: TagSpacing.s4),
        Text(
          preview.source.displaySummary,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: TagSpacing.s2),
        Text(
          _sourceSubtitle(preview.source),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: TagSpacing.s6),
        _PreviewSection(
          title: _originalSectionTitle(preview.source),
          icon: _sourceIcon(preview.source.type),
          child: _OriginalSourcePreview(source: preview.source),
        ),
        const SizedBox(height: TagSpacing.s4),
        _PreviewSection(
          title: 'Extracted text',
          icon: Icons.text_snippet_outlined,
          child: _EvidenceTextBlock(
            text: _displayText(preview.source.extractedText),
            emptyText: 'No extracted text has been saved for this source yet.',
            accent: _accentFor(focusedCard, colors),
          ),
        ),
        const SizedBox(height: TagSpacing.s4),
        _PreviewSection(
          title: 'Why Tag created this card',
          icon: Icons.fact_check_outlined,
          child: _WhyCardExists(
            focusedCard: focusedCard,
            fallbackEvidence: _displayText(preview.source.extractedText),
          ),
        ),
        const SizedBox(height: TagSpacing.s4),
        _PreviewSection(
          title: _relatedCardsTitle(widget.state),
          icon: Icons.view_agenda_outlined,
          child: _RelatedCardsList(cards: widget.state.visibleRelatedCards),
        ),
        if (focusedCard != null) ...[
          const SizedBox(height: TagSpacing.s4),
          _PreviewSection(
            title: 'Related Space',
            icon: Icons.space_dashboard_outlined,
            child: _RelatedSpaceBlock(
              card: focusedCard,
              onOpenSpace: () => _openSpace(focusedCard.space.id),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _openSpace(String spaceId) async {
    final cubit = context.read<SourcePreviewCubit>();
    await cubit.recordOpenSpace(spaceId);
    if (!mounted) {
      return;
    }

    context.push(spaceDetailLocation(spaceId));
  }
}

class _OriginalSourcePreview extends StatelessWidget {
  const _OriginalSourcePreview({required this.source});

  final SourceItemEntity source;

  @override
  Widget build(BuildContext context) {
    return switch (source.type) {
      SourceItemType.image ||
      SourceItemType.screenshot => _ImageSourcePreview(source: source),
      _ => _TextSourcePreview(source: source),
    };
  }
}

class _ImageSourcePreview extends StatefulWidget {
  const _ImageSourcePreview({required this.source});

  final SourceItemEntity source;

  @override
  State<_ImageSourcePreview> createState() => _ImageSourcePreviewState();
}

class _ImageSourcePreviewState extends State<_ImageSourcePreview> {
  Future<File?>? _repairedFileFuture;
  String? _repairPath;

  @override
  void didUpdateWidget(covariant _ImageSourcePreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.source.localFilePath != widget.source.localFilePath) {
      _repairedFileFuture = null;
      _repairPath = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final path = widget.source.localFilePath?.trim();
    if (path == null || path.isEmpty) {
      return const _RecoverablePreviewError(
        message: 'The original image path was not stored with this source.',
      );
    }

    final file = File(path);
    if (file.existsSync()) {
      return _LocalSourceImage(file: file);
    }

    return FutureBuilder<File?>(
      future: _futureForPath(path),
      builder: (context, snapshot) {
        final repairedFile = snapshot.data;
        if (repairedFile != null) {
          return _LocalSourceImage(file: repairedFile);
        }

        if (snapshot.connectionState != ConnectionState.done) {
          return const _SourcePreviewLoadingFrame();
        }

        return const _RecoverablePreviewError(
          message: 'The original image is missing from local storage.',
        );
      },
    );
  }

  Future<File?> _futureForPath(String path) {
    if (_repairedFileFuture == null || _repairPath != path) {
      _repairPath = path;
      _repairedFileFuture = resolveCurrentDocumentsFileForSourcePreview(path);
    }

    return _repairedFileFuture!;
  }
}

class _LocalSourceImage extends StatelessWidget {
  const _LocalSourceImage({required this.file});

  final File file;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<TagThemeColors>()!;

    return ClipRRect(
      borderRadius: BorderRadius.circular(TagRadii.sourcePreview),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surfaceSunken,
          border: Border.all(color: colors.borderDefault),
          borderRadius: BorderRadius.circular(TagRadii.sourcePreview),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 420),
          child: Image.file(
            file,
            fit: BoxFit.contain,
            width: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              return const _RecoverablePreviewError(
                message: 'The original image could not be rendered.',
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SourcePreviewLoadingFrame extends StatelessWidget {
  const _SourcePreviewLoadingFrame();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<TagThemeColors>()!;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceSunken,
        border: Border.all(color: colors.borderDefault),
        borderRadius: BorderRadius.circular(TagRadii.sourcePreview),
      ),
      child: const SizedBox(
        height: 220,
        width: double.infinity,
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

@visibleForTesting
Future<File?> resolveCurrentDocumentsFileForSourcePreview(
  String storedPath,
) async {
  final marker = '${p.separator}Documents${p.separator}Tag${p.separator}';
  final markerIndex = storedPath.indexOf(marker);
  if (markerIndex < 0) {
    return null;
  }

  final relativePath = storedPath.substring(markerIndex + marker.length);
  if (relativePath.trim().isEmpty) {
    return null;
  }

  final storageStatus = await locator<LocalFileStore>().checkStatus();
  if (!storageStatus.isHealthy || storageStatus.rootPath.isEmpty) {
    return null;
  }

  final candidate = File(
    p.joinAll([storageStatus.rootPath, ...p.split(relativePath)]),
  );

  return candidate.existsSync() ? candidate : null;
}

class _TextSourcePreview extends StatelessWidget {
  const _TextSourcePreview({required this.source});

  final SourceItemEntity source;

  @override
  Widget build(BuildContext context) {
    return _EvidenceTextBlock(
      text: _displayText(source.rawText),
      emptyText: 'No original text has been saved for this source.',
      accent: Theme.of(context).extension<TagThemeColors>()!.brandPrimary,
    );
  }
}

class _WhyCardExists extends StatelessWidget {
  const _WhyCardExists({
    required this.focusedCard,
    required this.fallbackEvidence,
  });

  final SourcePreviewRelatedCardEntity? focusedCard;
  final String? fallbackEvidence;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<TagThemeColors>()!;
    final theme = Theme.of(context);
    final card = focusedCard;

    if (card == null) {
      return Text(
        fallbackEvidence == null
            ? 'No Tag Card is linked to this source yet.'
            : fallbackEvidence!,
        style: theme.textTheme.bodyLarge?.copyWith(color: colors.textSecondary),
      );
    }

    final evidence = card.evidenceText?.trim().isNotEmpty == true
        ? card.evidenceText!.trim()
        : card.evidenceSummary.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          card.reason,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (evidence.isNotEmpty) ...[
          const SizedBox(height: TagSpacing.s3),
          _EvidenceTextBlock(
            text: evidence,
            emptyText: '',
            accent: _accentFor(card, colors),
          ),
        ],
      ],
    );
  }
}

class _RelatedSpaceBlock extends StatelessWidget {
  const _RelatedSpaceBlock({required this.card, required this.onOpenSpace});

  final SourcePreviewRelatedCardEntity card;
  final VoidCallback onOpenSpace;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<TagThemeColors>()!;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          card.space.name,
          style: theme.textTheme.titleSmall?.copyWith(
            color: colors.textPrimary,
          ),
        ),
        if (card.space.description?.trim().isNotEmpty == true) ...[
          const SizedBox(height: TagSpacing.s2),
          Text(
            card.space.description!.trim(),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ],
        const SizedBox(height: TagSpacing.s4),
        OutlinedButton.icon(
          onPressed: onOpenSpace,
          icon: const Icon(Icons.space_dashboard_outlined, size: 18),
          label: const Text('Open Space'),
        ),
      ],
    );
  }
}

class _RelatedCardsList extends StatelessWidget {
  const _RelatedCardsList({required this.cards});

  final List<SourcePreviewRelatedCardEntity> cards;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<TagThemeColors>()!;

    if (cards.isEmpty) {
      return Text(
        'No related cards for this Space yet.',
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(color: colors.textSecondary),
      );
    }

    return Column(
      children: [
        for (var index = 0; index < cards.length; index++) ...[
          if (index > 0) const SizedBox(height: TagSpacing.s3),
          _RelatedCardTile(card: cards[index]),
        ],
      ],
    );
  }
}

class _RelatedCardTile extends StatelessWidget {
  const _RelatedCardTile({required this.card});

  final SourcePreviewRelatedCardEntity card;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<TagThemeColors>()!;
    final theme = Theme.of(context);
    final style = _styleFor(card, colors);

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
          onTap: () => context.push(cardDetailLocation(card.cardId)),
          child: Padding(
            padding: const EdgeInsets.all(TagSpacing.s4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 4,
                  height: 56,
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
                      Wrap(
                        spacing: TagSpacing.s2,
                        runSpacing: TagSpacing.s2,
                        children: [
                          _SmallChip(
                            label: _cardLabel(card),
                            foreground: style.chipText,
                            background: style.chipBackground,
                          ),
                          _SmallChip(
                            label: card.space.name,
                            foreground: colors.brandSoftText,
                            background: colors.brandSoft,
                          ),
                        ],
                      ),
                      const SizedBox(height: TagSpacing.s3),
                      Text(
                        card.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: TagSpacing.s2),
                      Text(
                        _relatedCardSubtitle(card),
                        maxLines: 2,
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

class _PreviewSection extends StatelessWidget {
  const _PreviewSection({
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
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
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

class _EvidenceTextBlock extends StatelessWidget {
  const _EvidenceTextBlock({
    required this.text,
    required this.emptyText,
    required this.accent,
  });

  final String? text;
  final String emptyText;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<TagThemeColors>()!;
    final content = text?.trim();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.brandSoft.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(TagRadii.sourcePreview),
        border: Border.all(color: colors.borderDefault),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(TagRadii.sourcePreview),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(TagSpacing.s3),
                child: Text(
                  content == null || content.isEmpty ? emptyText : content,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: content == null || content.isEmpty
                        ? colors.textTertiary
                        : colors.textPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecoverablePreviewError extends StatelessWidget {
  const _RecoverablePreviewError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<TagThemeColors>()!;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceSunken,
        borderRadius: BorderRadius.circular(TagRadii.sourcePreview),
        border: Border.all(color: colors.borderDefault),
      ),
      child: Padding(
        padding: const EdgeInsets.all(TagSpacing.s4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.image_not_supported_outlined, color: colors.snoozedText),
            const SizedBox(width: TagSpacing.s3),
            Expanded(
              child: Text(
                message,
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

class _SourceTypeChip extends StatelessWidget {
  const _SourceTypeChip({required this.source});

  final SourceItemEntity source;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<TagThemeColors>()!;

    return _SmallChip(
      label: source.displayTypeLabel,
      foreground: colors.textSecondary,
      background: colors.surfaceSunken,
      icon: _sourceIcon(source.type),
    );
  }
}

class _LocalChip extends StatelessWidget {
  const _LocalChip({required this.colors});

  final TagThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return _SmallChip(
      label: 'Local',
      foreground: colors.brandSoftText,
      background: colors.brandSoft,
      icon: Icons.lock_outline_rounded,
    );
  }
}

class _SmallChip extends StatelessWidget {
  const _SmallChip({
    required this.label,
    required this.foreground,
    required this.background,
    this.icon,
  });

  final String label;
  final Color foreground;
  final Color background;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(TagRadii.chip),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          icon == null ? TagSpacing.s3 : TagSpacing.s2,
          TagSpacing.s1,
          TagSpacing.s3,
          TagSpacing.s1,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: foreground),
              const SizedBox(width: TagSpacing.s1),
            ],
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewMessage extends StatelessWidget {
  const _PreviewMessage({
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

String _sourceSubtitle(SourceItemEntity source) {
  final appSource = source.appSource?.trim();
  final contentType = source.contentType.trim();
  final created = DateFormat('MMM d, h:mm a').format(
    DateTime.fromMillisecondsSinceEpoch(
      source.createdAt,
      isUtc: true,
    ).toLocal(),
  );

  if (appSource != null && appSource.isNotEmpty) {
    return '$appSource · $contentType · $created';
  }

  return '$contentType · $created';
}

String _originalSectionTitle(SourceItemEntity source) {
  return switch (source.type) {
    SourceItemType.image || SourceItemType.screenshot => 'Original image',
    _ => 'Original text',
  };
}

String _relatedCardsTitle(SourcePreviewState state) {
  final spaceId = state.focusedSpaceId;
  if (spaceId == null || spaceId.isEmpty) {
    return 'Related cards';
  }

  final focusedCard = state.focusedCard;
  final spaceName = focusedCard?.space.id == spaceId
      ? focusedCard!.space.name
      : 'Space';

  return 'Related cards · $spaceName';
}

String? _displayText(String? text) {
  final trimmed = text?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }

  return trimmed;
}

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

Color _accentFor(SourcePreviewRelatedCardEntity? card, TagThemeColors colors) {
  if (card == null) {
    return colors.brandPrimary;
  }

  return _styleFor(card, colors).accent;
}

_RelatedCardStyle _styleFor(
  SourcePreviewRelatedCardEntity card,
  TagThemeColors colors,
) {
  if (card.status == TagCardStatus.completed) {
    return _RelatedCardStyle(
      accent: colors.completed,
      chipBackground: colors.completedSoft,
      chipText: colors.completedText,
    );
  }
  if (card.status == TagCardStatus.snoozed) {
    return _RelatedCardStyle(
      accent: colors.snoozed,
      chipBackground: colors.snoozedSoft,
      chipText: colors.snoozedText,
    );
  }
  if (card.status == TagCardStatus.cancelled ||
      card.status == TagCardStatus.dismissed ||
      card.status == TagCardStatus.archived) {
    return _RelatedCardStyle(
      accent: colors.cancelled,
      chipBackground: colors.cancelledSoft,
      chipText: colors.cancelledText,
    );
  }

  return switch (card.cardType) {
    TagCardType.urgent => _RelatedCardStyle(
      accent: colors.urgent,
      chipBackground: colors.urgentSoft,
      chipText: colors.urgentText,
    ),
    TagCardType.goal => _RelatedCardStyle(
      accent: colors.goalActive,
      chipBackground: colors.goalActiveSoft,
      chipText: colors.goalActiveText,
    ),
    TagCardType.suggestion => _RelatedCardStyle(
      accent: colors.suggestion,
      chipBackground: colors.suggestionSoft,
      chipText: colors.suggestionText,
    ),
  };
}

String _cardLabel(SourcePreviewRelatedCardEntity card) {
  if (card.status != TagCardStatus.active) {
    return card.status.label.toUpperCase();
  }

  return card.cardType.label.toUpperCase();
}

String _relatedCardSubtitle(SourcePreviewRelatedCardEntity card) {
  final time = card.nextActiveDeadline == null
      ? null
      : DateFormat('MMM d, h:mm a').format(
          DateTime.fromMillisecondsSinceEpoch(
            card.nextActiveDeadline!,
            isUtc: true,
          ).toLocal(),
        );
  final relation = card.role == 'primary' ? 'Primary source' : card.role;

  if (time == null) {
    return '$relation · ${card.reason}';
  }

  return '$relation · $time · ${card.reason}';
}

class _RelatedCardStyle {
  const _RelatedCardStyle({
    required this.accent,
    required this.chipBackground,
    required this.chipText,
  });

  final Color accent;
  final Color chipBackground;
  final Color chipText;
}
