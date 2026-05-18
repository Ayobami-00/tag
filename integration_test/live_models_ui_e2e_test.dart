import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:tag/app.dart';
import 'package:tag/core/DI/di.dart';
import 'package:tag/core/ai/cactus/cactus_model_service.dart';
import 'package:tag/core/config/app_config.dart';
import 'package:tag/core/local_storage/database/tag_database.dart';
import 'package:tag/core/notifications/local_notification_service.dart';
import 'package:tag/features/ai_processing/domain/entities/ai_processing_job_entity.dart';
import 'package:tag/features/ai_processing/domain/services/ai_job_queue_runner.dart';
import 'package:tag/features/cards/domain/entities/card_entities.dart';
import 'package:tag/features/cards/domain/entities/card_query.dart';
import 'package:tag/features/cards/domain/repositories/card_repository.dart';
import 'package:tag/features/cards/domain/use_cases/handle_notification_action.dart';
import 'package:tag/features/chat/domain/entities/chat_entities.dart';
import 'package:tag/features/chat/domain/entities/guided_planning_entities.dart';
import 'package:tag/features/model_setup/domain/repositories/model_setup_repository.dart';
import 'package:tag/features/model_setup/domain/use_cases/prepare_required_local_models.dart';
import 'package:tag/features/source_ingestion/domain/entities/source_item_entity.dart';
import 'package:tag/features/source_ingestion/domain/repositories/source_repository.dart';
import 'package:tag/features/source_ingestion/domain/use_cases/create_text_source.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets(
    'live local models can drive the app tap-by-tap',
    (tester) async {
      await binding.convertFlutterSurfaceToImage();

      await _launchTestApp();
      final evidence = _LiveUiEvidence(binding);
      final harness = _LiveUiHarness(tester: tester, evidence: evidence);

      await harness.waitForAppEntry();
      await harness.completeOnboardingIfNeeded();
      await harness.waitForToday();
      await evidence.capture('01_today_launch');

      final seed = await harness.createLiveSuggestionCard();
      await harness.waitForFinder(
        find.byKey(ValueKey('today_card_${seed.card.id}')),
        description: 'live seeded Today card',
        timeout: const Duration(minutes: 1),
      );
      await tester.ensureVisible(
        find.byKey(ValueKey('today_card_${seed.card.id}')),
      );
      await tester.pump(const Duration(milliseconds: 300));
      await evidence.capture('02_live_card_created');

      await harness.tapKey('today_fab_toggle');
      await evidence.capture('03_today_fab_open');

      await harness.tapKey('today_fab_ask_tag');
      await harness.waitForFinder(
        find.byKey(const ValueKey('chat_composer_field')),
        description: 'chat composer',
      );
      await evidence.capture('04_chat_open');

      await tester.enterText(
        find.byKey(const ValueKey('chat_composer_field')),
        'What did I save with TAG live UI E2E marker ${seed.runId} '
        'about the feedback call?',
      );
      await tester.pump(const Duration(milliseconds: 300));
      await evidence.capture('05_chat_prompt_entered');

      await harness.tapKey('chat_send_button');
      await evidence.capture('06_chat_sent');

      final citationFinder = find.byKey(
        ValueKey('chat_citation_${seed.source.id}'),
      );
      await harness.waitForFinder(
        citationFinder,
        description: 'source-backed chat answer',
        timeout: const Duration(minutes: 12),
        scroll: true,
      );
      await tester.ensureVisible(citationFinder);
      await tester.pump(const Duration(milliseconds: 300));
      await evidence.capture('07_chat_answer_with_citation');

      await tester.tap(citationFinder);
      await harness.waitForText('Source', timeout: const Duration(minutes: 1));
      await evidence.capture('08_source_preview_from_citation');

      await harness.tapTooltip('Back');
      await harness.waitForFinder(
        find.byKey(const ValueKey('chat_composer_field')),
        description: 'chat after source preview back',
      );
      await evidence.capture('09_back_to_chat');

      await harness.tapTooltip('Back to Today');
      await harness.waitForToday();
      await tester.ensureVisible(
        find.byKey(ValueKey('today_card_${seed.card.id}')),
      );
      await tester.pump(const Duration(milliseconds: 300));
      await evidence.capture('10_today_card_visible_again');

      await harness.tapKey('tag_card_expand_${seed.card.id}');
      await evidence.capture('11_card_expanded_actions');

      await harness.tapKey(
        'tag_card_action_${seed.card.id}_${TagCardAction.planThis.storageValue}',
      );
      await harness.waitForFinder(
        find.byKey(
          ValueKey('planning_choice_${PlanStyleChoice.weekend.storageValue}'),
        ),
        description: 'guided planning style choices',
        timeout: const Duration(minutes: 1),
      );
      await evidence.capture('12_guided_planning_style_choices');

      await harness.tapKey(
        'planning_choice_${PlanStyleChoice.weekend.storageValue}',
      );
      await harness.waitForFinder(
        find.byKey(
          ValueKey('planning_choice_${WeeklyTimeChoice.oneHour.storageValue}'),
        ),
        description: 'guided planning time choices',
        timeout: const Duration(minutes: 2),
      );
      await evidence.capture('13_guided_planning_time_choices');

      await harness.tapKey(
        'planning_choice_${WeeklyTimeChoice.oneHour.storageValue}',
      );
      await harness.waitForFinder(
        find.byKey(const ValueKey('goal_plan_preview_create_cards_button')),
        description: 'confirmation-gated goal plan preview',
        timeout: const Duration(minutes: 6),
        scroll: true,
      );
      await evidence.capture('14_goal_plan_preview_requires_confirmation');

      await harness.tapKey('goal_plan_preview_create_cards_button');
      await harness.waitForText(
        'Done. I created',
        timeout: const Duration(seconds: 30),
        scroll: true,
      );
      await evidence.capture('15_create_cards_confirmation_notice');

      final finalResult = await harness.verifyLocalOnlyRules(seed);
      await evidence.writeManifest(finalResult);
      debugPrint(
        'TAG_LIVE_UI_E2E_RESULT ${jsonEncode(finalResult)}',
        wrapWidth: 4096,
      );
    },
    timeout: const Timeout(Duration(minutes: 45)),
  );
}

Future<void> _launchTestApp() async {
  setUpAppLocator(appConfig: AppConfig(autoDownloadRequiredModels: false));
  await locator<LocalNotificationService>().initialize(
    onAction: locator<HandleNotificationAction>(),
  );

  runApp(const App());
}

class _LiveUiHarness {
  _LiveUiHarness({required this.tester, required this.evidence});

  final WidgetTester tester;
  final _LiveUiEvidence evidence;

  Future<void> waitForAppEntry() {
    return _pumpUntil(
      description: 'app entry screen',
      timeout: const Duration(minutes: 2),
      condition: () =>
          find
              .byKey(const ValueKey('today_fab_toggle'))
              .evaluate()
              .isNotEmpty ||
          find
              .byKey(const ValueKey('onboarding_start_button'))
              .evaluate()
              .isNotEmpty,
    );
  }

  Future<void> completeOnboardingIfNeeded() async {
    final startButton = find.byKey(const ValueKey('onboarding_start_button'));
    if (startButton.evaluate().isEmpty) {
      return;
    }

    await evidence.capture('00_onboarding_welcome');
    await tapKey('onboarding_start_button');
    await evidence.capture('00_onboarding_nickname');

    await tester.enterText(
      find.byKey(const ValueKey('nickname_field')),
      'Live Test',
    );
    await tapKey('nickname_continue_button');
    await evidence.capture('00_onboarding_avatar');

    await tapText('Use selected');
    await evidence.capture('00_onboarding_local_first');

    await tapKey('local_models_start_sooner_button');
    await evidence.capture('00_onboarding_notifications');

    await tapKey('skip_notifications_button');
    await evidence.capture('00_onboarding_share');

    await tapKey('finish_onboarding_button');
    await waitForToday();
  }

  Future<void> waitForToday() async {
    await waitForFinder(
      find.byKey(const ValueKey('today_fab_toggle')),
      description: 'Today screen',
      timeout: const Duration(minutes: 2),
    );
    await _pumpUntil(
      description: 'local model preparation overlay to clear',
      timeout: const Duration(minutes: 45),
      condition: () => find.text('Setting up your app').evaluate().isEmpty,
    );
  }

  Future<_LiveSeed> createLiveSuggestionCard() async {
    final runId = DateTime.now().toUtc().millisecondsSinceEpoch.toString();
    final modelProgress = <String>[];
    String? lastLoggedModelProgress;
    var lastLoggedAt = DateTime.fromMillisecondsSinceEpoch(0);

    await locator<PrepareRequiredLocalModels>().withProgress(
      onProgress: (progress) {
        modelProgress.add(progress.statusMessage);
        final now = DateTime.now();
        final shouldLog =
            progress.statusMessage != lastLoggedModelProgress ||
            now.difference(lastLoggedAt) >= const Duration(seconds: 20) ||
            progress.progress == 1;
        if (shouldLog) {
          debugPrint(
            'TAG_LIVE_UI_E2E_MODEL ${progress.statusMessage}'
            '${progress.progress == null ? '' : ' ${(progress.progress! * 100).toStringAsFixed(0)}%'}',
          );
          lastLoggedModelProgress = progress.statusMessage;
          lastLoggedAt = now;
        }
      },
    );

    final modelSetup = locator<ModelSetupRepository>();
    final primarySlug = await modelSetup.loadSelectedPrimaryModelSlug();
    final embeddingSlug = await modelSetup.loadSelectedEmbeddingModelSlug();
    final availableModels = await locator<CactusModelService>()
        .getAvailableModels();
    final primaryModel = _modelBySlug(availableModels, primarySlug);
    final embeddingModel = _modelBySlug(availableModels, embeddingSlug);
    expect(
      primaryModel?.isDownloaded,
      isTrue,
      reason: 'Primary model $primarySlug must be downloaded.',
    );
    expect(
      embeddingModel?.isDownloaded,
      isTrue,
      reason: 'Embedding model $embeddingSlug must be downloaded.',
    );

    final source = await locator<CreateTextSource>()(
      CreateTextSourceParams('''
TAG live UI E2E marker $runId.
Could we do a call this weekend to get feedback on the open-source human-in-the-loop prototype demo?
I saved this because I want Tag to keep the source evidence attached and turn it into a small plan.
'''),
    );

    await _waitForJob(source.id);
    locator<AiJobQueueRunner>().requestProcessing();
    await locator<AiJobQueueRunner>().drain();
    final completedJob = await _waitForCompletedJob(source.id);
    expect(completedJob.status, AiJobStatus.completed);

    final processedSource = await locator<SourceRepository>().getSourceById(
      source.id,
    );
    expect(processedSource, isNotNull);
    expect(processedSource!.processingState, SourceProcessingState.completed);
    expect(processedSource.extractedText?.trim().isNotEmpty, isTrue);

    final card = await _loadCreatedSuggestionCard(processedSource.id);
    final notifications = await locator<LocalNotificationService>()
        .requestsForCard(card.id);
    expect(
      notifications,
      isEmpty,
      reason: 'Suggestion Cards must never schedule notifications.',
    );

    return _LiveSeed(
      runId: runId,
      source: processedSource,
      card: card,
      primaryModelSlug: primarySlug,
      embeddingModelSlug: embeddingSlug,
      modelProgress: modelProgress,
    );
  }

  Future<Map<String, Object?>> verifyLocalOnlyRules(_LiveSeed seed) async {
    final card = (await locator<CardRepository>().getCardById(seed.card.id))!;
    final notifications = await locator<LocalNotificationService>()
        .requestsForCard(card.id);
    final planningSession = await _latestPlanningSession();

    expect(card.cardType, TagCardType.suggestion);
    expect(card.sourceIds, contains(seed.source.id));
    expect(card.space.id.trim().isNotEmpty, isTrue);
    expect(notifications, isEmpty);
    expect(planningSession?.pendingConfirmationJson, isNull);
    expect(planningSession?.linkedGoalPlanId, isNotNull);

    return {
      'ok': true,
      'run_id': seed.runId,
      'models': {
        'primary': seed.primaryModelSlug,
        'embedding': seed.embeddingModelSlug,
        'progress_tail': seed.modelProgress.take(6).toList(growable: false),
      },
      'source': {
        'id': seed.source.id,
        'state': seed.source.processingState.storageValue,
        'has_extracted_text':
            seed.source.extractedText?.trim().isNotEmpty == true,
      },
      'card': {
        'id': card.id,
        'title': card.title,
        'type': card.cardType.storageValue,
        'status': card.status.storageValue,
        'space': card.space.name,
        'source_count': card.sourceIds.length,
        'notification_request_count': notifications.length,
      },
      'guided_planning': {
        'session_id': planningSession?.id,
        'pending_confirmation_consumed':
            planningSession?.pendingConfirmationJson == null,
        'linked_goal_plan_id': planningSession?.linkedGoalPlanId,
      },
      'screenshots': evidence.screenshotNames,
    };
  }

  Future<void> tapKey(String key) async {
    final finder = find.byKey(ValueKey(key));
    await waitForFinder(finder, description: key);
    await tester.ensureVisible(finder);
    await tester.pump(const Duration(milliseconds: 200));
    final hitTestableFinder = finder.hitTestable();
    await _pumpUntil(
      description: '$key visible',
      timeout: const Duration(seconds: 10),
      scroll: true,
      condition: () => hitTestableFinder.evaluate().isNotEmpty,
    );
    await tester.tap(hitTestableFinder);
    await tester.pump(const Duration(milliseconds: 500));
  }

  Future<void> tapText(String text) async {
    final finder = find.text(text);
    await waitForFinder(finder, description: text);
    await tester.ensureVisible(finder);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(finder);
    await tester.pump(const Duration(milliseconds: 500));
  }

  Future<void> tapTooltip(String tooltip) async {
    final finder = find.byTooltip(tooltip);
    await waitForFinder(finder, description: tooltip);
    await tester.tap(finder);
    await tester.pump(const Duration(milliseconds: 500));
  }

  Future<void> waitForText(
    String text, {
    Duration timeout = const Duration(minutes: 1),
    bool scroll = false,
  }) {
    return waitForFinder(
      find.textContaining(text),
      description: text,
      timeout: timeout,
      scroll: scroll,
    );
  }

  Future<void> waitForFinder(
    Finder finder, {
    required String description,
    Duration timeout = const Duration(minutes: 1),
    bool scroll = false,
  }) {
    return _pumpUntil(
      description: description,
      timeout: timeout,
      scroll: scroll,
      condition: () => scroll
          ? finder.hitTestable().evaluate().isNotEmpty
          : finder.evaluate().isNotEmpty,
    );
  }

  Future<void> _pumpUntil({
    required String description,
    required bool Function() condition,
    required Duration timeout,
    bool scroll = false,
  }) async {
    final deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      await tester.pump(const Duration(milliseconds: 300));
      if (condition()) {
        return;
      }
      if (scroll) {
        await _nudgePrimaryScrollableDown();
      }
    }

    fail('Timed out waiting for $description.');
  }

  Future<void> _nudgePrimaryScrollableDown() async {
    final scrollable = find.byType(Scrollable);
    if (scrollable.evaluate().isEmpty) {
      return;
    }

    try {
      await tester.drag(scrollable.first, const Offset(0, -180));
      await tester.pump(const Duration(milliseconds: 120));
    } on Object {
      // The finder can disappear between polls while routes animate.
    }
  }

  Future<void> _waitForJob(String sourceId) async {
    await _waitUntil(
      description: 'job queued for $sourceId',
      timeout: const Duration(seconds: 20),
      poll: () async => (await _jobsForSource(sourceId)).isNotEmpty,
    );
  }

  Future<AiProcessingJobEntity> _waitForCompletedJob(String sourceId) async {
    AiProcessingJobEntity? latest;
    await _waitUntil(
      description: 'job completed for $sourceId',
      timeout: const Duration(minutes: 8),
      poll: () async {
        await locator<AiJobQueueRunner>().drain();
        final jobs = await _jobsForSource(sourceId);
        if (jobs.isEmpty) {
          return false;
        }
        latest = jobs.last;
        if (latest!.status == AiJobStatus.failed) {
          throw StateError('AI job failed: ${latest!.errorMessage}');
        }
        return latest!.status == AiJobStatus.completed;
      },
    );

    return latest!;
  }

  Future<TagCardEntity> _loadCreatedSuggestionCard(String sourceId) async {
    final cards = await locator<CardRepository>().getCards(
      CardListQuery(
        viewMode: TodayViewMode.all,
        filter: TodayCardFilter.all,
        now: DateTime.now(),
      ),
    );
    final matches = cards
        .where((card) => card.sourceIds.contains(sourceId))
        .toList(growable: false);
    expect(matches, isNotEmpty);

    return matches.firstWhere(
      (card) => card.cardType == TagCardType.suggestion,
    );
  }

  Future<List<AiProcessingJobEntity>> _jobsForSource(String sourceId) async {
    final database = locator<TagDatabase>();
    final rows =
        await (database.select(database.aiProcessingJobs)
              ..where((job) => job.sourceId.equals(sourceId))
              ..orderBy([(job) => OrderingTerm.asc(job.queuedAt)]))
            .get();

    return rows
        .map(
          (row) => AiProcessingJobEntity(
            id: row.id,
            jobType: AiJobType.fromStorageValue(row.jobType),
            status: AiJobStatus.fromStorageValue(row.status),
            sourceId: row.sourceId,
            cardId: row.cardId,
            spaceId: row.spaceId,
            chatSessionId: row.chatSessionId,
            priority: row.priority,
            attemptCount: row.attemptCount,
            maxAttempts: row.maxAttempts,
            inputJson: row.inputJson,
            outputJson: row.outputJson,
            errorMessage: row.errorMessage,
            modelSlug: row.modelSlug,
            queuedAt: row.queuedAt,
            startedAt: row.startedAt,
            completedAt: row.completedAt,
            updatedAt: row.updatedAt,
          ),
        )
        .toList(growable: false);
  }

  Future<ChatSessionEntity?> _latestPlanningSession() async {
    final database = locator<TagDatabase>();
    final rows =
        await (database.select(database.chatSessions)
              ..where((session) => session.purpose.equals('plan_suggestion'))
              ..orderBy([(session) => OrderingTerm.desc(session.createdAt)])
              ..limit(1))
            .get();
    if (rows.isEmpty) {
      return null;
    }

    final row = rows.single;
    return ChatSessionEntity(
      id: row.id,
      title: row.title,
      purpose: ChatPurpose.fromStorageValue(row.purpose),
      linkedCardId: row.linkedCardId,
      linkedSpaceId: row.linkedSpaceId,
      linkedGoalPlanId: row.linkedGoalPlanId,
      status: ChatStatus.fromStorageValue(row.status),
      pendingConfirmationJson: row.pendingConfirmationJson,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      archivedAt: row.archivedAt,
    );
  }

  Future<void> _waitUntil({
    required String description,
    required Duration timeout,
    required Future<bool> Function() poll,
  }) async {
    final deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      if (await poll()) {
        return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 300));
    }
    fail('Timed out waiting for $description.');
  }

  LocalAiModelInfo? _modelBySlug(List<LocalAiModelInfo> models, String slug) {
    for (final model in models) {
      if (model.slug == slug) {
        return model;
      }
    }
    return null;
  }
}

class _LiveUiEvidence {
  _LiveUiEvidence(this._binding);

  final IntegrationTestWidgetsFlutterBinding _binding;
  final List<String> screenshotNames = [];
  Directory? _directory;

  Future<void> capture(String name) async {
    await _ensureDirectory();
    final bytes = await _binding.takeScreenshot(name);
    final file = File(p.join(_directory!.path, '$name.png'));
    await file.writeAsBytes(bytes, flush: true);
    screenshotNames.add(file.path);
    debugPrint('TAG_LIVE_UI_E2E_SCREENSHOT ${file.path}');
  }

  Future<void> writeManifest(Map<String, Object?> result) async {
    _binding.reportData ??= <String, dynamic>{};
    _binding.reportData!['live_ui_e2e_result'] = result;
    await _ensureDirectory();
    final file = File(p.join(_directory!.path, 'manifest.json'));
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(result),
      flush: true,
    );
    debugPrint('TAG_LIVE_UI_E2E_MANIFEST ${file.path}');
  }

  Future<void> _ensureDirectory() async {
    if (_directory != null) {
      return;
    }

    final documents = await getApplicationDocumentsDirectory();
    _directory = Directory(p.join(documents.path, 'live_ui_e2e_screenshots'));
    await _directory!.create(recursive: true);
  }
}

class _LiveSeed {
  const _LiveSeed({
    required this.runId,
    required this.source,
    required this.card,
    required this.primaryModelSlug,
    required this.embeddingModelSlug,
    required this.modelProgress,
  });

  final String runId;
  final SourceItemEntity source;
  final TagCardEntity card;
  final String primaryModelSlug;
  final String embeddingModelSlug;
  final List<String> modelProgress;
}
