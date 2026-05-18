import 'package:equatable/equatable.dart';
import 'package:tag/core/use_cases/use_cases.dart';
import 'package:tag/features/chat/domain/entities/chat_entities.dart';
import 'package:tag/features/chat/domain/repositories/chat_repository.dart';

class StartFabChatParams extends Equatable {
  const StartFabChatParams({this.reuseMostRecent = false});

  final bool reuseMostRecent;

  @override
  List<Object?> get props => [reuseMostRecent];
}

class StartFabChat with UseCases<ChatSessionEntity, StartFabChatParams> {
  const StartFabChat(this._chatRepository);

  final ChatRepository _chatRepository;

  @override
  Future<ChatSessionEntity> call(StartFabChatParams params) async {
    if (params.reuseMostRecent) {
      final existing = await _chatRepository.getMostRecentActiveFabSession();
      if (existing != null) {
        return existing;
      }
    }

    return _chatRepository.startFabSession();
  }
}
