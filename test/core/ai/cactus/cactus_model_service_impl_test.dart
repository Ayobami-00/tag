import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:tag/core/ai/cactus/cactus_model_registry.dart';
import 'package:tag/core/ai/cactus/cactus_model_service.dart';
import 'package:tag/core/ai/cactus/cactus_model_service_impl.dart';
import 'package:tag/core/ai/cactus/cactus_v114_runtime.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('completeWithImage adds the LFM vision token and image path', () async {
    final runtime = _FakeCactusV114Runtime();
    final service = CactusModelServiceImpl(runtime: runtime);
    final directory = await Directory.systemTemp.createTemp('tag_vision_test');
    addTearDown(() => directory.delete(recursive: true));
    final imageFile = File('${directory.path}/source.jpg');
    await imageFile.writeAsBytes([1, 2, 3]);

    await service.completeWithImage(
      modelSlug: CactusModelRegistry.primaryVisionToolModelSlug,
      imagePath: imageFile.path,
      messages: const [
        AiChatMessage(role: 'system', content: 'System prompt'),
        AiChatMessage(role: 'user', content: 'Extract this image.'),
      ],
    );

    final userMessage = runtime.capturedMessages.last;
    expect(userMessage.content, startsWith('<image>\n'));
    expect(userMessage.imagePaths, [imageFile.path]);
  });

  test(
    'completeWithImage prepares LFM images for fixed CoreML shape',
    () async {
      final runtime = _FakeCactusV114Runtime();
      final service = CactusModelServiceImpl(runtime: runtime);
      final directory = await Directory.systemTemp.createTemp(
        'tag_vision_test',
      );
      addTearDown(() => directory.delete(recursive: true));
      final imageFile = await _writePngImage(
        directory: directory,
        name: 'source',
        width: 640,
        height: 480,
      );

      await service.completeWithImage(
        modelSlug: CactusModelRegistry.primaryVisionToolModelSlug,
        imagePath: imageFile.path,
        messages: const [
          AiChatMessage(role: 'user', content: 'Extract this image.'),
        ],
      );

      final imagePath = runtime.capturedMessages.last.imagePaths.single;
      expect(imagePath, isNot(imageFile.path));
      expect(imagePath, contains('_256x256.png'));
    },
  );
}

Future<File> _writePngImage({
  required Directory directory,
  required String name,
  required int width,
  required int height,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);
  final paint = ui.Paint()..color = const ui.Color(0xFFFFFFFF);
  canvas.drawRect(
    ui.Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
    paint,
  );
  paint.color = const ui.Color(0xFF2F5D62);
  canvas.drawCircle(
    ui.Offset(width * 0.5, height * 0.5),
    width < height ? width * 0.25 : height * 0.25,
    paint,
  );

  final picture = recorder.endRecording();
  final image = await picture.toImage(width, height);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  picture.dispose();

  final file = File('${directory.path}/$name.png');
  await file.writeAsBytes(byteData!.buffer.asUint8List(), flush: true);
  return file;
}

class _FakeCactusV114Runtime implements CactusV114Runtime {
  List<AiChatMessage> capturedMessages = const [];

  @override
  Future<AiCompletionResult> complete({
    required String modelSlug,
    required List<AiChatMessage> messages,
    required List<AiToolSchema> tools,
    required AiCompletionOptions options,
    void Function(String token)? onToken,
  }) async {
    capturedMessages = messages;
    return const AiCompletionResult(response: '{}');
  }

  @override
  Future<AiEmbeddingResult> embedText({
    required String modelSlug,
    required String text,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> initializeModel({
    required String slug,
    required String modelPath,
  }) async {}

  @override
  bool isInitialized(String slug) => true;

  @override
  Future<void> unloadModel(String slug) async {}
}
