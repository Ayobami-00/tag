// ignore_for_file: recursive_getters

import 'package:drift/drift.dart';
import 'package:tag/core/local_storage/database/database_values.dart';
import 'package:tag/core/local_storage/database/tables/spaces_table.dart';

@TableIndex(name: 'idx_tag_cards_status', columns: {#status})
@TableIndex(name: 'idx_tag_cards_card_type', columns: {#cardType})
@TableIndex(name: 'idx_tag_cards_space_id', columns: {#spaceId})
@TableIndex(
  name: 'idx_tag_cards_next_active_deadline',
  columns: {#nextActiveDeadline},
)
@TableIndex(
  name: 'idx_tag_cards_status_deadline',
  columns: {#status, #nextActiveDeadline},
)
@TableIndex(
  name: 'idx_tag_cards_type_status_deadline',
  columns: {#cardType, #status, #nextActiveDeadline},
)
class TagCards extends Table {
  @override
  String get tableName => 'tag_cards';

  TextColumn get id => text()();
  TextColumn get cardType =>
      text().check(cardType.isIn(TagDatabaseValues.cardTypes))();
  TextColumn get status => text()
      .check(status.isIn(TagDatabaseValues.cardStatuses))
      .withDefault(const Constant('active'))();
  TextColumn get title => text()();
  TextColumn get reason => text()();
  TextColumn get spaceId => text().references(Spaces, #id)();
  IntColumn get nextActiveDeadline => integer().nullable()();
  TextColumn get deadlineTimezone => text().nullable()();
  IntColumn get snoozedUntil => integer().nullable()();
  BoolColumn get notificationEnabled =>
      boolean().withDefault(const Constant(false))();
  TextColumn get actionsJson => text().withDefault(const Constant('[]'))();
  RealColumn get confidence => real().nullable()();
  TextColumn get sourceSummary => text()();
  TextColumn get evidenceSummary => text()();
  TextColumn get parentGoalPlanId => text().nullable()();
  TextColumn get suggestionClusterId => text().nullable()();
  TextColumn get createdBy =>
      text().check(createdBy.isIn(TagDatabaseValues.cardCreatedBy))();
  TextColumn get modelSlug => text().nullable()();
  TextColumn get modelOutputJson => text().nullable()();
  TextColumn get metadataJson => text().withDefault(const Constant('{}'))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get completedAt => integer().nullable()();
  IntColumn get cancelledAt => integer().nullable()();
  IntColumn get dismissedAt => integer().nullable()();
  IntColumn get archivedAt => integer().nullable()();
  IntColumn get deletedAt => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK (confidence IS NULL OR (confidence >= 0.0 AND confidence <= 1.0))',
    "CHECK (card_type != 'suggestion' OR notification_enabled = 0)",
    "CHECK (status NOT IN ('completed', 'cancelled', 'dismissed', 'archived') "
        'OR notification_enabled = 0)',
  ];
}
