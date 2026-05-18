import 'package:tag/core/use_cases/use_cases.dart';
import 'package:tag/features/cards/domain/entities/card_entities.dart';
import 'package:tag/features/cards/domain/entities/card_query.dart';
import 'package:tag/features/cards/domain/repositories/card_repository.dart';

class WatchTodayCards with StreamUseCases<List<TagCardEntity>, CardListQuery> {
  const WatchTodayCards(this._repository);

  final CardRepository _repository;

  @override
  Stream<List<TagCardEntity>> call(CardListQuery params) {
    return _repository.watchCards(params);
  }
}
