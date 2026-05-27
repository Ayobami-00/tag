import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:tag/core/use_cases/use_cases.dart';
import 'package:tag/features/source_ingestion/domain/entities/source_item_entity.dart';
import 'package:tag/features/source_ingestion/domain/repositories/source_repository.dart';
import 'package:tag/features/source_ingestion/domain/services/manual_source_picker.dart';
import 'package:tag/features/source_ingestion/domain/use_cases/queue_source_processing.dart';
import 'package:tag/features/source_ingestion/domain/use_cases/source_id_factory.dart';
import 'package:tag/features/source_ingestion/domain/use_cases/store_source_file.dart';

class ImportImageSourceParams extends Equatable {
  const ImportImageSourceParams({this.pickedImage, this.sourceDescription});

  final PickedImageSource? pickedImage;
  final String? sourceDescription;

  @override
  List<Object?> get props => [pickedImage, sourceDescription];
}

class ImportImageSource
    with UseCases<SourceItemEntity?, ImportImageSourceParams> {
  const ImportImageSource({
    required ManualSourcePicker manualSourcePicker,
    required StoreSourceFile storeSourceFile,
    required SourceRepository sourceRepository,
    required QueueSourceProcessing queueSourceProcessing,
    SourceIdFactory? sourceIdFactory,
  }) : _manualSourcePicker = manualSourcePicker,
       _storeSourceFile = storeSourceFile,
       _sourceRepository = sourceRepository,
       _queueSourceProcessing = queueSourceProcessing,
       _sourceIdFactory = sourceIdFactory ?? defaultSourceIdFactory;

  final ManualSourcePicker _manualSourcePicker;
  final StoreSourceFile _storeSourceFile;
  final SourceRepository _sourceRepository;
  final QueueSourceProcessing _queueSourceProcessing;
  final SourceIdFactory _sourceIdFactory;

  @override
  Future<SourceItemEntity?> call(ImportImageSourceParams params) async {
    final pickedImage =
        params.pickedImage ?? await _manualSourcePicker.pickImage();
    if (pickedImage == null) {
      return null;
    }

    final sourceDescription = _normalizedSourceDescription(
      params.sourceDescription,
    );
    final sourceId = _sourceIdFactory();
    final localFilePath = await _storeSourceFile(
      StoreSourceFileParams.image(
        sourceId: sourceId,
        sourceFile: File(pickedImage.path),
        extension: pickedImage.extension,
      ),
    );
    final source = await _sourceRepository.createSource(
      CreateSourceRequest(
        id: sourceId,
        type: SourceItemType.image,
        originalUri: pickedImage.originalUri ?? pickedImage.path,
        localFilePath: localFilePath,
        sourceSummary: _summaryForPickedImage(pickedImage),
        metadataJson: jsonEncode({
          'imported_via': 'manual_image',
          if (sourceDescription != null)
            'source_description': sourceDescription,
          if (pickedImage.displayName != null)
            'file_name': pickedImage.displayName,
          if (pickedImage.extension != null) 'extension': pickedImage.extension,
          if (pickedImage.sizeBytes != null)
            'size_bytes': pickedImage.sizeBytes,
        }),
      ),
    );

    _queueWithoutBlocking(source.id, sourceDescription: sourceDescription);
    return source;
  }

  void _queueWithoutBlocking(String sourceId, {String? sourceDescription}) {
    unawaited(
      _queueSourceProcessing(
        QueueSourceProcessingParams(
          sourceId,
          sourceDescription: sourceDescription,
        ),
      ).catchError((_) {}),
    );
  }

  String _summaryForPickedImage(PickedImageSource pickedImage) {
    final displayName = pickedImage.displayName?.trim();
    if (displayName == null || displayName.isEmpty) {
      return 'Manual image';
    }

    return 'Manual image - $displayName';
  }

  String? _normalizedSourceDescription(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }

    return trimmed;
  }
}
