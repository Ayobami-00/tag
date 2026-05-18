import 'package:flutter_test/flutter_test.dart';
import 'package:tag/core/ai/cactus/cactus_model_registry.dart';
import 'package:tag/core/ai/cactus/cactus_model_service.dart';

void main() {
  test('keeps fast local card setup and compact Nomic as defaults', () {
    expect(CactusModelRegistry.primaryVisionToolModelSlug, 'lfm2-vl-450m');
    expect(CactusModelRegistry.qualityVisionModelSlug, 'gemma-4-E2B-it');
    expect(CactusModelRegistry.defaultEmbeddingModelSlug, 'nomic2-embed-300m');
    expect(CactusModelRegistry.qualityEmbeddingModelSlug, 'qwen3-0.6-embed');
  });

  test('configures compact and quality embedding profiles', () {
    final compact = CactusModelRegistry.embeddingConfigForSlug(
      CactusModelRegistry.compactEmbeddingModelSlug,
    );
    final quality = CactusModelRegistry.embeddingConfigForSlug(
      CactusModelRegistry.qualityEmbeddingModelSlug,
    );

    expect(compact.dimension, 256);
    expect(compact.queryPrefix, 'search_query: ');
    expect(compact.documentPrefix, 'search_document: ');
    expect(quality.dimension, 512);
    expect(quality.queryInstruction, contains('personal intention inbox'));
    expect(compact.retrieval, 'hybrid_vector_plus_keyword');
    expect(quality.distance, 'cosine');
  });

  test('startup model set includes primary and selected embedding only', () {
    expect(
      CactusModelRegistry.requiredStartupModelSlugs(
        selectedPrimarySlug: 'unknown',
        selectedEmbeddingSlug: 'unknown',
      ),
      [
        CactusModelRegistry.primaryVisionToolModelSlug,
        CactusModelRegistry.defaultEmbeddingModelSlug,
      ],
    );
    expect(
      CactusModelRegistry.requiredStartupModelSlugs(
        selectedPrimarySlug: CactusModelRegistry.qualityVisionModelSlug,
        selectedEmbeddingSlug: CactusModelRegistry.qualityEmbeddingModelSlug,
      ),
      [
        CactusModelRegistry.qualityVisionModelSlug,
        CactusModelRegistry.qualityEmbeddingModelSlug,
      ],
    );
  });

  test('primary card model targets have direct Cactus-Compute assets', () {
    final asset = CactusModelRegistry.directDownloadAssetForSlug(
      CactusModelRegistry.primaryVisionToolModelSlug,
    );
    final qualityAsset = CactusModelRegistry.directDownloadAssetForSlug(
      CactusModelRegistry.qualityVisionModelSlug,
    );

    expect(asset, isNotNull);
    expect(asset!.downloadUrl, contains('Cactus-Compute/LFM2-VL-450M'));
    expect(asset.downloadUrl, contains('lfm2-vl-450m-int4-apple.zip'));
    expect(qualityAsset, isNotNull);
    expect(
      qualityAsset!.downloadUrl,
      contains('gemma-4-e2b-it-int4-apple.zip'),
    );
  });

  test('selects embedding profile from local storage capacity', () {
    expect(
      CactusModelRegistry.embeddingSlugForStorage(
        availableBytes: 4 * 1024 * 1024 * 1024,
        totalBytes: 64 * 1024 * 1024 * 1024,
        minAvailableBytes: 8 * 1024 * 1024 * 1024,
        minTotalBytes: 128 * 1024 * 1024 * 1024,
      ),
      CactusModelRegistry.compactEmbeddingModelSlug,
    );
    expect(
      CactusModelRegistry.embeddingSlugForStorage(
        availableBytes: 16 * 1024 * 1024 * 1024,
        totalBytes: 256 * 1024 * 1024 * 1024,
        minAvailableBytes: 8 * 1024 * 1024 * 1024,
        minTotalBytes: 128 * 1024 * 1024 * 1024,
      ),
      CactusModelRegistry.qualityEmbeddingModelSlug,
    );
  });

  test('passes primary capability check for completion, tools, and vision', () {
    final model = const LocalAiModelInfo(
      slug: CactusModelRegistry.primaryVisionToolModelSlug,
      displayName: 'Gemma 4 E2B IT',
      capabilities: {
        AiModelCapability.completion,
        AiModelCapability.tools,
        AiModelCapability.vision,
      },
      isDownloaded: true,
    );

    final check = CactusModelRegistry.checkPrimaryModel(
      model,
      now: () => DateTime.utc(2026, 5, 9),
    );

    expect(check.isPassed, isTrue);
    expect(check.missingCapabilities, isEmpty);
  });

  test('fails readiness check until model files are local', () {
    final model = const LocalAiModelInfo(
      slug: CactusModelRegistry.primaryVisionToolModelSlug,
      displayName: 'LFM2 VL 450M',
      capabilities: {
        AiModelCapability.completion,
        AiModelCapability.tools,
        AiModelCapability.vision,
      },
    );

    final check = CactusModelRegistry.checkPrimaryModel(
      model,
      now: () => DateTime.utc(2026, 5, 17),
    );

    expect(check.isPassed, isFalse);
    expect(check.isModelReady, isFalse);
    expect(check.message, contains('not downloaded locally yet'));
  });

  test('fails clearly when primary model is missing tools or vision', () {
    final model = const LocalAiModelInfo(
      slug: CactusModelRegistry.primaryVisionToolModelSlug,
      displayName: 'Gemma 4 E2B IT',
      capabilities: {AiModelCapability.completion},
      isDownloaded: true,
    );

    final check = CactusModelRegistry.checkPrimaryModel(
      model,
      now: () => DateTime.utc(2026, 5, 9),
    );

    expect(check.isPassed, isFalse);
    expect(check.missingCapabilities, {
      AiModelCapability.tools,
      AiModelCapability.vision,
    });
    expect(check.message, contains('tools'));
    expect(check.message, contains('vision'));
  });
}
