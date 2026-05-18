import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tag/features/source_ingestion/domain/entities/source_preview_entity.dart';
import 'package:tag/features/source_ingestion/domain/use_cases/get_source_preview.dart';
import 'package:tag/features/spaces/domain/use_cases/record_space_view.dart';

part 'source_preview_state.dart';

class SourcePreviewCubit extends Cubit<SourcePreviewState> {
  SourcePreviewCubit({
    required GetSourcePreview getSourcePreview,
    required RecordSpaceView recordSpaceView,
  }) : _getSourcePreview = getSourcePreview,
       _recordSpaceView = recordSpaceView,
       super(const SourcePreviewState());

  final GetSourcePreview _getSourcePreview;
  final RecordSpaceView _recordSpaceView;

  Future<void> load({required String sourceId, String? focusCardId}) async {
    emit(
      state.copyWith(
        status: SourcePreviewStatus.loading,
        focusCardId: focusCardId,
        errorMessage: '',
      ),
    );

    try {
      final preview = await _getSourcePreview(
        GetSourcePreviewParams(sourceId: sourceId),
      );
      if (preview == null) {
        emit(
          state.copyWith(
            status: SourcePreviewStatus.notFound,
            errorMessage: 'This local source is no longer available.',
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          status: SourcePreviewStatus.ready,
          preview: preview,
          errorMessage: '',
        ),
      );
    } on Object catch (error) {
      emit(
        state.copyWith(
          status: SourcePreviewStatus.error,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  void showCardsForSpace(String spaceId) {
    emit(state.copyWith(focusedSpaceId: spaceId));
  }

  Future<bool> recordOpenSpace(String spaceId) async {
    final preview = state.preview;
    if (preview == null) {
      return false;
    }

    final card = state.focusedCard;
    try {
      await _recordSpaceView(
        RecordSpaceViewParams(
          spaceId: spaceId,
          cardId: card?.cardId,
          sourceId: preview.source.id,
          cardType: card?.cardType.storageValue,
          cardStatus: card?.status.storageValue,
          openedFrom: 'source_preview',
          details: {
            'source_type': preview.source.type.storageValue,
            if (card != null) 'card_title': card.title,
          },
        ),
      );
      return true;
    } on Object catch (error) {
      emit(state.copyWith(errorMessage: error.toString()));
      return false;
    }
  }
}
