import 'package:tag/core/DI/di.dart';
import 'package:tag/core/ai/cactus/cactus_model_service.dart';
import 'package:tag/core/ai/rag/local_rag_service.dart';
import 'package:tag/core/local_storage/database/tag_database.dart';
import 'package:tag/features/cards/domain/repositories/card_repository.dart';
import 'package:tag/features/cards/domain/repositories/goal_plan_repository.dart';
import 'package:tag/features/cards/domain/use_cases/confirm_goal_plan.dart';
import 'package:tag/features/cards/domain/use_cases/edit_goal_plan.dart';
import 'package:tag/features/chat/data/data_sources/chat_local_data_source.dart';
import 'package:tag/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:tag/features/chat/domain/repositories/chat_repository.dart';
import 'package:tag/features/chat/domain/use_cases/ask_saved_context.dart';
import 'package:tag/features/chat/domain/use_cases/generate_goal_plan_preview.dart';
import 'package:tag/features/chat/domain/use_cases/start_edit_goal_chat.dart';
import 'package:tag/features/chat/domain/use_cases/start_fab_chat.dart';
import 'package:tag/features/chat/domain/use_cases/start_plan_this_chat.dart';
import 'package:tag/features/chat/presentation/logic/chat_cubit.dart';
import 'package:tag/features/model_setup/domain/repositories/model_setup_repository.dart';
import 'package:tag/features/source_ingestion/domain/repositories/source_repository.dart';

void setUpChatDependencies() {
  if (!locator.isRegistered<ChatLocalDataSource>()) {
    locator.registerLazySingleton<ChatLocalDataSource>(
      () => DriftChatLocalDataSource(locator<TagDatabase>()),
    );
  }

  if (!locator.isRegistered<ChatRepository>()) {
    locator.registerLazySingleton<ChatRepository>(
      () => ChatRepositoryImpl(localDataSource: locator<ChatLocalDataSource>()),
    );
  }

  if (!locator.isRegistered<StartFabChat>()) {
    locator.registerLazySingleton(
      () => StartFabChat(locator<ChatRepository>()),
    );
  }

  if (!locator.isRegistered<StartPlanThisChat>()) {
    locator.registerLazySingleton(
      () => StartPlanThisChat(locator<ChatRepository>()),
    );
  }

  if (!locator.isRegistered<StartEditGoalChat>()) {
    locator.registerLazySingleton(
      () => StartEditGoalChat(
        chatRepository: locator<ChatRepository>(),
        goalPlanRepository: locator<GoalPlanRepository>(),
      ),
    );
  }

  if (!locator.isRegistered<AskSavedContext>()) {
    locator.registerLazySingleton(
      () => AskSavedContext(
        localRagService: locator<LocalRagService>(),
        cactusModelService: locator<CactusModelService>(),
        modelSetupRepository: locator<ModelSetupRepository>(),
      ),
    );
  }

  if (!locator.isRegistered<GenerateGoalPlanPreview>()) {
    locator.registerLazySingleton(
      () => GenerateGoalPlanPreview(
        chatRepository: locator<ChatRepository>(),
        cardRepository: locator<CardRepository>(),
        sourceRepository: locator<SourceRepository>(),
        cactusModelService: locator<CactusModelService>(),
        modelSetupRepository: locator<ModelSetupRepository>(),
      ),
    );
  }

  if (!locator.isRegistered<ChatCubit>()) {
    locator.registerFactory(
      () => ChatCubit(
        startFabChat: locator<StartFabChat>(),
        chatRepository: locator<ChatRepository>(),
        askSavedContext: locator<AskSavedContext>(),
        generateGoalPlanPreview: locator<GenerateGoalPlanPreview>(),
        confirmGoalPlan: locator<ConfirmGoalPlan>(),
        editGoalPlan: locator<EditGoalPlan>(),
      ),
    );
  }
}
