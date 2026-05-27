import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tag/features/source_ingestion/domain/entities/source_item_entity.dart';
import 'package:tag/features/source_ingestion/domain/services/manual_source_picker.dart';
import 'package:tag/features/source_ingestion/domain/use_cases/create_text_source.dart';
import 'package:tag/features/source_ingestion/domain/use_cases/import_image_source.dart';
import 'package:tag/features/source_ingestion/domain/use_cases/watch_recent_sources.dart';

part 'source_ingestion_state.dart';

typedef ManualSourceDescriptionRequester =
    Future<String?> Function(PickedImageSource pickedImage);

class SourceIngestionCubit extends Cubit<SourceIngestionState> {
  SourceIngestionCubit({
    required ImportImageSource importImageSource,
    required ManualSourcePicker manualSourcePicker,
    required CreateTextSource createTextSource,
    required WatchRecentSources watchRecentSources,
  }) : _importImageSource = importImageSource,
       _manualSourcePicker = manualSourcePicker,
       _createTextSource = createTextSource,
       _watchRecentSources = watchRecentSources,
       super(const SourceIngestionState());

  final ImportImageSource _importImageSource;
  final ManualSourcePicker _manualSourcePicker;
  final CreateTextSource _createTextSource;
  final WatchRecentSources _watchRecentSources;
  StreamSubscription<List<SourceItemEntity>>? _recentSourcesSubscription;

  void load() {
    if (state.status == SourceIngestionStatus.ready ||
        state.status == SourceIngestionStatus.saving ||
        _recentSourcesSubscription != null) {
      return;
    }

    emit(state.copyWith(status: SourceIngestionStatus.loading));
    _recentSourcesSubscription =
        _watchRecentSources(const WatchRecentSourcesParams(limit: 8)).listen(
          _onRecentSourcesChanged,
          onError: (Object error) {
            if (isClosed) {
              return;
            }
            emit(
              state.copyWith(
                status: SourceIngestionStatus.failure,
                errorMessage: _userFacingError(error),
              ),
            );
          },
        );
  }

  Future<void> importImage({
    ManualSourceDescriptionRequester? requestDescription,
  }) async {
    emit(
      state.copyWith(
        status: SourceIngestionStatus.saving,
        actionMessage: '',
        errorMessage: '',
      ),
    );

    try {
      final pickedImage = await _manualSourcePicker.pickImage();
      if (pickedImage == null) {
        emit(
          state.copyWith(
            status: SourceIngestionStatus.ready,
            actionMessage: '',
          ),
        );
        return;
      }

      final sourceDescription = await requestDescription?.call(pickedImage);
      final source = await _importImageSource(
        ImportImageSourceParams(
          pickedImage: pickedImage,
          sourceDescription: sourceDescription,
        ),
      );
      if (source == null) {
        emit(
          state.copyWith(
            status: SourceIngestionStatus.ready,
            actionMessage: '',
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          status: SourceIngestionStatus.saved,
          lastSavedSource: source,
          actionMessage: 'Saved',
          errorMessage: '',
        ),
      );
    } on Object catch (error) {
      emit(
        state.copyWith(
          status: SourceIngestionStatus.failure,
          errorMessage: _userFacingError(error),
          actionMessage: '',
        ),
      );
    }
  }

  Future<void> createTextSource(String text) async {
    emit(
      state.copyWith(
        status: SourceIngestionStatus.saving,
        actionMessage: '',
        errorMessage: '',
      ),
    );

    try {
      final source = await _createTextSource(CreateTextSourceParams(text));
      emit(
        state.copyWith(
          status: SourceIngestionStatus.saved,
          lastSavedSource: source,
          actionMessage: 'Saved',
          errorMessage: '',
        ),
      );
    } on Object catch (error) {
      emit(
        state.copyWith(
          status: SourceIngestionStatus.failure,
          errorMessage: _userFacingError(error),
          actionMessage: '',
        ),
      );
    }
  }

  void clearActionMessage() {
    if (state.actionMessage.isEmpty) {
      return;
    }

    emit(state.copyWith(actionMessage: ''));
  }

  void _onRecentSourcesChanged(List<SourceItemEntity> sources) {
    if (isClosed) {
      return;
    }

    final nextStatus = switch (state.status) {
      SourceIngestionStatus.initial ||
      SourceIngestionStatus.loading => SourceIngestionStatus.ready,
      _ => state.status,
    };

    emit(state.copyWith(status: nextStatus, recentSources: sources));
  }

  @override
  Future<void> close() async {
    await _recentSourcesSubscription?.cancel();
    return super.close();
  }

  String _userFacingError(Object error) {
    if (error is ArgumentError) {
      return error.message?.toString() ?? 'Source could not be saved.';
    }

    return 'Source could not be saved locally.';
  }
}
