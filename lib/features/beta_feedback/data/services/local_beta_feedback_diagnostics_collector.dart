import 'dart:io';
import 'dart:ui';

import 'package:tag/core/config/app_config.dart';
import 'package:tag/features/beta_feedback/domain/entities/beta_feedback_entities.dart';
import 'package:tag/features/beta_feedback/domain/services/beta_feedback_diagnostics_collector.dart';

class LocalBetaFeedbackDiagnosticsCollector
    implements BetaFeedbackDiagnosticsCollector {
  const LocalBetaFeedbackDiagnosticsCollector(this._appConfig);

  final AppConfig _appConfig;

  @override
  Future<BetaFeedbackDiagnostics> collect({
    required String currentSurface,
  }) async {
    final operatingSystem = Platform.operatingSystem;

    return BetaFeedbackDiagnostics(
      appVersion: _appConfig.appVersion,
      buildNumber: _appConfig.buildNumber,
      commitSha: _appConfig.commitSha,
      deviceModel: operatingSystem == 'ios' ? 'iOS device' : operatingSystem,
      osVersion: Platform.operatingSystemVersion,
      currentSurface: currentSurface,
      generatedAtIso8601: DateTime.now().toUtc().toIso8601String(),
      extra: {
        'diagnostics_scope':
            'privacy_preserving; no saved source text or local database data',
        'local_first': _appConfig.localFirst,
        'local_only_mode': _appConfig.localOnlyMode,
        'cloud_fallback_enabled': _appConfig.cloudFallbackEnabled,
        'remote_llm_enabled': _appConfig.remoteLlmEnabled,
        'locale': PlatformDispatcher.instance.locale.toLanguageTag(),
      },
    );
  }
}
