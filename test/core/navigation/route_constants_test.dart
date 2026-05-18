import 'package:flutter_test/flutter_test.dart';
import 'package:tag/core/index.dart';

void main() {
  test('defines the milestone startup routes', () {
    expect(splashRoute, 'splash');
    expect(splashPath, '/splash');
    expect(onboardingRoute, 'onboarding');
    expect(onboardingPath, '/onboarding');
    expect(modelSetupRoute, 'modelSetup');
    expect(modelSetupPath, '/model-setup');
    expect(todayRoute, 'today');
    expect(todayPath, '/today');
    expect(cardDetailRoute, 'cardDetail');
    expect(cardDetailPath, '/card/:cardId');
    expect(cardDetailLocation('card_123'), '/card/card_123');
    expect(sourcePreviewRoute, 'sourcePreview');
    expect(sourcePreviewPath, '/source/:sourceId');
    expect(sourcePreviewLocation('src_123'), '/source/src_123');
    expect(
      sourcePreviewLocation('src_123', fromCardId: 'card_123'),
      '/source/src_123?cardId=card_123',
    );
    expect(spaceDetailRoute, 'spaceDetail');
    expect(spaceDetailPath, '/space/:spaceId');
    expect(spaceDetailLocation('space_123'), '/space/space_123');
    expect(chatRoute, 'chat');
    expect(chatPath, '/chat');
    expect(chatSessionRoute, 'chatSession');
    expect(chatSessionPath, '/chat/:chatSessionId');
    expect(chatSessionLocation('chat_123'), '/chat/chat_123');
    expect(settingsRoute, 'settings');
    expect(settingsPath, '/settings');
    expect(aiQueueDebugRoute, 'aiQueueDebug');
    expect(aiQueueDebugPath, '/debug/ai-jobs');
    expect(ragSearchDebugRoute, 'ragSearchDebug');
    expect(ragSearchDebugPath, '/debug/rag');
  });
}
