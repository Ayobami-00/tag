const String splashRoute = 'splash';
const String splashPath = '/splash';

const String onboardingRoute = 'onboarding';
const String onboardingPath = '/onboarding';

const String modelSetupRoute = 'modelSetup';
const String modelSetupPath = '/model-setup';

const String todayRoute = 'today';
const String todayPath = '/today';

const String cardDetailRoute = 'cardDetail';
const String cardDetailPath = '/card/:cardId';

String cardDetailLocation(String cardId) => '/card/$cardId';

const String sourcePreviewRoute = 'sourcePreview';
const String sourcePreviewPath = '/source/:sourceId';

String sourcePreviewLocation(String sourceId, {String? fromCardId}) {
  final encodedSourceId = Uri.encodeComponent(sourceId);
  final encodedCardId = fromCardId == null || fromCardId.trim().isEmpty
      ? null
      : Uri.encodeQueryComponent(fromCardId);

  if (encodedCardId == null) {
    return '/source/$encodedSourceId';
  }

  return '/source/$encodedSourceId?cardId=$encodedCardId';
}

const String spaceDetailRoute = 'spaceDetail';
const String spaceDetailPath = '/space/:spaceId';

String spaceDetailLocation(String spaceId) {
  return '/space/${Uri.encodeComponent(spaceId)}';
}

const String chatRoute = 'chat';
const String chatPath = '/chat';

const String chatSessionRoute = 'chatSession';
const String chatSessionPath = '/chat/:chatSessionId';

String chatSessionLocation(String chatSessionId) {
  return '/chat/${Uri.encodeComponent(chatSessionId)}';
}

const String settingsRoute = 'settings';
const String settingsPath = '/settings';

const String aiQueueDebugRoute = 'aiQueueDebug';
const String aiQueueDebugPath = '/debug/ai-jobs';

const String ragSearchDebugRoute = 'ragSearchDebug';
const String ragSearchDebugPath = '/debug/rag';
