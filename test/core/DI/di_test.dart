import 'package:flutter_test/flutter_test.dart';
import 'package:tag/core/index.dart';
import 'package:tag/features/ai_processing/index.dart';
import 'package:tag/features/chat/index.dart';
import 'package:tag/features/model_setup/index.dart';
import 'package:tag/features/onboarding/index.dart';
import 'package:tag/features/rag/index.dart';
import 'package:tag/features/spaces/index.dart';
import 'package:tag/features/source_ingestion/index.dart';

void main() {
  setUp(() async {
    await locator.reset();
  });

  tearDown(() async {
    await locator.reset();
  });

  test('setUpAppLocator registers core startup dependencies', () {
    expect(setUpAppLocator, returnsNormally);

    expect(locator.isRegistered<AppConfig>(), isTrue);
    expect(locator.isRegistered<TagDatabase>(), isTrue);
    expect(locator.isRegistered<DatabaseHealthCheck>(), isTrue);
    expect(locator.isRegistered<LocalFileStore>(), isTrue);
    expect(locator.isRegistered<CardLocalDataSource>(), isTrue);
    expect(locator.isRegistered<AiModelAssetsLocalDataSource>(), isTrue);
    expect(locator.isRegistered<CactusModelService>(), isTrue);
    expect(locator.isRegistered<DeviceStorageService>(), isTrue);
    expect(locator.isRegistered<LocalNotificationPermissionService>(), isTrue);
    expect(locator.isRegistered<OnboardingLocalDataSource>(), isTrue);
    expect(locator.isRegistered<OnboardingRepository>(), isTrue);
    expect(locator.isRegistered<LoadUserProfile>(), isTrue);
    expect(locator.isRegistered<SaveNickname>(), isTrue);
    expect(locator.isRegistered<SaveAvatar>(), isTrue);
    expect(locator.isRegistered<RequestNotificationPermission>(), isTrue);
    expect(locator.isRegistered<CompleteOnboarding>(), isTrue);
    expect(locator.isRegistered<OnboardingCubit>(), isTrue);
    expect(locator.isRegistered<ModelSetupRepository>(), isTrue);
    expect(locator.isRegistered<DiscoverCactusModels>(), isTrue);
    expect(locator.isRegistered<LoadCachedAiModels>(), isTrue);
    expect(locator.isRegistered<PrepareRequiredLocalModels>(), isTrue);
    expect(locator.isRegistered<DownloadCactusModel>(), isTrue);
    expect(locator.isRegistered<InitializeCactusModel>(), isTrue);
    expect(locator.isRegistered<LoadSelectedEmbeddingModel>(), isTrue);
    expect(locator.isRegistered<SelectEmbeddingModel>(), isTrue);
    expect(locator.isRegistered<ModelSetupCubit>(), isTrue);
    expect(locator.isRegistered<AiJobLocalDataSource>(), isTrue);
    expect(locator.isRegistered<AiJobRepository>(), isTrue);
    expect(locator.isRegistered<FakeAiJobProcessor>(), isTrue);
    expect(locator.isRegistered<AiJobProcessor>(), isTrue);
    expect(locator.isRegistered<ProcessNextAiJob>(), isTrue);
    expect(locator.isRegistered<AiJobQueueRunner>(), isTrue);
    expect(locator.isRegistered<WatchAiJobs>(), isTrue);
    expect(locator.isRegistered<RetryAiJob>(), isTrue);
    expect(locator.isRegistered<CancelAiJob>(), isTrue);
    expect(locator.isRegistered<QueueDebugFailingAiJob>(), isTrue);
    expect(locator.isRegistered<AiJobQueueCubit>(), isTrue);
    expect(locator.isRegistered<RagLocalDataSource>(), isTrue);
    expect(locator.isRegistered<SourceChunker>(), isTrue);
    expect(locator.isRegistered<LocalVectorIndex>(), isTrue);
    expect(locator.isRegistered<LocalRagService>(), isTrue);
    expect(locator.isRegistered<GetRagIndexStatus>(), isTrue);
    expect(locator.isRegistered<SearchSavedContext>(), isTrue);
    expect(locator.isRegistered<RagDebugCubit>(), isTrue);
    expect(locator.isRegistered<ChatLocalDataSource>(), isTrue);
    expect(locator.isRegistered<ChatRepository>(), isTrue);
    expect(locator.isRegistered<StartFabChat>(), isTrue);
    expect(locator.isRegistered<StartPlanThisChat>(), isTrue);
    expect(locator.isRegistered<AskSavedContext>(), isTrue);
    expect(locator.isRegistered<GenerateGoalPlanPreview>(), isTrue);
    expect(locator.isRegistered<ChatCubit>(), isTrue);
    expect(locator.isRegistered<SourceLocalDataSource>(), isTrue);
    expect(locator.isRegistered<ManualSourcePicker>(), isTrue);
    expect(locator.isRegistered<ShareIntakeService>(), isTrue);
    expect(locator.isRegistered<SourceRepository>(), isTrue);
    expect(locator.isRegistered<StoreSourceFile>(), isTrue);
    expect(locator.isRegistered<QueueSourceProcessing>(), isTrue);
    expect(locator.isRegistered<ImportImageSource>(), isTrue);
    expect(locator.isRegistered<CreateTextSource>(), isTrue);
    expect(locator.isRegistered<IngestSharedSource>(), isTrue);
    expect(locator.isRegistered<ImportPendingSharedSources>(), isTrue);
    expect(locator.isRegistered<GetSourceById>(), isTrue);
    expect(locator.isRegistered<WatchRecentSources>(), isTrue);
    expect(locator.isRegistered<UpdateSourceProcessingState>(), isTrue);
    expect(locator.isRegistered<SourceIngestionCubit>(), isTrue);
    expect(locator.isRegistered<SpacesLocalDataSource>(), isTrue);
    expect(locator.isRegistered<SpacesRepository>(), isTrue);
    expect(locator.isRegistered<WatchSpaceSummaries>(), isTrue);
    expect(locator.isRegistered<GetSpaceDetail>(), isTrue);
    expect(locator.isRegistered<RecordSpaceView>(), isTrue);
    expect(locator.isRegistered<SpacesCubit>(), isTrue);
    expect(locator.isRegistered<SpaceDetailCubit>(), isTrue);
    expect(locator.isRegistered<AppCubit>(), isTrue);
    expect(locator.isRegistered<NavigationService>(), isTrue);
  });
}
