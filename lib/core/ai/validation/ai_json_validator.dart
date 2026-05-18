import 'dart:convert';

import 'package:tag/core/ai/validation/ai_schema_validation_exception.dart';

typedef AiJsonDecoder<T> = T Function(Map<String, Object?> json);

class AiJsonValidator {
  const AiJsonValidator();

  T parseObject<T>({
    required String rawOutput,
    required AiJsonDecoder<T> decoder,
  }) {
    final json = extractObject(rawOutput);
    return decoder(json);
  }

  Map<String, Object?> extractObject(String rawOutput) {
    final trimmed = rawOutput.trim();
    if (trimmed.isEmpty) {
      throw const AiSchemaValidationException('Model returned an empty value.');
    }

    final withoutFence = _stripCodeFence(trimmed);
    final directlyDecoded = _tryDecodeObject(withoutFence);
    if (directlyDecoded != null) {
      return directlyDecoded;
    }

    final objectText = _firstJsonObject(withoutFence);
    if (objectText == null) {
      throw const AiSchemaValidationException(
        'Model output did not contain a JSON object.',
      );
    }

    final decoded = _tryDecodeObject(objectText);
    if (decoded == null) {
      throw const AiSchemaValidationException(
        'Model output contained malformed JSON.',
      );
    }

    return decoded;
  }

  String _stripCodeFence(String value) {
    if (!value.startsWith('```')) {
      return value;
    }

    final firstNewline = value.indexOf('\n');
    if (firstNewline == -1) {
      return value;
    }

    final closingFence = value.lastIndexOf('```');
    if (closingFence <= firstNewline) {
      return value.substring(firstNewline + 1).trim();
    }

    return value.substring(firstNewline + 1, closingFence).trim();
  }

  Map<String, Object?>? _tryDecodeObject(String value) {
    try {
      final decoded = jsonDecode(value);
      if (decoded is Map<String, dynamic>) {
        return Map<String, Object?>.from(decoded);
      }
      if (decoded is Map) {
        return decoded.map((key, value) {
          return MapEntry(key.toString(), value);
        });
      }
    } on FormatException {
      return null;
    }

    return null;
  }

  String? _firstJsonObject(String value) {
    var depth = 0;
    var inString = false;
    var isEscaped = false;
    int? startIndex;

    for (var index = 0; index < value.length; index++) {
      final char = value[index];

      if (inString) {
        if (isEscaped) {
          isEscaped = false;
        } else if (char == '\\') {
          isEscaped = true;
        } else if (char == '"') {
          inString = false;
        }
        continue;
      }

      if (char == '"') {
        inString = true;
        continue;
      }

      if (char == '{') {
        startIndex ??= index;
        depth++;
      } else if (char == '}') {
        if (depth == 0) {
          continue;
        }
        depth--;
        if (depth == 0 && startIndex != null) {
          return value.substring(startIndex, index + 1);
        }
      }
    }

    return null;
  }
}
