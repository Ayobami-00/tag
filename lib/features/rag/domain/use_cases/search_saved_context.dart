import 'package:equatable/equatable.dart';
import 'package:tag/core/ai/rag/local_rag_service.dart';
import 'package:tag/core/ai/rag/rag_models.dart';
import 'package:tag/core/use_cases/use_cases.dart';

class SearchSavedContextParams extends Equatable {
  const SearchSavedContextParams({required this.query, this.topK = 8});

  final String query;
  final int topK;

  @override
  List<Object?> get props => [query, topK];
}

class SearchSavedContext
    with UseCases<List<LocalRagSearchResult>, SearchSavedContextParams> {
  const SearchSavedContext(this._localRagService);

  final LocalRagService _localRagService;

  @override
  Future<List<LocalRagSearchResult>> call(SearchSavedContextParams params) {
    return _localRagService.search(query: params.query, topK: params.topK);
  }
}
