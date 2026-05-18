import 'dart:convert';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:tag/core/ai/cactus/v114/cactus_v114.dart'
    deferred as cactus
    hide Utf8Pointer, Utf8PointerExtension;

class LocalVectorDocument extends Equatable {
  const LocalVectorDocument({
    required this.externalId,
    required this.document,
    required this.embedding,
    this.metadata = const {},
  });

  final String externalId;
  final String document;
  final List<double> embedding;
  final Map<String, Object?> metadata;

  @override
  List<Object?> get props => [externalId, document, embedding, metadata];
}

class LocalVectorSearchHit extends Equatable {
  const LocalVectorSearchHit({required this.externalId, required this.score});

  final String externalId;
  final double score;

  @override
  List<Object?> get props => [externalId, score];
}

abstract interface class LocalVectorIndex {
  Future<void> upsertDocuments({
    required String indexPath,
    required int embeddingDimension,
    required List<LocalVectorDocument> documents,
  });

  Future<void> deleteDocuments({
    required String indexPath,
    required int embeddingDimension,
    required List<String> externalIds,
  });

  Future<List<LocalVectorSearchHit>> search({
    required String indexPath,
    required int embeddingDimension,
    required List<double> embedding,
    required int topK,
  });
}

class CactusLocalVectorIndex implements LocalVectorIndex {
  CactusLocalVectorIndex();

  final Map<String, dynamic> _handles = {};
  Future<void>? _bindingsLoad;

  @override
  Future<void> upsertDocuments({
    required String indexPath,
    required int embeddingDimension,
    required List<LocalVectorDocument> documents,
  }) async {
    if (documents.isEmpty) {
      return;
    }

    final handle = await _indexHandle(
      indexPath: indexPath,
      embeddingDimension: embeddingDimension,
    );
    final ids = documents
        .map((document) {
          return int.parse(document.externalId);
        })
        .toList(growable: false);

    try {
      cactus.cactusIndexDelete(handle, ids);
    } on Object {
      // Cactus indexes are local files; a missing id should not block a
      // replacement write when SQLite is the source of truth for metadata.
    }

    cactus.cactusIndexAdd(
      handle,
      ids,
      documents.map((document) => document.document).toList(growable: false),
      documents.map((document) => document.embedding).toList(growable: false),
      documents
          .map((document) {
            return jsonEncode({
              'external_id': document.externalId,
              ...document.metadata,
            });
          })
          .toList(growable: false),
    );
  }

  @override
  Future<void> deleteDocuments({
    required String indexPath,
    required int embeddingDimension,
    required List<String> externalIds,
  }) async {
    if (externalIds.isEmpty) {
      return;
    }

    final handle = await _indexHandle(
      indexPath: indexPath,
      embeddingDimension: embeddingDimension,
    );
    final ids = externalIds.map(int.parse).toList(growable: false);

    try {
      cactus.cactusIndexDelete(handle, ids);
    } on Object {
      // SQLite cleanup should still proceed if the local index file is already
      // missing a row.
    }
  }

  @override
  Future<List<LocalVectorSearchHit>> search({
    required String indexPath,
    required int embeddingDimension,
    required List<double> embedding,
    required int topK,
  }) async {
    if (embedding.isEmpty || topK <= 0) {
      return const [];
    }

    final handle = await _indexHandle(
      indexPath: indexPath,
      embeddingDimension: embeddingDimension,
    );
    final rawJson = cactus.cactusIndexQuery(
      handle,
      embedding,
      jsonEncode({'top_k': topK}),
    );
    final decoded = jsonDecode(rawJson);
    if (decoded is! Map<String, dynamic>) {
      return const [];
    }

    final results = decoded['results'];
    if (results is! List) {
      return const [];
    }

    return results
        .whereType<Map>()
        .map((hit) {
          final id = hit['id']?.toString();
          final score = hit['score'];
          if (id == null || id.isEmpty || score is! num) {
            return null;
          }

          return LocalVectorSearchHit(externalId: id, score: score.toDouble());
        })
        .nonNulls
        .toList(growable: false);
  }

  Future<dynamic> _indexHandle({
    required String indexPath,
    required int embeddingDimension,
  }) async {
    await _loadBindings();
    await Directory(indexPath).create(recursive: true);
    final key = '$indexPath::$embeddingDimension';
    return _handles[key] ??= cactus.cactusIndexInit(
      indexPath,
      embeddingDimension,
    );
  }

  Future<void> _loadBindings() {
    return _bindingsLoad ??= cactus.loadLibrary().then((_) {
      cactus.cactusLogSetLevel(3);
    });
  }
}
