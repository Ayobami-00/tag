part of 'today_cubit.dart';

enum TodayStatus { initial, loading, ready, error }

class TodayState extends Equatable {
  const TodayState({
    this.status = TodayStatus.initial,
    this.viewMode = TodayViewMode.today,
    this.filter = TodayCardFilter.all,
    this.cards = const [],
    this.errorMessage = '',
  });

  final TodayStatus status;
  final TodayViewMode viewMode;
  final TodayCardFilter filter;
  final List<TagCardEntity> cards;
  final String errorMessage;

  bool get isLoading =>
      status == TodayStatus.initial || status == TodayStatus.loading;

  bool get hasActiveFilter => filter != TodayCardFilter.all;

  TodayState copyWith({
    TodayStatus? status,
    TodayViewMode? viewMode,
    TodayCardFilter? filter,
    List<TagCardEntity>? cards,
    String? errorMessage,
  }) {
    return TodayState(
      status: status ?? this.status,
      viewMode: viewMode ?? this.viewMode,
      filter: filter ?? this.filter,
      cards: cards ?? this.cards,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, viewMode, filter, cards, errorMessage];
}
