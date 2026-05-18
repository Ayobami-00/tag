part of 'chat_cubit.dart';

enum ChatLoadStatus { initial, loading, ready, sending, error }

extension ChatLoadStatusX on ChatLoadStatus {
  bool get isBusy =>
      this == ChatLoadStatus.loading || this == ChatLoadStatus.sending;
}

class ChatState extends Equatable {
  const ChatState({
    this.status = ChatLoadStatus.initial,
    this.session,
    this.messages = const [],
    this.errorMessage = '',
  });

  final ChatLoadStatus status;
  final ChatSessionEntity? session;
  final List<ChatMessageEntity> messages;
  final String errorMessage;

  bool get isLoading =>
      status == ChatLoadStatus.initial || status == ChatLoadStatus.loading;

  bool get isSending => status == ChatLoadStatus.sending;

  ChatState copyWith({
    ChatLoadStatus? status,
    ChatSessionEntity? session,
    List<ChatMessageEntity>? messages,
    String? errorMessage,
  }) {
    return ChatState(
      status: status ?? this.status,
      session: session ?? this.session,
      messages: messages ?? this.messages,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, session, messages, errorMessage];
}
