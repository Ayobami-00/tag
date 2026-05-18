part of 'space_detail_cubit.dart';

enum SpaceDetailStatus { initial, loading, ready, notFound, error }

class SpaceDetailState extends Equatable {
  const SpaceDetailState({
    this.status = SpaceDetailStatus.initial,
    this.detail,
    this.errorMessage = '',
  });

  final SpaceDetailStatus status;
  final SpaceDetailEntity? detail;
  final String errorMessage;

  bool get isLoading =>
      status == SpaceDetailStatus.initial ||
      status == SpaceDetailStatus.loading;

  SpaceDetailState copyWith({
    SpaceDetailStatus? status,
    SpaceDetailEntity? detail,
    String? errorMessage,
  }) {
    return SpaceDetailState(
      status: status ?? this.status,
      detail: detail ?? this.detail,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, detail, errorMessage];
}
