import 'package:tag/features/ai_processing/domain/entities/ai_processing_job_entity.dart';

class AiJobProcessingResult {
  const AiJobProcessingResult({required this.outputJson, this.modelSlug});

  final String outputJson;
  final String? modelSlug;
}

class AiJobProcessingException implements Exception {
  const AiJobProcessingException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AiJobProcessingDeferredException extends AiJobProcessingException {
  const AiJobProcessingDeferredException(super.message);
}

abstract interface class AiJobProcessor {
  Future<AiJobProcessingResult> process(AiProcessingJobEntity job);
}
