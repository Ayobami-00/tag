import 'package:tag/core/platform/share_intake_service.dart';
import 'package:tag/core/use_cases/use_cases.dart';
import 'package:tag/features/source_ingestion/domain/entities/source_item_entity.dart';
import 'package:tag/features/source_ingestion/domain/use_cases/ingest_shared_source.dart';

class ImportPendingSharedSources
    with UseCases<List<SourceItemEntity>, NoParams> {
  const ImportPendingSharedSources({
    required ShareIntakeService shareIntakeService,
    required IngestSharedSource ingestSharedSource,
  }) : _shareIntakeService = shareIntakeService,
       _ingestSharedSource = ingestSharedSource;

  final ShareIntakeService _shareIntakeService;
  final IngestSharedSource _ingestSharedSource;

  @override
  Future<List<SourceItemEntity>> call(NoParams params) async {
    final pendingSources = await _shareIntakeService.getPendingSharedSources();
    final seenPayloadIds = <String>{};
    final importedSources = <SourceItemEntity>[];

    for (final pendingSource in pendingSources) {
      if (!seenPayloadIds.add(pendingSource.id)) {
        continue;
      }

      final ingestParams = _paramsFor(pendingSource);
      if (ingestParams == null) {
        continue;
      }

      try {
        final source = await _ingestSharedSource(ingestParams);
        importedSources.add(source);
        await _shareIntakeService.markPendingSharedSourceImported(
          pendingSource.id,
        );
      } on Object {
        // Keep the payload pending so the next app launch can retry the import.
      }
    }

    return importedSources;
  }

  IngestSharedSourceParams? _paramsFor(PendingSharedSource source) {
    final originalUri = 'tag-share://${source.id}';
    return switch (source.type) {
      PendingSharedSourceType.image => _imageParams(source, originalUri),
      PendingSharedSourceType.text => _textParams(source, originalUri),
      PendingSharedSourceType.url => _urlParams(source, originalUri),
    };
  }

  IngestSharedSourceParams? _imageParams(
    PendingSharedSource source,
    String originalUri,
  ) {
    final filePath = source.filePath?.trim();
    if (filePath == null || filePath.isEmpty) {
      return null;
    }

    return IngestSharedSourceParams(
      payloadId: source.id,
      originalUri: originalUri,
      sourceType: SourceItemType.image,
      filePath: filePath,
      displayName: source.suggestedName,
      receivedAt: source.receivedAt,
      sourceApplication: source.sourceApplication,
      uti: source.uti,
    );
  }

  IngestSharedSourceParams? _textParams(
    PendingSharedSource source,
    String originalUri,
  ) {
    final text = source.text?.trim();
    if (text == null || text.isEmpty) {
      return null;
    }

    return IngestSharedSourceParams(
      payloadId: source.id,
      originalUri: originalUri,
      sourceType: SourceItemType.text,
      rawText: text,
      displayName: source.suggestedName,
      receivedAt: source.receivedAt,
      sourceApplication: source.sourceApplication,
      uti: source.uti,
    );
  }

  IngestSharedSourceParams? _urlParams(
    PendingSharedSource source,
    String originalUri,
  ) {
    final url = (source.url ?? source.text)?.trim();
    if (url == null || url.isEmpty) {
      return null;
    }

    return IngestSharedSourceParams(
      payloadId: source.id,
      originalUri: originalUri,
      sourceType: SourceItemType.link,
      rawText: url,
      displayName: source.suggestedName,
      receivedAt: source.receivedAt,
      sourceApplication: source.sourceApplication,
      uti: source.uti,
    );
  }
}
