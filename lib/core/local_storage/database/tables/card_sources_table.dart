// ignore_for_file: recursive_getters

import 'package:drift/drift.dart';
import 'package:tag/core/local_storage/database/database_values.dart';
import 'package:tag/core/local_storage/database/tables/source_items_table.dart';
import 'package:tag/core/local_storage/database/tables/tag_cards_table.dart';

@TableIndex(name: 'idx_card_sources_card_id', columns: {#cardId})
@TableIndex(name: 'idx_card_sources_source_id', columns: {#sourceId})
class CardSources extends Table {
  @override
  String get tableName => 'card_sources';

  TextColumn get cardId => text().references(TagCards, #id)();
  TextColumn get sourceId => text().references(SourceItems, #id)();
  TextColumn get role =>
      text().check(role.isIn(TagDatabaseValues.cardSourceRoles))();
  TextColumn get evidenceText => text().nullable()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {cardId, sourceId};
}
