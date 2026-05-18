import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:tag/core/index.dart';
import 'package:tag/features/cards/domain/repositories/card_repository.dart';
import 'package:tag/features/source_ingestion/presentation/screens/source_preview_screen.dart';
import 'package:tag/utils/index.dart';

void main() {
  late Directory documentsDirectory;
  late TagDatabase database;

  setUp(() async {
    await locator.reset();
    database = TagDatabase.forTesting(NativeDatabase.memory());
    documentsDirectory = await Directory.systemTemp.createTemp(
      'tag_source_preview_docs_',
    );
    setUpAppLocator(
      appConfig: AppConfig(autoDownloadRequiredModels: false),
      tagDatabase: database,
      localFileStore: LocalFileStoreImpl(
        appDocumentsDirectoryProvider: () async => documentsDirectory,
      ),
      cactusModelService: const _FakeCactusModelService(),
    );
  });

  tearDown(() async {
    await locator.reset();
    if (await documentsDirectory.exists()) {
      await documentsDirectory.delete(recursive: true);
    }
  });

  testWidgets('missing local image file shows a recoverable error', (
    tester,
  ) async {
    await _insertImageSourceWithMissingFile(database);
    final card = await locator<CardRepository>().createFromProposal(
      proposal: CardProposal.fromJson({
        'card_type': 'urgent',
        'title': 'Buy bread',
        'reason': 'Detected an action and a time in the screenshot.',
        'space_name': 'Household Tasks',
        'next_active_deadline': DateTime.utc(2026, 5, 10, 20).toIso8601String(),
        'source_ids': const ['src_missing_image'],
        'actions': const ['complete', 'snooze', 'cancel'],
        'confidence': 0.91,
      }),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: TagTheme.lightTheme,
        home: SourcePreviewScreen(
          sourceId: 'src_missing_image',
          focusCardId: card.id,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('The original image is missing from local storage.'),
      findsOneWidget,
    );
    expect(find.text('Please buy bread at 8pm.'), findsWidgets);
    expect(
      find.text('Detected an action and a time in the screenshot.'),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(find.text('Open Space'), 240);
    expect(find.text('Open Space'), findsOneWidget);
    expect(find.text('Buy bread'), findsWidgets);
  });

  test(
    'source preview path repair finds the current app-container file',
    () async {
      final imageFile = await _writeRepairedImageFixture(documentsDirectory);

      final resolved = await resolveCurrentDocumentsFileForSourcePreview(
        '/tmp/old-container/Documents/Tag/sources/images/src_repaired_image.png',
      );

      expect(resolved?.path, imageFile.path);
    },
  );
}

Future<void> _insertImageSourceWithMissingFile(TagDatabase database) async {
  final now = DateTime.utc(2026, 5, 10, 12).millisecondsSinceEpoch;

  await database
      .into(database.sourceItems)
      .insert(
        SourceItemsCompanion.insert(
          id: 'src_missing_image',
          type: 'screenshot',
          localFilePath: const Value('/tmp/tag_missing_source_image.png'),
          sourceSummary: const Value('WhatsApp screenshot'),
          appSource: const Value('WhatsApp'),
          contentType: const Value('message'),
          rawText: const Value('Please buy bread at 8pm.'),
          extractedText: const Value('Please buy bread at 8pm.'),
          createdAt: now,
          updatedAt: now,
        ),
      );
}

Future<File> _writeRepairedImageFixture(Directory documentsDirectory) async {
  final imageFile = File(
    p.join(
      documentsDirectory.path,
      'Tag',
      'sources',
      'images',
      'src_repaired_image.png',
    ),
  );
  await imageFile.parent.create(recursive: true);
  await imageFile.writeAsBytes([1, 2, 3, 4]);
  return imageFile;
}

class _FakeCactusModelService implements CactusModelService {
  const _FakeCactusModelService();

  @override
  Future<List<LocalAiModelInfo>> getAvailableModels() async {
    return const [];
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
