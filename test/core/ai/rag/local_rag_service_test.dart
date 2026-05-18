import 'dart:io';
import 'dart:math' as math;

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tag/core/ai/cactus/cactus_model_registry.dart';
import 'package:tag/core/ai/cactus/cactus_model_service.dart';
import 'package:tag/core/ai/rag/local_rag_service.dart';
import 'package:tag/core/ai/rag/local_rag_service_impl.dart';
import 'package:tag/core/ai/rag/local_vector_index.dart';
import 'package:tag/core/ai/rag/source_chunker.dart';
import 'package:tag/core/local_storage/database/data_sources/rag_local_data_source.dart';
import 'package:tag/core/local_storage/database/tag_database.dart';
import 'package:tag/core/local_storage/file_store/local_file_store_impl.dart';

void main() {
  late TagDatabase database;
  late Directory documentsDirectory;
  late _FakeCactusModelService cactusModelService;
  late _InMemoryVectorIndex vectorIndex;
  late LocalRagService localRagService;

  setUp(() async {
    database = TagDatabase.forTesting(NativeDatabase.memory());
    documentsDirectory = await Directory.systemTemp.createTemp(
      'tag_rag_service_',
    );
    cactusModelService = _FakeCactusModelService();
    vectorIndex = _InMemoryVectorIndex();
    localRagService = LocalRagServiceImpl(
      cactusModelService: cactusModelService,
      localDataSource: DriftRagLocalDataSource(database),
      localFileStore: LocalFileStoreImpl(
        appDocumentsDirectoryProvider: () async => documentsDirectory,
      ),
      vectorIndex: vectorIndex,
      sourceChunker: const SourceChunker(),
      embeddingModelSlugProvider: () async =>
          CactusModelRegistry.defaultEmbeddingModelSlug,
      now: () => DateTime.utc(2026, 5, 15, 10),
    );
  });

  tearDown(() async {
    await database.close();
    if (await documentsDirectory.exists()) {
      await documentsDirectory.delete(recursive: true);
    }
  });

  test('source text chunks are created and embedded locally', () async {
    await _insertSource(database, id: 'src_cuda', summary: 'CUDA notes');
    final text = List.generate(420, (index) {
      return index.isEven ? 'CUDA memory hierarchy' : 'GPU kernels';
    }).join(' ');

    final result = await localRagService.indexSource(
      sourceId: 'src_cuda',
      text: text,
    );

    final chunks = await database.select(database.sourceTextChunks).get();
    final records = await database.select(database.ragIndexRecords).get();
    expect(result.chunkCount, greaterThan(1));
    expect(chunks, hasLength(result.chunkCount));
    expect(records, hasLength(result.chunkCount));
    expect(cactusModelService.embeddingRequests, hasLength(result.chunkCount));
    expect(
      cactusModelService.embeddingRequests,
      everyElement(startsWith('search_document: ')),
    );
    for (final chunk in chunks) {
      expect(
        chunk.embeddingModelSlug,
        CactusModelRegistry.defaultEmbeddingModelSlug,
      );
      expect(chunk.vectorIndexName, records.first.indexName);
      expect(chunk.vectorExternalId, isNotNull);
      expect(chunk.embeddingDimension, _FakeCactusModelService.dimension);
    }
    expect(
      records.map((record) => record.sourceChunkId),
      containsAll(chunks.map((chunk) => chunk.id)),
    );
    expect(vectorIndex.documentCount, result.chunkCount);
  });

  test('empty text is skipped and clears existing index rows', () async {
    await _insertSource(database, id: 'src_empty', summary: 'Empty source');
    await localRagService.indexSource(
      sourceId: 'src_empty',
      text: 'Please buy bread at 8pm',
    );

    final result = await localRagService.indexSource(
      sourceId: 'src_empty',
      text: '   \n\t  ',
    );

    expect(result.skippedEmptyText, isTrue);
    expect(result.removedChunkCount, 1);
    expect(await database.select(database.sourceTextChunks).get(), isEmpty);
    expect(await database.select(database.ragIndexRecords).get(), isEmpty);
    expect(vectorIndex.documentCount, 0);
  });

  test('query returns the expected fixture chunk', () async {
    await _insertSource(database, id: 'src_cuda', summary: 'CUDA reading');
    await _insertSource(database, id: 'src_bread', summary: 'Household note');
    await localRagService.indexSource(
      sourceId: 'src_cuda',
      text: 'Saved CUDA article about GPU memory hierarchy and kernels.',
    );
    await localRagService.indexSource(
      sourceId: 'src_bread',
      text: 'WhatsApp message: please buy bread and milk at 8pm.',
    );

    final cudaResults = await localRagService.search(query: 'CUDA', topK: 3);
    final breadResults = await localRagService.search(query: 'bread', topK: 3);

    expect(cudaResults.first.source.id, 'src_cuda');
    expect(cudaResults.first.chunk.chunkText, contains('CUDA'));
    expect(breadResults.first.source.id, 'src_bread');
    expect(breadResults.first.chunk.chunkText, contains('bread'));
    expect(
      cactusModelService.embeddingRequests.where(
        (request) => request.startsWith('search_query: '),
      ),
      isEmpty,
    );
  });

  test(
    'high-confidence keyword results skip close vector candidates',
    () async {
      final keywordBlindVectorIndex = _KeywordBlindVectorIndex();
      final service = LocalRagServiceImpl(
        cactusModelService: cactusModelService,
        localDataSource: DriftRagLocalDataSource(database),
        localFileStore: LocalFileStoreImpl(
          appDocumentsDirectoryProvider: () async => documentsDirectory,
        ),
        vectorIndex: keywordBlindVectorIndex,
        sourceChunker: const SourceChunker(),
        embeddingModelSlugProvider: () async =>
            CactusModelRegistry.defaultEmbeddingModelSlug,
        now: () => DateTime.utc(2026, 5, 15, 10),
      );
      await _insertSource(database, id: 'src_cuda', summary: 'CUDA reading');
      await _insertSource(database, id: 'src_bread', summary: 'Household note');
      await service.indexSource(
        sourceId: 'src_cuda',
        text: 'Saved CUDA article about GPU memory hierarchy and kernels.',
      );
      await service.indexSource(
        sourceId: 'src_bread',
        text: 'WhatsApp message: please buy bread and milk at 8pm.',
      );

      final results = await service.search(query: 'CUDA', topK: 2);

      expect(results, hasLength(1));
      expect(results.first.source.id, 'src_cuda');
      expect(
        cactusModelService.embeddingRequests.where(
          (request) => request.startsWith('search_query: '),
        ),
        isEmpty,
      );
    },
  );

  test(
    'keyword metadata search finds sources before vector rows exist',
    () async {
      final service = LocalRagServiceImpl(
        cactusModelService: _FailingEmbeddingModelService(),
        localDataSource: DriftRagLocalDataSource(database),
        localFileStore: LocalFileStoreImpl(
          appDocumentsDirectoryProvider: () async => documentsDirectory,
        ),
        vectorIndex: vectorIndex,
        sourceChunker: const SourceChunker(),
        embeddingModelSlugProvider: () async =>
            CactusModelRegistry.defaultEmbeddingModelSlug,
        now: () => DateTime.utc(2026, 5, 15, 10),
      );
      await _insertSource(
        database,
        id: 'src_ai_saturday',
        summary: 'Complete TRI AI Saturdays Cohort application',
      );

      final results = await service.search(query: 'Why AI Saturdays card?');

      expect(results, isNotEmpty);
      expect(results.first.source.id, 'src_ai_saturday');
      expect(results.first.chunk.id, startsWith('keyword_'));
      expect(results.first.chunk.preview, contains('AI Saturdays'));
    },
  );

  test('exact no-result recipe lookups do not pay vector latency', () async {
    await _insertSource(database, id: 'src_cuda', summary: 'CUDA reading');
    await localRagService.indexSource(
      sourceId: 'src_cuda',
      text: 'Saved CUDA article about GPU memory hierarchy and kernels.',
    );
    final requestsBeforeSearch = cactusModelService.embeddingRequests.length;

    final results = await localRagService.search(
      query: 'Do I have cooking recipes?',
      topK: 3,
    );

    expect(results, isEmpty);
    expect(
      cactusModelService.embeddingRequests,
      hasLength(requestsBeforeSearch),
    );
    expect(
      cactusModelService.embeddingRequests.where(
        (request) => request.startsWith('search_query: '),
      ),
      isEmpty,
    );
  });

  test('changed text invalidates stale vector records', () async {
    await _insertSource(database, id: 'src_change', summary: 'Saved note');
    await localRagService.indexSource(
      sourceId: 'src_change',
      text: 'CUDA weekend study reminder.',
    );
    final firstRecord = await database.select(database.ragIndexRecords).get();
    final firstRequestCount = cactusModelService.embeddingRequests.length;
    final chunk = await database.select(database.sourceTextChunks).getSingle();

    await (database.update(
      database.sourceTextChunks,
    )..where((table) => table.id.equals(chunk.id))).write(
      const SourceTextChunksCompanion(chunkText: Value('Buy bread at 8pm.')),
    );

    final staleStatus = await localRagService.getIndexStatus();
    expect(staleStatus.staleRecordCount, 1);

    final result = await localRagService.indexSource(
      sourceId: 'src_change',
      text: 'Buy bread at 8pm.',
    );
    final secondRecord = await database.select(database.ragIndexRecords).get();
    final freshStatus = await localRagService.getIndexStatus();

    expect(result.embeddedChunkCount, 1);
    expect(result.reusedChunkCount, 0);
    expect(cactusModelService.embeddingRequests.length, firstRequestCount + 1);
    expect(
      secondRecord.single.documentTextHash,
      isNot(firstRecord.single.documentTextHash),
    );
    expect(freshStatus.staleRecordCount, 0);
  });
}

Future<void> _insertSource(
  TagDatabase database, {
  required String id,
  required String summary,
}) async {
  final now = DateTime.utc(2026, 5, 15, 9).millisecondsSinceEpoch;
  await database
      .into(database.sourceItems)
      .insert(
        SourceItemsCompanion.insert(
          id: id,
          type: 'text',
          rawText: Value(summary),
          extractedText: Value(summary),
          sourceSummary: Value(summary),
          contentType: const Value('message'),
          processingState: const Value('extracted'),
          createdAt: now,
          updatedAt: now,
        ),
      );
}

class _FakeCactusModelService implements CactusModelService {
  static const dimension = 256;

  final List<String> embeddingRequests = [];

  @override
  Future<AiEmbeddingResult> embedText({
    required String modelSlug,
    required String text,
  }) async {
    embeddingRequests.add(text);
    return AiEmbeddingResult(
      modelSlug: modelSlug,
      embeddings: _embeddingFor(text),
      dimension: dimension,
    );
  }

  List<double> _embeddingFor(String text) {
    final lower = text.toLowerCase();
    final values = List<double>.filled(dimension, 0);
    void setTerm(int index, String term, double weight) {
      if (lower.contains(term)) {
        values[index] = weight;
      }
    }

    setTerm(0, 'cuda', 1);
    setTerm(1, 'gpu', 0.8);
    setTerm(2, 'bread', 1);
    setTerm(3, 'milk', 0.6);
    setTerm(4, 'weekend', 0.7);
    if (values.every((value) => value == 0)) {
      values[5] = 0.1;
    }

    return values;
  }

  @override
  Future<List<LocalAiModelInfo>> getAvailableModels() async {
    return const [
      LocalAiModelInfo(
        slug: CactusModelRegistry.defaultEmbeddingModelSlug,
        displayName: 'Nomic Embed Text v2 MoE',
        capabilities: {AiModelCapability.embedding},
      ),
    ];
  }

  @override
  Future<void> downloadModel(
    String slug, {
    void Function(ModelDownloadProgress progress)? onProgress,
  }) async {}

  @override
  Future<void> initializeModel(String slug) async {}

  @override
  Future<void> unloadModel(String slug) async {}

  @override
  Future<AiCompletionResult> complete({
    required String modelSlug,
    required List<AiChatMessage> messages,
    List<AiToolSchema> tools = const [],
    AiCompletionOptions options = const AiCompletionOptions(),
  }) {
    throw UnimplementedError();
  }

  @override
  Stream<String> streamComplete({
    required String modelSlug,
    required List<AiChatMessage> messages,
    List<AiToolSchema> tools = const [],
    AiCompletionOptions options = const AiCompletionOptions(),
  }) {
    throw UnimplementedError();
  }

  @override
  Future<AiVisionResult> completeWithImage({
    required String modelSlug,
    required String imagePath,
    required List<AiChatMessage> messages,
    List<AiToolSchema> tools = const [],
    AiCompletionOptions options = const AiCompletionOptions(),
  }) {
    throw UnimplementedError();
  }
}

class _FailingEmbeddingModelService extends _FakeCactusModelService {
  @override
  Future<AiEmbeddingResult> embedText({
    required String modelSlug,
    required String text,
  }) {
    throw StateError('embedding model is not downloaded locally');
  }
}

class _KeywordBlindVectorIndex implements LocalVectorIndex {
  final Map<String, Map<String, LocalVectorDocument>> _documentsByIndex = {};

  @override
  Future<void> upsertDocuments({
    required String indexPath,
    required int embeddingDimension,
    required List<LocalVectorDocument> documents,
  }) async {
    final documentsById = _documentsByIndex.putIfAbsent(indexPath, () => {});
    for (final document in documents) {
      documentsById[document.externalId] = document;
    }
  }

  @override
  Future<void> deleteDocuments({
    required String indexPath,
    required int embeddingDimension,
    required List<String> externalIds,
  }) async {
    final documentsById = _documentsByIndex[indexPath];
    if (documentsById == null) {
      return;
    }

    for (final externalId in externalIds) {
      documentsById.remove(externalId);
    }
  }

  @override
  Future<List<LocalVectorSearchHit>> search({
    required String indexPath,
    required int embeddingDimension,
    required List<double> embedding,
    required int topK,
  }) async {
    final documents = _documentsByIndex[indexPath]?.values ?? const [];
    final hits = documents.map((document) {
      return LocalVectorSearchHit(
        externalId: document.externalId,
        score: document.document.toLowerCase().contains('bread') ? 0.69 : 0.67,
      );
    }).toList()..sort((left, right) => right.score.compareTo(left.score));

    return hits.take(topK).toList(growable: false);
  }
}

class _InMemoryVectorIndex implements LocalVectorIndex {
  final Map<String, Map<String, LocalVectorDocument>> _documentsByIndex = {};

  int get documentCount {
    return _documentsByIndex.values.fold<int>(
      0,
      (sum, documents) => sum + documents.length,
    );
  }

  @override
  Future<void> upsertDocuments({
    required String indexPath,
    required int embeddingDimension,
    required List<LocalVectorDocument> documents,
  }) async {
    final documentsById = _documentsByIndex.putIfAbsent(indexPath, () => {});
    for (final document in documents) {
      documentsById[document.externalId] = document;
    }
  }

  @override
  Future<void> deleteDocuments({
    required String indexPath,
    required int embeddingDimension,
    required List<String> externalIds,
  }) async {
    final documentsById = _documentsByIndex[indexPath];
    if (documentsById == null) {
      return;
    }

    for (final externalId in externalIds) {
      documentsById.remove(externalId);
    }
  }

  @override
  Future<List<LocalVectorSearchHit>> search({
    required String indexPath,
    required int embeddingDimension,
    required List<double> embedding,
    required int topK,
  }) async {
    final documents = _documentsByIndex[indexPath]?.values ?? const [];
    final hits = documents.map((document) {
      return LocalVectorSearchHit(
        externalId: document.externalId,
        score: _cosine(embedding, document.embedding),
      );
    }).toList()..sort((left, right) => right.score.compareTo(left.score));

    return hits.take(topK).toList(growable: false);
  }

  double _cosine(List<double> left, List<double> right) {
    final length = math.min(left.length, right.length);
    var dot = 0.0;
    var leftNorm = 0.0;
    var rightNorm = 0.0;
    for (var index = 0; index < length; index++) {
      dot += left[index] * right[index];
      leftNorm += left[index] * left[index];
      rightNorm += right[index] * right[index];
    }

    if (leftNorm == 0 || rightNorm == 0) {
      return 0;
    }

    return dot / (math.sqrt(leftNorm) * math.sqrt(rightNorm));
  }
}
