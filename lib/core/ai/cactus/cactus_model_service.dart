import 'package:equatable/equatable.dart';

enum AiModelCapability {
  completion,
  tools,
  vision,
  embedding,
  audio;

  String get storageValue => name;

  static AiModelCapability fromStorageValue(String value) {
    return AiModelCapability.values.firstWhere(
      (capability) => capability.storageValue == value,
      orElse: () => throw ArgumentError.value(
        value,
        'value',
        'Unknown AI model capability.',
      ),
    );
  }
}

enum AiModelDownloadStatus {
  notDownloaded,
  queued,
  downloading,
  downloaded,
  initializing,
  ready,
  initializationFailed,
  failed;

  String get storageValue {
    return switch (this) {
      AiModelDownloadStatus.notDownloaded => 'not_downloaded',
      AiModelDownloadStatus.queued => 'queued',
      AiModelDownloadStatus.downloading => 'downloading',
      AiModelDownloadStatus.downloaded => 'downloaded',
      AiModelDownloadStatus.initializing => 'initializing',
      AiModelDownloadStatus.ready => 'ready',
      AiModelDownloadStatus.initializationFailed => 'initialization_failed',
      AiModelDownloadStatus.failed => 'failed',
    };
  }

  bool get isActive {
    return switch (this) {
      AiModelDownloadStatus.queued ||
      AiModelDownloadStatus.downloading ||
      AiModelDownloadStatus.initializing => true,
      _ => false,
    };
  }

  static AiModelDownloadStatus fromStorageValue(String value) {
    return AiModelDownloadStatus.values.firstWhere(
      (status) => status.storageValue == value,
      orElse: () => AiModelDownloadStatus.notDownloaded,
    );
  }
}

class ModelDownloadProgress extends Equatable {
  const ModelDownloadProgress({
    required this.slug,
    this.progress,
    this.statusMessage = '',
    this.isError = false,
  });

  final String slug;
  final double? progress;
  final String statusMessage;
  final bool isError;

  @override
  List<Object?> get props => [slug, progress, statusMessage, isError];
}

class LocalAiModelInfo extends Equatable {
  const LocalAiModelInfo({
    required this.slug,
    required this.displayName,
    required this.capabilities,
    this.sizeMb,
    this.quantization,
    this.isDownloaded = false,
    this.isInitialized = false,
    this.localPath,
    this.lastCheckedAt,
    this.lastInitializedAt,
    this.failureReason,
    this.downloadStatus = AiModelDownloadStatus.notDownloaded,
    this.downloadProgress,
    this.downloadStatusMessage,
    this.downloadStartedAt,
    this.downloadCompletedAt,
  });

  final String slug;
  final String displayName;
  final Set<AiModelCapability> capabilities;
  final double? sizeMb;
  final String? quantization;
  final bool isDownloaded;
  final bool isInitialized;
  final String? localPath;
  final DateTime? lastCheckedAt;
  final DateTime? lastInitializedAt;
  final String? failureReason;
  final AiModelDownloadStatus downloadStatus;
  final double? downloadProgress;
  final String? downloadStatusMessage;
  final DateTime? downloadStartedAt;
  final DateTime? downloadCompletedAt;

  bool supports(AiModelCapability capability) {
    return capabilities.contains(capability);
  }

  LocalAiModelInfo copyWith({
    String? slug,
    String? displayName,
    Set<AiModelCapability>? capabilities,
    double? sizeMb,
    String? quantization,
    bool? isDownloaded,
    bool? isInitialized,
    String? localPath,
    DateTime? lastCheckedAt,
    DateTime? lastInitializedAt,
    String? failureReason,
    bool clearFailureReason = false,
    AiModelDownloadStatus? downloadStatus,
    double? downloadProgress,
    bool clearDownloadProgress = false,
    String? downloadStatusMessage,
    bool clearDownloadStatusMessage = false,
    DateTime? downloadStartedAt,
    bool clearDownloadStartedAt = false,
    DateTime? downloadCompletedAt,
    bool clearDownloadCompletedAt = false,
  }) {
    return LocalAiModelInfo(
      slug: slug ?? this.slug,
      displayName: displayName ?? this.displayName,
      capabilities: capabilities ?? this.capabilities,
      sizeMb: sizeMb ?? this.sizeMb,
      quantization: quantization ?? this.quantization,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      isInitialized: isInitialized ?? this.isInitialized,
      localPath: localPath ?? this.localPath,
      lastCheckedAt: lastCheckedAt ?? this.lastCheckedAt,
      lastInitializedAt: lastInitializedAt ?? this.lastInitializedAt,
      failureReason: clearFailureReason
          ? null
          : failureReason ?? this.failureReason,
      downloadStatus: downloadStatus ?? this.downloadStatus,
      downloadProgress: clearDownloadProgress
          ? null
          : downloadProgress ?? this.downloadProgress,
      downloadStatusMessage: clearDownloadStatusMessage
          ? null
          : downloadStatusMessage ?? this.downloadStatusMessage,
      downloadStartedAt: clearDownloadStartedAt
          ? null
          : downloadStartedAt ?? this.downloadStartedAt,
      downloadCompletedAt: clearDownloadCompletedAt
          ? null
          : downloadCompletedAt ?? this.downloadCompletedAt,
    );
  }

  @override
  List<Object?> get props => [
    slug,
    displayName,
    capabilities,
    sizeMb,
    quantization,
    isDownloaded,
    isInitialized,
    localPath,
    lastCheckedAt,
    lastInitializedAt,
    failureReason,
    downloadStatus,
    downloadProgress,
    downloadStatusMessage,
    downloadStartedAt,
    downloadCompletedAt,
  ];
}

class AiChatMessage extends Equatable {
  const AiChatMessage({
    required this.role,
    required this.content,
    this.timestamp,
    this.imagePaths = const [],
  });

  final String role;
  final String content;
  final DateTime? timestamp;
  final List<String> imagePaths;

  @override
  List<Object?> get props => [role, content, timestamp, imagePaths];
}

class AiToolSchema extends Equatable {
  const AiToolSchema({
    required this.name,
    required this.description,
    required this.parameters,
  });

  final String name;
  final String description;
  final Map<String, AiToolParameter> parameters;

  @override
  List<Object?> get props => [name, description, parameters];
}

class AiToolParameter extends Equatable {
  const AiToolParameter({
    required this.type,
    required this.description,
    this.isRequired = false,
  });

  final String type;
  final String description;
  final bool isRequired;

  @override
  List<Object?> get props => [type, description, isRequired];
}

class AiToolCall extends Equatable {
  const AiToolCall({required this.name, required this.arguments});

  final String name;
  final Map<String, String> arguments;

  @override
  List<Object?> get props => [name, arguments];
}

class AiCompletionOptions extends Equatable {
  const AiCompletionOptions({
    this.temperature,
    this.topK,
    this.topP,
    this.maxTokens = 200,
    this.stopSequences = const ['<|im_end|>', '<end_of_turn>'],
    this.forceTools,
    this.localOnly = true,
  });

  final double? temperature;
  final int? topK;
  final double? topP;
  final int maxTokens;
  final List<String> stopSequences;
  final bool? forceTools;
  final bool localOnly;

  @override
  List<Object?> get props => [
    temperature,
    topK,
    topP,
    maxTokens,
    stopSequences,
    forceTools,
    localOnly,
  ];
}

class AiCompletionResult extends Equatable {
  const AiCompletionResult({
    required this.response,
    this.toolCalls = const [],
    this.timeToFirstTokenMs = 0,
    this.totalTimeMs = 0,
    this.tokensPerSecond = 0,
    this.prefillTokens = 0,
    this.decodeTokens = 0,
    this.totalTokens = 0,
    this.rawResult,
  });

  final String response;
  final List<AiToolCall> toolCalls;
  final double timeToFirstTokenMs;
  final double totalTimeMs;
  final double tokensPerSecond;
  final int prefillTokens;
  final int decodeTokens;
  final int totalTokens;
  final Object? rawResult;

  @override
  List<Object?> get props => [
    response,
    toolCalls,
    timeToFirstTokenMs,
    totalTimeMs,
    tokensPerSecond,
    prefillTokens,
    decodeTokens,
    totalTokens,
    rawResult,
  ];
}

class AiEmbeddingResult extends Equatable {
  const AiEmbeddingResult({
    required this.modelSlug,
    required this.embeddings,
    required this.dimension,
  });

  final String modelSlug;
  final List<double> embeddings;
  final int dimension;

  @override
  List<Object?> get props => [modelSlug, embeddings, dimension];
}

class AiVisionResult extends AiCompletionResult {
  const AiVisionResult({
    required super.response,
    super.toolCalls,
    super.timeToFirstTokenMs,
    super.totalTimeMs,
    super.tokensPerSecond,
    super.prefillTokens,
    super.decodeTokens,
    super.totalTokens,
    super.rawResult,
  });
}

abstract interface class CactusModelService {
  Future<List<LocalAiModelInfo>> getAvailableModels();

  Future<void> downloadModel(
    String slug, {
    void Function(ModelDownloadProgress progress)? onProgress,
  });

  Future<void> initializeModel(String slug);

  Future<void> unloadModel(String slug);

  Future<AiCompletionResult> complete({
    required String modelSlug,
    required List<AiChatMessage> messages,
    List<AiToolSchema> tools = const [],
    AiCompletionOptions options = const AiCompletionOptions(),
  });

  Stream<String> streamComplete({
    required String modelSlug,
    required List<AiChatMessage> messages,
    List<AiToolSchema> tools = const [],
    AiCompletionOptions options = const AiCompletionOptions(),
  });

  Future<AiEmbeddingResult> embedText({
    required String modelSlug,
    required String text,
  });

  Future<AiVisionResult> completeWithImage({
    required String modelSlug,
    required String imagePath,
    required List<AiChatMessage> messages,
    List<AiToolSchema> tools = const [],
    AiCompletionOptions options = const AiCompletionOptions(),
  });
}
