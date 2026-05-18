import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:tag/core/local_storage/database/tag_database.dart'
    as database_models;
import 'package:tag/features/chat/data/data_sources/chat_local_data_source.dart';
import 'package:tag/features/chat/domain/entities/chat_entities.dart';
import 'package:tag/features/chat/domain/repositories/chat_repository.dart';
import 'package:uuid/uuid.dart';

class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl({
    required ChatLocalDataSource localDataSource,
    DateTime Function()? now,
    Uuid? uuid,
  }) : _localDataSource = localDataSource,
       _now = now ?? DateTime.now,
       _uuid = uuid ?? const Uuid();

  final ChatLocalDataSource _localDataSource;
  final DateTime Function() _now;
  final Uuid _uuid;
  int? _lastTimestamp;

  @override
  Future<ChatSessionEntity> startFabSession({String? title}) async {
    final timestamp = _timestamp();
    final row = await _localDataSource.insertSession(
      database_models.ChatSessionsCompanion.insert(
        id: 'chat_${_uuid.v4()}',
        title: title?.trim().isNotEmpty == true ? title!.trim() : 'Ask Tag',
        purpose: ChatPurpose.general.storageValue,
        status: ChatStatus.active.storageValue,
        createdAt: timestamp,
        updatedAt: timestamp,
      ),
    );

    return _mapSession(row);
  }

  @override
  Future<ChatSessionEntity> startPlanThisSession({
    required String title,
    required String linkedCardId,
    required String linkedSpaceId,
  }) async {
    final timestamp = _timestamp();
    final row = await _localDataSource.insertSession(
      database_models.ChatSessionsCompanion.insert(
        id: 'chat_${_uuid.v4()}',
        title: title.trim().isEmpty ? 'Plan this' : title.trim(),
        purpose: ChatPurpose.planSuggestion.storageValue,
        linkedCardId: Value(linkedCardId),
        linkedSpaceId: Value(linkedSpaceId),
        status: ChatStatus.active.storageValue,
        createdAt: timestamp,
        updatedAt: timestamp,
      ),
    );

    return _mapSession(row);
  }

  @override
  Future<ChatSessionEntity> startEditGoalSession({
    required String title,
    required String linkedCardId,
    required String linkedSpaceId,
    required String linkedGoalPlanId,
  }) async {
    final timestamp = _timestamp();
    final row = await _localDataSource.insertSession(
      database_models.ChatSessionsCompanion.insert(
        id: 'chat_${_uuid.v4()}',
        title: title.trim().isEmpty ? 'Editing goal' : title.trim(),
        purpose: ChatPurpose.editGoal.storageValue,
        linkedCardId: Value(linkedCardId),
        linkedSpaceId: Value(linkedSpaceId),
        linkedGoalPlanId: Value(linkedGoalPlanId),
        status: ChatStatus.active.storageValue,
        createdAt: timestamp,
        updatedAt: timestamp,
      ),
    );

    return _mapSession(row);
  }

  @override
  Future<ChatSessionEntity?> getSession(String sessionId) async {
    final row = await _localDataSource.loadSession(sessionId);
    return row == null ? null : _mapSession(row);
  }

  @override
  Future<ChatSessionEntity?> getMostRecentActiveFabSession() async {
    final row = await _localDataSource.loadMostRecentActiveSession();
    return row == null ? null : _mapSession(row);
  }

  @override
  Future<ChatSessionEntity> updatePendingConfirmation({
    required String sessionId,
    required String? pendingConfirmationJson,
  }) async {
    final timestamp = _timestamp();
    final row = await _localDataSource.updateSession(
      sessionId: sessionId,
      changes: database_models.ChatSessionsCompanion(
        pendingConfirmationJson: Value(pendingConfirmationJson),
        updatedAt: Value(timestamp),
      ),
    );

    return _mapSession(row);
  }

  @override
  Future<ChatSessionEntity> updateGoalPlanLink({
    required String sessionId,
    required String linkedGoalPlanId,
    required String? pendingConfirmationJson,
  }) async {
    final timestamp = _timestamp();
    final row = await _localDataSource.updateSession(
      sessionId: sessionId,
      changes: database_models.ChatSessionsCompanion(
        linkedGoalPlanId: Value(linkedGoalPlanId),
        pendingConfirmationJson: Value(pendingConfirmationJson),
        updatedAt: Value(timestamp),
      ),
    );

    return _mapSession(row);
  }

  @override
  Future<ChatMessageEntity> addMessage(ChatMessageDraft draft) async {
    final timestamp = _timestamp();
    final row = await _localDataSource.insertMessage(
      message: database_models.ChatMessagesCompanion.insert(
        id: 'msg_${_uuid.v4()}',
        chatSessionId: draft.chatSessionId,
        role: draft.role.storageValue,
        content: draft.content,
        contentJson: _nullableValue(draft.contentJson),
        toolCallsJson: _nullableValue(draft.toolCallsJson),
        sourceIdsJson: Value(jsonEncode(_uniqueNonEmpty(draft.sourceIds))),
        cardIdsJson: Value(jsonEncode(_uniqueNonEmpty(draft.cardIds))),
        modelSlug: _nullableValue(draft.modelSlug),
        createdAt: timestamp,
      ),
      sessionUpdatedAt: timestamp,
    );

    return _mapMessage(row);
  }

  @override
  Future<List<ChatMessageEntity>> loadMessages(String sessionId) async {
    final rows = await _localDataSource.loadMessages(sessionId);
    return rows.map(_mapMessage).toList(growable: false);
  }

  @override
  Stream<List<ChatMessageEntity>> watchMessages(String sessionId) {
    return _localDataSource
        .watchMessages(sessionId)
        .map((rows) => rows.map(_mapMessage).toList(growable: false));
  }

  ChatSessionEntity _mapSession(database_models.ChatSession row) {
    return ChatSessionEntity(
      id: row.id,
      title: row.title,
      purpose: ChatPurpose.fromStorageValue(row.purpose),
      linkedCardId: row.linkedCardId,
      linkedSpaceId: row.linkedSpaceId,
      linkedGoalPlanId: row.linkedGoalPlanId,
      status: ChatStatus.fromStorageValue(row.status),
      pendingConfirmationJson: row.pendingConfirmationJson,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      archivedAt: row.archivedAt,
    );
  }

  ChatMessageEntity _mapMessage(database_models.ChatMessage row) {
    return ChatMessageEntity(
      id: row.id,
      chatSessionId: row.chatSessionId,
      role: ChatMessageRole.fromStorageValue(row.role),
      content: row.content,
      contentJson: row.contentJson,
      toolCallsJson: row.toolCallsJson,
      sourceIds: _decodeStringList(row.sourceIdsJson),
      cardIds: _decodeStringList(row.cardIdsJson),
      modelSlug: row.modelSlug,
      createdAt: row.createdAt,
    );
  }

  List<String> _decodeStringList(String jsonValue) {
    try {
      final decoded = jsonDecode(jsonValue);
      if (decoded is List) {
        return decoded
            .whereType<String>()
            .where((value) => value.trim().isNotEmpty)
            .toList(growable: false);
      }
    } on FormatException {
      return const [];
    }

    return const [];
  }

  List<String> _uniqueNonEmpty(List<String> values) {
    final seen = <String>{};
    return [
      for (final value in values)
        if (value.trim().isNotEmpty && seen.add(value.trim())) value.trim(),
    ];
  }

  Value<T?> _nullableValue<T>(T? value) {
    return value == null ? const Value.absent() : Value(value);
  }

  int _timestamp() {
    final current = _now().toUtc().millisecondsSinceEpoch;
    final previous = _lastTimestamp;
    final next = previous == null || current > previous
        ? current
        : previous + 1;
    _lastTimestamp = next;

    return next;
  }
}
