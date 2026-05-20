import 'package:tag/core/ai/cactus/cactus_model_registry.dart';

class AppConfig {
  AppConfig({
    this.localFirst = true,
    bool localOnlyMode = true,
    bool cloudFallbackEnabled = false,
    bool remoteLlmEnabled = false,
    bool cactusTelemetryEnabled = false,
    this.autoDownloadRequiredModels = true,
    this.qualityEmbeddingMinAvailableBytes = 8 * 1024 * 1024 * 1024,
    this.qualityEmbeddingMinTotalBytes = 128 * 1024 * 1024 * 1024,
    this.primaryModelSlug = CactusModelRegistry.defaultPrimaryModelSlug,
    this.embeddingModelSlug = CactusModelRegistry.defaultEmbeddingModelSlug,
    this.betaFeedbackEnabled = betaFeedbackEnabledFromEnvironment,
    this.betaFeedbackEndpoint = betaFeedbackEndpointFromEnvironment,
    this.betaFeedbackAnonKey = betaFeedbackAnonKeyFromEnvironment,
    this.appVersion = appVersionFromEnvironment,
    this.buildNumber = buildNumberFromEnvironment,
    this.commitSha = commitShaFromEnvironment,
  }) : localOnlyMode = _mustBeTrue(localOnlyMode, 'localOnlyMode'),
       cloudFallbackEnabled = _mustBeFalse(
         cloudFallbackEnabled,
         'cloudFallbackEnabled',
       ),
       remoteLlmEnabled = _mustBeFalse(remoteLlmEnabled, 'remoteLlmEnabled'),
       cactusTelemetryEnabled = _mustBeFalse(
         cactusTelemetryEnabled,
         'cactusTelemetryEnabled',
       );

  static const bool mvpCloudFallback = false;
  static const bool mvpRemoteLlm = false;
  static const bool mvpCactusTelemetry = false;
  static const bool mvpLocalOnly = true;
  static const bool betaFeedbackEnabledFromEnvironment = bool.fromEnvironment(
    'TAG_BETA_FEEDBACK_ENABLED',
  );
  static const String betaFeedbackEndpointFromEnvironment =
      String.fromEnvironment('TAG_BETA_FEEDBACK_ENDPOINT');
  static const String betaFeedbackAnonKeyFromEnvironment =
      String.fromEnvironment('TAG_BETA_FEEDBACK_ANON_KEY');
  static const String appVersionFromEnvironment = String.fromEnvironment(
    'TAG_APP_VERSION',
    defaultValue: '1.0.0',
  );
  static const String buildNumberFromEnvironment = String.fromEnvironment(
    'TAG_BUILD_NUMBER',
    defaultValue: '1',
  );
  static const String commitShaFromEnvironment = String.fromEnvironment(
    'TAG_COMMIT_SHA',
    defaultValue: 'local',
  );

  final bool localFirst;
  final bool localOnlyMode;
  final bool cloudFallbackEnabled;
  final bool remoteLlmEnabled;
  final bool cactusTelemetryEnabled;
  final bool autoDownloadRequiredModels;
  final int qualityEmbeddingMinAvailableBytes;
  final int qualityEmbeddingMinTotalBytes;
  final String primaryModelSlug;
  final String embeddingModelSlug;
  final bool betaFeedbackEnabled;
  final String betaFeedbackEndpoint;
  final String betaFeedbackAnonKey;
  final String appVersion;
  final String buildNumber;
  final String commitSha;

  bool get betaFeedbackConfigured =>
      betaFeedbackEndpoint.trim().isNotEmpty &&
      betaFeedbackAnonKey.trim().isNotEmpty;

  static bool _mustBeFalse(bool value, String name) {
    if (value) {
      throw UnsupportedError('$name cannot be enabled in Tag MVP.');
    }

    return false;
  }

  static bool _mustBeTrue(bool value, String name) {
    if (!value) {
      throw UnsupportedError('$name cannot be disabled in Tag MVP.');
    }

    return true;
  }
}
