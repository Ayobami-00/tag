import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tag/core/use_cases/use_cases.dart';
import 'package:tag/features/rag/domain/use_cases/get_rag_index_status.dart';
import 'package:tag/features/rag/domain/use_cases/search_saved_context.dart';
import 'package:tag/features/rag/presentation/logic/rag_debug_state.dart';

class RagDebugCubit extends Cubit<RagDebugState> {
  RagDebugCubit({
    required GetRagIndexStatus getRagIndexStatus,
    required SearchSavedContext searchSavedContext,
  }) : _getRagIndexStatus = getRagIndexStatus,
       _searchSavedContext = searchSavedContext,
       super(const RagDebugState());

  final GetRagIndexStatus _getRagIndexStatus;
  final SearchSavedContext _searchSavedContext;

  Future<void> load({String initialQuery = ''}) async {
    emit(state.copyWith(status: RagDebugStatus.loading, errorMessage: ''));
    try {
      final indexStatus = await _getRagIndexStatus(const NoParams());
      emit(
        state.copyWith(status: RagDebugStatus.ready, indexStatus: indexStatus),
      );
      final trimmedInitialQuery = initialQuery.trim();
      if (trimmedInitialQuery.isNotEmpty) {
        await search(trimmedInitialQuery);
      }
    } on Object catch (error) {
      emit(
        state.copyWith(
          status: RagDebugStatus.error,
          errorMessage: _messageFor(error),
        ),
      );
    }
  }

  Future<void> search(String query) async {
    final trimmedQuery = query.trim();
    emit(
      state.copyWith(
        query: query,
        status: trimmedQuery.isEmpty
            ? RagDebugStatus.ready
            : RagDebugStatus.searching,
        results: trimmedQuery.isEmpty ? const [] : state.results,
        errorMessage: '',
      ),
    );

    if (trimmedQuery.isEmpty) {
      return;
    }

    try {
      final results = await _searchSavedContext(
        SearchSavedContextParams(query: trimmedQuery, topK: 8),
      );
      final indexStatus = await _getRagIndexStatus(const NoParams());
      emit(
        state.copyWith(
          status: RagDebugStatus.ready,
          results: results,
          indexStatus: indexStatus,
        ),
      );
    } on Object catch (error) {
      emit(
        state.copyWith(
          status: RagDebugStatus.error,
          errorMessage: _messageFor(error),
        ),
      );
    }
  }

  String _messageFor(Object error) {
    final message = error.toString();
    if (message.startsWith('Exception: ')) {
      return message.substring('Exception: '.length);
    }

    return message;
  }
}
