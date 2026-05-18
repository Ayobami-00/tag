import 'dart:async';

import 'package:tag/core/use_cases/use_cases.dart';
import 'package:tag/features/ai_processing/domain/services/ai_job_queue_runner.dart';
import 'package:tag/features/ai_processing/domain/use_cases/process_next_ai_job.dart';

class LocalAiJobQueueRunner implements AiJobQueueRunner {
  LocalAiJobQueueRunner({
    required ProcessNextAiJob processNextAiJob,
    Duration recoveryPollInterval = const Duration(seconds: 20),
    int maxJobsPerTurn = 1,
    Duration interJobYield = const Duration(milliseconds: 16),
  }) : assert(maxJobsPerTurn > 0),
       _processNextAiJob = processNextAiJob,
       _recoveryPollInterval = recoveryPollInterval,
       _maxJobsPerTurn = maxJobsPerTurn,
       _interJobYield = interJobYield;

  final ProcessNextAiJob _processNextAiJob;
  final Duration _recoveryPollInterval;
  final int _maxJobsPerTurn;
  final Duration _interJobYield;
  Future<void>? _activeDrain;
  Timer? _recoveryTimer;
  Timer? _nextPassTimer;
  bool _needsAnotherPass = false;
  bool _isStopped = false;

  @override
  bool get isProcessing => _activeDrain != null;

  @override
  void start() {
    _isStopped = false;
    _recoveryTimer ??= Timer.periodic(
      _recoveryPollInterval,
      (_) => requestProcessing(),
    );
    requestProcessing();
  }

  @override
  void stop() {
    _isStopped = true;
    _recoveryTimer?.cancel();
    _recoveryTimer = null;
    _nextPassTimer?.cancel();
    _nextPassTimer = null;
  }

  @override
  void requestProcessing() {
    if (_activeDrain != null) {
      _needsAnotherPass = true;
      return;
    }

    _activeDrain = _drainQueue();
    unawaited(_activeDrain);
  }

  @override
  Future<void> drain() {
    requestProcessing();
    return _activeDrain ?? Future<void>.value();
  }

  Future<void> _drainQueue() async {
    try {
      var processedThisTurn = 0;
      while (true) {
        _needsAnotherPass = false;
        final processedJob = await _processNextAiJob(const NoParams());
        if (processedJob == null) {
          break;
        }
        processedThisTurn++;
        await Future<void>.delayed(_interJobYield);
        if (processedThisTurn >= _maxJobsPerTurn) {
          _needsAnotherPass = true;
          return;
        }
      }
    } finally {
      _activeDrain = null;
      if (_needsAnotherPass) {
        _needsAnotherPass = false;
        _nextPassTimer?.cancel();
        _nextPassTimer = Timer(Duration.zero, () {
          _nextPassTimer = null;
          if (_isStopped) {
            return;
          }
          requestProcessing();
        });
      }
    }
  }
}
