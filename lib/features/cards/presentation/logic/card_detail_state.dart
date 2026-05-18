part of 'card_detail_cubit.dart';

enum CardDetailStatus { initial, loading, ready, notFound, error }

class CardDetailState extends Equatable {
  const CardDetailState({
    this.status = CardDetailStatus.initial,
    this.card,
    this.actionMessage = '',
    this.errorMessage = '',
  });

  final CardDetailStatus status;
  final TagCardEntity? card;
  final String actionMessage;
  final String errorMessage;

  bool get isLoading =>
      status == CardDetailStatus.initial || status == CardDetailStatus.loading;

  CardDetailState copyWith({
    CardDetailStatus? status,
    TagCardEntity? card,
    String? actionMessage,
    String? errorMessage,
  }) {
    return CardDetailState(
      status: status ?? this.status,
      card: card ?? this.card,
      actionMessage: actionMessage ?? this.actionMessage,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, card, actionMessage, errorMessage];
}
