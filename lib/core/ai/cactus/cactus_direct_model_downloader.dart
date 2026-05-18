import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tag/core/ai/cactus/cactus_model_registry.dart';
import 'package:tag/core/ai/cactus/cactus_model_service.dart';
import 'package:tag/core/error/app_error.dart';

class CactusDirectModelDownloader {
  const CactusDirectModelDownloader();

  static final Map<String, Future<void>> _downloadsBySlug = {};
  static const _completionMarkerName = '.tag_model_download_complete';

  Future<String> modelPathForSlug(String slug) async {
    final appDocDir = await getApplicationDocumentsDirectory();
    return '${appDocDir.path}/models/$slug';
  }

  Future<bool> hasModelFilesForSlug(String slug) async {
    return _hasModelFiles(Directory(await modelPathForSlug(slug)));
  }

  Future<void> download(
    CactusModelDownloadAsset asset, {
    void Function(ModelDownloadProgress progress)? onProgress,
  }) async {
    final inFlightDownload = _downloadsBySlug[asset.slug];
    if (inFlightDownload != null) {
      await inFlightDownload;
      return;
    }

    final download = _download(asset, onProgress: onProgress);
    _downloadsBySlug[asset.slug] = download;
    try {
      await download;
    } finally {
      if (identical(_downloadsBySlug[asset.slug], download)) {
        _downloadsBySlug.remove(asset.slug);
      }
    }
  }

  Future<void> _download(
    CactusModelDownloadAsset asset, {
    void Function(ModelDownloadProgress progress)? onProgress,
  }) async {
    final modelPath = await modelPathForSlug(asset.slug);
    final modelsDir = Directory(File(modelPath).parent.path);
    final modelDir = Directory(modelPath);

    if (await _hasModelFiles(modelDir)) {
      onProgress?.call(
        ModelDownloadProgress(
          slug: asset.slug,
          progress: 1,
          statusMessage: '${asset.sourceLabel} is already downloaded.',
        ),
      );
      return;
    }

    await modelsDir.create(recursive: true);
    final packageFile = File('${modelsDir.path}/${asset.filename}');
    if (!await packageFile.exists() &&
        await _hasLegacyCompleteModelFiles(modelDir)) {
      await _writeCompletionMarker(modelDir);
      onProgress?.call(
        ModelDownloadProgress(
          slug: asset.slug,
          progress: 1,
          statusMessage: '${asset.sourceLabel} is already downloaded.',
        ),
      );
      return;
    }

    try {
      await _downloadPackage(asset, packageFile, onProgress: onProgress);
      await _extractPackage(asset, packageFile, modelDir, onProgress);
      await packageFile.delete();
    } on _PreservePartialDownloadException catch (error) {
      throw AppError(
        'Direct Cactus model download paused for ${asset.slug}.',
        cause: error,
      );
    } on Object catch (error) {
      await _cleanupPartialDownload(packageFile, modelDir);
      throw AppError(
        'Direct Cactus model download failed for ${asset.slug}.',
        cause: error,
      );
    }
  }

  Future<void> _downloadPackage(
    CactusModelDownloadAsset asset,
    File packageFile, {
    void Function(ModelDownloadProgress progress)? onProgress,
  }) async {
    final client = HttpClient();

    try {
      await packageFile.parent.create(recursive: true);
      onProgress?.call(
        ModelDownloadProgress(
          slug: asset.slug,
          statusMessage: 'Starting ${asset.sourceLabel} download...',
        ),
      );

      final existingBytes = await packageFile.exists()
          ? await packageFile.length()
          : 0;
      final response = await _openDownloadResponse(
        client: client,
        uri: Uri.parse(asset.downloadUrl),
        resumeFrom: existingBytes > 0 ? existingBytes : null,
      );
      final isResuming = existingBytes > 0;
      final canAppend =
          isResuming && response.statusCode == HttpStatus.partialContent;
      if (isResuming && response.statusCode == HttpStatus.ok) {
        throw _PreservePartialDownloadException(
          'Download host did not honor Range resume for ${asset.slug}; '
          'keeping the existing partial package.',
        );
      }
      if (response.statusCode != HttpStatus.ok &&
          response.statusCode != HttpStatus.partialContent) {
        throw HttpException(
          'Download returned HTTP ${response.statusCode}.',
          uri: Uri.parse(asset.downloadUrl),
        );
      }

      final sink = packageFile.openWrite(
        mode: canAppend ? FileMode.append : FileMode.write,
      );
      final initialBytes = canAppend ? existingBytes : 0;
      final contentLength = _downloadContentLength(
        response: response,
        initialBytes: initialBytes,
      );
      var totalBytes = initialBytes;

      try {
        await for (final chunk in response) {
          sink.add(chunk);
          totalBytes += chunk.length;

          final progress = contentLength > 0
              ? totalBytes / contentLength
              : null;
          onProgress?.call(
            ModelDownloadProgress(
              slug: asset.slug,
              progress: progress,
              statusMessage:
                  'Downloaded ${_megabytes(totalBytes)} MB of ${asset.sourceLabel}...',
            ),
          );
        }
      } finally {
        await sink.close();
      }

      if (!await packageFile.exists() || await packageFile.length() == 0) {
        throw FileSystemException(
          'Downloaded package was not written.',
          packageFile.path,
        );
      }
    } finally {
      client.close(force: true);
    }
  }

  Future<HttpClientResponse> _openDownloadResponse({
    required HttpClient client,
    required Uri uri,
    required int? resumeFrom,
    int redirects = 0,
  }) async {
    if (redirects > 5) {
      throw HttpException('Too many redirects while downloading.', uri: uri);
    }

    final request = await client.getUrl(uri);
    request.followRedirects = false;
    if (resumeFrom != null && resumeFrom > 0) {
      request.headers.set(HttpHeaders.rangeHeader, 'bytes=$resumeFrom-');
    }

    final response = await request.close();
    if (_isRedirect(response.statusCode)) {
      final location = response.headers.value(HttpHeaders.locationHeader);
      await response.drain<void>();
      if (location == null || location.trim().isEmpty) {
        throw HttpException(
          'Download redirect did not include a Location header.',
          uri: uri,
        );
      }

      return _openDownloadResponse(
        client: client,
        uri: uri.resolve(location),
        resumeFrom: resumeFrom,
        redirects: redirects + 1,
      );
    }

    return response;
  }

  bool _isRedirect(int statusCode) {
    return statusCode == HttpStatus.movedPermanently ||
        statusCode == HttpStatus.found ||
        statusCode == HttpStatus.seeOther ||
        statusCode == HttpStatus.temporaryRedirect ||
        statusCode == HttpStatus.permanentRedirect;
  }

  int _downloadContentLength({
    required HttpClientResponse response,
    required int initialBytes,
  }) {
    final contentRange = response.headers.value(HttpHeaders.contentRangeHeader);
    final totalFromRange = _totalBytesFromContentRange(contentRange);
    if (totalFromRange != null) {
      return totalFromRange;
    }

    if (response.contentLength > 0) {
      return initialBytes + response.contentLength;
    }

    return -1;
  }

  int? _totalBytesFromContentRange(String? value) {
    if (value == null) {
      return null;
    }

    final match = RegExp(r'^bytes\s+\d+-\d+/(\d+)$').firstMatch(value.trim());
    if (match == null) {
      return null;
    }

    return int.tryParse(match.group(1)!);
  }

  Future<void> _extractPackage(
    CactusModelDownloadAsset asset,
    File packageFile,
    Directory modelDir,
    void Function(ModelDownloadProgress progress)? onProgress,
  ) async {
    onProgress?.call(
      ModelDownloadProgress(
        slug: asset.slug,
        progress: 1,
        statusMessage: 'Extracting ${asset.sourceLabel}...',
      ),
    );

    final stagingDir = Directory('${modelDir.path}.tmp');
    if (await stagingDir.exists()) {
      await stagingDir.delete(recursive: true);
    }
    await stagingDir.create(recursive: true);
    final inputStream = InputFileStream(packageFile.path);

    try {
      final archive = ZipDecoder().decodeStream(inputStream);
      final rootFolderName = _rootFolderName(archive);
      final symbolicLinks = <ArchiveFile>[];

      for (final file in archive.files) {
        if (file.isSymbolicLink) {
          symbolicLinks.add(file);
          continue;
        }

        if (!file.isFile && !file.isDirectory) {
          continue;
        }

        final relativePath = _relativePath(file.name, rootFolderName);
        if (relativePath.isEmpty) {
          continue;
        }

        final outputPath = '${stagingDir.path}/$relativePath';
        if (file.isDirectory) {
          await Directory(outputPath).create(recursive: true);
          continue;
        }

        await File(outputPath).parent.create(recursive: true);
        final outputStream = OutputFileStream(outputPath);
        try {
          file.writeContent(outputStream);
        } finally {
          outputStream.closeSync();
        }
      }

      for (final file in symbolicLinks) {
        final relativePath = _relativePath(file.name, rootFolderName);
        if (relativePath.isEmpty) {
          continue;
        }

        final link = Link('${stagingDir.path}/$relativePath');
        await link.parent.create(recursive: true);
        await link.create(file.symbolicLink!, recursive: true);
      }
    } finally {
      inputStream.close();
    }

    await _writeCompletionMarker(stagingDir);
    if (await modelDir.exists()) {
      await modelDir.delete(recursive: true);
    }
    await stagingDir.rename(modelDir.path);
  }

  String? _rootFolderName(Archive archive) {
    for (final file in archive.files) {
      final pathParts = file.name.split('/');
      if (pathParts.isNotEmpty && pathParts.first.isNotEmpty) {
        return pathParts.first;
      }
    }

    return null;
  }

  String _relativePath(String path, String? rootFolderName) {
    if (rootFolderName == null || !path.startsWith('$rootFolderName/')) {
      return path;
    }

    return path.substring(rootFolderName.length + 1);
  }

  Future<bool> _hasModelFiles(Directory modelDir) async {
    if (!await modelDir.exists()) {
      return false;
    }

    return File('${modelDir.path}/$_completionMarkerName').exists();
  }

  Future<bool> _hasLegacyCompleteModelFiles(Directory modelDir) async {
    if (!await modelDir.exists()) {
      return false;
    }

    final files = await modelDir.list(followLinks: false).toList();
    if (files.length < 16) {
      return false;
    }

    return files.whereType<File>().any((file) {
      final name = file.uri.pathSegments.last.toLowerCase();
      return name == 'tokenizer.json' ||
          name == 'special_tokens.json' ||
          name == 'tokenizer_config.json';
    });
  }

  Future<void> _writeCompletionMarker(Directory modelDir) {
    return File(
      '${modelDir.path}/$_completionMarkerName',
    ).writeAsString(DateTime.now().toUtc().toIso8601String());
  }

  Future<void> _cleanupPartialDownload(
    File packageFile,
    Directory modelDir,
  ) async {
    try {
      if (await packageFile.exists()) {
        await packageFile.delete();
      }

      if (await modelDir.exists()) {
        await modelDir.delete(recursive: true);
      }

      final stagingDir = Directory('${modelDir.path}.tmp');
      if (await stagingDir.exists()) {
        await stagingDir.delete(recursive: true);
      }
    } on Object catch (error) {
      debugPrint('Failed to clean up partial direct model download: $error');
    }
  }

  int _megabytes(int bytes) {
    return bytes ~/ (1024 * 1024);
  }
}

class _PreservePartialDownloadException implements Exception {
  const _PreservePartialDownloadException(this.message);

  final String message;

  @override
  String toString() => message;
}
