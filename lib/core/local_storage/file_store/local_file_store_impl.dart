import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:tag/core/local_storage/file_store/local_file_store.dart';

typedef AppDocumentsDirectoryProvider = Future<Directory> Function();

class LocalFileStoreImpl implements LocalFileStore {
  LocalFileStoreImpl({
    AppDocumentsDirectoryProvider? appDocumentsDirectoryProvider,
  }) : _appDocumentsDirectoryProvider =
           appDocumentsDirectoryProvider ?? getApplicationDocumentsDirectory;

  static const _storageRootName = 'Tag';
  static const _requiredDirectoryLabels = <String>[
    'sources/images',
    'sources/thumbnails',
    'sources/text',
    'exports',
    'debug/ai_outputs',
  ];
  static const _allowedImageExtensions = <String>{
    '.png',
    '.jpg',
    '.jpeg',
    '.heic',
    '.webp',
  };

  final AppDocumentsDirectoryProvider _appDocumentsDirectoryProvider;

  @override
  Future<Directory> ensureInitialized() async {
    final root = await _rootDirectory();
    await root.create(recursive: true);

    for (final directoryPath in _requiredDirectoryPaths(root.path)) {
      await Directory(directoryPath).create(recursive: true);
    }

    return root;
  }

  @override
  Future<LocalFileStoreStatus> checkStatus() async {
    try {
      final root = await ensureInitialized();
      final requiredPaths = _requiredDirectoryPaths(root.path);
      final existingStates = await Future.wait(
        requiredPaths.map((path) => Directory(path).exists()),
      );
      final isHealthy = existingStates.every((exists) => exists);

      return LocalFileStoreStatus(
        isHealthy: isHealthy,
        rootPath: root.path,
        requiredDirectoryPaths: requiredPaths,
        requiredDirectoryLabels: _requiredDirectoryLabels,
        errorMessage: isHealthy ? null : 'Missing required storage directory.',
      );
    } catch (error) {
      return LocalFileStoreStatus(
        isHealthy: false,
        rootPath: '',
        requiredDirectoryPaths: const [],
        requiredDirectoryLabels: _requiredDirectoryLabels,
        errorMessage: error.toString(),
      );
    }
  }

  @override
  Future<String> imagePathForSource(
    String sourceId, {
    String extension = '.png',
  }) async {
    final fileName =
        '${_safeSourceId(sourceId)}'
        '${_safeImageExtension(extension, fallback: '.png')}';
    return _pathInsideRoot(['sources', 'images', fileName]);
  }

  @override
  Future<String> thumbnailPathForSource(
    String sourceId, {
    String extension = '.jpg',
  }) async {
    final fileName =
        '${_safeSourceId(sourceId)}'
        '${_safeImageExtension(extension, fallback: '.jpg')}';
    return _pathInsideRoot(['sources', 'thumbnails', fileName]);
  }

  @override
  Future<String> textPathForSource(String sourceId) async {
    return _pathInsideRoot([
      'sources',
      'text',
      '${_safeSourceId(sourceId)}.txt',
    ]);
  }

  @override
  Future<String> copyImageSource({
    required String sourceId,
    required File sourceFile,
    String? extension,
  }) async {
    await ensureInitialized();

    if (!await sourceFile.exists()) {
      throw LocalFileStoreException('Imported image file does not exist.');
    }

    final destinationPath = await imagePathForSource(
      sourceId,
      extension: extension ?? p.extension(sourceFile.path),
    );
    final destinationFile = File(destinationPath);
    await destinationFile.parent.create(recursive: true);

    if (p.equals(sourceFile.absolute.path, destinationFile.absolute.path)) {
      return destinationFile.path;
    }

    final copiedFile = await sourceFile.copy(destinationFile.path);
    return copiedFile.path;
  }

  @override
  Future<String> writeTextSource({
    required String sourceId,
    required String text,
  }) async {
    await ensureInitialized();

    final file = File(await textPathForSource(sourceId));
    await file.parent.create(recursive: true);
    await file.writeAsString(text, flush: true);

    return file.path;
  }

  @override
  Future<String> readTextSource(String sourceId) async {
    final file = File(await textPathForSource(sourceId));
    return file.readAsString();
  }

  @override
  Future<bool> exists(String localPath) async {
    final safePath = await _assertPathInsideRoot(localPath);
    if (await File(safePath).exists()) {
      return true;
    }

    return Directory(safePath).exists();
  }

  @override
  Future<bool> deleteFileIfExists(String localPath) async {
    final safePath = await _assertPathInsideRoot(localPath);
    final file = File(safePath);

    if (await file.exists()) {
      await file.delete();
      return true;
    }

    if (await Directory(safePath).exists()) {
      throw const LocalFileStoreException(
        'Refusing to delete a directory through the file delete helper.',
      );
    }

    return false;
  }

  Future<Directory> _rootDirectory() async {
    final documentsDirectory = await _appDocumentsDirectoryProvider();
    final rootPath = p.canonicalize(
      p.join(documentsDirectory.absolute.path, _storageRootName),
    );

    return Directory(rootPath);
  }

  List<String> _requiredDirectoryPaths(String rootPath) {
    return [
      for (final label in _requiredDirectoryLabels)
        p.canonicalize(p.joinAll([rootPath, ...p.split(label)])),
    ];
  }

  Future<String> _pathInsideRoot(List<String> segments) async {
    final root = await _rootDirectory();
    return _assertPathInsideRoot(p.joinAll([root.path, ...segments]));
  }

  Future<String> _assertPathInsideRoot(String path) async {
    final root = await _rootDirectory();
    final rootPath = p.canonicalize(root.path);
    final candidatePath = p.canonicalize(path);

    if (candidatePath == rootPath || !p.isWithin(rootPath, candidatePath)) {
      throw const UnsafeLocalFilePathException(
        'Path must stay inside Tag app storage.',
      );
    }

    return candidatePath;
  }

  String _safeSourceId(String sourceId) {
    final trimmedSourceId = sourceId.trim();
    final isSafe = RegExp(r'^[A-Za-z0-9_-]+$').hasMatch(trimmedSourceId);

    if (!isSafe) {
      throw const UnsafeLocalFilePathException(
        'Source id cannot contain path separators or traversal tokens.',
      );
    }

    return trimmedSourceId;
  }

  String _safeImageExtension(String extension, {required String fallback}) {
    final normalized = extension.trim().toLowerCase();
    final withDot = normalized.isEmpty
        ? fallback
        : normalized.startsWith('.')
        ? normalized
        : '.$normalized';

    if (_allowedImageExtensions.contains(withDot)) {
      return withDot;
    }

    return fallback;
  }
}
