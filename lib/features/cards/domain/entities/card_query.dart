import 'package:equatable/equatable.dart';

enum TodayViewMode {
  today('Today'),
  tomorrow('Tomorrow'),
  thisWeek('This Week'),
  all('All'),
  spaces('Spaces');

  const TodayViewMode(this.label);

  final String label;
}

enum TodayCardFilter {
  all('All'),
  processing('Processing'),
  urgent('Urgent'),
  goal('Goal'),
  suggestion('Suggestion'),
  completed('Completed'),
  snoozed('Snoozed'),
  cancelled('Cancelled');

  const TodayCardFilter(this.label);

  final String label;
}

class CardListQuery extends Equatable {
  const CardListQuery({
    required this.viewMode,
    required this.filter,
    required this.now,
  });

  final TodayViewMode viewMode;
  final TodayCardFilter filter;
  final DateTime now;

  @override
  List<Object?> get props => [viewMode, filter, now];
}
