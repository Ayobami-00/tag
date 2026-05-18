import 'dart:async';
import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:tag/core/use_cases/use_cases.dart';
import 'package:tag/features/source_ingestion/domain/entities/source_item_entity.dart';
import 'package:tag/features/source_ingestion/domain/repositories/source_repository.dart';
import 'package:tag/features/source_ingestion/domain/use_cases/queue_source_processing.dart';
import 'package:tag/features/source_ingestion/domain/use_cases/source_id_factory.dart';
import 'package:tag/features/source_ingestion/domain/use_cases/store_source_file.dart';

class CreateTextSourceParams extends Equatable {
  const CreateTextSourceParams(this.text);

  final String text;

  @override
  List<Object?> get props => [text];
}

class CreateTextSource with UseCases<SourceItemEntity, CreateTextSourceParams> {
  const CreateTextSource({
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
  Future<SourceItemEntity> call(CreateTextSourceParams params) async {
    final text = params.text.trim();
    if (text.isEmpty) {
      throw ArgumentError.value(params.text, 'text', 'Text is required.');
    }

    final sourceId = _sourceIdFactory();
    final localFilePath = await _storeSourceFile(
      StoreSourceFileParams.text(sourceId: sourceId, text: text),
    );
    final source = await _sourceRepository.createSource(
      CreateSourceRequest(
        id: sourceId,
        type: SourceItemType.text,
        localFilePath: localFilePath,
        rawText: text,
        sourceSummary: 'Manual text paste',
        metadataJson: jsonEncode({
          'imported_via': 'manual_text',
          'character_count': text.length,
          'line_count': '\n'.allMatches(text).length + 1,
        }),
      ),
    );

    _queueWithoutBlocking(source.id);
    return source;
  }

  void _queueWithoutBlocking(String sourceId) {
    unawaited(
      _queueSourceProcessing(
        QueueSourceProcessingParams(sourceId),
      ).catchError((_) {}),
    );
  }
}
