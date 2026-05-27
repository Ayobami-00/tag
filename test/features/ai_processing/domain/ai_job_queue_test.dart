import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart' show Value, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:tag/core/local_storage/database/tag_database.dart';
import 'package:tag/core/local_storage/file_store/local_file_store_impl.dart';
import 'package:tag/core/use_cases/use_cases.dart';
import 'package:tag/features/ai_processing/data/data_sources/ai_job_local_data_source.dart';
import 'package:tag/features/ai_processing/data/processors/fake_ai_job_processor.dart';
import 'package:tag/features/ai_processing/data/repositories/ai_job_repository_impl.dart';
import 'package:tag/features/ai_processing/domain/entities/ai_processing_job_entity.dart';
import 'package:tag/features/ai_processing/domain/processors/ai_job_processor.dart';
import 'package:tag/features/ai_processing/domain/repositories/ai_job_repository.dart';
import 'package:tag/features/ai_processing/domain/services/ai_job_queue_runner.dart';
import 'package:tag/features/ai_processing/domain/services/local_ai_job_queue_runner.dart';
import 'package:tag/features/ai_processing/domain/use_cases/process_next_ai_job.dart';
import 'package:tag/features/ai_processing/domain/use_cases/retry_ai_job.dart';
import 'package:tag/features/source_ingestion/data/data_sources/source_local_data_source.dart';
import 'package:tag/features/source_ingestion/data/repositories/source_repository_impl.dart';
import 'package:tag/features/source_ingestion/domain/use_cases/create_text_source.dart';
import 'package:tag/features/source_ingestion/domain/use_cases/queue_source_processing.dart';
import 'package:tag/features/source_ingestion/domain/use_cases/store_source_file.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late TagDatabase database;
  late _Clock clock;
  late AiJobRepository aiJobRepository;

  setUp(() {
    database = TagDatabase.forTesting(NativeDatabase.memory());
    clock = _Clock();
    aiJobRepository = AiJobRepositoryImpl(
      localDataSource: DriftAiJobLocalDataSource(database),
      now: clock.now,
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('source ingestion queues an extract_source job', () async {
    final tempDirectory = await Directory.systemTemp.createTemp(
      'tag_ai_queue_source_',
    );
    addTearDown(() async {
      if (await tempDirectory.exists()) {
        await tempDirectory.delete(recursive: true);
      }
    });
    final runner = _RecordingRunner();
    final sourceRepository = SourceRepositoryImpl(
      localDataSource: DriftSourceLocalDataSource(database),
      now: clock.now,
    );
    final createTextSource = CreateTextSource(
      storeSourceFile: StoreSourceFile(
        LocalFileStoreImpl(
          appDocumentsDirectoryProvider: () async => tempDirectory,
        ),
      ),
      sourceRepository: sourceRepository,
      queueSourceProcessing: QueueSourceProcessing(
        aiJobRepository: aiJobRepository,
        aiJobQueueRunner: runner,
        aiJobIdFactory: () => 'job_source_text',
        processingKickoffDelay: Duration.zero,
      ),
      sourceIdFactory: () => 'src_text',
    );

    final source = await createTextSource(
      const CreateTextSourceParams('Please buy bread at 8pm'),
    );

    final job = await _waitForJob(aiJobRepository, 'job_source_text');
    expect(source.id, 'src_text');
    expect(job.jobType, AiJobType.extractSource);
    expect(job.status, AiJobStatus.queued);
    expect(job.sourceId, 'src_text');
    expect(job.inputJson, contains('"source_id":"src_text"'));
    await Future<void>.delayed(Duration.zero);
    expect(runner.requestCount, 1);
  });

  test(
    'source processing job input includes manual source description',
    () async {
      final now = clock.now().millisecondsSinceEpoch;
      await database
          .into(database.sourceItems)
          .insert(
            SourceItemsCompanion.insert(
              id: 'src_described_image',
              type: 'image',
              sourceSummary: const Value('Manual image'),
              createdAt: now,
              updatedAt: now,
            ),
          );
      final runner = _RecordingRunner();
      final queueSourceProcessing = QueueSourceProcessing(
        aiJobRepository: aiJobRepository,
        aiJobQueueRunner: runner,
        aiJobIdFactory: () => 'job_source_description',
        processingKickoffDelay: Duration.zero,
      );

      await queueSourceProcessing(
        const QueueSourceProcessingParams(
          'src_described_image',
          sourceDescription: '  Family chat grocery request  ',
        ),
      );

      final job = await _waitForJob(aiJobRepository, 'job_source_description');
      expect(job.sourceId, 'src_described_image');
      expect(job.inputJson, contains('"source_id":"src_described_image"'));
      expect(job.inputJson, contains('"pipeline":"source_ingestion"'));
      expect(
        job.inputJson,
        contains('"source_description":"Family chat grocery request"'),
      );
      expect(runner.requestCount, 1);
    },
  );

  test('queued job transitions to running and completed', () async {
    await createJob(aiJobRepository, 'job_complete');
    final processNextAiJob = processNextWith(
      aiJobRepository,
      FakeAiJobProcessor(delay: Duration.zero, now: clock.now),
    );

    final processed = await processNextAiJob(const NoParams());
    final completed = await aiJobRepository.getJobById('job_complete');

    expect(processed?.status, AiJobStatus.completed);
    expect(completed?.attemptCount, 1);
    expect(completed?.startedAt, isNotNull);
    expect(completed?.completedAt, isNotNull);
    expect(completed?.outputJson, contains('"processor":"fake"'));
    expect(completed?.errorMessage, isNull);
  });

  test('queued job transitions to running and failed', () async {
    await createJob(aiJobRepository, 'job_failed');
    final processor = FakeAiJobProcessor(delay: Duration.zero, now: clock.now)
      ..failNextJob();
    final processNextAiJob = processNextWith(aiJobRepository, processor);

    final processed = await processNextAiJob(const NoParams());
    final failed = await aiJobRepository.getJobById('job_failed');

    expect(processed?.status, AiJobStatus.failed);
    expect(failed?.attemptCount, 1);
    expect(failed?.startedAt, isNotNull);
    expect(failed?.completedAt, isNull);
    expect(failed?.errorMessage, contains('Fake processor failure'));
  });

  test(
    'model-readiness deferral leaves job queued without burning attempts',
    () async {
      await createJob(aiJobRepository, 'job_waiting_for_model');
      final processNextAiJob = processNextWith(
        aiJobRepository,
        const _DeferredAiJobProcessor(),
      );

      final processed = await processNextAiJob(const NoParams());
      final deferred = await aiJobRepository.getJobById(
        'job_waiting_for_model',
      );

      expect(processed, isNull);
      expect(deferred?.status, AiJobStatus.queued);
      expect(deferred?.attemptCount, 0);
      expect(deferred?.startedAt, isNull);
      expect(deferred?.completedAt, isNull);
      expect(deferred?.errorMessage, contains('Waiting for local model setup'));
    },
  );

  test('old model-readiness failures are recovered as queued work', () async {
    await createJob(aiJobRepository, 'job_old_model_failure');
    await aiJobRepository.startJob('job_old_model_failure');
    await aiJobRepository.failJob(
      id: 'job_old_model_failure',
      errorMessage:
          'Local model lfm2-vl-450m is not ready on this device. Open Model setup and download the local model before processing sources.',
    );

    final recovered = await aiJobRepository.getNextRunnableJob();

    expect(recovered?.id, 'job_old_model_failure');
    expect(recovered?.status, AiJobStatus.queued);
    expect(recovered?.attemptCount, 1);
  });

  test('old model-initialization readiness failures are recovered', () async {
    await createJob(aiJobRepository, 'job_old_init_failure');
    await aiJobRepository.startJob('job_old_init_failure');
    await aiJobRepository.failJob(
      id: 'job_old_init_failure',
      errorMessage:
          'Cactus model initialization failed for gemma-4-E2B-it. The model files are downloaded, but the bundled Cactus v1.14 native runtime could not initialize them.',
    );

    final recovered = await aiJobRepository.getNextRunnableJob();

    expect(recovered?.id, 'job_old_init_failure');
    expect(recovered?.status, AiJobStatus.queued);
    expect(recovered?.attemptCount, 1);
  });

  test('failed job can retry and complete on a later attempt', () async {
    await createJob(
      aiJobRepository,
      'job_retry',
      inputJson: '{"source_id":"src_test","force_failure":true}',
    );
    final processor = FakeAiJobProcessor(delay: Duration.zero, now: clock.now);
    final processNextAiJob = processNextWith(aiJobRepository, processor);
    await processNextAiJob(const NoParams());
    final runner = _RecordingRunner();
    final retryAiJob = RetryAiJob(
      aiJobRepository: aiJobRepository,
      aiJobQueueRunner: runner,
    );

    final retried = await retryAiJob(const RetryAiJobParams('job_retry'));
    final completed = await processNextAiJob(const NoParams());

    expect(retried.status, AiJobStatus.queued);
    expect(retried.attemptCount, 1);
    expect(runner.requestCount, 1);
    expect(completed?.status, AiJobStatus.completed);
    expect(completed?.attemptCount, 2);
    expect(completed?.errorMessage, isNull);
  });

  test('cancelled job does not run', () async {
    await createJob(aiJobRepository, 'job_cancelled');
    await aiJobRepository.cancelJob('job_cancelled');
    final processNextAiJob = processNextWith(
      aiJobRepository,
      FakeAiJobProcessor(delay: Duration.zero, now: clock.now),
    );

    final processed = await processNextAiJob(const NoParams());
    final cancelled = await aiJobRepository.getJobById('job_cancelled');

    expect(processed, isNull);
    expect(cancelled?.status, AiJobStatus.cancelled);
    expect(cancelled?.attemptCount, 0);
  });

  test('stale running job is recovered and retried', () async {
    await createJob(aiJobRepository, 'job_stale');
    final running = await aiJobRepository.startJob('job_stale');
    expect(running?.status, AiJobStatus.running);
    expect(running?.attemptCount, 1);

    clock.advance(const Duration(minutes: 6));
    final recovered = await aiJobRepository.getNextRunnableJob();

    expect(recovered?.id, 'job_stale');
    expect(recovered?.status, AiJobStatus.queued);
    expect(recovered?.attemptCount, 1);
    expect(recovered?.startedAt, isNull);
  });

  test('exhausted stale running job gets one recovery retry', () async {
    await createJob(aiJobRepository, 'job_exhausted_stale', maxAttempts: 1);
    final running = await aiJobRepository.startJob('job_exhausted_stale');
    expect(running?.status, AiJobStatus.running);
    expect(running?.attemptCount, 1);

    clock.advance(const Duration(minutes: 6));
    final recovered = await aiJobRepository.getNextRunnableJob();

    expect(recovered?.id, 'job_exhausted_stale');
    expect(recovered?.status, AiJobStatus.queued);
    expect(recovered?.attemptCount, 0);
    expect(recovered?.startedAt, isNull);
    expect(recovered?.errorMessage, contains('Recovered stale'));
  });

  test(
    'queue runner watchdog recovers stale running jobs while app is open',
    () async {
      final fastRepository = AiJobRepositoryImpl(
        localDataSource: DriftAiJobLocalDataSource(database),
        now: clock.now,
        staleRunningJobAge: const Duration(milliseconds: 50),
      );
      await createJob(fastRepository, 'job_watchdog');
      final running = await fastRepository.startJob('job_watchdog');
      expect(running?.status, AiJobStatus.running);

      clock.advance(const Duration(milliseconds: 60));
      final runner = LocalAiJobQueueRunner(
        processNextAiJob: processNextWith(
          fastRepository,
          FakeAiJobProcessor(delay: Duration.zero, now: clock.now),
        ),
        recoveryPollInterval: const Duration(milliseconds: 5),
      );
      addTearDown(runner.stop);

      runner.start();
      await Future<void>.delayed(const Duration(milliseconds: 40));
      await runner.drain();
      final completed = await fastRepository.getJobById('job_watchdog');

      expect(completed?.status, AiJobStatus.completed);
      expect(completed?.attemptCount, 2);
      expect(completed?.errorMessage, isNull);
    },
  );

  test('queued jobs can be loaded after repository restart', () async {
    final tempDirectory = await Directory.systemTemp.createTemp(
      'tag_ai_queue_restart_',
    );
    final databasePath = p.join(tempDirectory.path, 'tag.sqlite');
    addTearDown(() async {
      if (await tempDirectory.exists()) {
        await tempDirectory.delete(recursive: true);
      }
    });
    final firstDatabase = TagDatabase.forTesting(
      NativeDatabase(File(databasePath)),
    );
    final firstRepository = AiJobRepositoryImpl(
      localDataSource: DriftAiJobLocalDataSource(firstDatabase),
      now: clock.now,
    );

    await firstRepository.createJob(
      const CreateAiJobRequest(
        id: 'job_restart',
        jobType: AiJobType.extractSource,
        inputJson: '{"source_id":"src_restart"}',
      ),
    );
    await firstDatabase.close();

    final secondDatabase = TagDatabase.forTesting(
      NativeDatabase(File(databasePath)),
    );
    addTearDown(secondDatabase.close);
    final secondRepository = AiJobRepositoryImpl(
      localDataSource: DriftAiJobLocalDataSource(secondDatabase),
      now: clock.now,
    );

    final queued = await secondRepository.getNextRunnableJob();

    expect(queued?.id, 'job_restart');
    expect(queued?.status, AiJobStatus.queued);
    expect(queued?.attemptCount, 0);
  });
}

Future<AiProcessingJobEntity> createJob(
  AiJobRepository repository,
  String id, {
  String inputJson = '{"source_id":"src_test"}',
  int maxAttempts = 3,
}) {
  return repository.createJob(
    CreateAiJobRequest(
      id: id,
      jobType: AiJobType.extractSource,
      inputJson: inputJson,
      maxAttempts: maxAttempts,
    ),
  );
}

ProcessNextAiJob processNextWith(
  AiJobRepository repository,
  AiJobProcessor processor,
) {
  return ProcessNextAiJob(
    aiJobRepository: repository,
    aiJobProcessor: processor,
  );
}

class _DeferredAiJobProcessor implements AiJobProcessor {
  const _DeferredAiJobProcessor();

  @override
  Future<AiJobProcessingResult> process(AiProcessingJobEntity job) {
    throw const AiJobProcessingDeferredException(
      'Waiting for local model setup before processing this source.',
    );
  }
}

Future<AiProcessingJobEntity> _waitForJob(
  AiJobRepository repository,
  String id,
) async {
  final completer = Completer<AiProcessingJobEntity>();
  Timer? timeout;
  Timer? timer;

  Future<void> poll() async {
    final job = await repository.getJobById(id);
    if (job != null && !completer.isCompleted) {
      completer.complete(job);
      return;
    }
  }

  timer = Timer.periodic(
    const Duration(milliseconds: 10),
    (_) => unawaited(poll()),
  );
  timeout = Timer(const Duration(seconds: 1), () {
    if (!completer.isCompleted) {
      completer.completeError(StateError('Timed out waiting for $id.'));
    }
  });
  await poll();

  return completer.future.whenComplete(() {
    timeout?.cancel();
    timer?.cancel();
  });
}

class _Clock {
  DateTime _current = DateTime.utc(2026, 5, 10, 12);

  DateTime now() {
    final next = _current;
    _current = _current.add(const Duration(milliseconds: 1));
    return next;
  }

  void advance(Duration duration) {
    _current = _current.add(duration);
  }
}

class _RecordingRunner implements AiJobQueueRunner {
  int requestCount = 0;
  int stopCount = 0;

  @override
  bool get isProcessing => false;

  @override
  void start() {}

  @override
  void stop() {
    stopCount++;
  }

  @override
  void requestProcessing() {
    requestCount++;
  }

  @override
  Future<void> drain() async {}
}
