import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tag/core/DI/di.dart';
import 'package:tag/features/ai_processing/domain/entities/ai_processing_job_entity.dart';
import 'package:tag/features/ai_processing/presentation/logic/ai_job_queue_cubit.dart';
import 'package:tag/utils/index.dart';

class AiJobQueueDebugScreen extends StatelessWidget {
  const AiJobQueueDebugScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AiJobQueueCubit>(
      create: (_) => locator<AiJobQueueCubit>()..load(),
      child: const _AiJobQueueDebugView(),
    );
  }
}

class _AiJobQueueDebugView extends StatelessWidget {
  const _AiJobQueueDebugView();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<TagThemeColors>()!;

    return BlocListener<AiJobQueueCubit, AiJobQueueState>(
      listenWhen: (previous, current) =>
          previous.actionMessage != current.actionMessage ||
          previous.errorMessage != current.errorMessage,
      listener: (context, state) {
        final message = state.actionMessage.isNotEmpty
            ? state.actionMessage
            : state.errorMessage;
        if (message.isEmpty) {
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
        );
        context.read<AiJobQueueCubit>().clearMessages();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('AI Queue')),
        body: SafeArea(
          child: BlocBuilder<AiJobQueueCubit, AiJobQueueState>(
            builder: (context, state) {
              return ListView(
                padding: const EdgeInsets.fromLTRB(
                  TagSpacing.s4,
                  TagSpacing.s3,
                  TagSpacing.s4,
                  TagSpacing.s6,
                ),
                children: [
                  _DebugHeader(colors: colors),
                  const SizedBox(height: TagSpacing.s4),
                  FilledButton.icon(
                    onPressed: () =>
                        context.read<AiJobQueueCubit>().queueDebugFailure(),
                    icon: const Icon(Icons.bug_report_outlined, size: 18),
                    label: const Text('Queue debug failure'),
                  ),
                  const SizedBox(height: TagSpacing.s5),
                  if (state.status == AiJobQueueViewStatus.loading)
                    const Center(child: CircularProgressIndicator())
                  else if (state.jobs.isEmpty)
                    _EmptyQueueCard(colors: colors)
                  else
                    for (final job in state.jobs) ...[
                      _AiJobRow(colors: colors, job: job),
                      const SizedBox(height: TagSpacing.s3),
                    ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DebugHeader extends StatelessWidget {
  const _DebugHeader({required this.colors});

  final TagThemeColors colors;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.backgroundSubtle,
        borderRadius: BorderRadius.circular(TagRadii.compactCard),
        border: Border.all(color: colors.borderDefault),
      ),
      child: Padding(
        padding: const EdgeInsets.all(TagSpacing.s4),
        child: Row(
          children: [
            Icon(Icons.memory_rounded, color: colors.brandSoftText),
            const SizedBox(width: TagSpacing.s3),
            Expanded(
              child: Text(
                'Local queue runner uses Cactus/Gemma 4 for source extraction and intention detection.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyQueueCard extends StatelessWidget {
  const _EmptyQueueCard({required this.colors});

  final TagThemeColors colors;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(TagSpacing.s5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.check_circle_outline_rounded, color: colors.completed),
            const SizedBox(height: TagSpacing.s3),
            Text('No AI jobs yet.', style: theme.textTheme.titleSmall),
            const SizedBox(height: TagSpacing.s2),
            Text(
              'Saving a text or image source will queue an extract_source job.',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _AiJobRow extends StatelessWidget {
  const _AiJobRow({required this.colors, required this.job});

  final TagThemeColors colors;
  final AiProcessingJobEntity job;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final updatedAt = DateFormat(
      'MMM d, h:mm:ss a',
    ).format(DateTime.fromMillisecondsSinceEpoch(job.updatedAt).toLocal());

    return Card(
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: _accentColor(),
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
                            job.jobType.displayLabel,
                            style: theme.textTheme.titleSmall,
                          ),
                        ),
                        const SizedBox(width: TagSpacing.s2),
                        _StatusChip(colors: colors, job: job),
                      ],
                    ),
                    const SizedBox(height: TagSpacing.s2),
                    Text(
                      _detailLine(updatedAt),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    if (job.errorMessage?.isNotEmpty == true) ...[
                      const SizedBox(height: TagSpacing.s2),
                      Text(
                        job.errorMessage!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.urgentText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    const SizedBox(height: TagSpacing.s3),
                    Wrap(
                      spacing: TagSpacing.s2,
                      runSpacing: TagSpacing.s2,
                      children: [
                        if (job.canRetry)
                          OutlinedButton.icon(
                            onPressed: () => context
                                .read<AiJobQueueCubit>()
                                .retryJob(job.id),
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: const Text('Retry'),
                          ),
                        if (job.canCancel)
                          TextButton.icon(
                            onPressed: () => context
                                .read<AiJobQueueCubit>()
                                .cancelJob(job.id),
                            icon: const Icon(Icons.close_rounded, size: 18),
                            label: const Text('Cancel'),
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

  String _detailLine(String updatedAt) {
    final sourceLabel = job.sourceId == null ? 'debug' : job.sourceId!;

    return 'Source $sourceLabel - attempt ${job.attemptCount}/${job.maxAttempts} - updated $updatedAt';
  }

  Color _accentColor() {
    return switch (job.status) {
      AiJobStatus.queued => colors.brandPrimary,
      AiJobStatus.running => colors.goalActive,
      AiJobStatus.awaitingConfirmation => colors.suggestion,
      AiJobStatus.completed => colors.completed,
      AiJobStatus.failed => colors.urgent,
      AiJobStatus.cancelled => colors.cancelled,
    };
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.colors, required this.job});

  final TagThemeColors colors;
  final AiProcessingJobEntity job;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final icon = switch (job.status) {
      AiJobStatus.queued => Icons.schedule_rounded,
      AiJobStatus.running => Icons.sync_rounded,
      AiJobStatus.awaitingConfirmation => Icons.fact_check_outlined,
      AiJobStatus.completed => Icons.check_circle_outline_rounded,
      AiJobStatus.failed => Icons.error_outline_rounded,
      AiJobStatus.cancelled => Icons.block_rounded,
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: _softColor(),
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
            Icon(icon, size: 14, color: _textColor()),
            const SizedBox(width: TagSpacing.s1),
            Text(
              job.status.displayLabel.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(color: _textColor()),
            ),
          ],
        ),
      ),
    );
  }

  Color _softColor() {
    return switch (job.status) {
      AiJobStatus.queued => colors.brandSoft,
      AiJobStatus.running => colors.goalActiveSoft,
      AiJobStatus.awaitingConfirmation => colors.suggestionSoft,
      AiJobStatus.completed => colors.completedSoft,
      AiJobStatus.failed => colors.urgentSoft,
      AiJobStatus.cancelled => colors.cancelledSoft,
    };
  }

  Color _textColor() {
    return switch (job.status) {
      AiJobStatus.queued => colors.brandSoftText,
      AiJobStatus.running => colors.goalActiveText,
      AiJobStatus.awaitingConfirmation => colors.suggestionText,
      AiJobStatus.completed => colors.completedText,
      AiJobStatus.failed => colors.urgentText,
      AiJobStatus.cancelled => colors.cancelledText,
    };
  }
}
