import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tag/core/DI/di.dart';
import 'package:tag/core/ai/rag/rag_models.dart';
import 'package:tag/features/rag/presentation/logic/rag_debug_cubit.dart';
import 'package:tag/features/rag/presentation/logic/rag_debug_state.dart';
import 'package:tag/utils/index.dart';

class RagDebugSearchScreen extends StatelessWidget {
  const RagDebugSearchScreen({super.key, this.initialQuery = ''});

  final String initialQuery;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RagDebugCubit>(
      create: (_) => locator<RagDebugCubit>()..load(initialQuery: initialQuery),
      child: _RagDebugSearchView(initialQuery: initialQuery),
    );
  }
}

class _RagDebugSearchView extends StatefulWidget {
  const _RagDebugSearchView({required this.initialQuery});

  final String initialQuery;

  @override
  State<_RagDebugSearchView> createState() => _RagDebugSearchViewState();
}

class _RagDebugSearchViewState extends State<_RagDebugSearchView> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<TagThemeColors>()!;

    return Scaffold(
      appBar: AppBar(title: const Text('RAG search')),
      body: SafeArea(
        child: BlocBuilder<RagDebugCubit, RagDebugState>(
          builder: (context, state) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(
                TagSpacing.s4,
                TagSpacing.s3,
                TagSpacing.s4,
                TagSpacing.s6,
              ),
              children: [
                _IndexStatusCard(colors: colors, status: state.indexStatus),
                const SizedBox(height: TagSpacing.s4),
                _SearchField(
                  controller: _controller,
                  isBusy: state.isBusy,
                  onSubmitted: (query) =>
                      context.read<RagDebugCubit>().search(query),
                ),
                if (state.errorMessage.isNotEmpty) ...[
                  const SizedBox(height: TagSpacing.s3),
                  _ErrorCard(colors: colors, message: state.errorMessage),
                ],
                const SizedBox(height: TagSpacing.s5),
                if (state.status == RagDebugStatus.loading)
                  const Center(child: CircularProgressIndicator())
                else if (state.results.isEmpty)
                  _EmptyRagCard(colors: colors, hasRows: _hasRows(state))
                else
                  for (final result in state.results) ...[
                    _RagResultCard(colors: colors, result: result),
                    const SizedBox(height: TagSpacing.s3),
                  ],
              ],
            );
          },
        ),
      ),
    );
  }

  bool _hasRows(RagDebugState state) {
    return state.indexStatus?.hasRows ?? false;
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.isBusy,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final bool isBusy;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            enabled: !isBusy,
            textInputAction: TextInputAction.search,
            onSubmitted: onSubmitted,
            decoration: const InputDecoration(
              hintText: 'Search saved sources',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
        ),
        const SizedBox(width: TagSpacing.s2),
        IconButton.filled(
          onPressed: isBusy ? null : () => onSubmitted(controller.text),
          tooltip: 'Search',
          icon: isBusy
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.arrow_forward_rounded),
        ),
      ],
    );
  }
}

class _IndexStatusCard extends StatelessWidget {
  const _IndexStatusCard({required this.colors, required this.status});

  final TagThemeColors colors;
  final LocalRagIndexStatus? status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final indexStatus = status;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.backgroundSubtle,
        borderRadius: BorderRadius.circular(TagRadii.compactCard),
        border: Border.all(color: colors.borderDefault),
      ),
      child: Padding(
        padding: const EdgeInsets.all(TagSpacing.s4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.hub_outlined, color: colors.brandSoftText),
                const SizedBox(width: TagSpacing.s2),
                Expanded(
                  child: Text('Local index', style: theme.textTheme.titleSmall),
                ),
              ],
            ),
            const SizedBox(height: TagSpacing.s3),
            Wrap(
              spacing: TagSpacing.s2,
              runSpacing: TagSpacing.s2,
              children: [
                _StatusChip(
                  colors: colors,
                  label: 'Chunks ${indexStatus?.chunkCount ?? 0}',
                  icon: Icons.notes_rounded,
                ),
                _StatusChip(
                  colors: colors,
                  label: 'Records ${indexStatus?.recordCount ?? 0}',
                  icon: Icons.storage_rounded,
                ),
                _StatusChip(
                  colors: colors,
                  label: 'Stale ${indexStatus?.staleRecordCount ?? 0}',
                  icon: Icons.sync_problem_rounded,
                  isWarning: (indexStatus?.staleRecordCount ?? 0) > 0,
                ),
              ],
            ),
            if (indexStatus != null) ...[
              const SizedBox(height: TagSpacing.s3),
              Text(
                '${indexStatus.embeddingModelSlug} - ${indexStatus.embeddingDimension}d',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.colors,
    required this.label,
    required this.icon,
    this.isWarning = false,
  });

  final TagThemeColors colors;
  final String label;
  final IconData icon;
  final bool isWarning;

  @override
  Widget build(BuildContext context) {
    final textColor = isWarning ? colors.snoozedText : colors.brandSoftText;
    final background = isWarning ? colors.snoozedSoft : colors.brandSoft;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
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
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: TagSpacing.s1),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}

class _RagResultCard extends StatelessWidget {
  const _RagResultCard({required this.colors, required this.result});

  final TagThemeColors colors;
  final LocalRagSearchResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final relatedCard = result.relatedCards.isEmpty
        ? null
        : result.relatedCards.first;

    return Card(
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: relatedCard?.isActive == true
                    ? colors.goalActive
                    : colors.brandPrimary,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(TagRadii.card),
                ),
              ),
              child: const SizedBox(width: 4),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(TagSpacing.s4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            relatedCard?.title ?? result.source.displaySummary,
                            style: theme.textTheme.titleSmall,
                          ),
                        ),
                        const SizedBox(width: TagSpacing.s2),
                        Text(
                          '#${result.rank}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: TagSpacing.s2),
                    Text(
                      result.chunk.preview,
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: TagSpacing.s3),
                    Wrap(
                      spacing: TagSpacing.s2,
                      runSpacing: TagSpacing.s2,
                      children: [
                        _MiniMeta(
                          colors: colors,
                          icon: Icons.source_outlined,
                          label: result.source.displaySummary,
                        ),
                        if (relatedCard != null)
                          _MiniMeta(
                            colors: colors,
                            icon: Icons.dashboard_customize_outlined,
                            label: relatedCard.spaceName,
                          ),
                        _MiniMeta(
                          colors: colors,
                          icon: Icons.percent_rounded,
                          label: result.score.toStringAsFixed(3),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniMeta extends StatelessWidget {
  const _MiniMeta({
    required this.colors,
    required this.icon,
    required this.label,
  });

  final TagThemeColors colors;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: colors.textTertiary),
        const SizedBox(width: TagSpacing.s1),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 220),
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: colors.textTertiary),
          ),
        ),
      ],
    );
  }
}

class _EmptyRagCard extends StatelessWidget {
  const _EmptyRagCard({required this.colors, required this.hasRows});

  final TagThemeColors colors;
  final bool hasRows;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(TagSpacing.s5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              hasRows
                  ? Icons.manage_search_outlined
                  : Icons.inventory_2_outlined,
              color: colors.brandSoftText,
            ),
            const SizedBox(height: TagSpacing.s3),
            Text(
              hasRows ? 'No matching saved source.' : 'No local chunks yet.',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.colors, required this.message});

  final TagThemeColors colors;
  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.urgentSoft,
        borderRadius: BorderRadius.circular(TagRadii.compactCard),
        border: Border.all(color: colors.borderDefault),
      ),
      child: Padding(
        padding: const EdgeInsets.all(TagSpacing.s3),
        child: Row(
          children: [
            Icon(Icons.error_outline_rounded, color: colors.urgentText),
            const SizedBox(width: TagSpacing.s2),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.urgentText,
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
