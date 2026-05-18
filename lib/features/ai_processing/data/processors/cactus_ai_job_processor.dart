import 'dart:convert';

import 'package:tag/core/ai/orchestrator/ai_orchestrator.dart';
import 'package:tag/core/ai/rag/local_rag_service.dart';
import 'package:tag/core/ai/rag/rag_models.dart';
import 'package:tag/core/ai/schemas/card_proposal_schema.dart';
import 'package:tag/core/ai/schemas/extraction_result_schema.dart';
import 'package:tag/core/ai/schemas/intention_result_schema.dart';
import 'package:tag/core/ai/validation/ai_schema_validation_exception.dart';
import 'package:tag/core/error/app_error.dart';
import 'package:tag/core/notifications/local_notification_service.dart';
import 'package:tag/features/ai_processing/domain/entities/ai_processing_job_entity.dart';
import 'package:tag/features/ai_processing/domain/processors/ai_job_processor.dart';
import 'package:tag/features/cards/domain/use_cases/create_card_from_proposal.dart';
import 'package:tag/features/source_ingestion/domain/entities/source_item_entity.dart';
import 'package:tag/features/source_ingestion/domain/repositories/source_repository.dart';

class CactusAiJobProcessor implements AiJobProcessor {
  const CactusAiJobProcessor({
    required AiOrchestrator aiOrchestrator,
    required SourceRepository sourceRepository,
    CreateCardFromProposal? createCardFromProposal,
    LocalNotificationService? notificationService,
    LocalRagService? localRagService,
    DateTime Function()? now,
  }) : _aiOrchestrator = aiOrchestrator,
       _sourceRepository = sourceRepository,
       _createCardFromProposal = createCardFromProposal,
       _notificationService = notificationService,
       _localRagService = localRagService,
       _now = now ?? DateTime.now;

  final AiOrchestrator _aiOrchestrator;
  final SourceRepository _sourceRepository;
  final CreateCardFromProposal? _createCardFromProposal;
  final LocalNotificationService? _notificationService;
  final LocalRagService? _localRagService;
  final DateTime Function() _now;

  @override
  Future<AiJobProcessingResult> process(AiProcessingJobEntity job) async {
    if (job.jobType != AiJobType.extractSource) {
      throw AiJobProcessingException(
        '${job.jobType.storageValue} is not handled by milestone 09.',
      );
    }

    final sourceId = job.sourceId ?? _sourceIdFromInput(job.inputJson);
    if (sourceId == null || sourceId.isEmpty) {
      throw const AiJobProcessingException(
        'AI job is missing a local source id.',
      );
    }

    SourceItemEntity? loadedSource;

    try {
      final source = await _loadSource(sourceId);
      loadedSource = source;
      final modelSlug = await _aiOrchestrator.resolveModelSlug();
      final extraction = await _aiOrchestrator.extractSourceContent(
        source,
        modelSlug: modelSlug,
      );
      final extractedSource = await _sourceRepository.updateExtractionResult(
        sourceId: source.id,
        extractedText: extraction.text,
        sourceSummary: _extractionSummary(source, extraction),
        contentType: extraction.contentType,
        languageCode: extraction.language,
        detectedDatesJson: jsonEncode(extraction.dates),
        detectedTimesJson: jsonEncode(extraction.times),
        detectedLinksJson: jsonEncode(extraction.links),
        detectedEntitiesJson: jsonEncode(extraction.visibleEntities),
        visibleEntitiesJson: jsonEncode(extraction.visibleEntities),
        metadataJson: _metadataJson(
          source: source,
          job: job,
          modelSlug: modelSlug,
          extraction: extraction,
          phase: 'extracted',
        ),
        extractionConfidence: extraction.confidence,
        processingState: SourceProcessingState.extracted,
      );
      LocalRagIndexResult? ragIndexResult;
      String? ragIndexError;
      try {
        ragIndexResult = await _localRagService?.indexSource(
          sourceId: extractedSource.id,
          text: extraction.text,
        );
      } on Object catch (error) {
        ragIndexError = error.toString();
      }

      await _sourceRepository.updateProcessingState(
        sourceId: source.id,
        processingState: SourceProcessingState.classifying,
      );

      final intention = await _aiOrchestrator.detectIntention(
        source: extractedSource,
        extraction: extraction,
        modelSlug: modelSlug,
      );
      var proposal = _aiOrchestrator.buildCardProposal(
        source: extractedSource,
        intention: intention,
      );
      proposal = await _withRelatedLearningSources(
        proposal: proposal,
        source: extractedSource,
      );

      final proposedSource = await _sourceRepository.updateExtractionResult(
        sourceId: source.id,
        extractedText: extraction.text,
        sourceSummary: intention.sourceSummary,
        contentType: extraction.contentType,
        languageCode: extraction.language,
        detectedDatesJson: jsonEncode(extraction.dates),
        detectedTimesJson: jsonEncode(extraction.times),
        detectedLinksJson: jsonEncode(extraction.links),
        detectedEntitiesJson: jsonEncode(extraction.visibleEntities),
        visibleEntitiesJson: jsonEncode(extraction.visibleEntities),
        metadataJson: _metadataJson(
          source: source,
          job: job,
          modelSlug: modelSlug,
          extraction: extraction,
          intention: intention,
          proposal: proposal,
          ragIndexResult: ragIndexResult,
          ragIndexError: ragIndexError,
          phase: 'proposed',
        ),
        extractionConfidence: extraction.confidence,
        processingState: SourceProcessingState.proposed,
      );
      loadedSource = proposedSource;

      if (_aiOrchestrator.shouldCreateCard(proposal)) {
        await _createCardFromProposal?.call(
          CreateCardFromProposalParams(
            proposal: proposal,
            modelSlug: modelSlug,
          ),
        );
      } else {
        await _showImageCardFailureNotification(
          proposedSource,
          reason: _invalidCardReason(proposal),
        );
      }

      return AiJobProcessingResult(
        modelSlug: modelSlug,
        outputJson: _outputJson(
          job: job,
          modelSlug: modelSlug,
          extraction: extraction,
          intention: intention,
          proposal: proposal,
          ragIndexResult: ragIndexResult,
          ragIndexError: ragIndexError,
        ),
      );
    } on AiJobProcessingException catch (error) {
      await _showImageCardFailureNotification(
        loadedSource,
        reason: _userFacingFailureReason(error.message),
      );
      rethrow;
    } on AiSchemaValidationException catch (error) {
      await _showImageCardFailureNotification(
        loadedSource,
        reason: 'The local model returned output Tag could not use.',
      );
      throw AiJobProcessingException(error.message);
    } on AppError catch (error) {
      if (_isModelReadinessFailure(error.message)) {
        throw const AiJobProcessingDeferredException(
          'Waiting for local model setup before processing this source.',
        );
      }
      await _showImageCardFailureNotification(
        loadedSource,
        reason: _userFacingFailureReason(error.toString()),
      );
      throw AiJobProcessingException(error.toString());
    } on Object catch (error) {
      await _showImageCardFailureNotification(
        loadedSource,
        reason: 'Tag could not turn this image into a valid card.',
      );
      throw AiJobProcessingException(error.toString());
    }
  }

  Future<SourceItemEntity> _loadSource(String sourceId) async {
    final source = await _sourceRepository.getSourceById(sourceId);
    if (source == null) {
      throw AiJobProcessingException(
        'Source $sourceId could not be found locally.',
      );
    }

    return source;
  }

  String? _sourceIdFromInput(String inputJson) {
    try {
      final decoded = jsonDecode(inputJson);
      if (decoded is Map<String, dynamic>) {
        return decoded['source_id']?.toString();
      }
    } on FormatException {
      return null;
    }

    return null;
  }

  String _extractionSummary(
    SourceItemEntity source,
    ExtractionResult extraction,
  ) {
    final existingSummary = source.sourceSummary?.trim();
    if (existingSummary != null && existingSummary.isNotEmpty) {
      return existingSummary;
    }

    final text = extraction.text.trim();
    if (text.isEmpty) {
      return 'Saved ${extraction.contentType} source';
    }

    return text.length <= 72 ? text : '${text.substring(0, 72).trim()}...';
  }

  String _metadataJson({
    required SourceItemEntity source,
    required AiProcessingJobEntity job,
    required String modelSlug,
    required ExtractionResult extraction,
    required String phase,
    IntentionResult? intention,
    CardProposal? proposal,
    LocalRagIndexResult? ragIndexResult,
    String? ragIndexError,
  }) {
    final metadata = _existingMetadata(source.metadataJson);
    metadata['ai'] = {
      'processor': 'cactus_local',
      'phase': phase,
      'model_slug': modelSlug,
      'job_id': job.id,
      'updated_at': _now().toUtc().toIso8601String(),
      'extraction': {
        ...extraction.toJson(),
        'raw_dates': extraction.rawDates,
        'raw_times': extraction.rawTimes,
      },
      if (intention != null) 'intention': intention.toJson(),
      if (proposal != null) 'card_proposal': proposal.toJson(),
      if (ragIndexResult != null) 'rag_index': _ragIndexJson(ragIndexResult),
      if (ragIndexError != null) 'rag_index_error': ragIndexError,
    };

    return jsonEncode(metadata);
  }

  Map<String, Object?> _existingMetadata(String metadataJson) {
    try {
      final decoded = jsonDecode(metadataJson);
      if (decoded is Map<String, dynamic>) {
        return Map<String, Object?>.from(decoded);
      }
      if (decoded is Map) {
        return decoded.map((key, value) {
          return MapEntry(key.toString(), value);
        });
      }
    } on FormatException {
      return {'previous_metadata_parse_error': true};
    }

    return {};
  }

  Future<void> _showImageCardFailureNotification(
    SourceItemEntity? source, {
    required String reason,
  }) async {
    final notificationService = _notificationService;
    if (notificationService == null || !_isImageSource(source)) {
      return;
    }

    await notificationService.showSourceProcessingFailureNotification(
      SourceProcessingFailureNotification(
        sourceId: source!.id,
        title: 'Image was saved, but no card was made',
        body:
            '${reason.trim()} Re-add it with a short note about what you '
            'want to do.',
        sourceSummary: source.displaySummary,
      ),
    );
  }

  bool _isImageSource(SourceItemEntity? source) {
    return switch (source?.type) {
      SourceItemType.image || SourceItemType.screenshot => true,
      _ => false,
    };
  }

  String _invalidCardReason(CardProposal proposal) {
    if (proposal.cardType == 'passive') {
      return 'No clear action was detected.';
    }

    if (proposal.confidence < AiOrchestrator.cardCreationConfidenceThreshold) {
      return 'Tag was not confident enough in the detected action.';
    }

    return 'Tag could not turn this image into a valid card.';
  }

  Future<CardProposal> _withRelatedLearningSources({
    required CardProposal proposal,
    required SourceItemEntity source,
  }) async {
    if (!_isLearningSuggestionProposal(proposal)) {
      return proposal;
    }

    final relatedSourceIds = await _relatedLearningSourceIds(source);
    if (relatedSourceIds.length < 3) {
      return CardProposal(
        cardType: 'passive',
        title: 'Review saved AI learning source',
        reason:
            'Tag saved this source while waiting for related learning context.',
        spaceName: proposal.spaceName,
        nextActiveDeadline: null,
        sourceIds: [source.id],
        actions: CardProposalValues.passiveActions,
        confidence: proposal.confidence,
        notificationEligible: false,
      );
    }

    return CardProposal(
      cardType: 'suggestion',
      title: 'Goal detected: Learn LLM internals',
      reason:
          'Related saved AI systems sources point to a learning goal worth planning.',
      spaceName: 'Learning',
      nextActiveDeadline: null,
      sourceIds: relatedSourceIds,
      actions: CardProposalValues.suggestionActions,
      confidence: proposal.confidence.clamp(0.68, 0.88).toDouble(),
      notificationEligible: false,
    );
  }

  bool _isLearningSuggestionProposal(CardProposal proposal) {
    if (proposal.cardType != 'suggestion') {
      return false;
    }

    final normalized =
        '${proposal.title} ${proposal.reason} ${proposal.spaceName}'
            .toLowerCase();
    return normalized.contains('learn') ||
        normalized.contains('learning') ||
        normalized.contains('llm') ||
        normalized.contains('ai systems');
  }

  Future<List<String>> _relatedLearningSourceIds(
    SourceItemEntity source,
  ) async {
    final recentSources = await _sourceRepository
        .watchRecentSources(limit: 30)
        .first;
    final byId = <String, SourceItemEntity>{source.id: source};
    for (final recent in recentSources) {
      byId[recent.id] = recent;
    }

    final related =
        byId.values
            .where((candidate) => _isLearningSource(candidate))
            .toList(growable: false)
          ..sort((left, right) {
            final createdCompare = left.createdAt.compareTo(right.createdAt);
            if (createdCompare != 0) {
              return createdCompare;
            }
            return left.id.compareTo(right.id);
          });

    return related.map((candidate) => candidate.id).toList(growable: false);
  }

  bool _isLearningSource(SourceItemEntity source) {
    final text = [
      source.extractedText,
      source.rawText,
      source.sourceSummary,
    ].whereType<String>().join(' ').toLowerCase();
    if (text.trim().isEmpty) {
      return false;
    }

    final hasAiTopic = RegExp(
      r'\b(llm|large language model|attention|tokenization|inference|q,\s*k,\s*v|query\(q\)|key\(k\)|value\(v\)|gpu fleets?|adaptive ml|ai systems?|ml systems?)\b',
    ).hasMatch(text);
    final hasLearningShape = RegExp(
      r'\b(learn|internals?|step by step|math behind|paper|blog|article|systems context|optimization|inference at scale|data pipelines?)\b',
    ).hasMatch(text);
    final explicitApplication = RegExp(
      r'\b(apply now|application|applications?\s+close|recruiter|opportunity)\b',
    ).hasMatch(text);

    return hasAiTopic && hasLearningShape && !explicitApplication;
  }

  String _userFacingFailureReason(String message) {
    final normalized = message.toLowerCase();
    if (normalized.contains('unavailable') ||
        normalized.contains('not ready')) {
      return 'The local model is not ready yet.';
    }

    if (normalized.contains('missing') ||
        normalized.contains('no local image')) {
      return 'Tag could not find the saved image file.';
    }

    if (normalized.contains('validation') || normalized.contains('json')) {
      return 'The local model returned output Tag could not use.';
    }

    return 'Tag could not turn this image into a valid card.';
  }

  bool _isModelReadinessFailure(String message) {
    final normalized = message.toLowerCase();
    return normalized.contains('not ready') ||
        normalized.contains('not downloaded locally') ||
        normalized.contains('download the local model') ||
        normalized.contains('model initialization failed') ||
        normalized.contains('model files are downloaded, but');
  }

  String _outputJson({
    required AiProcessingJobEntity job,
    required String modelSlug,
    required ExtractionResult extraction,
    required IntentionResult intention,
    required CardProposal proposal,
    LocalRagIndexResult? ragIndexResult,
    String? ragIndexError,
  }) {
    return jsonEncode({
      'processor': 'cactus_local',
      'job_id': job.id,
      'job_type': job.jobType.storageValue,
      if (job.sourceId != null) 'source_id': job.sourceId,
      'model_slug': modelSlug,
      'extraction': extraction.toJson(),
      'intention': intention.toJson(),
      'card_proposal': proposal.toJson(),
      if (ragIndexResult != null) 'rag_index': _ragIndexJson(ragIndexResult),
      if (ragIndexError != null) 'rag_index_error': ragIndexError,
      'completed_at': _now().toUtc().toIso8601String(),
    });
  }

  Map<String, Object> _ragIndexJson(LocalRagIndexResult result) {
    return {
      'index_name': result.indexName,
      'embedding_model_slug': result.embeddingModelSlug,
      'embedding_dimension': result.embeddingDimension,
      'chunk_count': result.chunkCount,
      'embedded_chunk_count': result.embeddedChunkCount,
      'reused_chunk_count': result.reusedChunkCount,
      'removed_chunk_count': result.removedChunkCount,
      'skipped_empty_text': result.skippedEmptyText,
    };
  }
}
