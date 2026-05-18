import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tag/core/local_storage/database/tag_database.dart';
import 'package:tag/core/notifications/local_notification_permission_service.dart';
import 'package:tag/features/onboarding/data/data_sources/onboarding_local_data_source.dart';
import 'package:tag/features/onboarding/data/repositories/onboarding_repository_impl.dart';

void main() {
  late TagDatabase database;
  late _FakeNotificationPermissionService permissionService;
  late OnboardingRepositoryImpl repository;

  setUp(() {
    database = TagDatabase.forTesting(NativeDatabase.memory());
    permissionService = _FakeNotificationPermissionService();
    repository = OnboardingRepositoryImpl(
      localDataSource: DriftOnboardingLocalDataSource(
        database,
        now: () => DateTime.utc(2026, 5, 9, 10),
      ),
      notificationPermissionService: permissionService,
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('returns null when no local user profile exists', () async {
    expect(await repository.loadUserProfile(), isNull);
  });

  test('persists nickname and avatar on the local_user profile', () async {
    await repository.saveNickname('  Alex  ');
    final profile = await repository.saveAvatar(
      avatarKind: 'emoji',
      avatarValue: '🧭',
    );

    expect(profile.id, DriftOnboardingLocalDataSource.localUserId);
    expect(profile.nickname, 'Alex');
    expect(profile.avatarKind, 'emoji');
    expect(profile.avatarValue, '🧭');
    expect(profile.localOnly, isTrue);

    final storedProfile = await database
        .select(database.userProfiles)
        .getSingle();
    expect(storedProfile.id, 'local_user');
    expect(storedProfile.nickname, 'Alex');
    expect(storedProfile.avatarValue, '🧭');
  });

  test('stores granted notification permission after a request', () async {
    permissionService.nextState = NotificationPermissionState.granted;
    await repository.saveNickname('Alex');

    final profile = await repository.requestNotificationPermission();

    expect(permissionService.requestCount, 1);
    expect(
      profile.notificationPermissionState,
      NotificationPermissionState.granted,
    );
    expect(
      (await database.select(database.userProfiles).getSingle())
          .notificationPermissionState,
      'granted',
    );
  });

  test('can skip notification permission without a platform request', () async {
    await repository.saveNickname('Alex');

    final profile = await repository.skipNotificationPermission();

    expect(permissionService.requestCount, 0);
    expect(
      profile.notificationPermissionState,
      NotificationPermissionState.unknown,
    );
    expect(
      (await database.select(database.userProfiles).getSingle())
          .notificationPermissionState,
      'unknown',
    );
  });

  test('marks onboarding completed locally', () async {
    await repository.saveNickname('Alex');
    await repository.saveAvatar(avatarKind: 'emoji', avatarValue: '✨');

    final profile = await repository.completeOnboarding();

    expect(profile.isOnboardingComplete, isTrue);
    expect(profile.onboardingCompletedAt, isNotNull);

    final storedProfile = await database
        .select(database.userProfiles)
        .getSingle();
    expect(storedProfile.onboardingCompletedAt, isNotNull);
  });

  test('database rejects a non-local profile', () async {
    await expectLater(
      database
          .into(database.userProfiles)
          .insert(
            UserProfilesCompanion.insert(
              id: 'local_user',
              nickname: 'Alex',
              avatarKind: 'emoji',
              avatarValue: '✨',
              localOnly: const Value(false),
              createdAt: 1,
              updatedAt: 1,
            ),
          ),
      throwsA(isA<Exception>()),
    );
  });
}

class _FakeNotificationPermissionService
    implements LocalNotificationPermissionService {
  NotificationPermissionState nextState = NotificationPermissionState.denied;
  int requestCount = 0;

  @override
  Future<NotificationPermissionState> requestPermission() async {
    requestCount += 1;
    return nextState;
  }
}
