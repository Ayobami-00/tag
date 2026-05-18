import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tag/core/DI/di.dart';
import 'package:tag/core/ai/cactus/cactus_model_registry.dart';
import 'package:tag/core/ai/cactus/cactus_model_service.dart';
import 'package:tag/features/model_setup/presentation/logic/model_setup_cubit.dart';
import 'package:tag/utils/index.dart';

class ModelSetupScreen extends StatelessWidget {
  const ModelSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => locator<ModelSetupCubit>()..load(),
      child: const _ModelSetupView(),
    );
  }
}

class _ModelSetupView extends StatelessWidget {
  const _ModelSetupView();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<TagThemeColors>()!;

    return Scaffold(
      appBar: AppBar(title: const Text('Model setup')),
      body: SafeArea(
        child: BlocBuilder<ModelSetupCubit, ModelSetupState>(
          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: context.read<ModelSetupCubit>().refresh,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  TagSpacing.s4,
                  TagSpacing.s3,
                  TagSpacing.s4,
                  TagSpacing.s8,
                ),
                children: [
                  Wrap(
                    spacing: TagSpacing.s2,
                    runSpacing: TagSpacing.s2,
                    children: [
                      _PolicyChip(
                        label: 'Local-only',
                        icon: Icons.lock_outline_rounded,
                        foregroundColor: colors.goalActiveText,
                        backgroundColor: colors.goalActiveSoft,
                      ),
                      _PolicyChip(
                        label: 'Cloud fallback off',
                        icon: Icons.cloud_off_rounded,
                        foregroundColor: colors.textSecondary,
                        backgroundColor: colors.surfaceSunken,
                      ),
                      _PolicyChip(
                        label: 'Telemetry off',
                        icon: Icons.visibility_off_outlined,
                        foregroundColor: colors.textSecondary,
                        backgroundColor: colors.surfaceSunken,
                      ),
                    ],
                  ),
                  const SizedBox(height: TagSpacing.s4),
                  if (state.status == ModelSetupStatus.loading)
                    const LinearProgressIndicator(minHeight: 3),
                  if (_activeModelDownloads(state).isNotEmpty) ...[
                    _StatusBanner(
                      icon: Icons.downloading_rounded,
                      message: _activeDownloadMessage(state),
                      foregroundColor: colors.brandSoftText,
                      backgroundColor: colors.brandSoft,
                    ),
                    const SizedBox(height: TagSpacing.s3),
                  ],
                  if (state.errorMessage.isNotEmpty) ...[
                    _StatusBanner(
                      icon: Icons.info_outline_rounded,
                      message: state.errorMessage,
                      foregroundColor: colors.snoozedText,
                      backgroundColor: colors.snoozedSoft,
                    ),
                    const SizedBox(height: TagSpacing.s3),
                  ],
                  if (state.actionMessage.isNotEmpty) ...[
                    _StatusBanner(
                      icon: Icons.memory_rounded,
                      message: state.actionMessage,
                      foregroundColor: colors.brandSoftText,
                      backgroundColor: colors.brandSoft,
                    ),
                    const SizedBox(height: TagSpacing.s3),
                  ],
                  _PrimaryStatusCard(state: state),
                  const SizedBox(height: TagSpacing.s4),
                  _EmbeddingStatusCard(state: state),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PrimaryStatusCard extends StatelessWidget {
  const _PrimaryStatusCard({required this.state});

  final ModelSetupState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ModelSetupCubit>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(TagSpacing.s4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ModelCardHeader(
              title: 'Card creation quality',
              subtitle: state.selectedPrimaryConfig.userLabel,
              icon: Icons.auto_awesome_rounded,
            ),
            const SizedBox(height: TagSpacing.s3),
            Wrap(
              spacing: TagSpacing.s2,
              runSpacing: TagSpacing.s2,
              children: CactusModelRegistry.primaryProfiles
                  .map((profile) {
                    return ChoiceChip(
                      label: Text(profile.userLabel),
                      selected: profile.modelSlug == state.selectedPrimarySlug,
                      onSelected: state.isBusy
                          ? null
                          : (_) => cubit.selectPrimary(profile.modelSlug),
                    );
                  })
                  .toList(growable: false),
            ),
            const SizedBox(height: TagSpacing.s3),
            _ModelStatusBody(
              model: state.primaryModel,
              requiredCapabilities:
                  CactusModelRegistry.primaryModelCapabilities,
              capabilityCheck: state.effectivePrimaryCheck,
              isBusy: state.isBusy,
              activeModelSlug: state.activeModelSlug,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmbeddingStatusCard extends StatelessWidget {
  const _EmbeddingStatusCard({required this.state});

  final ModelSetupState state;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<TagThemeColors>()!;
    final cubit = context.read<ModelSetupCubit>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(TagSpacing.s4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ModelCardHeader(
              title: 'Embedding model',
              subtitle: state.selectedEmbeddingConfig.displayName,
              icon: Icons.hub_outlined,
            ),
            const SizedBox(height: TagSpacing.s3),
            Wrap(
              spacing: TagSpacing.s2,
              runSpacing: TagSpacing.s2,
              children: CactusModelRegistry.embeddingProfiles
                  .map((profile) {
                    final selected =
                        profile.modelSlug == state.selectedEmbeddingSlug;

                    return ChoiceChip(
                      label: Text(profile.displayName),
                      selected: selected,
                      onSelected: state.isBusy
                          ? null
                          : (_) => cubit.selectEmbedding(profile.modelSlug),
                    );
                  })
                  .toList(growable: false),
            ),
            const SizedBox(height: TagSpacing.s3),
            Text(
              state.embeddingModel.slug,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: TagSpacing.s3),
            Wrap(
              spacing: TagSpacing.s2,
              runSpacing: TagSpacing.s2,
              children: [
                _MetricChip(
                  label: '${state.selectedEmbeddingConfig.dimension}d',
                  icon: Icons.straighten_rounded,
                  foregroundColor: colors.textSecondary,
                  backgroundColor: colors.surfaceSunken,
                ),
                _MetricChip(
                  label: state.selectedEmbeddingConfig.distance,
                  icon: Icons.trip_origin_rounded,
                  foregroundColor: colors.textSecondary,
                  backgroundColor: colors.surfaceSunken,
                ),
                _MetricChip(
                  label: 'Hybrid retrieval',
                  icon: Icons.manage_search_rounded,
                  foregroundColor: colors.textSecondary,
                  backgroundColor: colors.surfaceSunken,
                ),
              ],
            ),
            const SizedBox(height: TagSpacing.s4),
            _CapabilityRow(
              capability: AiModelCapability.embedding,
              isSupported: state.embeddingModel.supports(
                AiModelCapability.embedding,
              ),
            ),
            const SizedBox(height: TagSpacing.s3),
            _ModelAvailability(model: state.embeddingModel),
            const SizedBox(height: TagSpacing.s4),
            _ModelActions(
              model: state.embeddingModel,
              capabilityCheck: state.effectiveEmbeddingCheck,
              isBusy: state.isBusy,
              activeModelSlug: state.activeModelSlug,
            ),
          ],
        ),
      ),
    );
  }
}

class _ModelStatusBody extends StatelessWidget {
  const _ModelStatusBody({
    required this.model,
    required this.requiredCapabilities,
    required this.capabilityCheck,
    required this.isBusy,
    required this.activeModelSlug,
  });

  final LocalAiModelInfo model;
  final Set<AiModelCapability> requiredCapabilities;
  final ModelCapabilityCheck capabilityCheck;
  final bool isBusy;
  final String activeModelSlug;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(model.slug, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: TagSpacing.s4),
        ...requiredCapabilities.map((capability) {
          return Padding(
            padding: const EdgeInsets.only(bottom: TagSpacing.s2),
            child: _CapabilityRow(
              capability: capability,
              isSupported: model.supports(capability),
            ),
          );
        }),
        const SizedBox(height: TagSpacing.s2),
        _ModelAvailability(model: model),
        const SizedBox(height: TagSpacing.s4),
        _CapabilitySummary(capabilityCheck: capabilityCheck),
        const SizedBox(height: TagSpacing.s4),
        _ModelActions(
          model: model,
          capabilityCheck: capabilityCheck,
          isBusy: isBusy,
          activeModelSlug: activeModelSlug,
        ),
      ],
    );
  }
}

class _ModelCardHeader extends StatelessWidget {
  const _ModelCardHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<TagThemeColors>()!;
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.brandSoft,
            shape: BoxShape.circle,
          ),
          child: Padding(
            padding: const EdgeInsets.all(TagSpacing.s3),
            child: Icon(icon, color: colors.brandSoftText, size: 20),
          ),
        ),
        const SizedBox(width: TagSpacing.s3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.labelLarge),
              const SizedBox(height: TagSpacing.s1),
              Text(subtitle, style: theme.textTheme.titleSmall),
            ],
          ),
        ),
      ],
    );
  }
}

class _CapabilityRow extends StatelessWidget {
  const _CapabilityRow({required this.capability, required this.isSupported});

  final AiModelCapability capability;
  final bool isSupported;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<TagThemeColors>()!;

    return Row(
      children: [
        Icon(
          isSupported
              ? Icons.check_circle_outline_rounded
              : Icons.error_outline_rounded,
          color: isSupported ? colors.goalActive : colors.snoozed,
          size: 20,
        ),
        const SizedBox(width: TagSpacing.s2),
        Expanded(
          child: Text(
            _capabilityLabel(capability),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        _MetricChip(
          label: isSupported ? 'Supported' : 'Missing',
          icon: isSupported ? Icons.done_rounded : Icons.priority_high_rounded,
          foregroundColor: isSupported
              ? colors.goalActiveText
              : colors.snoozedText,
          backgroundColor: isSupported
              ? colors.goalActiveSoft
              : colors.snoozedSoft,
        ),
      ],
    );
  }
}

class _CapabilitySummary extends StatelessWidget {
  const _CapabilitySummary({required this.capabilityCheck});

  final ModelCapabilityCheck capabilityCheck;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<TagThemeColors>()!;
    final isPassed = capabilityCheck.isPassed;

    return _StatusBanner(
      icon: isPassed ? Icons.verified_outlined : Icons.report_problem_outlined,
      message: capabilityCheck.message,
      foregroundColor: isPassed ? colors.goalActiveText : colors.snoozedText,
      backgroundColor: isPassed ? colors.goalActiveSoft : colors.snoozedSoft,
    );
  }
}

class _ModelAvailability extends StatelessWidget {
  const _ModelAvailability({required this.model});

  final LocalAiModelInfo model;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<TagThemeColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: TagSpacing.s2,
          runSpacing: TagSpacing.s2,
          children: [
            _MetricChip(
              label: _downloadStatusLabel(model),
              icon: _downloadStatusIcon(model.downloadStatus),
              foregroundColor: _downloadStatusForeground(colors, model),
              backgroundColor: _downloadStatusBackground(colors, model),
            ),
            _MetricChip(
              label: model.isInitialized ? 'Initialized' : 'Not initialized',
              icon: model.isInitialized
                  ? Icons.power_settings_new_rounded
                  : Icons.power_off_rounded,
              foregroundColor: model.isInitialized
                  ? colors.goalActiveText
                  : colors.textSecondary,
              backgroundColor: model.isInitialized
                  ? colors.goalActiveSoft
                  : colors.surfaceSunken,
            ),
            if (model.sizeMb != null)
              _MetricChip(
                label: '${model.sizeMb!.round()} MB',
                icon: Icons.storage_rounded,
                foregroundColor: colors.textSecondary,
                backgroundColor: colors.surfaceSunken,
              ),
            if (model.quantization != null)
              _MetricChip(
                label: model.quantization!,
                icon: Icons.speed_rounded,
                foregroundColor: colors.textSecondary,
                backgroundColor: colors.surfaceSunken,
              ),
          ],
        ),
        if (_shouldShowDownloadDetail(model)) ...[
          const SizedBox(height: TagSpacing.s3),
          _ModelDownloadProgress(model: model),
        ],
      ],
    );
  }
}

class _ModelDownloadProgress extends StatelessWidget {
  const _ModelDownloadProgress({required this.model});

  final LocalAiModelInfo model;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<TagThemeColors>()!;
    final progress = model.downloadProgress?.clamp(0, 1).toDouble();
    final isFailed = _isFailureStatus(model.downloadStatus);
    final message =
        model.downloadStatusMessage ?? model.failureReason ?? 'Preparing...';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isFailed ? colors.urgentSoft : colors.surfaceSunken,
        borderRadius: BorderRadius.circular(TagRadii.compactCard),
      ),
      child: Padding(
        padding: const EdgeInsets.all(TagSpacing.s3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: colors.borderDefault,
              color: isFailed ? colors.urgent : colors.brandPrimary,
            ),
            const SizedBox(height: TagSpacing.s2),
            Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isFailed ? colors.urgentText : colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModelActions extends StatelessWidget {
  const _ModelActions({
    required this.model,
    required this.capabilityCheck,
    required this.isBusy,
    required this.activeModelSlug,
  });

  final LocalAiModelInfo model;
  final ModelCapabilityCheck capabilityCheck;
  final bool isBusy;
  final String activeModelSlug;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ModelSetupCubit>();
    final isActive = activeModelSlug == model.slug;
    final canAct = !isBusy || isActive;
    final isDownloading =
        model.downloadStatus == AiModelDownloadStatus.queued ||
        model.downloadStatus == AiModelDownloadStatus.downloading;
    final isInitializing =
        model.downloadStatus == AiModelDownloadStatus.initializing;

    return Wrap(
      spacing: TagSpacing.s2,
      runSpacing: TagSpacing.s2,
      children: [
        OutlinedButton.icon(
          onPressed: isBusy ? null : cubit.refresh,
          icon: const Icon(Icons.refresh_rounded, size: 18),
          label: const Text('Refresh'),
        ),
        FilledButton.icon(
          onPressed: canAct && !model.isDownloaded && !isDownloading
              ? () => cubit.download(model.slug)
              : null,
          icon: isDownloading || (isActive && !model.isDownloaded)
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.download_rounded, size: 18),
          label: Text(isDownloading ? 'Downloading' : 'Download'),
        ),
        FilledButton.icon(
          onPressed:
              canAct &&
                  model.isDownloaded &&
                  !model.isInitialized &&
                  !isInitializing
              ? () => cubit.initialize(model.slug)
              : null,
          icon:
              isInitializing ||
                  (isActive && model.isDownloaded && !model.isInitialized)
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.play_arrow_rounded, size: 18),
          label: Text(isInitializing ? 'Initializing' : 'Initialize'),
        ),
        OutlinedButton.icon(
          onPressed: null,
          icon: Icon(
            capabilityCheck.isPassed
                ? Icons.verified_rounded
                : Icons.report_problem_rounded,
            size: 18,
          ),
          label: Text(capabilityCheck.isPassed ? 'Verified' : 'Check failed'),
        ),
      ],
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.icon,
    required this.message,
    required this.foregroundColor,
    required this.backgroundColor,
  });

  final IconData icon;
  final String message;
  final Color foregroundColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(TagRadii.compactCard),
      ),
      child: Padding(
        padding: const EdgeInsets.all(TagSpacing.s3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: foregroundColor, size: 20),
            const SizedBox(width: TagSpacing.s2),
            Expanded(
              child: Text(
                message,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: foregroundColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PolicyChip extends StatelessWidget {
  const _PolicyChip({
    required this.label,
    required this.icon,
    required this.foregroundColor,
    required this.backgroundColor,
  });

  final String label;
  final IconData icon;
  final Color foregroundColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return _MetricChip(
      label: label,
      icon: icon,
      foregroundColor: foregroundColor,
      backgroundColor: backgroundColor,
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.label,
    required this.icon,
    required this.foregroundColor,
    required this.backgroundColor,
  });

  final String label;
  final IconData icon;
  final Color foregroundColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(TagRadii.chip),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: TagSpacing.s3,
          vertical: TagSpacing.s2,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: foregroundColor, size: 16),
            const SizedBox(width: TagSpacing.s1),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: foregroundColor),
            ),
          ],
        ),
      ),
    );
  }
}

String _capabilityLabel(AiModelCapability capability) {
  return switch (capability) {
    AiModelCapability.completion => 'Completion',
    AiModelCapability.tools => 'Tools',
    AiModelCapability.vision => 'Vision',
    AiModelCapability.embedding => 'Embedding',
    AiModelCapability.audio => 'Audio',
  };
}

List<LocalAiModelInfo> _activeModelDownloads(ModelSetupState state) {
  return state.models
      .where((model) {
        return model.downloadStatus == AiModelDownloadStatus.queued ||
            model.downloadStatus == AiModelDownloadStatus.downloading ||
            model.downloadStatus == AiModelDownloadStatus.initializing;
      })
      .toList(growable: false);
}

String _activeDownloadMessage(ModelSetupState state) {
  final activeModels = _activeModelDownloads(state);
  if (activeModels.isEmpty) {
    return '';
  }

  final labels = activeModels
      .map((model) {
        final percent = _downloadPercent(model);
        return percent == null
            ? model.displayName
            : '${model.displayName} $percent%';
      })
      .join(', ');

  return 'Preparing local models in the background: $labels.';
}

String _downloadStatusLabel(LocalAiModelInfo model) {
  return switch (model.downloadStatus) {
    AiModelDownloadStatus.notDownloaded =>
      model.isDownloaded ? 'Downloaded' : 'Not downloaded',
    AiModelDownloadStatus.queued => 'Queued',
    AiModelDownloadStatus.downloading =>
      'Downloading${_downloadPercentLabel(model)}',
    AiModelDownloadStatus.downloaded => 'Downloaded',
    AiModelDownloadStatus.initializing => 'Initializing',
    AiModelDownloadStatus.ready => 'Ready locally',
    AiModelDownloadStatus.initializationFailed => 'Initialization failed',
    AiModelDownloadStatus.failed => 'Download failed',
  };
}

String _downloadPercentLabel(LocalAiModelInfo model) {
  final percent = _downloadPercent(model);
  return percent == null ? '' : ' $percent%';
}

int? _downloadPercent(LocalAiModelInfo model) {
  final progress = model.downloadProgress;
  if (progress == null) {
    return null;
  }

  return (progress.clamp(0, 1) * 100).round();
}

IconData _downloadStatusIcon(AiModelDownloadStatus status) {
  return switch (status) {
    AiModelDownloadStatus.notDownloaded => Icons.download_for_offline_outlined,
    AiModelDownloadStatus.queued => Icons.schedule_rounded,
    AiModelDownloadStatus.downloading => Icons.downloading_rounded,
    AiModelDownloadStatus.downloaded => Icons.download_done_rounded,
    AiModelDownloadStatus.initializing => Icons.play_circle_outline_rounded,
    AiModelDownloadStatus.ready => Icons.verified_rounded,
    AiModelDownloadStatus.initializationFailed => Icons.error_outline_rounded,
    AiModelDownloadStatus.failed => Icons.error_outline_rounded,
  };
}

Color _downloadStatusForeground(TagThemeColors colors, LocalAiModelInfo model) {
  return switch (model.downloadStatus) {
    AiModelDownloadStatus.failed ||
    AiModelDownloadStatus.initializationFailed => colors.urgentText,
    AiModelDownloadStatus.queued ||
    AiModelDownloadStatus.downloading ||
    AiModelDownloadStatus.initializing => colors.brandSoftText,
    AiModelDownloadStatus.downloaded ||
    AiModelDownloadStatus.ready => colors.goalActiveText,
    AiModelDownloadStatus.notDownloaded =>
      model.isDownloaded ? colors.goalActiveText : colors.textSecondary,
  };
}

Color _downloadStatusBackground(TagThemeColors colors, LocalAiModelInfo model) {
  return switch (model.downloadStatus) {
    AiModelDownloadStatus.failed ||
    AiModelDownloadStatus.initializationFailed => colors.urgentSoft,
    AiModelDownloadStatus.queued ||
    AiModelDownloadStatus.downloading ||
    AiModelDownloadStatus.initializing => colors.brandSoft,
    AiModelDownloadStatus.downloaded ||
    AiModelDownloadStatus.ready => colors.goalActiveSoft,
    AiModelDownloadStatus.notDownloaded =>
      model.isDownloaded ? colors.goalActiveSoft : colors.surfaceSunken,
  };
}

bool _shouldShowDownloadDetail(LocalAiModelInfo model) {
  return model.downloadStatus == AiModelDownloadStatus.downloading ||
      model.downloadStatus == AiModelDownloadStatus.queued ||
      model.downloadStatus == AiModelDownloadStatus.initializing ||
      model.downloadStatus == AiModelDownloadStatus.initializationFailed ||
      model.downloadStatus == AiModelDownloadStatus.failed;
}

bool _isFailureStatus(AiModelDownloadStatus status) {
  return status == AiModelDownloadStatus.failed ||
      status == AiModelDownloadStatus.initializationFailed;
}
