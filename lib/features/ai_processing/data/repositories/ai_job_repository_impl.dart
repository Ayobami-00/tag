import 'package:drift/drift.dart';
import 'package:tag/core/local_storage/database/tag_database.dart'
    as database_models;
import 'package:tag/features/ai_processing/data/data_sources/ai_job_local_data_source.dart';
import 'package:tag/features/ai_processing/domain/entities/ai_processing_job_entity.dart';
import 'package:tag/features/ai_processing/domain/repositories/ai_job_repository.dart';

class AiJobRepositoryImpl implements AiJobRepository {
  const AiJobRepositoryImpl({
    required AiJobLocalDataSource localDataSource,
    DateTime Function()? now,
    Duration staleRunningJobAge = const Duration(seconds: 90),
  }) : _localDataSource = localDataSource,
       _now = now ?? DateTime.now,
       _staleRunningJobAge = staleRunningJobAge;

  final AiJobLocalDataSource _localDataSource;
  final DateTime Function() _now;
  final Duration _staleRunningJobAge;

  @override
  Future<AiProcessingJobEntity> createJob(CreateAiJobRequest request) async {
    final timestamp = _timestamp();
    final row = await _localDataSource.insertJob(
      database_models.AiProcessingJobsCompanion.insert(
        id: request.id,
        jobType: request.jobType.storageValue,
        status: AiJobStatus.queued.storageValue,
        sourceId: _nullableValue(request.sourceId),
        cardId: _nullableValue(request.cardId),
        spaceId: _nullableValue(request.spaceId),
        chatSessionId: _nullableValue(request.chatSessionId),
        priority: Value(request.priority),
        maxAttempts: Value(request.maxAttempts),
        inputJson: Value(request.inputJson),
        modelSlug: _nullableValue(request.modelSlug),
        queuedAt: timestamp,
        updatedAt: timestamp,
      ),
    );

    return _mapJob(row);
  }

  @override
  Future<AiProcessingJobEntity?> getJobById(String id) async {
    final row = await _localDataSource.getJobById(id);
    return row == null ? null : _mapJob(row);
  }

  @override
  Future<AiProcessingJobEntity?> getNextRunnableJob() async {
    await recoverStaleRunningJobs();
    await _localDataSource.requeueModelReadinessFailures(
      updatedAt: _timestamp(),
    );
    final row = await _localDataSource.getNextQueuedJob();
    return row == null ? null : _mapJob(row);
  }

  @override
  Future<int> recoverStaleRunningJobs() async {
    final timestamp = _timestamp();
    final recoveredExhausted = await _localDataSource
        .requeueExhaustedStaleRunningJobs(
          staleBefore: timestamp - _staleRunningJobAge.inMilliseconds,
          updatedAt: timestamp,
        );
    final recoveredRunnable = await _localDataSource.requeueStaleRunningJobs(
      staleBefore: timestamp - _staleRunningJobAge.inMilliseconds,
      updatedAt: timestamp,
    );

    return recoveredExhausted + recoveredRunnable;
  }

  @override
  Stream<List<AiProcessingJobEntity>> watchJobs({int limit = 50}) {
    return _localDataSource
        .watchJobs(limit: limit)
        .map((rows) => rows.map(_mapJob).toList(growable: false));
  }

  @override
  Future<AiProcessingJobEntity?> startJob(String id) async {
    final timestamp = _timestamp();
    final row = await _localDataSource.markRunning(
      id: id,
      startedAt: timestamp,
      updatedAt: timestamp,
    );

    return row == null ? null : _mapJob(row);
  }

  @override
  Future<AiProcessingJobEntity> completeJob({
    required String id,
    required String outputJson,
    String? modelSlug,
  }) async {
    final timestamp = _timestamp();
    final row = await _localDataSource.markCompleted(
      id: id,
      outputJson: outputJson,
      modelSlug: modelSlug,
      completedAt: timestamp,
      updatedAt: timestamp,
    );

    return _mapJob(row);
  }

  @override
  Future<AiProcessingJobEntity> failJob({
    required String id,
    required String errorMessage,
  }) async {
    final row = await _localDataSource.markFailed(
      id: id,
      errorMessage: errorMessage,
      updatedAt: _timestamp(),
    );

    return _mapJob(row);
  }

  @override
  Future<AiProcessingJobEntity> deferJob({
    required String id,
    required String errorMessage,
  }) async {
    final row = await _localDataSource.markDeferred(
      id: id,
      errorMessage: errorMessage,
      updatedAt: _timestamp(),
    );

    return _mapJob(row);
  }

  @override
  Future<AiProcessingJobEntity> retryJob(String id) async {
    final current = await getJobById(id);
    if (current == null) {
      throw StateError('AI job does not exist.');
    }
    if (!current.canRetry) {
      throw StateError('Only failed jobs below max attempts can be retried.');
    }

    final row = await _localDataSource.markQueuedForRetry(
      id: id,
      updatedAt: _timestamp(),
    );

    return _mapJob(row);
  }

  @override
  Future<AiProcessingJobEntity> cancelJob(String id) async {
    final current = await getJobById(id);
    if (current == null) {
      throw StateError('AI job does not exist.');
    }
    if (!current.canCancel) {
      throw StateError('Only queued or running jobs can be cancelled.');
    }

    final row = await _localDataSource.markCancelled(
      id: id,
      updatedAt: _timestamp(),
    );

    return _mapJob(row);
  }

  AiProcessingJobEntity _mapJob(database_models.AiProcessingJob row) {
    return AiProcessingJobEntity(
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
    );
  }

  Value<T?> _nullableValue<T>(T? value) {
    return value == null ? const Value.absent() : Value(value);
  }

  int _timestamp() => _now().toUtc().millisecondsSinceEpoch;
}
