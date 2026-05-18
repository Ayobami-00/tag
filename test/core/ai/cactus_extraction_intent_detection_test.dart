import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tag/core/ai/cactus/cactus_model_registry.dart';
import 'package:tag/core/ai/cactus/cactus_model_service.dart';
import 'package:tag/core/ai/orchestrator/ai_orchestrator.dart';
import 'package:tag/core/ai/schemas/card_proposal_schema.dart';
import 'package:tag/core/ai/schemas/extraction_result_schema.dart';
import 'package:tag/core/ai/schemas/intention_result_schema.dart';
import 'package:tag/core/ai/validation/ai_json_validator.dart';
import 'package:tag/core/ai/validation/ai_schema_validation_exception.dart';
import 'package:tag/core/local_storage/database/tag_database.dart';
import 'package:tag/core/notifications/local_notification_permission_service.dart';
import 'package:tag/core/notifications/local_notification_service.dart';
import 'package:tag/core/platform/local_text_recognition_service.dart';
import 'package:tag/core/use_cases/use_cases.dart';
import 'package:tag/features/ai_processing/data/data_sources/ai_job_local_data_source.dart';
import 'package:tag/features/ai_processing/data/processors/cactus_ai_job_processor.dart';
import 'package:tag/features/ai_processing/data/repositories/ai_job_repository_impl.dart';
import 'package:tag/features/ai_processing/domain/entities/ai_processing_job_entity.dart';
import 'package:tag/features/ai_processing/domain/repositories/ai_job_repository.dart';
import 'package:tag/features/ai_processing/domain/use_cases/process_next_ai_job.dart';
import 'package:tag/features/source_ingestion/data/data_sources/source_local_data_source.dart';
import 'package:tag/features/source_ingestion/data/repositories/source_repository_impl.dart';
import 'package:tag/features/source_ingestion/domain/entities/source_item_entity.dart';
import 'package:tag/features/source_ingestion/domain/repositories/source_repository.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  const validator = AiJsonValidator();

  test('valid extraction JSON parses', () {
    final result = validator.parseObject(
      rawOutput: jsonEncode(_validExtractionJson()),
      decoder: ExtractionResult.fromJson,
    );

    expect(result.text, 'Please buy bread at 8pm');
    expect(result.contentType, 'message');
    expect(result.times, ['8pm']);
    expect(result.confidence, 0.92);
  });

  test('common source-shape content types normalize to unknown', () {
    final result = validator.parseObject(
      rawOutput: jsonEncode({
        ..._validExtractionJson(),
        'content_type': 'text',
      }),
      decoder: ExtractionResult.fromJson,
    );

    expect(result.contentType, 'unknown');
  });

  test('schema-placeholder content type normalizes to unknown', () {
    final result = validator.parseObject(
      rawOutput: jsonEncode({
        ..._validExtractionJson(),
        'content_type':
            'message | job_post | article | event | product | travel | unknown',
      }),
      decoder: ExtractionResult.fromJson,
    );

    expect(result.contentType, 'unknown');
  });

  test('missing extraction list fields default to empty lists', () {
    final result = validator.parseObject(
      rawOutput: jsonEncode({
        'text': 'A landscape photo',
        'content_type': 'image',
        'language': 'en',
        'confidence': 0.6,
      }),
      decoder: ExtractionResult.fromJson,
    );

    expect(result.contentType, 'unknown');
    expect(result.dates, isEmpty);
    expect(result.times, isEmpty);
    expect(result.links, isEmpty);
    expect(result.visibleEntities, isEmpty);
  });

  test('invalid extraction JSON fails cleanly', () {
    expect(
      () => validator.parseObject(
        rawOutput: '{"text":"missing fields"}',
        decoder: ExtractionResult.fromJson,
      ),
      throwsA(isA<AiSchemaValidationException>()),
    );
  });

  test('valid intention JSON parses', () {
    final result = validator.parseObject(
      rawOutput: jsonEncode(_validIntentionJson()),
      decoder: IntentionResult.fromJson,
    );

    expect(result.intentionType, 'buy');
    expect(result.suggestedCardType, 'urgent');
    expect(result.nextActiveDeadline, '2026-05-10T20:00:00+01:00');
  });

  test(
    'passive intention output promotes obvious source-backed purchase',
    () async {
      final orchestrator = AiOrchestrator(
        cactusModelService: _FakeCactusModelService(textResponses: ['{}']),
        now: _fixedNow,
      );

      final result = await orchestrator.detectIntention(
        source: _sourceEntity(id: 'src_text', type: SourceItemType.text),
        extraction: const ExtractionResult(
          text: 'Buy oat milk today at 8pm',
          visibleEntities: ['oat milk'],
          dates: [],
          times: ['20:00'],
          links: [],
          contentType: 'message',
          language: 'en',
          confidence: 0.88,
        ),
      );

      expect(result.intentionType, 'buy');
      expect(result.suggestedCardType, 'urgent');
      expect(result.title, 'Buy oat milk');
      expect(result.nextActiveDeadline, startsWith('2026-05-10T20:00:00'));
      expect(result.evidenceSummary, contains('Buy oat milk today at 8pm'));
    },
  );

  test(
    'passive intention output promotes clear job application evidence',
    () async {
      final orchestrator = AiOrchestrator(
        cactusModelService: _FakeCactusModelService(textResponses: ['{}']),
        now: _fixedNow,
      );

      final result = await orchestrator.detectIntention(
        source: _sourceEntity(id: 'src_job', type: SourceItemType.image),
        extraction: const ExtractionResult(
          text:
              'nVIDIA\nNVIDIA\nSenior System Software\nEngineer - Dynamo O\nRemote\nFull-time\nApply',
          visibleEntities: ['NVIDIA'],
          dates: [],
          times: [],
          links: [],
          contentType: 'job_post',
          language: 'en',
          confidence: 0.82,
        ),
      );

      expect(result.intentionType, 'apply');
      expect(result.suggestedCardType, 'goal');
      expect(
        result.title,
        'Apply to NVIDIA: Senior System Software Engineer - Dynamo',
      );
      expect(result.nextActiveDeadline, isNull);
      expect(result.spaceSuggestion, 'Career');
    },
  );

  test(
    'passive intention output promotes future event invitation evidence',
    () async {
      final orchestrator = AiOrchestrator(
        cactusModelService: _FakeCactusModelService(textResponses: ['{}']),
        now: _fixedNow,
      );

      final result = await orchestrator.detectIntention(
        source: _sourceEntity(id: 'src_event', type: SourceItemType.image),
        extraction: const ExtractionResult(
          text:
              'Invitation: Plexe Team Sync @\nMon 11 May 2026 2:30pm -\n3:30pm (BST)\nToday • 14:30 - 15:30\nPlexe Team Sync\nYes\nNo\nMaybe',
          visibleEntities: ['Plexe Team Sync'],
          dates: [],
          times: [],
          links: [],
          contentType: 'event',
          language: 'en',
          confidence: 0.82,
        ),
      );

      expect(result.intentionType, 'attend');
      expect(result.suggestedCardType, 'urgent');
      expect(result.title, 'RSVP to Plexe Team Sync');
      expect(result.nextActiveDeadline, startsWith('2026-05-11T14:30:00'));
      expect(result.spaceSuggestion, 'Schedule');
    },
  );

  test(
    'passive intention output promotes saved streak evidence to same-day urgent card',
    () async {
      final orchestrator = AiOrchestrator(
        cactusModelService: _FakeCactusModelService(textResponses: ['{}']),
        now: _fixedNow,
      );

      final result = await orchestrator.detectIntention(
        source: _sourceEntity(id: 'src_streak', type: SourceItemType.image),
        extraction: const ExtractionResult(
          text:
              "You're on a 3 Day Streak,\nChess.com\nKeep Your Streak\nAlive!",
          visibleEntities: ['Chess.com'],
          dates: [],
          times: [],
          links: [],
          contentType: 'unknown',
          language: 'en',
          confidence: 0.75,
        ),
      );

      expect(result.intentionType, 'complete');
      expect(result.suggestedCardType, 'urgent');
      expect(result.title, 'Complete Chess.com streak');
      expect(result.nextActiveDeadline, startsWith('2026-05-10T23:59:00'));
      expect(result.spaceSuggestion, 'Chess');
      expect(result.evidenceSummary, contains('3 Day Streak'));
    },
  );

  test('past event invitation evidence becomes an in-app suggestion', () async {
    final orchestrator = AiOrchestrator(
      cactusModelService: _FakeCactusModelService(textResponses: ['{}']),
      now: _fixedNow,
    );

    final result = await orchestrator.detectIntention(
      source: _sourceEntity(id: 'src_event', type: SourceItemType.image),
      extraction: const ExtractionResult(
        text:
            'Invitation: Plexe Team Sync @\nThu 9 Apr 2026 2:30pm -\n3:30pm (BST)\nToday • 14:30 - 15:30\nPlexe Team Sync\nYes\nNo\nMaybe',
        visibleEntities: ['Plexe Team Sync'],
        dates: [],
        times: [],
        links: [],
        contentType: 'event',
        language: 'en',
        confidence: 0.82,
      ),
    );

    expect(result.intentionType, 'decide');
    expect(result.suggestedCardType, 'suggestion');
    expect(result.title, 'Review Plexe Team Sync invitation');
    expect(result.nextActiveDeadline, isNull);
    expect(result.spaceSuggestion, 'Schedule');
  });

  test('passive intention output promotes sign-in code evidence', () async {
    final orchestrator = AiOrchestrator(
      cactusModelService: _FakeCactusModelService(textResponses: ['{}']),
      now: _fixedNow,
    );

    final result = await orchestrator.detectIntention(
      source: _sourceEntity(id: 'src_code', type: SourceItemType.image),
      extraction: const ExtractionResult(
        text:
            'Netflix: Your sign-in code\nEnter this code to sign in\n4590\nThis code will expire in 15 minutes.',
        visibleEntities: ['Netflix'],
        dates: [],
        times: [],
        links: [],
        contentType: 'unknown',
        language: 'en',
        confidence: 0.82,
      ),
    );

    expect(result.intentionType, 'follow_up');
    expect(result.suggestedCardType, 'suggestion');
    expect(result.title, 'Use Netflix sign-in code');
    expect(result.reason, contains('4590'));
    expect(result.nextActiveDeadline, isNull);
    expect(result.spaceSuggestion, 'Accounts');
  });

  test(
    'malformed intention output falls back to account security evidence',
    () async {
      final orchestrator = AiOrchestrator(
        cactusModelService: _FakeCactusModelService(
          textResponses: ['not json', 'still not json'],
        ),
        now: _fixedNow,
      );

      final result = await orchestrator.detectIntention(
        source: _sourceEntity(id: 'src_security', type: SourceItemType.image),
        extraction: const ExtractionResult(
          text:
              'A new device is using your account\nA new device signed in to your Netflix account.\nDevice PC Chrome - Web Browser\nLocation Kwara, Nigeria\nIf it was someone else:',
          visibleEntities: ['Netflix'],
          dates: [],
          times: [],
          links: [],
          contentType: 'unknown',
          language: 'en',
          confidence: 0.78,
        ),
      );

      expect(result.intentionType, 'decide');
      expect(result.suggestedCardType, 'suggestion');
      expect(result.title, 'Review Netflix account activity');
      expect(result.nextActiveDeadline, isNull);
      expect(result.spaceSuggestion, 'Security');
    },
  );

  test('DocuSign tenancy evidence creates a review suggestion locally', () async {
    final service = _FakeCactusModelService(textResponses: const []);
    final orchestrator = AiOrchestrator(
      cactusModelService: service,
      now: _fixedNow,
    );

    final result = await orchestrator.detectIntention(
      source: _sourceEntity(id: 'src_tenancy', type: SourceItemType.image),
      extraction: const ExtractionResult(
        text:
            'Docusign Envelope ID: DEMO-0001\nASSURED SHORTHOLD TENANCY AGREEMENT\n28 February 2026\nDATED\nBETWEEN\nAlex Morgan\nRELATING TO:\n42 Sample Street\nLetter_20260221.PDF',
        visibleEntities: ['Docusign'],
        dates: [],
        times: [],
        links: [],
        contentType: 'unknown',
        language: 'en',
        confidence: 0.75,
      ),
    );

    expect(result.intentionType, 'read');
    expect(result.suggestedCardType, 'suggestion');
    expect(result.title, 'Review tenancy agreement');
    expect(result.nextActiveDeadline, isNull);
    expect(result.spaceSuggestion, 'Home');
    expect(service.textCompletionCount, 0);
  });

  test('direct request evidence creates a suggestion locally', () async {
    final service = _FakeCactusModelService(textResponses: const []);
    final orchestrator = AiOrchestrator(
      cactusModelService: service,
      now: _fixedNow,
    );

    final result = await orchestrator.detectIntention(
      source: _sourceEntity(id: 'src_request', type: SourceItemType.image),
      extraction: const ExtractionResult(
        text: 'My love\nPlease can you help me make\nchips?',
        visibleEntities: ['chips'],
        dates: [],
        times: [],
        links: [],
        contentType: 'message',
        language: 'en',
        confidence: 0.95,
      ),
    );

    expect(result.intentionType, 'follow_up');
    expect(result.suggestedCardType, 'suggestion');
    expect(result.title, 'Help make chips');
    expect(result.nextActiveDeadline, isNull);
    expect(result.spaceSuggestion, 'Home');
    expect(service.textCompletionCount, 0);
  });

  test('feedback call request is not classified as a purchase', () async {
    final service = _FakeCactusModelService(textResponses: const []);
    final orchestrator = AiOrchestrator(
      cactusModelService: service,
      now: _fixedNow,
    );

    final result = await orchestrator.detectIntention(
      source: _sourceEntity(
        id: 'src_feedback_call',
        type: SourceItemType.image,
      ),
      extraction: const ExtractionResult(
        text:
            'So i am almost done with that open-source thing for human in the loop. '
            'I was going to ask if we could do a call during the weekend to see '
            'you implement it and get your general feedback on the developer '
            'experience generally. Like if it is easy to setup and all of that '
            '19:00',
        visibleEntities: [],
        dates: [],
        times: [],
        links: [],
        contentType: 'message',
        language: 'en',
        confidence: 0.75,
      ),
    );

    expect(result.intentionType, 'follow_up');
    expect(result.suggestedCardType, 'suggestion');
    expect(result.title, 'Plan weekend feedback call');
    expect(result.spaceSuggestion, 'Work');
    expect(result.reason, contains('feedback'));
    expect(service.textCompletionCount, 0);
  });

  test(
    'family weekend call request becomes an urgent weekend reminder',
    () async {
      final service = _FakeCactusModelService(textResponses: const []);
      final orchestrator = AiOrchestrator(
        cactusModelService: service,
        now: _fixedNow,
      );

      final result = await orchestrator.detectIntention(
        source: _sourceEntity(
          id: 'src_sister_call',
          type: SourceItemType.image,
        ),
        extraction: const ExtractionResult(
          text:
              'Sista\nWe fit schedule call for this weekend?\n'
              "It's just a short call\nBut I need to talk with you about something",
          visibleEntities: ['Sista'],
          dates: [],
          times: [],
          links: [],
          contentType: 'message',
          language: 'en',
          confidence: 0.75,
        ),
      );

      expect(result.intentionType, 'follow_up');
      expect(result.suggestedCardType, 'urgent');
      expect(result.title, 'Call your sister this weekend');
      expect(result.nextActiveDeadline, startsWith('2026-05-10T18:00:00'));
      expect(result.spaceSuggestion, 'Family');
      expect(service.textCompletionCount, 0);
    },
  );

  test(
    'course application deadline becomes an urgent learning application card',
    () async {
      final service = _FakeCactusModelService(textResponses: const []);
      final orchestrator = AiOrchestrator(
        cactusModelService: service,
        now: _fixedNow,
      );

      final result = await orchestrator.detectIntention(
        source: _sourceEntity(
          id: 'src_ai_saturdays',
          type: SourceItemType.image,
        ),
        extraction: const ExtractionResult(
          text:
              '[AI6Lagos] Final Call: TRI AI Saturdays Cohort 10\n'
              'There are only 2 days left until applications close for '
              'TRI AI Saturdays Cohort 10 on May 17th.\n'
              'If you have been waiting to submit your application, this is '
              'your final reminder.\nApply Now: https://tinyurl.com/tri',
          visibleEntities: ['TRI AI Saturdays'],
          dates: [],
          times: [],
          links: ['https://tinyurl.com/tri'],
          contentType: 'job_post',
          language: 'en',
          confidence: 0.75,
        ),
      );

      expect(result.intentionType, 'apply');
      expect(result.suggestedCardType, 'urgent');
      expect(result.title, 'Complete TRI AI Saturdays Cohort 10 application');
      expect(result.nextActiveDeadline, startsWith('2026-05-17T23:59:00'));
      expect(result.spaceSuggestion, 'AI Saturdays');
      expect(service.textCompletionCount, 0);
    },
  );

  test('engineering article evidence creates a read-later goal card', () async {
    final service = _FakeCactusModelService(textResponses: const []);
    final orchestrator = AiOrchestrator(
      cactusModelService: service,
      now: _fixedNow,
    );

    final result = await orchestrator.detectIntention(
      source: _sourceEntity(id: 'src_medium', type: SourceItemType.image),
      extraction: const ExtractionResult(
        text:
            "I Built Uber's Real-Time Tracking System "
            '(50,000 Concurrent Drivers, Sub-100ms Updates)\n'
            'Ronik Dedhia in JavaScript in Plain English\n'
            'Medium Daily Digest\nThe map that would not stop freezing',
        visibleEntities: ['Medium'],
        dates: [],
        times: [],
        links: [],
        contentType: 'unknown',
        language: 'en',
        confidence: 0.75,
      ),
    );

    expect(result.intentionType, 'read');
    expect(result.suggestedCardType, 'goal');
    expect(result.title, contains('Uber'));
    expect(result.nextActiveDeadline, isNull);
    expect(result.spaceSuggestion, 'Engineering Articles');
    expect(service.textCompletionCount, 0);
  });

  test(
    'AI systems learning source becomes a non-notifying suggestion',
    () async {
      final service = _FakeCactusModelService(textResponses: const []);
      final orchestrator = AiOrchestrator(
        cactusModelService: service,
        now: _fixedNow,
      );

      final result = await orchestrator.detectIntention(
        source: _sourceEntity(id: 'src_llm', type: SourceItemType.image),
        extraction: const ExtractionResult(
          text:
              'Learn LLM internals step by step - from tokenization to '
              'attention to inference optimization.',
          visibleEntities: ['LLM Internals'],
          dates: [],
          times: [],
          links: [],
          contentType: 'unknown',
          language: 'en',
          confidence: 0.75,
        ),
      );

      final proposal = orchestrator.buildCardProposal(
        source: _sourceEntity(id: 'src_llm', type: SourceItemType.image),
        intention: result,
      );

      expect(result.intentionType, 'learn');
      expect(result.suggestedCardType, 'suggestion');
      expect(result.nextActiveDeadline, isNull);
      expect(proposal.notificationEligible, isFalse);
      expect(service.textCompletionCount, 0);
    },
  );

  test(
    'low-confidence actionable model output falls below card threshold',
    () async {
      final orchestrator = AiOrchestrator(
        cactusModelService: _FakeCactusModelService(
          textResponses: [
            jsonEncode({
              'intention_type': 'plan',
              'confidence': 0.55,
              'title': 'Plan trip',
              'reason': 'The source may be travel inspiration.',
              'next_active_deadline': null,
              'suggested_card_type': 'suggestion',
              'space_suggestion': 'Travel',
              'source_summary': 'Travel post',
              'evidence_summary': 'The source mentions a possible destination.',
            }),
          ],
        ),
        now: _fixedNow,
      );

      final result = await orchestrator.detectIntention(
        source: _sourceEntity(
          id: 'src_low_confidence',
          type: SourceItemType.text,
        ),
        extraction: const ExtractionResult(
          text: 'A scenic travel photo with no visible ask or deadline.',
          visibleEntities: [],
          dates: [],
          times: [],
          links: [],
          contentType: 'unknown',
          language: 'en',
          confidence: 0.8,
        ),
      );

      expect(result.intentionType, 'remember');
      expect(result.suggestedCardType, 'passive');
      expect(result.confidence, 0.55);
      expect(result.reason, contains('confidence'));
    },
  );

  test('missing safe intention fields default to passive remember', () {
    final result = validator.parseObject(
      rawOutput: jsonEncode({
        'reason': 'No actionable request was visible.',
        'space_suggestion': 'Saved Images',
        'source_summary': 'Manual image',
        'evidence_summary': 'The source appears to be a landscape image.',
      }),
      decoder: IntentionResult.fromJson,
    );

    expect(result.intentionType, 'remember');
    expect(result.suggestedCardType, 'passive');
    expect(result.title, 'No actionable request was visible.');
    expect(result.nextActiveDeadline, isNull);
    expect(result.confidence, 0.5);
  });

  test('invalid card type is rejected', () {
    expect(
      () => CardProposal.fromJson({
        ..._validCardProposalJson(),
        'card_type': 'calendar',
      }),
      throwsA(isA<AiSchemaValidationException>()),
    );
  });

  test('suggestion proposal does not set notification eligibility', () {
    final proposal = CardProposal.fromJson({
      ..._validCardProposalJson(),
      'card_type': 'suggestion',
      'next_active_deadline': null,
      'actions': ['plan_this', 'dismiss'],
      'notification_enabled': true,
    });

    expect(proposal.notificationEligible, isFalse);
  });

  test('card creation threshold blocks weak proposals', () {
    final orchestrator = AiOrchestrator(
      cactusModelService: _FakeCactusModelService(textResponses: const []),
      now: _fixedNow,
    );
    final weakSuggestion = CardProposal.fromJson({
      ..._validCardProposalJson(),
      'card_type': 'suggestion',
      'next_active_deadline': null,
      'actions': ['plan_this', 'dismiss'],
      'confidence': 0.59,
    });
    final thresholdSuggestion = CardProposal.fromJson({
      ..._validCardProposalJson(),
      'card_type': 'suggestion',
      'next_active_deadline': null,
      'actions': ['plan_this', 'dismiss'],
      'confidence': AiOrchestrator.cardCreationConfidenceThreshold,
    });
    final passive = CardProposal.fromJson({
      ..._validCardProposalJson(),
      'card_type': 'passive',
      'next_active_deadline': null,
      'actions': <String>[],
      'confidence': 0.95,
    });

    expect(orchestrator.shouldCreateCard(weakSuggestion), isFalse);
    expect(orchestrator.shouldCreateCard(thresholdSuggestion), isTrue);
    expect(orchestrator.shouldCreateCard(passive), isFalse);
  });

  test('image sources use Cactus vision completion', () async {
    final directory = await Directory.systemTemp.createTemp('tag_image_source');
    addTearDown(() => directory.delete(recursive: true));
    final imageFile = File('${directory.path}/src_image.png');
    await imageFile.writeAsBytes([1, 2, 3]);
    final service = _FakeCactusModelService(
      textResponses: const [],
      imageResponses: [jsonEncode(_validExtractionJson())],
    );
    final orchestrator = AiOrchestrator(
      cactusModelService: service,
      now: _fixedNow,
    );
    final source = _sourceEntity(
      id: 'src_image',
      type: SourceItemType.image,
      localFilePath: imageFile.path,
    );

    final result = await orchestrator.extractSourceContent(source);

    expect(result.text, 'Please buy bread at 8pm');
    expect(service.visionCompletionCount, 1);
    expect(service.textCompletionCount, 0);
  });

  test('image extraction falls back to readable plain text model output', () async {
    final directory = await Directory.systemTemp.createTemp('tag_image_source');
    addTearDown(() => directory.delete(recursive: true));
    final imageFile = File('${directory.path}/src_image.png');
    await imageFile.writeAsBytes([1, 2, 3]);
    final service = _FakeCactusModelService(
      textResponses: const [],
      imageResponses: const [
        'NVIDIA Senior System Software Engineer - Dynamo Remote Full-time Apply',
        'NVIDIA Senior System Software Engineer - Dynamo Remote Full-time Apply',
      ],
    );
    final orchestrator = AiOrchestrator(
      cactusModelService: service,
      now: _fixedNow,
    );
    final source = _sourceEntity(
      id: 'src_image',
      type: SourceItemType.image,
      localFilePath: imageFile.path,
    );

    final result = await orchestrator.extractSourceContent(source);

    expect(result.text, contains('NVIDIA'));
    expect(result.contentType, 'job_post');
    expect(result.confidence, 0.45);
    expect(service.visionCompletionCount, 2);
  });

  test(
    'text extraction falls back to original local text after invalid JSON',
    () async {
      const sourceText =
          'Could we do a call this weekend to get feedback on the '
          'open-source human-in-the-loop prototype demo?';
      final invalidExtractionJson = jsonEncode({
        ..._validExtractionJson(),
        'text': 'model returned a partial extraction',
        'times': 'weekend',
      });
      final service = _FakeCactusModelService(
        textResponses: [invalidExtractionJson, invalidExtractionJson],
      );
      final orchestrator = AiOrchestrator(
        cactusModelService: service,
        now: _fixedNow,
      );
      final source = _sourceEntity(
        id: 'src_text',
        type: SourceItemType.text,
        rawText: sourceText,
      );

      final result = await orchestrator.extractSourceContent(source);

      expect(result.text, sourceText);
      expect(result.times, isEmpty);
      expect(result.language, 'en');
      expect(result.confidence, 0.9);
      expect(service.textCompletionCount, 2);
    },
  );

  test(
    'text extraction preserves original local text after valid JSON',
    () async {
      const sourceText =
          'Could we do a call this weekend to get feedback on the '
          'open-source human-in-the-loop prototype demo? '
          'https://example.com/prototype';
      final service = _FakeCactusModelService(
        textResponses: [
          jsonEncode({
            ..._validExtractionJson(),
            'text': 'A summarized feedback call request.',
            'links': <String>[],
            'content_type': 'unknown',
            'confidence': 0.71,
          }),
        ],
      );
      final orchestrator = AiOrchestrator(
        cactusModelService: service,
        now: _fixedNow,
      );
      final source = _sourceEntity(
        id: 'src_text',
        type: SourceItemType.text,
        rawText: sourceText,
      );

      final result = await orchestrator.extractSourceContent(source);

      expect(result.text, sourceText);
      expect(result.links, ['https://example.com/prototype']);
      expect(result.confidence, 0.71);
      expect(service.textCompletionCount, 1);
    },
  );

  test('image extraction passes local OCR text and falls back to it', () async {
    final directory = await Directory.systemTemp.createTemp('tag_image_source');
    addTearDown(() => directory.delete(recursive: true));
    final imageFile = File('${directory.path}/src_image.png');
    await imageFile.writeAsBytes([1, 2, 3]);
    final service = _FakeCactusModelService(
      textResponses: const [],
      imageResponses: const ['SINGLE', 'SINGLE'],
    );
    final ocr = _FakeLocalTextRecognitionService(
      const LocalRecognizedText(
        text:
            'NVIDIA\nSenior System Software Engineer - Dynamo\nRemote\nFull-time\nApply',
        confidence: 0.81,
      ),
    );
    final orchestrator = AiOrchestrator(
      cactusModelService: service,
      localTextRecognitionService: ocr,
      now: _fixedNow,
    );
    final source = _sourceEntity(
      id: 'src_image',
      type: SourceItemType.image,
      localFilePath: imageFile.path,
    );

    final result = await orchestrator.extractSourceContent(source);

    expect(ocr.lastImagePath, imageFile.path);
    expect(
      service.lastImageMessages?.any(
        (message) => message.content.contains('On-device OCR'),
      ),
      isTrue,
    );
    expect(
      service.lastImageMessages?.any(
        (message) => message.content.contains('NVIDIA'),
      ),
      isTrue,
    );
    expect(result.text, contains('Senior System Software Engineer'));
    expect(result.contentType, 'job_post');
    expect(result.confidence, 0.75);
    expect(service.visionCompletionCount, 2);
  });

  test('source row updates after extraction and intention detection', () async {
    final harness = _ProcessorHarness(
      cactusModelService: _FakeCactusModelService(
        textResponses: [
          jsonEncode(_validExtractionJson()),
          jsonEncode(_validIntentionJson()),
        ],
      ),
    );
    addTearDown(harness.close);
    await harness.createTextSource('src_text');
    await harness.createJob('job_extract', 'src_text');

    final processed = await harness.processNextAiJob(const NoParams());
    final source = await harness.sourceRepository.getSourceById('src_text');
    final job = await harness.aiJobRepository.getJobById('job_extract');
    final sourceMetadata = jsonDecode(source!.metadataJson) as Map;
    final output = jsonDecode(job!.outputJson!) as Map;

    expect(processed?.status, AiJobStatus.completed);
    expect(source.processingState, SourceProcessingState.completed);
    expect(source.extractedText, 'Please buy bread at 8pm');
    expect(source.detectedTimesJson, jsonEncode(['20:00']));
    expect(source.contentType, 'message');
    expect(sourceMetadata['ai']['intention']['intention_type'], 'buy');
    expect(output['card_proposal']['card_type'], 'urgent');
    expect(output['card_proposal']['notification_eligible'], isTrue);
  });

  test(
    'image source without a valid card shows failure notification',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'tag_image_source',
      );
      addTearDown(() => directory.delete(recursive: true));
      final imageFile = File('${directory.path}/src_image.png');
      await imageFile.writeAsBytes([1, 2, 3]);
      final notifications = _RecordingLocalNotificationService();
      final harness = _ProcessorHarness(
        cactusModelService: _FakeCactusModelService(
          textResponses: [
            jsonEncode({
              ..._validIntentionJson(),
              'intention_type': 'remember',
              'confidence': 0.91,
              'title': 'Review image',
              'reason': 'The image does not show a clear next action.',
              'next_active_deadline': null,
              'suggested_card_type': 'passive',
              'space_suggestion': 'General',
              'source_summary': 'Uploaded image without a clear action',
              'evidence_summary':
                  'The image does not show a clear next action.',
            }),
          ],
          imageResponses: [
            jsonEncode({
              ..._validExtractionJson(),
              'text': 'A saved image with no obvious next action.',
              'visible_entities': ['saved image'],
              'times': <String>[],
              'content_type': 'image',
              'confidence': 0.78,
            }),
          ],
        ),
        notificationService: notifications,
      );
      addTearDown(harness.close);
      await harness.sourceRepository.createSource(
        CreateSourceRequest(
          id: 'src_image',
          type: SourceItemType.image,
          localFilePath: imageFile.path,
          sourceSummary: 'Uploaded image',
        ),
      );
      await harness.createJob('job_image', 'src_image');

      final processed = await harness.processNextAiJob(const NoParams());
      final job = await harness.aiJobRepository.getJobById('job_image');
      final output = jsonDecode(job!.outputJson!) as Map;

      expect(processed?.status, AiJobStatus.completed);
      expect(output['card_proposal']['card_type'], 'passive');
      expect(notifications.sourceFailures, hasLength(1));
      expect(notifications.sourceFailures.single.sourceId, 'src_image');
      expect(
        notifications.sourceFailures.single.body,
        contains('No clear action was detected.'),
      );
      expect(notifications.sourceFailures.single.body, contains('Re-add it'));
    },
  );

  test(
    'third related AI learning source creates one source-linked suggestion',
    () async {
      final harness = _ProcessorHarness(
        cactusModelService: _FakeCactusModelService(
          textResponses: [
            jsonEncode({
              ..._validExtractionJson(),
              'text':
                  'Learn LLM internals step by step - from tokenization to '
                  'attention to inference optimization.',
              'visible_entities': ['LLM Internals'],
              'times': <String>[],
              'content_type': 'unknown',
              'confidence': 0.75,
            }),
          ],
        ),
      );
      addTearDown(harness.close);
      await harness.sourceRepository.createSource(
        const CreateSourceRequest(
          id: 'src_llm_inference',
          type: SourceItemType.text,
          rawText:
              'Distributed Systems Engineer - LLM inference at scale, '
              'data pipelines, GPU fleets.',
          extractedText:
              'Distributed Systems Engineer - LLM inference at scale, '
              'data pipelines, GPU fleets.',
          sourceSummary: 'LLM inference systems',
        ),
      );
      await harness.sourceRepository.createSource(
        const CreateSourceRequest(
          id: 'src_attention',
          type: SourceItemType.text,
          rawText: 'The math behind Attention: Query(Q), Key(K), and Value(V).',
          extractedText:
              'The math behind Attention: Query(Q), Key(K), and Value(V).',
          sourceSummary: 'Math behind attention',
        ),
      );
      await harness.sourceRepository.createSource(
        const CreateSourceRequest(
          id: 'src_llm_internals',
          type: SourceItemType.text,
          rawText:
              'Learn LLM internals step by step - from tokenization to '
              'attention to inference optimization.',
          sourceSummary: 'LLM internals',
        ),
      );
      await harness.createJob('job_llm_cluster', 'src_llm_internals');

      final processed = await harness.processNextAiJob(const NoParams());
      final job = await harness.aiJobRepository.getJobById('job_llm_cluster');
      final output = jsonDecode(job!.outputJson!) as Map;
      final proposal = output['card_proposal'] as Map;

      expect(processed?.status, AiJobStatus.completed);
      expect(proposal['card_type'], 'suggestion');
      expect(proposal['title'], 'Goal detected: Learn LLM internals');
      expect(proposal['notification_eligible'], isFalse);
      expect(
        proposal['source_ids'],
        containsAll([
          'src_llm_inference',
          'src_attention',
          'src_llm_internals',
        ]),
      );
    },
  );

  test('job fails with clear error if model unavailable', () async {
    final harness = _ProcessorHarness(
      cactusModelService: _FakeCactusModelService(
        models: const [],
        textResponses: const [],
      ),
    );
    addTearDown(harness.close);
    await harness.createTextSource('src_text');
    await harness.createJob('job_missing_model', 'src_text');

    final processed = await harness.processNextAiJob(const NoParams());
    final job = await harness.aiJobRepository.getJobById('job_missing_model');

    expect(processed?.status, AiJobStatus.failed);
    expect(job?.errorMessage, contains('unavailable'));
  });

  test(
    'invalid text extraction output retries before local fallback',
    () async {
      final service = _FakeCactusModelService(
        textResponses: [
          'not json',
          '{"text":"still missing fields"}',
          jsonEncode(_validIntentionJson()),
        ],
      );
      final harness = _ProcessorHarness(cactusModelService: service);
      addTearDown(harness.close);
      await harness.createTextSource('src_text');
      await harness.createJob('job_invalid_json', 'src_text');

      final processed = await harness.processNextAiJob(const NoParams());
      final job = await harness.aiJobRepository.getJobById('job_invalid_json');
      final source = await harness.sourceRepository.getSourceById('src_text');

      expect(processed?.status, AiJobStatus.completed);
      expect(job?.errorMessage, isNull);
      expect(source?.extractedText, 'Please buy bread at 8pm');
      expect(source?.processingState, SourceProcessingState.completed);
      expect(service.textCompletionCount, 3);
    },
  );
}

Map<String, Object?> _validExtractionJson() {
  return {
    'text': 'Please buy bread at 8pm',
    'visible_entities': ['bread'],
    'dates': <String>[],
    'times': ['8pm'],
    'links': <String>[],
    'content_type': 'message',
    'language': 'en',
    'confidence': 0.92,
  };
}

Map<String, Object?> _validIntentionJson() {
  return {
    'intention_type': 'buy',
    'confidence': 0.88,
    'title': 'Buy bread',
    'reason': 'The saved message asks you to buy bread at 8pm.',
    'next_active_deadline': '2026-05-10T20:00:00+01:00',
    'suggested_card_type': 'urgent',
    'space_suggestion': 'Household Tasks',
    'source_summary': 'Message about buying bread',
    'evidence_summary': 'The source says: Please buy bread at 8pm.',
  };
}

Map<String, Object?> _validCardProposalJson() {
  return {
    'card_type': 'urgent',
    'title': 'Buy bread',
    'reason': 'The saved message asks you to buy bread at 8pm.',
    'space_name': 'Household Tasks',
    'next_active_deadline': '2026-05-10T20:00:00+01:00',
    'source_ids': ['src_text'],
    'actions': ['complete', 'snooze', 'cancel'],
    'confidence': 0.88,
  };
}

DateTime _fixedNow() => DateTime.utc(2026, 5, 10, 12);

SourceItemEntity _sourceEntity({
  required String id,
  required SourceItemType type,
  String? rawText,
  String? localFilePath,
}) {
  return SourceItemEntity(
    id: id,
    type: type,
    localFilePath: localFilePath,
    rawText: rawText,
    sourceSummary: 'Manual source',
    appSource: 'Manual',
    contentType: 'unknown',
    processingState: SourceProcessingState.saved,
    createdAt: _fixedNow().millisecondsSinceEpoch,
    updatedAt: _fixedNow().millisecondsSinceEpoch,
  );
}

class _ProcessorHarness {
  _ProcessorHarness({
    required CactusModelService cactusModelService,
    LocalNotificationService? notificationService,
  }) : database = TagDatabase.forTesting(NativeDatabase.memory()) {
    sourceRepository = SourceRepositoryImpl(
      localDataSource: DriftSourceLocalDataSource(database),
      now: _fixedNow,
    );
    aiJobRepository = AiJobRepositoryImpl(
      localDataSource: DriftAiJobLocalDataSource(database),
      now: _fixedNow,
    );
    processNextAiJob = ProcessNextAiJob(
      aiJobRepository: aiJobRepository,
      aiJobProcessor: CactusAiJobProcessor(
        aiOrchestrator: AiOrchestrator(
          cactusModelService: cactusModelService,
          now: _fixedNow,
        ),
        sourceRepository: sourceRepository,
        notificationService: notificationService,
        now: _fixedNow,
      ),
      sourceRepository: sourceRepository,
    );
  }

  final TagDatabase database;
  late final SourceRepository sourceRepository;
  late final AiJobRepository aiJobRepository;
  late final ProcessNextAiJob processNextAiJob;

  Future<void> createTextSource(String id) async {
    await sourceRepository.createSource(
      CreateSourceRequest(
        id: id,
        type: SourceItemType.text,
        rawText: 'Please buy bread at 8pm',
        sourceSummary: 'Manual text paste',
      ),
    );
  }

  Future<void> createJob(String id, String sourceId) async {
    await aiJobRepository.createJob(
      CreateAiJobRequest(
        id: id,
        jobType: AiJobType.extractSource,
        sourceId: sourceId,
        inputJson: jsonEncode({'source_id': sourceId}),
      ),
    );
  }

  Future<void> close() => database.close();
}

class _FakeCactusModelService implements CactusModelService {
  _FakeCactusModelService({
    required List<String> textResponses,
    List<String> imageResponses = const [],
    this.models = const [
      LocalAiModelInfo(
        slug: CactusModelRegistry.primaryVisionToolModelSlug,
        displayName: 'Gemma 4 E2B IT',
        capabilities: {
          AiModelCapability.completion,
          AiModelCapability.tools,
          AiModelCapability.vision,
        },
        isDownloaded: true,
        isInitialized: true,
      ),
    ],
  }) : _textResponses = [...textResponses],
       _imageResponses = [...imageResponses];

  final List<LocalAiModelInfo> models;
  final List<String> _textResponses;
  final List<String> _imageResponses;
  int textCompletionCount = 0;
  int visionCompletionCount = 0;
  List<AiChatMessage>? lastImageMessages;

  @override
  Future<List<LocalAiModelInfo>> getAvailableModels() async => models;

  @override
  Future<void> downloadModel(
    String slug, {
    void Function(ModelDownloadProgress progress)? onProgress,
  }) async {}

  @override
  Future<void> initializeModel(String slug) async {}

  @override
  Future<void> unloadModel(String slug) async {}

  @override
  Future<AiCompletionResult> complete({
    required String modelSlug,
    required List<AiChatMessage> messages,
    List<AiToolSchema> tools = const [],
    AiCompletionOptions options = const AiCompletionOptions(),
  }) async {
    textCompletionCount++;
    return AiCompletionResult(response: _textResponses.removeAt(0));
  }

  @override
  Stream<String> streamComplete({
    required String modelSlug,
    required List<AiChatMessage> messages,
    List<AiToolSchema> tools = const [],
    AiCompletionOptions options = const AiCompletionOptions(),
  }) {
    throw UnimplementedError();
  }

  @override
  Future<AiEmbeddingResult> embedText({
    required String modelSlug,
    required String text,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<AiVisionResult> completeWithImage({
    required String modelSlug,
    required String imagePath,
    required List<AiChatMessage> messages,
    List<AiToolSchema> tools = const [],
    AiCompletionOptions options = const AiCompletionOptions(),
  }) async {
    visionCompletionCount++;
    lastImageMessages = messages;
    return AiVisionResult(response: _imageResponses.removeAt(0));
  }
}

class _FakeLocalTextRecognitionService implements LocalTextRecognitionService {
  _FakeLocalTextRecognitionService(this.result);

  final LocalRecognizedText result;
  String? lastImagePath;

  @override
  Future<LocalRecognizedText> recognizeTextFromImage(String imagePath) async {
    lastImagePath = imagePath;
    return result;
  }
}

class _RecordingLocalNotificationService implements LocalNotificationService {
  final sourceFailures = <SourceProcessingFailureNotification>[];
  NotificationActionHandler? onAction;

  @override
  Future<void> initialize({NotificationActionHandler? onAction}) async {
    this.onAction = onAction;
  }

  @override
  Future<NotificationPermissionState> requestPermission() async {
    return NotificationPermissionState.granted;
  }

  @override
  Future<NotificationRequestEntity?> scheduleCardNotification(
    LocalNotificationCardSnapshot card,
  ) async {
    return null;
  }

  @override
  Future<void> cancelCardNotifications(String cardId) async {}

  @override
  Future<List<NotificationRequestEntity>> requestsForCard(String cardId) async {
    return const [];
  }

  @override
  Future<void> showSourceProcessingFailureNotification(
    SourceProcessingFailureNotification notification,
  ) async {
    sourceFailures.add(notification);
  }

  @override
  Future<void> handleActionPayload(NotificationActionPayload payload) async {
    await onAction?.call(payload);
  }
}
