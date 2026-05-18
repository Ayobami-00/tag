import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:tag/core/local_storage/database/tag_database.dart';
import 'package:tag/core/local_storage/file_store/local_file_store_impl.dart';
import 'package:tag/core/platform/share_intake_service.dart';
import 'package:tag/core/use_cases/use_cases.dart';
import 'package:tag/features/source_ingestion/data/data_sources/source_local_data_source.dart';
import 'package:tag/features/source_ingestion/data/repositories/source_repository_impl.dart';
import 'package:tag/features/source_ingestion/domain/entities/source_item_entity.dart';
import 'package:tag/features/source_ingestion/domain/repositories/source_repository.dart';
import 'package:tag/features/source_ingestion/domain/services/manual_source_picker.dart';
import 'package:tag/features/source_ingestion/domain/use_cases/create_text_source.dart';
import 'package:tag/features/source_ingestion/domain/use_cases/import_image_source.dart';
import 'package:tag/features/source_ingestion/domain/use_cases/import_pending_shared_sources.dart';
import 'package:tag/features/source_ingestion/domain/use_cases/ingest_shared_source.dart';
import 'package:tag/features/source_ingestion/domain/use_cases/queue_source_processing.dart';
import 'package:tag/features/source_ingestion/domain/use_cases/store_source_file.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late Directory tempDirectory;
  late Directory documentsDirectory;
  late TagDatabase database;
  late SourceRepository sourceRepository;
  late StoreSourceFile storeSourceFile;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp(
      'tag_source_ingestion_test_',
    );
    documentsDirectory = Directory(p.join(tempDirectory.path, 'documents'));
    await documentsDirectory.create(recursive: true);
    database = TagDatabase.forTesting(NativeDatabase.memory());
    sourceRepository = SourceRepositoryImpl(
      localDataSource: DriftSourceLocalDataSource(database),
      now: () => DateTime.utc(2026, 5, 10, 12),
    );
    storeSourceFile = StoreSourceFile(
      LocalFileStoreImpl(
        appDocumentsDirectoryProvider: () async => documentsDirectory,
      ),
    );
  });

  tearDown(() async {
    await database.close();
    if (await tempDirectory.exists()) {
      await tempDirectory.delete(recursive: true);
    }
  });

  test(
    'importing an image creates a saved source and copies the file',
    () async {
      final importedImage = File(p.join(tempDirectory.path, 'photo.png'));
      await importedImage.writeAsBytes([10, 20, 30, 40], flush: true);
      final queue = _ControlledQueueSourceProcessing();
      final importImageSource = ImportImageSource(
        manualSourcePicker: _FakeManualSourcePicker(
          PickedImageSource(
            path: importedImage.path,
            displayName: 'photo.png',
            extension: 'png',
            sizeBytes: 4,
          ),
        ),
        storeSourceFile: storeSourceFile,
        sourceRepository: sourceRepository,
        queueSourceProcessing: queue,
        sourceIdFactory: () => 'src_image',
      );

      final source = await importImageSource(
        const NoParams(),
      ).timeout(const Duration(seconds: 1));

      expect(source, isNotNull);
      expect(source!.id, 'src_image');
      expect(source.type, SourceItemType.image);
      expect(source.processingState, SourceProcessingState.saved);
      expect(source.sourceSummary, 'Manual image - photo.png');
      expect(source.localFilePath, isNot(importedImage.path));
      expect(await File(source.localFilePath!).readAsBytes(), [10, 20, 30, 40]);
      expect(
        p.relative(source.localFilePath!, from: documentsDirectory.path),
        p.join('Tag', 'sources', 'images', 'src_image.png'),
      );

      final rows = await database.select(database.sourceItems).get();
      expect(rows, hasLength(1));
      expect(rows.single.processingState, 'saved');
      await queue.started.future.timeout(const Duration(seconds: 1));
      queue.complete();
    },
  );

  test('text paste creates a saved source and local text file', () async {
    final queue = _ControlledQueueSourceProcessing();
    final createTextSource = CreateTextSource(
      storeSourceFile: storeSourceFile,
      sourceRepository: sourceRepository,
      queueSourceProcessing: queue,
      sourceIdFactory: () => 'src_text',
    );

    final source = await createTextSource(
      const CreateTextSourceParams('  Please buy bread at 8pm  '),
    ).timeout(const Duration(seconds: 1));

    expect(source.id, 'src_text');
    expect(source.type, SourceItemType.text);
    expect(source.rawText, 'Please buy bread at 8pm');
    expect(source.processingState, SourceProcessingState.saved);
    expect(source.sourceSummary, 'Manual text paste');
    expect(await File(source.localFilePath!).readAsString(), source.rawText);
    expect(
      p.relative(source.localFilePath!, from: documentsDirectory.path),
      p.join('Tag', 'sources', 'text', 'src_text.txt'),
    );

    final rows = await database.select(database.sourceItems).get();
    expect(rows, hasLength(1));
    expect(rows.single.processingState, 'saved');
    await queue.started.future.timeout(const Duration(seconds: 1));
    queue.complete();
  });

  test('save returns before queued processing is available', () async {
    final queue = _ControlledQueueSourceProcessing();
    final createTextSource = CreateTextSource(
      storeSourceFile: storeSourceFile,
      sourceRepository: sourceRepository,
      queueSourceProcessing: queue,
      sourceIdFactory: () => 'src_fast_save',
    );

    final source = await createTextSource(
      const CreateTextSourceParams('Remember the source reason.'),
    ).timeout(const Duration(milliseconds: 500));

    expect(source.processingState, SourceProcessingState.saved);
    await queue.started.future.timeout(const Duration(seconds: 1));
    queue.complete();
  });

  test('pending shared image creates a source and queues processing', () async {
    final sharedImage = File(p.join(tempDirectory.path, 'shared_photo.png'));
    await sharedImage.writeAsBytes([1, 2, 3, 4], flush: true);
    final queue = _ImmediateQueueSourceProcessing();
    final shareService = _FakeShareIntakeService([
      PendingSharedSource(
        id: 'pending_image',
        type: PendingSharedSourceType.image,
        filePath: sharedImage.path,
        suggestedName: 'shared_photo.png',
        receivedAt: DateTime.utc(2026, 5, 10, 11).millisecondsSinceEpoch,
        sourceApplication: 'com.apple.mobileslideshow',
        uti: 'public.png',
      ),
    ]);
    final importPending = _buildImportPendingSharedSources(
      shareService: shareService,
      queueSourceProcessing: queue,
      sourceIds: ['src_shared_image'],
      storeSourceFile: storeSourceFile,
      sourceRepository: sourceRepository,
    );

    final imported = await importPending(const NoParams());

    expect(imported, hasLength(1));
    final source = imported.single;
    expect(source.id, 'src_shared_image');
    expect(source.type, SourceItemType.image);
    expect(source.originalUri, 'tag-share://pending_image');
    expect(source.sourceSummary, 'Shared image - shared_photo.png');
    expect(source.appSource, 'iOS Share');
    expect(source.processingState, SourceProcessingState.saved);
    expect(source.localFilePath, isNot(sharedImage.path));
    expect(await File(source.localFilePath!).readAsBytes(), [1, 2, 3, 4]);
    expect(queue.sourceIds, ['src_shared_image']);
    expect(shareService.importedIds, ['pending_image']);
  });

  test('pending shared text creates a source and queues processing', () async {
    final queue = _ImmediateQueueSourceProcessing();
    final shareService = _FakeShareIntakeService([
      const PendingSharedSource(
        id: 'pending_text',
        type: PendingSharedSourceType.text,
        text: '  Please buy bread at 8pm  ',
        sourceApplication: 'com.apple.MobileSMS',
        uti: 'public.plain-text',
      ),
    ]);
    final importPending = _buildImportPendingSharedSources(
      shareService: shareService,
      queueSourceProcessing: queue,
      sourceIds: ['src_shared_text'],
      storeSourceFile: storeSourceFile,
      sourceRepository: sourceRepository,
    );

    final imported = await importPending(const NoParams());

    expect(imported, hasLength(1));
    final source = imported.single;
    expect(source.id, 'src_shared_text');
    expect(source.type, SourceItemType.text);
    expect(source.rawText, 'Please buy bread at 8pm');
    expect(source.sourceSummary, 'Shared text');
    expect(await File(source.localFilePath!).readAsString(), source.rawText);
    expect(queue.sourceIds, ['src_shared_text']);
    expect(shareService.importedIds, ['pending_text']);
  });

  test('pending shared URL creates a link source', () async {
    final queue = _ImmediateQueueSourceProcessing();
    final shareService = _FakeShareIntakeService([
      const PendingSharedSource(
        id: 'pending_url',
        type: PendingSharedSourceType.url,
        url: 'https://example.com/saved-post',
        sourceApplication: 'com.apple.mobilesafari',
        uti: 'public.url',
      ),
    ]);
    final importPending = _buildImportPendingSharedSources(
      shareService: shareService,
      queueSourceProcessing: queue,
      sourceIds: ['src_shared_url'],
      storeSourceFile: storeSourceFile,
      sourceRepository: sourceRepository,
    );

    final imported = await importPending(const NoParams());

    expect(imported, hasLength(1));
    final source = imported.single;
    expect(source.id, 'src_shared_url');
    expect(source.type, SourceItemType.link);
    expect(source.rawText, 'https://example.com/saved-post');
    expect(source.detectedLinksJson, '["https://example.com/saved-post"]');
    expect(source.sourceSummary, 'Shared link');
    expect(queue.sourceIds, ['src_shared_url']);
    expect(shareService.importedIds, ['pending_url']);
  });

  test('duplicate pending payload is not imported twice', () async {
    final queue = _ImmediateQueueSourceProcessing();
    final shareService = _FakeShareIntakeService([
      const PendingSharedSource(
        id: 'pending_duplicate',
        type: PendingSharedSourceType.text,
        text: 'Save this once.',
      ),
      const PendingSharedSource(
        id: 'pending_duplicate',
        type: PendingSharedSourceType.text,
        text: 'Save this once.',
      ),
    ]);
    final importPending = _buildImportPendingSharedSources(
      shareService: shareService,
      queueSourceProcessing: queue,
      sourceIds: ['src_duplicate_a', 'src_duplicate_b'],
      storeSourceFile: storeSourceFile,
      sourceRepository: sourceRepository,
    );

    final imported = await importPending(const NoParams());
    final rows = await database.select(database.sourceItems).get();

    expect(imported, hasLength(1));
    expect(rows, hasLength(1));
    expect(rows.single.id, 'src_duplicate_a');
    expect(queue.sourceIds, ['src_duplicate_a']);
    expect(shareService.importedIds, ['pending_duplicate']);
  });
}

ImportPendingSharedSources _buildImportPendingSharedSources({
  required ShareIntakeService shareService,
  required QueueSourceProcessing queueSourceProcessing,
  required List<String> sourceIds,
  required StoreSourceFile storeSourceFile,
  required SourceRepository sourceRepository,
}) {
  var index = 0;
  return ImportPendingSharedSources(
    shareIntakeService: shareService,
    ingestSharedSource: IngestSharedSource(
      storeSourceFile: storeSourceFile,
      sourceRepository: sourceRepository,
      queueSourceProcessing: queueSourceProcessing,
      sourceIdFactory: () => sourceIds[index++],
    ),
  );
}

class _FakeManualSourcePicker implements ManualSourcePicker {
  const _FakeManualSourcePicker(this.source);

  final PickedImageSource? source;

  @override
  Future<PickedImageSource?> pickImage() async => source;
}

class _ControlledQueueSourceProcessing extends QueueSourceProcessing {
  _ControlledQueueSourceProcessing();

  final Completer<void> started = Completer<void>();
  final Completer<void> completion = Completer<void>();
  final List<String> sourceIds = [];

  @override
  Future<void> call(QueueSourceProcessingParams params) {
    sourceIds.add(params.sourceId);
    if (!started.isCompleted) {
      started.complete();
    }
    return completion.future;
  }

  void complete() {
    if (!completion.isCompleted) {
      completion.complete();
    }
  }
}

class _ImmediateQueueSourceProcessing extends QueueSourceProcessing {
  final List<String> sourceIds = [];

  @override
  Future<void> call(QueueSourceProcessingParams params) async {
    sourceIds.add(params.sourceId);
  }
}

class _FakeShareIntakeService implements ShareIntakeService {
  _FakeShareIntakeService(this.pendingSources);

  final List<PendingSharedSource> pendingSources;
  final List<String> importedIds = [];

  @override
  Future<List<PendingSharedSource>> getPendingSharedSources() async {
    return pendingSources;
  }

  @override
  Future<void> markPendingSharedSourceImported(String id) async {
    importedIds.add(id);
  }
}
