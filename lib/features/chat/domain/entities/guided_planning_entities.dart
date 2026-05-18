import 'package:equatable/equatable.dart';
import 'package:tag/core/ai/schemas/goal_plan_preview_schema.dart';
import 'package:tag/features/chat/domain/entities/chat_entities.dart';

enum PlanStyleChoice {
  weekend('weekend', 'Weekend plan', 1),
  fourWeek('four_week', '4-week plan', 4),
  lightReading('light_reading', 'Light reading only', 4),
  custom('custom', 'Custom', null);

  const PlanStyleChoice(this.storageValue, this.label, this.durationWeeks);

  final String storageValue;
  final String label;
  final int? durationWeeks;

  static PlanStyleChoice fromStorageValue(String value) {
    return PlanStyleChoice.values.firstWhere(
      (choice) => choice.storageValue == value,
      orElse: () => PlanStyleChoice.custom,
    );
  }
}

enum WeeklyTimeChoice {
  oneHour('one_hour', '1 hour', 60),
  threeHours('three_hours', '3 hours', 180),
  fiveHours('five_hours', '5 hours', 300),
  custom('custom', 'Custom', null);

  const WeeklyTimeChoice(this.storageValue, this.label, this.minutes);

  final String storageValue;
  final String label;
  final int? minutes;

  static WeeklyTimeChoice fromStorageValue(String value) {
    return WeeklyTimeChoice.values.firstWhere(
      (choice) => choice.storageValue == value,
      orElse: () => WeeklyTimeChoice.custom,
    );
  }
}

class GenerateGoalPlanPreviewResult extends Equatable {
  const GenerateGoalPlanPreviewResult({
    required this.preview,
    required this.pendingConfirmationJson,
    required this.updatedSession,
    required this.modelSlug,
    required this.rawModelOutput,
  });

  final GoalPlanPreview preview;
  final String pendingConfirmationJson;
  final ChatSessionEntity updatedSession;
  final String modelSlug;
  final String rawModelOutput;

  @override
  List<Object?> get props => [
    preview,
    pendingConfirmationJson,
    updatedSession,
    modelSlug,
    rawModelOutput,
  ];
}
