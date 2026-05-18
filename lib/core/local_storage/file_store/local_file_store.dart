import 'dart:io';

class LocalFileStoreStatus {
  const LocalFileStoreStatus({
    required this.isHealthy,
    required this.rootPath,
    required this.requiredDirectoryPaths,
    required this.requiredDirectoryLabels,
    this.errorMessage,
  });

  final bool isHealthy;
  final String rootPath;
  final List<String> requiredDirectoryPaths;
  final List<String> requiredDirectoryLabels;
  final String? errorMessage;

  int get readyDirectoryCount => requiredDirectoryPaths.length;
}

class LocalFileStoreException implements Exception {
  const LocalFileStoreException(this.message);

  final String message;

  @override
  String toString() => 'LocalFileStoreException: $message';
}

class UnsafeLocalFilePathException extends LocalFileStoreException {
  const UnsafeLocalFilePathException(super.message);
}

abstract interface class LocalFileStore {
  Future<Directory> ensureInitialized();

  Future<LocalFileStoreStatus> checkStatus();

  Future<String> imagePathForSource(
    String sourceId, {
    String extension = '.png',
  });

  Future<String> thumbnailPathForSource(
    String sourceId, {
    String extension = '.jpg',
  });

  Future<String> textPathForSource(String sourceId);

  Future<String> copyImageSource({
    required String sourceId,
    required File sourceFile,
    String? extension,
  });

  Future<String> writeTextSource({
    required String sourceId,
    required String text,
  });

  Future<String> readTextSource(String sourceId);

  Future<bool> exists(String localPath);

  Future<bool> deleteFileIfExists(String localPath);
}
