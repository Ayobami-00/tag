import 'package:drift/drift.dart';
import 'package:tag/core/local_storage/database/tag_database.dart';

abstract interface class ChatLocalDataSource {
  Future<ChatSession> insertSession(ChatSessionsCompanion session);

  Future<ChatSession?> loadSession(String sessionId);

  Future<ChatSession?> loadMostRecentActiveSession();

  Future<ChatSession> updateSession({
    required String sessionId,
    required ChatSessionsCompanion changes,
  });

  Future<ChatMessage> insertMessage({
    required ChatMessagesCompanion message,
    required int sessionUpdatedAt,
  });

  Future<List<ChatMessage>> loadMessages(String sessionId);

  Stream<List<ChatMessage>> watchMessages(String sessionId);
}

class DriftChatLocalDataSource implements ChatLocalDataSource {
  const DriftChatLocalDataSource(this._database);

  final TagDatabase _database;

  @override
  Future<ChatSession> insertSession(ChatSessionsCompanion session) async {
    await _database.into(_database.chatSessions).insert(session);

    return (_database.select(
      _database.chatSessions,
    )..where((table) => table.id.equals(session.id.value))).getSingle();
  }

  @override
  Future<ChatSession?> loadSession(String sessionId) {
    return (_database.select(_database.chatSessions)..where((session) {
          return session.id.equals(sessionId) & session.archivedAt.isNull();
        }))
        .getSingleOrNull();
  }

  @override
  Future<ChatSession?> loadMostRecentActiveSession() {
    final query = _database.select(_database.chatSessions)
      ..where((session) {
        return session.status.equals('active') &
            session.purpose.equals('general') &
            session.archivedAt.isNull();
      })
      ..orderBy([
        (session) => OrderingTerm.desc(session.updatedAt),
        (session) => OrderingTerm.desc(session.createdAt),
      ])
      ..limit(1);

    return query.getSingleOrNull();
  }

  @override
  Future<ChatSession> updateSession({
    required String sessionId,
    required ChatSessionsCompanion changes,
  }) async {
    final updatedRows =
        await (_database.update(_database.chatSessions)..where((session) {
              return session.id.equals(sessionId) & session.archivedAt.isNull();
            }))
            .write(changes);

    if (updatedRows == 0) {
      throw StateError('Chat session was not found.');
    }

    return (_database.select(
      _database.chatSessions,
    )..where((table) => table.id.equals(sessionId))).getSingle();
  }

  @override
  Future<ChatMessage> insertMessage({
    required ChatMessagesCompanion message,
    required int sessionUpdatedAt,
  }) async {
    await _database.transaction(() async {
      await _database.into(_database.chatMessages).insert(message);
      await (_database.update(_database.chatSessions)..where((session) {
            return session.id.equals(message.chatSessionId.value);
          }))
          .write(ChatSessionsCompanion(updatedAt: Value(sessionUpdatedAt)));
    });

    return (_database.select(
      _database.chatMessages,
    )..where((table) => table.id.equals(message.id.value))).getSingle();
  }

  @override
  Future<List<ChatMessage>> loadMessages(String sessionId) {
    final query = _database.select(_database.chatMessages)
      ..where((message) => message.chatSessionId.equals(sessionId))
      ..orderBy([
        (message) => OrderingTerm.asc(message.createdAt),
        (message) => OrderingTerm.asc(message.id),
      ]);

    return query.get();
  }

  @override
  Stream<List<ChatMessage>> watchMessages(String sessionId) {
    final query = _database.select(_database.chatMessages)
      ..where((message) => message.chatSessionId.equals(sessionId))
      ..orderBy([
        (message) => OrderingTerm.asc(message.createdAt),
        (message) => OrderingTerm.asc(message.id),
      ]);

    return query.watch();
  }
}
