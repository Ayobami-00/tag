import 'package:tag/core/DI/di.dart';
import 'package:tag/features/cards/domain/repositories/card_repository.dart';
import 'package:tag/features/cards/domain/use_cases/cancel_card.dart';
import 'package:tag/features/cards/domain/use_cases/complete_card.dart';
import 'package:tag/features/cards/domain/use_cases/delete_card.dart';
import 'package:tag/features/cards/domain/use_cases/dismiss_suggestion.dart';
import 'package:tag/features/cards/domain/use_cases/snooze_card.dart';
import 'package:tag/features/cards/domain/use_cases/store_feedback_event.dart';
import 'package:tag/features/cards/domain/use_cases/update_preference_memory.dart';
import 'package:tag/features/chat/domain/use_cases/start_edit_goal_chat.dart';
import 'package:tag/features/chat/domain/use_cases/start_plan_this_chat.dart';
import 'package:tag/features/today/domain/use_cases/watch_today_cards.dart';
import 'package:tag/features/today/presentation/logic/today_cubit.dart';

void setUpTodayDependencies() {
  if (!locator.isRegistered<WatchTodayCards>()) {
    locator.registerLazySingleton(
      () => WatchTodayCards(locator<CardRepository>()),
    );
  }

  if (!locator.isRegistered<TodayCubit>()) {
    locator.registerFactory(
      () => TodayCubit(
        watchTodayCards: locator<WatchTodayCards>(),
        deleteCard: locator<DeleteCard>(),
        completeCard: locator<CompleteCard>(),
        snoozeCard: locator<SnoozeCard>(),
        cancelCard: locator<CancelCard>(),
        dismissSuggestion: locator<DismissSuggestion>(),
        storeFeedbackEvent: locator<StoreFeedbackEvent>(),
        updatePreferenceMemory: locator<UpdatePreferenceMemory>(),
        startPlanThisChat: locator<StartPlanThisChat>(),
        startEditGoalChat: locator<StartEditGoalChat>(),
      ),
    );
  }
}
