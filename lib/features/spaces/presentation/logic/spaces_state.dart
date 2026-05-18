part of 'spaces_cubit.dart';

enum SpacesStatus { initial, loading, ready, error }

class SpacesState extends Equatable {
  const SpacesState({
    this.status = SpacesStatus.initial,
    this.spaces = const [],
    this.errorMessage = '',
  });

  final SpacesStatus status;
  final List<SpaceSummaryEntity> spaces;
  final String errorMessage;

  bool get isLoading =>
      status == SpacesStatus.initial || status == SpacesStatus.loading;

  SpacesState copyWith({
    SpacesStatus? status,
    List<SpaceSummaryEntity>? spaces,
    String? errorMessage,
  }) {
    return SpacesState(
      status: status ?? this.status,
      spaces: spaces ?? this.spaces,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, spaces, errorMessage];
}
