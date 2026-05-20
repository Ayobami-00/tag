import 'dart:io';

import 'package:drift/native.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tag/app.dart';
import 'package:tag/core/index.dart';
import 'package:tag/utils/index.dart';
import '../../test_support/source_ingestion_test_support.dart';

void main() {
  late Directory documentsDirectory;
  late TagDatabase database;

  setUp(() async {
    await locator.reset();
    database = TagDatabase.forTesting(NativeDatabase.memory());
    documentsDirectory = await Directory.systemTemp.createTemp(
      'tag_router_docs_',
    );
    setUpAppLocator(
      appConfig: AppConfig(
        autoDownloadRequiredModels: false,
        betaFeedbackEnabled: true,
      ),
      tagDatabase: database,
      localFileStore: LocalFileStoreImpl(
        appDocumentsDirectoryProvider: () async => documentsDirectory,
      ),
      cactusModelService: const _FakeCactusModelService(),
    );
    await registerStableSourceIngestionCubitForWidgetTests();
    router.go(splashPath);
  });

  tearDown(() async {
    await locator.reset();
    if (await documentsDirectory.exists()) {
      await documentsDirectory.delete(recursive: true);
    }
  });

  testWidgets('routes first run to onboarding', (tester) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, onboardingPath);
    expect(find.text('Welcome to Tag'), findsOneWidget);
  });

  testWidgets('routes completed onboarding to Today', (tester) async {
    await _insertCompletedProfile(database);

    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, todayPath);
    expect(find.text('Today'), findsWidgets);

    await _disposeWidgetTree(tester);
  });

  testWidgets('router renders all milestone placeholder routes', (
    tester,
  ) async {
    await tester.pumpWidget(const App());

    final routes = <String, String>{
      splashPath: 'Splash',
      onboardingPath: 'Welcome to Tag',
      modelSetupPath: 'Model setup',
      todayPath: 'Today',
      sourcePreviewLocation('src_missing'): 'Source',
      spaceDetailLocation('space_missing'): 'Space',
      chatPath: 'Ask Tag',
      settingsPath: 'Settings',
      betaFeedbackPath: 'Beta feedback',
      ragSearchDebugPath: 'RAG search',
    };

    for (final entry in routes.entries) {
      router.go(entry.key);
      await tester.pumpAndSettle();

      final currentPath = router.routeInformationProvider.value.uri.path;
      if (entry.key == chatPath) {
        expect(currentPath, startsWith('/chat/'));
      } else {
        expect(currentPath, entry.key);
      }
      expect(find.text(entry.value), findsWidgets);
    }

    await _disposeWidgetTree(tester);
  });

  testWidgets('settings beta feedback entry preserves back navigation', (
    tester,
  ) async {
    final settingsRouter = GoRouter(
      initialLocation: settingsPath,
      routes: [
        GoRoute(
          path: settingsPath,
          builder: (_, __) => const SettingsPlaceholderScreen(),
        ),
        GoRoute(
          path: betaFeedbackPath,
          builder: (_, __) => Scaffold(
            appBar: AppBar(title: const Text('Beta feedback')),
            body: const Text('Beta feedback body'),
          ),
        ),
      ],
    );
    addTearDown(settingsRouter.dispose);

    await tester.pumpWidget(
      MaterialApp.router(
        theme: TagTheme.lightTheme,
        routerConfig: settingsRouter,
      ),
    );
    await tester.pumpAndSettle();

    expect(locator<AppConfig>().betaFeedbackEnabled, isTrue);
    expect(find.text('Settings'), findsWidgets);
    expect(find.text('Open beta feedback'), findsOneWidget);

    final betaFeedbackButton = find.byKey(
      const ValueKey('settings_open_beta_feedback_button'),
    );
    await tester.ensureVisible(betaFeedbackButton);
    await tester.tap(betaFeedbackButton);
    await tester.pumpAndSettle();

    expect(find.text('Beta feedback body'), findsOneWidget);
    expect(settingsRouter.canPop(), isTrue);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsWidgets);
    expect(find.text('Beta feedback body'), findsNothing);

    await _disposeWidgetTree(tester);
  });
}

Future<void> _disposeWidgetTree(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 1));
}

class _FakeCactusModelService implements CactusModelService {
  const _FakeCactusModelService();

  @override
  Future<List<LocalAiModelInfo>> getAvailableModels() async {
    return const [
      LocalAiModelInfo(
        slug: CactusModelRegistry.primaryVisionToolModelSlug,
        displayName: 'Gemma 4 E2B IT',
        capabilities: {
          AiModelCapability.completion,
          AiModelCapability.tools,
          AiModelCapability.vision,
        },
      ),
      LocalAiModelInfo(
        slug: CactusModelRegistry.defaultEmbeddingModelSlug,
        displayName: 'Nomic Embed Text v2 MoE',
        capabilities: {AiModelCapability.embedding},
      ),
    ];
  }

  @override
  Future<void> downloadModel(
    String slug, {
    void Function(ModelDownloadProgress progress)? onProgress,
  }) async {}

  @override
  Future<void> initializeModel(String slug) async {}

  @override
  Future<void> unloadModel(String slug) async {}

  @override
  Future<AiCompletionResult> complete({
    required String modelSlug,
    required List<AiChatMessage> messages,
    List<AiToolSchema> tools = const [],
    AiCompletionOptions options = const AiCompletionOptions(),
  }) {
    throw UnimplementedError();
  }

  @override
  Stream<String> streamComplete({
    required String modelSlug,
    required List<AiChatMessage> messages,
    List<AiToolSchema> tools = const [],
    AiCompletionOptions options = const AiCompletionOptions(),
  }) {
    throw UnimplementedError();
  }

  @override
  Future<AiEmbeddingResult> embedText({
    required String modelSlug,
    required String text,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<AiVisionResult> completeWithImage({
    required String modelSlug,
    required String imagePath,
    required List<AiChatMessage> messages,
    List<AiToolSchema> tools = const [],
    AiCompletionOptions options = const AiCompletionOptions(),
  }) {
    throw UnimplementedError();
  }
}

Future<void> _insertCompletedProfile(TagDatabase database) async {
  final now = DateTime.utc(2026, 5, 9, 10).millisecondsSinceEpoch;

  await database
      .into(database.userProfiles)
      .insert(
        UserProfilesCompanion.insert(
          id: 'local_user',
          nickname: 'Alex',
          avatarKind: 'emoji',
          avatarValue: '📌',
          onboardingCompletedAt: Value(now),
          notificationPermissionState: const Value('unknown'),
          createdAt: now,
          updatedAt: now,
        ),
      );
}
