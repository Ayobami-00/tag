import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:path/path.dart' as p;
import 'package:tag/core/ai/cactus/cactus_direct_model_downloader.dart';
import 'package:tag/core/ai/cactus/cactus_model_registry.dart';
import 'package:tag/core/ai/cactus/cactus_model_service.dart';
import 'package:tag/core/ai/cactus/cactus_v114_runtime.dart';
import 'package:tag/core/error/app_error.dart';

class CactusModelServiceImpl implements CactusModelService {
  CactusModelServiceImpl({
    CactusV114Runtime? runtime,
    CactusDirectModelDownloader directModelDownloader =
        const CactusDirectModelDownloader(),
  }) : _runtime = runtime ?? CactusV114Runtime(),
       _directModelDownloader = directModelDownloader;

  final CactusV114Runtime _runtime;
  final CactusDirectModelDownloader _directModelDownloader;
  static const _visionImageToken = '<image>';
  static const _visionMaxImageDimension = 512;
  // LFM Apple INT4 CoreML vision models accept exactly 256 patch states.
  static const _lfmVisionImageSize = 256;

  static void configureLocalOnly() {}

  @override
  Future<List<LocalAiModelInfo>> getAvailableModels() async {
    final checkedAt = DateTime.now().toUtc();
    final models = <LocalAiModelInfo>[];

    for (final target in CactusModelRegistry.requiredModelTargets) {
      final isDownloaded = await _directModelDownloader.hasModelFilesForSlug(
        target.slug,
      );
      final localPath = isDownloaded
          ? await _directModelDownloader.modelPathForSlug(target.slug)
          : null;
      final isInitialized = _runtime.isInitialized(target.slug);

      models.add(
        target.copyWith(
          isDownloaded: isDownloaded,
          isInitialized: isInitialized,
          localPath: localPath,
          lastCheckedAt: checkedAt,
          downloadStatus: isInitialized
              ? AiModelDownloadStatus.ready
              : isDownloaded
              ? AiModelDownloadStatus.downloaded
              : AiModelDownloadStatus.notDownloaded,
          downloadProgress: isDownloaded ? 1 : null,
          clearDownloadProgress: !isDownloaded,
          clearFailureReason: isDownloaded,
          downloadStatusMessage: isDownloaded
              ? '${target.displayName} is available locally.'
              : _downloadPromptFor(target.slug),
        ),
      );
    }

    return models;
  }

  @override
  Future<void> downloadModel(
    String slug, {
    void Function(ModelDownloadProgress progress)? onProgress,
  }) async {
    final directDownloadAsset = CactusModelRegistry.directDownloadAssetForSlug(
      slug,
    );
    if (directDownloadAsset == null) {
      throw AppError('Cactus v1.14 does not have a local asset for $slug.');
    }

    await _directModelDownloader.download(
      directDownloadAsset,
      onProgress: onProgress,
    );
  }

  @override
  Future<void> initializeModel(String slug) async {
    final modelPath = await _localModelPath(slug);
    await _runtime.initializeModel(slug: slug, modelPath: modelPath);
  }

  @override
  Future<void> unloadModel(String slug) {
    return _runtime.unloadModel(slug);
  }

  @override
  Future<AiCompletionResult> complete({
    required String modelSlug,
    required List<AiChatMessage> messages,
    List<AiToolSchema> tools = const [],
    AiCompletionOptions options = const AiCompletionOptions(),
  }) async {
    _ensureLocalOnly(options);
    await _ensureInitialized(modelSlug);

    try {
      return await _runtime.complete(
        modelSlug: modelSlug,
        messages: messages,
        tools: tools,
        options: options,
      );
    } on AppError {
      rethrow;
    } on Object catch (error) {
      throw AppError('Local Cactus v1.14 completion failed.', cause: error);
    }
  }

  @override
  Stream<String> streamComplete({
    required String modelSlug,
    required List<AiChatMessage> messages,
    List<AiToolSchema> tools = const [],
    AiCompletionOptions options = const AiCompletionOptions(),
  }) async* {
    _ensureLocalOnly(options);
    await _ensureInitialized(modelSlug);

    final controller = StreamController<String>();
    unawaited(
      _runtime
          .complete(
            modelSlug: modelSlug,
            messages: messages,
            tools: tools,
            options: options,
            onToken: controller.add,
          )
          .then((_) => controller.close())
          .catchError((Object error, StackTrace stackTrace) {
            controller.addError(
              AppError(
                'Local Cactus v1.14 streaming completion failed.',
                cause: error,
              ),
              stackTrace,
            );
            return controller.close();
          }),
    );

    yield* controller.stream;
  }

  @override
  Future<AiEmbeddingResult> embedText({
    required String modelSlug,
    required String text,
  }) async {
    await _ensureInitialized(modelSlug);

    try {
      return await _runtime.embedText(modelSlug: modelSlug, text: text);
    } on AppError {
      rethrow;
    } on Object catch (error) {
      throw AppError('Local Cactus v1.14 embedding failed.', cause: error);
    }
  }

  @override
  Future<AiVisionResult> completeWithImage({
    required String modelSlug,
    required String imagePath,
    required List<AiChatMessage> messages,
    List<AiToolSchema> tools = const [],
    AiCompletionOptions options = const AiCompletionOptions(),
  }) async {
    _ensureLocalOnly(options);
    final preparedImagePath = await _prepareVisionImage(
      modelSlug: modelSlug,
      imagePath: imagePath,
    );

    final completion = await complete(
      modelSlug: modelSlug,
      messages: _withImageOnLastUserMessage(messages, preparedImagePath),
      tools: tools,
      options: options,
    );

    return AiVisionResult(
      response: completion.response,
      toolCalls: completion.toolCalls,
      timeToFirstTokenMs: completion.timeToFirstTokenMs,
      totalTimeMs: completion.totalTimeMs,
      tokensPerSecond: completion.tokensPerSecond,
      prefillTokens: completion.prefillTokens,
      decodeTokens: completion.decodeTokens,
      totalTokens: completion.totalTokens,
      rawResult: completion.rawResult,
    );
  }

  Future<String> _prepareVisionImage({
    required String modelSlug,
    required String imagePath,
  }) async {
    try {
      final sourceFile = File(imagePath);
      final bytes = await sourceFile.readAsBytes();
      final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
      ui.ImageDescriptor? descriptor;
      ui.Codec? codec;
      ui.FrameInfo? frame;
      ui.Picture? picture;
      ui.Image? resizedImage;

      try {
        descriptor = await ui.ImageDescriptor.encoded(buffer);
        final targetSize = _visionTargetSize(
          modelSlug: modelSlug,
          width: descriptor.width,
          height: descriptor.height,
        );
        if (targetSize.width == descriptor.width &&
            targetSize.height == descriptor.height &&
            _isRuntimeFriendlyImage(sourceFile.path)) {
          return imagePath;
        }

        final outputFile = await _visionImageCacheFile(
          sourceFile: sourceFile,
          cacheVariant: _visionCacheVariant(modelSlug),
          targetWidth: targetSize.width,
          targetHeight: targetSize.height,
        );
        if (await outputFile.exists()) {
          return outputFile.path;
        }

        if (_usesLfmVisionCrop(modelSlug)) {
          codec = await descriptor.instantiateCodec();
          frame = await codec.getNextFrame();
          final recorder = ui.PictureRecorder();
          final canvas = ui.Canvas(recorder);
          final destinationRect = ui.Rect.fromLTWH(
            0,
            0,
            targetSize.width.toDouble(),
            targetSize.height.toDouble(),
          );
          canvas.drawColor(const ui.Color(0xFFFFFFFF), ui.BlendMode.src);
          canvas.drawImageRect(
            frame.image,
            _lfmVisionSourceRect(
              width: frame.image.width,
              height: frame.image.height,
            ),
            destinationRect,
            ui.Paint()..filterQuality = ui.FilterQuality.high,
          );
          picture = recorder.endRecording();
          resizedImage = await picture.toImage(
            targetSize.width,
            targetSize.height,
          );
        } else {
          codec = await descriptor.instantiateCodec(
            targetWidth: targetSize.width,
            targetHeight: targetSize.height,
          );
          frame = await codec.getNextFrame();
          resizedImage = frame.image;
        }
        final pngBytes = await resizedImage.toByteData(
          format: ui.ImageByteFormat.png,
        );
        if (pngBytes == null) {
          return imagePath;
        }

        await outputFile.parent.create(recursive: true);
        await outputFile.writeAsBytes(
          pngBytes.buffer.asUint8List(),
          flush: true,
        );
        return outputFile.path;
      } finally {
        if (resizedImage != frame?.image) {
          resizedImage?.dispose();
        }
        picture?.dispose();
        frame?.image.dispose();
        codec?.dispose();
        descriptor?.dispose();
        buffer.dispose();
      }
    } on Object {
      return imagePath;
    }
  }

  ({int width, int height}) _visionTargetSize({
    required String modelSlug,
    required int width,
    required int height,
  }) {
    if (modelSlug == CactusModelRegistry.compactVisionModelSlug) {
      return _lfmVisionTargetSize();
    }

    final maxSide = width > height ? width : height;
    if (maxSide <= _visionMaxImageDimension) {
      return (width: width, height: height);
    }

    final scale = _visionMaxImageDimension / maxSide;
    return (
      width: (width * scale).round().clamp(1, _visionMaxImageDimension).toInt(),
      height: (height * scale)
          .round()
          .clamp(1, _visionMaxImageDimension)
          .toInt(),
    );
  }

  ({int width, int height}) _lfmVisionTargetSize() {
    return (width: _lfmVisionImageSize, height: _lfmVisionImageSize);
  }

  bool _usesLfmVisionCrop(String modelSlug) {
    return modelSlug == CactusModelRegistry.compactVisionModelSlug;
  }

  ui.Rect _lfmVisionSourceRect({required int width, required int height}) {
    if (width == height) {
      return ui.Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble());
    }
    if (height > width) {
      return ui.Rect.fromLTWH(0, 0, width.toDouble(), width.toDouble());
    }

    return ui.Rect.fromLTWH(0, 0, height.toDouble(), height.toDouble());
  }

  bool _isRuntimeFriendlyImage(String path) {
    final extension = p.extension(path).toLowerCase();
    return extension == '.png' || extension == '.jpg' || extension == '.jpeg';
  }

  Future<File> _visionImageCacheFile({
    required File sourceFile,
    required String cacheVariant,
    required int targetWidth,
    required int targetHeight,
  }) async {
    final stat = await sourceFile.stat();
    final sourceName = p.basenameWithoutExtension(sourceFile.path);
    final cacheName =
        '${sourceName}_${cacheVariant}_${stat.modified.millisecondsSinceEpoch}_'
        '${targetWidth}x$targetHeight.png';
    return File(
      p.join(Directory.systemTemp.path, 'tag_cactus_images', cacheName),
    );
  }

  String _visionCacheVariant(String modelSlug) {
    if (_usesLfmVisionCrop(modelSlug)) {
      return 'lfm_top_left_square_crop';
    }

    return 'resize';
  }

  Future<void> _ensureInitialized(String slug) async {
    if (_runtime.isInitialized(slug)) {
      return;
    }

    await initializeModel(slug);
  }

  Future<String> _localModelPath(String slug) async {
    final modelPath = await _directModelDownloader.modelPathForSlug(slug);
    final isDownloaded = await _directModelDownloader.hasModelFilesForSlug(
      slug,
    );
    if (!isDownloaded) {
      throw AppError('$slug is not downloaded locally.');
    }

    return modelPath;
  }

  String _downloadPromptFor(String slug) {
    final asset = CactusModelRegistry.directDownloadAssetForSlug(slug);
    if (asset == null) {
      return '$slug is not configured as a local Cactus v1.14 asset.';
    }

    return 'Available from ${asset.sourceLabel}.';
  }

  List<AiChatMessage> _withImageOnLastUserMessage(
    List<AiChatMessage> messages,
    String imagePath,
  ) {
    if (messages.isEmpty) {
      return [
        AiChatMessage(
          role: 'user',
          content: '$_visionImageToken\nReview this saved image.',
          imagePaths: [imagePath],
        ),
      ];
    }

    final updatedMessages = [...messages];
    final index = updatedMessages.lastIndexWhere(
      (message) => message.role == 'user',
    );
    final targetIndex = index == -1 ? updatedMessages.length - 1 : index;
    final target = updatedMessages[targetIndex];

    updatedMessages[targetIndex] = AiChatMessage(
      role: target.role,
      content: _withVisionImageToken(target.content),
      timestamp: target.timestamp,
      imagePaths: {...target.imagePaths, imagePath}.toList(growable: false),
    );

    return updatedMessages;
  }

  String _withVisionImageToken(String content) {
    if (content.contains(_visionImageToken)) {
      return content;
    }

    return '$_visionImageToken\n$content';
  }

  void _ensureLocalOnly(AiCompletionOptions options) {
    if (!options.localOnly) {
      throw UnsupportedError(
        'Hybrid Cactus completion is disabled in Tag MVP.',
      );
    }
  }
}
