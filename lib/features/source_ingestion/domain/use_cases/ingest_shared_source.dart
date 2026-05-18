import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:path/path.dart' as p;
import 'package:tag/core/use_cases/use_cases.dart';
import 'package:tag/features/source_ingestion/domain/entities/source_item_entity.dart';
import 'package:tag/features/source_ingestion/domain/repositories/source_repository.dart';
import 'package:tag/features/source_ingestion/domain/use_cases/queue_source_processing.dart';
import 'package:tag/features/source_ingestion/domain/use_cases/source_id_factory.dart';
import 'package:tag/features/source_ingestion/domain/use_cases/store_source_file.dart';

class IngestSharedSourceParams extends Equatable {
  const IngestSharedSourceParams({
    required this.originalUri,
    required this.sourceType,
    this.payloadId,
    this.rawText,
    this.filePath,
    this.displayName,
    this.receivedAt,
    this.sourceApplication,
    this.uti,
  });

  final String originalUri;
  final SourceItemType sourceType;
  final String? payloadId;
  final String? rawText;
  final String? filePath;
  final String? displayName;
  final int? receivedAt;
  final String? sourceApplication;
  final String? uti;

  @override
  List<Object?> get props => [
    originalUri,
    sourceType,
    payloadId,
    rawText,
    filePath,
    displayName,
    receivedAt,
    sourceApplication,
    uti,
  ];
}

class IngestSharedSource
    with UseCases<SourceItemEntity, IngestSharedSourceParams> {
  const IngestSharedSource({
    required StoreSourceFile storeSourceFile,
    required SourceRepository sourceRepository,
    required QueueSourceProcessing queueSourceProcessing,
    SourceIdFactory? sourceIdFactory,
  }) : _storeSourceFile = storeSourceFile,
       _sourceRepository = sourceRepository,
       _queueSourceProcessing = queueSourceProcessing,
       _sourceIdFactory = sourceIdFactory ?? defaultSourceIdFactory;

  final StoreSourceFile _storeSourceFile;
  final SourceRepository _sourceRepository;
  final QueueSourceProcessing _queueSourceProcessing;
  final SourceIdFactory _sourceIdFactory;

  @override
  Future<SourceItemEntity> call(IngestSharedSourceParams params) async {
    final existing = await _sourceRepository.getSourceByOriginalUri(
      params.originalUri,
    );
    if (existing != null) {
      return existing;
    }

    final sourceId = _sourceIdFactory();
    final sourceType = params.sourceType;
    final localFilePath = await _storeSharedPayload(sourceId, params);
    final source = await _sourceRepository.createSource(
      CreateSourceRequest(
        id: sourceId,
        type: sourceType,
        originalUri: params.originalUri,
        localFilePath: localFilePath,
        rawText: _rawTextFor(params),
        sourceSummary: _sourceSummaryFor(params),
        appSource: 'iOS Share',
        detectedLinksJson: _detectedLinksJsonFor(params),
        metadataJson: jsonEncode(_metadataFor(params)),
      ),
    );

    _queueWithoutBlocking(source.id);
    return source;
  }

  Future<String?> _storeSharedPayload(
    String sourceId,
    IngestSharedSourceParams params,
  ) {
    return switch (params.sourceType) {
      SourceItemType.image ||
      SourceItemType.screenshot => _storeImage(sourceId, params),
      SourceItemType.link ||
      SourceItemType.text ||
      SourceItemType.chat ||
      SourceItemType.savedPost ||
      SourceItemType.emailText ||
      SourceItemType.manual => _storeText(sourceId, params),
    };
  }

  Future<String> _storeImage(String sourceId, IngestSharedSourceParams params) {
    final filePath = params.filePath?.trim();
    if (filePath == null || filePath.isEmpty) {
      throw ArgumentError.value(
        params.filePath,
        'filePath',
        'Shared image payload requires a file path.',
      );
    }

    return _storeSourceFile(
      StoreSourceFileParams.image(
        sourceId: sourceId,
        sourceFile: File(filePath),
        extension: p.extension(filePath),
      ),
    );
  }

  Future<String> _storeText(String sourceId, IngestSharedSourceParams params) {
    final text = _rawTextFor(params)?.trim();
    if (text == null || text.isEmpty) {
      throw ArgumentError.value(
        params.rawText ?? params.originalUri,
        'rawText',
        'Shared text payload requires text.',
      );
    }

    return _storeSourceFile(
      StoreSourceFileParams.text(sourceId: sourceId, text: text),
    );
  }

  String? _rawTextFor(IngestSharedSourceParams params) {
    if (params.sourceType == SourceItemType.link) {
      return params.rawText?.trim().isNotEmpty == true
          ? params.rawText!.trim()
          : params.originalUri;
    }

    return params.rawText?.trim();
  }

  String _detectedLinksJsonFor(IngestSharedSourceParams params) {
    if (params.sourceType != SourceItemType.link) {
      return '[]';
    }

    final link = _rawTextFor(params);
    return link == null ? '[]' : jsonEncode([link]);
  }

  String _sourceSummaryFor(IngestSharedSourceParams params) {
    final displayName = params.displayName?.trim();
    return switch (params.sourceType) {
      SourceItemType.image || SourceItemType.screenshot =>
        displayName == null || displayName.isEmpty
            ? 'Shared image'
            : 'Shared image - $displayName',
      SourceItemType.link => 'Shared link',
      SourceItemType.text => 'Shared text',
      SourceItemType.chat => 'Shared chat text',
      SourceItemType.savedPost => 'Shared post',
      SourceItemType.emailText => 'Shared email text',
      SourceItemType.manual => 'Shared source',
    };
  }

  Map<String, Object?> _metadataFor(IngestSharedSourceParams params) {
    return <String, Object?>{
      'imported_via': 'ios_share_extension',
      if (params.payloadId != null) 'share_payload_id': params.payloadId,
      if (params.displayName != null) 'display_name': params.displayName,
      if (params.filePath != null) 'shared_file_path': params.filePath,
      if (params.receivedAt != null) 'received_at': params.receivedAt,
      if (params.sourceApplication != null)
        'source_application': params.sourceApplication,
      if (params.uti != null) 'uti': params.uti,
    };
  }

  void _queueWithoutBlocking(String sourceId) {
    unawaited(
      _queueSourceProcessing(
        QueueSourceProcessingParams(sourceId),
      ).catchError((_) {}),
    );
  }
}
