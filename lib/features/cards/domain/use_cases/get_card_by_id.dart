import 'package:equatable/equatable.dart';
import 'package:tag/core/use_cases/use_cases.dart';
import 'package:tag/features/cards/domain/entities/card_entities.dart';
import 'package:tag/features/cards/domain/repositories/card_repository.dart';

class GetCardById implements UseCase<TagCardEntity?, GetCardByIdParams> {
  const GetCardById(this._repository);

  final CardRepository _repository;

  @override
  Future<TagCardEntity?> call(GetCardByIdParams params) {
    return _repository.getCardById(params.cardId);
  }
}

class GetCardByIdParams extends Equatable {
  const GetCardByIdParams({required this.cardId});

  final String cardId;

  @override
  List<Object?> get props => [cardId];
}
