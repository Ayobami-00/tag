import 'package:flutter_test/flutter_test.dart';
import 'package:tag/core/config/app_config.dart';

void main() {
  test('defaults to the MVP local-only policy', () {
    final config = AppConfig();

    expect(config.localOnlyMode, isTrue);
    expect(config.cloudFallbackEnabled, isFalse);
    expect(config.remoteLlmEnabled, isFalse);
    expect(config.cactusTelemetryEnabled, isFalse);
    expect(config.autoDownloadRequiredModels, isTrue);
    expect(config.qualityEmbeddingMinAvailableBytes, greaterThan(0));
    expect(config.qualityEmbeddingMinTotalBytes, greaterThan(0));
    expect(AppConfig.mvpCloudFallback, isFalse);
    expect(AppConfig.mvpRemoteLlm, isFalse);
    expect(AppConfig.mvpCactusTelemetry, isFalse);
    expect(AppConfig.mvpLocalOnly, isTrue);
  });

  test('rejects cloud fallback, remote LLM, telemetry, and non-local mode', () {
    expect(() => AppConfig(cloudFallbackEnabled: true), throwsUnsupportedError);
    expect(() => AppConfig(remoteLlmEnabled: true), throwsUnsupportedError);
    expect(
      () => AppConfig(cactusTelemetryEnabled: true),
      throwsUnsupportedError,
    );
    expect(() => AppConfig(localOnlyMode: false), throwsUnsupportedError);
  });
}
