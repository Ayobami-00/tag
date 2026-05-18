import 'package:equatable/equatable.dart';

class RagChunkDraft extends Equatable {
  const RagChunkDraft({
    required this.chunkIndex,
    required this.chunkText,
    required this.charStart,
    required this.charEnd,
    required this.tokenCountEstimate,
  });

  final int chunkIndex;
  final String chunkText;
  final int charStart;
  final int charEnd;
  final int tokenCountEstimate;

  @override
  List<Object?> get props => [
    chunkIndex,
    chunkText,
    charStart,
    charEnd,
    tokenCountEstimate,
  ];
}

class RagSourceChunk extends Equatable {
  const RagSourceChunk({
    required this.id,
    required this.sourceId,
    required this.chunkIndex,
    required this.chunkText,
    required this.createdAt,
    required this.updatedAt,
    this.charStart,
    this.charEnd,
    this.tokenCountEstimate,
    this.embeddingModelSlug,
    this.vectorIndexName,
    this.vectorExternalId,
    this.embeddingDimension,
  });

  final String id;
  final String sourceId;
  final int chunkIndex;
  final String chunkText;
  final int? charStart;
  final int? charEnd;
  final int? tokenCountEstimate;
  final String? embeddingModelSlug;
  final String? vectorIndexName;
  final String? vectorExternalId;
  final int? embeddingDimension;
  final int createdAt;
  final int updatedAt;

  String get preview {
    final collapsed = chunkText.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (collapsed.length <= 180) {
      return collapsed;
    }

    return '${collapsed.substring(0, 180).trim()}...';
  }

  @override
  List<Object?> get props => [
    id,
    sourceId,
    chunkIndex,
    chunkText,
    charStart,
    charEnd,
    tokenCountEstimate,
    embeddingModelSlug,
    vectorIndexName,
    vectorExternalId,
    embeddingDimension,
    createdAt,
    updatedAt,
  ];
}

class RagSourceSnapshot extends Equatable {
  const RagSourceSnapshot({
    required this.id,
    required this.type,
    required this.contentType,
    required this.processingState,
    required this.createdAt,
    required this.updatedAt,
    this.sourceSummary,
    this.appSource,
  });

  final String id;
  final String type;
  final String contentType;
  final String processingState;
  final String? sourceSummary;
  final String? appSource;
  final int createdAt;
  final int updatedAt;

  String get displaySummary {
    final summary = sourceSummary?.trim();
    if (summary != null && summary.isNotEmpty) {
      return summary;
    }

    return switch (type) {
      'image' || 'screenshot' => 'Saved image',
      'text' || 'chat' => 'Saved text',
      _ => 'Saved source',
    };
  }

  @override
  List<Object?> get props => [
    id,
    type,
    contentType,
    processingState,
    sourceSummary,
    appSource,
    createdAt,
    updatedAt,
  ];
}

class RagRelatedCardSnapshot extends Equatable {
  const RagRelatedCardSnapshot({
    required this.cardId,
    required this.cardType,
    required this.status,
    required this.title,
    required this.spaceName,
    this.reason,
    this.sourceSummary,
    this.evidenceText,
    this.nextActiveDeadline,
  });

  final String cardId;
  final String cardType;
  final String status;
  final String title;
  final String spaceName;
  final String? reason;
  final String? sourceSummary;
  final String? evidenceText;
  final int? nextActiveDeadline;

  bool get isActive => status == 'active' || status == 'snoozed';

  @override
  List<Object?> get props => [
    cardId,
    cardType,
    status,
    title,
    spaceName,
    reason,
    sourceSummary,
    evidenceText,
    nextActiveDeadline,
  ];
}

class LocalRagSearchResult extends Equatable {
  const LocalRagSearchResult({
    required this.rank,
    required this.score,
    required this.chunk,
    required this.source,
    this.relatedCards = const [],
  });

  final int rank;
  final double score;
  final RagSourceChunk chunk;
  final RagSourceSnapshot source;
  final List<RagRelatedCardSnapshot> relatedCards;

  @override
  List<Object?> get props => [rank, score, chunk, source, relatedCards];
}

class LocalRagIndexResult extends Equatable {
  const LocalRagIndexResult({
    required this.sourceId,
    required this.indexName,
    required this.embeddingModelSlug,
    required this.embeddingDimension,
    required this.chunkCount,
    required this.embeddedChunkCount,
    required this.reusedChunkCount,
    required this.removedChunkCount,
    required this.skippedEmptyText,
  });

  final String sourceId;
  final String indexName;
  final String embeddingModelSlug;
  final int embeddingDimension;
  final int chunkCount;
  final int embeddedChunkCount;
  final int reusedChunkCount;
  final int removedChunkCount;
  final bool skippedEmptyText;

  @override
  List<Object?> get props => [
    sourceId,
    indexName,
    embeddingModelSlug,
    embeddingDimension,
    chunkCount,
    embeddedChunkCount,
    reusedChunkCount,
    removedChunkCount,
    skippedEmptyText,
  ];
}

class LocalRagIndexStatus extends Equatable {
  const LocalRagIndexStatus({
    required this.indexName,
    required this.embeddingModelSlug,
    required this.embeddingDimension,
    required this.chunkCount,
    required this.recordCount,
    required this.staleRecordCount,
    required this.updatedAt,
  });

  final String indexName;
  final String embeddingModelSlug;
  final int embeddingDimension;
  final int chunkCount;
  final int recordCount;
  final int staleRecordCount;
  final DateTime updatedAt;

  bool get hasRows => chunkCount > 0 || recordCount > 0;

  @override
  List<Object?> get props => [
    indexName,
    embeddingModelSlug,
    embeddingDimension,
    chunkCount,
    recordCount,
    staleRecordCount,
    updatedAt,
  ];
}
