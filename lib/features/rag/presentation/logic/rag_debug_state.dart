import 'package:equatable/equatable.dart';
import 'package:tag/core/ai/rag/rag_models.dart';

enum RagDebugStatus { initial, loading, ready, searching, error }

class RagDebugState extends Equatable {
  const RagDebugState({
    this.status = RagDebugStatus.initial,
    this.query = '',
    this.results = const [],
    this.indexStatus,
    this.errorMessage = '',
  });

  final RagDebugStatus status;
  final String query;
  final List<LocalRagSearchResult> results;
  final LocalRagIndexStatus? indexStatus;
  final String errorMessage;

  bool get isBusy =>
      status == RagDebugStatus.loading || status == RagDebugStatus.searching;

  RagDebugState copyWith({
    RagDebugStatus? status,
    String? query,
    List<LocalRagSearchResult>? results,
    LocalRagIndexStatus? indexStatus,
    String? errorMessage,
  }) {
    return RagDebugState(
      status: status ?? this.status,
      query: query ?? this.query,
      results: results ?? this.results,
      indexStatus: indexStatus ?? this.indexStatus,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    query,
    results,
    indexStatus,
    errorMessage,
  ];
}
