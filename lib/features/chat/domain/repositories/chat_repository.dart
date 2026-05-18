import 'package:tag/features/chat/domain/entities/chat_entities.dart';

abstract interface class ChatRepository {
  Future<ChatSessionEntity> startFabSession({String? title});

  Future<ChatSessionEntity> startPlanThisSession({
    required String title,
    required String linkedCardId,
    required String linkedSpaceId,
  });

  Future<ChatSessionEntity> startEditGoalSession({
    required String title,
    required String linkedCardId,
    required String linkedSpaceId,
    required String linkedGoalPlanId,
  });

  Future<ChatSessionEntity?> getSession(String sessionId);

  Future<ChatSessionEntity?> getMostRecentActiveFabSession();

  Future<ChatSessionEntity> updatePendingConfirmation({
    required String sessionId,
    required String? pendingConfirmationJson,
  });

  Future<ChatSessionEntity> updateGoalPlanLink({
    required String sessionId,
    required String linkedGoalPlanId,
    required String? pendingConfirmationJson,
  });

  Future<ChatMessageEntity> addMessage(ChatMessageDraft draft);

  Future<List<ChatMessageEntity>> loadMessages(String sessionId);

  Stream<List<ChatMessageEntity>> watchMessages(String sessionId);
}
