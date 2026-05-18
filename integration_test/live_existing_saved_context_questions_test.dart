import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:tag/core/DI/di.dart';
import 'package:tag/core/config/app_config.dart';
import 'package:tag/core/local_storage/database/tag_database.dart';
import 'package:tag/features/chat/domain/use_cases/ask_saved_context.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets(
    'answers required saved-context questions from existing live imports',
    (tester) async {
      setUpAppLocator(appConfig: AppConfig(autoDownloadRequiredModels: false));

      final database = locator<TagDatabase>();
      final sourceCount =
          (await database.select(database.sourceItems).get()).length;
      final cardCount = (await database.select(database.tagCards).get()).length;
      final ragRecordCount =
          (await database.select(database.ragIndexRecords).get()).length;
      final askSavedContext = locator<AskSavedContext>();
      final transcript = <Map<String, Object?>>[];

      for (final question in _requiredQuestions) {
        final startedAt = DateTime.now();
        try {
          final result = await askSavedContext(
            AskSavedContextParams(query: question),
          );
          transcript.add({
            'question': question,
            'elapsed_ms': DateTime.now().difference(startedAt).inMilliseconds,
            'answer': result.answer.answer,
            'reasoning_summary': result.answer.reasoningSummary,
            'source_ids': result.answer.sourceIds,
            'card_ids': result.answer.cardIds,
            'citation_labels': result.answer.sourceCitations
                .map((citation) => citation.label)
                .toList(growable: false),
            'context_source_ids': result.contextResults
                .map((context) => context.source.id)
                .toList(growable: false),
            'raw_output': result.rawModelOutput,
            'bad_content_flags': _badContentFlags(
              answer: result.answer.answer,
              rawOutput: result.rawModelOutput,
            ),
          });
        } on Object catch (error, stackTrace) {
          transcript.add({
            'question': question,
            'elapsed_ms': DateTime.now().difference(startedAt).inMilliseconds,
            'error': error.toString(),
            'stack_tail': stackTrace.toString().split('\n').take(6).toList(),
          });
        }
      }

      final output = {
        'captured_at': DateTime.now().toIso8601String(),
        'source_count': sourceCount,
        'card_count': cardCount,
        'rag_record_count': ragRecordCount,
        'questions': transcript,
      };
      final documents = await getApplicationDocumentsDirectory();
      final outputDir = Directory(
        p.join(documents.path, 'live_existing_saved_context_questions'),
      );
      await outputDir.create(recursive: true);
      final outputFile = File(p.join(outputDir.path, 'chat_transcript.json'));
      await outputFile.writeAsString(
        const JsonEncoder.withIndent('  ').convert(output),
        flush: true,
      );
      binding.reportData ??= <String, dynamic>{};
      binding.reportData!['live_existing_saved_context_questions'] = output;
      // Keep this single-line for grep-friendly artifact capture.
      // ignore: avoid_print
      print('TAG_EXISTING_CHAT_TRANSCRIPT ${outputFile.path}');
      // ignore: avoid_print
      print('TAG_EXISTING_CHAT_RESULT ${jsonEncode(output)}');

      expect(sourceCount, greaterThanOrEqualTo(9));
      expect(cardCount, greaterThan(0));
      expect(ragRecordCount, greaterThan(0));
    },
    timeout: const Timeout(Duration(minutes: 45)),
  );
}

const _requiredQuestions = [
  'What UK company formation information have I saved?',
  'What LLM internals resources have I saved?',
  'What job applications do I need to follow up on?',
  'What personal reminders do I have this weekend?',
  'Why did you create the AI Saturdays card?',
  'Show me the source for my sister call reminder.',
  'What have I saved about attention?',
  'What should I do next for my saved learning resources?',
  'Do I have anything about cooking recipes?',
  'Create a reminder from my UK company source.',
];

List<String> _badContentFlags({
  required String answer,
  required String rawOutput,
}) {
  final flags = <String>[];
  final normalized = answer.toLowerCase();
  if (answer.trim().startsWith('{') || answer.trim().startsWith('[')) {
    flags.add('raw_json_answer');
  }
  if (normalized.contains('null') || normalized.contains('undefined')) {
    flags.add('null_or_undefined');
  }
  if (normalized.contains('stack trace') || normalized.contains('exception')) {
    flags.add('debug_trace_language');
  }
  if (normalized.contains('system prompt') ||
      normalized.contains('return exactly this json')) {
    flags.add('prompt_leakage');
  }
  if (rawOutput.trim().isEmpty) {
    flags.add('empty_raw_output');
  }
  return flags;
}
