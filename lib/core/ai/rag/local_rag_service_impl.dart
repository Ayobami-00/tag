import 'dart:math' as math;

import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:tag/core/ai/cactus/cactus_model_registry.dart';
import 'package:tag/core/ai/cactus/cactus_model_service.dart';
import 'package:tag/core/ai/rag/local_rag_service.dart';
import 'package:tag/core/ai/rag/local_vector_index.dart';
import 'package:tag/core/ai/rag/rag_models.dart';
import 'package:tag/core/ai/rag/rag_text_hash.dart';
import 'package:tag/core/ai/rag/source_chunker.dart';
import 'package:tag/core/local_storage/database/data_sources/rag_local_data_source.dart';
import 'package:tag/core/local_storage/database/tag_database.dart'
    as database_models;
import 'package:tag/core/local_storage/file_store/local_file_store.dart';
import 'package:tag/features/cards/domain/use_cases/card_title_normalizer.dart';

typedef EmbeddingModelSlugProvider = Future<String> Function();

class LocalRagServiceImpl implements LocalRagService {
  const LocalRagServiceImpl({
    required CactusModelService cactusModelService,
    required RagLocalDataSource localDataSource,
    required LocalFileStore localFileStore,
    required LocalVectorIndex vectorIndex,
    required SourceChunker sourceChunker,
    EmbeddingModelSlugProvider? embeddingModelSlugProvider,
    DateTime Function()? now,
  }) : _cactusModelService = cactusModelService,
       _localDataSource = localDataSource,
       _localFileStore = localFileStore,
       _vectorIndex = vectorIndex,
       _sourceChunker = sourceChunker,
       _embeddingModelSlugProvider = embeddingModelSlugProvider,
       _now = now ?? DateTime.now;

  final CactusModelService _cactusModelService;
  final RagLocalDataSource _localDataSource;
  final LocalFileStore _localFileStore;
  final LocalVectorIndex _vectorIndex;
  final SourceChunker _sourceChunker;
  final EmbeddingModelSlugProvider? _embeddingModelSlugProvider;
  final DateTime Function() _now;

  @override
  Future<LocalRagIndexResult> indexSource({
    required String sourceId,
    required String text,
    String? embeddingModelSlug,
  }) async {
    final resolvedModelSlug = await _resolveEmbeddingModelSlug(
      embeddingModelSlug,
    );
    final config = CactusModelRegistry.embeddingConfigForSlug(
      resolvedModelSlug,
    );
    final indexName = _indexNameFor(config);
    final indexPath = await _indexPath(indexName);
    final drafts = _sourceChunker.chunk(
      text,
      maxTokenEstimate: config.maxChunkTokens,
    );

    if (drafts.isEmpty) {
      final removed = await _localDataSource.deleteChunksForSource(sourceId);
      await _deleteRemovedVectors(removed);
      return LocalRagIndexResult(
        sourceId: sourceId,
        indexName: indexName,
        embeddingModelSlug: config.modelSlug,
        embeddingDimension: config.dimension,
        chunkCount: 0,
        embeddedChunkCount: 0,
        reusedChunkCount: 0,
        removedChunkCount: removed.length,
        skippedEmptyText: true,
      );
    }

    final existingRecords = await _localDataSource.loadChunksForSource(
      sourceId,
    );
    final existingByChunkId = {
      for (final record in existingRecords) record.chunk.id: record,
    };
    final retainedChunkIds = <String>{};
    var embeddedChunkCount = 0;
    var reusedChunkCount = 0;

    for (final draft in drafts) {
      final chunkId = _chunkId(sourceId, draft.chunkIndex);
      final externalId = _externalIdForChunk(
        indexName: indexName,
        sourceId: sourceId,
        chunkIndex: draft.chunkIndex,
      );
      final documentHash = RagTextHash.documentTextHash(draft.chunkText);
      retainedChunkIds.add(chunkId);

      final existing = existingByChunkId[chunkId];
      if (_canReuseExistingRecord(
        existing,
        indexName: indexName,
        externalId: externalId,
        embeddingModelSlug: config.modelSlug,
        embeddingDimension: config.dimension,
        documentTextHash: documentHash,
      )) {
        reusedChunkCount++;
        continue;
      }

      await _deletePreviousVectorIfNeeded(
        existing,
        replacementIndexName: indexName,
        replacementExternalId: externalId,
      );

      final embedding = await _cactusModelService.embedText(
        modelSlug: config.modelSlug,
        text: _documentEmbeddingText(config, draft.chunkText),
      );

      await _vectorIndex.upsertDocuments(
        indexPath: indexPath,
        embeddingDimension: embedding.dimension,
        documents: [
          LocalVectorDocument(
            externalId: externalId,
            document: draft.chunkText,
            embedding: embedding.embeddings,
            metadata: {
              'source_id': sourceId,
              'source_chunk_id': chunkId,
              'chunk_index': draft.chunkIndex,
              'embedding_model_slug': config.modelSlug,
              'document_text_hash': documentHash,
            },
          ),
        ],
      );

      final timestamp = _timestamp();
      await _localDataSource.upsertSourceChunk(
        database_models.SourceTextChunksCompanion.insert(
          id: chunkId,
          sourceId: sourceId,
          chunkIndex: draft.chunkIndex,
          chunkText: draft.chunkText,
          charStart: Value(draft.charStart),
          charEnd: Value(draft.charEnd),
          tokenCountEstimate: Value(draft.tokenCountEstimate),
          embeddingModelSlug: Value(config.modelSlug),
          vectorIndexName: Value(indexName),
          vectorExternalId: Value(externalId),
          embeddingDimension: Value(embedding.dimension),
          createdAt: existing?.chunk.createdAt ?? timestamp,
          updatedAt: timestamp,
        ),
      );
      await _localDataSource.upsertRagIndexRecord(
        database_models.RagIndexRecordsCompanion.insert(
          id: _recordId(chunkId),
          indexName: indexName,
          externalId: externalId,
          sourceChunkId: chunkId,
          embeddingModelSlug: config.modelSlug,
          embeddingDimension: embedding.dimension,
          documentTextHash: documentHash,
          createdAt: existing?.indexRecord?.createdAt ?? timestamp,
          updatedAt: timestamp,
        ),
      );
      embeddedChunkCount++;
    }

    final removed = await _localDataSource.deleteChunksOutsideIds(
      sourceId: sourceId,
      retainedChunkIds: retainedChunkIds,
    );
    await _deleteRemovedVectors(removed);

    return LocalRagIndexResult(
      sourceId: sourceId,
      indexName: indexName,
      embeddingModelSlug: config.modelSlug,
      embeddingDimension: config.dimension,
      chunkCount: drafts.length,
      embeddedChunkCount: embeddedChunkCount,
      reusedChunkCount: reusedChunkCount,
      removedChunkCount: removed.length,
      skippedEmptyText: false,
    );
  }

  @override
  Future<List<LocalRagSearchResult>> search({
    required String query,
    int topK = 8,
    String? embeddingModelSlug,
  }) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty || topK <= 0) {
      return const [];
    }

    final keywordResults = await _keywordSearchResults(
      query: trimmedQuery,
      topK: topK,
    );
    if (keywordResults.isEmpty && _canSkipVectorForExactLookup(trimmedQuery)) {
      return const [];
    }
    if (_hasHighConfidenceKeywordResults(keywordResults)) {
      return _rerank(keywordResults.take(topK).toList(growable: false));
    }

    final resolvedModelSlug = await _resolveEmbeddingModelSlug(
      embeddingModelSlug,
    );
    final config = CactusModelRegistry.embeddingConfigForSlug(
      resolvedModelSlug,
    );
    final indexName = _indexNameFor(config);
    final vectorResults = await _vectorSearchResults(
      query: trimmedQuery,
      topK: topK,
      config: config,
      indexName: indexName,
    );

    if (vectorResults.isEmpty && keywordResults.isEmpty) {
      return const [];
    }

    final mergedBySourceId = <String, LocalRagSearchResult>{};
    for (final result in [...vectorResults, ...keywordResults]) {
      final existing = mergedBySourceId[result.source.id];
      if (existing == null || result.score > existing.score) {
        mergedBySourceId[result.source.id] = result;
      }
    }

    final merged = mergedBySourceId.values.toList(growable: false)
      ..sort((left, right) {
        final scoreOrder = right.score.compareTo(left.score);
        if (scoreOrder != 0) {
          return scoreOrder;
        }

        return right.source.updatedAt.compareTo(left.source.updatedAt);
      });

    return _rerank(merged.take(topK).toList(growable: false));
  }

  bool _hasHighConfidenceKeywordResults(List<LocalRagSearchResult> results) {
    if (results.isEmpty) {
      return false;
    }

    if (results.first.score >= 0.62) {
      return true;
    }

    return results.length >= 2 &&
        results.first.score >= 0.5 &&
        results[1].score >= 0.42;
  }

  bool _canSkipVectorForExactLookup(String query) {
    final terms = _queryTerms(query).toSet();
    return terms.any(_recipeLookupSignals.contains);
  }

  Future<List<LocalRagSearchResult>> _vectorSearchResults({
    required String query,
    required int topK,
    required EmbeddingModelConfig config,
    required String indexName,
  }) async {
    final List<LocalVectorSearchHit> hits;
    try {
      final indexPath = await _indexPath(indexName);
      final queryEmbedding = await _cactusModelService.embedText(
        modelSlug: config.modelSlug,
        text: _queryEmbeddingText(config, query),
      );
      hits = await _vectorIndex.search(
        indexPath: indexPath,
        embeddingDimension: queryEmbedding.dimension,
        embedding: queryEmbedding.embeddings,
        topK: math.max(topK * 3, topK),
      );
    } on Object {
      return const [];
    }

    if (hits.isEmpty) {
      return const [];
    }

    final contexts = await _localDataSource.loadSearchContexts(
      indexName: indexName,
      externalIds: hits.map((hit) => hit.externalId).toList(growable: false),
    );
    final contextsByExternalId = {
      for (final context in contexts) context.indexRecord.externalId: context,
    };
    final rankedContexts =
        hits
            .map((hit) {
              final context = contextsByExternalId[hit.externalId];
              if (context == null) {
                return null;
              }

              final keywordScore = _keywordScore(query, context);
              return _RankedRagSearchContext(
                hit: hit,
                context: context,
                score: _hybridScore(hit.score, keywordScore),
              );
            })
            .nonNulls
            .toList(growable: false)
          ..sort((left, right) {
            final scoreOrder = right.score.compareTo(left.score);
            if (scoreOrder != 0) {
              return scoreOrder;
            }

            return right.hit.score.compareTo(left.hit.score);
          });

    final results = <LocalRagSearchResult>[];
    final seenSourceIds = <String>{};

    for (final candidate in rankedContexts) {
      final context = candidate.context;
      if (seenSourceIds.contains(context.source.id)) {
        continue;
      }

      seenSourceIds.add(context.source.id);
      results.add(
        LocalRagSearchResult(
          rank: results.length + 1,
          score: candidate.score,
          chunk: _mapChunk(context.chunk),
          source: _mapSource(context.source),
          relatedCards: context.relatedCards
              .map(_mapRelatedCard)
              .toList(growable: false),
        ),
      );

      if (results.length >= topK) {
        break;
      }
    }

    return results;
  }

  Future<List<LocalRagSearchResult>> _keywordSearchResults({
    required String query,
    required int topK,
  }) async {
    final queryTerms = _queryTerms(query);
    if (queryTerms.isEmpty) {
      return const [];
    }

    final corpus = await _localDataSource.loadKeywordSearchCorpus(
      limit: math.max(200, topK * 24),
    );
    final ranked = <_RankedKeywordSearchContext>[];
    for (final record in corpus) {
      final score = _keywordCorpusScore(queryTerms, record);
      if (score <= 0) {
        continue;
      }

      ranked.add(_RankedKeywordSearchContext(record: record, score: score));
    }

    ranked.sort((left, right) {
      final scoreOrder = right.score.compareTo(left.score);
      if (scoreOrder != 0) {
        return scoreOrder;
      }

      return right.record.source.updatedAt.compareTo(
        left.record.source.updatedAt,
      );
    });

    return [
      for (var index = 0; index < math.min(ranked.length, topK * 2); index++)
        _mapKeywordResult(ranked[index], index + 1),
    ];
  }

  double _hybridScore(double vectorScore, double keywordScore) {
    return (vectorScore * 0.7) + (keywordScore * 0.3);
  }

  double _keywordScore(String query, RagSearchContextRecord context) {
    final queryTerms = _queryTerms(query);
    if (queryTerms.isEmpty) {
      return 0;
    }

    final searchableTerms = _terms(
      [
        context.chunk.chunkText,
        context.source.rawText ?? '',
        context.source.extractedText ?? '',
        context.source.sourceSummary ?? '',
        for (final card in context.relatedCards) ...[
          card.card.title,
          card.card.reason,
          card.card.sourceSummary,
          card.cardSource.evidenceText,
          card.space.name,
        ],
      ].join(' '),
    ).toSet();
    if (searchableTerms.isEmpty) {
      return 0;
    }

    final matches = queryTerms
        .where((term) => searchableTerms.contains(term))
        .length;
    return matches / queryTerms.length;
  }

  double _keywordCorpusScore(
    List<String> queryTerms,
    RagKeywordSearchContextRecord record,
  ) {
    final searchableTerms = _terms(_keywordCorpusText(record)).toSet();
    if (searchableTerms.isEmpty) {
      return 0;
    }

    final matches = queryTerms
        .where((term) => searchableTerms.contains(term))
        .length;
    if (matches == 0) {
      return 0;
    }

    final titleTerms = _terms(
      [
        record.source.sourceSummary ?? '',
        for (final relatedCard in record.relatedCards) ...[
          relatedCard.card.title,
          relatedCard.card.reason,
          relatedCard.space.name,
        ],
      ].join(' '),
    ).toSet();
    final titleMatches = queryTerms
        .where((term) => titleTerms.contains(term))
        .length;
    final baseScore = matches / queryTerms.length;
    final titleBoost = math.min(0.3, titleMatches * 0.08);

    return math.min(1, 0.22 + (baseScore * 0.58) + titleBoost);
  }

  LocalRagSearchResult _mapKeywordResult(
    _RankedKeywordSearchContext ranked,
    int rank,
  ) {
    final record = ranked.record;
    final chunk = record.chunk == null
        ? RagSourceChunk(
            id: 'keyword_${record.source.id}',
            sourceId: record.source.id,
            chunkIndex: 0,
            chunkText: _keywordCorpusText(record),
            createdAt: record.source.createdAt,
            updatedAt: record.source.updatedAt,
          )
        : _mapChunk(record.chunk!);

    return LocalRagSearchResult(
      rank: rank,
      score: ranked.score,
      chunk: chunk,
      source: _mapSource(record.source),
      relatedCards: record.relatedCards.map(_mapRelatedCard).toList(),
    );
  }

  List<LocalRagSearchResult> _rerank(List<LocalRagSearchResult> results) {
    return [
      for (var index = 0; index < results.length; index++)
        LocalRagSearchResult(
          rank: index + 1,
          score: results[index].score,
          chunk: results[index].chunk,
          source: results[index].source,
          relatedCards: results[index].relatedCards,
        ),
    ];
  }

  List<String> _queryTerms(String text) {
    final terms = _terms(text)
        .where((term) => !_keywordStopWords.contains(term))
        .toList(growable: false);
    if (terms.isEmpty) {
      return _terms(text);
    }

    return terms;
  }

  List<String> _terms(String text) {
    return RegExp(r'[a-z0-9]+')
        .allMatches(text.toLowerCase())
        .map((match) => match.group(0)!)
        .where((term) => term.length > 1)
        .toSet()
        .toList(growable: false);
  }

  String _keywordCorpusText(RagKeywordSearchContextRecord record) {
    return [
      record.source.sourceSummary ?? '',
      for (final relatedCard in record.relatedCards) ...[
        relatedCard.card.title,
        relatedCard.card.reason,
        relatedCard.card.sourceSummary,
        relatedCard.card.evidenceSummary,
        relatedCard.cardSource.evidenceText ?? '',
        relatedCard.space.name,
      ],
      record.chunk?.chunkText ?? '',
      record.source.extractedText ?? '',
      record.source.rawText ?? '',
      record.source.contentType,
      record.source.type,
    ].where((part) => part.trim().isNotEmpty).join('\n');
  }

  @override
  Future<LocalRagIndexStatus> getIndexStatus({
    String? embeddingModelSlug,
  }) async {
    final resolvedModelSlug = await _resolveEmbeddingModelSlug(
      embeddingModelSlug,
    );
    final config = CactusModelRegistry.embeddingConfigForSlug(
      resolvedModelSlug,
    );
    final indexName = _indexNameFor(config);
    final counts = await _localDataSource.loadIndexCounts(indexName);
    final indexedChunks = await _localDataSource.loadIndexedChunks(indexName);
    final staleRecordCount = indexedChunks.where((record) {
      final indexRecord = record.indexRecord;
      if (indexRecord == null) {
        return true;
      }

      return indexRecord.documentTextHash !=
          RagTextHash.documentTextHash(record.chunk.chunkText);
    }).length;

    return LocalRagIndexStatus(
      indexName: indexName,
      embeddingModelSlug: config.modelSlug,
      embeddingDimension: config.dimension,
      chunkCount: counts.chunkCount,
      recordCount: counts.recordCount,
      staleRecordCount: staleRecordCount,
      updatedAt: _now().toUtc(),
    );
  }

  bool _canReuseExistingRecord(
    RagChunkIndexRecord? existing, {
    required String indexName,
    required String externalId,
    required String embeddingModelSlug,
    required int embeddingDimension,
    required String documentTextHash,
  }) {
    final chunk = existing?.chunk;
    final indexRecord = existing?.indexRecord;
    if (chunk == null || indexRecord == null) {
      return false;
    }

    return chunk.vectorIndexName == indexName &&
        chunk.vectorExternalId == externalId &&
        chunk.embeddingModelSlug == embeddingModelSlug &&
        chunk.embeddingDimension == embeddingDimension &&
        indexRecord.indexName == indexName &&
        indexRecord.externalId == externalId &&
        indexRecord.embeddingModelSlug == embeddingModelSlug &&
        indexRecord.embeddingDimension == embeddingDimension &&
        indexRecord.documentTextHash == documentTextHash;
  }

  Future<void> _deletePreviousVectorIfNeeded(
    RagChunkIndexRecord? existing, {
    required String replacementIndexName,
    required String replacementExternalId,
  }) async {
    final existingRecord = existing?.indexRecord;
    final existingIndexName = existingRecord?.indexName;
    final existingExternalId = existingRecord?.externalId;
    final existingDimension = existingRecord?.embeddingDimension;
    if (existingIndexName == null ||
        existingExternalId == null ||
        existingDimension == null) {
      return;
    }

    if (existingIndexName == replacementIndexName &&
        existingExternalId == replacementExternalId) {
      return;
    }

    await _vectorIndex.deleteDocuments(
      indexPath: await _indexPath(existingIndexName),
      embeddingDimension: existingDimension,
      externalIds: [existingExternalId],
    );
  }

  Future<void> _deleteRemovedVectors(
    List<RemovedRagChunkRecord> removed,
  ) async {
    for (final record in removed) {
      final indexName =
          record.indexRecord?.indexName ?? record.chunk.vectorIndexName;
      final externalId =
          record.indexRecord?.externalId ?? record.chunk.vectorExternalId;
      final dimension =
          record.indexRecord?.embeddingDimension ??
          record.chunk.embeddingDimension;
      if (indexName == null || externalId == null || dimension == null) {
        continue;
      }

      await _vectorIndex.deleteDocuments(
        indexPath: await _indexPath(indexName),
        embeddingDimension: dimension,
        externalIds: [externalId],
      );
    }
  }

  RagSourceChunk _mapChunk(database_models.SourceTextChunk chunk) {
    return RagSourceChunk(
      id: chunk.id,
      sourceId: chunk.sourceId,
      chunkIndex: chunk.chunkIndex,
      chunkText: chunk.chunkText,
      charStart: chunk.charStart,
      charEnd: chunk.charEnd,
      tokenCountEstimate: chunk.tokenCountEstimate,
      embeddingModelSlug: chunk.embeddingModelSlug,
      vectorIndexName: chunk.vectorIndexName,
      vectorExternalId: chunk.vectorExternalId,
      embeddingDimension: chunk.embeddingDimension,
      createdAt: chunk.createdAt,
      updatedAt: chunk.updatedAt,
    );
  }

  RagSourceSnapshot _mapSource(database_models.SourceItem source) {
    return RagSourceSnapshot(
      id: source.id,
      type: source.type,
      contentType: source.contentType,
      processingState: source.processingState,
      sourceSummary: source.sourceSummary,
      appSource: source.appSource,
      createdAt: source.createdAt,
      updatedAt: source.updatedAt,
    );
  }

  RagRelatedCardSnapshot _mapRelatedCard(RagRelatedCardRecord record) {
    return RagRelatedCardSnapshot(
      cardId: record.card.id,
      cardType: record.card.cardType,
      status: record.card.status,
      title: normalizeTagCardTitle(record.card.title),
      reason: record.card.reason,
      spaceName: record.space.name,
      sourceSummary: record.card.sourceSummary,
      evidenceText: record.cardSource.evidenceText,
      nextActiveDeadline: record.card.nextActiveDeadline,
    );
  }

  Future<String> _resolveEmbeddingModelSlug(String? requestedSlug) async {
    final candidate = requestedSlug?.trim();
    if (candidate != null && candidate.isNotEmpty) {
      return CactusModelRegistry.embeddingConfigForSlug(candidate).modelSlug;
    }

    final provider = _embeddingModelSlugProvider;
    if (provider == null) {
      return CactusModelRegistry.defaultEmbeddingModelSlug;
    }

    final selectedSlug = await provider();
    return CactusModelRegistry.embeddingConfigForSlug(selectedSlug).modelSlug;
  }

  String _documentEmbeddingText(EmbeddingModelConfig config, String chunkText) {
    return '${config.documentPrefix}$chunkText';
  }

  String _queryEmbeddingText(EmbeddingModelConfig config, String query) {
    return '${config.queryInstruction}${config.queryPrefix}$query';
  }

  String _chunkId(String sourceId, int chunkIndex) {
    return 'chunk_${sourceId}_$chunkIndex';
  }

  String _recordId(String chunkId) {
    return 'ragrec_$chunkId';
  }

  String _externalIdForChunk({
    required String indexName,
    required String sourceId,
    required int chunkIndex,
  }) {
    return RagTextHash.stablePositiveInt(
      '$indexName::$sourceId::$chunkIndex',
    ).toString();
  }

  String _indexNameFor(EmbeddingModelConfig config) {
    final safeSlug = config.modelSlug.replaceAll(
      RegExp(r'[^a-zA-Z0-9_-]'),
      '_',
    );
    return 'tag_source_chunks_${safeSlug}_${config.dimension}d';
  }

  Future<String> _indexPath(String indexName) async {
    final root = await _localFileStore.ensureInitialized();
    return p.join(root.path, 'rag_indices', indexName);
  }

  int _timestamp() => _now().toUtc().millisecondsSinceEpoch;
}

class _RankedRagSearchContext {
  const _RankedRagSearchContext({
    required this.hit,
    required this.context,
    required this.score,
  });

  final LocalVectorSearchHit hit;
  final RagSearchContextRecord context;
  final double score;
}

class _RankedKeywordSearchContext {
  const _RankedKeywordSearchContext({
    required this.record,
    required this.score,
  });

  final RagKeywordSearchContextRecord record;
  final double score;
}

const _keywordStopWords = {
  'what',
  'have',
  'saved',
  'about',
  'anything',
  'with',
  'from',
  'need',
  'this',
  'that',
  'your',
  'you',
  'for',
  'the',
  'and',
  'did',
  'why',
  'show',
  'source',
  'create',
  'reminder',
  'reminders',
  'next',
  'card',
  'cards',
  'do',
  'me',
  'my',
};

const _recipeLookupSignals = {'cook', 'cooking', 'recipe', 'recipes'};
