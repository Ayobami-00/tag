import 'dart:io';

import 'package:drift/drift.dart' show Value, driftRuntimeOptions, innerJoin;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:tag/core/local_storage/database/data_sources/card_local_data_source.dart';
import 'package:tag/core/local_storage/database/database_health_check.dart';
import 'package:tag/core/local_storage/database/tag_database.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late TagDatabase database;

  setUp(() {
    database = TagDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  test('database opens and exposes the current schema version', () async {
    final result = await database.customSelect('SELECT 1 AS ok').getSingle();

    expect(result.read<int>('ok'), 1);
    expect(database.schemaVersion, TagDatabase.currentSchemaVersion);
  });

  test('migration from an empty database creates every MVP table', () async {
    final tempDirectory = await Directory.systemTemp.createTemp(
      'tag_database_test_',
    );
    final file = File(p.join(tempDirectory.path, 'tag.sqlite'));
    final migratedDatabase = TagDatabase.forTesting(NativeDatabase(file));

    addTearDown(() async {
      await migratedDatabase.close();
      await tempDirectory.delete(recursive: true);
    });

    final tables = await migratedDatabase.listUserTables();

    expect(tables, containsAll(TagDatabase.appTableNames));
    expect(migratedDatabase.schemaVersion, TagDatabase.currentSchemaVersion);
  });

  test('database health check reports healthy after opening', () async {
    final healthCheck = DriftDatabaseHealthCheck(database);

    final status = await healthCheck.check();

    expect(status.isHealthy, isTrue);
    expect(status.schemaVersion, TagDatabase.currentSchemaVersion);
    expect(status.tableNames, containsAll(TagDatabase.appTableNames));
  });

  test('inserts and reads a UserProfile', () async {
    final now = _now();

    await database
        .into(database.userProfiles)
        .insert(
          UserProfilesCompanion.insert(
            id: 'local_user',
            nickname: 'Alex',
            avatarKind: 'emoji',
            avatarValue: ':)',
            createdAt: now,
            updatedAt: now,
          ),
        );

    final profile = await database.select(database.userProfiles).getSingle();

    expect(profile.id, 'local_user');
    expect(profile.localOnly, isTrue);
    expect(profile.notificationPermissionState, 'unknown');
  });

  test('inserts and reads a SourceItem', () async {
    final source = await _insertSource(database);

    expect(source.id, 'src_001');
    expect(source.type, 'screenshot');
    expect(source.processingState, 'saved');
    expect(source.deletedAt, isNull);
  });

  test('inserts and reads a Space', () async {
    final space = await _insertSpace(database);

    expect(space.id, 'space_household');
    expect(space.name, 'Household Tasks');
    expect(space.type, 'specific');
  });

  test('inserts and reads a TagCard with a primary Space', () async {
    await _insertSpace(database);
    final card = await _insertCard(database);

    expect(card.id, 'card_bread');
    expect(card.cardType, 'urgent');
    expect(card.status, 'active');
    expect(card.spaceId, 'space_household');
  });

  test('joins TagCard to SourceItem through card_sources', () async {
    await _insertSource(database);
    await _insertSpace(database);
    await _insertCardWithSource(database);

    final rows = await database.select(database.tagCards).join([
      innerJoin(
        database.cardSources,
        database.cardSources.cardId.equalsExp(database.tagCards.id),
      ),
      innerJoin(
        database.sourceItems,
        database.sourceItems.id.equalsExp(database.cardSources.sourceId),
      ),
    ]).get();

    final card = rows.single.readTable(database.tagCards);
    final source = rows.single.readTable(database.sourceItems);
    final evidence = rows.single.readTable(database.cardSources);

    expect(card.title, 'Buy bread at 8pm');
    expect(source.sourceSummary, 'WhatsApp screenshot');
    expect(evidence.role, 'primary');
  });

  test('inserts a FeedbackEvent locally', () async {
    await _insertSource(database);
    await _insertSpace(database);
    await _insertCardWithSource(database);
    final now = _now();

    await database
        .into(database.feedbackEvents)
        .insert(
          FeedbackEventsCompanion.insert(
            id: 'fb_001',
            eventType: 'complete',
            cardId: const Value('card_bread'),
            spaceId: const Value('space_household'),
            sourceId: const Value('src_001'),
            detailsJson: const Value('{"origin":"test"}'),
            createdAt: now,
          ),
        );

    final event = await database.select(database.feedbackEvents).getSingle();

    expect(event.eventType, 'complete');
    expect(event.cardId, 'card_bread');
    expect(event.detailsJson, contains('origin'));
  });

  test('inserts an AiProcessingJob for resumable local work', () async {
    await _insertSource(database);
    final now = _now();

    await database
        .into(database.aiProcessingJobs)
        .insert(
          AiProcessingJobsCompanion.insert(
            id: 'job_001',
            jobType: 'extract_source',
            status: 'queued',
            sourceId: const Value('src_001'),
            inputJson: const Value('{"source_id":"src_001"}'),
            queuedAt: now,
            updatedAt: now,
          ),
        );

    final job = await database.select(database.aiProcessingJobs).getSingle();

    expect(job.jobType, 'extract_source');
    expect(job.status, 'queued');
    expect(job.attemptCount, 0);
    expect(job.maxAttempts, 3);
  });

  test('prevents Suggestion Cards from enabling notifications', () async {
    await _insertSpace(database);

    await expectLater(
      database
          .into(database.tagCards)
          .insert(
            _cardCompanion(
              id: 'card_suggestion',
              cardType: 'suggestion',
              notificationEnabled: true,
            ),
          ),
      throwsA(isA<Exception>()),
    );
  });

  test('prevents inactive cards from keeping notifications enabled', () async {
    await _insertSpace(database);

    await expectLater(
      database
          .into(database.tagCards)
          .insert(
            _cardCompanion(
              id: 'card_done',
              status: 'completed',
              notificationEnabled: true,
            ),
          ),
      throwsA(isA<Exception>()),
    );
  });

  test('card data source requires source evidence for card creation', () async {
    await _insertSpace(database);
    final dataSource = DriftCardLocalDataSource(database);

    await expectLater(
      dataSource.insertCardWithSources(
        card: _cardCompanion(),
        sources: const [],
      ),
      throwsArgumentError,
    );
  });

  test(
    'card data source creates a card and its source link together',
    () async {
      await _insertSource(database);
      await _insertSpace(database);
      final dataSource = DriftCardLocalDataSource(database);

      await dataSource.insertCardWithSources(
        card: _cardCompanion(),
        sources: [
          CardSourcesCompanion.insert(
            cardId: 'card_bread',
            sourceId: 'src_001',
            role: 'primary',
            evidenceText: const Value('Please buy bread at 8pm'),
            createdAt: _now(),
          ),
        ],
      );

      expect(await database.select(database.tagCards).get(), hasLength(1));
      expect(await database.select(database.cardSources).get(), hasLength(1));
    },
  );
}

int _now() => DateTime.utc(2026, 5, 8, 12).millisecondsSinceEpoch;

Future<SourceItem> _insertSource(TagDatabase database) async {
  final now = _now();

  await database
      .into(database.sourceItems)
      .insert(
        SourceItemsCompanion.insert(
          id: 'src_001',
          type: 'screenshot',
          sourceSummary: const Value('WhatsApp screenshot'),
          appSource: const Value('WhatsApp'),
          contentType: const Value('message'),
          rawText: const Value('Please buy bread at 8pm'),
          extractedText: const Value('Please buy bread at 8pm'),
          createdAt: now,
          updatedAt: now,
        ),
      );

  return database.select(database.sourceItems).getSingle();
}

Future<Space> _insertSpace(TagDatabase database) async {
  final now = _now();

  await database
      .into(database.spaces)
      .insert(
        SpacesCompanion.insert(
          id: 'space_household',
          name: 'Household Tasks',
          normalizedName: 'household tasks',
          type: 'specific',
          description: const Value('Household reminders and errands.'),
          primaryIntentionType: const Value('buy'),
          createdBy: 'user',
          createdAt: now,
          updatedAt: now,
        ),
      );

  return database.select(database.spaces).getSingle();
}

Future<TagCard> _insertCard(TagDatabase database) async {
  await database.into(database.tagCards).insert(_cardCompanion());

  return database.select(database.tagCards).getSingle();
}

Future<void> _insertCardWithSource(TagDatabase database) async {
  final dataSource = DriftCardLocalDataSource(database);

  await dataSource.insertCardWithSources(
    card: _cardCompanion(),
    sources: [
      CardSourcesCompanion.insert(
        cardId: 'card_bread',
        sourceId: 'src_001',
        role: 'primary',
        evidenceText: const Value('Please buy bread at 8pm'),
        createdAt: _now(),
      ),
    ],
  );
}

TagCardsCompanion _cardCompanion({
  String id = 'card_bread',
  String cardType = 'urgent',
  String status = 'active',
  bool notificationEnabled = false,
}) {
  final now = _now();

  return TagCardsCompanion.insert(
    id: id,
    cardType: cardType,
    status: Value(status),
    title: 'Buy bread at 8pm',
    reason: 'Detected from a message screenshot.',
    spaceId: 'space_household',
    nextActiveDeadline: Value(now + const Duration(hours: 8).inMilliseconds),
    deadlineTimezone: const Value('Europe/London'),
    notificationEnabled: Value(notificationEnabled),
    actionsJson: const Value('["complete","snooze","cancel"]'),
    sourceSummary: 'WhatsApp screenshot',
    evidenceSummary: 'The screenshot asks for bread by 8pm.',
    createdBy: 'ai',
    createdAt: now,
    updatedAt: now,
  );
}
