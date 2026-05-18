import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:tag/app.dart';
import 'package:tag/core/DI/di.dart';
import 'package:tag/core/ai/cactus/cactus_model_registry.dart';
import 'package:tag/core/config/app_config.dart';
import 'package:tag/core/local_storage/database/tag_database.dart';
import 'package:tag/core/navigation/route_constants.dart';
import 'package:tag/core/notifications/local_notification_permission_service.dart';
import 'package:tag/core/notifications/local_notification_service.dart';
import 'package:tag/features/ai_processing/domain/entities/ai_processing_job_entity.dart';
import 'package:tag/features/ai_processing/domain/services/ai_job_queue_runner.dart';
import 'package:tag/features/cards/domain/entities/card_entities.dart';
import 'package:tag/features/cards/domain/entities/card_query.dart';
import 'package:tag/features/cards/domain/repositories/card_repository.dart';
import 'package:tag/features/cards/domain/use_cases/card_policy.dart';
import 'package:tag/features/cards/domain/use_cases/handle_notification_action.dart';
import 'package:tag/features/model_setup/domain/repositories/model_setup_repository.dart';
import 'package:tag/features/source_ingestion/domain/entities/source_item_entity.dart';
import 'package:tag/features/source_ingestion/domain/use_cases/ingest_shared_source.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets(
    'GitHub demo: fresh onboarding, real screenshots, chat, completion, notification',
    (tester) async {
      await binding.convertFlutterSurfaceToImage();

      await _launchDemoApp();
      final evidence = _DemoEvidence(binding);
      final harness = _DemoHarness(tester: tester, evidence: evidence);

      await harness.waitForAppEntry();
      await harness.completeFreshOnboardingUntilShare();
      await harness.waitForSeededDemoAssets();
      await harness.finishFreshOnboarding();
      await harness.waitForToday();
      await evidence.capture('01_today_model_setup_progress');
      await harness.requestNotificationPermissionForDemo();
      await evidence.capture('01_notifications_permission_enabled');

      final modelResult = await harness.waitForCompactModelsPrepared();
      await evidence.capture('02_today_after_local_model_setup');

      final importedSources = await harness.importDemoScreenshots();
      await evidence.capture('04_today_sources_imported_processing');

      final cards = await harness.processImportedSources(importedSources);
      await harness.waitForAnyCard(cards);
      await evidence.capture('05_today_cards_created_from_real_images');
      await harness.showSpacesView();
      await evidence.capture('05_spaces_view_from_sources');
      await harness.showAllCardsView();
      await harness.showFilteredView(TodayCardFilter.urgent);
      await evidence.capture('05_filtered_urgent_cards');
      await harness.clearFilter();
      await harness.showAllCardsView();

      final sourceCard = await harness.openFirstSourcePreview(cards);
      await evidence.capture('06_source_evidence_preview');
      await harness.goToToday();
      await harness.waitForToday();

      await harness.openChat();
      await evidence.capture('07_chat_empty_state');
      await harness.askSavedContextQuestion(importedSources);
      await evidence.capture('08_chat_loading_state');
      final citationSourceId = await harness.waitForChatAnswerWithCitation(
        importedSources,
      );
      await evidence.capture('09_chat_answer_with_citation');

      await harness.openCitation(citationSourceId);
      await evidence.capture('10_chat_citation_source_preview');
      await harness.goToToday();
      await harness.waitForToday();
      await harness.showAllCardsView();
      await evidence.capture('10_today_all_cards_ready_for_actions');

      final notificationCard = await harness.scheduleShortDemoNotification(
        cards,
      );
      await evidence.capture('11_notification_scheduled_in_app');
      await harness.waitForScheduledNotificationToFire();
      await evidence.capture('12_after_scheduled_notification_fire');

      final snoozedCard = await harness.snoozeOneActionableCard(
        cards,
        preferredCardId: notificationCard.id,
      );
      await evidence.capture('13_today_card_snoozed');

      final completedCard = await harness.completeOneActionableCard(
        cards,
        avoidCardIds: {snoozedCard.id},
      );
      await evidence.capture('14_today_card_completed');

      final discardedCard = await harness.discardOneActionableCard(
        cards,
        avoidCardIds: {snoozedCard.id, completedCard.id},
      );
      await evidence.capture('15_today_card_discarded');

      final result = await harness.buildResult(
        modelResult: modelResult,
        importedSources: importedSources,
        cards: await harness.currentCards(),
        sourcePreviewCard: sourceCard,
        citationSourceId: citationSourceId,
        snoozedCard: snoozedCard,
        discardedCard: discardedCard,
        completedCard: completedCard,
        notificationCard: notificationCard,
      );
      await evidence.writeManifest(result);
      await Future<void>.delayed(const Duration(seconds: 4));

      debugPrint(
        'TAG_GITHUB_DEMO_RESULT ${jsonEncode(result)}',
        wrapWidth: 4096,
      );
    },
    timeout: const Timeout(Duration(minutes: 60)),
  );
}

Future<void> _launchDemoApp() async {
  await _resetDemoStatePreservingSeededAssets();
  setUpAppLocator(
    appConfig: AppConfig(
      autoDownloadRequiredModels: true,
      qualityEmbeddingMinAvailableBytes: 1 << 60,
      qualityEmbeddingMinTotalBytes: 1 << 60,
    ),
  );
  await locator<LocalNotificationService>().initialize(
    onAction: locator<HandleNotificationAction>(),
  );

  runApp(const App());
}

Future<void> _resetDemoStatePreservingSeededAssets() async {
  final documents = await getApplicationDocumentsDirectory();
  for (final fileName in const [
    'tag.sqlite',
    'tag.sqlite-shm',
    'tag.sqlite-wal',
  ]) {
    final file = File(p.join(documents.path, fileName));
    if (await file.exists()) {
      await file.delete();
    }
  }

  for (final directoryName in const [
    'github_demo_e2e',
    'source_images',
    'source_text',
    'source_urls',
  ]) {
    final directory = Directory(p.join(documents.path, directoryName));
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  }
}

class _DemoHarness {
  _DemoHarness({required this.tester, required this.evidence});

  final WidgetTester tester;
  final _DemoEvidence evidence;

  Future<void> waitForAppEntry() {
    return _pumpUntil(
      description: 'app entry screen',
      timeout: const Duration(minutes: 2),
      condition: () =>
          find
              .byKey(const ValueKey('onboarding_start_button'))
              .evaluate()
              .isNotEmpty ||
          find.byKey(const ValueKey('today_fab_toggle')).evaluate().isNotEmpty,
    );
  }

  Future<void> completeFreshOnboardingUntilShare() async {
    await evidence.capture('00_onboarding_welcome');
    await tapKey('onboarding_start_button');
    await evidence.capture('00_onboarding_nickname');

    await tester.enterText(
      find.byKey(const ValueKey('nickname_field')),
      'Demo',
    );
    await tapKey('nickname_continue_button');
    await evidence.capture('00_onboarding_avatar');

    await tapText('Use selected');
    await evidence.capture('00_onboarding_local_first');

    await tapKey('local_models_start_sooner_button');
    await evidence.capture('00_onboarding_notifications');

    await tapKey('skip_notifications_button');
    await evidence.capture('00_onboarding_share');
  }

  Future<void> finishFreshOnboarding() async {
    await tapKey(
      'finish_onboarding_button',
      timeout: const Duration(minutes: 3),
    );
    await waitForToday();
  }

  Future<void> requestNotificationPermissionForDemo() async {
    debugPrint('TAG_GITHUB_DEMO_PERMISSION_PROMPT requesting');
    final permission = await locator<LocalNotificationService>()
        .requestPermission();
    debugPrint('TAG_GITHUB_DEMO_PERMISSION_RESULT ${permission.storageValue}');
    expect(permission, NotificationPermissionState.granted);
  }

  Future<Map<String, Object?>> waitForCompactModelsPrepared() async {
    await _waitUntil(
      description: 'automatic local model setup complete',
      timeout: const Duration(minutes: 10),
      poll: () async {
        final repository = locator<ModelSetupRepository>();
        final primarySlug = await repository.loadSelectedPrimaryModelSlug();
        final embeddingSlug = await repository.loadSelectedEmbeddingModelSlug();
        final documents = await getApplicationDocumentsDirectory();
        final primaryDir = Directory(
          p.join(documents.path, 'models', primarySlug),
        );
        final embeddingDir = Directory(
          p.join(documents.path, 'models', embeddingSlug),
        );
        return primarySlug == CactusModelRegistry.compactVisionModelSlug &&
            embeddingSlug == CactusModelRegistry.compactEmbeddingModelSlug &&
            await primaryDir.exists() &&
            await embeddingDir.exists();
      },
    );
    final repository = locator<ModelSetupRepository>();
    final primarySlug = await repository.loadSelectedPrimaryModelSlug();
    final embeddingSlug = await repository.loadSelectedEmbeddingModelSlug();
    expect(primarySlug, CactusModelRegistry.compactVisionModelSlug);
    expect(embeddingSlug, CactusModelRegistry.compactEmbeddingModelSlug);

    final documents = await getApplicationDocumentsDirectory();
    final highQualityDir = Directory(
      p.join(documents.path, 'models', CactusModelRegistry.gemma4E2BModelSlug),
    );
    expect(
      await highQualityDir.exists(),
      isFalse,
      reason: 'The demo simulator must not contain the high-quality model.',
    );

    return {
      'primary_model': primarySlug,
      'embedding_model': embeddingSlug,
      'high_quality_model_present': false,
    };
  }

  Future<void> waitForSeededDemoAssets() {
    return _waitUntil(
      description: 'low-quality demo models and image fixtures seeded',
      timeout: const Duration(minutes: 10),
      poll: () async {
        final documents = await getApplicationDocumentsDirectory();
        final modelRoot = Directory(p.join(documents.path, 'models'));
        final compactVision = Directory(
          p.join(modelRoot.path, CactusModelRegistry.compactVisionModelSlug),
        );
        final compactEmbedding = Directory(
          p.join(modelRoot.path, CactusModelRegistry.compactEmbeddingModelSlug),
        );
        final highQuality = Directory(
          p.join(modelRoot.path, CactusModelRegistry.gemma4E2BModelSlug),
        );
        final fixtureDirectory = Directory(
          p.join(documents.path, 'demo_fixtures'),
        );
        final fixtureFiles = [
          for (final fixture in _demoFixtures)
            File(p.join(fixtureDirectory.path, fixture.fileName)),
        ];

        final fixtureExists = await Future.wait(
          fixtureFiles.map((file) => file.exists()),
        );

        return await compactVision.exists() &&
            await compactEmbedding.exists() &&
            !await highQuality.exists() &&
            await fixtureDirectory.exists() &&
            fixtureExists.every((exists) => exists);
      },
    );
  }

  Future<List<SourceItemEntity>> importDemoScreenshots() async {
    final documents = await getApplicationDocumentsDirectory();
    final fixtureDirectory = Directory(p.join(documents.path, 'demo_fixtures'));
    final imported = <SourceItemEntity>[];

    for (final fixture in _demoFixtures) {
      final file = File(p.join(fixtureDirectory.path, fixture.fileName));
      expect(await file.exists(), isTrue, reason: '${file.path} must exist');
      final source = await locator<IngestSharedSource>()(
        IngestSharedSourceParams(
          originalUri: 'tag-demo://${fixture.fileName}',
          sourceType: SourceItemType.image,
          filePath: file.path,
          displayName: fixture.displayName,
          receivedAt: DateTime.now().toUtc().millisecondsSinceEpoch,
          sourceApplication: fixture.sourceApplication,
          uti: 'public.jpeg',
        ),
      );
      imported.add(source);
    }

    locator<AiJobQueueRunner>().requestProcessing();
    return imported;
  }

  Future<List<TagCardEntity>> processImportedSources(
    List<SourceItemEntity> sources,
  ) async {
    for (final source in sources) {
      await _waitForJob(source.id);
    }

    await locator<AiJobQueueRunner>().drain();
    for (final source in sources) {
      await _waitForCompletedJob(source.id);
    }

    await _waitUntil(
      description: 'cards created from imported screenshots',
      timeout: const Duration(minutes: 2),
      poll: () async => (await currentCards()).isNotEmpty,
    );

    final cards = await currentCards();
    expect(cards, isNotEmpty);
    return cards;
  }

  Future<List<TagCardEntity>> currentCards() {
    return locator<CardRepository>().getCards(
      CardListQuery(
        viewMode: TodayViewMode.all,
        filter: TodayCardFilter.all,
        now: DateTime.now(),
      ),
    );
  }

  Future<void> waitForAnyCard(List<TagCardEntity> cards) async {
    await waitForFinder(
      find.byKey(ValueKey('today_card_${cards.first.id}')),
      description: 'first created card',
      timeout: const Duration(minutes: 1),
      scroll: true,
    );
  }

  Future<TagCardEntity> openFirstSourcePreview(
    List<TagCardEntity> cards,
  ) async {
    final card = cards.firstWhere(
      (candidate) => candidate.sourceIds.isNotEmpty,
      orElse: () => cards.first,
    );
    await tester.ensureVisible(find.byKey(ValueKey('today_card_${card.id}')));
    await tester.tap(
      find.byKey(ValueKey('today_card_${card.id}')).hitTestable(),
    );
    await tester.pump(const Duration(milliseconds: 500));
    await waitForText(
      'Source evidence',
      timeout: const Duration(minutes: 1),
      scroll: true,
    );
    return card;
  }

  Future<void> openChat() async {
    await waitForToday();
    await tapKey('today_fab_toggle');
    await tapKey('today_fab_ask_tag');
    await waitForFinder(
      find.byKey(const ValueKey('chat_composer_field')),
      description: 'chat composer',
      timeout: const Duration(minutes: 1),
    );
  }

  Future<void> askSavedContextQuestion(List<SourceItemEntity> sources) async {
    await tester.enterText(
      find.byKey(const ValueKey('chat_composer_field')),
      'What did I save about chess, the Medium article, LLM optimization, and hiring?',
    );
    await tester.pump(const Duration(milliseconds: 300));
    await tapKey('chat_send_button');
    await tryWaitForFinder(
      find.byKey(const ValueKey('chat_thinking_bubble')),
      description: 'chat loading state',
      timeout: const Duration(seconds: 8),
      scroll: true,
    );
  }

  Future<String> waitForChatAnswerWithCitation(
    List<SourceItemEntity> sources,
  ) async {
    String? citationSourceId;
    await _pumpUntil(
      description: 'chat answer with source citation',
      timeout: const Duration(minutes: 10),
      scroll: true,
      condition: () {
        for (final source in sources) {
          final finder = find.byKey(ValueKey('chat_citation_${source.id}'));
          if (finder.evaluate().isNotEmpty ||
              finder.hitTestable().evaluate().isNotEmpty) {
            citationSourceId = source.id;
            return true;
          }
        }
        return false;
      },
    );
    return citationSourceId!;
  }

  Future<void> openCitation(String sourceId) async {
    final finder = find.byKey(ValueKey('chat_citation_$sourceId'));
    await tester.ensureVisible(finder);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(finder.hitTestable());
    await waitForText('Source', timeout: const Duration(minutes: 1));
  }

  Future<void> showAllCardsView() async {
    await tapKey('today_view_switch');
    final allOption = find.text('All').last;
    await waitForFinder(
      allOption,
      description: 'All cards view option',
      scroll: true,
    );
    await tester.tap(allOption.hitTestable());
    await tester.pump(const Duration(milliseconds: 600));
  }

  Future<void> showSpacesView() async {
    await tapKey('today_view_switch');
    final spacesOption = find.text('Spaces').last;
    await waitForFinder(
      spacesOption,
      description: 'Spaces view option',
      scroll: true,
    );
    await tester.tap(spacesOption.hitTestable());
    await tester.pump(const Duration(milliseconds: 800));
    await waitForText(
      'Source-backed contexts, not folders',
      timeout: const Duration(seconds: 30),
    );
  }

  Future<void> showFilteredView(TodayCardFilter filter) async {
    await tapKey('today_filter_button');
    final filterOption = find.text(filter.label).last;
    await waitForFinder(
      filterOption,
      description: '${filter.label} filter option',
      scroll: true,
    );
    await tester.tap(filterOption.hitTestable());
    await tester.pump(const Duration(milliseconds: 800));
    await waitForText(
      'Filter: ${filter.label}',
      timeout: const Duration(seconds: 30),
      scroll: true,
    );
  }

  Future<void> clearFilter() async {
    await tapKey('today_filter_button');
    final allOption = find.text('All').last;
    await waitForFinder(
      allOption,
      description: 'All filter option',
      scroll: true,
    );
    await tester.tap(allOption.hitTestable());
    await tester.pump(const Duration(milliseconds: 800));
  }

  Future<TagCardEntity> snoozeOneActionableCard(
    List<TagCardEntity> cards, {
    String? preferredCardId,
    Set<String> avoidCardIds = const {},
  }) async {
    final card = preferredCardId == null
        ? await _findActionableCard(
            TagCardAction.snooze,
            avoidCardIds: avoidCardIds,
          )
        : await _requireActionableCardById(
            preferredCardId,
            TagCardAction.snooze,
          );

    await waitForFinder(
      find.byKey(ValueKey('today_card_${card.id}')),
      description: 'card to snooze',
      timeout: const Duration(minutes: 1),
      scroll: true,
    );
    await tapKey('tag_card_expand_${card.id}');
    await tapKey(
      'tag_card_action_${card.id}_${TagCardAction.snooze.storageValue}',
    );
    await waitForText('Snooze', timeout: const Duration(seconds: 30));
    await tapText('In 30 minutes');
    await waitForText('Snoozed', timeout: const Duration(seconds: 30));

    return (await locator<CardRepository>().getCardById(card.id)) ?? card;
  }

  Future<TagCardEntity> _requireActionableCardById(
    String cardId,
    TagCardAction action,
  ) async {
    final card = await locator<CardRepository>().getCardById(cardId);
    if (card == null ||
        card.status != TagCardStatus.active ||
        !CardPolicy.availableActionsFor(card).contains(action)) {
      fail('Card $cardId is not active for ${action.storageValue}.');
    }
    return card;
  }

  Future<TagCardEntity> discardOneActionableCard(
    List<TagCardEntity> cards, {
    Set<String> avoidCardIds = const {},
  }) async {
    final card = await _findActionableCard(
      TagCardAction.cancel,
      fallbackAction: TagCardAction.dismiss,
      avoidCardIds: avoidCardIds,
    );
    final action =
        CardPolicy.availableActionsFor(card).contains(TagCardAction.cancel)
        ? TagCardAction.cancel
        : TagCardAction.dismiss;

    await waitForFinder(
      find.byKey(ValueKey('today_card_${card.id}')),
      description: 'card to discard',
      timeout: const Duration(minutes: 1),
      scroll: true,
    );
    await tapKey('tag_card_expand_${card.id}');
    await tapKey('tag_card_action_${card.id}_${action.storageValue}');
    await waitForText(
      action == TagCardAction.cancel ? 'Cancelled' : 'Dismissed',
      timeout: const Duration(seconds: 30),
    );

    return (await locator<CardRepository>().getCardById(card.id)) ?? card;
  }

  Future<TagCardEntity> completeOneActionableCard(
    List<TagCardEntity> cards, {
    Set<String> avoidCardIds = const {},
  }) async {
    final card = await _findActionableCard(
      TagCardAction.complete,
      avoidCardIds: avoidCardIds,
    );

    await waitForFinder(
      find.byKey(ValueKey('today_card_${card.id}')),
      description: 'card to complete',
      timeout: const Duration(minutes: 1),
      scroll: true,
    );
    await tapKey('tag_card_expand_${card.id}');
    await tapKey(
      'tag_card_action_${card.id}_${TagCardAction.complete.storageValue}',
    );
    await waitForText('Completed', timeout: const Duration(seconds: 30));

    return (await locator<CardRepository>().getCardById(card.id)) ?? card;
  }

  Future<TagCardEntity> _findActionableCard(
    TagCardAction action, {
    TagCardAction? fallbackAction,
    Set<String> avoidCardIds = const {},
  }) async {
    final freshCards = await currentCards();
    final primary = freshCards.where(
      (candidate) =>
          !avoidCardIds.contains(candidate.id) &&
          candidate.status == TagCardStatus.active &&
          CardPolicy.availableActionsFor(candidate).contains(action),
    );

    if (primary.isNotEmpty) {
      return primary.first;
    }

    if (fallbackAction != null) {
      final fallback = freshCards.where(
        (candidate) =>
            !avoidCardIds.contains(candidate.id) &&
            candidate.status == TagCardStatus.active &&
            CardPolicy.availableActionsFor(candidate).contains(fallbackAction),
      );
      if (fallback.isNotEmpty) {
        return fallback.first;
      }
    }

    fail(
      'No active card found for ${action.storageValue}'
      '${fallbackAction == null ? '' : ' or ${fallbackAction.storageValue}'}.',
    );
  }

  Future<TagCardEntity> scheduleShortDemoNotification(
    List<TagCardEntity> cards, {
    Set<String> avoidCardIds = const {},
  }) async {
    final freshCards = await currentCards();
    final candidate = freshCards.firstWhere(
      (card) =>
          !avoidCardIds.contains(card.id) &&
          card.status == TagCardStatus.active &&
          (card.cardType == TagCardType.urgent ||
              card.cardType == TagCardType.goal),
      orElse: () => freshCards.firstWhere(
        (card) =>
            !avoidCardIds.contains(card.id) &&
            card.status == TagCardStatus.active,
        orElse: () => freshCards.first,
      ),
    );
    final notificationTime = DateTime.now()
        .toUtc()
        .add(const Duration(seconds: 12))
        .millisecondsSinceEpoch;
    final snapshot = LocalNotificationCardSnapshot(
      id: candidate.id,
      cardType: candidate.cardType == TagCardType.suggestion
          ? TagCardType.urgent.storageValue
          : candidate.cardType.storageValue,
      status: TagCardStatus.active.storageValue,
      title: candidate.title,
      reason: candidate.reason,
      spaceName: candidate.space.name,
      sourceSummary: candidate.sourceSummary,
      notificationEnabled: true,
      nextActiveDeadline: notificationTime,
    );

    final request = await locator<LocalNotificationService>()
        .scheduleCardNotification(snapshot);
    expect(request, isNotNull);
    debugPrint(
      'TAG_GITHUB_DEMO_NOTIFICATION ${jsonEncode({'card_id': candidate.id, 'title': request?.title, 'scheduled_for': request?.scheduledFor, 'status': request?.status})}',
    );
    return candidate;
  }

  Future<void> waitForScheduledNotificationToFire() async {
    await tester.pump(const Duration(seconds: 16));
  }

  Future<Map<String, Object?>> buildResult({
    required Map<String, Object?> modelResult,
    required List<SourceItemEntity> importedSources,
    required List<TagCardEntity> cards,
    required TagCardEntity sourcePreviewCard,
    required String citationSourceId,
    required TagCardEntity snoozedCard,
    required TagCardEntity discardedCard,
    required TagCardEntity completedCard,
    required TagCardEntity notificationCard,
  }) async {
    final database = locator<TagDatabase>();
    final notificationRows = await database
        .select(database.notificationRequests)
        .get();
    final ragRows = await database.select(database.ragIndexRecords).get();
    return {
      'ok': true,
      'captured_at': DateTime.now().toUtc().toIso8601String(),
      'models': modelResult,
      'sources': importedSources
          .map(
            (source) => {
              'id': source.id,
              'summary': source.sourceSummary,
              'state': source.processingState.storageValue,
            },
          )
          .toList(growable: false),
      'cards': cards
          .map(
            (card) => {
              'id': card.id,
              'title': card.title,
              'type': card.cardType.storageValue,
              'status': card.status.storageValue,
              'space': card.space.name,
              'source_ids': card.sourceIds,
            },
          )
          .toList(growable: false),
      'source_preview_card_id': sourcePreviewCard.id,
      'citation_source_id': citationSourceId,
      'snoozed_card_id': snoozedCard.id,
      'discarded_card_id': discardedCard.id,
      'completed_card_id': completedCard.id,
      'notification_card_id': notificationCard.id,
      'notification_request_count': notificationRows.length,
      'rag_record_count': ragRows.length,
      'screenshots': evidence.screenshotNames,
    };
  }

  Future<void> waitForToday() async {
    await waitForFinder(
      find.byKey(const ValueKey('today_fab_toggle')),
      description: 'Today screen',
      timeout: const Duration(minutes: 2),
    );
  }

  Future<void> tapKey(
    String key, {
    Duration timeout = const Duration(minutes: 1),
  }) async {
    final finder = find.byKey(ValueKey(key));
    await waitForFinder(
      finder,
      description: key,
      timeout: timeout,
      scroll: true,
    );
    await tester.ensureVisible(finder);
    await tester.pump(const Duration(milliseconds: 160));
    await tester.tap(finder.hitTestable());
    await tester.pump(const Duration(milliseconds: 500));
  }

  Future<void> tapText(String text) async {
    final finder = find.text(text);
    await waitForFinder(finder, description: text, scroll: true);
    await tester.ensureVisible(finder);
    await tester.pump(const Duration(milliseconds: 160));
    await tester.tap(finder.hitTestable());
    await tester.pump(const Duration(milliseconds: 500));
  }

  Future<void> tapTooltip(String tooltip) async {
    final finder = find.byTooltip(tooltip);
    try {
      await waitForFinder(
        finder,
        description: tooltip,
        timeout: const Duration(seconds: 8),
      );
      await tester.tap(finder.hitTestable());
    } on TestFailure {
      if (!tooltip.toLowerCase().contains('back')) {
        rethrow;
      }
      await _tryNavigatorPopOrToday();
    }
    await tester.pump(const Duration(milliseconds: 500));
  }

  Future<void> goToToday() async {
    await goToRoute(todayPath);
  }

  Future<void> goToRoute(String route) async {
    final navigator = find.byType(Navigator);
    expect(navigator.evaluate(), isNotEmpty);
    GoRouter.of(tester.element(navigator.last)).go(route);
    await tester.pump(const Duration(milliseconds: 500));
  }

  Future<void> _tryNavigatorPopOrToday() async {
    final navigator = find.byType(Navigator);
    if (navigator.evaluate().isNotEmpty) {
      final state = tester.state<NavigatorState>(navigator.last);
      final didPop = await state.maybePop();
      if (didPop) {
        return;
      }
    }
    await goToToday();
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
          ? finder.evaluate().isNotEmpty ||
                finder.hitTestable().evaluate().isNotEmpty
          : finder.evaluate().isNotEmpty,
    );
  }

  Future<bool> tryWaitForFinder(
    Finder finder, {
    required String description,
    Duration timeout = const Duration(minutes: 1),
    bool scroll = false,
  }) async {
    try {
      await waitForFinder(
        finder,
        description: description,
        timeout: timeout,
        scroll: scroll,
      );
      return true;
    } on TestFailure {
      return false;
    }
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
      timeout: const Duration(seconds: 30),
      poll: () async => (await _jobsForSource(sourceId)).isNotEmpty,
    );
  }

  Future<AiProcessingJobEntity> _waitForCompletedJob(String sourceId) async {
    AiProcessingJobEntity? latest;
    await _waitUntil(
      description: 'job completed for $sourceId',
      timeout: const Duration(minutes: 12),
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
}

class _DemoEvidence {
  _DemoEvidence(this._binding);

  final IntegrationTestWidgetsFlutterBinding _binding;
  final List<String> screenshotNames = [];
  Directory? _directory;

  Future<void> capture(String name) async {
    await _ensureDirectory();
    final bytes = await _binding.takeScreenshot(name);
    final file = File(p.join(_directory!.path, '$name.png'));
    await file.writeAsBytes(bytes, flush: true);
    screenshotNames.add(file.path);
    debugPrint('TAG_GITHUB_DEMO_SCREENSHOT ${file.path}');
  }

  Future<void> writeManifest(Map<String, Object?> result) async {
    _binding.reportData ??= <String, dynamic>{};
    _binding.reportData!['github_demo_result'] = result;
    await _ensureDirectory();
    final file = File(p.join(_directory!.path, 'manifest.json'));
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(result),
      flush: true,
    );
    debugPrint('TAG_GITHUB_DEMO_MANIFEST ${file.path}');
  }

  Future<void> _ensureDirectory() async {
    if (_directory != null) {
      return;
    }

    final documents = await getApplicationDocumentsDirectory();
    _directory = Directory(p.join(documents.path, 'github_demo_e2e'));
    await _directory!.create(recursive: true);
  }
}

class _DemoFixture {
  const _DemoFixture({
    required this.fileName,
    required this.displayName,
    required this.sourceApplication,
  });

  final String fileName;
  final String displayName;
  final String sourceApplication;
}

const _demoFixtures = [
  _DemoFixture(
    fileName: 'chess_streak_reminder.jpeg',
    displayName: 'Chess streak reminder',
    sourceApplication: 'Gmail',
  ),
  _DemoFixture(
    fileName: 'medium_article_reminder.jpeg',
    displayName: 'Medium article reminder',
    sourceApplication: 'Gmail',
  ),
  _DemoFixture(
    fileName: 'llm_optimization2.jpeg',
    displayName: 'LLM internals resource',
    sourceApplication: 'X',
  ),
  _DemoFixture(
    fileName: 'llm_optimization3.jpeg',
    displayName: 'LLM optimization resource',
    sourceApplication: 'X',
  ),
  _DemoFixture(
    fileName: 'hiring.jpeg',
    displayName: 'Hiring post',
    sourceApplication: 'X',
  ),
  _DemoFixture(
    fileName: 'uk_company_creation_info.jpeg',
    displayName: 'UK founder starter pack',
    sourceApplication: 'X',
  ),
];
