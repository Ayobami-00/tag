import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:tag/core/local_storage/file_store/local_file_store.dart';
import 'package:tag/core/local_storage/file_store/local_file_store_impl.dart';

void main() {
  late Directory documentsDirectory;
  late LocalFileStore store;

  setUp(() async {
    documentsDirectory = await Directory.systemTemp.createTemp(
      'tag_file_store_docs_',
    );
    store = LocalFileStoreImpl(
      appDocumentsDirectoryProvider: () async => documentsDirectory,
    );
  });

  tearDown(() async {
    if (await documentsDirectory.exists()) {
      await documentsDirectory.delete(recursive: true);
    }
  });

  test('initializes the app-owned storage root and directories', () async {
    final status = await store.checkStatus();

    expect(status.isHealthy, isTrue);
    expect(p.basename(status.rootPath), 'Tag');
    expect(status.requiredDirectoryLabels, [
      'sources/images',
      'sources/thumbnails',
      'sources/text',
      'exports',
      'debug/ai_outputs',
    ]);

    for (final directoryPath in status.requiredDirectoryPaths) {
      expect(await Directory(directoryPath).exists(), isTrue);
      expect(
        p.isWithin(
          p.canonicalize(p.join(documentsDirectory.path, 'Tag')),
          directoryPath,
        ),
        isTrue,
      );
    }
  });

  test(
    'generates deterministic image paths and copies imported images',
    () async {
      final importedImage = File(p.join(documentsDirectory.path, 'import.png'));
      await importedImage.writeAsBytes([1, 2, 3, 4], flush: true);

      final generatedPath = await store.imagePathForSource('src_001');
      final copiedPath = await store.copyImageSource(
        sourceId: 'src_001',
        sourceFile: importedImage,
      );

      expect(copiedPath, generatedPath);
      expect(
        copiedPath,
        p.canonicalize(
          p.join(
            documentsDirectory.path,
            'Tag',
            'sources',
            'images',
            'src_001.png',
          ),
        ),
      );
      expect(await File(copiedPath).readAsBytes(), [1, 2, 3, 4]);
    },
  );

  test('writes and reads text sources', () async {
    final path = await store.writeTextSource(
      sourceId: 'src_note',
      text: 'Buy bread at 8pm.',
    );
    final text = await store.readTextSource('src_note');

    expect(
      path,
      p.canonicalize(
        p.join(
          documentsDirectory.path,
          'Tag',
          'sources',
          'text',
          'src_note.txt',
        ),
      ),
    );
    expect(text, 'Buy bread at 8pm.');
  });

  test('generates thumbnail paths without writing files', () async {
    final path = await store.thumbnailPathForSource('src_001');

    expect(
      path,
      p.canonicalize(
        p.join(
          documentsDirectory.path,
          'Tag',
          'sources',
          'thumbnails',
          'src_001.jpg',
        ),
      ),
    );
    expect(await File(path).exists(), isFalse);
  });

  test('deletes files inside the storage root safely', () async {
    final path = await store.writeTextSource(
      sourceId: 'src_delete',
      text: 'temporary source',
    );

    expect(await store.exists(path), isTrue);
    expect(await store.deleteFileIfExists(path), isTrue);
    expect(await store.exists(path), isFalse);
    expect(await store.deleteFileIfExists(path), isFalse);
  });

  test('rejects attempted deletes outside the storage root', () async {
    final outsidePath = p.join(
      documentsDirectory.path,
      '..',
      'outside_tag_storage.txt',
    );

    await expectLater(
      store.deleteFileIfExists(outsidePath),
      throwsA(isA<UnsafeLocalFilePathException>()),
    );
  });

  test('rejects source ids with path traversal tokens', () async {
    await expectLater(
      store.writeTextSource(sourceId: '../src_bad', text: 'nope'),
      throwsA(isA<UnsafeLocalFilePathException>()),
    );
  });
}
