import 'dart:ui';

import 'package:go_router/go_router.dart';
import 'package:tag/core/DI/di.dart';
import 'package:tag/core/navigation/custom_page_routes.dart';
import 'package:tag/core/navigation/navigation_service.dart';
import 'package:tag/core/navigation/presentation/placeholder_route_screen.dart';
import 'package:tag/core/navigation/presentation/settings_placeholder_screen.dart';
import 'package:tag/core/navigation/route_constants.dart';
import 'package:tag/features/ai_processing/presentation/screens/ai_job_queue_debug_screen.dart';
import 'package:tag/features/cards/presentation/screens/card_detail_screen.dart';
import 'package:tag/features/chat/presentation/screens/chat_screen.dart';
import 'package:tag/features/model_setup/presentation/screens/model_setup_screen.dart';
import 'package:tag/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:tag/features/rag/presentation/screens/rag_debug_search_screen.dart';
import 'package:tag/features/source_ingestion/presentation/screens/source_preview_screen.dart';
import 'package:tag/features/spaces/presentation/screens/space_detail_screen.dart';
import 'package:tag/features/today/presentation/screens/today_screen.dart';

const Set<String> _startupRouteAllowlist = {
  splashPath,
  onboardingPath,
  modelSetupPath,
  todayPath,
  sourcePreviewPath,
  spaceDetailPath,
  chatPath,
  settingsPath,
  aiQueueDebugPath,
  ragSearchDebugPath,
};

String get _initialLocation {
  final defaultRouteName = PlatformDispatcher.instance.defaultRouteName;

  if (_isAllowedStartupRoute(defaultRouteName)) {
    return defaultRouteName;
  }

  return splashPath;
}

bool _isAllowedStartupRoute(String routeName) {
  final path = Uri.tryParse(routeName)?.path ?? routeName;
  return _startupRouteAllowlist.contains(path) ||
      path.startsWith('/card/') ||
      path.startsWith('/source/') ||
      path.startsWith('/space/') ||
      path.startsWith('/chat/');
}

final GoRouter router = GoRouter(
  initialLocation: _initialLocation,
  navigatorKey: locator<NavigationService>().navigatorKey,
  routes: [
    GoRoute(path: '/', redirect: (_, __) => todayPath),
    GoRoute(
      path: splashPath,
      name: splashRoute,
      pageBuilder: (context, state) {
        return TagPageRoutes.withoutAnimation(
          name: state.name,
          child: const PlaceholderRouteScreen(
            title: 'Splash',
            description: 'Startup handoff for the local-first app shell.',
          ),
        );
      },
    ),
    GoRoute(
      path: onboardingPath,
      name: onboardingRoute,
      pageBuilder: (context, state) {
        return TagPageRoutes.withoutAnimation(
          name: state.name,
          child: const OnboardingScreen(),
        );
      },
    ),
    GoRoute(
      path: modelSetupPath,
      name: modelSetupRoute,
      pageBuilder: (context, state) {
        return TagPageRoutes.withoutAnimation(
          name: state.name,
          child: const ModelSetupScreen(),
        );
      },
    ),
    GoRoute(
      path: todayPath,
      name: todayRoute,
      pageBuilder: (context, state) {
        return TagPageRoutes.withoutAnimation(
          name: state.name,
          child: const TodayScreen(),
        );
      },
    ),
    GoRoute(
      path: cardDetailPath,
      name: cardDetailRoute,
      pageBuilder: (context, state) {
        return TagPageRoutes.withoutAnimation(
          name: state.name,
          child: CardDetailScreen(cardId: state.pathParameters['cardId'] ?? ''),
        );
      },
    ),
    GoRoute(
      path: sourcePreviewPath,
      name: sourcePreviewRoute,
      pageBuilder: (context, state) {
        return TagPageRoutes.withoutAnimation(
          name: state.name,
          child: SourcePreviewScreen(
            sourceId: state.pathParameters['sourceId'] ?? '',
            focusCardId: state.uri.queryParameters['cardId'],
          ),
        );
      },
    ),
    GoRoute(
      path: spaceDetailPath,
      name: spaceDetailRoute,
      pageBuilder: (context, state) {
        return TagPageRoutes.withoutAnimation(
          name: state.name,
          child: SpaceDetailScreen(
            spaceId: state.pathParameters['spaceId'] ?? '',
          ),
        );
      },
    ),
    GoRoute(
      path: chatPath,
      name: chatRoute,
      pageBuilder: (context, state) {
        return TagPageRoutes.withoutAnimation(
          name: state.name,
          child: const ChatScreen(),
        );
      },
    ),
    GoRoute(
      path: chatSessionPath,
      name: chatSessionRoute,
      pageBuilder: (context, state) {
        return TagPageRoutes.withoutAnimation(
          name: state.name,
          child: ChatScreen(
            chatSessionId: state.pathParameters['chatSessionId'],
          ),
        );
      },
    ),
    GoRoute(
      path: settingsPath,
      name: settingsRoute,
      pageBuilder: (context, state) {
        return TagPageRoutes.withoutAnimation(
          name: state.name,
          child: const SettingsPlaceholderScreen(),
        );
      },
    ),
    GoRoute(
      path: aiQueueDebugPath,
      name: aiQueueDebugRoute,
      pageBuilder: (context, state) {
        return TagPageRoutes.withoutAnimation(
          name: state.name,
          child: const AiJobQueueDebugScreen(),
        );
      },
    ),
    GoRoute(
      path: ragSearchDebugPath,
      name: ragSearchDebugRoute,
      pageBuilder: (context, state) {
        return TagPageRoutes.withoutAnimation(
          name: state.name,
          child: RagDebugSearchScreen(
            initialQuery: state.uri.queryParameters['query'] ?? '',
          ),
        );
      },
    ),
  ],
);
