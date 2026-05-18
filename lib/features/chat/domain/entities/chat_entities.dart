import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:tag/core/ai/rag/rag_models.dart';

enum ChatPurpose {
  general('general', 'Ask Tag'),
  planSuggestion('plan_suggestion', 'Plan this'),
  editCard('edit_card', 'Edit card'),
  editSpace('edit_space', 'Edit Space'),
  editGoal('edit_goal', 'Edit goal'),
  manualCard('manual_card', 'Manual card');

  const ChatPurpose(this.storageValue, this.label);

  final String storageValue;
  final String label;

  static ChatPurpose fromStorageValue(String value) {
    return ChatPurpose.values.firstWhere(
      (purpose) => purpose.storageValue == value,
      orElse: () => ChatPurpose.general,
    );
  }
}

enum ChatStatus {
  active('active'),
  completed('completed'),
  archived('archived');

  const ChatStatus(this.storageValue);

  final String storageValue;

  static ChatStatus fromStorageValue(String value) {
    return ChatStatus.values.firstWhere(
      (status) => status.storageValue == value,
      orElse: () => ChatStatus.active,
    );
  }
}

enum ChatMessageRole {
  user('user'),
  assistant('assistant'),
  system('system'),
  tool('tool');

  const ChatMessageRole(this.storageValue);

  final String storageValue;

  static ChatMessageRole fromStorageValue(String value) {
    return ChatMessageRole.values.firstWhere(
      (role) => role.storageValue == value,
      orElse: () => ChatMessageRole.assistant,
    );
  }
}

class ChatSessionEntity extends Equatable {
  const ChatSessionEntity({
    required this.id,
    required this.title,
    required this.purpose,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.linkedCardId,
    this.linkedSpaceId,
    this.linkedGoalPlanId,
    this.pendingConfirmationJson,
    this.archivedAt,
  });

  final String id;
  final String title;
  final ChatPurpose purpose;
  final String? linkedCardId;
  final String? linkedSpaceId;
  final String? linkedGoalPlanId;
  final ChatStatus status;
  final String? pendingConfirmationJson;
  final int createdAt;
  final int updatedAt;
  final int? archivedAt;

  @override
  List<Object?> get props => [
    id,
    title,
    purpose,
    linkedCardId,
    linkedSpaceId,
    linkedGoalPlanId,
    status,
    pendingConfirmationJson,
    createdAt,
    updatedAt,
    archivedAt,
  ];
}

class ChatMessageEntity extends Equatable {
  const ChatMessageEntity({
    required this.id,
    required this.chatSessionId,
    required this.role,
    required this.content,
    required this.sourceIds,
    required this.cardIds,
    required this.createdAt,
    this.contentJson,
    this.toolCallsJson,
    this.modelSlug,
  });

  final String id;
  final String chatSessionId;
  final ChatMessageRole role;
  final String content;
  final String? contentJson;
  final String? toolCallsJson;
  final List<String> sourceIds;
  final List<String> cardIds;
  final String? modelSlug;
  final int createdAt;

  ChatAnswerEntity? get structuredAnswer {
    if (contentJson == null || contentJson!.trim().isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(contentJson!);
      if (decoded is Map<String, dynamic>) {
        return ChatAnswerEntity.fromJson(decoded);
      }
      if (decoded is Map) {
        return ChatAnswerEntity.fromJson(
          decoded.map((key, value) => MapEntry(key.toString(), value)),
        );
      }
    } on FormatException {
      return null;
    }

    return null;
  }

  List<ChatSourceCitationEntity> get sourceCitations {
    final answer = structuredAnswer;
    if (answer != null && answer.sourceCitations.isNotEmpty) {
      return answer.sourceCitations;
    }

    return sourceIds
        .map(
          (sourceId) =>
              ChatSourceCitationEntity(sourceId: sourceId, label: sourceId),
        )
        .toList(growable: false);
  }

  @override
  List<Object?> get props => [
    id,
    chatSessionId,
    role,
    content,
    contentJson,
    toolCallsJson,
    sourceIds,
    cardIds,
    modelSlug,
    createdAt,
  ];
}

class ChatMessageDraft extends Equatable {
  const ChatMessageDraft({
    required this.chatSessionId,
    required this.role,
    required this.content,
    this.contentJson,
    this.toolCallsJson,
    this.sourceIds = const [],
    this.cardIds = const [],
    this.modelSlug,
  });

  final String chatSessionId;
  final ChatMessageRole role;
  final String content;
  final String? contentJson;
  final String? toolCallsJson;
  final List<String> sourceIds;
  final List<String> cardIds;
  final String? modelSlug;

  @override
  List<Object?> get props => [
    chatSessionId,
    role,
    content,
    contentJson,
    toolCallsJson,
    sourceIds,
    cardIds,
    modelSlug,
  ];
}

class ChatSourceCitationEntity extends Equatable {
  const ChatSourceCitationEntity({
    required this.sourceId,
    required this.label,
    this.cardId,
    this.cardTitle,
    this.spaceName,
    this.evidencePreview,
  });

  final String sourceId;
  final String label;
  final String? cardId;
  final String? cardTitle;
  final String? spaceName;
  final String? evidencePreview;

  Map<String, Object?> toJson() {
    return {
      'source_id': sourceId,
      'label': label,
      if (cardId != null) 'card_id': cardId,
      if (cardTitle != null) 'card_title': cardTitle,
      if (spaceName != null) 'space_name': spaceName,
      if (evidencePreview != null) 'evidence_preview': evidencePreview,
    };
  }

  factory ChatSourceCitationEntity.fromJson(Map<String, Object?> json) {
    return ChatSourceCitationEntity(
      sourceId: _stringValue(json['source_id'] ?? json['sourceId']),
      label: _stringValue(json['label']).isEmpty
          ? _stringValue(json['source_id'] ?? json['sourceId'])
          : _stringValue(json['label']),
      cardId: _nullableString(json['card_id'] ?? json['cardId']),
      cardTitle: _nullableString(json['card_title'] ?? json['cardTitle']),
      spaceName: _nullableString(json['space_name'] ?? json['spaceName']),
      evidencePreview: _nullableString(
        json['evidence_preview'] ?? json['evidencePreview'],
      ),
    );
  }

  static ChatSourceCitationEntity fromRagResult(LocalRagSearchResult result) {
    final relatedCard = result.relatedCards.isEmpty
        ? null
        : result.relatedCards.first;
    final label = relatedCard?.title ?? result.source.displaySummary;

    return ChatSourceCitationEntity(
      sourceId: result.source.id,
      label: label,
      cardId: relatedCard?.cardId,
      cardTitle: relatedCard?.title,
      spaceName: relatedCard?.spaceName,
      evidencePreview: result.chunk.preview,
    );
  }

  @override
  List<Object?> get props => [
    sourceId,
    label,
    cardId,
    cardTitle,
    spaceName,
    evidencePreview,
  ];
}

class ChatOptionalActionPreviewEntity extends Equatable {
  const ChatOptionalActionPreviewEntity({
    required this.type,
    required this.label,
    this.preview = const {},
  });

  final String type;
  final String label;
  final Map<String, Object?> preview;

  Map<String, Object?> toJson() {
    return {'type': type, 'label': label, 'preview': preview};
  }

  factory ChatOptionalActionPreviewEntity.fromJson(Map<String, Object?> json) {
    return ChatOptionalActionPreviewEntity(
      type: _stringValue(json['type']),
      label: _stringValue(json['label']),
      preview: _mapValue(json['preview']),
    );
  }

  @override
  List<Object?> get props => [type, label, preview];
}

class ChatAnswerEntity extends Equatable {
  const ChatAnswerEntity({
    required this.answer,
    required this.reasoningSummary,
    this.sourceCitations = const [],
    this.sourceIds = const [],
    this.cardIds = const [],
    this.optionalAction,
  });

  final String answer;
  final String reasoningSummary;
  final List<ChatSourceCitationEntity> sourceCitations;
  final List<String> sourceIds;
  final List<String> cardIds;
  final ChatOptionalActionPreviewEntity? optionalAction;

  bool get hasOptionalAction => optionalAction != null;

  Map<String, Object?> toJson() {
    return {
      'answer': answer,
      'reasoning_summary': reasoningSummary,
      'source_ids': sourceIds,
      'card_ids': cardIds,
      'source_citations': sourceCitations
          .map((citation) => citation.toJson())
          .toList(growable: false),
      if (optionalAction != null) 'optional_action': optionalAction!.toJson(),
    };
  }

  factory ChatAnswerEntity.fromJson(Map<String, Object?> json) {
    final sourceCitations = _listValue(json['source_citations'])
        .whereType<Map>()
        .map((value) {
          return ChatSourceCitationEntity.fromJson(
            value.map((key, value) => MapEntry(key.toString(), value)),
          );
        })
        .where((citation) => citation.sourceId.isNotEmpty)
        .toList(growable: false);
    final sourceIds = _stringListValue(json['source_ids']);
    final directCardIds = _stringListValue(json['card_ids']);
    final sourceCardIds = _sourceCardIds(json['source_cards']);

    return ChatAnswerEntity(
      answer: _stringValue(json['answer']).trim(),
      reasoningSummary: _stringValue(json['reasoning_summary']).trim(),
      sourceCitations: sourceCitations,
      sourceIds: _uniqueStrings([
        ...sourceIds,
        ...sourceCitations.map((citation) => citation.sourceId),
      ]),
      cardIds: _uniqueStrings([
        ...directCardIds,
        ...sourceCardIds,
        ...sourceCitations
            .map((citation) => citation.cardId)
            .whereType<String>(),
      ]),
      optionalAction: json['optional_action'] is Map
          ? ChatOptionalActionPreviewEntity.fromJson(
              (json['optional_action']! as Map).map(
                (key, value) => MapEntry(key.toString(), value),
              ),
            )
          : null,
    );
  }

  ChatAnswerEntity groundedBy(List<LocalRagSearchResult> contextResults) {
    final resultBySourceId = {
      for (final result in contextResults) result.source.id: result,
    };
    final allowedCardIds = {
      for (final result in contextResults)
        for (final card in result.relatedCards) card.cardId,
    };

    var groundedSourceIds = sourceIds
        .where(resultBySourceId.containsKey)
        .toList(growable: false);

    final groundedCitations = groundedSourceIds
        .map(
          (sourceId) => ChatSourceCitationEntity.fromRagResult(
            resultBySourceId[sourceId]!,
          ),
        )
        .toList(growable: false);
    final groundedCardIds = _uniqueStrings([
      ...cardIds.where(allowedCardIds.contains),
      ...groundedCitations
          .map((citation) => citation.cardId)
          .whereType<String>(),
    ]);

    return ChatAnswerEntity(
      answer: answer,
      reasoningSummary: reasoningSummary,
      sourceCitations: groundedCitations,
      sourceIds: groundedSourceIds,
      cardIds: groundedCardIds,
      optionalAction: optionalAction,
    );
  }

  @override
  List<Object?> get props => [
    answer,
    reasoningSummary,
    sourceCitations,
    sourceIds,
    cardIds,
    optionalAction,
  ];
}

List<String> _sourceCardIds(Object? value) {
  return _listValue(value)
      .map((item) {
        if (item is String) {
          return item;
        }
        if (item is Map) {
          return _stringValue(item['card_id'] ?? item['cardId']);
        }
        return '';
      })
      .where((value) => value.trim().isNotEmpty)
      .toList(growable: false);
}

List<String> _stringListValue(Object? value) {
  return _listValue(value)
      .map(_stringValue)
      .where((value) => value.trim().isNotEmpty)
      .toList(growable: false);
}

List<Object?> _listValue(Object? value) {
  if (value is List) {
    return value;
  }

  return const [];
}

Map<String, Object?> _mapValue(Object? value) {
  if (value is Map<String, Object?>) {
    return value;
  }
  if (value is Map) {
    return value.map((key, value) => MapEntry(key.toString(), value));
  }

  return const {};
}

List<String> _uniqueStrings(Iterable<String> values) {
  final seen = <String>{};
  return [
    for (final value in values)
      if (value.trim().isNotEmpty && seen.add(value.trim())) value.trim(),
  ];
}

String? _nullableString(Object? value) {
  final string = _stringValue(value).trim();
  return string.isEmpty ? null : string;
}

String _stringValue(Object? value) {
  return value == null ? '' : value.toString();
}
