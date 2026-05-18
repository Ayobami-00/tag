import 'package:equatable/equatable.dart';
import 'package:tag/core/ai/validation/ai_schema_validation_exception.dart';
import 'package:tag/core/local_storage/database/database_values.dart';

class ExtractionResult extends Equatable {
  const ExtractionResult({
    required this.text,
    required this.visibleEntities,
    required this.dates,
    required this.times,
    required this.links,
    required this.contentType,
    required this.language,
    required this.confidence,
    this.rawDates = const [],
    this.rawTimes = const [],
  });

  factory ExtractionResult.fromJson(Map<String, Object?> json) {
    final rawContentType = _requiredString(json, 'content_type');
    final contentType = _normalizedContentType(rawContentType);
    if (contentType == null) {
      throw AiSchemaValidationException(
        'Extraction content_type "$rawContentType" is not supported.',
      );
    }

    final confidence = _requiredConfidence(json, 'confidence');

    final dates = _stringList(json, 'dates');
    final times = _stringList(json, 'times');

    return ExtractionResult(
      text: _requiredString(json, 'text'),
      visibleEntities: _stringList(json, 'visible_entities'),
      dates: dates,
      times: times,
      links: _stringList(json, 'links'),
      contentType: contentType,
      language: _requiredString(json, 'language'),
      confidence: confidence,
      rawDates: dates,
      rawTimes: times,
    );
  }

  final String text;
  final List<String> visibleEntities;
  final List<String> dates;
  final List<String> times;
  final List<String> links;
  final String contentType;
  final String language;
  final double confidence;
  final List<String> rawDates;
  final List<String> rawTimes;

  ExtractionResult copyWith({
    String? text,
    List<String>? visibleEntities,
    List<String>? dates,
    List<String>? times,
    List<String>? links,
    String? contentType,
    String? language,
    double? confidence,
    List<String>? rawDates,
    List<String>? rawTimes,
  }) {
    return ExtractionResult(
      text: text ?? this.text,
      visibleEntities: visibleEntities ?? this.visibleEntities,
      dates: dates ?? this.dates,
      times: times ?? this.times,
      links: links ?? this.links,
      contentType: contentType ?? this.contentType,
      language: language ?? this.language,
      confidence: confidence ?? this.confidence,
      rawDates: rawDates ?? this.rawDates,
      rawTimes: rawTimes ?? this.rawTimes,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'text': text,
      'visible_entities': visibleEntities,
      'dates': dates,
      'times': times,
      'links': links,
      'content_type': contentType,
      'language': language,
      'confidence': confidence,
    };
  }

  @override
  List<Object?> get props => [
    text,
    visibleEntities,
    dates,
    times,
    links,
    contentType,
    language,
    confidence,
    rawDates,
    rawTimes,
  ];
}

String? _normalizedContentType(String value) {
  final normalized = value.trim().toLowerCase();
  if (TagDatabaseValues.contentTypes.contains(normalized)) {
    return normalized;
  }

  return switch (normalized) {
    'text' || 'note' || 'manual' || 'image' || 'screenshot' => 'unknown',
    'message | job_post | article | event | product | travel | unknown' =>
      'unknown',
    _ => null,
  };
}

String _requiredString(Map<String, Object?> json, String key) {
  if (!json.containsKey(key)) {
    throw AiSchemaValidationException('Extraction JSON is missing "$key".');
  }

  final value = json[key];
  if (value is! String) {
    throw AiSchemaValidationException(
      'Extraction field "$key" must be a string.',
    );
  }

  return value.trim();
}

List<String> _stringList(Map<String, Object?> json, String key) {
  if (!json.containsKey(key)) {
    return const [];
  }

  final value = json[key];
  if (value is! List) {
    throw AiSchemaValidationException(
      'Extraction field "$key" must be a list.',
    );
  }

  return value
      .map((item) {
        if (item is! String) {
          throw AiSchemaValidationException(
            'Extraction field "$key" must contain only strings.',
          );
        }
        return item.trim();
      })
      .where((item) => item.isNotEmpty)
      .toList(growable: false);
}

double _requiredConfidence(Map<String, Object?> json, String key) {
  if (!json.containsKey(key)) {
    throw AiSchemaValidationException('Extraction JSON is missing "$key".');
  }

  final value = json[key];
  final confidence = value is num ? value.toDouble() : null;
  if (confidence == null || confidence < 0 || confidence > 1) {
    throw AiSchemaValidationException(
      'Extraction field "$key" must be between 0 and 1.',
    );
  }

  return confidence;
}
