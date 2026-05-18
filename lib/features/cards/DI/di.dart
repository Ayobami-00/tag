import 'package:tag/core/DI/di.dart';
import 'package:tag/core/local_storage/database/data_sources/card_local_data_source.dart';
import 'package:tag/core/local_storage/database/tag_database.dart';
import 'package:tag/core/notifications/local_notification_service.dart';
import 'package:tag/features/cards/data/repositories/feedback_repository_impl.dart';
import 'package:tag/features/cards/data/repositories/card_repository_impl.dart';
import 'package:tag/features/cards/data/repositories/goal_plan_repository_impl.dart';
import 'package:tag/features/cards/data/repositories/preference_memory_repository_impl.dart';
import 'package:tag/features/cards/data/repositories/space_repository_impl.dart';
import 'package:tag/features/cards/domain/repositories/card_repository.dart';
import 'package:tag/features/cards/domain/repositories/feedback_repository.dart';
import 'package:tag/features/cards/domain/repositories/goal_plan_repository.dart';
import 'package:tag/features/cards/domain/repositories/preference_memory_repository.dart';
import 'package:tag/features/cards/domain/repositories/space_repository.dart';
import 'package:tag/features/cards/domain/use_cases/archive_card.dart';
import 'package:tag/features/cards/domain/use_cases/cancel_card.dart';
import 'package:tag/features/cards/domain/use_cases/complete_card.dart';
import 'package:tag/features/cards/domain/use_cases/confirm_goal_plan.dart';
import 'package:tag/features/cards/domain/use_cases/create_card_from_proposal.dart';
import 'package:tag/features/cards/domain/use_cases/create_goal_cards_from_plan.dart';
import 'package:tag/features/cards/domain/use_cases/delete_card.dart';
import 'package:tag/features/cards/domain/use_cases/dismiss_suggestion.dart';
import 'package:tag/features/cards/domain/use_cases/edit_goal_plan.dart';
import 'package:tag/features/cards/domain/use_cases/get_card_by_id.dart';
import 'package:tag/features/cards/domain/use_cases/handle_notification_action.dart';
import 'package:tag/features/cards/domain/use_cases/open_source_for_card.dart';
import 'package:tag/features/cards/domain/use_cases/snooze_card.dart';
import 'package:tag/features/cards/domain/use_cases/store_feedback_event.dart';
import 'package:tag/features/cards/domain/use_cases/update_future_goal_cards.dart';
import 'package:tag/features/cards/domain/use_cases/update_preference_memory.dart';
import 'package:tag/features/chat/domain/repositories/chat_repository.dart';
import 'package:tag/features/chat/domain/use_cases/start_edit_goal_chat.dart';
import 'package:tag/features/cards/presentation/logic/card_detail_cubit.dart';

void setUpCardsDependencies() {
  if (!locator.isRegistered<SpaceRepository>()) {
    locator.registerLazySingleton<SpaceRepository>(
      () => SpaceRepositoryImpl(database: locator<TagDatabase>()),
    );
  }

  if (!locator.isRegistered<CardRepository>()) {
    locator.registerLazySingleton<CardRepository>(
      () => CardRepositoryImpl(
        database: locator<TagDatabase>(),
        localDataSource: locator<CardLocalDataSource>(),
        spaceRepository: locator<SpaceRepository>(),
      ),
    );
  }

  if (!locator.isRegistered<GoalPlanRepository>()) {
    locator.registerLazySingleton<GoalPlanRepository>(
      () => GoalPlanRepositoryImpl(
        database: locator<TagDatabase>(),
        spaceRepository: locator<SpaceRepository>(),
      ),
    );
  }

  if (!locator.isRegistered<FeedbackRepository>()) {
    locator.registerLazySingleton<FeedbackRepository>(
      () => FeedbackRepositoryImpl(database: locator<TagDatabase>()),
    );
  }

  if (!locator.isRegistered<PreferenceMemoryRepository>()) {
    locator.registerLazySingleton<PreferenceMemoryRepository>(
      () => PreferenceMemoryRepositoryImpl(database: locator<TagDatabase>()),
    );
  }

  if (!locator.isRegistered<CreateCardFromProposal>()) {
    locator.registerLazySingleton(
      () => CreateCardFromProposal(
        locator<CardRepository>(),
        notificationService: locator<LocalNotificationService>(),
      ),
    );
  }

  if (!locator.isRegistered<CreateGoalCardsFromPlan>()) {
    locator.registerLazySingleton(
      () => CreateGoalCardsFromPlan(
        goalPlanRepository: locator<GoalPlanRepository>(),
        notificationService: locator<LocalNotificationService>(),
      ),
    );
  }

  if (!locator.isRegistered<ConfirmGoalPlan>()) {
    locator.registerLazySingleton(
      () => ConfirmGoalPlan(
        chatRepository: locator<ChatRepository>(),
        createGoalCardsFromPlan: locator<CreateGoalCardsFromPlan>(),
      ),
    );
  }

  if (!locator.isRegistered<UpdateFutureGoalCards>()) {
    locator.registerLazySingleton(
      () => UpdateFutureGoalCards(
        goalPlanRepository: locator<GoalPlanRepository>(),
        notificationService: locator<LocalNotificationService>(),
      ),
    );
  }

  if (!locator.isRegistered<DeleteCard>()) {
    locator.registerLazySingleton(
      () => DeleteCard(
        locator<CardRepository>(),
        notificationService: locator<LocalNotificationService>(),
      ),
    );
  }

  if (!locator.isRegistered<GetCardById>()) {
    locator.registerLazySingleton(() => GetCardById(locator<CardRepository>()));
  }

  if (!locator.isRegistered<StoreFeedbackEvent>()) {
    locator.registerLazySingleton(
      () => StoreFeedbackEvent(locator<FeedbackRepository>()),
    );
  }

  if (!locator.isRegistered<UpdatePreferenceMemory>()) {
    locator.registerLazySingleton(
      () => UpdatePreferenceMemory(locator<PreferenceMemoryRepository>()),
    );
  }

  if (!locator.isRegistered<EditGoalPlan>()) {
    locator.registerLazySingleton(
      () => EditGoalPlan(
        goalPlanRepository: locator<GoalPlanRepository>(),
        updateFutureGoalCards: locator<UpdateFutureGoalCards>(),
        storeFeedbackEvent: locator<StoreFeedbackEvent>(),
      ),
    );
  }

  if (!locator.isRegistered<CompleteCard>()) {
    locator.registerLazySingleton(
      () => CompleteCard(
        cardRepository: locator<CardRepository>(),
        storeFeedbackEvent: locator<StoreFeedbackEvent>(),
        updatePreferenceMemory: locator<UpdatePreferenceMemory>(),
        notificationService: locator<LocalNotificationService>(),
      ),
    );
  }

  if (!locator.isRegistered<SnoozeCard>()) {
    locator.registerLazySingleton(
      () => SnoozeCard(
        cardRepository: locator<CardRepository>(),
        storeFeedbackEvent: locator<StoreFeedbackEvent>(),
        updatePreferenceMemory: locator<UpdatePreferenceMemory>(),
        notificationService: locator<LocalNotificationService>(),
      ),
    );
  }

  if (!locator.isRegistered<CancelCard>()) {
    locator.registerLazySingleton(
      () => CancelCard(
        cardRepository: locator<CardRepository>(),
        storeFeedbackEvent: locator<StoreFeedbackEvent>(),
        updatePreferenceMemory: locator<UpdatePreferenceMemory>(),
        notificationService: locator<LocalNotificationService>(),
      ),
    );
  }

  if (!locator.isRegistered<DismissSuggestion>()) {
    locator.registerLazySingleton(
      () => DismissSuggestion(
        cardRepository: locator<CardRepository>(),
        storeFeedbackEvent: locator<StoreFeedbackEvent>(),
        updatePreferenceMemory: locator<UpdatePreferenceMemory>(),
        notificationService: locator<LocalNotificationService>(),
      ),
    );
  }

  if (!locator.isRegistered<ArchiveCard>()) {
    locator.registerLazySingleton(
      () => ArchiveCard(
        cardRepository: locator<CardRepository>(),
        storeFeedbackEvent: locator<StoreFeedbackEvent>(),
        updatePreferenceMemory: locator<UpdatePreferenceMemory>(),
        notificationService: locator<LocalNotificationService>(),
      ),
    );
  }

  if (!locator.isRegistered<HandleNotificationAction>()) {
    locator.registerLazySingleton(
      () => HandleNotificationAction(
        completeCard: locator<CompleteCard>(),
        snoozeCard: locator<SnoozeCard>(),
        cancelCard: locator<CancelCard>(),
      ),
    );
  }

  if (!locator.isRegistered<OpenSourceForCard>()) {
    locator.registerLazySingleton(
      () => OpenSourceForCard(
        cardRepository: locator<CardRepository>(),
        storeFeedbackEvent: locator<StoreFeedbackEvent>(),
        updatePreferenceMemory: locator<UpdatePreferenceMemory>(),
      ),
    );
  }

  if (!locator.isRegistered<CardDetailCubit>()) {
    locator.registerFactory(
      () => CardDetailCubit(
        getCardById: locator<GetCardById>(),
        completeCard: locator<CompleteCard>(),
        snoozeCard: locator<SnoozeCard>(),
        cancelCard: locator<CancelCard>(),
        dismissSuggestion: locator<DismissSuggestion>(),
        archiveCard: locator<ArchiveCard>(),
        openSourceForCard: locator<OpenSourceForCard>(),
        storeFeedbackEvent: locator<StoreFeedbackEvent>(),
        updatePreferenceMemory: locator<UpdatePreferenceMemory>(),
        startEditGoalChat: locator<StartEditGoalChat>(),
      ),
    );
  }
}
