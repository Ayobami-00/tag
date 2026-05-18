import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tag/core/use_cases/use_cases.dart';
import 'package:tag/features/spaces/domain/entities/space_entities.dart';
import 'package:tag/features/spaces/domain/use_cases/record_space_view.dart';
import 'package:tag/features/spaces/domain/use_cases/watch_space_summaries.dart';

part 'spaces_state.dart';

class SpacesCubit extends Cubit<SpacesState> {
  SpacesCubit({
    required WatchSpaceSummaries watchSpaceSummaries,
    required RecordSpaceView recordSpaceView,
  }) : _watchSpaceSummaries = watchSpaceSummaries,
       _recordSpaceView = recordSpaceView,
       super(const SpacesState());

  final WatchSpaceSummaries _watchSpaceSummaries;
  final RecordSpaceView _recordSpaceView;
  StreamSubscription<List<SpaceSummaryEntity>>? _spacesSubscription;

  void load() {
    _spacesSubscription?.cancel();
    emit(state.copyWith(status: SpacesStatus.loading, errorMessage: ''));
    _spacesSubscription = _watchSpaceSummaries(const NoParams()).listen(
      (spaces) {
        if (isClosed) {
          return;
        }
        emit(state.copyWith(status: SpacesStatus.ready, spaces: spaces));
      },
      onError: (Object error) {
        if (isClosed) {
          return;
        }
        emit(
          state.copyWith(
            status: SpacesStatus.error,
            errorMessage: error.toString(),
          ),
        );
      },
    );
  }

  Future<bool> recordSpaceView(String spaceId) async {
    try {
      await _recordSpaceView(
        RecordSpaceViewParams(spaceId: spaceId, openedFrom: 'spaces_view'),
      );
      return true;
    } on Object {
      return false;
    }
  }

  @override
  Future<void> close() async {
    await _spacesSubscription?.cancel();
    return super.close();
  }
}
