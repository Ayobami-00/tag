import 'package:flutter/services.dart';

class LocalRecognizedText {
  const LocalRecognizedText({
    required this.text,
    this.lines = const [],
    this.confidence,
  });

  factory LocalRecognizedText.fromMap(Map<Object?, Object?> map) {
    final rawLines = map['lines'];
    final lines = rawLines is List
        ? rawLines
              .whereType<String>()
              .map((line) => line.trim())
              .where((line) => line.isNotEmpty)
              .toList(growable: false)
        : const <String>[];
    final text = (map['text'] as String?)?.trim();
    final confidence = map['confidence'];

    return LocalRecognizedText(
      text: text?.isNotEmpty == true ? text! : lines.join('\n'),
      lines: lines,
      confidence: confidence is num ? confidence.toDouble() : null,
    );
  }

  static const empty = LocalRecognizedText(text: '');

  final String text;
  final List<String> lines;
  final double? confidence;

  bool get isEmpty => text.trim().isEmpty;
}

abstract class LocalTextRecognitionService {
  const LocalTextRecognitionService();

  Future<LocalRecognizedText> recognizeTextFromImage(String imagePath);
}

class MethodChannelLocalTextRecognitionService
    implements LocalTextRecognitionService {
  const MethodChannelLocalTextRecognitionService({
    MethodChannel channel = const MethodChannel('tag/local_text_recognition'),
  }) : _channel = channel;

  final MethodChannel _channel;

  @override
  Future<LocalRecognizedText> recognizeTextFromImage(String imagePath) async {
    final path = imagePath.trim();
    if (path.isEmpty) {
      return LocalRecognizedText.empty;
    }

    try {
      final result = await _channel.invokeMapMethod<Object?, Object?>(
        'recognizeTextFromImage',
        {'imagePath': path},
      );
      if (result == null) {
        return LocalRecognizedText.empty;
      }

      return LocalRecognizedText.fromMap(result);
    } on MissingPluginException {
      return LocalRecognizedText.empty;
    } on PlatformException {
      return LocalRecognizedText.empty;
    }
  }
}
