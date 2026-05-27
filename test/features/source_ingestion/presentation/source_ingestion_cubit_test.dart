import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:tag/core/local_storage/database/tag_database.dart';
import 'package:tag/core/local_storage/file_store/local_file_store_impl.dart';
import 'package:tag/features/source_ingestion/data/data_sources/source_local_data_source.dart';
import 'package:tag/features/source_ingestion/data/repositories/source_repository_impl.dart';
import 'package:tag/features/source_ingestion/domain/repositories/source_repository.dart';
import 'package:tag/features/source_ingestion/domain/services/manual_source_picker.dart';
import 'package:tag/features/source_ingestion/domain/use_cases/create_text_source.dart';
import 'package:tag/features/source_ingestion/domain/use_cases/import_image_source.dart';
import 'package:tag/features/source_ingestion/domain/use_cases/queue_source_processing.dart';
import 'package:tag/features/source_ingestion/domain/use_cases/store_source_file.dart';
import 'package:tag/features/source_ingestion/domain/use_cases/watch_recent_sources.dart';
import 'package:tag/features/source_ingestion/presentation/logic/source_ingestion_cubit.dart';

void main() {
  late Directory tempDirectory;
  late Directory documentsDirectory;
  late TagDatabase database;
  late SourceRepository sourceRepository;
  late StoreSourceFile storeSourceFile;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp(
      'tag_source_ingestion_cubit_test_',
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

  test('dismissed manual image description cancels the import', () async {
    final importedImage = await _writeImageFixture(tempDirectory);
    final queue = _ImmediateQueueSourceProcessing();
    final cubit = _buildCubit(
      pickedImage: importedImage,
      storeSourceFile: storeSourceFile,
      sourceRepository: sourceRepository,
      queueSourceProcessing: queue,
    );
    addTearDown(cubit.close);

    await cubit.importImage(requestDescription: (_) async => null);

    expect(cubit.state.status, SourceIngestionStatus.ready);
    expect(cubit.state.lastSavedSource, isNull);
    expect(await database.select(database.sourceItems).get(), isEmpty);
    expect(queue.sourceIds, isEmpty);
  });

  test('skipping manual image description still imports the image', () async {
    final importedImage = await _writeImageFixture(tempDirectory);
    final queue = _ImmediateQueueSourceProcessing();
    final cubit = _buildCubit(
      pickedImage: importedImage,
      storeSourceFile: storeSourceFile,
      sourceRepository: sourceRepository,
      queueSourceProcessing: queue,
    );
    addTearDown(cubit.close);

    await cubit.importImage(requestDescription: (_) async => '');

    final rows = await database.select(database.sourceItems).get();
    expect(cubit.state.status, SourceIngestionStatus.saved);
    expect(cubit.state.lastSavedSource?.sourceDescription, isNull);
    expect(rows, hasLength(1));
    expect(rows.single.metadataJson, isNot(contains('source_description')));
    expect(queue.sourceIds, ['src_image']);
  });
}

SourceIngestionCubit _buildCubit({
  required File pickedImage,
  required StoreSourceFile storeSourceFile,
  required SourceRepository sourceRepository,
  required QueueSourceProcessing queueSourceProcessing,
}) {
  final manualSourcePicker = _FakeManualSourcePicker(
    PickedImageSource(
      path: pickedImage.path,
      displayName: 'photo.png',
      extension: 'png',
      sizeBytes: pickedImage.lengthSync(),
    ),
  );

  return SourceIngestionCubit(
    importImageSource: ImportImageSource(
      manualSourcePicker: manualSourcePicker,
      storeSourceFile: storeSourceFile,
      sourceRepository: sourceRepository,
      queueSourceProcessing: queueSourceProcessing,
      sourceIdFactory: () => 'src_image',
    ),
    manualSourcePicker: manualSourcePicker,
    createTextSource: CreateTextSource(
      storeSourceFile: storeSourceFile,
      sourceRepository: sourceRepository,
      queueSourceProcessing: queueSourceProcessing,
    ),
    watchRecentSources: WatchRecentSources(sourceRepository),
  );
}

Future<File> _writeImageFixture(Directory tempDirectory) async {
  final importedImage = File(p.join(tempDirectory.path, 'photo.png'));
  await importedImage.writeAsBytes([10, 20, 30, 40], flush: true);
  return importedImage;
}

class _FakeManualSourcePicker implements ManualSourcePicker {
  const _FakeManualSourcePicker(this.source);

  final PickedImageSource source;

  @override
  Future<PickedImageSource?> pickImage() async => source;
}

class _ImmediateQueueSourceProcessing extends QueueSourceProcessing {
  final List<String> sourceIds = [];

  @override
  Future<void> call(QueueSourceProcessingParams params) async {
    sourceIds.add(params.sourceId);
  }
}
