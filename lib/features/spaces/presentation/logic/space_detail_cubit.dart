import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tag/features/spaces/domain/entities/space_entities.dart';
import 'package:tag/features/spaces/domain/use_cases/get_space_detail.dart';

part 'space_detail_state.dart';

class SpaceDetailCubit extends Cubit<SpaceDetailState> {
  SpaceDetailCubit({required GetSpaceDetail getSpaceDetail})
    : _getSpaceDetail = getSpaceDetail,
      super(const SpaceDetailState());

  final GetSpaceDetail _getSpaceDetail;

  Future<void> load(String spaceId) async {
    emit(state.copyWith(status: SpaceDetailStatus.loading, errorMessage: ''));
    try {
      final detail = await _getSpaceDetail(
        GetSpaceDetailParams(spaceId: spaceId),
      );
      if (detail == null) {
        emit(
          state.copyWith(
            status: SpaceDetailStatus.notFound,
            errorMessage: 'This Space is no longer available.',
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          status: SpaceDetailStatus.ready,
          detail: detail,
          errorMessage: '',
        ),
      );
    } on Object catch (error) {
      emit(
        state.copyWith(
          status: SpaceDetailStatus.error,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}
