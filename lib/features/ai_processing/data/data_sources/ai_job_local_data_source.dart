import 'package:drift/drift.dart';
import 'package:tag/core/local_storage/database/tag_database.dart';

abstract interface class AiJobLocalDataSource {
  Future<AiProcessingJob> insertJob(AiProcessingJobsCompanion job);

  Future<AiProcessingJob?> getJobById(String id);

  Future<AiProcessingJob?> getNextQueuedJob();

  Stream<List<AiProcessingJob>> watchJobs({int limit = 50});

  Future<int> requeueStaleRunningJobs({
    required int staleBefore,
    required int updatedAt,
  });

  Future<int> requeueExhaustedStaleRunningJobs({
    required int staleBefore,
    required int updatedAt,
  });

  Future<int> requeueModelReadinessFailures({required int updatedAt});

  Future<AiProcessingJob?> markRunning({
    required String id,
    required int startedAt,
    required int updatedAt,
  });

  Future<AiProcessingJob> markCompleted({
    required String id,
    required String outputJson,
    required int completedAt,
    required int updatedAt,
    String? modelSlug,
  });

  Future<AiProcessingJob> markFailed({
    required String id,
    required String errorMessage,
    required int updatedAt,
  });

  Future<AiProcessingJob> markDeferred({
    required String id,
    required String errorMessage,
    required int updatedAt,
  });

  Future<AiProcessingJob> markQueuedForRetry({
    required String id,
    required int updatedAt,
  });

  Future<AiProcessingJob> markCancelled({
    required String id,
    required int updatedAt,
  });
}

class DriftAiJobLocalDataSource implements AiJobLocalDataSource {
  const DriftAiJobLocalDataSource(this._database);

  final TagDatabase _database;

  @override
  Future<AiProcessingJob> insertJob(AiProcessingJobsCompanion job) async {
    await _database.into(_database.aiProcessingJobs).insert(job);
    final inserted = await getJobById(job.id.value);

    if (inserted == null) {
      throw StateError('AI job row was not readable after insert.');
    }

    return inserted;
  }

  @override
  Future<AiProcessingJob?> getJobById(String id) {
    return (_database.select(
      _database.aiProcessingJobs,
    )..where((job) => job.id.equals(id))).getSingleOrNull();
  }

  @override
  Future<AiProcessingJob?> getNextQueuedJob() {
    final query = _database.select(_database.aiProcessingJobs)
      ..where(
        (job) =>
            job.status.equals('queued') &
            job.attemptCount.isSmallerThan(job.maxAttempts),
      )
      ..orderBy([
        (job) => OrderingTerm(expression: job.priority, mode: OrderingMode.asc),
        (job) => OrderingTerm(expression: job.queuedAt, mode: OrderingMode.asc),
      ])
      ..limit(1);

    return query.getSingleOrNull();
  }

  @override
  Stream<List<AiProcessingJob>> watchJobs({int limit = 50}) {
    final query = _database.select(_database.aiProcessingJobs)
      ..orderBy([
        (job) =>
            OrderingTerm(expression: job.updatedAt, mode: OrderingMode.desc),
        (job) =>
            OrderingTerm(expression: job.queuedAt, mode: OrderingMode.desc),
      ])
      ..limit(limit);

    return query.watch();
  }

  @override
  Future<int> requeueStaleRunningJobs({
    required int staleBefore,
    required int updatedAt,
  }) {
    return (_database.update(_database.aiProcessingJobs)..where(
          (job) =>
              job.status.equals('running') &
              job.attemptCount.isSmallerThan(job.maxAttempts) &
              job.startedAt.isSmallerThanValue(staleBefore),
        ))
        .write(
          AiProcessingJobsCompanion(
            status: const Value('queued'),
            outputJson: const Value(null),
            errorMessage: const Value(null),
            startedAt: const Value(null),
            completedAt: const Value(null),
            updatedAt: Value(updatedAt),
          ),
        );
  }

  @override
  Future<int> requeueExhaustedStaleRunningJobs({
    required int staleBefore,
    required int updatedAt,
  }) {
    return _database.customUpdate(
      '''
UPDATE ai_processing_jobs
SET status = 'queued',
    attempt_count = CASE
      WHEN max_attempts > 0 THEN max_attempts - 1
      ELSE 0
    END,
    output_json = NULL,
    error_message = 'Recovered stale local processing attempt for retry.',
    started_at = NULL,
    completed_at = NULL,
    updated_at = ?
WHERE status = 'running'
  AND attempt_count >= max_attempts
  AND started_at IS NOT NULL
  AND started_at < ?
''',
      variables: [Variable<int>(updatedAt), Variable<int>(staleBefore)],
      updates: {_database.aiProcessingJobs},
    );
  }

  @override
  Future<int> requeueModelReadinessFailures({required int updatedAt}) {
    return (_database.update(_database.aiProcessingJobs)..where(
          (job) =>
              job.status.equals('failed') &
              job.attemptCount.isSmallerThan(job.maxAttempts) &
              job.errorMessage.isNotNull() &
              (job.errorMessage.like('%not ready%') |
                  job.errorMessage.like('%not downloaded locally%') |
                  job.errorMessage.like('%download the local model%') |
                  job.errorMessage.like('%model initialization failed%') |
                  job.errorMessage.like('%model files are downloaded, but%')),
        ))
        .write(
          AiProcessingJobsCompanion(
            status: const Value('queued'),
            outputJson: const Value(null),
            startedAt: const Value(null),
            completedAt: const Value(null),
            updatedAt: Value(updatedAt),
          ),
        );
  }

  @override
  Future<AiProcessingJob?> markRunning({
    required String id,
    required int startedAt,
    required int updatedAt,
  }) {
    return _database.transaction(() async {
      final current = await getJobById(id);
      if (current == null || current.status != 'queued') {
        return null;
      }

      await (_database.update(
        _database.aiProcessingJobs,
      )..where((job) => job.id.equals(id))).write(
        AiProcessingJobsCompanion(
          status: const Value('running'),
          attemptCount: Value(current.attemptCount + 1),
          errorMessage: const Value(null),
          startedAt: Value(startedAt),
          completedAt: const Value(null),
          updatedAt: Value(updatedAt),
        ),
      );

      return getJobById(id);
    });
  }

  @override
  Future<AiProcessingJob> markCompleted({
    required String id,
    required String outputJson,
    required int completedAt,
    required int updatedAt,
    String? modelSlug,
  }) async {
    await (_database.update(
      _database.aiProcessingJobs,
    )..where((job) => job.id.equals(id))).write(
      AiProcessingJobsCompanion(
        status: const Value('completed'),
        outputJson: Value(outputJson),
        errorMessage: const Value(null),
        modelSlug: Value(modelSlug),
        completedAt: Value(completedAt),
        updatedAt: Value(updatedAt),
      ),
    );

    return _readExisting(id);
  }

  @override
  Future<AiProcessingJob> markFailed({
    required String id,
    required String errorMessage,
    required int updatedAt,
  }) async {
    await (_database.update(
      _database.aiProcessingJobs,
    )..where((job) => job.id.equals(id))).write(
      AiProcessingJobsCompanion(
        status: const Value('failed'),
        errorMessage: Value(errorMessage),
        updatedAt: Value(updatedAt),
      ),
    );

    return _readExisting(id);
  }

  @override
  Future<AiProcessingJob> markDeferred({
    required String id,
    required String errorMessage,
    required int updatedAt,
  }) {
    return _database.transaction(() async {
      final current = await getJobById(id);
      if (current == null) {
        throw StateError('AI job row was not readable before deferring.');
      }

      await (_database.update(
        _database.aiProcessingJobs,
      )..where((job) => job.id.equals(id))).write(
        AiProcessingJobsCompanion(
          status: const Value('queued'),
          attemptCount: Value(
            current.attemptCount <= 0 ? 0 : current.attemptCount - 1,
          ),
          outputJson: const Value(null),
          errorMessage: Value(errorMessage),
          startedAt: const Value(null),
          completedAt: const Value(null),
          updatedAt: Value(updatedAt),
        ),
      );

      return _readExisting(id);
    });
  }

  @override
  Future<AiProcessingJob> markQueuedForRetry({
    required String id,
    required int updatedAt,
  }) async {
    await (_database.update(
      _database.aiProcessingJobs,
    )..where((job) => job.id.equals(id))).write(
      AiProcessingJobsCompanion(
        status: const Value('queued'),
        outputJson: const Value(null),
        errorMessage: const Value(null),
        startedAt: const Value(null),
        completedAt: const Value(null),
        updatedAt: Value(updatedAt),
      ),
    );

    return _readExisting(id);
  }

  @override
  Future<AiProcessingJob> markCancelled({
    required String id,
    required int updatedAt,
  }) async {
    await (_database.update(
      _database.aiProcessingJobs,
    )..where((job) => job.id.equals(id))).write(
      AiProcessingJobsCompanion(
        status: const Value('cancelled'),
        errorMessage: const Value(null),
        updatedAt: Value(updatedAt),
      ),
    );

    return _readExisting(id);
  }

  Future<AiProcessingJob> _readExisting(String id) async {
    final row = await getJobById(id);
    if (row == null) {
      throw StateError('AI job row was not readable after update.');
    }

    return row;
  }
}
