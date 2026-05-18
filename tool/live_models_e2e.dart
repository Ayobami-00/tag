import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter/material.dart';
import 'package:tag/core/DI/di.dart';
import 'package:tag/core/ai/cactus/cactus_model_service.dart';
import 'package:tag/core/ai/rag/local_rag_service.dart';
import 'package:tag/core/local_storage/database/tag_database.dart';
import 'package:tag/core/notifications/local_notification_service.dart';
import 'package:tag/features/ai_processing/domain/entities/ai_processing_job_entity.dart';
import 'package:tag/features/ai_processing/domain/services/ai_job_queue_runner.dart';
import 'package:tag/features/cards/domain/entities/card_entities.dart';
import 'package:tag/features/cards/domain/entities/card_query.dart';
import 'package:tag/features/cards/domain/repositories/card_repository.dart';
import 'package:tag/features/chat/domain/entities/chat_entities.dart';
import 'package:tag/features/chat/domain/entities/guided_planning_entities.dart';
import 'package:tag/features/chat/domain/repositories/chat_repository.dart';
import 'package:tag/features/chat/domain/use_cases/start_plan_this_chat.dart';
import 'package:tag/features/chat/presentation/logic/chat_cubit.dart';
import 'package:tag/features/model_setup/domain/repositories/model_setup_repository.dart';
import 'package:tag/features/model_setup/domain/use_cases/prepare_required_local_models.dart';
import 'package:tag/features/source_ingestion/domain/entities/source_item_entity.dart';
import 'package:tag/features/source_ingestion/domain/repositories/source_repository.dart';
import 'package:tag/features/source_ingestion/domain/use_cases/create_text_source.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final status = ValueNotifier<String>('Preparing live E2E run...');
  runApp(_LiveE2eApp(status: status));

  unawaited(_runAndReport(status));
}

Future<void> _runAndReport(ValueNotifier<String> status) async {
  try {
    setUpAppLocator();
    final result = await _LiveModelsE2e(status).run();
    status.value = 'Live E2E passed.';
    debugPrint('TAG_LIVE_E2E_RESULT ${jsonEncode(result)}', wrapWidth: 4096);
  } on Object catch (error, stackTrace) {
    status.value = 'Live E2E failed: $error';
    final result = {
      'ok': false,
      'error': error.toString(),
      'stack_top': stackTrace.toString().split('\n').take(8).join('\n'),
    };
    debugPrint('TAG_LIVE_E2E_RESULT ${jsonEncode(result)}', wrapWidth: 4096);
  }
}

class _LiveModelsE2e {
  _LiveModelsE2e(this._status);

  final ValueNotifier<String> _status;

  Future<Map<String, Object?>> run() async {
    final runId = DateTime.now().toUtc().millisecondsSinceEpoch.toString();
    _setStatus('Setting up local-only services...');

    await locator<LocalNotificationService>().initialize();

    final modelSetup = locator<ModelSetupRepository>();
    final modelProgress = <String>[];
    _setStatus('Checking local Cactus models...');
    await locator<PrepareRequiredLocalModels>().withProgress(
      onProgress: (progress) {
        modelProgress.add(progress.statusMessage);
        _setStatus(progress.statusMessage);
      },
    );

    final primarySlug = await modelSetup.loadSelectedPrimaryModelSlug();
    final embeddingSlug = await modelSetup.loadSelectedEmbeddingModelSlug();
    final availableModels = await locator<CactusModelService>()
        .getAvailableModels();
    final primaryModel = _modelBySlug(availableModels, primarySlug);
    final embeddingModel = _modelBySlug(availableModels, embeddingSlug);
    _require(
      primaryModel?.isDownloaded == true,
      'Primary model $primarySlug is not downloaded.',
    );
    _require(
      embeddingModel?.isDownloaded == true,
      'Embedding model $embeddingSlug is not downloaded.',
    );

    final source = await _createAndProcessSource(runId);
    final card = await _loadCreatedSuggestionCard(source.id);
    final cardNotifications = await locator<LocalNotificationService>()
        .requestsForCard(card.id);
    _require(
      cardNotifications.isEmpty,
      'Suggestion card unexpectedly scheduled notifications.',
    );

    final ragEvidence = await _exerciseRag(source.id);
    final chatEvidence = await _exerciseSavedContextChat(source.id, runId);
    final planningEvidence = await _exerciseGuidedPlanning(card);

    final database = locator<TagDatabase>();
    final counts = await _databaseCounts(database);
    await database.close();

    return {
      'ok': true,
      'run_id': runId,
      'models': {
        'primary': {
          'slug': primarySlug,
          'downloaded': primaryModel?.isDownloaded,
          'initialized_after_run': _modelBySlug(
            await locator<CactusModelService>().getAvailableModels(),
            primarySlug,
          )?.isInitialized,
        },
        'embedding': {
          'slug': embeddingSlug,
          'downloaded': embeddingModel?.isDownloaded,
          'initialized_after_run': _modelBySlug(
            await locator<CactusModelService>().getAvailableModels(),
            embeddingSlug,
          )?.isInitialized,
        },
        'progress_tail': modelProgress.take(4).toList(growable: false),
      },
      'source': {
        'id': source.id,
        'state': source.processingState.storageValue,
        'has_extracted_text': source.extractedText?.trim().isNotEmpty == true,
      },
      'card': {
        'id': card.id,
        'type': card.cardType.storageValue,
        'status': card.status.storageValue,
        'space': card.space.name,
        'source_count': card.sourceIds.length,
        'notification_enabled': card.notificationEnabled,
      },
      'rag': ragEvidence,
      'chat': chatEvidence,
      'guided_planning': planningEvidence,
      'database_counts': counts,
    };
  }

  Future<SourceItemEntity> _createAndProcessSource(String runId) async {
    _setStatus('Creating a real manual text source...');
    final source = await locator<CreateTextSource>()(
      CreateTextSourceParams('''
TAG live E2E marker $runId.
Could we do a call this weekend to get feedback on the open-source human-in-the-loop prototype demo?
I saved this because I want Tag to keep the source evidence attached and turn it into a small plan.
'''),
    );

    _setStatus('Running the real AI queue...');
    await _waitForJob(source.id);
    await locator<AiJobQueueRunner>().drain();

    final completedJob = await _waitForCompletedJob(source.id);
    _require(
      completedJob.status == AiJobStatus.completed,
      'AI job did not complete.',
    );

    final processedSource = await locator<SourceRepository>().getSourceById(
      source.id,
    );
    _require(processedSource != null, 'Processed source is missing.');
    _require(
      processedSource!.processingState == SourceProcessingState.completed,
      'Source ended as ${processedSource.processingState.storageValue}.',
    );
    _require(
      processedSource.extractedText?.trim().isNotEmpty == true,
      'Source has no extracted text.',
    );

    return processedSource;
  }

  Future<TagCardEntity> _loadCreatedSuggestionCard(String sourceId) async {
    _setStatus('Checking source-backed card creation...');
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
    _require(matches.isNotEmpty, 'No Tag Card was created for $sourceId.');

    final suggestion = matches.firstWhere(
      (card) => card.cardType == TagCardType.suggestion,
      orElse: () => throw StateError(
        'Created card was not a Suggestion Card: '
        '${matches.map((card) => card.cardType.storageValue).join(', ')}.',
      ),
    );

    _require(suggestion.sourceIds.length == 1, 'Card source link is invalid.');
    _require(
      suggestion.space.id.trim().isNotEmpty,
      'Card does not belong to a primary Space.',
    );
    _require(
      !suggestion.notificationEnabled,
      'Suggestion Cards must not enable notifications.',
    );

    return suggestion;
  }

  Future<Map<String, Object?>> _exerciseRag(String sourceId) async {
    _setStatus('Searching local RAG with live embeddings...');
    final rag = locator<LocalRagService>();
    final status = await rag.getIndexStatus();
    final results = await rag.search(
      query: 'feedback call prototype weekend',
      topK: 3,
    );
    _require(results.isNotEmpty, 'RAG search returned no local context.');
    _require(
      results.any((result) => result.source.id == sourceId),
      'RAG search did not return the live E2E source.',
    );

    return {
      'index_name': status.indexName,
      'chunk_count': status.chunkCount,
      'hit_count': results.length,
      'matched_source': results.first.source.id,
    };
  }

  Future<Map<String, Object?>> _exerciseSavedContextChat(
    String sourceId,
    String runId,
  ) async {
    _setStatus('Asking saved-context chat with live models...');
    final chatCubit = locator<ChatCubit>();
    await chatCubit.open();
    await _waitForChatReady(chatCubit);
    await chatCubit.ask(
      'What did I save with TAG live E2E marker $runId about the feedback call?',
    );
    await _waitForChatReady(chatCubit);

    final session = chatCubit.state.session;
    _require(session != null, 'Chat session was not created.');
    final messages = await locator<ChatRepository>().loadMessages(session!.id);
    final assistantMessages = messages
        .where((message) => message.role == ChatMessageRole.assistant)
        .toList(growable: false);
    _require(assistantMessages.isNotEmpty, 'Chat produced no answer.');
    final answer = assistantMessages.last;
    _require(
      answer.sourceIds.contains(sourceId),
      'Chat answer did not cite the live E2E source.',
    );
    await chatCubit.close();

    return {
      'session_id': session.id,
      'assistant_message_id': answer.id,
      'cited_source_count': answer.sourceIds.length,
      'model_slug': answer.modelSlug,
    };
  }

  Future<Map<String, Object?>> _exerciseGuidedPlanning(
    TagCardEntity suggestion,
  ) async {
    _setStatus('Generating guided planning preview with live models...');
    final session = await locator<StartPlanThisChat>()(
      StartPlanThisChatParams(suggestionCard: suggestion),
    );
    final chatCubit = locator<ChatCubit>();
    await chatCubit.open(chatSessionId: session.id);
    await _waitForChatReady(chatCubit);
    await chatCubit.selectPlanStyle(PlanStyleChoice.weekend);
    await _waitForChatReady(chatCubit);
    await chatCubit.selectWeeklyTime(WeeklyTimeChoice.oneHour);
    await _waitForChatReady(chatCubit);

    final updatedSession = await locator<ChatRepository>().getSession(
      session.id,
    );
    _require(updatedSession != null, 'Planning chat session disappeared.');
    final pending = jsonDecode(updatedSession!.pendingConfirmationJson ?? '{}');
    _require(
      pending is Map && pending['requires_confirmation'] == true,
      'Guided planning did not create a confirmation-gated preview.',
    );
    final preview = pending['preview'];
    _require(preview is Map, 'Guided planning preview is missing.');
    final previewCards = preview['cards'];
    _require(
      previewCards is List && previewCards.isNotEmpty,
      'Guided planning preview has no cards.',
    );
    final citedSourceIds = previewCards
        .whereType<Map>()
        .expand((card) => (card['source_ids'] as List?) ?? const [])
        .map((sourceId) => sourceId.toString())
        .toSet();
    _require(
      citedSourceIds.contains(suggestion.sourceIds.single),
      'Guided planning preview did not cite source evidence.',
    );
    await chatCubit.close();

    return {
      'session_id': session.id,
      'pending_type': pending['type'],
      'requires_confirmation': pending['requires_confirmation'],
      'preview_card_count': previewCards.length,
      'cited_source_count': citedSourceIds.length,
    };
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

  Future<void> _waitForChatReady(ChatCubit cubit) async {
    await _waitUntil(
      description: 'chat ready',
      timeout: const Duration(minutes: 5),
      poll: () async {
        if (cubit.state.status == ChatLoadStatus.error) {
          throw StateError(cubit.state.errorMessage);
        }
        return cubit.state.status == ChatLoadStatus.ready;
      },
    );
  }

  Future<Map<String, int>> _databaseCounts(TagDatabase database) async {
    Future<int> countTable(String tableName) async {
      final row = await database
          .customSelect('select count(*) as row_count from $tableName')
          .getSingle();
      return row.read<int>('row_count');
    }

    return {
      'sources': await countTable('source_items'),
      'cards': await countTable('tag_cards'),
      'spaces': await countTable('spaces'),
      'jobs': await countTable('ai_processing_jobs'),
      'chunks': await countTable('source_text_chunks'),
      'rag_records': await countTable('rag_index_records'),
      'chat_sessions': await countTable('chat_sessions'),
      'chat_messages': await countTable('chat_messages'),
      'notifications': await countTable('notification_requests'),
    };
  }

  LocalAiModelInfo? _modelBySlug(List<LocalAiModelInfo> models, String slug) {
    for (final model in models) {
      if (model.slug == slug) {
        return model;
      }
    }
    return null;
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
    throw TimeoutException('Timed out waiting for $description.', timeout);
  }

  void _require(bool condition, String message) {
    if (!condition) {
      throw StateError(message);
    }
  }

  void _setStatus(String value) {
    _status.value = value;
    debugPrint('TAG_LIVE_E2E_STATUS $value');
  }
}

class _LiveE2eApp extends StatelessWidget {
  const _LiveE2eApp({required this.status});

  final ValueNotifier<String> status;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFFFAF7F2),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ValueListenableBuilder<String>(
              valueListenable: status,
              builder: (context, value, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tag Live E2E',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2C2721),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF5C534A),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
