import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tag/core/ai/cactus/cactus_model_registry.dart';
import 'package:tag/core/ai/cactus/cactus_model_service.dart';
import 'package:tag/core/ai/schemas/card_proposal_schema.dart';
import 'package:tag/core/DI/di.dart';
import 'package:tag/core/config/app_config.dart';
import 'package:tag/core/local_storage/database/tag_database.dart';
import 'package:tag/core/local_storage/file_store/local_file_store.dart';
import 'package:tag/core/local_storage/file_store/local_file_store_impl.dart';
import 'package:tag/core/navigation/route_constants.dart';
import 'package:tag/core/notifications/local_notification_permission_service.dart';
import 'package:tag/core/startup/app_cubit.dart';
import 'package:tag/core/use_cases/use_cases.dart';
import 'package:tag/features/ai_processing/domain/services/ai_job_queue_runner.dart';
import 'package:tag/features/ai_processing/domain/use_cases/process_next_ai_job.dart';
import 'package:tag/features/cards/domain/use_cases/create_card_from_proposal.dart';
import 'package:tag/features/cards/presentation/screens/card_detail_screen.dart';
import 'package:tag/features/chat/presentation/screens/chat_screen.dart';
import 'package:tag/features/model_setup/domain/repositories/model_setup_repository.dart';
import 'package:tag/features/model_setup/domain/use_cases/prepare_required_local_models.dart';
import 'package:tag/features/onboarding/domain/entities/onboarding_user_profile.dart';
import 'package:tag/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:tag/features/onboarding/domain/use_cases/load_user_profile.dart';
import 'package:tag/features/source_ingestion/domain/services/manual_source_picker.dart';
import 'package:tag/features/source_ingestion/presentation/logic/source_ingestion_cubit.dart';
import 'package:tag/features/today/presentation/screens/today_screen.dart';
import 'package:tag/utils/index.dart';
import '../../../test_support/source_ingestion_test_support.dart';

void main() {
  late Directory tempDirectory;

  setUp(() async {
    await locator.reset();
    tempDirectory = await Directory.systemTemp.createTemp('tag_today_test_');
    setUpAppLocator(
      tagDatabase: TagDatabase.forTesting(NativeDatabase.memory()),
      localFileStore: LocalFileStoreImpl(
        appDocumentsDirectoryProvider: () async => tempDirectory,
      ),
    );
    await registerStableSourceIngestionCubitForWidgetTests();
  });

  tearDown(() async {
    await locator.reset();
    if (await tempDirectory.exists()) {
      await tempDirectory.delete(recursive: true);
    }
  });

  testWidgets('shows a non-blocking setup banner while local models prepare', (
    tester,
  ) async {
    final preparationCompleter = Completer<void>();
    final cubit = AppCubit(
      appConfig: AppConfig(),
      loadUserProfile: LoadUserProfile(
        _FakeOnboardingRepository(_completedProfile()),
      ),
      prepareRequiredLocalModels: PrepareRequiredLocalModels(
        _FakeModelPreparationRepository(
          preparationFuture: preparationCompleter.future,
        ),
      ),
      aiJobQueueRunner: _FakeAiJobQueueRunner(),
      minimumModelPreparationVisibility: Duration.zero,
    );
    addTearDown(cubit.close);

    await cubit.start();

    await tester.pumpWidget(
      BlocProvider.value(
        value: cubit,
        child: MaterialApp(
          theme: TagTheme.lightTheme,
          home: const TodayScreen(),
        ),
      ),
    );

    expect(find.text('Local models are getting ready'), findsOneWidget);
    expect(
      find.textContaining('Keep saving while this finishes.'),
      findsOneWidget,
    );
    expect(find.text('Model setup'), findsOneWidget);
    expect(find.text('42%'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.byType(BackdropFilter), findsNothing);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is ModalBarrier &&
            widget.dismissible == false &&
            widget.color == Colors.transparent,
      ),
      findsNothing,
    );
    expect(find.byKey(const ValueKey('today_fab_toggle')), findsOneWidget);

    preparationCompleter.complete();
    await tester.pump();
    await tester.pump();

    expect(find.text('Local models are getting ready'), findsNothing);

    await _disposeWidgetTree(tester);
  });

  testWidgets('expands the Today FAB into icon actions', (tester) async {
    final cubit = AppCubit(
      appConfig: AppConfig(),
      loadUserProfile: LoadUserProfile(
        _FakeOnboardingRepository(_completedProfile()),
      ),
      prepareRequiredLocalModels: PrepareRequiredLocalModels(
        _FakeModelPreparationRepository(
          preparationFuture: Future<void>.value(),
        ),
      ),
      aiJobQueueRunner: _FakeAiJobQueueRunner(),
      minimumModelPreparationVisibility: Duration.zero,
    );
    addTearDown(cubit.close);

    await cubit.start();

    await tester.pumpWidget(
      BlocProvider.value(
        value: cubit,
        child: MaterialApp(
          theme: TagTheme.lightTheme,
          home: const TodayScreen(),
        ),
      ),
    );
    await tester.pump();

    expect(find.byTooltip('Open actions'), findsOneWidget);
    expect(find.text('Save a source'), findsNothing);
    expect(find.text('Paste text'), findsNothing);

    await tester.tap(find.byTooltip('Open actions'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Close actions'), findsOneWidget);
    expect(find.byTooltip('Ask Tag'), findsOneWidget);
    expect(find.byTooltip('Attach image'), findsOneWidget);
    expect(find.byIcon(Icons.auto_awesome_rounded), findsAtLeastNWidgets(1));
    expect(
      find.byIcon(Icons.add_photo_alternate_outlined),
      findsAtLeastNWidgets(1),
    );

    await _disposeWidgetTree(tester);
  });

  testWidgets('opens beta feedback from the Today app bar in beta builds', (
    tester,
  ) async {
    final appConfig = AppConfig(betaFeedbackEnabled: true);
    await locator.unregister<AppConfig>();
    locator.registerSingleton<AppConfig>(appConfig);
    final cubit = AppCubit(
      appConfig: appConfig,
      loadUserProfile: LoadUserProfile(
        _FakeOnboardingRepository(_completedProfile()),
      ),
      prepareRequiredLocalModels: PrepareRequiredLocalModels(
        _FakeModelPreparationRepository(
          preparationFuture: Future<void>.value(),
        ),
      ),
      aiJobQueueRunner: _FakeAiJobQueueRunner(),
      minimumModelPreparationVisibility: Duration.zero,
    );
    addTearDown(cubit.close);

    await cubit.start();

    final router = GoRouter(
      initialLocation: todayPath,
      routes: [
        GoRoute(path: todayPath, builder: (_, __) => const TodayScreen()),
        GoRoute(
          path: betaFeedbackPath,
          builder: (_, __) =>
              const Scaffold(body: Center(child: Text('Beta feedback route'))),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      BlocProvider.value(
        value: cubit,
        child: MaterialApp.router(
          theme: TagTheme.lightTheme,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byTooltip('Beta feedback'), findsOneWidget);

    await tester.tap(find.byTooltip('Beta feedback'));
    await tester.pumpAndSettle();

    expect(router.canPop(), isTrue);
    expect(find.text('Beta feedback route'), findsOneWidget);

    router.pop();
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, todayPath);

    await _disposeWidgetTree(tester);
  });

  testWidgets('opens FAB chat and creates a persisted chat session', (
    tester,
  ) async {
    final cubit = AppCubit(
      appConfig: AppConfig(),
      loadUserProfile: LoadUserProfile(
        _FakeOnboardingRepository(_completedProfile()),
      ),
      prepareRequiredLocalModels: PrepareRequiredLocalModels(
        _FakeModelPreparationRepository(
          preparationFuture: Future<void>.value(),
        ),
      ),
      aiJobQueueRunner: _FakeAiJobQueueRunner(),
      minimumModelPreparationVisibility: Duration.zero,
    );
    addTearDown(cubit.close);

    await cubit.start();

    final router = GoRouter(
      initialLocation: todayPath,
      routes: [
        GoRoute(path: todayPath, builder: (_, __) => const TodayScreen()),
        GoRoute(path: chatPath, builder: (_, __) => const ChatScreen()),
        GoRoute(
          path: chatSessionPath,
          builder: (_, state) =>
              ChatScreen(chatSessionId: state.pathParameters['chatSessionId']),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      BlocProvider.value(
        value: cubit,
        child: MaterialApp.router(
          theme: TagTheme.lightTheme,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Open actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Ask Tag'));
    await tester.pumpAndSettle();

    expect(
      router.routeInformationProvider.value.uri.path,
      startsWith('/chat/'),
    );
    expect(find.text('Ask Tag'), findsOneWidget);

    final sessions = await locator<TagDatabase>()
        .select(locator<TagDatabase>().chatSessions)
        .get();
    expect(sessions, hasLength(1));
    expect(sessions.single.purpose, 'general');

    await _disposeWidgetTree(tester);
  });

  testWidgets('shows the empty Today state when there are no cards', (
    tester,
  ) async {
    final cubit = AppCubit(
      appConfig: AppConfig(),
      loadUserProfile: LoadUserProfile(
        _FakeOnboardingRepository(_completedProfile()),
      ),
      prepareRequiredLocalModels: PrepareRequiredLocalModels(
        _FakeModelPreparationRepository(
          preparationFuture: Future<void>.value(),
        ),
      ),
      aiJobQueueRunner: _FakeAiJobQueueRunner(),
      minimumModelPreparationVisibility: Duration.zero,
    );
    addTearDown(cubit.close);

    await cubit.start();

    await tester.pumpWidget(
      BlocProvider.value(
        value: cubit,
        child: MaterialApp(
          theme: TagTheme.lightTheme,
          home: const TodayScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nothing needs your attention today.'), findsOneWidget);
    expect(find.textContaining("I'll turn it into a card"), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsNothing);

    await _disposeWidgetTree(tester);
  });

  testWidgets('opens card details on a back-stack route', (tester) async {
    final cubit = AppCubit(
      appConfig: AppConfig(),
      loadUserProfile: LoadUserProfile(
        _FakeOnboardingRepository(_completedProfile()),
      ),
      prepareRequiredLocalModels: PrepareRequiredLocalModels(
        _FakeModelPreparationRepository(
          preparationFuture: Future<void>.value(),
        ),
      ),
      aiJobQueueRunner: _FakeAiJobQueueRunner(),
      minimumModelPreparationVisibility: Duration.zero,
    );
    addTearDown(cubit.close);
    await cubit.start();
    await _seedNavigationCard();

    final router = GoRouter(
      initialLocation: todayPath,
      routes: [
        GoRoute(path: todayPath, builder: (_, __) => const TodayScreen()),
        GoRoute(
          path: cardDetailPath,
          builder: (_, state) =>
              CardDetailScreen(cardId: state.pathParameters['cardId'] ?? ''),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      BlocProvider.value(
        value: cubit,
        child: MaterialApp.router(
          theme: TagTheme.lightTheme,
          routerConfig: router,
        ),
      ),
    );
    await _pumpUntilFound(tester, find.text('Buy bread'));

    expect(router.canPop(), isFalse);

    await tester.tap(find.text('Buy bread'));
    await tester.pumpAndSettle();

    expect(find.text('Card'), findsOneWidget);
    expect(find.byTooltip('Back to Today'), findsOneWidget);
    expect(router.canPop(), isTrue);

    await tester.tap(find.byTooltip('Back to Today'));
    await tester.pumpAndSettle();

    expect(find.text(AppConstants.appName), findsOneWidget);
    expect(find.text('Buy bread'), findsOneWidget);
    expect(router.canPop(), isFalse);

    await _disposeWidgetTree(tester);
  });

  testWidgets('opens view switcher and filter menus inside Today', (
    tester,
  ) async {
    final cubit = AppCubit(
      appConfig: AppConfig(),
      loadUserProfile: LoadUserProfile(
        _FakeOnboardingRepository(_completedProfile()),
      ),
      prepareRequiredLocalModels: PrepareRequiredLocalModels(
        _FakeModelPreparationRepository(
          preparationFuture: Future<void>.value(),
        ),
      ),
      aiJobQueueRunner: _FakeAiJobQueueRunner(),
      minimumModelPreparationVisibility: Duration.zero,
    );
    addTearDown(cubit.close);

    await cubit.start();

    await tester.pumpWidget(
      BlocProvider.value(
        value: cubit,
        child: MaterialApp(
          theme: TagTheme.lightTheme,
          home: const TodayScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Today').first);
    await tester.pumpAndSettle();

    expect(find.text('Tomorrow'), findsOneWidget);
    expect(find.text('This Week'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Spaces'), findsOneWidget);

    await tester.tap(find.text('All'));
    await tester.pumpAndSettle();

    expect(find.text('All'), findsWidgets);

    await tester.tap(find.text('Filter'));
    await tester.pumpAndSettle();

    expect(find.text('Urgent'), findsOneWidget);
    expect(find.text('Processing'), findsOneWidget);
    expect(find.text('Goal'), findsOneWidget);
    expect(find.text('Suggestion'), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);
    expect(find.text('Snoozed'), findsOneWidget);
    expect(find.text('Cancelled'), findsOneWidget);

    await _disposeWidgetTree(tester);
  });

  testWidgets('shows Space cards through the Today view switcher', (
    tester,
  ) async {
    final cubit = AppCubit(
      appConfig: AppConfig(),
      loadUserProfile: LoadUserProfile(
        _FakeOnboardingRepository(_completedProfile()),
      ),
      prepareRequiredLocalModels: PrepareRequiredLocalModels(
        _FakeModelPreparationRepository(
          preparationFuture: Future<void>.value(),
        ),
      ),
      aiJobQueueRunner: _FakeAiJobQueueRunner(),
      minimumModelPreparationVisibility: Duration.zero,
    );
    addTearDown(cubit.close);
    await cubit.start();
    await _seedNavigationCard();

    await tester.pumpWidget(
      BlocProvider.value(
        value: cubit,
        child: MaterialApp(
          theme: TagTheme.lightTheme,
          home: const TodayScreen(),
        ),
      ),
    );
    await _pumpUntilFound(tester, find.text('Buy bread'));

    await tester.tap(find.text('Today').first);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Spaces'));
    await tester.tap(find.text('Spaces'));
    await tester.pumpAndSettle();
    await _pumpUntilFound(tester, find.text('Household Tasks'));

    expect(find.text('Household Tasks'), findsOneWidget);
    expect(find.textContaining('1 active card'), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsNothing);

    await _disposeWidgetTree(tester);
  });

  testWidgets('imports an image through the FAB and creates a Tag Card', (
    tester,
  ) async {
    await locator.reset();

    final cardDeadline = DateTime.now()
        .toLocal()
        .subtract(const Duration(minutes: 5))
        .toIso8601String();
    final imageFile = File('${tempDirectory.path}/random-test-image.png');
    imageFile.writeAsBytesSync(_tinyPngBytes);
    final cactusModelService = _FakeCactusModelService(
      visionResponses: [
        jsonEncode({
          'text': 'Please buy bread at 8pm',
          'visible_entities': ['bread'],
          'dates': <String>[],
          'times': ['8pm'],
          'links': <String>[],
          'content_type': 'message',
          'language': 'en',
          'confidence': 0.92,
        }),
      ],
      textResponses: [
        jsonEncode({
          'intention_type': 'buy',
          'confidence': 0.91,
          'title': 'Buy bread',
          'reason': 'Detected from a message screenshot.',
          'next_active_deadline': cardDeadline,
          'suggested_card_type': 'urgent',
          'space_suggestion': 'Household Tasks',
          'source_summary': 'Random image screenshot',
          'evidence_summary': 'The image says: Please buy bread at 8pm.',
        }),
      ],
    );

    locator.registerSingleton<ManualSourcePicker>(
      _FakeManualSourcePicker(
        PickedImageSource(
          path: imageFile.path,
          displayName: 'random-test-image.png',
          extension: 'png',
          sizeBytes: imageFile.lengthSync(),
        ),
      ),
    );
    setUpAppLocator(
      appConfig: AppConfig(autoDownloadRequiredModels: false),
      tagDatabase: TagDatabase.forTesting(NativeDatabase.memory()),
      localFileStore: const _FakeLocalFileStore(),
      cactusModelService: cactusModelService,
    );
    await locator.unregister<AiJobQueueRunner>();
    locator.registerSingleton<AiJobQueueRunner>(_FakeAiJobQueueRunner());
    await registerStableSourceIngestionCubitForWidgetTests();

    final cubit = AppCubit(
      appConfig: AppConfig(autoDownloadRequiredModels: false),
      loadUserProfile: LoadUserProfile(
        _FakeOnboardingRepository(_completedProfile()),
      ),
      prepareRequiredLocalModels: PrepareRequiredLocalModels(
        _FakeModelPreparationRepository(
          preparationFuture: Future<void>.value(),
        ),
      ),
      aiJobQueueRunner: _FakeAiJobQueueRunner(),
      minimumModelPreparationVisibility: Duration.zero,
    );
    addTearDown(cubit.close);
    await cubit.start();

    await tester.pumpWidget(
      BlocProvider.value(
        value: cubit,
        child: MaterialApp(
          theme: TagTheme.lightTheme,
          home: const TodayScreen(),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byTooltip('Open actions'));
    await tester.pump(const Duration(milliseconds: 220));
    await tester.runAsync(() async {
      await tester.tap(find.byTooltip('Attach image'));
    });
    final sourceCubit = tester
        .element(find.byType(Scaffold))
        .read<SourceIngestionCubit>();
    await _waitForImageImport(tester, sourceCubit);
    await _disposeWidgetTree(tester);
    await _processQueuedAiJob(tester);

    await tester.pumpWidget(
      BlocProvider.value(
        value: cubit,
        child: MaterialApp(
          theme: TagTheme.lightTheme,
          home: const TodayScreen(),
        ),
      ),
    );
    await _pumpUntilFound(tester, find.text('Buy bread'));

    expect(cactusModelService.visionCompletionCount, 1);
    expect(cactusModelService.textCompletionCount, 1);
    expect(find.text('URGENT'), findsOneWidget);
    expect(find.text('Buy bread'), findsOneWidget);
    expect(
      find.textContaining('Detected from a message screenshot'),
      findsOneWidget,
    );
    expect(find.text('Household Tasks'), findsOneWidget);
    expect(find.text('Random image screenshot'), findsOneWidget);

    await tester.tap(find.byTooltip('Expand card'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Detected from a message screenshot'),
      findsOneWidget,
    );
    expect(find.text('Household Tasks'), findsOneWidget);
    expect(find.text('Random image screenshot'), findsOneWidget);
    expect(find.textContaining('The image says'), findsNothing);
    expect(find.text('Complete'), findsOneWidget);
    expect(find.text('Snooze'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);

    await tester.drag(find.byType(Dismissible).first, const Offset(-500, 0));
    await tester.pumpAndSettle();

    expect(find.text('Buy bread'), findsNothing);
    expect(find.textContaining('Deleted'), findsOneWidget);

    await _disposeWidgetTree(tester);
  });
}

class _FakeAiJobQueueRunner implements AiJobQueueRunner {
  @override
  bool get isProcessing => false;

  @override
  void start() {}

  @override
  void stop() {}

  @override
  void requestProcessing() {}

  @override
  Future<void> drain() async {}
}

Future<void> _disposeWidgetTree(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 1));
}

Future<void> _processQueuedAiJob(
  WidgetTester tester, {
  int attempts = 20,
}) async {
  final processedJob = await tester.runAsync<bool>(() async {
    final processNextAiJob = locator<ProcessNextAiJob>();

    await Future<void>.delayed(const Duration(milliseconds: 50));
    for (var attempt = 0; attempt < attempts; attempt++) {
      final job = await processNextAiJob(const NoParams());
      if (job != null) {
        return true;
      }

      await Future<void>.delayed(const Duration(milliseconds: 10));
    }

    return false;
  });

  if (processedJob != true) {
    throw TestFailure('Expected an image import AI job to be queued.');
  }
}

Future<void> _pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  int attempts = 20,
}) async {
  for (var attempt = 0; attempt < attempts; attempt++) {
    await tester.pump(const Duration(milliseconds: 50));

    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }

  throw TestFailure(
    'Expected the created Tag Card to appear after processing queued AI jobs.',
  );
}

Future<void> _waitForImageImport(
  WidgetTester tester,
  SourceIngestionCubit sourceCubit,
) async {
  final status = await tester.runAsync<SourceIngestionStatus>(() async {
    for (var attempt = 0; attempt < 50; attempt++) {
      if (sourceCubit.state.status == SourceIngestionStatus.saved ||
          sourceCubit.state.status == SourceIngestionStatus.failure) {
        return sourceCubit.state.status;
      }
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }

    return sourceCubit.state.status;
  });

  if (status != SourceIngestionStatus.saved) {
    throw TestFailure('Expected image import to save, got ${status?.name}.');
  }
}

Future<void> _seedNavigationCard() async {
  final database = locator<TagDatabase>();
  final now = DateTime.utc(2026, 5, 10, 12).millisecondsSinceEpoch;

  await database
      .into(database.sourceItems)
      .insert(
        SourceItemsCompanion.insert(
          id: 'src_navigation',
          type: 'text',
          sourceSummary: const Value('Navigation test source'),
          contentType: const Value('message'),
          rawText: const Value('Please buy bread.'),
          extractedText: const Value('Please buy bread.'),
          createdAt: now,
          updatedAt: now,
        ),
      );

  final createCardFromProposal = locator<CreateCardFromProposal>();
  await createCardFromProposal(
    CreateCardFromProposalParams(
      proposal: CardProposal.fromJson({
        'card_type': 'urgent',
        'title': 'Buy bread',
        'reason': 'Detected from a saved local source.',
        'space_name': 'Household Tasks',
        'next_active_deadline': DateTime.utc(2026, 5, 10, 20).toIso8601String(),
        'source_ids': ['src_navigation'],
        'actions': ['complete', 'snooze', 'cancel'],
        'confidence': 0.91,
      }),
    ),
  );
}

OnboardingUserProfile _completedProfile() {
  final now = DateTime.utc(2026, 5, 9, 10).millisecondsSinceEpoch;

  return OnboardingUserProfile(
    id: 'local_user',
    nickname: 'Alex',
    avatarKind: 'asset',
    avatarValue: 'memoji_02',
    localOnly: true,
    onboardingCompletedAt: now,
    notificationPermissionState: NotificationPermissionState.unknown,
    createdAt: now,
    updatedAt: now,
  );
}

class _FakeModelPreparationRepository implements ModelSetupRepository {
  const _FakeModelPreparationRepository({required this.preparationFuture});

  final Future<void> preparationFuture;

  @override
  Future<void> prepareRequiredModels({
    void Function(ModelPreparationProgress progress)? onProgress,
  }) {
    onProgress?.call(
      const ModelPreparationProgress(
        progress: 0.42,
        statusMessage: 'Downloading local models...',
      ),
    );
    return preparationFuture;
  }

  @override
  Future<List<LocalAiModelInfo>> discoverModels() {
    throw UnimplementedError();
  }

  @override
  Future<List<LocalAiModelInfo>> loadCachedModels() {
    throw UnimplementedError();
  }

  @override
  Future<void> downloadModel(
    String slug, {
    void Function(ModelDownloadProgress progress)? onProgress,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> initializeModel(String slug) {
    throw UnimplementedError();
  }

  @override
  Future<String> loadSelectedEmbeddingModelSlug() {
    throw UnimplementedError();
  }

  @override
  Future<String> loadSelectedPrimaryModelSlug() {
    throw UnimplementedError();
  }

  @override
  Future<void> selectEmbeddingModel(String slug) {
    throw UnimplementedError();
  }

  @override
  Future<void> selectPrimaryModel(String slug) {
    throw UnimplementedError();
  }
}

class _FakeOnboardingRepository implements OnboardingRepository {
  const _FakeOnboardingRepository(this.profile);

  final OnboardingUserProfile? profile;

  @override
  Future<OnboardingUserProfile?> loadUserProfile() async => profile;

  @override
  Future<OnboardingUserProfile> saveNickname(String nickname) {
    throw UnimplementedError();
  }

  @override
  Future<OnboardingUserProfile> saveAvatar({
    required String avatarKind,
    required String avatarValue,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<OnboardingUserProfile> requestNotificationPermission() {
    throw UnimplementedError();
  }

  @override
  Future<OnboardingUserProfile> skipNotificationPermission() {
    throw UnimplementedError();
  }

  @override
  Future<OnboardingUserProfile> completeOnboarding() {
    throw UnimplementedError();
  }
}

class _FakeManualSourcePicker implements ManualSourcePicker {
  const _FakeManualSourcePicker(this.image);

  final PickedImageSource image;

  @override
  Future<PickedImageSource?> pickImage() async => image;
}

class _FakeLocalFileStore implements LocalFileStore {
  const _FakeLocalFileStore();

  @override
  Future<Directory> ensureInitialized() async => Directory.systemTemp;

  @override
  Future<LocalFileStoreStatus> checkStatus() async {
    return LocalFileStoreStatus(
      isHealthy: true,
      rootPath: Directory.systemTemp.path,
      requiredDirectoryPaths: const [],
      requiredDirectoryLabels: const [],
    );
  }

  @override
  Future<String> imagePathForSource(
    String sourceId, {
    String extension = '.png',
  }) async {
    return '${Directory.systemTemp.path}/$sourceId$extension';
  }

  @override
  Future<String> thumbnailPathForSource(
    String sourceId, {
    String extension = '.jpg',
  }) async {
    return '${Directory.systemTemp.path}/$sourceId$extension';
  }

  @override
  Future<String> textPathForSource(String sourceId) async {
    return '${Directory.systemTemp.path}/$sourceId.txt';
  }

  @override
  Future<String> copyImageSource({
    required String sourceId,
    required File sourceFile,
    String? extension,
  }) async {
    return sourceFile.path;
  }

  @override
  Future<String> writeTextSource({
    required String sourceId,
    required String text,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<String> readTextSource(String sourceId) {
    throw UnimplementedError();
  }

  @override
  Future<bool> exists(String localPath) async => true;

  @override
  Future<bool> deleteFileIfExists(String localPath) async => true;
}

class _FakeCactusModelService implements CactusModelService {
  _FakeCactusModelService({
    required List<String> visionResponses,
    required List<String> textResponses,
  }) : _visionResponses = Queue.of(visionResponses),
       _textResponses = Queue.of(textResponses);

  final Queue<String> _visionResponses;
  final Queue<String> _textResponses;
  int visionCompletionCount = 0;
  int textCompletionCount = 0;

  @override
  Future<List<LocalAiModelInfo>> getAvailableModels() async {
    return const [
      LocalAiModelInfo(
        slug: CactusModelRegistry.primaryVisionToolModelSlug,
        displayName: 'Gemma 4 E2B IT',
        capabilities: {
          AiModelCapability.completion,
          AiModelCapability.tools,
          AiModelCapability.vision,
        },
        isDownloaded: true,
      ),
    ];
  }

  @override
  Future<AiCompletionResult> complete({
    required String modelSlug,
    required List<AiChatMessage> messages,
    List<AiToolSchema> tools = const [],
    AiCompletionOptions options = const AiCompletionOptions(),
  }) async {
    textCompletionCount++;
    return AiCompletionResult(response: _textResponses.removeFirst());
  }

  @override
  Future<AiVisionResult> completeWithImage({
    required String modelSlug,
    required String imagePath,
    required List<AiChatMessage> messages,
    List<AiToolSchema> tools = const [],
    AiCompletionOptions options = const AiCompletionOptions(),
  }) async {
    visionCompletionCount++;
    return AiVisionResult(response: _visionResponses.removeFirst());
  }

  @override
  Future<void> downloadModel(
    String slug, {
    void Function(ModelDownloadProgress progress)? onProgress,
  }) async {}

  @override
  Future<void> initializeModel(String slug) async {}

  @override
  Future<void> unloadModel(String slug) async {}

  @override
  Stream<String> streamComplete({
    required String modelSlug,
    required List<AiChatMessage> messages,
    List<AiToolSchema> tools = const [],
    AiCompletionOptions options = const AiCompletionOptions(),
  }) {
    throw UnimplementedError();
  }

  @override
  Future<AiEmbeddingResult> embedText({
    required String modelSlug,
    required String text,
  }) {
    throw UnimplementedError();
  }
}

const _tinyPngBytes = [
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0A,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x0D,
  0x0A,
  0x2D,
  0xB4,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
  0x42,
  0x60,
  0x82,
];
