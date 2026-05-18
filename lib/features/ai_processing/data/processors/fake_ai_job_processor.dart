import 'dart:convert';

import 'package:tag/features/ai_processing/domain/entities/ai_processing_job_entity.dart';
import 'package:tag/features/ai_processing/domain/processors/ai_job_processor.dart';

class FakeAiJobProcessor implements AiJobProcessor {
  FakeAiJobProcessor({
    this.delay = const Duration(milliseconds: 350),
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final Duration delay;
  final DateTime Function() _now;
  bool _shouldFailNextJob = false;

  bool get shouldFailNextJob => _shouldFailNextJob;

  void failNextJob() {
    _shouldFailNextJob = true;
  }

  @override
  Future<AiJobProcessingResult> process(AiProcessingJobEntity job) async {
    await Future<void>.delayed(delay);

    final forceFailure = _readForceFailure(job.inputJson);
    if (_shouldFailNextJob || (forceFailure && job.attemptCount <= 1)) {
      _shouldFailNextJob = false;
      throw const AiJobProcessingException(
        'Fake processor failure requested from debug queue.',
      );
    }

    return AiJobProcessingResult(
      modelSlug: 'fake-local-processor',
      outputJson: jsonEncode({
        'processor': 'fake',
        'job_id': job.id,
        'job_type': job.jobType.storageValue,
        if (job.sourceId != null) 'source_id': job.sourceId,
        'completed_at': _now().toUtc().toIso8601String(),
      }),
    );
  }

  bool _readForceFailure(String inputJson) {
    try {
      final value = jsonDecode(inputJson);
      return value is Map<String, Object?> && value['force_failure'] == true;
    } on Object {
      return false;
    }
  }
}
