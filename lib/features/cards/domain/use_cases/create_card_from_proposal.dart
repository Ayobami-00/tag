import 'package:equatable/equatable.dart';
import 'package:tag/core/ai/schemas/card_proposal_schema.dart';
import 'package:tag/core/notifications/local_notification_service.dart';
import 'package:tag/core/use_cases/use_cases.dart';
import 'package:tag/features/cards/domain/entities/card_entities.dart';
import 'package:tag/features/cards/domain/repositories/card_repository.dart';
import 'package:tag/features/cards/domain/use_cases/card_notification_snapshot.dart';

class CreateCardFromProposal
    implements UseCase<TagCardEntity, CreateCardFromProposalParams> {
  const CreateCardFromProposal(
    this._repository, {
    LocalNotificationService? notificationService,
  }) : _notificationService = notificationService;

  final CardRepository _repository;
  final LocalNotificationService? _notificationService;

  @override
  Future<TagCardEntity> call(CreateCardFromProposalParams params) async {
    final card = await _repository.createFromProposal(
      proposal: params.proposal,
      modelSlug: params.modelSlug,
    );

    await _notificationService?.scheduleCardNotification(
      notificationSnapshotFor(card),
    );

    return card;
  }
}

class CreateCardFromProposalParams extends Equatable {
  const CreateCardFromProposalParams({required this.proposal, this.modelSlug});

  final CardProposal proposal;
  final String? modelSlug;

  @override
  List<Object?> get props => [proposal, modelSlug];
}

class CardCreationException implements Exception {
  const CardCreationException(this.message);

  final String message;

  @override
  String toString() => message;
}
