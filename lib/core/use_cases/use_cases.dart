import 'package:equatable/equatable.dart';

abstract class UseCase<Result, Params> {
  Future<Result> call(Params params);
}

mixin UseCases<Result, Params> {
  Future<Result> call(Params params);
}

mixin StreamUseCases<Result, Params> {
  Stream<Result> call(Params params);
}

class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => const [];
}
