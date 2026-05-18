import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:tag/app.dart';
import 'package:tag/core/index.dart';
import 'test_support/source_ingestion_test_support.dart';

void main() {
  late Directory documentsDirectory;
  late TagDatabase database;

  setUp(() async {
    await locator.reset();
    database = TagDatabase.forTesting(NativeDatabase.memory());
    documentsDirectory = await Directory.systemTemp.createTemp(
      'tag_widget_docs_',
    );
    setUpAppLocator(
      appConfig: AppConfig(autoDownloadRequiredModels: false),
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

  testWidgets('shows no-login onboarding on first run', (tester) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    expect(find.text('Tag'), findsOneWidget);
    expect(find.text('Welcome to Tag'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsNothing);
    expect(find.text('Login'), findsNothing);
  });

  testWidgets('shows the Today placeholder shell after onboarding', (
    tester,
  ) async {
    await _insertCompletedProfile(database);

    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    expect(find.text('Tag'), findsOneWidget);
    expect(find.text('Today'), findsWidgets);
    expect(find.text('Sorted by next active deadline'), findsOneWidget);
    expect(find.text('Nothing needs your attention today.'), findsOneWidget);
    expect(find.byTooltip('Open actions'), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsNothing);
    expect(find.text('Login'), findsNothing);

    await _disposeWidgetTree(tester);
  });

  testWidgets('uses onboarding as the first-run app surface', (tester) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, onboardingPath);
  });

  testWidgets('onboarding stores the fast local model choice', (tester) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('onboarding_start_button')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('nickname_field')),
      'Alex',
    );
    await tester.tap(find.byKey(const ValueKey('nickname_continue_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Use selected'));
    await tester.pumpAndSettle();

    expect(find.text('Private by default'), findsOneWidget);
    expect(find.text('Start sooner'), findsOneWidget);
    expect(find.text('Best quality'), findsOneWidget);
    expect(find.textContaining('LFM2'), findsNothing);
    expect(find.textContaining('Gemma'), findsNothing);

    await tester.tap(
      find.byKey(const ValueKey('local_models_start_sooner_button')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Notifications are optional.'), findsOneWidget);

    final row =
        await (database.select(database.appSettings)
              ..where((table) => table.key.equals('selected_model_slug')))
            .getSingleOrNull();

    expect(row == null, isFalse);
    expect(
      jsonDecode(row!.valueJson),
      CactusModelRegistry.defaultPrimaryModelSlug,
    );
  });

  testWidgets('onboarding pills revisit reached steps and keep state', (
    tester,
  ) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('nickname_field')),
      'Alex',
    );
    await tester.tap(find.byKey(const ValueKey('nickname_continue_button')));
    await tester.pumpAndSettle();

    expect(find.text('Choose an avatar.'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('onboarding_step_nickname')));
    await tester.pumpAndSettle();

    final nicknameField = tester.widget<TextField>(
      find.byKey(const ValueKey('nickname_field')),
    );
    expect(nicknameField.controller?.text, 'Alex');

    await tester.tap(find.byKey(const ValueKey('onboarding_step_avatar')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('avatar_next_button')));
    await tester.pumpAndSettle();

    expect(find.text('Choose an avatar.'), findsOneWidget);
    expect(find.text('Private by default'), findsNothing);

    await tester.tap(find.text('Use selected'));
    await tester.pumpAndSettle();

    expect(find.text('Private by default'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('onboarding_step_avatar')));
    await tester.pumpAndSettle();
    expect(find.text('Choose an avatar.'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('onboarding_step_localFirst')));
    await tester.pumpAndSettle();
    expect(find.text('Private by default'), findsOneWidget);
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
