import 'package:drift/drift.dart';
import 'package:tag/core/local_storage/database/tag_database.dart';

abstract interface class OnboardingLocalDataSource {
  Future<UserProfile?> loadUserProfile();

  Future<UserProfile> saveNickname(String nickname);

  Future<UserProfile> saveAvatar({
    required String avatarKind,
    required String avatarValue,
  });

  Future<UserProfile> saveNotificationPermissionState(String state);

  Future<UserProfile> completeOnboarding();
}

class DriftOnboardingLocalDataSource implements OnboardingLocalDataSource {
  const DriftOnboardingLocalDataSource(
    this._database, {
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  static const localUserId = 'local_user';
  static const defaultNickname = 'Friend';
  static const defaultAvatarKind = 'asset';
  static const defaultAvatarValue = 'memoji_02';

  final TagDatabase _database;
  final DateTime Function() _now;

  @override
  Future<UserProfile?> loadUserProfile() async {
    return (_database.select(
      _database.userProfiles,
    )..where((profile) => profile.id.equals(localUserId))).getSingleOrNull();
  }

  @override
  Future<UserProfile> saveNickname(String nickname) {
    final normalizedNickname = nickname.trim();
    if (normalizedNickname.isEmpty) {
      throw ArgumentError.value(nickname, 'nickname', 'Nickname is required.');
    }

    return _upsertProfile(nickname: normalizedNickname);
  }

  @override
  Future<UserProfile> saveAvatar({
    required String avatarKind,
    required String avatarValue,
  }) {
    if (avatarKind.trim().isEmpty || avatarValue.trim().isEmpty) {
      throw ArgumentError('Avatar kind and value are required.');
    }

    return _upsertProfile(
      avatarKind: avatarKind.trim(),
      avatarValue: avatarValue.trim(),
    );
  }

  @override
  Future<UserProfile> saveNotificationPermissionState(String state) {
    return _upsertProfile(notificationPermissionState: state);
  }

  @override
  Future<UserProfile> completeOnboarding() {
    final timestamp = _timestamp();

    return _upsertProfile(onboardingCompletedAt: Value(timestamp));
  }

  Future<UserProfile> _upsertProfile({
    String? nickname,
    String? avatarKind,
    String? avatarValue,
    String? notificationPermissionState,
    Value<int?> onboardingCompletedAt = const Value.absent(),
  }) async {
    final existing = await loadUserProfile();
    final timestamp = _timestamp();

    if (existing == null) {
      await _database
          .into(_database.userProfiles)
          .insert(
            UserProfilesCompanion.insert(
              id: localUserId,
              nickname: nickname ?? defaultNickname,
              avatarKind: avatarKind ?? defaultAvatarKind,
              avatarValue: avatarValue ?? defaultAvatarValue,
              onboardingCompletedAt: onboardingCompletedAt,
              notificationPermissionState: Value(
                notificationPermissionState ?? 'unknown',
              ),
              createdAt: timestamp,
              updatedAt: timestamp,
            ),
          );
    } else {
      await (_database.update(
        _database.userProfiles,
      )..where((profile) => profile.id.equals(localUserId))).write(
        UserProfilesCompanion(
          nickname: nickname == null ? const Value.absent() : Value(nickname),
          avatarKind: avatarKind == null
              ? const Value.absent()
              : Value(avatarKind),
          avatarValue: avatarValue == null
              ? const Value.absent()
              : Value(avatarValue),
          onboardingCompletedAt: onboardingCompletedAt,
          notificationPermissionState: notificationPermissionState == null
              ? const Value.absent()
              : Value(notificationPermissionState),
          updatedAt: Value(timestamp),
        ),
      );
    }

    return (await loadUserProfile())!;
  }

  int _timestamp() => _now().toUtc().millisecondsSinceEpoch;
}
