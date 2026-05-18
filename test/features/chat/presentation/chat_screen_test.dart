import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tag/core/DI/di.dart';
import 'package:tag/core/ai/cactus/cactus_model_registry.dart';
import 'package:tag/core/ai/cactus/cactus_model_service.dart';
import 'package:tag/core/ai/rag/local_rag_service.dart';
import 'package:tag/core/ai/rag/rag_models.dart';
import 'package:tag/core/config/app_config.dart';
import 'package:tag/core/local_storage/database/tag_database.dart';
import 'package:tag/core/navigation/route_constants.dart';
import 'package:tag/features/chat/presentation/screens/chat_screen.dart';
import 'package:tag/utils/index.dart';

void main() {
  late TagDatabase database;
  late GoRouter router;

  setUp(() async {
    await locator.reset();
    database = TagDatabase.forTesting(NativeDatabase.memory());
    locator.registerSingleton<LocalRagService>(_FakeRagService());
    setUpAppLocator(
      appConfig: AppConfig(autoDownloadRequiredModels: false),
      tagDatabase: database,
      cactusModelService: _FakeCactusModelService(),
    );
    router = GoRouter(
      initialLocation: chatPath,
      routes: [
        GoRoute(path: chatPath, builder: (_, __) => const ChatScreen()),
        GoRoute(
          path: chatSessionPath,
          builder: (_, state) =>
              ChatScreen(chatSessionId: state.pathParameters['chatSessionId']),
        ),
        GoRoute(
          path: sourcePreviewPath,
          builder: (_, state) {
            return Scaffold(
              appBar: AppBar(title: const Text('Source')),
              body: Text('Opened ${state.pathParameters['sourceId']}'),
            );
          },
        ),
      ],
    );
  });

  tearDown(() async {
    router.dispose();
    await locator.reset();
  });

  testWidgets('renders source citations and opens source preview', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp.router(theme: TagTheme.lightTheme, routerConfig: router),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextField),
      'What CUDA resources have I saved?',
    );
    await tester.tap(find.byTooltip('Send'));
    await tester.pumpAndSettle();

    expect(find.textContaining('I found saved context'), findsOneWidget);
    expect(
      find.textContaining('Saved as part of CUDA learning'),
      findsOneWidget,
    );
    expect(find.text('CUDA memory hierarchy'), findsOneWidget);

    final citationChip = find.widgetWithText(
      ActionChip,
      'CUDA memory hierarchy',
    );
    await tester.ensureVisible(citationChip);
    final chip = tester.widget<ActionChip>(citationChip);
    expect(chip.onPressed, isNotNull);
    chip.onPressed!();
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Opened src_cuda'), findsOneWidget);
    expect(router.canPop(), isTrue);

    await _disposeWidgetTree(tester);
  });
}

Future<void> _disposeWidgetTree(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 1));
}

class _FakeRagService implements LocalRagService {
  @override
  Future<List<LocalRagSearchResult>> search({
    required String query,
    int topK = 8,
    String? embeddingModelSlug,
  }) async {
    final now = DateTime.utc(2026, 5, 15, 10).millisecondsSinceEpoch;
    return [
      LocalRagSearchResult(
        rank: 1,
        score: 0.91,
        chunk: RagSourceChunk(
          id: 'chunk_src_cuda_0',
          sourceId: 'src_cuda',
          chunkIndex: 0,
          chunkText: 'CUDA memory hierarchy notes.',
          createdAt: now,
          updatedAt: now,
        ),
        source: RagSourceSnapshot(
          id: 'src_cuda',
          type: 'text',
          contentType: 'article',
          processingState: 'completed',
          sourceSummary: 'CUDA article notes',
          createdAt: now,
          updatedAt: now,
        ),
        relatedCards: [
          RagRelatedCardSnapshot(
            cardId: 'card_cuda',
            cardType: 'goal',
            status: 'active',
            title: 'CUDA memory hierarchy',
            spaceName: 'Learn CUDA',
            reason: 'Saved as part of CUDA learning.',
            sourceSummary: 'CUDA article notes',
            evidenceText: 'CUDA memory hierarchy notes',
          ),
        ],
      ),
    ];
  }

  @override
  Future<LocalRagIndexStatus> getIndexStatus({String? embeddingModelSlug}) {
    throw UnimplementedError();
  }

  @override
  Future<LocalRagIndexResult> indexSource({
    required String sourceId,
    required String text,
    String? embeddingModelSlug,
  }) {
    throw UnimplementedError();
  }
}

class _FakeCactusModelService implements CactusModelService {
  @override
  Future<AiCompletionResult> complete({
    required String modelSlug,
    required List<AiChatMessage> messages,
    List<AiToolSchema> tools = const [],
    AiCompletionOptions options = const AiCompletionOptions(),
  }) async {
    return AiCompletionResult(
      response: jsonEncode({
        'answer': 'You saved CUDA memory hierarchy notes.',
        'reasoning_summary':
            'The local CUDA source and related Goal Card match.',
        'source_cards': ['card_cuda'],
        'source_ids': ['src_cuda'],
        'card_ids': ['card_cuda'],
        'optional_action': null,
      }),
    );
  }

  @override
  Future<List<LocalAiModelInfo>> getAvailableModels() async {
    return const [
      LocalAiModelInfo(
        slug: CactusModelRegistry.primaryModelSlug,
        displayName: 'LFM2 VL 450M',
        capabilities: {
          AiModelCapability.completion,
          AiModelCapability.tools,
          AiModelCapability.vision,
        },
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
