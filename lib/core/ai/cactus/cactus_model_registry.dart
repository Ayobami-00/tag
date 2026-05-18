import 'package:equatable/equatable.dart';
import 'package:tag/core/ai/cactus/cactus_model_service.dart';

enum EmbeddingProfile { compact, quality }

enum PrimaryModelProfile { fast, quality }

class PrimaryModelConfig extends Equatable {
  const PrimaryModelConfig({
    required this.profile,
    required this.modelSlug,
    required this.displayName,
    required this.userLabel,
    required this.userDescription,
  });

  final PrimaryModelProfile profile;
  final String modelSlug;
  final String displayName;
  final String userLabel;
  final String userDescription;

  @override
  List<Object?> get props => [
    profile,
    modelSlug,
    displayName,
    userLabel,
    userDescription,
  ];
}

class EmbeddingModelConfig extends Equatable {
  const EmbeddingModelConfig({
    required this.profile,
    required this.modelSlug,
    required this.displayName,
    required this.dimension,
    required this.maxChunkTokens,
    required this.distance,
    required this.retrieval,
    this.queryPrefix = '',
    this.documentPrefix = '',
    this.queryInstruction = '',
  });

  final EmbeddingProfile profile;
  final String modelSlug;
  final String displayName;
  final int dimension;
  final int maxChunkTokens;
  final String distance;
  final String retrieval;
  final String queryPrefix;
  final String documentPrefix;
  final String queryInstruction;

  @override
  List<Object?> get props => [
    profile,
    modelSlug,
    displayName,
    dimension,
    maxChunkTokens,
    distance,
    retrieval,
    queryPrefix,
    documentPrefix,
    queryInstruction,
  ];
}

class CactusModelDownloadAsset extends Equatable {
  const CactusModelDownloadAsset({
    required this.slug,
    required this.downloadUrl,
    required this.filename,
    required this.sourceLabel,
  });

  final String slug;
  final String downloadUrl;
  final String filename;
  final String sourceLabel;

  @override
  List<Object?> get props => [slug, downloadUrl, filename, sourceLabel];
}

class ModelCapabilityCheck extends Equatable {
  const ModelCapabilityCheck({
    required this.modelSlug,
    required this.requiredCapabilities,
    required this.missingCapabilities,
    required this.checkedAt,
    this.isModelAvailable = true,
    this.isModelReady = true,
  });

  final String modelSlug;
  final Set<AiModelCapability> requiredCapabilities;
  final Set<AiModelCapability> missingCapabilities;
  final DateTime checkedAt;
  final bool isModelAvailable;
  final bool isModelReady;

  bool get isPassed =>
      isModelAvailable && isModelReady && missingCapabilities.isEmpty;

  String get message {
    if (!isModelAvailable) {
      return '$modelSlug is not reported by the local Cactus registry.';
    }

    if (!isModelReady) {
      return '$modelSlug is available, but it is not downloaded locally yet.';
    }

    if (isPassed) {
      return '$modelSlug has the required local capabilities.';
    }

    final missing = missingCapabilities
        .map((capability) {
          return capability.storageValue;
        })
        .join(', ');

    return '$modelSlug is missing: $missing.';
  }

  @override
  List<Object?> get props => [
    modelSlug,
    requiredCapabilities,
    missingCapabilities,
    checkedAt,
    isModelAvailable,
    isModelReady,
  ];
}

abstract final class CactusModelRegistry {
  static const compactVisionModelSlug = 'lfm2-vl-450m';
  static const gemma4E2BModelSlug = 'gemma-4-E2B-it';
  static const qualityVisionModelSlug = gemma4E2BModelSlug;
  static const defaultPrimaryModelSlug = compactVisionModelSlug;
  static const primaryVisionToolModelSlug = defaultPrimaryModelSlug;
  static const primaryModelSlug = primaryVisionToolModelSlug;
  static const optionalHighEndModelSlug = 'gemma-4-E4B-it';
  static const optionalFastToolModelSlug = 'functiongemma-270m';
  static const defaultEmbeddingModelSlug = compactEmbeddingModelSlug;
  static const compactEmbeddingModelSlug = 'nomic2-embed-300m';
  static const qualityEmbeddingModelSlug = 'qwen3-0.6-embed';
  static const _lfm2Vl450MAppleDownloadAsset = CactusModelDownloadAsset(
    slug: compactVisionModelSlug,
    downloadUrl:
        'https://huggingface.co/Cactus-Compute/LFM2-VL-450M/resolve/main/'
        'weights/lfm2-vl-450m-int4-apple.zip',
    filename: 'lfm2-vl-450m-int4-apple.zip',
    sourceLabel: 'Cactus-Compute LFM2 VL 450M Apple INT4',
  );
  static const _gemma4E2BAppleInt4DownloadAsset = CactusModelDownloadAsset(
    slug: gemma4E2BModelSlug,
    downloadUrl:
        'https://huggingface.co/Cactus-Compute/gemma-4-E2B-it/resolve/main/'
        'weights/gemma-4-e2b-it-int4-apple.zip',
    filename: 'gemma-4-e2b-it-int4-apple.zip',
    sourceLabel: 'Cactus-Compute Cactus v1.14 Gemma 4 E2B Apple INT4',
  );
  static const _nomicEmbedInt4DownloadAsset = CactusModelDownloadAsset(
    slug: compactEmbeddingModelSlug,
    downloadUrl:
        'https://huggingface.co/Cactus-Compute/nomic-embed-text-v2-moe/'
        'resolve/main/weights/nomic-embed-text-v2-moe-int4.zip',
    filename: 'nomic-embed-text-v2-moe-int4.zip',
    sourceLabel: 'Cactus-Compute Cactus v1.14 Nomic Embed Text v2 MoE INT4',
  );
  static const _qwen3EmbedInt4DownloadAsset = CactusModelDownloadAsset(
    slug: qualityEmbeddingModelSlug,
    downloadUrl:
        'https://huggingface.co/Cactus-Compute/Qwen3-Embedding-0.6B/'
        'resolve/main/weights/qwen3-embedding-0.6b-int4.zip',
    filename: 'qwen3-embedding-0.6b-int4.zip',
    sourceLabel: 'Cactus-Compute Cactus v1.14 Qwen3 Embedding 0.6B INT4',
  );

  static const primaryModelCapabilities = {
    AiModelCapability.completion,
    AiModelCapability.tools,
    AiModelCapability.vision,
  };

  static const embeddingModelCapabilities = {AiModelCapability.embedding};

  static const compactEmbedding = EmbeddingModelConfig(
    profile: EmbeddingProfile.compact,
    modelSlug: compactEmbeddingModelSlug,
    displayName: 'Compact: Nomic v2 MoE',
    dimension: 256,
    maxChunkTokens: 350,
    distance: 'cosine',
    retrieval: 'hybrid_vector_plus_keyword',
    queryPrefix: 'search_query: ',
    documentPrefix: 'search_document: ',
  );

  static const qualityEmbedding = EmbeddingModelConfig(
    profile: EmbeddingProfile.quality,
    modelSlug: qualityEmbeddingModelSlug,
    displayName: 'Quality: Qwen3 Embedding 0.6B',
    dimension: 512,
    maxChunkTokens: 1200,
    distance: 'cosine',
    retrieval: 'hybrid_vector_plus_keyword',
    queryInstruction:
        'Instruct: Given a query from a personal intention inbox, retrieve '
        'saved screenshots, cards, spaces, and notes that answer it.\nQuery: ',
  );

  static const embeddingProfiles = [compactEmbedding, qualityEmbedding];

  static const fastPrimary = PrimaryModelConfig(
    profile: PrimaryModelProfile.fast,
    modelSlug: compactVisionModelSlug,
    displayName: 'LFM2 VL 450M',
    userLabel: 'Start sooner',
    userDescription:
        'Downloads a smaller local card model so you can test Tag sooner.',
  );

  static const qualityPrimary = PrimaryModelConfig(
    profile: PrimaryModelProfile.quality,
    modelSlug: qualityVisionModelSlug,
    displayName: 'Gemma 4 E2B IT',
    userLabel: 'Best quality',
    userDescription:
        'Downloads a larger local card model for stronger extraction.',
  );

  static const primaryProfiles = [fastPrimary, qualityPrimary];

  static LocalAiModelInfo get primaryModelTarget {
    return compactPrimaryModelTarget;
  }

  static LocalAiModelInfo get compactPrimaryModelTarget {
    return const LocalAiModelInfo(
      slug: compactVisionModelSlug,
      displayName: 'LFM2 VL 450M',
      capabilities: primaryModelCapabilities,
      sizeMb: 385,
      quantization: 'INT4 Apple',
    );
  }

  static LocalAiModelInfo get qualityPrimaryModelTarget {
    return const LocalAiModelInfo(
      slug: qualityVisionModelSlug,
      displayName: 'Gemma 4 E2B IT',
      capabilities: primaryModelCapabilities,
      sizeMb: 4463,
      quantization: 'INT4 Apple',
    );
  }

  static LocalAiModelInfo get compactEmbeddingTarget {
    return const LocalAiModelInfo(
      slug: compactEmbeddingModelSlug,
      displayName: 'Nomic Embed Text v2 MoE',
      capabilities: embeddingModelCapabilities,
      sizeMb: 328,
      quantization: 'INT4',
    );
  }

  static LocalAiModelInfo get qualityEmbeddingTarget {
    return const LocalAiModelInfo(
      slug: qualityEmbeddingModelSlug,
      displayName: 'Qwen3 Embedding 0.6B',
      capabilities: embeddingModelCapabilities,
      sizeMb: 394,
      quantization: 'INT4',
    );
  }

  static List<LocalAiModelInfo> get requiredModelTargets {
    return [
      compactPrimaryModelTarget,
      qualityPrimaryModelTarget,
      compactEmbeddingTarget,
      qualityEmbeddingTarget,
    ];
  }

  static List<CactusModelDownloadAsset> get directDownloadAssets {
    return [
      _lfm2Vl450MAppleDownloadAsset,
      _gemma4E2BAppleInt4DownloadAsset,
      _nomicEmbedInt4DownloadAsset,
      _qwen3EmbedInt4DownloadAsset,
    ];
  }

  static CactusModelDownloadAsset? directDownloadAssetForSlug(String slug) {
    for (final asset in directDownloadAssets) {
      if (asset.slug == slug) {
        return asset;
      }
    }

    return null;
  }

  static String? directDownloadInitializationMessage(String slug) {
    final asset = directDownloadAssetForSlug(slug);
    if (asset == null) {
      return null;
    }

    return 'Cactus model initialization failed for $slug. The model files '
        'are downloaded, but the bundled Cactus v1.14 native runtime could '
        'not initialize them. Confirm cactus-ios.xcframework is embedded and '
        'that the model folder contains a complete Cactus-Compute weight set.';
  }

  static List<String> requiredStartupModelSlugs({
    required String selectedPrimarySlug,
    required String selectedEmbeddingSlug,
  }) {
    final primarySlug = primaryModelConfigForSlug(
      selectedPrimarySlug,
    ).modelSlug;
    final embeddingSlug = embeddingConfigForSlug(
      selectedEmbeddingSlug,
    ).modelSlug;

    return {primarySlug, embeddingSlug}.toList(growable: false);
  }

  static PrimaryModelConfig primaryModelConfigForSlug(String slug) {
    return primaryProfiles.firstWhere(
      (profile) => profile.modelSlug == slug,
      orElse: () => fastPrimary,
    );
  }

  static bool isKnownPrimaryModel(String slug) {
    return primaryProfiles.any((profile) => profile.modelSlug == slug);
  }

  static String embeddingSlugForStorage({
    required int? availableBytes,
    required int? totalBytes,
    required int minAvailableBytes,
    required int minTotalBytes,
  }) {
    if (availableBytes == null || totalBytes == null) {
      return compactEmbeddingModelSlug;
    }

    if (availableBytes >= minAvailableBytes && totalBytes >= minTotalBytes) {
      return qualityEmbeddingModelSlug;
    }

    return compactEmbeddingModelSlug;
  }

  static EmbeddingModelConfig embeddingConfigForSlug(String slug) {
    return embeddingProfiles.firstWhere(
      (profile) => profile.modelSlug == slug,
      orElse: () => compactEmbedding,
    );
  }

  static bool isKnownEmbeddingModel(String slug) {
    return embeddingProfiles.any((profile) => profile.modelSlug == slug);
  }

  static ModelCapabilityCheck checkPrimaryModel(
    LocalAiModelInfo? model, {
    String? modelSlug,
    DateTime Function()? now,
  }) {
    return checkCapabilities(
      model: model,
      modelSlug: modelSlug ?? defaultPrimaryModelSlug,
      requiredCapabilities: primaryModelCapabilities,
      now: now,
    );
  }

  static ModelCapabilityCheck checkEmbeddingModel(
    LocalAiModelInfo? model, {
    DateTime Function()? now,
  }) {
    return checkCapabilities(
      model: model,
      modelSlug: model?.slug ?? defaultEmbeddingModelSlug,
      requiredCapabilities: embeddingModelCapabilities,
      now: now,
    );
  }

  static ModelCapabilityCheck checkCapabilities({
    required LocalAiModelInfo? model,
    required String modelSlug,
    required Set<AiModelCapability> requiredCapabilities,
    DateTime Function()? now,
  }) {
    final checkedAt = (now ?? DateTime.now)().toUtc();

    if (model == null) {
      return ModelCapabilityCheck(
        modelSlug: modelSlug,
        requiredCapabilities: requiredCapabilities,
        missingCapabilities: requiredCapabilities,
        checkedAt: checkedAt,
        isModelAvailable: false,
        isModelReady: false,
      );
    }

    return ModelCapabilityCheck(
      modelSlug: model.slug,
      requiredCapabilities: requiredCapabilities,
      missingCapabilities: requiredCapabilities.difference(model.capabilities),
      checkedAt: checkedAt,
      isModelReady: model.isDownloaded || model.isInitialized,
    );
  }
}
