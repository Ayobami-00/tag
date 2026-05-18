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
