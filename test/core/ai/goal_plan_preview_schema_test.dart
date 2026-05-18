import 'package:flutter_test/flutter_test.dart';
import 'package:tag/core/ai/schemas/goal_plan_preview_schema.dart';
import 'package:tag/core/ai/validation/ai_schema_validation_exception.dart';

void main() {
  test('validates a source-backed GoalPlanPreview', () {
    final preview =
        GoalPlanPreview.fromJson({
          'goal_name': 'Learn Rust',
          'space_name': 'Learn Rust',
          'duration_weeks': 4,
          'preferred_days': ['Saturday'],
          'cards': [
            {
              'title': 'Rust basics and ownership',
              'reason': 'Part of your Rust learning plan.',
              'scheduled_for': '2026-05-23T10:00:00+01:00',
              'source_ids': ['src_rust'],
            },
          ],
        }).validateForSourceBackedSuggestion(
          allowedSourceIds: {'src_rust'},
          expectedDurationWeeks: 4,
        );

    expect(preview.goalName, 'Learn Rust');
    expect(preview.cards.single.sourceIds, ['src_rust']);
  });

  test('rejects empty preview card lists', () {
    expect(
      () => GoalPlanPreview.fromJson({
        'goal_name': 'Learn Rust',
        'space_name': 'Learn Rust',
        'duration_weeks': 4,
        'preferred_days': ['Saturday'],
        'cards': <Map<String, Object?>>[],
      }),
      throwsA(isA<AiSchemaValidationException>()),
    );
  });

  test('rejects unknown source ids before pending confirmation is stored', () {
    final preview = GoalPlanPreview.fromJson({
      'goal_name': 'Learn Rust',
      'space_name': 'Learn Rust',
      'duration_weeks': 4,
      'preferred_days': ['Saturday'],
      'cards': [
        {
          'title': 'Rust basics and ownership',
          'reason': 'Part of your Rust learning plan.',
          'scheduled_for': '2026-05-23T10:00:00+01:00',
          'source_ids': ['src_other'],
        },
      ],
    });

    expect(
      () => preview.validateForSourceBackedSuggestion(
        allowedSourceIds: {'src_rust'},
        expectedDurationWeeks: 4,
      ),
      throwsA(isA<AiSchemaValidationException>()),
    );
  });
}
