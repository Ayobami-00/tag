import 'package:tag/core/ai/rag/rag_models.dart';

abstract interface class LocalRagService {
  Future<LocalRagIndexResult> indexSource({
    required String sourceId,
    required String text,
    String? embeddingModelSlug,
  });

  Future<List<LocalRagSearchResult>> search({
    required String query,
    int topK = 8,
    String? embeddingModelSlug,
  });

  Future<LocalRagIndexStatus> getIndexStatus({String? embeddingModelSlug});
}
