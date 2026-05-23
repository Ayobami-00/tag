import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tag/core/DI/di.dart';
import 'package:tag/core/config/app_config.dart';
import 'package:tag/features/beta_feedback/domain/entities/beta_feedback_entities.dart';
import 'package:tag/features/beta_feedback/presentation/logic/beta_feedback_cubit.dart';
import 'package:tag/features/beta_feedback/presentation/logic/beta_feedback_state.dart';
import 'package:tag/utils/index.dart';

class BetaFeedbackScreen extends StatelessWidget {
  const BetaFeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => locator<BetaFeedbackCubit>(),
      child: const _BetaFeedbackView(),
    );
  }
}

class _BetaFeedbackView extends StatefulWidget {
  const _BetaFeedbackView();

  @override
  State<_BetaFeedbackView> createState() => _BetaFeedbackViewState();
}

class _BetaFeedbackViewState extends State<_BetaFeedbackView> {
  final _formKey = GlobalKey<FormState>();
  final _summaryController = TextEditingController();
  final _happenedController = TextEditingController();
  final _expectedController = TextEditingController();
  final _stepsController = TextEditingController();
  final _contactController = TextEditingController();

  @override
  void dispose() {
    _summaryController.dispose();
    _happenedController.dispose();
    _expectedController.dispose();
    _stepsController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<TagThemeColors>()!;
    final theme = Theme.of(context);
    final appConfig = locator<AppConfig>();
    final isAvailable = appConfig.betaFeedbackEnabled || kDebugMode;

    return BlocConsumer<BetaFeedbackCubit, BetaFeedbackState>(
      listenWhen: (previous, current) =>
          previous.status != current.status &&
          current.status == BetaFeedbackSubmissionStatus.success,
      listener: (context, state) {
        FocusScope.of(context).unfocus();
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Beta feedback')),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                TagSpacing.s4,
                TagSpacing.s3,
                TagSpacing.s4,
                TagSpacing.s8,
              ),
              children: [
                _IntroPanel(
                  isConfigured: appConfig.betaFeedbackConfigured,
                  isAvailable: isAvailable,
                ),
                const SizedBox(height: TagSpacing.s4),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<BetaFeedbackArea>(
                        initialValue: state.area,
                        decoration: const InputDecoration(labelText: 'Area'),
                        items: [
                          for (final area in BetaFeedbackArea.values)
                            DropdownMenuItem(
                              value: area,
                              child: Text(area.label),
                            ),
                        ],
                        onChanged: state.isSubmitting
                            ? null
                            : (area) {
                                if (area != null) {
                                  context.read<BetaFeedbackCubit>().areaChanged(
                                    area,
                                  );
                                }
                              },
                      ),
                      const SizedBox(height: TagSpacing.s3),
                      _FeedbackField(
                        controller: _summaryController,
                        label: 'Summary',
                        hint: 'Source preview stays blank after import',
                        maxLines: 1,
                      ),
                      const SizedBox(height: TagSpacing.s3),
                      _FeedbackField(
                        controller: _happenedController,
                        label: 'What happened?',
                        hint: 'Describe what Tag did.',
                      ),
                      const SizedBox(height: TagSpacing.s3),
                      _FeedbackField(
                        controller: _expectedController,
                        label: 'What did you expect?',
                        hint: 'Describe the outcome you expected.',
                      ),
                      const SizedBox(height: TagSpacing.s3),
                      _FeedbackField(
                        controller: _stepsController,
                        label: 'Steps to reproduce',
                        hint:
                            '1. Open Tag\n2. Import a redacted screenshot\n3. Open the card',
                      ),
                      const SizedBox(height: TagSpacing.s3),
                      _FeedbackField(
                        controller: _contactController,
                        label: 'Contact email (optional)',
                        hint: 'Only if the team can follow up privately',
                        maxLines: 1,
                        isRequired: false,
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: TagSpacing.s4),
                _AttachmentPanel(state: state),
                const SizedBox(height: TagSpacing.s3),
                _DiagnosticsTile(
                  value: state.includeDiagnostics,
                  onChanged: state.isSubmitting
                      ? null
                      : context
                            .read<BetaFeedbackCubit>()
                            .includeDiagnosticsChanged,
                ),
                const SizedBox(height: TagSpacing.s3),
                _ConsentTile(
                  value: state.consentPrivateReview,
                  onChanged: state.isSubmitting
                      ? null
                      : context.read<BetaFeedbackCubit>().consentChanged,
                ),
                if (state.status == BetaFeedbackSubmissionStatus.failure &&
                    state.errorMessage != null) ...[
                  const SizedBox(height: TagSpacing.s3),
                  _ErrorPanel(message: state.errorMessage!),
                ],
                if (state.status == BetaFeedbackSubmissionStatus.success &&
                    state.result != null) ...[
                  const SizedBox(height: TagSpacing.s3),
                  _SuccessPanel(result: state.result!),
                ],
                const SizedBox(height: TagSpacing.s5),
                FilledButton.icon(
                  onPressed:
                      !isAvailable ||
                          state.isSubmitting ||
                          !state.consentPrivateReview
                      ? null
                      : () => _submit(context),
                  icon: state.isSubmitting
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send_rounded),
                  label: Text(
                    state.isSubmitting ? 'Sending privately...' : 'Send report',
                  ),
                ),
                const SizedBox(height: TagSpacing.s2),
                Text(
                  'Reports go to the Tag team for private beta review. Screenshots and diagnostics stay in private beta storage.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _submit(BuildContext context) {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    context.read<BetaFeedbackCubit>().submit(
      summary: _summaryController.text,
      happened: _happenedController.text,
      expected: _expectedController.text,
      steps: _stepsController.text,
      contactEmail: _contactController.text,
    );
  }
}

class _IntroPanel extends StatelessWidget {
  const _IntroPanel({required this.isConfigured, required this.isAvailable});

  final bool isConfigured;
  final bool isAvailable;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<TagThemeColors>()!;
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(TagSpacing.s4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.lock_outline_rounded, color: colors.brandPrimary),
            const SizedBox(width: TagSpacing.s3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Private beta report',
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: TagSpacing.s2),
                  Text(
                    'Tell the Tag team what broke. Private screenshots and diagnostics are only used for beta review.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  if (!isConfigured || !isAvailable) ...[
                    const SizedBox(height: TagSpacing.s3),
                    Text(
                      isAvailable
                          ? 'This build needs TAG_BETA_FEEDBACK_ENDPOINT and TAG_BETA_FEEDBACK_ANON_KEY before reports can be sent.'
                          : 'This screen is only enabled for internal beta builds.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.snoozedText,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedbackField extends StatelessWidget {
  const _FeedbackField({
    required this.controller,
    required this.label,
    required this.hint,
    this.maxLines = 4,
    this.isRequired = true,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final int maxLines;
  final bool isRequired;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textInputAction: maxLines == 1 ? TextInputAction.next : null,
      decoration: InputDecoration(labelText: label, hintText: hint),
      validator: (value) {
        if (!isRequired) {
          return null;
        }
        if ((value ?? '').trim().length < 3) {
          return '$label needs a little more detail.';
        }
        return null;
      },
    );
  }
}

class _AttachmentPanel extends StatelessWidget {
  const _AttachmentPanel({required this.state});

  final BetaFeedbackState state;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<TagThemeColors>()!;
    final theme = Theme.of(context);
    final attachment = state.attachment;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(TagSpacing.s4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.image_outlined, color: colors.textSecondary),
                const SizedBox(width: TagSpacing.s2),
                Expanded(
                  child: Text(
                    'Screenshot (optional)',
                    style: theme.textTheme.titleSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: TagSpacing.s2),
            Text(
              'Screenshots may contain private saved context. Preview it here and remove anything you do not want reviewed privately.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: TagSpacing.s3),
            if (attachment == null)
              OutlinedButton.icon(
                onPressed: state.isSubmitting
                    ? null
                    : context.read<BetaFeedbackCubit>().pickScreenshot,
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: const Text('Attach screenshot'),
              )
            else
              _AttachmentPreview(attachment: attachment),
          ],
        ),
      ),
    );
  }
}

class _AttachmentPreview extends StatelessWidget {
  const _AttachmentPreview({required this.attachment});

  final BetaFeedbackAttachment attachment;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<TagThemeColors>()!;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(TagRadii.sourcePreview),
          child: Image.file(
            File(attachment.path),
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) {
              return Container(
                height: 120,
                color: colors.surfaceSunken,
                alignment: Alignment.center,
                child: Text(
                  'Preview unavailable',
                  style: theme.textTheme.bodyMedium,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: TagSpacing.s2),
        Row(
          children: [
            Expanded(
              child: Text(
                '${attachment.fileName} - ${_formatBytes(attachment.byteSize)}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            TextButton.icon(
              onPressed: context.read<BetaFeedbackCubit>().removeScreenshot,
              icon: const Icon(Icons.close_rounded),
              label: const Text('Remove'),
            ),
          ],
        ),
      ],
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    }
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class _DiagnosticsTile extends StatelessWidget {
  const _DiagnosticsTile({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      value: value,
      onChanged: onChanged,
      title: const Text('Include minimal diagnostics'),
      subtitle: const Text(
        'App version, OS, surface, and local-only flags. No saved source text or database contents.',
      ),
      secondary: const Icon(Icons.fact_check_outlined),
    );
  }
}

class _ConsentTile extends StatelessWidget {
  const _ConsentTile({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: value,
      onChanged: onChanged == null ? null : (next) => onChanged!(next ?? false),
      controlAffinity: ListTileControlAffinity.leading,
      title: const Text(
        'I understand this sends a beta bug report to the Tag team. I have removed anything I do not want reviewed privately.',
      ),
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<TagThemeColors>()!;
    return Container(
      padding: const EdgeInsets.all(TagSpacing.s3),
      decoration: BoxDecoration(
        color: colors.urgentSoft,
        borderRadius: BorderRadius.circular(TagRadii.compactCard),
        border: Border.all(color: colors.urgent.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: colors.urgentText),
          const SizedBox(width: TagSpacing.s2),
          Expanded(
            child: Text(message, style: TextStyle(color: colors.urgentText)),
          ),
        ],
      ),
    );
  }
}

class _SuccessPanel extends StatelessWidget {
  const _SuccessPanel({required this.result});

  final BetaFeedbackSubmissionResult result;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<TagThemeColors>()!;
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(TagSpacing.s3),
      decoration: BoxDecoration(
        color: colors.goalActiveSoft,
        borderRadius: BorderRadius.circular(TagRadii.compactCard),
        border: Border.all(color: colors.goalActive.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                color: colors.goalActiveText,
              ),
              const SizedBox(width: TagSpacing.s2),
              Expanded(
                child: Text(
                  'Report received privately',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colors.goalActiveText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: TagSpacing.s2),
          Text(
            'Private report id: ${result.reportId}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.goalActiveText,
            ),
          ),
          const SizedBox(height: TagSpacing.s1),
          Text(
            'The Tag team will triage it from the private beta queue.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.goalActiveText,
            ),
          ),
        ],
      ),
    );
  }
}
