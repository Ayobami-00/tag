// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag_database.dart';

// ignore_for_file: type=lint
class $UserProfilesTable extends UserProfiles
    with TableInfo<$UserProfilesTable, UserProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nicknameMeta = const VerificationMeta(
    'nickname',
  );
  @override
  late final GeneratedColumn<String> nickname = GeneratedColumn<String>(
    'nickname',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avatarKindMeta = const VerificationMeta(
    'avatarKind',
  );
  @override
  late final GeneratedColumn<String> avatarKind = GeneratedColumn<String>(
    'avatar_kind',
    aliasedName,
    false,
    check: () => avatarKind.isIn(TagDatabaseValues.avatarKinds),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avatarValueMeta = const VerificationMeta(
    'avatarValue',
  );
  @override
  late final GeneratedColumn<String> avatarValue = GeneratedColumn<String>(
    'avatar_value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localOnlyMeta = const VerificationMeta(
    'localOnly',
  );
  @override
  late final GeneratedColumn<bool> localOnly = GeneratedColumn<bool>(
    'local_only',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("local_only" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _onboardingCompletedAtMeta =
      const VerificationMeta('onboardingCompletedAt');
  @override
  late final GeneratedColumn<int> onboardingCompletedAt = GeneratedColumn<int>(
    'onboarding_completed_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notificationPermissionStateMeta =
      const VerificationMeta('notificationPermissionState');
  @override
  late final GeneratedColumn<String> notificationPermissionState =
      GeneratedColumn<String>(
        'notification_permission_state',
        aliasedName,
        false,
        check: () => notificationPermissionState.isIn(
          TagDatabaseValues.notificationPermissionStates,
        ),
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('unknown'),
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nickname,
    avatarKind,
    avatarValue,
    localOnly,
    onboardingCompletedAt,
    notificationPermissionState,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('nickname')) {
      context.handle(
        _nicknameMeta,
        nickname.isAcceptableOrUnknown(data['nickname']!, _nicknameMeta),
      );
    } else if (isInserting) {
      context.missing(_nicknameMeta);
    }
    if (data.containsKey('avatar_kind')) {
      context.handle(
        _avatarKindMeta,
        avatarKind.isAcceptableOrUnknown(data['avatar_kind']!, _avatarKindMeta),
      );
    } else if (isInserting) {
      context.missing(_avatarKindMeta);
    }
    if (data.containsKey('avatar_value')) {
      context.handle(
        _avatarValueMeta,
        avatarValue.isAcceptableOrUnknown(
          data['avatar_value']!,
          _avatarValueMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_avatarValueMeta);
    }
    if (data.containsKey('local_only')) {
      context.handle(
        _localOnlyMeta,
        localOnly.isAcceptableOrUnknown(data['local_only']!, _localOnlyMeta),
      );
    }
    if (data.containsKey('onboarding_completed_at')) {
      context.handle(
        _onboardingCompletedAtMeta,
        onboardingCompletedAt.isAcceptableOrUnknown(
          data['onboarding_completed_at']!,
          _onboardingCompletedAtMeta,
        ),
      );
    }
    if (data.containsKey('notification_permission_state')) {
      context.handle(
        _notificationPermissionStateMeta,
        notificationPermissionState.isAcceptableOrUnknown(
          data['notification_permission_state']!,
          _notificationPermissionStateMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProfile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      nickname: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nickname'],
      )!,
      avatarKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_kind'],
      )!,
      avatarValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_value'],
      )!,
      localOnly: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}local_only'],
      )!,
      onboardingCompletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}onboarding_completed_at'],
      ),
      notificationPermissionState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notification_permission_state'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $UserProfilesTable createAlias(String alias) {
    return $UserProfilesTable(attachedDatabase, alias);
  }
}

class UserProfile extends DataClass implements Insertable<UserProfile> {
  final String id;
  final String nickname;
  final String avatarKind;
  final String avatarValue;
  final bool localOnly;
  final int? onboardingCompletedAt;
  final String notificationPermissionState;
  final int createdAt;
  final int updatedAt;
  const UserProfile({
    required this.id,
    required this.nickname,
    required this.avatarKind,
    required this.avatarValue,
    required this.localOnly,
    this.onboardingCompletedAt,
    required this.notificationPermissionState,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['nickname'] = Variable<String>(nickname);
    map['avatar_kind'] = Variable<String>(avatarKind);
    map['avatar_value'] = Variable<String>(avatarValue);
    map['local_only'] = Variable<bool>(localOnly);
    if (!nullToAbsent || onboardingCompletedAt != null) {
      map['onboarding_completed_at'] = Variable<int>(onboardingCompletedAt);
    }
    map['notification_permission_state'] = Variable<String>(
      notificationPermissionState,
    );
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  UserProfilesCompanion toCompanion(bool nullToAbsent) {
    return UserProfilesCompanion(
      id: Value(id),
      nickname: Value(nickname),
      avatarKind: Value(avatarKind),
      avatarValue: Value(avatarValue),
      localOnly: Value(localOnly),
      onboardingCompletedAt: onboardingCompletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(onboardingCompletedAt),
      notificationPermissionState: Value(notificationPermissionState),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory UserProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProfile(
      id: serializer.fromJson<String>(json['id']),
      nickname: serializer.fromJson<String>(json['nickname']),
      avatarKind: serializer.fromJson<String>(json['avatarKind']),
      avatarValue: serializer.fromJson<String>(json['avatarValue']),
      localOnly: serializer.fromJson<bool>(json['localOnly']),
      onboardingCompletedAt: serializer.fromJson<int?>(
        json['onboardingCompletedAt'],
      ),
      notificationPermissionState: serializer.fromJson<String>(
        json['notificationPermissionState'],
      ),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'nickname': serializer.toJson<String>(nickname),
      'avatarKind': serializer.toJson<String>(avatarKind),
      'avatarValue': serializer.toJson<String>(avatarValue),
      'localOnly': serializer.toJson<bool>(localOnly),
      'onboardingCompletedAt': serializer.toJson<int?>(onboardingCompletedAt),
      'notificationPermissionState': serializer.toJson<String>(
        notificationPermissionState,
      ),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  UserProfile copyWith({
    String? id,
    String? nickname,
    String? avatarKind,
    String? avatarValue,
    bool? localOnly,
    Value<int?> onboardingCompletedAt = const Value.absent(),
    String? notificationPermissionState,
    int? createdAt,
    int? updatedAt,
  }) => UserProfile(
    id: id ?? this.id,
    nickname: nickname ?? this.nickname,
    avatarKind: avatarKind ?? this.avatarKind,
    avatarValue: avatarValue ?? this.avatarValue,
    localOnly: localOnly ?? this.localOnly,
    onboardingCompletedAt: onboardingCompletedAt.present
        ? onboardingCompletedAt.value
        : this.onboardingCompletedAt,
    notificationPermissionState:
        notificationPermissionState ?? this.notificationPermissionState,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  UserProfile copyWithCompanion(UserProfilesCompanion data) {
    return UserProfile(
      id: data.id.present ? data.id.value : this.id,
      nickname: data.nickname.present ? data.nickname.value : this.nickname,
      avatarKind: data.avatarKind.present
          ? data.avatarKind.value
          : this.avatarKind,
      avatarValue: data.avatarValue.present
          ? data.avatarValue.value
          : this.avatarValue,
      localOnly: data.localOnly.present ? data.localOnly.value : this.localOnly,
      onboardingCompletedAt: data.onboardingCompletedAt.present
          ? data.onboardingCompletedAt.value
          : this.onboardingCompletedAt,
      notificationPermissionState: data.notificationPermissionState.present
          ? data.notificationPermissionState.value
          : this.notificationPermissionState,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProfile(')
          ..write('id: $id, ')
          ..write('nickname: $nickname, ')
          ..write('avatarKind: $avatarKind, ')
          ..write('avatarValue: $avatarValue, ')
          ..write('localOnly: $localOnly, ')
          ..write('onboardingCompletedAt: $onboardingCompletedAt, ')
          ..write('notificationPermissionState: $notificationPermissionState, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    nickname,
    avatarKind,
    avatarValue,
    localOnly,
    onboardingCompletedAt,
    notificationPermissionState,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProfile &&
          other.id == this.id &&
          other.nickname == this.nickname &&
          other.avatarKind == this.avatarKind &&
          other.avatarValue == this.avatarValue &&
          other.localOnly == this.localOnly &&
          other.onboardingCompletedAt == this.onboardingCompletedAt &&
          other.notificationPermissionState ==
              this.notificationPermissionState &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class UserProfilesCompanion extends UpdateCompanion<UserProfile> {
  final Value<String> id;
  final Value<String> nickname;
  final Value<String> avatarKind;
  final Value<String> avatarValue;
  final Value<bool> localOnly;
  final Value<int?> onboardingCompletedAt;
  final Value<String> notificationPermissionState;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const UserProfilesCompanion({
    this.id = const Value.absent(),
    this.nickname = const Value.absent(),
    this.avatarKind = const Value.absent(),
    this.avatarValue = const Value.absent(),
    this.localOnly = const Value.absent(),
    this.onboardingCompletedAt = const Value.absent(),
    this.notificationPermissionState = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserProfilesCompanion.insert({
    required String id,
    required String nickname,
    required String avatarKind,
    required String avatarValue,
    this.localOnly = const Value.absent(),
    this.onboardingCompletedAt = const Value.absent(),
    this.notificationPermissionState = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       nickname = Value(nickname),
       avatarKind = Value(avatarKind),
       avatarValue = Value(avatarValue),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<UserProfile> custom({
    Expression<String>? id,
    Expression<String>? nickname,
    Expression<String>? avatarKind,
    Expression<String>? avatarValue,
    Expression<bool>? localOnly,
    Expression<int>? onboardingCompletedAt,
    Expression<String>? notificationPermissionState,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nickname != null) 'nickname': nickname,
      if (avatarKind != null) 'avatar_kind': avatarKind,
      if (avatarValue != null) 'avatar_value': avatarValue,
      if (localOnly != null) 'local_only': localOnly,
      if (onboardingCompletedAt != null)
        'onboarding_completed_at': onboardingCompletedAt,
      if (notificationPermissionState != null)
        'notification_permission_state': notificationPermissionState,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserProfilesCompanion copyWith({
    Value<String>? id,
    Value<String>? nickname,
    Value<String>? avatarKind,
    Value<String>? avatarValue,
    Value<bool>? localOnly,
    Value<int?>? onboardingCompletedAt,
    Value<String>? notificationPermissionState,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return UserProfilesCompanion(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      avatarKind: avatarKind ?? this.avatarKind,
      avatarValue: avatarValue ?? this.avatarValue,
      localOnly: localOnly ?? this.localOnly,
      onboardingCompletedAt:
          onboardingCompletedAt ?? this.onboardingCompletedAt,
      notificationPermissionState:
          notificationPermissionState ?? this.notificationPermissionState,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (nickname.present) {
      map['nickname'] = Variable<String>(nickname.value);
    }
    if (avatarKind.present) {
      map['avatar_kind'] = Variable<String>(avatarKind.value);
    }
    if (avatarValue.present) {
      map['avatar_value'] = Variable<String>(avatarValue.value);
    }
    if (localOnly.present) {
      map['local_only'] = Variable<bool>(localOnly.value);
    }
    if (onboardingCompletedAt.present) {
      map['onboarding_completed_at'] = Variable<int>(
        onboardingCompletedAt.value,
      );
    }
    if (notificationPermissionState.present) {
      map['notification_permission_state'] = Variable<String>(
        notificationPermissionState.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProfilesCompanion(')
          ..write('id: $id, ')
          ..write('nickname: $nickname, ')
          ..write('avatarKind: $avatarKind, ')
          ..write('avatarValue: $avatarValue, ')
          ..write('localOnly: $localOnly, ')
          ..write('onboardingCompletedAt: $onboardingCompletedAt, ')
          ..write('notificationPermissionState: $notificationPermissionState, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueJsonMeta = const VerificationMeta(
    'valueJson',
  );
  @override
  late final GeneratedColumn<String> valueJson = GeneratedColumn<String>(
    'value_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, valueJson, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value_json')) {
      context.handle(
        _valueJsonMeta,
        valueJson.isAcceptableOrUnknown(data['value_json']!, _valueJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_valueJsonMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      valueJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value_json'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String valueJson;
  final int updatedAt;
  const AppSetting({
    required this.key,
    required this.valueJson,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value_json'] = Variable<String>(valueJson);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      key: Value(key),
      valueJson: Value(valueJson),
      updatedAt: Value(updatedAt),
    );
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      valueJson: serializer.fromJson<String>(json['valueJson']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'valueJson': serializer.toJson<String>(valueJson),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  AppSetting copyWith({String? key, String? valueJson, int? updatedAt}) =>
      AppSetting(
        key: key ?? this.key,
        valueJson: valueJson ?? this.valueJson,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      valueJson: data.valueJson.present ? data.valueJson.value : this.valueJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('valueJson: $valueJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, valueJson, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.key == this.key &&
          other.valueJson == this.valueJson &&
          other.updatedAt == this.updatedAt);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String> valueJson;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.valueJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String valueJson,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       valueJson = Value(valueJson),
       updatedAt = Value(updatedAt);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<String>? valueJson,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (valueJson != null) 'value_json': valueJson,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? valueJson,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      valueJson: valueJson ?? this.valueJson,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (valueJson.present) {
      map['value_json'] = Variable<String>(valueJson.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('valueJson: $valueJson, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SourceItemsTable extends SourceItems
    with TableInfo<$SourceItemsTable, SourceItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SourceItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    check: () => type.isIn(TagDatabaseValues.sourceTypes),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originalUriMeta = const VerificationMeta(
    'originalUri',
  );
  @override
  late final GeneratedColumn<String> originalUri = GeneratedColumn<String>(
    'original_uri',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localFilePathMeta = const VerificationMeta(
    'localFilePath',
  );
  @override
  late final GeneratedColumn<String> localFilePath = GeneratedColumn<String>(
    'local_file_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _thumbnailFilePathMeta = const VerificationMeta(
    'thumbnailFilePath',
  );
  @override
  late final GeneratedColumn<String> thumbnailFilePath =
      GeneratedColumn<String>(
        'thumbnail_file_path',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _rawTextMeta = const VerificationMeta(
    'rawText',
  );
  @override
  late final GeneratedColumn<String> rawText = GeneratedColumn<String>(
    'raw_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _extractedTextMeta = const VerificationMeta(
    'extractedText',
  );
  @override
  late final GeneratedColumn<String> extractedText = GeneratedColumn<String>(
    'extracted_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceSummaryMeta = const VerificationMeta(
    'sourceSummary',
  );
  @override
  late final GeneratedColumn<String> sourceSummary = GeneratedColumn<String>(
    'source_summary',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _appSourceMeta = const VerificationMeta(
    'appSource',
  );
  @override
  late final GeneratedColumn<String> appSource = GeneratedColumn<String>(
    'app_source',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contentTypeMeta = const VerificationMeta(
    'contentType',
  );
  @override
  late final GeneratedColumn<String> contentType = GeneratedColumn<String>(
    'content_type',
    aliasedName,
    false,
    check: () => contentType.isIn(TagDatabaseValues.contentTypes),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('unknown'),
  );
  static const VerificationMeta _languageCodeMeta = const VerificationMeta(
    'languageCode',
  );
  @override
  late final GeneratedColumn<String> languageCode = GeneratedColumn<String>(
    'language_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _detectedDatesJsonMeta = const VerificationMeta(
    'detectedDatesJson',
  );
  @override
  late final GeneratedColumn<String> detectedDatesJson =
      GeneratedColumn<String>(
        'detected_dates_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  static const VerificationMeta _detectedTimesJsonMeta = const VerificationMeta(
    'detectedTimesJson',
  );
  @override
  late final GeneratedColumn<String> detectedTimesJson =
      GeneratedColumn<String>(
        'detected_times_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  static const VerificationMeta _detectedLinksJsonMeta = const VerificationMeta(
    'detectedLinksJson',
  );
  @override
  late final GeneratedColumn<String> detectedLinksJson =
      GeneratedColumn<String>(
        'detected_links_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  static const VerificationMeta _detectedEntitiesJsonMeta =
      const VerificationMeta('detectedEntitiesJson');
  @override
  late final GeneratedColumn<String> detectedEntitiesJson =
      GeneratedColumn<String>(
        'detected_entities_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  static const VerificationMeta _visibleEntitiesJsonMeta =
      const VerificationMeta('visibleEntitiesJson');
  @override
  late final GeneratedColumn<String> visibleEntitiesJson =
      GeneratedColumn<String>(
        'visible_entities_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  static const VerificationMeta _metadataJsonMeta = const VerificationMeta(
    'metadataJson',
  );
  @override
  late final GeneratedColumn<String> metadataJson = GeneratedColumn<String>(
    'metadata_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _processingStateMeta = const VerificationMeta(
    'processingState',
  );
  @override
  late final GeneratedColumn<String> processingState = GeneratedColumn<String>(
    'processing_state',
    aliasedName,
    false,
    check: () => processingState.isIn(TagDatabaseValues.sourceProcessingStates),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('saved'),
  );
  static const VerificationMeta _extractionConfidenceMeta =
      const VerificationMeta('extractionConfidence');
  @override
  late final GeneratedColumn<double> extractionConfidence =
      GeneratedColumn<double>(
        'extraction_confidence',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _failureReasonMeta = const VerificationMeta(
    'failureReason',
  );
  @override
  late final GeneratedColumn<String> failureReason = GeneratedColumn<String>(
    'failure_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    originalUri,
    localFilePath,
    thumbnailFilePath,
    rawText,
    extractedText,
    sourceSummary,
    appSource,
    contentType,
    languageCode,
    detectedDatesJson,
    detectedTimesJson,
    detectedLinksJson,
    detectedEntitiesJson,
    visibleEntitiesJson,
    metadataJson,
    processingState,
    extractionConfidence,
    failureReason,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'source_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<SourceItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('original_uri')) {
      context.handle(
        _originalUriMeta,
        originalUri.isAcceptableOrUnknown(
          data['original_uri']!,
          _originalUriMeta,
        ),
      );
    }
    if (data.containsKey('local_file_path')) {
      context.handle(
        _localFilePathMeta,
        localFilePath.isAcceptableOrUnknown(
          data['local_file_path']!,
          _localFilePathMeta,
        ),
      );
    }
    if (data.containsKey('thumbnail_file_path')) {
      context.handle(
        _thumbnailFilePathMeta,
        thumbnailFilePath.isAcceptableOrUnknown(
          data['thumbnail_file_path']!,
          _thumbnailFilePathMeta,
        ),
      );
    }
    if (data.containsKey('raw_text')) {
      context.handle(
        _rawTextMeta,
        rawText.isAcceptableOrUnknown(data['raw_text']!, _rawTextMeta),
      );
    }
    if (data.containsKey('extracted_text')) {
      context.handle(
        _extractedTextMeta,
        extractedText.isAcceptableOrUnknown(
          data['extracted_text']!,
          _extractedTextMeta,
        ),
      );
    }
    if (data.containsKey('source_summary')) {
      context.handle(
        _sourceSummaryMeta,
        sourceSummary.isAcceptableOrUnknown(
          data['source_summary']!,
          _sourceSummaryMeta,
        ),
      );
    }
    if (data.containsKey('app_source')) {
      context.handle(
        _appSourceMeta,
        appSource.isAcceptableOrUnknown(data['app_source']!, _appSourceMeta),
      );
    }
    if (data.containsKey('content_type')) {
      context.handle(
        _contentTypeMeta,
        contentType.isAcceptableOrUnknown(
          data['content_type']!,
          _contentTypeMeta,
        ),
      );
    }
    if (data.containsKey('language_code')) {
      context.handle(
        _languageCodeMeta,
        languageCode.isAcceptableOrUnknown(
          data['language_code']!,
          _languageCodeMeta,
        ),
      );
    }
    if (data.containsKey('detected_dates_json')) {
      context.handle(
        _detectedDatesJsonMeta,
        detectedDatesJson.isAcceptableOrUnknown(
          data['detected_dates_json']!,
          _detectedDatesJsonMeta,
        ),
      );
    }
    if (data.containsKey('detected_times_json')) {
      context.handle(
        _detectedTimesJsonMeta,
        detectedTimesJson.isAcceptableOrUnknown(
          data['detected_times_json']!,
          _detectedTimesJsonMeta,
        ),
      );
    }
    if (data.containsKey('detected_links_json')) {
      context.handle(
        _detectedLinksJsonMeta,
        detectedLinksJson.isAcceptableOrUnknown(
          data['detected_links_json']!,
          _detectedLinksJsonMeta,
        ),
      );
    }
    if (data.containsKey('detected_entities_json')) {
      context.handle(
        _detectedEntitiesJsonMeta,
        detectedEntitiesJson.isAcceptableOrUnknown(
          data['detected_entities_json']!,
          _detectedEntitiesJsonMeta,
        ),
      );
    }
    if (data.containsKey('visible_entities_json')) {
      context.handle(
        _visibleEntitiesJsonMeta,
        visibleEntitiesJson.isAcceptableOrUnknown(
          data['visible_entities_json']!,
          _visibleEntitiesJsonMeta,
        ),
      );
    }
    if (data.containsKey('metadata_json')) {
      context.handle(
        _metadataJsonMeta,
        metadataJson.isAcceptableOrUnknown(
          data['metadata_json']!,
          _metadataJsonMeta,
        ),
      );
    }
    if (data.containsKey('processing_state')) {
      context.handle(
        _processingStateMeta,
        processingState.isAcceptableOrUnknown(
          data['processing_state']!,
          _processingStateMeta,
        ),
      );
    }
    if (data.containsKey('extraction_confidence')) {
      context.handle(
        _extractionConfidenceMeta,
        extractionConfidence.isAcceptableOrUnknown(
          data['extraction_confidence']!,
          _extractionConfidenceMeta,
        ),
      );
    }
    if (data.containsKey('failure_reason')) {
      context.handle(
        _failureReasonMeta,
        failureReason.isAcceptableOrUnknown(
          data['failure_reason']!,
          _failureReasonMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SourceItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SourceItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      originalUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_uri'],
      ),
      localFilePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_file_path'],
      ),
      thumbnailFilePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumbnail_file_path'],
      ),
      rawText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_text'],
      ),
      extractedText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}extracted_text'],
      ),
      sourceSummary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_summary'],
      ),
      appSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}app_source'],
      ),
      contentType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_type'],
      )!,
      languageCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language_code'],
      ),
      detectedDatesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}detected_dates_json'],
      )!,
      detectedTimesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}detected_times_json'],
      )!,
      detectedLinksJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}detected_links_json'],
      )!,
      detectedEntitiesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}detected_entities_json'],
      )!,
      visibleEntitiesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}visible_entities_json'],
      )!,
      metadataJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metadata_json'],
      )!,
      processingState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}processing_state'],
      )!,
      extractionConfidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}extraction_confidence'],
      ),
      failureReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}failure_reason'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $SourceItemsTable createAlias(String alias) {
    return $SourceItemsTable(attachedDatabase, alias);
  }
}

class SourceItem extends DataClass implements Insertable<SourceItem> {
  final String id;
  final String type;
  final String? originalUri;
  final String? localFilePath;
  final String? thumbnailFilePath;
  final String? rawText;
  final String? extractedText;
  final String? sourceSummary;
  final String? appSource;
  final String contentType;
  final String? languageCode;
  final String detectedDatesJson;
  final String detectedTimesJson;
  final String detectedLinksJson;
  final String detectedEntitiesJson;
  final String visibleEntitiesJson;
  final String metadataJson;
  final String processingState;
  final double? extractionConfidence;
  final String? failureReason;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  const SourceItem({
    required this.id,
    required this.type,
    this.originalUri,
    this.localFilePath,
    this.thumbnailFilePath,
    this.rawText,
    this.extractedText,
    this.sourceSummary,
    this.appSource,
    required this.contentType,
    this.languageCode,
    required this.detectedDatesJson,
    required this.detectedTimesJson,
    required this.detectedLinksJson,
    required this.detectedEntitiesJson,
    required this.visibleEntitiesJson,
    required this.metadataJson,
    required this.processingState,
    this.extractionConfidence,
    this.failureReason,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || originalUri != null) {
      map['original_uri'] = Variable<String>(originalUri);
    }
    if (!nullToAbsent || localFilePath != null) {
      map['local_file_path'] = Variable<String>(localFilePath);
    }
    if (!nullToAbsent || thumbnailFilePath != null) {
      map['thumbnail_file_path'] = Variable<String>(thumbnailFilePath);
    }
    if (!nullToAbsent || rawText != null) {
      map['raw_text'] = Variable<String>(rawText);
    }
    if (!nullToAbsent || extractedText != null) {
      map['extracted_text'] = Variable<String>(extractedText);
    }
    if (!nullToAbsent || sourceSummary != null) {
      map['source_summary'] = Variable<String>(sourceSummary);
    }
    if (!nullToAbsent || appSource != null) {
      map['app_source'] = Variable<String>(appSource);
    }
    map['content_type'] = Variable<String>(contentType);
    if (!nullToAbsent || languageCode != null) {
      map['language_code'] = Variable<String>(languageCode);
    }
    map['detected_dates_json'] = Variable<String>(detectedDatesJson);
    map['detected_times_json'] = Variable<String>(detectedTimesJson);
    map['detected_links_json'] = Variable<String>(detectedLinksJson);
    map['detected_entities_json'] = Variable<String>(detectedEntitiesJson);
    map['visible_entities_json'] = Variable<String>(visibleEntitiesJson);
    map['metadata_json'] = Variable<String>(metadataJson);
    map['processing_state'] = Variable<String>(processingState);
    if (!nullToAbsent || extractionConfidence != null) {
      map['extraction_confidence'] = Variable<double>(extractionConfidence);
    }
    if (!nullToAbsent || failureReason != null) {
      map['failure_reason'] = Variable<String>(failureReason);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    return map;
  }

  SourceItemsCompanion toCompanion(bool nullToAbsent) {
    return SourceItemsCompanion(
      id: Value(id),
      type: Value(type),
      originalUri: originalUri == null && nullToAbsent
          ? const Value.absent()
          : Value(originalUri),
      localFilePath: localFilePath == null && nullToAbsent
          ? const Value.absent()
          : Value(localFilePath),
      thumbnailFilePath: thumbnailFilePath == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailFilePath),
      rawText: rawText == null && nullToAbsent
          ? const Value.absent()
          : Value(rawText),
      extractedText: extractedText == null && nullToAbsent
          ? const Value.absent()
          : Value(extractedText),
      sourceSummary: sourceSummary == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceSummary),
      appSource: appSource == null && nullToAbsent
          ? const Value.absent()
          : Value(appSource),
      contentType: Value(contentType),
      languageCode: languageCode == null && nullToAbsent
          ? const Value.absent()
          : Value(languageCode),
      detectedDatesJson: Value(detectedDatesJson),
      detectedTimesJson: Value(detectedTimesJson),
      detectedLinksJson: Value(detectedLinksJson),
      detectedEntitiesJson: Value(detectedEntitiesJson),
      visibleEntitiesJson: Value(visibleEntitiesJson),
      metadataJson: Value(metadataJson),
      processingState: Value(processingState),
      extractionConfidence: extractionConfidence == null && nullToAbsent
          ? const Value.absent()
          : Value(extractionConfidence),
      failureReason: failureReason == null && nullToAbsent
          ? const Value.absent()
          : Value(failureReason),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory SourceItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SourceItem(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      originalUri: serializer.fromJson<String?>(json['originalUri']),
      localFilePath: serializer.fromJson<String?>(json['localFilePath']),
      thumbnailFilePath: serializer.fromJson<String?>(
        json['thumbnailFilePath'],
      ),
      rawText: serializer.fromJson<String?>(json['rawText']),
      extractedText: serializer.fromJson<String?>(json['extractedText']),
      sourceSummary: serializer.fromJson<String?>(json['sourceSummary']),
      appSource: serializer.fromJson<String?>(json['appSource']),
      contentType: serializer.fromJson<String>(json['contentType']),
      languageCode: serializer.fromJson<String?>(json['languageCode']),
      detectedDatesJson: serializer.fromJson<String>(json['detectedDatesJson']),
      detectedTimesJson: serializer.fromJson<String>(json['detectedTimesJson']),
      detectedLinksJson: serializer.fromJson<String>(json['detectedLinksJson']),
      detectedEntitiesJson: serializer.fromJson<String>(
        json['detectedEntitiesJson'],
      ),
      visibleEntitiesJson: serializer.fromJson<String>(
        json['visibleEntitiesJson'],
      ),
      metadataJson: serializer.fromJson<String>(json['metadataJson']),
      processingState: serializer.fromJson<String>(json['processingState']),
      extractionConfidence: serializer.fromJson<double?>(
        json['extractionConfidence'],
      ),
      failureReason: serializer.fromJson<String?>(json['failureReason']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'originalUri': serializer.toJson<String?>(originalUri),
      'localFilePath': serializer.toJson<String?>(localFilePath),
      'thumbnailFilePath': serializer.toJson<String?>(thumbnailFilePath),
      'rawText': serializer.toJson<String?>(rawText),
      'extractedText': serializer.toJson<String?>(extractedText),
      'sourceSummary': serializer.toJson<String?>(sourceSummary),
      'appSource': serializer.toJson<String?>(appSource),
      'contentType': serializer.toJson<String>(contentType),
      'languageCode': serializer.toJson<String?>(languageCode),
      'detectedDatesJson': serializer.toJson<String>(detectedDatesJson),
      'detectedTimesJson': serializer.toJson<String>(detectedTimesJson),
      'detectedLinksJson': serializer.toJson<String>(detectedLinksJson),
      'detectedEntitiesJson': serializer.toJson<String>(detectedEntitiesJson),
      'visibleEntitiesJson': serializer.toJson<String>(visibleEntitiesJson),
      'metadataJson': serializer.toJson<String>(metadataJson),
      'processingState': serializer.toJson<String>(processingState),
      'extractionConfidence': serializer.toJson<double?>(extractionConfidence),
      'failureReason': serializer.toJson<String?>(failureReason),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
    };
  }

  SourceItem copyWith({
    String? id,
    String? type,
    Value<String?> originalUri = const Value.absent(),
    Value<String?> localFilePath = const Value.absent(),
    Value<String?> thumbnailFilePath = const Value.absent(),
    Value<String?> rawText = const Value.absent(),
    Value<String?> extractedText = const Value.absent(),
    Value<String?> sourceSummary = const Value.absent(),
    Value<String?> appSource = const Value.absent(),
    String? contentType,
    Value<String?> languageCode = const Value.absent(),
    String? detectedDatesJson,
    String? detectedTimesJson,
    String? detectedLinksJson,
    String? detectedEntitiesJson,
    String? visibleEntitiesJson,
    String? metadataJson,
    String? processingState,
    Value<double?> extractionConfidence = const Value.absent(),
    Value<String?> failureReason = const Value.absent(),
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
  }) => SourceItem(
    id: id ?? this.id,
    type: type ?? this.type,
    originalUri: originalUri.present ? originalUri.value : this.originalUri,
    localFilePath: localFilePath.present
        ? localFilePath.value
        : this.localFilePath,
    thumbnailFilePath: thumbnailFilePath.present
        ? thumbnailFilePath.value
        : this.thumbnailFilePath,
    rawText: rawText.present ? rawText.value : this.rawText,
    extractedText: extractedText.present
        ? extractedText.value
        : this.extractedText,
    sourceSummary: sourceSummary.present
        ? sourceSummary.value
        : this.sourceSummary,
    appSource: appSource.present ? appSource.value : this.appSource,
    contentType: contentType ?? this.contentType,
    languageCode: languageCode.present ? languageCode.value : this.languageCode,
    detectedDatesJson: detectedDatesJson ?? this.detectedDatesJson,
    detectedTimesJson: detectedTimesJson ?? this.detectedTimesJson,
    detectedLinksJson: detectedLinksJson ?? this.detectedLinksJson,
    detectedEntitiesJson: detectedEntitiesJson ?? this.detectedEntitiesJson,
    visibleEntitiesJson: visibleEntitiesJson ?? this.visibleEntitiesJson,
    metadataJson: metadataJson ?? this.metadataJson,
    processingState: processingState ?? this.processingState,
    extractionConfidence: extractionConfidence.present
        ? extractionConfidence.value
        : this.extractionConfidence,
    failureReason: failureReason.present
        ? failureReason.value
        : this.failureReason,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  SourceItem copyWithCompanion(SourceItemsCompanion data) {
    return SourceItem(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      originalUri: data.originalUri.present
          ? data.originalUri.value
          : this.originalUri,
      localFilePath: data.localFilePath.present
          ? data.localFilePath.value
          : this.localFilePath,
      thumbnailFilePath: data.thumbnailFilePath.present
          ? data.thumbnailFilePath.value
          : this.thumbnailFilePath,
      rawText: data.rawText.present ? data.rawText.value : this.rawText,
      extractedText: data.extractedText.present
          ? data.extractedText.value
          : this.extractedText,
      sourceSummary: data.sourceSummary.present
          ? data.sourceSummary.value
          : this.sourceSummary,
      appSource: data.appSource.present ? data.appSource.value : this.appSource,
      contentType: data.contentType.present
          ? data.contentType.value
          : this.contentType,
      languageCode: data.languageCode.present
          ? data.languageCode.value
          : this.languageCode,
      detectedDatesJson: data.detectedDatesJson.present
          ? data.detectedDatesJson.value
          : this.detectedDatesJson,
      detectedTimesJson: data.detectedTimesJson.present
          ? data.detectedTimesJson.value
          : this.detectedTimesJson,
      detectedLinksJson: data.detectedLinksJson.present
          ? data.detectedLinksJson.value
          : this.detectedLinksJson,
      detectedEntitiesJson: data.detectedEntitiesJson.present
          ? data.detectedEntitiesJson.value
          : this.detectedEntitiesJson,
      visibleEntitiesJson: data.visibleEntitiesJson.present
          ? data.visibleEntitiesJson.value
          : this.visibleEntitiesJson,
      metadataJson: data.metadataJson.present
          ? data.metadataJson.value
          : this.metadataJson,
      processingState: data.processingState.present
          ? data.processingState.value
          : this.processingState,
      extractionConfidence: data.extractionConfidence.present
          ? data.extractionConfidence.value
          : this.extractionConfidence,
      failureReason: data.failureReason.present
          ? data.failureReason.value
          : this.failureReason,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SourceItem(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('originalUri: $originalUri, ')
          ..write('localFilePath: $localFilePath, ')
          ..write('thumbnailFilePath: $thumbnailFilePath, ')
          ..write('rawText: $rawText, ')
          ..write('extractedText: $extractedText, ')
          ..write('sourceSummary: $sourceSummary, ')
          ..write('appSource: $appSource, ')
          ..write('contentType: $contentType, ')
          ..write('languageCode: $languageCode, ')
          ..write('detectedDatesJson: $detectedDatesJson, ')
          ..write('detectedTimesJson: $detectedTimesJson, ')
          ..write('detectedLinksJson: $detectedLinksJson, ')
          ..write('detectedEntitiesJson: $detectedEntitiesJson, ')
          ..write('visibleEntitiesJson: $visibleEntitiesJson, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('processingState: $processingState, ')
          ..write('extractionConfidence: $extractionConfidence, ')
          ..write('failureReason: $failureReason, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    type,
    originalUri,
    localFilePath,
    thumbnailFilePath,
    rawText,
    extractedText,
    sourceSummary,
    appSource,
    contentType,
    languageCode,
    detectedDatesJson,
    detectedTimesJson,
    detectedLinksJson,
    detectedEntitiesJson,
    visibleEntitiesJson,
    metadataJson,
    processingState,
    extractionConfidence,
    failureReason,
    createdAt,
    updatedAt,
    deletedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SourceItem &&
          other.id == this.id &&
          other.type == this.type &&
          other.originalUri == this.originalUri &&
          other.localFilePath == this.localFilePath &&
          other.thumbnailFilePath == this.thumbnailFilePath &&
          other.rawText == this.rawText &&
          other.extractedText == this.extractedText &&
          other.sourceSummary == this.sourceSummary &&
          other.appSource == this.appSource &&
          other.contentType == this.contentType &&
          other.languageCode == this.languageCode &&
          other.detectedDatesJson == this.detectedDatesJson &&
          other.detectedTimesJson == this.detectedTimesJson &&
          other.detectedLinksJson == this.detectedLinksJson &&
          other.detectedEntitiesJson == this.detectedEntitiesJson &&
          other.visibleEntitiesJson == this.visibleEntitiesJson &&
          other.metadataJson == this.metadataJson &&
          other.processingState == this.processingState &&
          other.extractionConfidence == this.extractionConfidence &&
          other.failureReason == this.failureReason &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class SourceItemsCompanion extends UpdateCompanion<SourceItem> {
  final Value<String> id;
  final Value<String> type;
  final Value<String?> originalUri;
  final Value<String?> localFilePath;
  final Value<String?> thumbnailFilePath;
  final Value<String?> rawText;
  final Value<String?> extractedText;
  final Value<String?> sourceSummary;
  final Value<String?> appSource;
  final Value<String> contentType;
  final Value<String?> languageCode;
  final Value<String> detectedDatesJson;
  final Value<String> detectedTimesJson;
  final Value<String> detectedLinksJson;
  final Value<String> detectedEntitiesJson;
  final Value<String> visibleEntitiesJson;
  final Value<String> metadataJson;
  final Value<String> processingState;
  final Value<double?> extractionConfidence;
  final Value<String?> failureReason;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<int> rowid;
  const SourceItemsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.originalUri = const Value.absent(),
    this.localFilePath = const Value.absent(),
    this.thumbnailFilePath = const Value.absent(),
    this.rawText = const Value.absent(),
    this.extractedText = const Value.absent(),
    this.sourceSummary = const Value.absent(),
    this.appSource = const Value.absent(),
    this.contentType = const Value.absent(),
    this.languageCode = const Value.absent(),
    this.detectedDatesJson = const Value.absent(),
    this.detectedTimesJson = const Value.absent(),
    this.detectedLinksJson = const Value.absent(),
    this.detectedEntitiesJson = const Value.absent(),
    this.visibleEntitiesJson = const Value.absent(),
    this.metadataJson = const Value.absent(),
    this.processingState = const Value.absent(),
    this.extractionConfidence = const Value.absent(),
    this.failureReason = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SourceItemsCompanion.insert({
    required String id,
    required String type,
    this.originalUri = const Value.absent(),
    this.localFilePath = const Value.absent(),
    this.thumbnailFilePath = const Value.absent(),
    this.rawText = const Value.absent(),
    this.extractedText = const Value.absent(),
    this.sourceSummary = const Value.absent(),
    this.appSource = const Value.absent(),
    this.contentType = const Value.absent(),
    this.languageCode = const Value.absent(),
    this.detectedDatesJson = const Value.absent(),
    this.detectedTimesJson = const Value.absent(),
    this.detectedLinksJson = const Value.absent(),
    this.detectedEntitiesJson = const Value.absent(),
    this.visibleEntitiesJson = const Value.absent(),
    this.metadataJson = const Value.absent(),
    this.processingState = const Value.absent(),
    this.extractionConfidence = const Value.absent(),
    this.failureReason = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       type = Value(type),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<SourceItem> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<String>? originalUri,
    Expression<String>? localFilePath,
    Expression<String>? thumbnailFilePath,
    Expression<String>? rawText,
    Expression<String>? extractedText,
    Expression<String>? sourceSummary,
    Expression<String>? appSource,
    Expression<String>? contentType,
    Expression<String>? languageCode,
    Expression<String>? detectedDatesJson,
    Expression<String>? detectedTimesJson,
    Expression<String>? detectedLinksJson,
    Expression<String>? detectedEntitiesJson,
    Expression<String>? visibleEntitiesJson,
    Expression<String>? metadataJson,
    Expression<String>? processingState,
    Expression<double>? extractionConfidence,
    Expression<String>? failureReason,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (originalUri != null) 'original_uri': originalUri,
      if (localFilePath != null) 'local_file_path': localFilePath,
      if (thumbnailFilePath != null) 'thumbnail_file_path': thumbnailFilePath,
      if (rawText != null) 'raw_text': rawText,
      if (extractedText != null) 'extracted_text': extractedText,
      if (sourceSummary != null) 'source_summary': sourceSummary,
      if (appSource != null) 'app_source': appSource,
      if (contentType != null) 'content_type': contentType,
      if (languageCode != null) 'language_code': languageCode,
      if (detectedDatesJson != null) 'detected_dates_json': detectedDatesJson,
      if (detectedTimesJson != null) 'detected_times_json': detectedTimesJson,
      if (detectedLinksJson != null) 'detected_links_json': detectedLinksJson,
      if (detectedEntitiesJson != null)
        'detected_entities_json': detectedEntitiesJson,
      if (visibleEntitiesJson != null)
        'visible_entities_json': visibleEntitiesJson,
      if (metadataJson != null) 'metadata_json': metadataJson,
      if (processingState != null) 'processing_state': processingState,
      if (extractionConfidence != null)
        'extraction_confidence': extractionConfidence,
      if (failureReason != null) 'failure_reason': failureReason,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SourceItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? type,
    Value<String?>? originalUri,
    Value<String?>? localFilePath,
    Value<String?>? thumbnailFilePath,
    Value<String?>? rawText,
    Value<String?>? extractedText,
    Value<String?>? sourceSummary,
    Value<String?>? appSource,
    Value<String>? contentType,
    Value<String?>? languageCode,
    Value<String>? detectedDatesJson,
    Value<String>? detectedTimesJson,
    Value<String>? detectedLinksJson,
    Value<String>? detectedEntitiesJson,
    Value<String>? visibleEntitiesJson,
    Value<String>? metadataJson,
    Value<String>? processingState,
    Value<double?>? extractionConfidence,
    Value<String?>? failureReason,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<int>? rowid,
  }) {
    return SourceItemsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      originalUri: originalUri ?? this.originalUri,
      localFilePath: localFilePath ?? this.localFilePath,
      thumbnailFilePath: thumbnailFilePath ?? this.thumbnailFilePath,
      rawText: rawText ?? this.rawText,
      extractedText: extractedText ?? this.extractedText,
      sourceSummary: sourceSummary ?? this.sourceSummary,
      appSource: appSource ?? this.appSource,
      contentType: contentType ?? this.contentType,
      languageCode: languageCode ?? this.languageCode,
      detectedDatesJson: detectedDatesJson ?? this.detectedDatesJson,
      detectedTimesJson: detectedTimesJson ?? this.detectedTimesJson,
      detectedLinksJson: detectedLinksJson ?? this.detectedLinksJson,
      detectedEntitiesJson: detectedEntitiesJson ?? this.detectedEntitiesJson,
      visibleEntitiesJson: visibleEntitiesJson ?? this.visibleEntitiesJson,
      metadataJson: metadataJson ?? this.metadataJson,
      processingState: processingState ?? this.processingState,
      extractionConfidence: extractionConfidence ?? this.extractionConfidence,
      failureReason: failureReason ?? this.failureReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (originalUri.present) {
      map['original_uri'] = Variable<String>(originalUri.value);
    }
    if (localFilePath.present) {
      map['local_file_path'] = Variable<String>(localFilePath.value);
    }
    if (thumbnailFilePath.present) {
      map['thumbnail_file_path'] = Variable<String>(thumbnailFilePath.value);
    }
    if (rawText.present) {
      map['raw_text'] = Variable<String>(rawText.value);
    }
    if (extractedText.present) {
      map['extracted_text'] = Variable<String>(extractedText.value);
    }
    if (sourceSummary.present) {
      map['source_summary'] = Variable<String>(sourceSummary.value);
    }
    if (appSource.present) {
      map['app_source'] = Variable<String>(appSource.value);
    }
    if (contentType.present) {
      map['content_type'] = Variable<String>(contentType.value);
    }
    if (languageCode.present) {
      map['language_code'] = Variable<String>(languageCode.value);
    }
    if (detectedDatesJson.present) {
      map['detected_dates_json'] = Variable<String>(detectedDatesJson.value);
    }
    if (detectedTimesJson.present) {
      map['detected_times_json'] = Variable<String>(detectedTimesJson.value);
    }
    if (detectedLinksJson.present) {
      map['detected_links_json'] = Variable<String>(detectedLinksJson.value);
    }
    if (detectedEntitiesJson.present) {
      map['detected_entities_json'] = Variable<String>(
        detectedEntitiesJson.value,
      );
    }
    if (visibleEntitiesJson.present) {
      map['visible_entities_json'] = Variable<String>(
        visibleEntitiesJson.value,
      );
    }
    if (metadataJson.present) {
      map['metadata_json'] = Variable<String>(metadataJson.value);
    }
    if (processingState.present) {
      map['processing_state'] = Variable<String>(processingState.value);
    }
    if (extractionConfidence.present) {
      map['extraction_confidence'] = Variable<double>(
        extractionConfidence.value,
      );
    }
    if (failureReason.present) {
      map['failure_reason'] = Variable<String>(failureReason.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SourceItemsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('originalUri: $originalUri, ')
          ..write('localFilePath: $localFilePath, ')
          ..write('thumbnailFilePath: $thumbnailFilePath, ')
          ..write('rawText: $rawText, ')
          ..write('extractedText: $extractedText, ')
          ..write('sourceSummary: $sourceSummary, ')
          ..write('appSource: $appSource, ')
          ..write('contentType: $contentType, ')
          ..write('languageCode: $languageCode, ')
          ..write('detectedDatesJson: $detectedDatesJson, ')
          ..write('detectedTimesJson: $detectedTimesJson, ')
          ..write('detectedLinksJson: $detectedLinksJson, ')
          ..write('detectedEntitiesJson: $detectedEntitiesJson, ')
          ..write('visibleEntitiesJson: $visibleEntitiesJson, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('processingState: $processingState, ')
          ..write('extractionConfidence: $extractionConfidence, ')
          ..write('failureReason: $failureReason, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SourceTextChunksTable extends SourceTextChunks
    with TableInfo<$SourceTextChunksTable, SourceTextChunk> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SourceTextChunksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES source_items (id)',
    ),
  );
  static const VerificationMeta _chunkIndexMeta = const VerificationMeta(
    'chunkIndex',
  );
  @override
  late final GeneratedColumn<int> chunkIndex = GeneratedColumn<int>(
    'chunk_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chunkTextMeta = const VerificationMeta(
    'chunkText',
  );
  @override
  late final GeneratedColumn<String> chunkText = GeneratedColumn<String>(
    'chunk_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _charStartMeta = const VerificationMeta(
    'charStart',
  );
  @override
  late final GeneratedColumn<int> charStart = GeneratedColumn<int>(
    'char_start',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _charEndMeta = const VerificationMeta(
    'charEnd',
  );
  @override
  late final GeneratedColumn<int> charEnd = GeneratedColumn<int>(
    'char_end',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tokenCountEstimateMeta =
      const VerificationMeta('tokenCountEstimate');
  @override
  late final GeneratedColumn<int> tokenCountEstimate = GeneratedColumn<int>(
    'token_count_estimate',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _embeddingModelSlugMeta =
      const VerificationMeta('embeddingModelSlug');
  @override
  late final GeneratedColumn<String> embeddingModelSlug =
      GeneratedColumn<String>(
        'embedding_model_slug',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _vectorIndexNameMeta = const VerificationMeta(
    'vectorIndexName',
  );
  @override
  late final GeneratedColumn<String> vectorIndexName = GeneratedColumn<String>(
    'vector_index_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _vectorExternalIdMeta = const VerificationMeta(
    'vectorExternalId',
  );
  @override
  late final GeneratedColumn<String> vectorExternalId = GeneratedColumn<String>(
    'vector_external_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _embeddingDimensionMeta =
      const VerificationMeta('embeddingDimension');
  @override
  late final GeneratedColumn<int> embeddingDimension = GeneratedColumn<int>(
    'embedding_dimension',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sourceId,
    chunkIndex,
    chunkText,
    charStart,
    charEnd,
    tokenCountEstimate,
    embeddingModelSlug,
    vectorIndexName,
    vectorExternalId,
    embeddingDimension,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'source_text_chunks';
  @override
  VerificationContext validateIntegrity(
    Insertable<SourceTextChunk> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('chunk_index')) {
      context.handle(
        _chunkIndexMeta,
        chunkIndex.isAcceptableOrUnknown(data['chunk_index']!, _chunkIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_chunkIndexMeta);
    }
    if (data.containsKey('chunk_text')) {
      context.handle(
        _chunkTextMeta,
        chunkText.isAcceptableOrUnknown(data['chunk_text']!, _chunkTextMeta),
      );
    } else if (isInserting) {
      context.missing(_chunkTextMeta);
    }
    if (data.containsKey('char_start')) {
      context.handle(
        _charStartMeta,
        charStart.isAcceptableOrUnknown(data['char_start']!, _charStartMeta),
      );
    }
    if (data.containsKey('char_end')) {
      context.handle(
        _charEndMeta,
        charEnd.isAcceptableOrUnknown(data['char_end']!, _charEndMeta),
      );
    }
    if (data.containsKey('token_count_estimate')) {
      context.handle(
        _tokenCountEstimateMeta,
        tokenCountEstimate.isAcceptableOrUnknown(
          data['token_count_estimate']!,
          _tokenCountEstimateMeta,
        ),
      );
    }
    if (data.containsKey('embedding_model_slug')) {
      context.handle(
        _embeddingModelSlugMeta,
        embeddingModelSlug.isAcceptableOrUnknown(
          data['embedding_model_slug']!,
          _embeddingModelSlugMeta,
        ),
      );
    }
    if (data.containsKey('vector_index_name')) {
      context.handle(
        _vectorIndexNameMeta,
        vectorIndexName.isAcceptableOrUnknown(
          data['vector_index_name']!,
          _vectorIndexNameMeta,
        ),
      );
    }
    if (data.containsKey('vector_external_id')) {
      context.handle(
        _vectorExternalIdMeta,
        vectorExternalId.isAcceptableOrUnknown(
          data['vector_external_id']!,
          _vectorExternalIdMeta,
        ),
      );
    }
    if (data.containsKey('embedding_dimension')) {
      context.handle(
        _embeddingDimensionMeta,
        embeddingDimension.isAcceptableOrUnknown(
          data['embedding_dimension']!,
          _embeddingDimensionMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SourceTextChunk map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SourceTextChunk(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
      chunkIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chunk_index'],
      )!,
      chunkText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chunk_text'],
      )!,
      charStart: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}char_start'],
      ),
      charEnd: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}char_end'],
      ),
      tokenCountEstimate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}token_count_estimate'],
      ),
      embeddingModelSlug: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}embedding_model_slug'],
      ),
      vectorIndexName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vector_index_name'],
      ),
      vectorExternalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vector_external_id'],
      ),
      embeddingDimension: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}embedding_dimension'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SourceTextChunksTable createAlias(String alias) {
    return $SourceTextChunksTable(attachedDatabase, alias);
  }
}

class SourceTextChunk extends DataClass implements Insertable<SourceTextChunk> {
  final String id;
  final String sourceId;
  final int chunkIndex;
  final String chunkText;
  final int? charStart;
  final int? charEnd;
  final int? tokenCountEstimate;
  final String? embeddingModelSlug;
  final String? vectorIndexName;
  final String? vectorExternalId;
  final int? embeddingDimension;
  final int createdAt;
  final int updatedAt;
  const SourceTextChunk({
    required this.id,
    required this.sourceId,
    required this.chunkIndex,
    required this.chunkText,
    this.charStart,
    this.charEnd,
    this.tokenCountEstimate,
    this.embeddingModelSlug,
    this.vectorIndexName,
    this.vectorExternalId,
    this.embeddingDimension,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['source_id'] = Variable<String>(sourceId);
    map['chunk_index'] = Variable<int>(chunkIndex);
    map['chunk_text'] = Variable<String>(chunkText);
    if (!nullToAbsent || charStart != null) {
      map['char_start'] = Variable<int>(charStart);
    }
    if (!nullToAbsent || charEnd != null) {
      map['char_end'] = Variable<int>(charEnd);
    }
    if (!nullToAbsent || tokenCountEstimate != null) {
      map['token_count_estimate'] = Variable<int>(tokenCountEstimate);
    }
    if (!nullToAbsent || embeddingModelSlug != null) {
      map['embedding_model_slug'] = Variable<String>(embeddingModelSlug);
    }
    if (!nullToAbsent || vectorIndexName != null) {
      map['vector_index_name'] = Variable<String>(vectorIndexName);
    }
    if (!nullToAbsent || vectorExternalId != null) {
      map['vector_external_id'] = Variable<String>(vectorExternalId);
    }
    if (!nullToAbsent || embeddingDimension != null) {
      map['embedding_dimension'] = Variable<int>(embeddingDimension);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  SourceTextChunksCompanion toCompanion(bool nullToAbsent) {
    return SourceTextChunksCompanion(
      id: Value(id),
      sourceId: Value(sourceId),
      chunkIndex: Value(chunkIndex),
      chunkText: Value(chunkText),
      charStart: charStart == null && nullToAbsent
          ? const Value.absent()
          : Value(charStart),
      charEnd: charEnd == null && nullToAbsent
          ? const Value.absent()
          : Value(charEnd),
      tokenCountEstimate: tokenCountEstimate == null && nullToAbsent
          ? const Value.absent()
          : Value(tokenCountEstimate),
      embeddingModelSlug: embeddingModelSlug == null && nullToAbsent
          ? const Value.absent()
          : Value(embeddingModelSlug),
      vectorIndexName: vectorIndexName == null && nullToAbsent
          ? const Value.absent()
          : Value(vectorIndexName),
      vectorExternalId: vectorExternalId == null && nullToAbsent
          ? const Value.absent()
          : Value(vectorExternalId),
      embeddingDimension: embeddingDimension == null && nullToAbsent
          ? const Value.absent()
          : Value(embeddingDimension),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory SourceTextChunk.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SourceTextChunk(
      id: serializer.fromJson<String>(json['id']),
      sourceId: serializer.fromJson<String>(json['sourceId']),
      chunkIndex: serializer.fromJson<int>(json['chunkIndex']),
      chunkText: serializer.fromJson<String>(json['chunkText']),
      charStart: serializer.fromJson<int?>(json['charStart']),
      charEnd: serializer.fromJson<int?>(json['charEnd']),
      tokenCountEstimate: serializer.fromJson<int?>(json['tokenCountEstimate']),
      embeddingModelSlug: serializer.fromJson<String?>(
        json['embeddingModelSlug'],
      ),
      vectorIndexName: serializer.fromJson<String?>(json['vectorIndexName']),
      vectorExternalId: serializer.fromJson<String?>(json['vectorExternalId']),
      embeddingDimension: serializer.fromJson<int?>(json['embeddingDimension']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sourceId': serializer.toJson<String>(sourceId),
      'chunkIndex': serializer.toJson<int>(chunkIndex),
      'chunkText': serializer.toJson<String>(chunkText),
      'charStart': serializer.toJson<int?>(charStart),
      'charEnd': serializer.toJson<int?>(charEnd),
      'tokenCountEstimate': serializer.toJson<int?>(tokenCountEstimate),
      'embeddingModelSlug': serializer.toJson<String?>(embeddingModelSlug),
      'vectorIndexName': serializer.toJson<String?>(vectorIndexName),
      'vectorExternalId': serializer.toJson<String?>(vectorExternalId),
      'embeddingDimension': serializer.toJson<int?>(embeddingDimension),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  SourceTextChunk copyWith({
    String? id,
    String? sourceId,
    int? chunkIndex,
    String? chunkText,
    Value<int?> charStart = const Value.absent(),
    Value<int?> charEnd = const Value.absent(),
    Value<int?> tokenCountEstimate = const Value.absent(),
    Value<String?> embeddingModelSlug = const Value.absent(),
    Value<String?> vectorIndexName = const Value.absent(),
    Value<String?> vectorExternalId = const Value.absent(),
    Value<int?> embeddingDimension = const Value.absent(),
    int? createdAt,
    int? updatedAt,
  }) => SourceTextChunk(
    id: id ?? this.id,
    sourceId: sourceId ?? this.sourceId,
    chunkIndex: chunkIndex ?? this.chunkIndex,
    chunkText: chunkText ?? this.chunkText,
    charStart: charStart.present ? charStart.value : this.charStart,
    charEnd: charEnd.present ? charEnd.value : this.charEnd,
    tokenCountEstimate: tokenCountEstimate.present
        ? tokenCountEstimate.value
        : this.tokenCountEstimate,
    embeddingModelSlug: embeddingModelSlug.present
        ? embeddingModelSlug.value
        : this.embeddingModelSlug,
    vectorIndexName: vectorIndexName.present
        ? vectorIndexName.value
        : this.vectorIndexName,
    vectorExternalId: vectorExternalId.present
        ? vectorExternalId.value
        : this.vectorExternalId,
    embeddingDimension: embeddingDimension.present
        ? embeddingDimension.value
        : this.embeddingDimension,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SourceTextChunk copyWithCompanion(SourceTextChunksCompanion data) {
    return SourceTextChunk(
      id: data.id.present ? data.id.value : this.id,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      chunkIndex: data.chunkIndex.present
          ? data.chunkIndex.value
          : this.chunkIndex,
      chunkText: data.chunkText.present ? data.chunkText.value : this.chunkText,
      charStart: data.charStart.present ? data.charStart.value : this.charStart,
      charEnd: data.charEnd.present ? data.charEnd.value : this.charEnd,
      tokenCountEstimate: data.tokenCountEstimate.present
          ? data.tokenCountEstimate.value
          : this.tokenCountEstimate,
      embeddingModelSlug: data.embeddingModelSlug.present
          ? data.embeddingModelSlug.value
          : this.embeddingModelSlug,
      vectorIndexName: data.vectorIndexName.present
          ? data.vectorIndexName.value
          : this.vectorIndexName,
      vectorExternalId: data.vectorExternalId.present
          ? data.vectorExternalId.value
          : this.vectorExternalId,
      embeddingDimension: data.embeddingDimension.present
          ? data.embeddingDimension.value
          : this.embeddingDimension,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SourceTextChunk(')
          ..write('id: $id, ')
          ..write('sourceId: $sourceId, ')
          ..write('chunkIndex: $chunkIndex, ')
          ..write('chunkText: $chunkText, ')
          ..write('charStart: $charStart, ')
          ..write('charEnd: $charEnd, ')
          ..write('tokenCountEstimate: $tokenCountEstimate, ')
          ..write('embeddingModelSlug: $embeddingModelSlug, ')
          ..write('vectorIndexName: $vectorIndexName, ')
          ..write('vectorExternalId: $vectorExternalId, ')
          ..write('embeddingDimension: $embeddingDimension, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sourceId,
    chunkIndex,
    chunkText,
    charStart,
    charEnd,
    tokenCountEstimate,
    embeddingModelSlug,
    vectorIndexName,
    vectorExternalId,
    embeddingDimension,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SourceTextChunk &&
          other.id == this.id &&
          other.sourceId == this.sourceId &&
          other.chunkIndex == this.chunkIndex &&
          other.chunkText == this.chunkText &&
          other.charStart == this.charStart &&
          other.charEnd == this.charEnd &&
          other.tokenCountEstimate == this.tokenCountEstimate &&
          other.embeddingModelSlug == this.embeddingModelSlug &&
          other.vectorIndexName == this.vectorIndexName &&
          other.vectorExternalId == this.vectorExternalId &&
          other.embeddingDimension == this.embeddingDimension &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SourceTextChunksCompanion extends UpdateCompanion<SourceTextChunk> {
  final Value<String> id;
  final Value<String> sourceId;
  final Value<int> chunkIndex;
  final Value<String> chunkText;
  final Value<int?> charStart;
  final Value<int?> charEnd;
  final Value<int?> tokenCountEstimate;
  final Value<String?> embeddingModelSlug;
  final Value<String?> vectorIndexName;
  final Value<String?> vectorExternalId;
  final Value<int?> embeddingDimension;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const SourceTextChunksCompanion({
    this.id = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.chunkIndex = const Value.absent(),
    this.chunkText = const Value.absent(),
    this.charStart = const Value.absent(),
    this.charEnd = const Value.absent(),
    this.tokenCountEstimate = const Value.absent(),
    this.embeddingModelSlug = const Value.absent(),
    this.vectorIndexName = const Value.absent(),
    this.vectorExternalId = const Value.absent(),
    this.embeddingDimension = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SourceTextChunksCompanion.insert({
    required String id,
    required String sourceId,
    required int chunkIndex,
    required String chunkText,
    this.charStart = const Value.absent(),
    this.charEnd = const Value.absent(),
    this.tokenCountEstimate = const Value.absent(),
    this.embeddingModelSlug = const Value.absent(),
    this.vectorIndexName = const Value.absent(),
    this.vectorExternalId = const Value.absent(),
    this.embeddingDimension = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sourceId = Value(sourceId),
       chunkIndex = Value(chunkIndex),
       chunkText = Value(chunkText),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<SourceTextChunk> custom({
    Expression<String>? id,
    Expression<String>? sourceId,
    Expression<int>? chunkIndex,
    Expression<String>? chunkText,
    Expression<int>? charStart,
    Expression<int>? charEnd,
    Expression<int>? tokenCountEstimate,
    Expression<String>? embeddingModelSlug,
    Expression<String>? vectorIndexName,
    Expression<String>? vectorExternalId,
    Expression<int>? embeddingDimension,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sourceId != null) 'source_id': sourceId,
      if (chunkIndex != null) 'chunk_index': chunkIndex,
      if (chunkText != null) 'chunk_text': chunkText,
      if (charStart != null) 'char_start': charStart,
      if (charEnd != null) 'char_end': charEnd,
      if (tokenCountEstimate != null)
        'token_count_estimate': tokenCountEstimate,
      if (embeddingModelSlug != null)
        'embedding_model_slug': embeddingModelSlug,
      if (vectorIndexName != null) 'vector_index_name': vectorIndexName,
      if (vectorExternalId != null) 'vector_external_id': vectorExternalId,
      if (embeddingDimension != null) 'embedding_dimension': embeddingDimension,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SourceTextChunksCompanion copyWith({
    Value<String>? id,
    Value<String>? sourceId,
    Value<int>? chunkIndex,
    Value<String>? chunkText,
    Value<int?>? charStart,
    Value<int?>? charEnd,
    Value<int?>? tokenCountEstimate,
    Value<String?>? embeddingModelSlug,
    Value<String?>? vectorIndexName,
    Value<String?>? vectorExternalId,
    Value<int?>? embeddingDimension,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return SourceTextChunksCompanion(
      id: id ?? this.id,
      sourceId: sourceId ?? this.sourceId,
      chunkIndex: chunkIndex ?? this.chunkIndex,
      chunkText: chunkText ?? this.chunkText,
      charStart: charStart ?? this.charStart,
      charEnd: charEnd ?? this.charEnd,
      tokenCountEstimate: tokenCountEstimate ?? this.tokenCountEstimate,
      embeddingModelSlug: embeddingModelSlug ?? this.embeddingModelSlug,
      vectorIndexName: vectorIndexName ?? this.vectorIndexName,
      vectorExternalId: vectorExternalId ?? this.vectorExternalId,
      embeddingDimension: embeddingDimension ?? this.embeddingDimension,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (chunkIndex.present) {
      map['chunk_index'] = Variable<int>(chunkIndex.value);
    }
    if (chunkText.present) {
      map['chunk_text'] = Variable<String>(chunkText.value);
    }
    if (charStart.present) {
      map['char_start'] = Variable<int>(charStart.value);
    }
    if (charEnd.present) {
      map['char_end'] = Variable<int>(charEnd.value);
    }
    if (tokenCountEstimate.present) {
      map['token_count_estimate'] = Variable<int>(tokenCountEstimate.value);
    }
    if (embeddingModelSlug.present) {
      map['embedding_model_slug'] = Variable<String>(embeddingModelSlug.value);
    }
    if (vectorIndexName.present) {
      map['vector_index_name'] = Variable<String>(vectorIndexName.value);
    }
    if (vectorExternalId.present) {
      map['vector_external_id'] = Variable<String>(vectorExternalId.value);
    }
    if (embeddingDimension.present) {
      map['embedding_dimension'] = Variable<int>(embeddingDimension.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SourceTextChunksCompanion(')
          ..write('id: $id, ')
          ..write('sourceId: $sourceId, ')
          ..write('chunkIndex: $chunkIndex, ')
          ..write('chunkText: $chunkText, ')
          ..write('charStart: $charStart, ')
          ..write('charEnd: $charEnd, ')
          ..write('tokenCountEstimate: $tokenCountEstimate, ')
          ..write('embeddingModelSlug: $embeddingModelSlug, ')
          ..write('vectorIndexName: $vectorIndexName, ')
          ..write('vectorExternalId: $vectorExternalId, ')
          ..write('embeddingDimension: $embeddingDimension, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SpacesTable extends Spaces with TableInfo<$SpacesTable, Space> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SpacesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _normalizedNameMeta = const VerificationMeta(
    'normalizedName',
  );
  @override
  late final GeneratedColumn<String> normalizedName = GeneratedColumn<String>(
    'normalized_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    check: () => type.isIn(TagDatabaseValues.spaceTypes),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _primaryIntentionTypeMeta =
      const VerificationMeta('primaryIntentionType');
  @override
  late final GeneratedColumn<String> primaryIntentionType =
      GeneratedColumn<String>(
        'primary_intention_type',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    false,
    check: () => createdBy.isIn(TagDatabaseValues.spaceCreatedBy),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
    'confidence',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceIdsSnapshotJsonMeta =
      const VerificationMeta('sourceIdsSnapshotJson');
  @override
  late final GeneratedColumn<String> sourceIdsSnapshotJson =
      GeneratedColumn<String>(
        'source_ids_snapshot_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  static const VerificationMeta _metadataJsonMeta = const VerificationMeta(
    'metadataJson',
  );
  @override
  late final GeneratedColumn<String> metadataJson = GeneratedColumn<String>(
    'metadata_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _archivedAtMeta = const VerificationMeta(
    'archivedAt',
  );
  @override
  late final GeneratedColumn<int> archivedAt = GeneratedColumn<int>(
    'archived_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    normalizedName,
    type,
    description,
    primaryIntentionType,
    createdBy,
    confidence,
    sourceIdsSnapshotJson,
    metadataJson,
    createdAt,
    updatedAt,
    archivedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'spaces';
  @override
  VerificationContext validateIntegrity(
    Insertable<Space> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('normalized_name')) {
      context.handle(
        _normalizedNameMeta,
        normalizedName.isAcceptableOrUnknown(
          data['normalized_name']!,
          _normalizedNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_normalizedNameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('primary_intention_type')) {
      context.handle(
        _primaryIntentionTypeMeta,
        primaryIntentionType.isAcceptableOrUnknown(
          data['primary_intention_type']!,
          _primaryIntentionTypeMeta,
        ),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    }
    if (data.containsKey('source_ids_snapshot_json')) {
      context.handle(
        _sourceIdsSnapshotJsonMeta,
        sourceIdsSnapshotJson.isAcceptableOrUnknown(
          data['source_ids_snapshot_json']!,
          _sourceIdsSnapshotJsonMeta,
        ),
      );
    }
    if (data.containsKey('metadata_json')) {
      context.handle(
        _metadataJsonMeta,
        metadataJson.isAcceptableOrUnknown(
          data['metadata_json']!,
          _metadataJsonMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('archived_at')) {
      context.handle(
        _archivedAtMeta,
        archivedAt.isAcceptableOrUnknown(data['archived_at']!, _archivedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {normalizedName},
  ];
  @override
  Space map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Space(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      normalizedName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      primaryIntentionType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}primary_intention_type'],
      ),
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      )!,
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      ),
      sourceIdsSnapshotJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_ids_snapshot_json'],
      )!,
      metadataJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metadata_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      archivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}archived_at'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $SpacesTable createAlias(String alias) {
    return $SpacesTable(attachedDatabase, alias);
  }
}

class Space extends DataClass implements Insertable<Space> {
  final String id;
  final String name;
  final String normalizedName;
  final String type;
  final String? description;
  final String? primaryIntentionType;
  final String createdBy;
  final double? confidence;
  final String sourceIdsSnapshotJson;
  final String metadataJson;
  final int createdAt;
  final int updatedAt;
  final int? archivedAt;
  final int? deletedAt;
  const Space({
    required this.id,
    required this.name,
    required this.normalizedName,
    required this.type,
    this.description,
    this.primaryIntentionType,
    required this.createdBy,
    this.confidence,
    required this.sourceIdsSnapshotJson,
    required this.metadataJson,
    required this.createdAt,
    required this.updatedAt,
    this.archivedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['normalized_name'] = Variable<String>(normalizedName);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || primaryIntentionType != null) {
      map['primary_intention_type'] = Variable<String>(primaryIntentionType);
    }
    map['created_by'] = Variable<String>(createdBy);
    if (!nullToAbsent || confidence != null) {
      map['confidence'] = Variable<double>(confidence);
    }
    map['source_ids_snapshot_json'] = Variable<String>(sourceIdsSnapshotJson);
    map['metadata_json'] = Variable<String>(metadataJson);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<int>(archivedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    return map;
  }

  SpacesCompanion toCompanion(bool nullToAbsent) {
    return SpacesCompanion(
      id: Value(id),
      name: Value(name),
      normalizedName: Value(normalizedName),
      type: Value(type),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      primaryIntentionType: primaryIntentionType == null && nullToAbsent
          ? const Value.absent()
          : Value(primaryIntentionType),
      createdBy: Value(createdBy),
      confidence: confidence == null && nullToAbsent
          ? const Value.absent()
          : Value(confidence),
      sourceIdsSnapshotJson: Value(sourceIdsSnapshotJson),
      metadataJson: Value(metadataJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Space.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Space(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      normalizedName: serializer.fromJson<String>(json['normalizedName']),
      type: serializer.fromJson<String>(json['type']),
      description: serializer.fromJson<String?>(json['description']),
      primaryIntentionType: serializer.fromJson<String?>(
        json['primaryIntentionType'],
      ),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      confidence: serializer.fromJson<double?>(json['confidence']),
      sourceIdsSnapshotJson: serializer.fromJson<String>(
        json['sourceIdsSnapshotJson'],
      ),
      metadataJson: serializer.fromJson<String>(json['metadataJson']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      archivedAt: serializer.fromJson<int?>(json['archivedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'normalizedName': serializer.toJson<String>(normalizedName),
      'type': serializer.toJson<String>(type),
      'description': serializer.toJson<String?>(description),
      'primaryIntentionType': serializer.toJson<String?>(primaryIntentionType),
      'createdBy': serializer.toJson<String>(createdBy),
      'confidence': serializer.toJson<double?>(confidence),
      'sourceIdsSnapshotJson': serializer.toJson<String>(sourceIdsSnapshotJson),
      'metadataJson': serializer.toJson<String>(metadataJson),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'archivedAt': serializer.toJson<int?>(archivedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
    };
  }

  Space copyWith({
    String? id,
    String? name,
    String? normalizedName,
    String? type,
    Value<String?> description = const Value.absent(),
    Value<String?> primaryIntentionType = const Value.absent(),
    String? createdBy,
    Value<double?> confidence = const Value.absent(),
    String? sourceIdsSnapshotJson,
    String? metadataJson,
    int? createdAt,
    int? updatedAt,
    Value<int?> archivedAt = const Value.absent(),
    Value<int?> deletedAt = const Value.absent(),
  }) => Space(
    id: id ?? this.id,
    name: name ?? this.name,
    normalizedName: normalizedName ?? this.normalizedName,
    type: type ?? this.type,
    description: description.present ? description.value : this.description,
    primaryIntentionType: primaryIntentionType.present
        ? primaryIntentionType.value
        : this.primaryIntentionType,
    createdBy: createdBy ?? this.createdBy,
    confidence: confidence.present ? confidence.value : this.confidence,
    sourceIdsSnapshotJson: sourceIdsSnapshotJson ?? this.sourceIdsSnapshotJson,
    metadataJson: metadataJson ?? this.metadataJson,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  Space copyWithCompanion(SpacesCompanion data) {
    return Space(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      normalizedName: data.normalizedName.present
          ? data.normalizedName.value
          : this.normalizedName,
      type: data.type.present ? data.type.value : this.type,
      description: data.description.present
          ? data.description.value
          : this.description,
      primaryIntentionType: data.primaryIntentionType.present
          ? data.primaryIntentionType.value
          : this.primaryIntentionType,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      sourceIdsSnapshotJson: data.sourceIdsSnapshotJson.present
          ? data.sourceIdsSnapshotJson.value
          : this.sourceIdsSnapshotJson,
      metadataJson: data.metadataJson.present
          ? data.metadataJson.value
          : this.metadataJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      archivedAt: data.archivedAt.present
          ? data.archivedAt.value
          : this.archivedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Space(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('type: $type, ')
          ..write('description: $description, ')
          ..write('primaryIntentionType: $primaryIntentionType, ')
          ..write('createdBy: $createdBy, ')
          ..write('confidence: $confidence, ')
          ..write('sourceIdsSnapshotJson: $sourceIdsSnapshotJson, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    normalizedName,
    type,
    description,
    primaryIntentionType,
    createdBy,
    confidence,
    sourceIdsSnapshotJson,
    metadataJson,
    createdAt,
    updatedAt,
    archivedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Space &&
          other.id == this.id &&
          other.name == this.name &&
          other.normalizedName == this.normalizedName &&
          other.type == this.type &&
          other.description == this.description &&
          other.primaryIntentionType == this.primaryIntentionType &&
          other.createdBy == this.createdBy &&
          other.confidence == this.confidence &&
          other.sourceIdsSnapshotJson == this.sourceIdsSnapshotJson &&
          other.metadataJson == this.metadataJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.archivedAt == this.archivedAt &&
          other.deletedAt == this.deletedAt);
}

class SpacesCompanion extends UpdateCompanion<Space> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> normalizedName;
  final Value<String> type;
  final Value<String?> description;
  final Value<String?> primaryIntentionType;
  final Value<String> createdBy;
  final Value<double?> confidence;
  final Value<String> sourceIdsSnapshotJson;
  final Value<String> metadataJson;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> archivedAt;
  final Value<int?> deletedAt;
  final Value<int> rowid;
  const SpacesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.normalizedName = const Value.absent(),
    this.type = const Value.absent(),
    this.description = const Value.absent(),
    this.primaryIntentionType = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.confidence = const Value.absent(),
    this.sourceIdsSnapshotJson = const Value.absent(),
    this.metadataJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SpacesCompanion.insert({
    required String id,
    required String name,
    required String normalizedName,
    required String type,
    this.description = const Value.absent(),
    this.primaryIntentionType = const Value.absent(),
    required String createdBy,
    this.confidence = const Value.absent(),
    this.sourceIdsSnapshotJson = const Value.absent(),
    this.metadataJson = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.archivedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       normalizedName = Value(normalizedName),
       type = Value(type),
       createdBy = Value(createdBy),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Space> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? normalizedName,
    Expression<String>? type,
    Expression<String>? description,
    Expression<String>? primaryIntentionType,
    Expression<String>? createdBy,
    Expression<double>? confidence,
    Expression<String>? sourceIdsSnapshotJson,
    Expression<String>? metadataJson,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? archivedAt,
    Expression<int>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (normalizedName != null) 'normalized_name': normalizedName,
      if (type != null) 'type': type,
      if (description != null) 'description': description,
      if (primaryIntentionType != null)
        'primary_intention_type': primaryIntentionType,
      if (createdBy != null) 'created_by': createdBy,
      if (confidence != null) 'confidence': confidence,
      if (sourceIdsSnapshotJson != null)
        'source_ids_snapshot_json': sourceIdsSnapshotJson,
      if (metadataJson != null) 'metadata_json': metadataJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SpacesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? normalizedName,
    Value<String>? type,
    Value<String?>? description,
    Value<String?>? primaryIntentionType,
    Value<String>? createdBy,
    Value<double?>? confidence,
    Value<String>? sourceIdsSnapshotJson,
    Value<String>? metadataJson,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? archivedAt,
    Value<int?>? deletedAt,
    Value<int>? rowid,
  }) {
    return SpacesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      normalizedName: normalizedName ?? this.normalizedName,
      type: type ?? this.type,
      description: description ?? this.description,
      primaryIntentionType: primaryIntentionType ?? this.primaryIntentionType,
      createdBy: createdBy ?? this.createdBy,
      confidence: confidence ?? this.confidence,
      sourceIdsSnapshotJson:
          sourceIdsSnapshotJson ?? this.sourceIdsSnapshotJson,
      metadataJson: metadataJson ?? this.metadataJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedAt: archivedAt ?? this.archivedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (normalizedName.present) {
      map['normalized_name'] = Variable<String>(normalizedName.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (primaryIntentionType.present) {
      map['primary_intention_type'] = Variable<String>(
        primaryIntentionType.value,
      );
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (sourceIdsSnapshotJson.present) {
      map['source_ids_snapshot_json'] = Variable<String>(
        sourceIdsSnapshotJson.value,
      );
    }
    if (metadataJson.present) {
      map['metadata_json'] = Variable<String>(metadataJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<int>(archivedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SpacesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('type: $type, ')
          ..write('description: $description, ')
          ..write('primaryIntentionType: $primaryIntentionType, ')
          ..write('createdBy: $createdBy, ')
          ..write('confidence: $confidence, ')
          ..write('sourceIdsSnapshotJson: $sourceIdsSnapshotJson, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TagCardsTable extends TagCards with TableInfo<$TagCardsTable, TagCard> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagCardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cardTypeMeta = const VerificationMeta(
    'cardType',
  );
  @override
  late final GeneratedColumn<String> cardType = GeneratedColumn<String>(
    'card_type',
    aliasedName,
    false,
    check: () => cardType.isIn(TagDatabaseValues.cardTypes),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    check: () => status.isIn(TagDatabaseValues.cardStatuses),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _spaceIdMeta = const VerificationMeta(
    'spaceId',
  );
  @override
  late final GeneratedColumn<String> spaceId = GeneratedColumn<String>(
    'space_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES spaces (id)',
    ),
  );
  static const VerificationMeta _nextActiveDeadlineMeta =
      const VerificationMeta('nextActiveDeadline');
  @override
  late final GeneratedColumn<int> nextActiveDeadline = GeneratedColumn<int>(
    'next_active_deadline',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deadlineTimezoneMeta = const VerificationMeta(
    'deadlineTimezone',
  );
  @override
  late final GeneratedColumn<String> deadlineTimezone = GeneratedColumn<String>(
    'deadline_timezone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _snoozedUntilMeta = const VerificationMeta(
    'snoozedUntil',
  );
  @override
  late final GeneratedColumn<int> snoozedUntil = GeneratedColumn<int>(
    'snoozed_until',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notificationEnabledMeta =
      const VerificationMeta('notificationEnabled');
  @override
  late final GeneratedColumn<bool> notificationEnabled = GeneratedColumn<bool>(
    'notification_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("notification_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _actionsJsonMeta = const VerificationMeta(
    'actionsJson',
  );
  @override
  late final GeneratedColumn<String> actionsJson = GeneratedColumn<String>(
    'actions_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
    'confidence',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceSummaryMeta = const VerificationMeta(
    'sourceSummary',
  );
  @override
  late final GeneratedColumn<String> sourceSummary = GeneratedColumn<String>(
    'source_summary',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _evidenceSummaryMeta = const VerificationMeta(
    'evidenceSummary',
  );
  @override
  late final GeneratedColumn<String> evidenceSummary = GeneratedColumn<String>(
    'evidence_summary',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parentGoalPlanIdMeta = const VerificationMeta(
    'parentGoalPlanId',
  );
  @override
  late final GeneratedColumn<String> parentGoalPlanId = GeneratedColumn<String>(
    'parent_goal_plan_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _suggestionClusterIdMeta =
      const VerificationMeta('suggestionClusterId');
  @override
  late final GeneratedColumn<String> suggestionClusterId =
      GeneratedColumn<String>(
        'suggestion_cluster_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    false,
    check: () => createdBy.isIn(TagDatabaseValues.cardCreatedBy),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modelSlugMeta = const VerificationMeta(
    'modelSlug',
  );
  @override
  late final GeneratedColumn<String> modelSlug = GeneratedColumn<String>(
    'model_slug',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _modelOutputJsonMeta = const VerificationMeta(
    'modelOutputJson',
  );
  @override
  late final GeneratedColumn<String> modelOutputJson = GeneratedColumn<String>(
    'model_output_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _metadataJsonMeta = const VerificationMeta(
    'metadataJson',
  );
  @override
  late final GeneratedColumn<String> metadataJson = GeneratedColumn<String>(
    'metadata_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<int> completedAt = GeneratedColumn<int>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cancelledAtMeta = const VerificationMeta(
    'cancelledAt',
  );
  @override
  late final GeneratedColumn<int> cancelledAt = GeneratedColumn<int>(
    'cancelled_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dismissedAtMeta = const VerificationMeta(
    'dismissedAt',
  );
  @override
  late final GeneratedColumn<int> dismissedAt = GeneratedColumn<int>(
    'dismissed_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _archivedAtMeta = const VerificationMeta(
    'archivedAt',
  );
  @override
  late final GeneratedColumn<int> archivedAt = GeneratedColumn<int>(
    'archived_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cardType,
    status,
    title,
    reason,
    spaceId,
    nextActiveDeadline,
    deadlineTimezone,
    snoozedUntil,
    notificationEnabled,
    actionsJson,
    confidence,
    sourceSummary,
    evidenceSummary,
    parentGoalPlanId,
    suggestionClusterId,
    createdBy,
    modelSlug,
    modelOutputJson,
    metadataJson,
    createdAt,
    updatedAt,
    completedAt,
    cancelledAt,
    dismissedAt,
    archivedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tag_cards';
  @override
  VerificationContext validateIntegrity(
    Insertable<TagCard> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('card_type')) {
      context.handle(
        _cardTypeMeta,
        cardType.isAcceptableOrUnknown(data['card_type']!, _cardTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_cardTypeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('space_id')) {
      context.handle(
        _spaceIdMeta,
        spaceId.isAcceptableOrUnknown(data['space_id']!, _spaceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_spaceIdMeta);
    }
    if (data.containsKey('next_active_deadline')) {
      context.handle(
        _nextActiveDeadlineMeta,
        nextActiveDeadline.isAcceptableOrUnknown(
          data['next_active_deadline']!,
          _nextActiveDeadlineMeta,
        ),
      );
    }
    if (data.containsKey('deadline_timezone')) {
      context.handle(
        _deadlineTimezoneMeta,
        deadlineTimezone.isAcceptableOrUnknown(
          data['deadline_timezone']!,
          _deadlineTimezoneMeta,
        ),
      );
    }
    if (data.containsKey('snoozed_until')) {
      context.handle(
        _snoozedUntilMeta,
        snoozedUntil.isAcceptableOrUnknown(
          data['snoozed_until']!,
          _snoozedUntilMeta,
        ),
      );
    }
    if (data.containsKey('notification_enabled')) {
      context.handle(
        _notificationEnabledMeta,
        notificationEnabled.isAcceptableOrUnknown(
          data['notification_enabled']!,
          _notificationEnabledMeta,
        ),
      );
    }
    if (data.containsKey('actions_json')) {
      context.handle(
        _actionsJsonMeta,
        actionsJson.isAcceptableOrUnknown(
          data['actions_json']!,
          _actionsJsonMeta,
        ),
      );
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    }
    if (data.containsKey('source_summary')) {
      context.handle(
        _sourceSummaryMeta,
        sourceSummary.isAcceptableOrUnknown(
          data['source_summary']!,
          _sourceSummaryMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceSummaryMeta);
    }
    if (data.containsKey('evidence_summary')) {
      context.handle(
        _evidenceSummaryMeta,
        evidenceSummary.isAcceptableOrUnknown(
          data['evidence_summary']!,
          _evidenceSummaryMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_evidenceSummaryMeta);
    }
    if (data.containsKey('parent_goal_plan_id')) {
      context.handle(
        _parentGoalPlanIdMeta,
        parentGoalPlanId.isAcceptableOrUnknown(
          data['parent_goal_plan_id']!,
          _parentGoalPlanIdMeta,
        ),
      );
    }
    if (data.containsKey('suggestion_cluster_id')) {
      context.handle(
        _suggestionClusterIdMeta,
        suggestionClusterId.isAcceptableOrUnknown(
          data['suggestion_cluster_id']!,
          _suggestionClusterIdMeta,
        ),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('model_slug')) {
      context.handle(
        _modelSlugMeta,
        modelSlug.isAcceptableOrUnknown(data['model_slug']!, _modelSlugMeta),
      );
    }
    if (data.containsKey('model_output_json')) {
      context.handle(
        _modelOutputJsonMeta,
        modelOutputJson.isAcceptableOrUnknown(
          data['model_output_json']!,
          _modelOutputJsonMeta,
        ),
      );
    }
    if (data.containsKey('metadata_json')) {
      context.handle(
        _metadataJsonMeta,
        metadataJson.isAcceptableOrUnknown(
          data['metadata_json']!,
          _metadataJsonMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('cancelled_at')) {
      context.handle(
        _cancelledAtMeta,
        cancelledAt.isAcceptableOrUnknown(
          data['cancelled_at']!,
          _cancelledAtMeta,
        ),
      );
    }
    if (data.containsKey('dismissed_at')) {
      context.handle(
        _dismissedAtMeta,
        dismissedAt.isAcceptableOrUnknown(
          data['dismissed_at']!,
          _dismissedAtMeta,
        ),
      );
    }
    if (data.containsKey('archived_at')) {
      context.handle(
        _archivedAtMeta,
        archivedAt.isAcceptableOrUnknown(data['archived_at']!, _archivedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TagCard map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TagCard(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      cardType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}card_type'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      )!,
      spaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}space_id'],
      )!,
      nextActiveDeadline: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}next_active_deadline'],
      ),
      deadlineTimezone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deadline_timezone'],
      ),
      snoozedUntil: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}snoozed_until'],
      ),
      notificationEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}notification_enabled'],
      )!,
      actionsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}actions_json'],
      )!,
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      ),
      sourceSummary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_summary'],
      )!,
      evidenceSummary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}evidence_summary'],
      )!,
      parentGoalPlanId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_goal_plan_id'],
      ),
      suggestionClusterId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}suggestion_cluster_id'],
      ),
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      )!,
      modelSlug: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_slug'],
      ),
      modelOutputJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_output_json'],
      ),
      metadataJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metadata_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_at'],
      ),
      cancelledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cancelled_at'],
      ),
      dismissedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dismissed_at'],
      ),
      archivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}archived_at'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $TagCardsTable createAlias(String alias) {
    return $TagCardsTable(attachedDatabase, alias);
  }
}

class TagCard extends DataClass implements Insertable<TagCard> {
  final String id;
  final String cardType;
  final String status;
  final String title;
  final String reason;
  final String spaceId;
  final int? nextActiveDeadline;
  final String? deadlineTimezone;
  final int? snoozedUntil;
  final bool notificationEnabled;
  final String actionsJson;
  final double? confidence;
  final String sourceSummary;
  final String evidenceSummary;
  final String? parentGoalPlanId;
  final String? suggestionClusterId;
  final String createdBy;
  final String? modelSlug;
  final String? modelOutputJson;
  final String metadataJson;
  final int createdAt;
  final int updatedAt;
  final int? completedAt;
  final int? cancelledAt;
  final int? dismissedAt;
  final int? archivedAt;
  final int? deletedAt;
  const TagCard({
    required this.id,
    required this.cardType,
    required this.status,
    required this.title,
    required this.reason,
    required this.spaceId,
    this.nextActiveDeadline,
    this.deadlineTimezone,
    this.snoozedUntil,
    required this.notificationEnabled,
    required this.actionsJson,
    this.confidence,
    required this.sourceSummary,
    required this.evidenceSummary,
    this.parentGoalPlanId,
    this.suggestionClusterId,
    required this.createdBy,
    this.modelSlug,
    this.modelOutputJson,
    required this.metadataJson,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
    this.cancelledAt,
    this.dismissedAt,
    this.archivedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['card_type'] = Variable<String>(cardType);
    map['status'] = Variable<String>(status);
    map['title'] = Variable<String>(title);
    map['reason'] = Variable<String>(reason);
    map['space_id'] = Variable<String>(spaceId);
    if (!nullToAbsent || nextActiveDeadline != null) {
      map['next_active_deadline'] = Variable<int>(nextActiveDeadline);
    }
    if (!nullToAbsent || deadlineTimezone != null) {
      map['deadline_timezone'] = Variable<String>(deadlineTimezone);
    }
    if (!nullToAbsent || snoozedUntil != null) {
      map['snoozed_until'] = Variable<int>(snoozedUntil);
    }
    map['notification_enabled'] = Variable<bool>(notificationEnabled);
    map['actions_json'] = Variable<String>(actionsJson);
    if (!nullToAbsent || confidence != null) {
      map['confidence'] = Variable<double>(confidence);
    }
    map['source_summary'] = Variable<String>(sourceSummary);
    map['evidence_summary'] = Variable<String>(evidenceSummary);
    if (!nullToAbsent || parentGoalPlanId != null) {
      map['parent_goal_plan_id'] = Variable<String>(parentGoalPlanId);
    }
    if (!nullToAbsent || suggestionClusterId != null) {
      map['suggestion_cluster_id'] = Variable<String>(suggestionClusterId);
    }
    map['created_by'] = Variable<String>(createdBy);
    if (!nullToAbsent || modelSlug != null) {
      map['model_slug'] = Variable<String>(modelSlug);
    }
    if (!nullToAbsent || modelOutputJson != null) {
      map['model_output_json'] = Variable<String>(modelOutputJson);
    }
    map['metadata_json'] = Variable<String>(metadataJson);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<int>(completedAt);
    }
    if (!nullToAbsent || cancelledAt != null) {
      map['cancelled_at'] = Variable<int>(cancelledAt);
    }
    if (!nullToAbsent || dismissedAt != null) {
      map['dismissed_at'] = Variable<int>(dismissedAt);
    }
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<int>(archivedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    return map;
  }

  TagCardsCompanion toCompanion(bool nullToAbsent) {
    return TagCardsCompanion(
      id: Value(id),
      cardType: Value(cardType),
      status: Value(status),
      title: Value(title),
      reason: Value(reason),
      spaceId: Value(spaceId),
      nextActiveDeadline: nextActiveDeadline == null && nullToAbsent
          ? const Value.absent()
          : Value(nextActiveDeadline),
      deadlineTimezone: deadlineTimezone == null && nullToAbsent
          ? const Value.absent()
          : Value(deadlineTimezone),
      snoozedUntil: snoozedUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(snoozedUntil),
      notificationEnabled: Value(notificationEnabled),
      actionsJson: Value(actionsJson),
      confidence: confidence == null && nullToAbsent
          ? const Value.absent()
          : Value(confidence),
      sourceSummary: Value(sourceSummary),
      evidenceSummary: Value(evidenceSummary),
      parentGoalPlanId: parentGoalPlanId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentGoalPlanId),
      suggestionClusterId: suggestionClusterId == null && nullToAbsent
          ? const Value.absent()
          : Value(suggestionClusterId),
      createdBy: Value(createdBy),
      modelSlug: modelSlug == null && nullToAbsent
          ? const Value.absent()
          : Value(modelSlug),
      modelOutputJson: modelOutputJson == null && nullToAbsent
          ? const Value.absent()
          : Value(modelOutputJson),
      metadataJson: Value(metadataJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      cancelledAt: cancelledAt == null && nullToAbsent
          ? const Value.absent()
          : Value(cancelledAt),
      dismissedAt: dismissedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(dismissedAt),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory TagCard.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TagCard(
      id: serializer.fromJson<String>(json['id']),
      cardType: serializer.fromJson<String>(json['cardType']),
      status: serializer.fromJson<String>(json['status']),
      title: serializer.fromJson<String>(json['title']),
      reason: serializer.fromJson<String>(json['reason']),
      spaceId: serializer.fromJson<String>(json['spaceId']),
      nextActiveDeadline: serializer.fromJson<int?>(json['nextActiveDeadline']),
      deadlineTimezone: serializer.fromJson<String?>(json['deadlineTimezone']),
      snoozedUntil: serializer.fromJson<int?>(json['snoozedUntil']),
      notificationEnabled: serializer.fromJson<bool>(
        json['notificationEnabled'],
      ),
      actionsJson: serializer.fromJson<String>(json['actionsJson']),
      confidence: serializer.fromJson<double?>(json['confidence']),
      sourceSummary: serializer.fromJson<String>(json['sourceSummary']),
      evidenceSummary: serializer.fromJson<String>(json['evidenceSummary']),
      parentGoalPlanId: serializer.fromJson<String?>(json['parentGoalPlanId']),
      suggestionClusterId: serializer.fromJson<String?>(
        json['suggestionClusterId'],
      ),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      modelSlug: serializer.fromJson<String?>(json['modelSlug']),
      modelOutputJson: serializer.fromJson<String?>(json['modelOutputJson']),
      metadataJson: serializer.fromJson<String>(json['metadataJson']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      completedAt: serializer.fromJson<int?>(json['completedAt']),
      cancelledAt: serializer.fromJson<int?>(json['cancelledAt']),
      dismissedAt: serializer.fromJson<int?>(json['dismissedAt']),
      archivedAt: serializer.fromJson<int?>(json['archivedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'cardType': serializer.toJson<String>(cardType),
      'status': serializer.toJson<String>(status),
      'title': serializer.toJson<String>(title),
      'reason': serializer.toJson<String>(reason),
      'spaceId': serializer.toJson<String>(spaceId),
      'nextActiveDeadline': serializer.toJson<int?>(nextActiveDeadline),
      'deadlineTimezone': serializer.toJson<String?>(deadlineTimezone),
      'snoozedUntil': serializer.toJson<int?>(snoozedUntil),
      'notificationEnabled': serializer.toJson<bool>(notificationEnabled),
      'actionsJson': serializer.toJson<String>(actionsJson),
      'confidence': serializer.toJson<double?>(confidence),
      'sourceSummary': serializer.toJson<String>(sourceSummary),
      'evidenceSummary': serializer.toJson<String>(evidenceSummary),
      'parentGoalPlanId': serializer.toJson<String?>(parentGoalPlanId),
      'suggestionClusterId': serializer.toJson<String?>(suggestionClusterId),
      'createdBy': serializer.toJson<String>(createdBy),
      'modelSlug': serializer.toJson<String?>(modelSlug),
      'modelOutputJson': serializer.toJson<String?>(modelOutputJson),
      'metadataJson': serializer.toJson<String>(metadataJson),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'completedAt': serializer.toJson<int?>(completedAt),
      'cancelledAt': serializer.toJson<int?>(cancelledAt),
      'dismissedAt': serializer.toJson<int?>(dismissedAt),
      'archivedAt': serializer.toJson<int?>(archivedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
    };
  }

  TagCard copyWith({
    String? id,
    String? cardType,
    String? status,
    String? title,
    String? reason,
    String? spaceId,
    Value<int?> nextActiveDeadline = const Value.absent(),
    Value<String?> deadlineTimezone = const Value.absent(),
    Value<int?> snoozedUntil = const Value.absent(),
    bool? notificationEnabled,
    String? actionsJson,
    Value<double?> confidence = const Value.absent(),
    String? sourceSummary,
    String? evidenceSummary,
    Value<String?> parentGoalPlanId = const Value.absent(),
    Value<String?> suggestionClusterId = const Value.absent(),
    String? createdBy,
    Value<String?> modelSlug = const Value.absent(),
    Value<String?> modelOutputJson = const Value.absent(),
    String? metadataJson,
    int? createdAt,
    int? updatedAt,
    Value<int?> completedAt = const Value.absent(),
    Value<int?> cancelledAt = const Value.absent(),
    Value<int?> dismissedAt = const Value.absent(),
    Value<int?> archivedAt = const Value.absent(),
    Value<int?> deletedAt = const Value.absent(),
  }) => TagCard(
    id: id ?? this.id,
    cardType: cardType ?? this.cardType,
    status: status ?? this.status,
    title: title ?? this.title,
    reason: reason ?? this.reason,
    spaceId: spaceId ?? this.spaceId,
    nextActiveDeadline: nextActiveDeadline.present
        ? nextActiveDeadline.value
        : this.nextActiveDeadline,
    deadlineTimezone: deadlineTimezone.present
        ? deadlineTimezone.value
        : this.deadlineTimezone,
    snoozedUntil: snoozedUntil.present ? snoozedUntil.value : this.snoozedUntil,
    notificationEnabled: notificationEnabled ?? this.notificationEnabled,
    actionsJson: actionsJson ?? this.actionsJson,
    confidence: confidence.present ? confidence.value : this.confidence,
    sourceSummary: sourceSummary ?? this.sourceSummary,
    evidenceSummary: evidenceSummary ?? this.evidenceSummary,
    parentGoalPlanId: parentGoalPlanId.present
        ? parentGoalPlanId.value
        : this.parentGoalPlanId,
    suggestionClusterId: suggestionClusterId.present
        ? suggestionClusterId.value
        : this.suggestionClusterId,
    createdBy: createdBy ?? this.createdBy,
    modelSlug: modelSlug.present ? modelSlug.value : this.modelSlug,
    modelOutputJson: modelOutputJson.present
        ? modelOutputJson.value
        : this.modelOutputJson,
    metadataJson: metadataJson ?? this.metadataJson,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    cancelledAt: cancelledAt.present ? cancelledAt.value : this.cancelledAt,
    dismissedAt: dismissedAt.present ? dismissedAt.value : this.dismissedAt,
    archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  TagCard copyWithCompanion(TagCardsCompanion data) {
    return TagCard(
      id: data.id.present ? data.id.value : this.id,
      cardType: data.cardType.present ? data.cardType.value : this.cardType,
      status: data.status.present ? data.status.value : this.status,
      title: data.title.present ? data.title.value : this.title,
      reason: data.reason.present ? data.reason.value : this.reason,
      spaceId: data.spaceId.present ? data.spaceId.value : this.spaceId,
      nextActiveDeadline: data.nextActiveDeadline.present
          ? data.nextActiveDeadline.value
          : this.nextActiveDeadline,
      deadlineTimezone: data.deadlineTimezone.present
          ? data.deadlineTimezone.value
          : this.deadlineTimezone,
      snoozedUntil: data.snoozedUntil.present
          ? data.snoozedUntil.value
          : this.snoozedUntil,
      notificationEnabled: data.notificationEnabled.present
          ? data.notificationEnabled.value
          : this.notificationEnabled,
      actionsJson: data.actionsJson.present
          ? data.actionsJson.value
          : this.actionsJson,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      sourceSummary: data.sourceSummary.present
          ? data.sourceSummary.value
          : this.sourceSummary,
      evidenceSummary: data.evidenceSummary.present
          ? data.evidenceSummary.value
          : this.evidenceSummary,
      parentGoalPlanId: data.parentGoalPlanId.present
          ? data.parentGoalPlanId.value
          : this.parentGoalPlanId,
      suggestionClusterId: data.suggestionClusterId.present
          ? data.suggestionClusterId.value
          : this.suggestionClusterId,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      modelSlug: data.modelSlug.present ? data.modelSlug.value : this.modelSlug,
      modelOutputJson: data.modelOutputJson.present
          ? data.modelOutputJson.value
          : this.modelOutputJson,
      metadataJson: data.metadataJson.present
          ? data.metadataJson.value
          : this.metadataJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      cancelledAt: data.cancelledAt.present
          ? data.cancelledAt.value
          : this.cancelledAt,
      dismissedAt: data.dismissedAt.present
          ? data.dismissedAt.value
          : this.dismissedAt,
      archivedAt: data.archivedAt.present
          ? data.archivedAt.value
          : this.archivedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TagCard(')
          ..write('id: $id, ')
          ..write('cardType: $cardType, ')
          ..write('status: $status, ')
          ..write('title: $title, ')
          ..write('reason: $reason, ')
          ..write('spaceId: $spaceId, ')
          ..write('nextActiveDeadline: $nextActiveDeadline, ')
          ..write('deadlineTimezone: $deadlineTimezone, ')
          ..write('snoozedUntil: $snoozedUntil, ')
          ..write('notificationEnabled: $notificationEnabled, ')
          ..write('actionsJson: $actionsJson, ')
          ..write('confidence: $confidence, ')
          ..write('sourceSummary: $sourceSummary, ')
          ..write('evidenceSummary: $evidenceSummary, ')
          ..write('parentGoalPlanId: $parentGoalPlanId, ')
          ..write('suggestionClusterId: $suggestionClusterId, ')
          ..write('createdBy: $createdBy, ')
          ..write('modelSlug: $modelSlug, ')
          ..write('modelOutputJson: $modelOutputJson, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('cancelledAt: $cancelledAt, ')
          ..write('dismissedAt: $dismissedAt, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    cardType,
    status,
    title,
    reason,
    spaceId,
    nextActiveDeadline,
    deadlineTimezone,
    snoozedUntil,
    notificationEnabled,
    actionsJson,
    confidence,
    sourceSummary,
    evidenceSummary,
    parentGoalPlanId,
    suggestionClusterId,
    createdBy,
    modelSlug,
    modelOutputJson,
    metadataJson,
    createdAt,
    updatedAt,
    completedAt,
    cancelledAt,
    dismissedAt,
    archivedAt,
    deletedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TagCard &&
          other.id == this.id &&
          other.cardType == this.cardType &&
          other.status == this.status &&
          other.title == this.title &&
          other.reason == this.reason &&
          other.spaceId == this.spaceId &&
          other.nextActiveDeadline == this.nextActiveDeadline &&
          other.deadlineTimezone == this.deadlineTimezone &&
          other.snoozedUntil == this.snoozedUntil &&
          other.notificationEnabled == this.notificationEnabled &&
          other.actionsJson == this.actionsJson &&
          other.confidence == this.confidence &&
          other.sourceSummary == this.sourceSummary &&
          other.evidenceSummary == this.evidenceSummary &&
          other.parentGoalPlanId == this.parentGoalPlanId &&
          other.suggestionClusterId == this.suggestionClusterId &&
          other.createdBy == this.createdBy &&
          other.modelSlug == this.modelSlug &&
          other.modelOutputJson == this.modelOutputJson &&
          other.metadataJson == this.metadataJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.completedAt == this.completedAt &&
          other.cancelledAt == this.cancelledAt &&
          other.dismissedAt == this.dismissedAt &&
          other.archivedAt == this.archivedAt &&
          other.deletedAt == this.deletedAt);
}

class TagCardsCompanion extends UpdateCompanion<TagCard> {
  final Value<String> id;
  final Value<String> cardType;
  final Value<String> status;
  final Value<String> title;
  final Value<String> reason;
  final Value<String> spaceId;
  final Value<int?> nextActiveDeadline;
  final Value<String?> deadlineTimezone;
  final Value<int?> snoozedUntil;
  final Value<bool> notificationEnabled;
  final Value<String> actionsJson;
  final Value<double?> confidence;
  final Value<String> sourceSummary;
  final Value<String> evidenceSummary;
  final Value<String?> parentGoalPlanId;
  final Value<String?> suggestionClusterId;
  final Value<String> createdBy;
  final Value<String?> modelSlug;
  final Value<String?> modelOutputJson;
  final Value<String> metadataJson;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> completedAt;
  final Value<int?> cancelledAt;
  final Value<int?> dismissedAt;
  final Value<int?> archivedAt;
  final Value<int?> deletedAt;
  final Value<int> rowid;
  const TagCardsCompanion({
    this.id = const Value.absent(),
    this.cardType = const Value.absent(),
    this.status = const Value.absent(),
    this.title = const Value.absent(),
    this.reason = const Value.absent(),
    this.spaceId = const Value.absent(),
    this.nextActiveDeadline = const Value.absent(),
    this.deadlineTimezone = const Value.absent(),
    this.snoozedUntil = const Value.absent(),
    this.notificationEnabled = const Value.absent(),
    this.actionsJson = const Value.absent(),
    this.confidence = const Value.absent(),
    this.sourceSummary = const Value.absent(),
    this.evidenceSummary = const Value.absent(),
    this.parentGoalPlanId = const Value.absent(),
    this.suggestionClusterId = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.modelSlug = const Value.absent(),
    this.modelOutputJson = const Value.absent(),
    this.metadataJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.cancelledAt = const Value.absent(),
    this.dismissedAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TagCardsCompanion.insert({
    required String id,
    required String cardType,
    this.status = const Value.absent(),
    required String title,
    required String reason,
    required String spaceId,
    this.nextActiveDeadline = const Value.absent(),
    this.deadlineTimezone = const Value.absent(),
    this.snoozedUntil = const Value.absent(),
    this.notificationEnabled = const Value.absent(),
    this.actionsJson = const Value.absent(),
    this.confidence = const Value.absent(),
    required String sourceSummary,
    required String evidenceSummary,
    this.parentGoalPlanId = const Value.absent(),
    this.suggestionClusterId = const Value.absent(),
    required String createdBy,
    this.modelSlug = const Value.absent(),
    this.modelOutputJson = const Value.absent(),
    this.metadataJson = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.completedAt = const Value.absent(),
    this.cancelledAt = const Value.absent(),
    this.dismissedAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       cardType = Value(cardType),
       title = Value(title),
       reason = Value(reason),
       spaceId = Value(spaceId),
       sourceSummary = Value(sourceSummary),
       evidenceSummary = Value(evidenceSummary),
       createdBy = Value(createdBy),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<TagCard> custom({
    Expression<String>? id,
    Expression<String>? cardType,
    Expression<String>? status,
    Expression<String>? title,
    Expression<String>? reason,
    Expression<String>? spaceId,
    Expression<int>? nextActiveDeadline,
    Expression<String>? deadlineTimezone,
    Expression<int>? snoozedUntil,
    Expression<bool>? notificationEnabled,
    Expression<String>? actionsJson,
    Expression<double>? confidence,
    Expression<String>? sourceSummary,
    Expression<String>? evidenceSummary,
    Expression<String>? parentGoalPlanId,
    Expression<String>? suggestionClusterId,
    Expression<String>? createdBy,
    Expression<String>? modelSlug,
    Expression<String>? modelOutputJson,
    Expression<String>? metadataJson,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? completedAt,
    Expression<int>? cancelledAt,
    Expression<int>? dismissedAt,
    Expression<int>? archivedAt,
    Expression<int>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cardType != null) 'card_type': cardType,
      if (status != null) 'status': status,
      if (title != null) 'title': title,
      if (reason != null) 'reason': reason,
      if (spaceId != null) 'space_id': spaceId,
      if (nextActiveDeadline != null)
        'next_active_deadline': nextActiveDeadline,
      if (deadlineTimezone != null) 'deadline_timezone': deadlineTimezone,
      if (snoozedUntil != null) 'snoozed_until': snoozedUntil,
      if (notificationEnabled != null)
        'notification_enabled': notificationEnabled,
      if (actionsJson != null) 'actions_json': actionsJson,
      if (confidence != null) 'confidence': confidence,
      if (sourceSummary != null) 'source_summary': sourceSummary,
      if (evidenceSummary != null) 'evidence_summary': evidenceSummary,
      if (parentGoalPlanId != null) 'parent_goal_plan_id': parentGoalPlanId,
      if (suggestionClusterId != null)
        'suggestion_cluster_id': suggestionClusterId,
      if (createdBy != null) 'created_by': createdBy,
      if (modelSlug != null) 'model_slug': modelSlug,
      if (modelOutputJson != null) 'model_output_json': modelOutputJson,
      if (metadataJson != null) 'metadata_json': metadataJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (cancelledAt != null) 'cancelled_at': cancelledAt,
      if (dismissedAt != null) 'dismissed_at': dismissedAt,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TagCardsCompanion copyWith({
    Value<String>? id,
    Value<String>? cardType,
    Value<String>? status,
    Value<String>? title,
    Value<String>? reason,
    Value<String>? spaceId,
    Value<int?>? nextActiveDeadline,
    Value<String?>? deadlineTimezone,
    Value<int?>? snoozedUntil,
    Value<bool>? notificationEnabled,
    Value<String>? actionsJson,
    Value<double?>? confidence,
    Value<String>? sourceSummary,
    Value<String>? evidenceSummary,
    Value<String?>? parentGoalPlanId,
    Value<String?>? suggestionClusterId,
    Value<String>? createdBy,
    Value<String?>? modelSlug,
    Value<String?>? modelOutputJson,
    Value<String>? metadataJson,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? completedAt,
    Value<int?>? cancelledAt,
    Value<int?>? dismissedAt,
    Value<int?>? archivedAt,
    Value<int?>? deletedAt,
    Value<int>? rowid,
  }) {
    return TagCardsCompanion(
      id: id ?? this.id,
      cardType: cardType ?? this.cardType,
      status: status ?? this.status,
      title: title ?? this.title,
      reason: reason ?? this.reason,
      spaceId: spaceId ?? this.spaceId,
      nextActiveDeadline: nextActiveDeadline ?? this.nextActiveDeadline,
      deadlineTimezone: deadlineTimezone ?? this.deadlineTimezone,
      snoozedUntil: snoozedUntil ?? this.snoozedUntil,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      actionsJson: actionsJson ?? this.actionsJson,
      confidence: confidence ?? this.confidence,
      sourceSummary: sourceSummary ?? this.sourceSummary,
      evidenceSummary: evidenceSummary ?? this.evidenceSummary,
      parentGoalPlanId: parentGoalPlanId ?? this.parentGoalPlanId,
      suggestionClusterId: suggestionClusterId ?? this.suggestionClusterId,
      createdBy: createdBy ?? this.createdBy,
      modelSlug: modelSlug ?? this.modelSlug,
      modelOutputJson: modelOutputJson ?? this.modelOutputJson,
      metadataJson: metadataJson ?? this.metadataJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      dismissedAt: dismissedAt ?? this.dismissedAt,
      archivedAt: archivedAt ?? this.archivedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (cardType.present) {
      map['card_type'] = Variable<String>(cardType.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (spaceId.present) {
      map['space_id'] = Variable<String>(spaceId.value);
    }
    if (nextActiveDeadline.present) {
      map['next_active_deadline'] = Variable<int>(nextActiveDeadline.value);
    }
    if (deadlineTimezone.present) {
      map['deadline_timezone'] = Variable<String>(deadlineTimezone.value);
    }
    if (snoozedUntil.present) {
      map['snoozed_until'] = Variable<int>(snoozedUntil.value);
    }
    if (notificationEnabled.present) {
      map['notification_enabled'] = Variable<bool>(notificationEnabled.value);
    }
    if (actionsJson.present) {
      map['actions_json'] = Variable<String>(actionsJson.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (sourceSummary.present) {
      map['source_summary'] = Variable<String>(sourceSummary.value);
    }
    if (evidenceSummary.present) {
      map['evidence_summary'] = Variable<String>(evidenceSummary.value);
    }
    if (parentGoalPlanId.present) {
      map['parent_goal_plan_id'] = Variable<String>(parentGoalPlanId.value);
    }
    if (suggestionClusterId.present) {
      map['suggestion_cluster_id'] = Variable<String>(
        suggestionClusterId.value,
      );
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (modelSlug.present) {
      map['model_slug'] = Variable<String>(modelSlug.value);
    }
    if (modelOutputJson.present) {
      map['model_output_json'] = Variable<String>(modelOutputJson.value);
    }
    if (metadataJson.present) {
      map['metadata_json'] = Variable<String>(metadataJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<int>(completedAt.value);
    }
    if (cancelledAt.present) {
      map['cancelled_at'] = Variable<int>(cancelledAt.value);
    }
    if (dismissedAt.present) {
      map['dismissed_at'] = Variable<int>(dismissedAt.value);
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<int>(archivedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagCardsCompanion(')
          ..write('id: $id, ')
          ..write('cardType: $cardType, ')
          ..write('status: $status, ')
          ..write('title: $title, ')
          ..write('reason: $reason, ')
          ..write('spaceId: $spaceId, ')
          ..write('nextActiveDeadline: $nextActiveDeadline, ')
          ..write('deadlineTimezone: $deadlineTimezone, ')
          ..write('snoozedUntil: $snoozedUntil, ')
          ..write('notificationEnabled: $notificationEnabled, ')
          ..write('actionsJson: $actionsJson, ')
          ..write('confidence: $confidence, ')
          ..write('sourceSummary: $sourceSummary, ')
          ..write('evidenceSummary: $evidenceSummary, ')
          ..write('parentGoalPlanId: $parentGoalPlanId, ')
          ..write('suggestionClusterId: $suggestionClusterId, ')
          ..write('createdBy: $createdBy, ')
          ..write('modelSlug: $modelSlug, ')
          ..write('modelOutputJson: $modelOutputJson, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('cancelledAt: $cancelledAt, ')
          ..write('dismissedAt: $dismissedAt, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CardSourcesTable extends CardSources
    with TableInfo<$CardSourcesTable, CardSource> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CardSourcesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
  @override
  late final GeneratedColumn<String> cardId = GeneratedColumn<String>(
    'card_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tag_cards (id)',
    ),
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES source_items (id)',
    ),
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    check: () => role.isIn(TagDatabaseValues.cardSourceRoles),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _evidenceTextMeta = const VerificationMeta(
    'evidenceText',
  );
  @override
  late final GeneratedColumn<String> evidenceText = GeneratedColumn<String>(
    'evidence_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    cardId,
    sourceId,
    role,
    evidenceText,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'card_sources';
  @override
  VerificationContext validateIntegrity(
    Insertable<CardSource> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('card_id')) {
      context.handle(
        _cardIdMeta,
        cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cardIdMeta);
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('evidence_text')) {
      context.handle(
        _evidenceTextMeta,
        evidenceText.isAcceptableOrUnknown(
          data['evidence_text']!,
          _evidenceTextMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {cardId, sourceId};
  @override
  CardSource map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CardSource(
      cardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}card_id'],
      )!,
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      evidenceText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}evidence_text'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CardSourcesTable createAlias(String alias) {
    return $CardSourcesTable(attachedDatabase, alias);
  }
}

class CardSource extends DataClass implements Insertable<CardSource> {
  final String cardId;
  final String sourceId;
  final String role;
  final String? evidenceText;
  final int createdAt;
  const CardSource({
    required this.cardId,
    required this.sourceId,
    required this.role,
    this.evidenceText,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['card_id'] = Variable<String>(cardId);
    map['source_id'] = Variable<String>(sourceId);
    map['role'] = Variable<String>(role);
    if (!nullToAbsent || evidenceText != null) {
      map['evidence_text'] = Variable<String>(evidenceText);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  CardSourcesCompanion toCompanion(bool nullToAbsent) {
    return CardSourcesCompanion(
      cardId: Value(cardId),
      sourceId: Value(sourceId),
      role: Value(role),
      evidenceText: evidenceText == null && nullToAbsent
          ? const Value.absent()
          : Value(evidenceText),
      createdAt: Value(createdAt),
    );
  }

  factory CardSource.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CardSource(
      cardId: serializer.fromJson<String>(json['cardId']),
      sourceId: serializer.fromJson<String>(json['sourceId']),
      role: serializer.fromJson<String>(json['role']),
      evidenceText: serializer.fromJson<String?>(json['evidenceText']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'cardId': serializer.toJson<String>(cardId),
      'sourceId': serializer.toJson<String>(sourceId),
      'role': serializer.toJson<String>(role),
      'evidenceText': serializer.toJson<String?>(evidenceText),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  CardSource copyWith({
    String? cardId,
    String? sourceId,
    String? role,
    Value<String?> evidenceText = const Value.absent(),
    int? createdAt,
  }) => CardSource(
    cardId: cardId ?? this.cardId,
    sourceId: sourceId ?? this.sourceId,
    role: role ?? this.role,
    evidenceText: evidenceText.present ? evidenceText.value : this.evidenceText,
    createdAt: createdAt ?? this.createdAt,
  );
  CardSource copyWithCompanion(CardSourcesCompanion data) {
    return CardSource(
      cardId: data.cardId.present ? data.cardId.value : this.cardId,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      role: data.role.present ? data.role.value : this.role,
      evidenceText: data.evidenceText.present
          ? data.evidenceText.value
          : this.evidenceText,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CardSource(')
          ..write('cardId: $cardId, ')
          ..write('sourceId: $sourceId, ')
          ..write('role: $role, ')
          ..write('evidenceText: $evidenceText, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(cardId, sourceId, role, evidenceText, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CardSource &&
          other.cardId == this.cardId &&
          other.sourceId == this.sourceId &&
          other.role == this.role &&
          other.evidenceText == this.evidenceText &&
          other.createdAt == this.createdAt);
}

class CardSourcesCompanion extends UpdateCompanion<CardSource> {
  final Value<String> cardId;
  final Value<String> sourceId;
  final Value<String> role;
  final Value<String?> evidenceText;
  final Value<int> createdAt;
  final Value<int> rowid;
  const CardSourcesCompanion({
    this.cardId = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.role = const Value.absent(),
    this.evidenceText = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CardSourcesCompanion.insert({
    required String cardId,
    required String sourceId,
    required String role,
    this.evidenceText = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : cardId = Value(cardId),
       sourceId = Value(sourceId),
       role = Value(role),
       createdAt = Value(createdAt);
  static Insertable<CardSource> custom({
    Expression<String>? cardId,
    Expression<String>? sourceId,
    Expression<String>? role,
    Expression<String>? evidenceText,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (cardId != null) 'card_id': cardId,
      if (sourceId != null) 'source_id': sourceId,
      if (role != null) 'role': role,
      if (evidenceText != null) 'evidence_text': evidenceText,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CardSourcesCompanion copyWith({
    Value<String>? cardId,
    Value<String>? sourceId,
    Value<String>? role,
    Value<String?>? evidenceText,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return CardSourcesCompanion(
      cardId: cardId ?? this.cardId,
      sourceId: sourceId ?? this.sourceId,
      role: role ?? this.role,
      evidenceText: evidenceText ?? this.evidenceText,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (cardId.present) {
      map['card_id'] = Variable<String>(cardId.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (evidenceText.present) {
      map['evidence_text'] = Variable<String>(evidenceText.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CardSourcesCompanion(')
          ..write('cardId: $cardId, ')
          ..write('sourceId: $sourceId, ')
          ..write('role: $role, ')
          ..write('evidenceText: $evidenceText, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GoalPlansTable extends GoalPlans
    with TableInfo<$GoalPlansTable, GoalPlan> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GoalPlansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _spaceIdMeta = const VerificationMeta(
    'spaceId',
  );
  @override
  late final GeneratedColumn<String> spaceId = GeneratedColumn<String>(
    'space_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES spaces (id)',
    ),
  );
  static const VerificationMeta _originCardIdMeta = const VerificationMeta(
    'originCardId',
  );
  @override
  late final GeneratedColumn<String> originCardId = GeneratedColumn<String>(
    'origin_card_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _chatSessionIdMeta = const VerificationMeta(
    'chatSessionId',
  );
  @override
  late final GeneratedColumn<String> chatSessionId = GeneratedColumn<String>(
    'chat_session_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationWeeksMeta = const VerificationMeta(
    'durationWeeks',
  );
  @override
  late final GeneratedColumn<int> durationWeeks = GeneratedColumn<int>(
    'duration_weeks',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _preferredDaysJsonMeta = const VerificationMeta(
    'preferredDaysJson',
  );
  @override
  late final GeneratedColumn<String> preferredDaysJson =
      GeneratedColumn<String>(
        'preferred_days_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  static const VerificationMeta _sessionLengthMinutesMeta =
      const VerificationMeta('sessionLengthMinutes');
  @override
  late final GeneratedColumn<int> sessionLengthMinutes = GeneratedColumn<int>(
    'session_length_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reminderPreferenceJsonMeta =
      const VerificationMeta('reminderPreferenceJson');
  @override
  late final GeneratedColumn<String> reminderPreferenceJson =
      GeneratedColumn<String>(
        'reminder_preference_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('{}'),
      );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    check: () => status.isIn(TagDatabaseValues.goalPlanStatuses),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    false,
    check: () => createdBy.isIn(TagDatabaseValues.goalPlanCreatedBy),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modelSlugMeta = const VerificationMeta(
    'modelSlug',
  );
  @override
  late final GeneratedColumn<String> modelSlug = GeneratedColumn<String>(
    'model_slug',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _planPreviewJsonMeta = const VerificationMeta(
    'planPreviewJson',
  );
  @override
  late final GeneratedColumn<String> planPreviewJson = GeneratedColumn<String>(
    'plan_preview_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<int> completedAt = GeneratedColumn<int>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cancelledAtMeta = const VerificationMeta(
    'cancelledAt',
  );
  @override
  late final GeneratedColumn<int> cancelledAt = GeneratedColumn<int>(
    'cancelled_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    spaceId,
    originCardId,
    chatSessionId,
    name,
    description,
    durationWeeks,
    preferredDaysJson,
    sessionLengthMinutes,
    reminderPreferenceJson,
    status,
    createdBy,
    modelSlug,
    planPreviewJson,
    createdAt,
    updatedAt,
    completedAt,
    cancelledAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'goal_plans';
  @override
  VerificationContext validateIntegrity(
    Insertable<GoalPlan> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('space_id')) {
      context.handle(
        _spaceIdMeta,
        spaceId.isAcceptableOrUnknown(data['space_id']!, _spaceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_spaceIdMeta);
    }
    if (data.containsKey('origin_card_id')) {
      context.handle(
        _originCardIdMeta,
        originCardId.isAcceptableOrUnknown(
          data['origin_card_id']!,
          _originCardIdMeta,
        ),
      );
    }
    if (data.containsKey('chat_session_id')) {
      context.handle(
        _chatSessionIdMeta,
        chatSessionId.isAcceptableOrUnknown(
          data['chat_session_id']!,
          _chatSessionIdMeta,
        ),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('duration_weeks')) {
      context.handle(
        _durationWeeksMeta,
        durationWeeks.isAcceptableOrUnknown(
          data['duration_weeks']!,
          _durationWeeksMeta,
        ),
      );
    }
    if (data.containsKey('preferred_days_json')) {
      context.handle(
        _preferredDaysJsonMeta,
        preferredDaysJson.isAcceptableOrUnknown(
          data['preferred_days_json']!,
          _preferredDaysJsonMeta,
        ),
      );
    }
    if (data.containsKey('session_length_minutes')) {
      context.handle(
        _sessionLengthMinutesMeta,
        sessionLengthMinutes.isAcceptableOrUnknown(
          data['session_length_minutes']!,
          _sessionLengthMinutesMeta,
        ),
      );
    }
    if (data.containsKey('reminder_preference_json')) {
      context.handle(
        _reminderPreferenceJsonMeta,
        reminderPreferenceJson.isAcceptableOrUnknown(
          data['reminder_preference_json']!,
          _reminderPreferenceJsonMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('model_slug')) {
      context.handle(
        _modelSlugMeta,
        modelSlug.isAcceptableOrUnknown(data['model_slug']!, _modelSlugMeta),
      );
    }
    if (data.containsKey('plan_preview_json')) {
      context.handle(
        _planPreviewJsonMeta,
        planPreviewJson.isAcceptableOrUnknown(
          data['plan_preview_json']!,
          _planPreviewJsonMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('cancelled_at')) {
      context.handle(
        _cancelledAtMeta,
        cancelledAt.isAcceptableOrUnknown(
          data['cancelled_at']!,
          _cancelledAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GoalPlan map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GoalPlan(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      spaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}space_id'],
      )!,
      originCardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin_card_id'],
      ),
      chatSessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chat_session_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      durationWeeks: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_weeks'],
      ),
      preferredDaysJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}preferred_days_json'],
      )!,
      sessionLengthMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_length_minutes'],
      ),
      reminderPreferenceJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reminder_preference_json'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      )!,
      modelSlug: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_slug'],
      ),
      planPreviewJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plan_preview_json'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_at'],
      ),
      cancelledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cancelled_at'],
      ),
    );
  }

  @override
  $GoalPlansTable createAlias(String alias) {
    return $GoalPlansTable(attachedDatabase, alias);
  }
}

class GoalPlan extends DataClass implements Insertable<GoalPlan> {
  final String id;
  final String spaceId;
  final String? originCardId;
  final String? chatSessionId;
  final String name;
  final String? description;
  final int? durationWeeks;
  final String preferredDaysJson;
  final int? sessionLengthMinutes;
  final String reminderPreferenceJson;
  final String status;
  final String createdBy;
  final String? modelSlug;
  final String? planPreviewJson;
  final int createdAt;
  final int updatedAt;
  final int? completedAt;
  final int? cancelledAt;
  const GoalPlan({
    required this.id,
    required this.spaceId,
    this.originCardId,
    this.chatSessionId,
    required this.name,
    this.description,
    this.durationWeeks,
    required this.preferredDaysJson,
    this.sessionLengthMinutes,
    required this.reminderPreferenceJson,
    required this.status,
    required this.createdBy,
    this.modelSlug,
    this.planPreviewJson,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
    this.cancelledAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['space_id'] = Variable<String>(spaceId);
    if (!nullToAbsent || originCardId != null) {
      map['origin_card_id'] = Variable<String>(originCardId);
    }
    if (!nullToAbsent || chatSessionId != null) {
      map['chat_session_id'] = Variable<String>(chatSessionId);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || durationWeeks != null) {
      map['duration_weeks'] = Variable<int>(durationWeeks);
    }
    map['preferred_days_json'] = Variable<String>(preferredDaysJson);
    if (!nullToAbsent || sessionLengthMinutes != null) {
      map['session_length_minutes'] = Variable<int>(sessionLengthMinutes);
    }
    map['reminder_preference_json'] = Variable<String>(reminderPreferenceJson);
    map['status'] = Variable<String>(status);
    map['created_by'] = Variable<String>(createdBy);
    if (!nullToAbsent || modelSlug != null) {
      map['model_slug'] = Variable<String>(modelSlug);
    }
    if (!nullToAbsent || planPreviewJson != null) {
      map['plan_preview_json'] = Variable<String>(planPreviewJson);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<int>(completedAt);
    }
    if (!nullToAbsent || cancelledAt != null) {
      map['cancelled_at'] = Variable<int>(cancelledAt);
    }
    return map;
  }

  GoalPlansCompanion toCompanion(bool nullToAbsent) {
    return GoalPlansCompanion(
      id: Value(id),
      spaceId: Value(spaceId),
      originCardId: originCardId == null && nullToAbsent
          ? const Value.absent()
          : Value(originCardId),
      chatSessionId: chatSessionId == null && nullToAbsent
          ? const Value.absent()
          : Value(chatSessionId),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      durationWeeks: durationWeeks == null && nullToAbsent
          ? const Value.absent()
          : Value(durationWeeks),
      preferredDaysJson: Value(preferredDaysJson),
      sessionLengthMinutes: sessionLengthMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(sessionLengthMinutes),
      reminderPreferenceJson: Value(reminderPreferenceJson),
      status: Value(status),
      createdBy: Value(createdBy),
      modelSlug: modelSlug == null && nullToAbsent
          ? const Value.absent()
          : Value(modelSlug),
      planPreviewJson: planPreviewJson == null && nullToAbsent
          ? const Value.absent()
          : Value(planPreviewJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      cancelledAt: cancelledAt == null && nullToAbsent
          ? const Value.absent()
          : Value(cancelledAt),
    );
  }

  factory GoalPlan.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GoalPlan(
      id: serializer.fromJson<String>(json['id']),
      spaceId: serializer.fromJson<String>(json['spaceId']),
      originCardId: serializer.fromJson<String?>(json['originCardId']),
      chatSessionId: serializer.fromJson<String?>(json['chatSessionId']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      durationWeeks: serializer.fromJson<int?>(json['durationWeeks']),
      preferredDaysJson: serializer.fromJson<String>(json['preferredDaysJson']),
      sessionLengthMinutes: serializer.fromJson<int?>(
        json['sessionLengthMinutes'],
      ),
      reminderPreferenceJson: serializer.fromJson<String>(
        json['reminderPreferenceJson'],
      ),
      status: serializer.fromJson<String>(json['status']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      modelSlug: serializer.fromJson<String?>(json['modelSlug']),
      planPreviewJson: serializer.fromJson<String?>(json['planPreviewJson']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      completedAt: serializer.fromJson<int?>(json['completedAt']),
      cancelledAt: serializer.fromJson<int?>(json['cancelledAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'spaceId': serializer.toJson<String>(spaceId),
      'originCardId': serializer.toJson<String?>(originCardId),
      'chatSessionId': serializer.toJson<String?>(chatSessionId),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'durationWeeks': serializer.toJson<int?>(durationWeeks),
      'preferredDaysJson': serializer.toJson<String>(preferredDaysJson),
      'sessionLengthMinutes': serializer.toJson<int?>(sessionLengthMinutes),
      'reminderPreferenceJson': serializer.toJson<String>(
        reminderPreferenceJson,
      ),
      'status': serializer.toJson<String>(status),
      'createdBy': serializer.toJson<String>(createdBy),
      'modelSlug': serializer.toJson<String?>(modelSlug),
      'planPreviewJson': serializer.toJson<String?>(planPreviewJson),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'completedAt': serializer.toJson<int?>(completedAt),
      'cancelledAt': serializer.toJson<int?>(cancelledAt),
    };
  }

  GoalPlan copyWith({
    String? id,
    String? spaceId,
    Value<String?> originCardId = const Value.absent(),
    Value<String?> chatSessionId = const Value.absent(),
    String? name,
    Value<String?> description = const Value.absent(),
    Value<int?> durationWeeks = const Value.absent(),
    String? preferredDaysJson,
    Value<int?> sessionLengthMinutes = const Value.absent(),
    String? reminderPreferenceJson,
    String? status,
    String? createdBy,
    Value<String?> modelSlug = const Value.absent(),
    Value<String?> planPreviewJson = const Value.absent(),
    int? createdAt,
    int? updatedAt,
    Value<int?> completedAt = const Value.absent(),
    Value<int?> cancelledAt = const Value.absent(),
  }) => GoalPlan(
    id: id ?? this.id,
    spaceId: spaceId ?? this.spaceId,
    originCardId: originCardId.present ? originCardId.value : this.originCardId,
    chatSessionId: chatSessionId.present
        ? chatSessionId.value
        : this.chatSessionId,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    durationWeeks: durationWeeks.present
        ? durationWeeks.value
        : this.durationWeeks,
    preferredDaysJson: preferredDaysJson ?? this.preferredDaysJson,
    sessionLengthMinutes: sessionLengthMinutes.present
        ? sessionLengthMinutes.value
        : this.sessionLengthMinutes,
    reminderPreferenceJson:
        reminderPreferenceJson ?? this.reminderPreferenceJson,
    status: status ?? this.status,
    createdBy: createdBy ?? this.createdBy,
    modelSlug: modelSlug.present ? modelSlug.value : this.modelSlug,
    planPreviewJson: planPreviewJson.present
        ? planPreviewJson.value
        : this.planPreviewJson,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    cancelledAt: cancelledAt.present ? cancelledAt.value : this.cancelledAt,
  );
  GoalPlan copyWithCompanion(GoalPlansCompanion data) {
    return GoalPlan(
      id: data.id.present ? data.id.value : this.id,
      spaceId: data.spaceId.present ? data.spaceId.value : this.spaceId,
      originCardId: data.originCardId.present
          ? data.originCardId.value
          : this.originCardId,
      chatSessionId: data.chatSessionId.present
          ? data.chatSessionId.value
          : this.chatSessionId,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      durationWeeks: data.durationWeeks.present
          ? data.durationWeeks.value
          : this.durationWeeks,
      preferredDaysJson: data.preferredDaysJson.present
          ? data.preferredDaysJson.value
          : this.preferredDaysJson,
      sessionLengthMinutes: data.sessionLengthMinutes.present
          ? data.sessionLengthMinutes.value
          : this.sessionLengthMinutes,
      reminderPreferenceJson: data.reminderPreferenceJson.present
          ? data.reminderPreferenceJson.value
          : this.reminderPreferenceJson,
      status: data.status.present ? data.status.value : this.status,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      modelSlug: data.modelSlug.present ? data.modelSlug.value : this.modelSlug,
      planPreviewJson: data.planPreviewJson.present
          ? data.planPreviewJson.value
          : this.planPreviewJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      cancelledAt: data.cancelledAt.present
          ? data.cancelledAt.value
          : this.cancelledAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GoalPlan(')
          ..write('id: $id, ')
          ..write('spaceId: $spaceId, ')
          ..write('originCardId: $originCardId, ')
          ..write('chatSessionId: $chatSessionId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('durationWeeks: $durationWeeks, ')
          ..write('preferredDaysJson: $preferredDaysJson, ')
          ..write('sessionLengthMinutes: $sessionLengthMinutes, ')
          ..write('reminderPreferenceJson: $reminderPreferenceJson, ')
          ..write('status: $status, ')
          ..write('createdBy: $createdBy, ')
          ..write('modelSlug: $modelSlug, ')
          ..write('planPreviewJson: $planPreviewJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('cancelledAt: $cancelledAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    spaceId,
    originCardId,
    chatSessionId,
    name,
    description,
    durationWeeks,
    preferredDaysJson,
    sessionLengthMinutes,
    reminderPreferenceJson,
    status,
    createdBy,
    modelSlug,
    planPreviewJson,
    createdAt,
    updatedAt,
    completedAt,
    cancelledAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GoalPlan &&
          other.id == this.id &&
          other.spaceId == this.spaceId &&
          other.originCardId == this.originCardId &&
          other.chatSessionId == this.chatSessionId &&
          other.name == this.name &&
          other.description == this.description &&
          other.durationWeeks == this.durationWeeks &&
          other.preferredDaysJson == this.preferredDaysJson &&
          other.sessionLengthMinutes == this.sessionLengthMinutes &&
          other.reminderPreferenceJson == this.reminderPreferenceJson &&
          other.status == this.status &&
          other.createdBy == this.createdBy &&
          other.modelSlug == this.modelSlug &&
          other.planPreviewJson == this.planPreviewJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.completedAt == this.completedAt &&
          other.cancelledAt == this.cancelledAt);
}

class GoalPlansCompanion extends UpdateCompanion<GoalPlan> {
  final Value<String> id;
  final Value<String> spaceId;
  final Value<String?> originCardId;
  final Value<String?> chatSessionId;
  final Value<String> name;
  final Value<String?> description;
  final Value<int?> durationWeeks;
  final Value<String> preferredDaysJson;
  final Value<int?> sessionLengthMinutes;
  final Value<String> reminderPreferenceJson;
  final Value<String> status;
  final Value<String> createdBy;
  final Value<String?> modelSlug;
  final Value<String?> planPreviewJson;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> completedAt;
  final Value<int?> cancelledAt;
  final Value<int> rowid;
  const GoalPlansCompanion({
    this.id = const Value.absent(),
    this.spaceId = const Value.absent(),
    this.originCardId = const Value.absent(),
    this.chatSessionId = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.durationWeeks = const Value.absent(),
    this.preferredDaysJson = const Value.absent(),
    this.sessionLengthMinutes = const Value.absent(),
    this.reminderPreferenceJson = const Value.absent(),
    this.status = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.modelSlug = const Value.absent(),
    this.planPreviewJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.cancelledAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GoalPlansCompanion.insert({
    required String id,
    required String spaceId,
    this.originCardId = const Value.absent(),
    this.chatSessionId = const Value.absent(),
    required String name,
    this.description = const Value.absent(),
    this.durationWeeks = const Value.absent(),
    this.preferredDaysJson = const Value.absent(),
    this.sessionLengthMinutes = const Value.absent(),
    this.reminderPreferenceJson = const Value.absent(),
    required String status,
    required String createdBy,
    this.modelSlug = const Value.absent(),
    this.planPreviewJson = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.completedAt = const Value.absent(),
    this.cancelledAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       spaceId = Value(spaceId),
       name = Value(name),
       status = Value(status),
       createdBy = Value(createdBy),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<GoalPlan> custom({
    Expression<String>? id,
    Expression<String>? spaceId,
    Expression<String>? originCardId,
    Expression<String>? chatSessionId,
    Expression<String>? name,
    Expression<String>? description,
    Expression<int>? durationWeeks,
    Expression<String>? preferredDaysJson,
    Expression<int>? sessionLengthMinutes,
    Expression<String>? reminderPreferenceJson,
    Expression<String>? status,
    Expression<String>? createdBy,
    Expression<String>? modelSlug,
    Expression<String>? planPreviewJson,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? completedAt,
    Expression<int>? cancelledAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (spaceId != null) 'space_id': spaceId,
      if (originCardId != null) 'origin_card_id': originCardId,
      if (chatSessionId != null) 'chat_session_id': chatSessionId,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (durationWeeks != null) 'duration_weeks': durationWeeks,
      if (preferredDaysJson != null) 'preferred_days_json': preferredDaysJson,
      if (sessionLengthMinutes != null)
        'session_length_minutes': sessionLengthMinutes,
      if (reminderPreferenceJson != null)
        'reminder_preference_json': reminderPreferenceJson,
      if (status != null) 'status': status,
      if (createdBy != null) 'created_by': createdBy,
      if (modelSlug != null) 'model_slug': modelSlug,
      if (planPreviewJson != null) 'plan_preview_json': planPreviewJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (cancelledAt != null) 'cancelled_at': cancelledAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GoalPlansCompanion copyWith({
    Value<String>? id,
    Value<String>? spaceId,
    Value<String?>? originCardId,
    Value<String?>? chatSessionId,
    Value<String>? name,
    Value<String?>? description,
    Value<int?>? durationWeeks,
    Value<String>? preferredDaysJson,
    Value<int?>? sessionLengthMinutes,
    Value<String>? reminderPreferenceJson,
    Value<String>? status,
    Value<String>? createdBy,
    Value<String?>? modelSlug,
    Value<String?>? planPreviewJson,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? completedAt,
    Value<int?>? cancelledAt,
    Value<int>? rowid,
  }) {
    return GoalPlansCompanion(
      id: id ?? this.id,
      spaceId: spaceId ?? this.spaceId,
      originCardId: originCardId ?? this.originCardId,
      chatSessionId: chatSessionId ?? this.chatSessionId,
      name: name ?? this.name,
      description: description ?? this.description,
      durationWeeks: durationWeeks ?? this.durationWeeks,
      preferredDaysJson: preferredDaysJson ?? this.preferredDaysJson,
      sessionLengthMinutes: sessionLengthMinutes ?? this.sessionLengthMinutes,
      reminderPreferenceJson:
          reminderPreferenceJson ?? this.reminderPreferenceJson,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      modelSlug: modelSlug ?? this.modelSlug,
      planPreviewJson: planPreviewJson ?? this.planPreviewJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (spaceId.present) {
      map['space_id'] = Variable<String>(spaceId.value);
    }
    if (originCardId.present) {
      map['origin_card_id'] = Variable<String>(originCardId.value);
    }
    if (chatSessionId.present) {
      map['chat_session_id'] = Variable<String>(chatSessionId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (durationWeeks.present) {
      map['duration_weeks'] = Variable<int>(durationWeeks.value);
    }
    if (preferredDaysJson.present) {
      map['preferred_days_json'] = Variable<String>(preferredDaysJson.value);
    }
    if (sessionLengthMinutes.present) {
      map['session_length_minutes'] = Variable<int>(sessionLengthMinutes.value);
    }
    if (reminderPreferenceJson.present) {
      map['reminder_preference_json'] = Variable<String>(
        reminderPreferenceJson.value,
      );
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (modelSlug.present) {
      map['model_slug'] = Variable<String>(modelSlug.value);
    }
    if (planPreviewJson.present) {
      map['plan_preview_json'] = Variable<String>(planPreviewJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<int>(completedAt.value);
    }
    if (cancelledAt.present) {
      map['cancelled_at'] = Variable<int>(cancelledAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GoalPlansCompanion(')
          ..write('id: $id, ')
          ..write('spaceId: $spaceId, ')
          ..write('originCardId: $originCardId, ')
          ..write('chatSessionId: $chatSessionId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('durationWeeks: $durationWeeks, ')
          ..write('preferredDaysJson: $preferredDaysJson, ')
          ..write('sessionLengthMinutes: $sessionLengthMinutes, ')
          ..write('reminderPreferenceJson: $reminderPreferenceJson, ')
          ..write('status: $status, ')
          ..write('createdBy: $createdBy, ')
          ..write('modelSlug: $modelSlug, ')
          ..write('planPreviewJson: $planPreviewJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('cancelledAt: $cancelledAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GoalPlanCardsTable extends GoalPlanCards
    with TableInfo<$GoalPlanCardsTable, GoalPlanCard> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GoalPlanCardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _goalPlanIdMeta = const VerificationMeta(
    'goalPlanId',
  );
  @override
  late final GeneratedColumn<String> goalPlanId = GeneratedColumn<String>(
    'goal_plan_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES goal_plans (id)',
    ),
  );
  static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
  @override
  late final GeneratedColumn<String> cardId = GeneratedColumn<String>(
    'card_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tag_cards (id)',
    ),
  );
  static const VerificationMeta _sequenceIndexMeta = const VerificationMeta(
    'sequenceIndex',
  );
  @override
  late final GeneratedColumn<int> sequenceIndex = GeneratedColumn<int>(
    'sequence_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    goalPlanId,
    cardId,
    sequenceIndex,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'goal_plan_cards';
  @override
  VerificationContext validateIntegrity(
    Insertable<GoalPlanCard> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('goal_plan_id')) {
      context.handle(
        _goalPlanIdMeta,
        goalPlanId.isAcceptableOrUnknown(
          data['goal_plan_id']!,
          _goalPlanIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_goalPlanIdMeta);
    }
    if (data.containsKey('card_id')) {
      context.handle(
        _cardIdMeta,
        cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cardIdMeta);
    }
    if (data.containsKey('sequence_index')) {
      context.handle(
        _sequenceIndexMeta,
        sequenceIndex.isAcceptableOrUnknown(
          data['sequence_index']!,
          _sequenceIndexMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sequenceIndexMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {goalPlanId, cardId};
  @override
  GoalPlanCard map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GoalPlanCard(
      goalPlanId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}goal_plan_id'],
      )!,
      cardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}card_id'],
      )!,
      sequenceIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sequence_index'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $GoalPlanCardsTable createAlias(String alias) {
    return $GoalPlanCardsTable(attachedDatabase, alias);
  }
}

class GoalPlanCard extends DataClass implements Insertable<GoalPlanCard> {
  final String goalPlanId;
  final String cardId;
  final int sequenceIndex;
  final int createdAt;
  const GoalPlanCard({
    required this.goalPlanId,
    required this.cardId,
    required this.sequenceIndex,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['goal_plan_id'] = Variable<String>(goalPlanId);
    map['card_id'] = Variable<String>(cardId);
    map['sequence_index'] = Variable<int>(sequenceIndex);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  GoalPlanCardsCompanion toCompanion(bool nullToAbsent) {
    return GoalPlanCardsCompanion(
      goalPlanId: Value(goalPlanId),
      cardId: Value(cardId),
      sequenceIndex: Value(sequenceIndex),
      createdAt: Value(createdAt),
    );
  }

  factory GoalPlanCard.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GoalPlanCard(
      goalPlanId: serializer.fromJson<String>(json['goalPlanId']),
      cardId: serializer.fromJson<String>(json['cardId']),
      sequenceIndex: serializer.fromJson<int>(json['sequenceIndex']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'goalPlanId': serializer.toJson<String>(goalPlanId),
      'cardId': serializer.toJson<String>(cardId),
      'sequenceIndex': serializer.toJson<int>(sequenceIndex),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  GoalPlanCard copyWith({
    String? goalPlanId,
    String? cardId,
    int? sequenceIndex,
    int? createdAt,
  }) => GoalPlanCard(
    goalPlanId: goalPlanId ?? this.goalPlanId,
    cardId: cardId ?? this.cardId,
    sequenceIndex: sequenceIndex ?? this.sequenceIndex,
    createdAt: createdAt ?? this.createdAt,
  );
  GoalPlanCard copyWithCompanion(GoalPlanCardsCompanion data) {
    return GoalPlanCard(
      goalPlanId: data.goalPlanId.present
          ? data.goalPlanId.value
          : this.goalPlanId,
      cardId: data.cardId.present ? data.cardId.value : this.cardId,
      sequenceIndex: data.sequenceIndex.present
          ? data.sequenceIndex.value
          : this.sequenceIndex,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GoalPlanCard(')
          ..write('goalPlanId: $goalPlanId, ')
          ..write('cardId: $cardId, ')
          ..write('sequenceIndex: $sequenceIndex, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(goalPlanId, cardId, sequenceIndex, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GoalPlanCard &&
          other.goalPlanId == this.goalPlanId &&
          other.cardId == this.cardId &&
          other.sequenceIndex == this.sequenceIndex &&
          other.createdAt == this.createdAt);
}

class GoalPlanCardsCompanion extends UpdateCompanion<GoalPlanCard> {
  final Value<String> goalPlanId;
  final Value<String> cardId;
  final Value<int> sequenceIndex;
  final Value<int> createdAt;
  final Value<int> rowid;
  const GoalPlanCardsCompanion({
    this.goalPlanId = const Value.absent(),
    this.cardId = const Value.absent(),
    this.sequenceIndex = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GoalPlanCardsCompanion.insert({
    required String goalPlanId,
    required String cardId,
    required int sequenceIndex,
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : goalPlanId = Value(goalPlanId),
       cardId = Value(cardId),
       sequenceIndex = Value(sequenceIndex),
       createdAt = Value(createdAt);
  static Insertable<GoalPlanCard> custom({
    Expression<String>? goalPlanId,
    Expression<String>? cardId,
    Expression<int>? sequenceIndex,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (goalPlanId != null) 'goal_plan_id': goalPlanId,
      if (cardId != null) 'card_id': cardId,
      if (sequenceIndex != null) 'sequence_index': sequenceIndex,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GoalPlanCardsCompanion copyWith({
    Value<String>? goalPlanId,
    Value<String>? cardId,
    Value<int>? sequenceIndex,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return GoalPlanCardsCompanion(
      goalPlanId: goalPlanId ?? this.goalPlanId,
      cardId: cardId ?? this.cardId,
      sequenceIndex: sequenceIndex ?? this.sequenceIndex,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (goalPlanId.present) {
      map['goal_plan_id'] = Variable<String>(goalPlanId.value);
    }
    if (cardId.present) {
      map['card_id'] = Variable<String>(cardId.value);
    }
    if (sequenceIndex.present) {
      map['sequence_index'] = Variable<int>(sequenceIndex.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GoalPlanCardsCompanion(')
          ..write('goalPlanId: $goalPlanId, ')
          ..write('cardId: $cardId, ')
          ..write('sequenceIndex: $sequenceIndex, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChatSessionsTable extends ChatSessions
    with TableInfo<$ChatSessionsTable, ChatSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _purposeMeta = const VerificationMeta(
    'purpose',
  );
  @override
  late final GeneratedColumn<String> purpose = GeneratedColumn<String>(
    'purpose',
    aliasedName,
    false,
    check: () => purpose.isIn(TagDatabaseValues.chatPurposes),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _linkedCardIdMeta = const VerificationMeta(
    'linkedCardId',
  );
  @override
  late final GeneratedColumn<String> linkedCardId = GeneratedColumn<String>(
    'linked_card_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _linkedSpaceIdMeta = const VerificationMeta(
    'linkedSpaceId',
  );
  @override
  late final GeneratedColumn<String> linkedSpaceId = GeneratedColumn<String>(
    'linked_space_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES spaces (id)',
    ),
  );
  static const VerificationMeta _linkedGoalPlanIdMeta = const VerificationMeta(
    'linkedGoalPlanId',
  );
  @override
  late final GeneratedColumn<String> linkedGoalPlanId = GeneratedColumn<String>(
    'linked_goal_plan_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    check: () => status.isIn(TagDatabaseValues.chatStatuses),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pendingConfirmationJsonMeta =
      const VerificationMeta('pendingConfirmationJson');
  @override
  late final GeneratedColumn<String> pendingConfirmationJson =
      GeneratedColumn<String>(
        'pending_confirmation_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _archivedAtMeta = const VerificationMeta(
    'archivedAt',
  );
  @override
  late final GeneratedColumn<int> archivedAt = GeneratedColumn<int>(
    'archived_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    purpose,
    linkedCardId,
    linkedSpaceId,
    linkedGoalPlanId,
    status,
    pendingConfirmationJson,
    createdAt,
    updatedAt,
    archivedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChatSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('purpose')) {
      context.handle(
        _purposeMeta,
        purpose.isAcceptableOrUnknown(data['purpose']!, _purposeMeta),
      );
    } else if (isInserting) {
      context.missing(_purposeMeta);
    }
    if (data.containsKey('linked_card_id')) {
      context.handle(
        _linkedCardIdMeta,
        linkedCardId.isAcceptableOrUnknown(
          data['linked_card_id']!,
          _linkedCardIdMeta,
        ),
      );
    }
    if (data.containsKey('linked_space_id')) {
      context.handle(
        _linkedSpaceIdMeta,
        linkedSpaceId.isAcceptableOrUnknown(
          data['linked_space_id']!,
          _linkedSpaceIdMeta,
        ),
      );
    }
    if (data.containsKey('linked_goal_plan_id')) {
      context.handle(
        _linkedGoalPlanIdMeta,
        linkedGoalPlanId.isAcceptableOrUnknown(
          data['linked_goal_plan_id']!,
          _linkedGoalPlanIdMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('pending_confirmation_json')) {
      context.handle(
        _pendingConfirmationJsonMeta,
        pendingConfirmationJson.isAcceptableOrUnknown(
          data['pending_confirmation_json']!,
          _pendingConfirmationJsonMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('archived_at')) {
      context.handle(
        _archivedAtMeta,
        archivedAt.isAcceptableOrUnknown(data['archived_at']!, _archivedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChatSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      purpose: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}purpose'],
      )!,
      linkedCardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}linked_card_id'],
      ),
      linkedSpaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}linked_space_id'],
      ),
      linkedGoalPlanId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}linked_goal_plan_id'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      pendingConfirmationJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pending_confirmation_json'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      archivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}archived_at'],
      ),
    );
  }

  @override
  $ChatSessionsTable createAlias(String alias) {
    return $ChatSessionsTable(attachedDatabase, alias);
  }
}

class ChatSession extends DataClass implements Insertable<ChatSession> {
  final String id;
  final String title;
  final String purpose;
  final String? linkedCardId;
  final String? linkedSpaceId;
  final String? linkedGoalPlanId;
  final String status;
  final String? pendingConfirmationJson;
  final int createdAt;
  final int updatedAt;
  final int? archivedAt;
  const ChatSession({
    required this.id,
    required this.title,
    required this.purpose,
    this.linkedCardId,
    this.linkedSpaceId,
    this.linkedGoalPlanId,
    required this.status,
    this.pendingConfirmationJson,
    required this.createdAt,
    required this.updatedAt,
    this.archivedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['purpose'] = Variable<String>(purpose);
    if (!nullToAbsent || linkedCardId != null) {
      map['linked_card_id'] = Variable<String>(linkedCardId);
    }
    if (!nullToAbsent || linkedSpaceId != null) {
      map['linked_space_id'] = Variable<String>(linkedSpaceId);
    }
    if (!nullToAbsent || linkedGoalPlanId != null) {
      map['linked_goal_plan_id'] = Variable<String>(linkedGoalPlanId);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || pendingConfirmationJson != null) {
      map['pending_confirmation_json'] = Variable<String>(
        pendingConfirmationJson,
      );
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<int>(archivedAt);
    }
    return map;
  }

  ChatSessionsCompanion toCompanion(bool nullToAbsent) {
    return ChatSessionsCompanion(
      id: Value(id),
      title: Value(title),
      purpose: Value(purpose),
      linkedCardId: linkedCardId == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedCardId),
      linkedSpaceId: linkedSpaceId == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedSpaceId),
      linkedGoalPlanId: linkedGoalPlanId == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedGoalPlanId),
      status: Value(status),
      pendingConfirmationJson: pendingConfirmationJson == null && nullToAbsent
          ? const Value.absent()
          : Value(pendingConfirmationJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
    );
  }

  factory ChatSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatSession(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      purpose: serializer.fromJson<String>(json['purpose']),
      linkedCardId: serializer.fromJson<String?>(json['linkedCardId']),
      linkedSpaceId: serializer.fromJson<String?>(json['linkedSpaceId']),
      linkedGoalPlanId: serializer.fromJson<String?>(json['linkedGoalPlanId']),
      status: serializer.fromJson<String>(json['status']),
      pendingConfirmationJson: serializer.fromJson<String?>(
        json['pendingConfirmationJson'],
      ),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      archivedAt: serializer.fromJson<int?>(json['archivedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'purpose': serializer.toJson<String>(purpose),
      'linkedCardId': serializer.toJson<String?>(linkedCardId),
      'linkedSpaceId': serializer.toJson<String?>(linkedSpaceId),
      'linkedGoalPlanId': serializer.toJson<String?>(linkedGoalPlanId),
      'status': serializer.toJson<String>(status),
      'pendingConfirmationJson': serializer.toJson<String?>(
        pendingConfirmationJson,
      ),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'archivedAt': serializer.toJson<int?>(archivedAt),
    };
  }

  ChatSession copyWith({
    String? id,
    String? title,
    String? purpose,
    Value<String?> linkedCardId = const Value.absent(),
    Value<String?> linkedSpaceId = const Value.absent(),
    Value<String?> linkedGoalPlanId = const Value.absent(),
    String? status,
    Value<String?> pendingConfirmationJson = const Value.absent(),
    int? createdAt,
    int? updatedAt,
    Value<int?> archivedAt = const Value.absent(),
  }) => ChatSession(
    id: id ?? this.id,
    title: title ?? this.title,
    purpose: purpose ?? this.purpose,
    linkedCardId: linkedCardId.present ? linkedCardId.value : this.linkedCardId,
    linkedSpaceId: linkedSpaceId.present
        ? linkedSpaceId.value
        : this.linkedSpaceId,
    linkedGoalPlanId: linkedGoalPlanId.present
        ? linkedGoalPlanId.value
        : this.linkedGoalPlanId,
    status: status ?? this.status,
    pendingConfirmationJson: pendingConfirmationJson.present
        ? pendingConfirmationJson.value
        : this.pendingConfirmationJson,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
  );
  ChatSession copyWithCompanion(ChatSessionsCompanion data) {
    return ChatSession(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      purpose: data.purpose.present ? data.purpose.value : this.purpose,
      linkedCardId: data.linkedCardId.present
          ? data.linkedCardId.value
          : this.linkedCardId,
      linkedSpaceId: data.linkedSpaceId.present
          ? data.linkedSpaceId.value
          : this.linkedSpaceId,
      linkedGoalPlanId: data.linkedGoalPlanId.present
          ? data.linkedGoalPlanId.value
          : this.linkedGoalPlanId,
      status: data.status.present ? data.status.value : this.status,
      pendingConfirmationJson: data.pendingConfirmationJson.present
          ? data.pendingConfirmationJson.value
          : this.pendingConfirmationJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      archivedAt: data.archivedAt.present
          ? data.archivedAt.value
          : this.archivedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatSession(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('purpose: $purpose, ')
          ..write('linkedCardId: $linkedCardId, ')
          ..write('linkedSpaceId: $linkedSpaceId, ')
          ..write('linkedGoalPlanId: $linkedGoalPlanId, ')
          ..write('status: $status, ')
          ..write('pendingConfirmationJson: $pendingConfirmationJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('archivedAt: $archivedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    purpose,
    linkedCardId,
    linkedSpaceId,
    linkedGoalPlanId,
    status,
    pendingConfirmationJson,
    createdAt,
    updatedAt,
    archivedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatSession &&
          other.id == this.id &&
          other.title == this.title &&
          other.purpose == this.purpose &&
          other.linkedCardId == this.linkedCardId &&
          other.linkedSpaceId == this.linkedSpaceId &&
          other.linkedGoalPlanId == this.linkedGoalPlanId &&
          other.status == this.status &&
          other.pendingConfirmationJson == this.pendingConfirmationJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.archivedAt == this.archivedAt);
}

class ChatSessionsCompanion extends UpdateCompanion<ChatSession> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> purpose;
  final Value<String?> linkedCardId;
  final Value<String?> linkedSpaceId;
  final Value<String?> linkedGoalPlanId;
  final Value<String> status;
  final Value<String?> pendingConfirmationJson;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> archivedAt;
  final Value<int> rowid;
  const ChatSessionsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.purpose = const Value.absent(),
    this.linkedCardId = const Value.absent(),
    this.linkedSpaceId = const Value.absent(),
    this.linkedGoalPlanId = const Value.absent(),
    this.status = const Value.absent(),
    this.pendingConfirmationJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChatSessionsCompanion.insert({
    required String id,
    required String title,
    required String purpose,
    this.linkedCardId = const Value.absent(),
    this.linkedSpaceId = const Value.absent(),
    this.linkedGoalPlanId = const Value.absent(),
    required String status,
    this.pendingConfirmationJson = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       purpose = Value(purpose),
       status = Value(status),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ChatSession> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? purpose,
    Expression<String>? linkedCardId,
    Expression<String>? linkedSpaceId,
    Expression<String>? linkedGoalPlanId,
    Expression<String>? status,
    Expression<String>? pendingConfirmationJson,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? archivedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (purpose != null) 'purpose': purpose,
      if (linkedCardId != null) 'linked_card_id': linkedCardId,
      if (linkedSpaceId != null) 'linked_space_id': linkedSpaceId,
      if (linkedGoalPlanId != null) 'linked_goal_plan_id': linkedGoalPlanId,
      if (status != null) 'status': status,
      if (pendingConfirmationJson != null)
        'pending_confirmation_json': pendingConfirmationJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChatSessionsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? purpose,
    Value<String?>? linkedCardId,
    Value<String?>? linkedSpaceId,
    Value<String?>? linkedGoalPlanId,
    Value<String>? status,
    Value<String?>? pendingConfirmationJson,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? archivedAt,
    Value<int>? rowid,
  }) {
    return ChatSessionsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      purpose: purpose ?? this.purpose,
      linkedCardId: linkedCardId ?? this.linkedCardId,
      linkedSpaceId: linkedSpaceId ?? this.linkedSpaceId,
      linkedGoalPlanId: linkedGoalPlanId ?? this.linkedGoalPlanId,
      status: status ?? this.status,
      pendingConfirmationJson:
          pendingConfirmationJson ?? this.pendingConfirmationJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedAt: archivedAt ?? this.archivedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (purpose.present) {
      map['purpose'] = Variable<String>(purpose.value);
    }
    if (linkedCardId.present) {
      map['linked_card_id'] = Variable<String>(linkedCardId.value);
    }
    if (linkedSpaceId.present) {
      map['linked_space_id'] = Variable<String>(linkedSpaceId.value);
    }
    if (linkedGoalPlanId.present) {
      map['linked_goal_plan_id'] = Variable<String>(linkedGoalPlanId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (pendingConfirmationJson.present) {
      map['pending_confirmation_json'] = Variable<String>(
        pendingConfirmationJson.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<int>(archivedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatSessionsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('purpose: $purpose, ')
          ..write('linkedCardId: $linkedCardId, ')
          ..write('linkedSpaceId: $linkedSpaceId, ')
          ..write('linkedGoalPlanId: $linkedGoalPlanId, ')
          ..write('status: $status, ')
          ..write('pendingConfirmationJson: $pendingConfirmationJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChatMessagesTable extends ChatMessages
    with TableInfo<$ChatMessagesTable, ChatMessage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chatSessionIdMeta = const VerificationMeta(
    'chatSessionId',
  );
  @override
  late final GeneratedColumn<String> chatSessionId = GeneratedColumn<String>(
    'chat_session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES chat_sessions (id)',
    ),
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    check: () => role.isIn(TagDatabaseValues.chatRoles),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentJsonMeta = const VerificationMeta(
    'contentJson',
  );
  @override
  late final GeneratedColumn<String> contentJson = GeneratedColumn<String>(
    'content_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _toolCallsJsonMeta = const VerificationMeta(
    'toolCallsJson',
  );
  @override
  late final GeneratedColumn<String> toolCallsJson = GeneratedColumn<String>(
    'tool_calls_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceIdsJsonMeta = const VerificationMeta(
    'sourceIdsJson',
  );
  @override
  late final GeneratedColumn<String> sourceIdsJson = GeneratedColumn<String>(
    'source_ids_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _cardIdsJsonMeta = const VerificationMeta(
    'cardIdsJson',
  );
  @override
  late final GeneratedColumn<String> cardIdsJson = GeneratedColumn<String>(
    'card_ids_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _modelSlugMeta = const VerificationMeta(
    'modelSlug',
  );
  @override
  late final GeneratedColumn<String> modelSlug = GeneratedColumn<String>(
    'model_slug',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    chatSessionId,
    role,
    content,
    contentJson,
    toolCallsJson,
    sourceIdsJson,
    cardIdsJson,
    modelSlug,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChatMessage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('chat_session_id')) {
      context.handle(
        _chatSessionIdMeta,
        chatSessionId.isAcceptableOrUnknown(
          data['chat_session_id']!,
          _chatSessionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_chatSessionIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('content_json')) {
      context.handle(
        _contentJsonMeta,
        contentJson.isAcceptableOrUnknown(
          data['content_json']!,
          _contentJsonMeta,
        ),
      );
    }
    if (data.containsKey('tool_calls_json')) {
      context.handle(
        _toolCallsJsonMeta,
        toolCallsJson.isAcceptableOrUnknown(
          data['tool_calls_json']!,
          _toolCallsJsonMeta,
        ),
      );
    }
    if (data.containsKey('source_ids_json')) {
      context.handle(
        _sourceIdsJsonMeta,
        sourceIdsJson.isAcceptableOrUnknown(
          data['source_ids_json']!,
          _sourceIdsJsonMeta,
        ),
      );
    }
    if (data.containsKey('card_ids_json')) {
      context.handle(
        _cardIdsJsonMeta,
        cardIdsJson.isAcceptableOrUnknown(
          data['card_ids_json']!,
          _cardIdsJsonMeta,
        ),
      );
    }
    if (data.containsKey('model_slug')) {
      context.handle(
        _modelSlugMeta,
        modelSlug.isAcceptableOrUnknown(data['model_slug']!, _modelSlugMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChatMessage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatMessage(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      chatSessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chat_session_id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      contentJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_json'],
      ),
      toolCallsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tool_calls_json'],
      ),
      sourceIdsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_ids_json'],
      )!,
      cardIdsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}card_ids_json'],
      )!,
      modelSlug: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_slug'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ChatMessagesTable createAlias(String alias) {
    return $ChatMessagesTable(attachedDatabase, alias);
  }
}

class ChatMessage extends DataClass implements Insertable<ChatMessage> {
  final String id;
  final String chatSessionId;
  final String role;
  final String content;
  final String? contentJson;
  final String? toolCallsJson;
  final String sourceIdsJson;
  final String cardIdsJson;
  final String? modelSlug;
  final int createdAt;
  const ChatMessage({
    required this.id,
    required this.chatSessionId,
    required this.role,
    required this.content,
    this.contentJson,
    this.toolCallsJson,
    required this.sourceIdsJson,
    required this.cardIdsJson,
    this.modelSlug,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['chat_session_id'] = Variable<String>(chatSessionId);
    map['role'] = Variable<String>(role);
    map['content'] = Variable<String>(content);
    if (!nullToAbsent || contentJson != null) {
      map['content_json'] = Variable<String>(contentJson);
    }
    if (!nullToAbsent || toolCallsJson != null) {
      map['tool_calls_json'] = Variable<String>(toolCallsJson);
    }
    map['source_ids_json'] = Variable<String>(sourceIdsJson);
    map['card_ids_json'] = Variable<String>(cardIdsJson);
    if (!nullToAbsent || modelSlug != null) {
      map['model_slug'] = Variable<String>(modelSlug);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  ChatMessagesCompanion toCompanion(bool nullToAbsent) {
    return ChatMessagesCompanion(
      id: Value(id),
      chatSessionId: Value(chatSessionId),
      role: Value(role),
      content: Value(content),
      contentJson: contentJson == null && nullToAbsent
          ? const Value.absent()
          : Value(contentJson),
      toolCallsJson: toolCallsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(toolCallsJson),
      sourceIdsJson: Value(sourceIdsJson),
      cardIdsJson: Value(cardIdsJson),
      modelSlug: modelSlug == null && nullToAbsent
          ? const Value.absent()
          : Value(modelSlug),
      createdAt: Value(createdAt),
    );
  }

  factory ChatMessage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatMessage(
      id: serializer.fromJson<String>(json['id']),
      chatSessionId: serializer.fromJson<String>(json['chatSessionId']),
      role: serializer.fromJson<String>(json['role']),
      content: serializer.fromJson<String>(json['content']),
      contentJson: serializer.fromJson<String?>(json['contentJson']),
      toolCallsJson: serializer.fromJson<String?>(json['toolCallsJson']),
      sourceIdsJson: serializer.fromJson<String>(json['sourceIdsJson']),
      cardIdsJson: serializer.fromJson<String>(json['cardIdsJson']),
      modelSlug: serializer.fromJson<String?>(json['modelSlug']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'chatSessionId': serializer.toJson<String>(chatSessionId),
      'role': serializer.toJson<String>(role),
      'content': serializer.toJson<String>(content),
      'contentJson': serializer.toJson<String?>(contentJson),
      'toolCallsJson': serializer.toJson<String?>(toolCallsJson),
      'sourceIdsJson': serializer.toJson<String>(sourceIdsJson),
      'cardIdsJson': serializer.toJson<String>(cardIdsJson),
      'modelSlug': serializer.toJson<String?>(modelSlug),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  ChatMessage copyWith({
    String? id,
    String? chatSessionId,
    String? role,
    String? content,
    Value<String?> contentJson = const Value.absent(),
    Value<String?> toolCallsJson = const Value.absent(),
    String? sourceIdsJson,
    String? cardIdsJson,
    Value<String?> modelSlug = const Value.absent(),
    int? createdAt,
  }) => ChatMessage(
    id: id ?? this.id,
    chatSessionId: chatSessionId ?? this.chatSessionId,
    role: role ?? this.role,
    content: content ?? this.content,
    contentJson: contentJson.present ? contentJson.value : this.contentJson,
    toolCallsJson: toolCallsJson.present
        ? toolCallsJson.value
        : this.toolCallsJson,
    sourceIdsJson: sourceIdsJson ?? this.sourceIdsJson,
    cardIdsJson: cardIdsJson ?? this.cardIdsJson,
    modelSlug: modelSlug.present ? modelSlug.value : this.modelSlug,
    createdAt: createdAt ?? this.createdAt,
  );
  ChatMessage copyWithCompanion(ChatMessagesCompanion data) {
    return ChatMessage(
      id: data.id.present ? data.id.value : this.id,
      chatSessionId: data.chatSessionId.present
          ? data.chatSessionId.value
          : this.chatSessionId,
      role: data.role.present ? data.role.value : this.role,
      content: data.content.present ? data.content.value : this.content,
      contentJson: data.contentJson.present
          ? data.contentJson.value
          : this.contentJson,
      toolCallsJson: data.toolCallsJson.present
          ? data.toolCallsJson.value
          : this.toolCallsJson,
      sourceIdsJson: data.sourceIdsJson.present
          ? data.sourceIdsJson.value
          : this.sourceIdsJson,
      cardIdsJson: data.cardIdsJson.present
          ? data.cardIdsJson.value
          : this.cardIdsJson,
      modelSlug: data.modelSlug.present ? data.modelSlug.value : this.modelSlug,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessage(')
          ..write('id: $id, ')
          ..write('chatSessionId: $chatSessionId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('contentJson: $contentJson, ')
          ..write('toolCallsJson: $toolCallsJson, ')
          ..write('sourceIdsJson: $sourceIdsJson, ')
          ..write('cardIdsJson: $cardIdsJson, ')
          ..write('modelSlug: $modelSlug, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    chatSessionId,
    role,
    content,
    contentJson,
    toolCallsJson,
    sourceIdsJson,
    cardIdsJson,
    modelSlug,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatMessage &&
          other.id == this.id &&
          other.chatSessionId == this.chatSessionId &&
          other.role == this.role &&
          other.content == this.content &&
          other.contentJson == this.contentJson &&
          other.toolCallsJson == this.toolCallsJson &&
          other.sourceIdsJson == this.sourceIdsJson &&
          other.cardIdsJson == this.cardIdsJson &&
          other.modelSlug == this.modelSlug &&
          other.createdAt == this.createdAt);
}

class ChatMessagesCompanion extends UpdateCompanion<ChatMessage> {
  final Value<String> id;
  final Value<String> chatSessionId;
  final Value<String> role;
  final Value<String> content;
  final Value<String?> contentJson;
  final Value<String?> toolCallsJson;
  final Value<String> sourceIdsJson;
  final Value<String> cardIdsJson;
  final Value<String?> modelSlug;
  final Value<int> createdAt;
  final Value<int> rowid;
  const ChatMessagesCompanion({
    this.id = const Value.absent(),
    this.chatSessionId = const Value.absent(),
    this.role = const Value.absent(),
    this.content = const Value.absent(),
    this.contentJson = const Value.absent(),
    this.toolCallsJson = const Value.absent(),
    this.sourceIdsJson = const Value.absent(),
    this.cardIdsJson = const Value.absent(),
    this.modelSlug = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChatMessagesCompanion.insert({
    required String id,
    required String chatSessionId,
    required String role,
    required String content,
    this.contentJson = const Value.absent(),
    this.toolCallsJson = const Value.absent(),
    this.sourceIdsJson = const Value.absent(),
    this.cardIdsJson = const Value.absent(),
    this.modelSlug = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       chatSessionId = Value(chatSessionId),
       role = Value(role),
       content = Value(content),
       createdAt = Value(createdAt);
  static Insertable<ChatMessage> custom({
    Expression<String>? id,
    Expression<String>? chatSessionId,
    Expression<String>? role,
    Expression<String>? content,
    Expression<String>? contentJson,
    Expression<String>? toolCallsJson,
    Expression<String>? sourceIdsJson,
    Expression<String>? cardIdsJson,
    Expression<String>? modelSlug,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (chatSessionId != null) 'chat_session_id': chatSessionId,
      if (role != null) 'role': role,
      if (content != null) 'content': content,
      if (contentJson != null) 'content_json': contentJson,
      if (toolCallsJson != null) 'tool_calls_json': toolCallsJson,
      if (sourceIdsJson != null) 'source_ids_json': sourceIdsJson,
      if (cardIdsJson != null) 'card_ids_json': cardIdsJson,
      if (modelSlug != null) 'model_slug': modelSlug,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChatMessagesCompanion copyWith({
    Value<String>? id,
    Value<String>? chatSessionId,
    Value<String>? role,
    Value<String>? content,
    Value<String?>? contentJson,
    Value<String?>? toolCallsJson,
    Value<String>? sourceIdsJson,
    Value<String>? cardIdsJson,
    Value<String?>? modelSlug,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return ChatMessagesCompanion(
      id: id ?? this.id,
      chatSessionId: chatSessionId ?? this.chatSessionId,
      role: role ?? this.role,
      content: content ?? this.content,
      contentJson: contentJson ?? this.contentJson,
      toolCallsJson: toolCallsJson ?? this.toolCallsJson,
      sourceIdsJson: sourceIdsJson ?? this.sourceIdsJson,
      cardIdsJson: cardIdsJson ?? this.cardIdsJson,
      modelSlug: modelSlug ?? this.modelSlug,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (chatSessionId.present) {
      map['chat_session_id'] = Variable<String>(chatSessionId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (contentJson.present) {
      map['content_json'] = Variable<String>(contentJson.value);
    }
    if (toolCallsJson.present) {
      map['tool_calls_json'] = Variable<String>(toolCallsJson.value);
    }
    if (sourceIdsJson.present) {
      map['source_ids_json'] = Variable<String>(sourceIdsJson.value);
    }
    if (cardIdsJson.present) {
      map['card_ids_json'] = Variable<String>(cardIdsJson.value);
    }
    if (modelSlug.present) {
      map['model_slug'] = Variable<String>(modelSlug.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessagesCompanion(')
          ..write('id: $id, ')
          ..write('chatSessionId: $chatSessionId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('contentJson: $contentJson, ')
          ..write('toolCallsJson: $toolCallsJson, ')
          ..write('sourceIdsJson: $sourceIdsJson, ')
          ..write('cardIdsJson: $cardIdsJson, ')
          ..write('modelSlug: $modelSlug, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FeedbackEventsTable extends FeedbackEvents
    with TableInfo<$FeedbackEventsTable, FeedbackEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FeedbackEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventTypeMeta = const VerificationMeta(
    'eventType',
  );
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
    'event_type',
    aliasedName,
    false,
    check: () => eventType.isIn(TagDatabaseValues.feedbackEventTypes),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
  @override
  late final GeneratedColumn<String> cardId = GeneratedColumn<String>(
    'card_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tag_cards (id)',
    ),
  );
  static const VerificationMeta _spaceIdMeta = const VerificationMeta(
    'spaceId',
  );
  @override
  late final GeneratedColumn<String> spaceId = GeneratedColumn<String>(
    'space_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES spaces (id)',
    ),
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES source_items (id)',
    ),
  );
  static const VerificationMeta _goalPlanIdMeta = const VerificationMeta(
    'goalPlanId',
  );
  @override
  late final GeneratedColumn<String> goalPlanId = GeneratedColumn<String>(
    'goal_plan_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _detailsJsonMeta = const VerificationMeta(
    'detailsJson',
  );
  @override
  late final GeneratedColumn<String> detailsJson = GeneratedColumn<String>(
    'details_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    eventType,
    cardId,
    spaceId,
    sourceId,
    goalPlanId,
    detailsJson,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'feedback_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<FeedbackEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('event_type')) {
      context.handle(
        _eventTypeMeta,
        eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    if (data.containsKey('card_id')) {
      context.handle(
        _cardIdMeta,
        cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta),
      );
    }
    if (data.containsKey('space_id')) {
      context.handle(
        _spaceIdMeta,
        spaceId.isAcceptableOrUnknown(data['space_id']!, _spaceIdMeta),
      );
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    }
    if (data.containsKey('goal_plan_id')) {
      context.handle(
        _goalPlanIdMeta,
        goalPlanId.isAcceptableOrUnknown(
          data['goal_plan_id']!,
          _goalPlanIdMeta,
        ),
      );
    }
    if (data.containsKey('details_json')) {
      context.handle(
        _detailsJsonMeta,
        detailsJson.isAcceptableOrUnknown(
          data['details_json']!,
          _detailsJsonMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FeedbackEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FeedbackEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      eventType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_type'],
      )!,
      cardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}card_id'],
      ),
      spaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}space_id'],
      ),
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      ),
      goalPlanId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}goal_plan_id'],
      ),
      detailsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}details_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $FeedbackEventsTable createAlias(String alias) {
    return $FeedbackEventsTable(attachedDatabase, alias);
  }
}

class FeedbackEvent extends DataClass implements Insertable<FeedbackEvent> {
  final String id;
  final String eventType;
  final String? cardId;
  final String? spaceId;
  final String? sourceId;
  final String? goalPlanId;
  final String detailsJson;
  final int createdAt;
  const FeedbackEvent({
    required this.id,
    required this.eventType,
    this.cardId,
    this.spaceId,
    this.sourceId,
    this.goalPlanId,
    required this.detailsJson,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['event_type'] = Variable<String>(eventType);
    if (!nullToAbsent || cardId != null) {
      map['card_id'] = Variable<String>(cardId);
    }
    if (!nullToAbsent || spaceId != null) {
      map['space_id'] = Variable<String>(spaceId);
    }
    if (!nullToAbsent || sourceId != null) {
      map['source_id'] = Variable<String>(sourceId);
    }
    if (!nullToAbsent || goalPlanId != null) {
      map['goal_plan_id'] = Variable<String>(goalPlanId);
    }
    map['details_json'] = Variable<String>(detailsJson);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  FeedbackEventsCompanion toCompanion(bool nullToAbsent) {
    return FeedbackEventsCompanion(
      id: Value(id),
      eventType: Value(eventType),
      cardId: cardId == null && nullToAbsent
          ? const Value.absent()
          : Value(cardId),
      spaceId: spaceId == null && nullToAbsent
          ? const Value.absent()
          : Value(spaceId),
      sourceId: sourceId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceId),
      goalPlanId: goalPlanId == null && nullToAbsent
          ? const Value.absent()
          : Value(goalPlanId),
      detailsJson: Value(detailsJson),
      createdAt: Value(createdAt),
    );
  }

  factory FeedbackEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FeedbackEvent(
      id: serializer.fromJson<String>(json['id']),
      eventType: serializer.fromJson<String>(json['eventType']),
      cardId: serializer.fromJson<String?>(json['cardId']),
      spaceId: serializer.fromJson<String?>(json['spaceId']),
      sourceId: serializer.fromJson<String?>(json['sourceId']),
      goalPlanId: serializer.fromJson<String?>(json['goalPlanId']),
      detailsJson: serializer.fromJson<String>(json['detailsJson']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'eventType': serializer.toJson<String>(eventType),
      'cardId': serializer.toJson<String?>(cardId),
      'spaceId': serializer.toJson<String?>(spaceId),
      'sourceId': serializer.toJson<String?>(sourceId),
      'goalPlanId': serializer.toJson<String?>(goalPlanId),
      'detailsJson': serializer.toJson<String>(detailsJson),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  FeedbackEvent copyWith({
    String? id,
    String? eventType,
    Value<String?> cardId = const Value.absent(),
    Value<String?> spaceId = const Value.absent(),
    Value<String?> sourceId = const Value.absent(),
    Value<String?> goalPlanId = const Value.absent(),
    String? detailsJson,
    int? createdAt,
  }) => FeedbackEvent(
    id: id ?? this.id,
    eventType: eventType ?? this.eventType,
    cardId: cardId.present ? cardId.value : this.cardId,
    spaceId: spaceId.present ? spaceId.value : this.spaceId,
    sourceId: sourceId.present ? sourceId.value : this.sourceId,
    goalPlanId: goalPlanId.present ? goalPlanId.value : this.goalPlanId,
    detailsJson: detailsJson ?? this.detailsJson,
    createdAt: createdAt ?? this.createdAt,
  );
  FeedbackEvent copyWithCompanion(FeedbackEventsCompanion data) {
    return FeedbackEvent(
      id: data.id.present ? data.id.value : this.id,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      cardId: data.cardId.present ? data.cardId.value : this.cardId,
      spaceId: data.spaceId.present ? data.spaceId.value : this.spaceId,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      goalPlanId: data.goalPlanId.present
          ? data.goalPlanId.value
          : this.goalPlanId,
      detailsJson: data.detailsJson.present
          ? data.detailsJson.value
          : this.detailsJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FeedbackEvent(')
          ..write('id: $id, ')
          ..write('eventType: $eventType, ')
          ..write('cardId: $cardId, ')
          ..write('spaceId: $spaceId, ')
          ..write('sourceId: $sourceId, ')
          ..write('goalPlanId: $goalPlanId, ')
          ..write('detailsJson: $detailsJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    eventType,
    cardId,
    spaceId,
    sourceId,
    goalPlanId,
    detailsJson,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FeedbackEvent &&
          other.id == this.id &&
          other.eventType == this.eventType &&
          other.cardId == this.cardId &&
          other.spaceId == this.spaceId &&
          other.sourceId == this.sourceId &&
          other.goalPlanId == this.goalPlanId &&
          other.detailsJson == this.detailsJson &&
          other.createdAt == this.createdAt);
}

class FeedbackEventsCompanion extends UpdateCompanion<FeedbackEvent> {
  final Value<String> id;
  final Value<String> eventType;
  final Value<String?> cardId;
  final Value<String?> spaceId;
  final Value<String?> sourceId;
  final Value<String?> goalPlanId;
  final Value<String> detailsJson;
  final Value<int> createdAt;
  final Value<int> rowid;
  const FeedbackEventsCompanion({
    this.id = const Value.absent(),
    this.eventType = const Value.absent(),
    this.cardId = const Value.absent(),
    this.spaceId = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.goalPlanId = const Value.absent(),
    this.detailsJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FeedbackEventsCompanion.insert({
    required String id,
    required String eventType,
    this.cardId = const Value.absent(),
    this.spaceId = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.goalPlanId = const Value.absent(),
    this.detailsJson = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       eventType = Value(eventType),
       createdAt = Value(createdAt);
  static Insertable<FeedbackEvent> custom({
    Expression<String>? id,
    Expression<String>? eventType,
    Expression<String>? cardId,
    Expression<String>? spaceId,
    Expression<String>? sourceId,
    Expression<String>? goalPlanId,
    Expression<String>? detailsJson,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (eventType != null) 'event_type': eventType,
      if (cardId != null) 'card_id': cardId,
      if (spaceId != null) 'space_id': spaceId,
      if (sourceId != null) 'source_id': sourceId,
      if (goalPlanId != null) 'goal_plan_id': goalPlanId,
      if (detailsJson != null) 'details_json': detailsJson,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FeedbackEventsCompanion copyWith({
    Value<String>? id,
    Value<String>? eventType,
    Value<String?>? cardId,
    Value<String?>? spaceId,
    Value<String?>? sourceId,
    Value<String?>? goalPlanId,
    Value<String>? detailsJson,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return FeedbackEventsCompanion(
      id: id ?? this.id,
      eventType: eventType ?? this.eventType,
      cardId: cardId ?? this.cardId,
      spaceId: spaceId ?? this.spaceId,
      sourceId: sourceId ?? this.sourceId,
      goalPlanId: goalPlanId ?? this.goalPlanId,
      detailsJson: detailsJson ?? this.detailsJson,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (cardId.present) {
      map['card_id'] = Variable<String>(cardId.value);
    }
    if (spaceId.present) {
      map['space_id'] = Variable<String>(spaceId.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (goalPlanId.present) {
      map['goal_plan_id'] = Variable<String>(goalPlanId.value);
    }
    if (detailsJson.present) {
      map['details_json'] = Variable<String>(detailsJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FeedbackEventsCompanion(')
          ..write('id: $id, ')
          ..write('eventType: $eventType, ')
          ..write('cardId: $cardId, ')
          ..write('spaceId: $spaceId, ')
          ..write('sourceId: $sourceId, ')
          ..write('goalPlanId: $goalPlanId, ')
          ..write('detailsJson: $detailsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PreferenceMemoryTable extends PreferenceMemory
    with TableInfo<$PreferenceMemoryTable, PreferenceMemoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PreferenceMemoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    check: () => category.isIn(TagDatabaseValues.preferenceCategories),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueJsonMeta = const VerificationMeta(
    'valueJson',
  );
  @override
  late final GeneratedColumn<String> valueJson = GeneratedColumn<String>(
    'value_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
    'confidence',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _evidenceEventIdsJsonMeta =
      const VerificationMeta('evidenceEventIdsJson');
  @override
  late final GeneratedColumn<String> evidenceEventIdsJson =
      GeneratedColumn<String>(
        'evidence_event_ids_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    category,
    key,
    valueJson,
    confidence,
    evidenceEventIdsJson,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'preference_memory';
  @override
  VerificationContext validateIntegrity(
    Insertable<PreferenceMemoryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value_json')) {
      context.handle(
        _valueJsonMeta,
        valueJson.isAcceptableOrUnknown(data['value_json']!, _valueJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_valueJsonMeta);
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    } else if (isInserting) {
      context.missing(_confidenceMeta);
    }
    if (data.containsKey('evidence_event_ids_json')) {
      context.handle(
        _evidenceEventIdsJsonMeta,
        evidenceEventIdsJson.isAcceptableOrUnknown(
          data['evidence_event_ids_json']!,
          _evidenceEventIdsJsonMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PreferenceMemoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PreferenceMemoryData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      valueJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value_json'],
      )!,
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      )!,
      evidenceEventIdsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}evidence_event_ids_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PreferenceMemoryTable createAlias(String alias) {
    return $PreferenceMemoryTable(attachedDatabase, alias);
  }
}

class PreferenceMemoryData extends DataClass
    implements Insertable<PreferenceMemoryData> {
  final String id;
  final String category;
  final String key;
  final String valueJson;
  final double confidence;
  final String evidenceEventIdsJson;
  final int createdAt;
  final int updatedAt;
  const PreferenceMemoryData({
    required this.id,
    required this.category,
    required this.key,
    required this.valueJson,
    required this.confidence,
    required this.evidenceEventIdsJson,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['category'] = Variable<String>(category);
    map['key'] = Variable<String>(key);
    map['value_json'] = Variable<String>(valueJson);
    map['confidence'] = Variable<double>(confidence);
    map['evidence_event_ids_json'] = Variable<String>(evidenceEventIdsJson);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  PreferenceMemoryCompanion toCompanion(bool nullToAbsent) {
    return PreferenceMemoryCompanion(
      id: Value(id),
      category: Value(category),
      key: Value(key),
      valueJson: Value(valueJson),
      confidence: Value(confidence),
      evidenceEventIdsJson: Value(evidenceEventIdsJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory PreferenceMemoryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PreferenceMemoryData(
      id: serializer.fromJson<String>(json['id']),
      category: serializer.fromJson<String>(json['category']),
      key: serializer.fromJson<String>(json['key']),
      valueJson: serializer.fromJson<String>(json['valueJson']),
      confidence: serializer.fromJson<double>(json['confidence']),
      evidenceEventIdsJson: serializer.fromJson<String>(
        json['evidenceEventIdsJson'],
      ),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'category': serializer.toJson<String>(category),
      'key': serializer.toJson<String>(key),
      'valueJson': serializer.toJson<String>(valueJson),
      'confidence': serializer.toJson<double>(confidence),
      'evidenceEventIdsJson': serializer.toJson<String>(evidenceEventIdsJson),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  PreferenceMemoryData copyWith({
    String? id,
    String? category,
    String? key,
    String? valueJson,
    double? confidence,
    String? evidenceEventIdsJson,
    int? createdAt,
    int? updatedAt,
  }) => PreferenceMemoryData(
    id: id ?? this.id,
    category: category ?? this.category,
    key: key ?? this.key,
    valueJson: valueJson ?? this.valueJson,
    confidence: confidence ?? this.confidence,
    evidenceEventIdsJson: evidenceEventIdsJson ?? this.evidenceEventIdsJson,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PreferenceMemoryData copyWithCompanion(PreferenceMemoryCompanion data) {
    return PreferenceMemoryData(
      id: data.id.present ? data.id.value : this.id,
      category: data.category.present ? data.category.value : this.category,
      key: data.key.present ? data.key.value : this.key,
      valueJson: data.valueJson.present ? data.valueJson.value : this.valueJson,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      evidenceEventIdsJson: data.evidenceEventIdsJson.present
          ? data.evidenceEventIdsJson.value
          : this.evidenceEventIdsJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PreferenceMemoryData(')
          ..write('id: $id, ')
          ..write('category: $category, ')
          ..write('key: $key, ')
          ..write('valueJson: $valueJson, ')
          ..write('confidence: $confidence, ')
          ..write('evidenceEventIdsJson: $evidenceEventIdsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    category,
    key,
    valueJson,
    confidence,
    evidenceEventIdsJson,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PreferenceMemoryData &&
          other.id == this.id &&
          other.category == this.category &&
          other.key == this.key &&
          other.valueJson == this.valueJson &&
          other.confidence == this.confidence &&
          other.evidenceEventIdsJson == this.evidenceEventIdsJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PreferenceMemoryCompanion extends UpdateCompanion<PreferenceMemoryData> {
  final Value<String> id;
  final Value<String> category;
  final Value<String> key;
  final Value<String> valueJson;
  final Value<double> confidence;
  final Value<String> evidenceEventIdsJson;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const PreferenceMemoryCompanion({
    this.id = const Value.absent(),
    this.category = const Value.absent(),
    this.key = const Value.absent(),
    this.valueJson = const Value.absent(),
    this.confidence = const Value.absent(),
    this.evidenceEventIdsJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PreferenceMemoryCompanion.insert({
    required String id,
    required String category,
    required String key,
    required String valueJson,
    required double confidence,
    this.evidenceEventIdsJson = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       category = Value(category),
       key = Value(key),
       valueJson = Value(valueJson),
       confidence = Value(confidence),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<PreferenceMemoryData> custom({
    Expression<String>? id,
    Expression<String>? category,
    Expression<String>? key,
    Expression<String>? valueJson,
    Expression<double>? confidence,
    Expression<String>? evidenceEventIdsJson,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (category != null) 'category': category,
      if (key != null) 'key': key,
      if (valueJson != null) 'value_json': valueJson,
      if (confidence != null) 'confidence': confidence,
      if (evidenceEventIdsJson != null)
        'evidence_event_ids_json': evidenceEventIdsJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PreferenceMemoryCompanion copyWith({
    Value<String>? id,
    Value<String>? category,
    Value<String>? key,
    Value<String>? valueJson,
    Value<double>? confidence,
    Value<String>? evidenceEventIdsJson,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return PreferenceMemoryCompanion(
      id: id ?? this.id,
      category: category ?? this.category,
      key: key ?? this.key,
      valueJson: valueJson ?? this.valueJson,
      confidence: confidence ?? this.confidence,
      evidenceEventIdsJson: evidenceEventIdsJson ?? this.evidenceEventIdsJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (valueJson.present) {
      map['value_json'] = Variable<String>(valueJson.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (evidenceEventIdsJson.present) {
      map['evidence_event_ids_json'] = Variable<String>(
        evidenceEventIdsJson.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PreferenceMemoryCompanion(')
          ..write('id: $id, ')
          ..write('category: $category, ')
          ..write('key: $key, ')
          ..write('valueJson: $valueJson, ')
          ..write('confidence: $confidence, ')
          ..write('evidenceEventIdsJson: $evidenceEventIdsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NotificationRequestsTable extends NotificationRequests
    with TableInfo<$NotificationRequestsTable, NotificationRequest> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotificationRequestsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
  @override
  late final GeneratedColumn<String> cardId = GeneratedColumn<String>(
    'card_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tag_cards (id)',
    ),
  );
  static const VerificationMeta _platformNotificationIdMeta =
      const VerificationMeta('platformNotificationId');
  @override
  late final GeneratedColumn<int> platformNotificationId = GeneratedColumn<int>(
    'platform_notification_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scheduledForMeta = const VerificationMeta(
    'scheduledFor',
  );
  @override
  late final GeneratedColumn<int> scheduledFor = GeneratedColumn<int>(
    'scheduled_for',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timezoneMeta = const VerificationMeta(
    'timezone',
  );
  @override
  late final GeneratedColumn<String> timezone = GeneratedColumn<String>(
    'timezone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    check: () => status.isIn(TagDatabaseValues.notificationStatuses),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actionsJsonMeta = const VerificationMeta(
    'actionsJson',
  );
  @override
  late final GeneratedColumn<String> actionsJson = GeneratedColumn<String>(
    'actions_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _failureReasonMeta = const VerificationMeta(
    'failureReason',
  );
  @override
  late final GeneratedColumn<String> failureReason = GeneratedColumn<String>(
    'failure_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cancelledAtMeta = const VerificationMeta(
    'cancelledAt',
  );
  @override
  late final GeneratedColumn<int> cancelledAt = GeneratedColumn<int>(
    'cancelled_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cardId,
    platformNotificationId,
    scheduledFor,
    timezone,
    status,
    title,
    body,
    actionsJson,
    failureReason,
    createdAt,
    updatedAt,
    cancelledAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notification_requests';
  @override
  VerificationContext validateIntegrity(
    Insertable<NotificationRequest> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('card_id')) {
      context.handle(
        _cardIdMeta,
        cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cardIdMeta);
    }
    if (data.containsKey('platform_notification_id')) {
      context.handle(
        _platformNotificationIdMeta,
        platformNotificationId.isAcceptableOrUnknown(
          data['platform_notification_id']!,
          _platformNotificationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_platformNotificationIdMeta);
    }
    if (data.containsKey('scheduled_for')) {
      context.handle(
        _scheduledForMeta,
        scheduledFor.isAcceptableOrUnknown(
          data['scheduled_for']!,
          _scheduledForMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduledForMeta);
    }
    if (data.containsKey('timezone')) {
      context.handle(
        _timezoneMeta,
        timezone.isAcceptableOrUnknown(data['timezone']!, _timezoneMeta),
      );
    } else if (isInserting) {
      context.missing(_timezoneMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('actions_json')) {
      context.handle(
        _actionsJsonMeta,
        actionsJson.isAcceptableOrUnknown(
          data['actions_json']!,
          _actionsJsonMeta,
        ),
      );
    }
    if (data.containsKey('failure_reason')) {
      context.handle(
        _failureReasonMeta,
        failureReason.isAcceptableOrUnknown(
          data['failure_reason']!,
          _failureReasonMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('cancelled_at')) {
      context.handle(
        _cancelledAtMeta,
        cancelledAt.isAcceptableOrUnknown(
          data['cancelled_at']!,
          _cancelledAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NotificationRequest map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NotificationRequest(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      cardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}card_id'],
      )!,
      platformNotificationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}platform_notification_id'],
      )!,
      scheduledFor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}scheduled_for'],
      )!,
      timezone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}timezone'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      actionsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}actions_json'],
      )!,
      failureReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}failure_reason'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      cancelledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cancelled_at'],
      ),
    );
  }

  @override
  $NotificationRequestsTable createAlias(String alias) {
    return $NotificationRequestsTable(attachedDatabase, alias);
  }
}

class NotificationRequest extends DataClass
    implements Insertable<NotificationRequest> {
  final String id;
  final String cardId;
  final int platformNotificationId;
  final int scheduledFor;
  final String timezone;
  final String status;
  final String title;
  final String body;
  final String actionsJson;
  final String? failureReason;
  final int createdAt;
  final int updatedAt;
  final int? cancelledAt;
  const NotificationRequest({
    required this.id,
    required this.cardId,
    required this.platformNotificationId,
    required this.scheduledFor,
    required this.timezone,
    required this.status,
    required this.title,
    required this.body,
    required this.actionsJson,
    this.failureReason,
    required this.createdAt,
    required this.updatedAt,
    this.cancelledAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['card_id'] = Variable<String>(cardId);
    map['platform_notification_id'] = Variable<int>(platformNotificationId);
    map['scheduled_for'] = Variable<int>(scheduledFor);
    map['timezone'] = Variable<String>(timezone);
    map['status'] = Variable<String>(status);
    map['title'] = Variable<String>(title);
    map['body'] = Variable<String>(body);
    map['actions_json'] = Variable<String>(actionsJson);
    if (!nullToAbsent || failureReason != null) {
      map['failure_reason'] = Variable<String>(failureReason);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || cancelledAt != null) {
      map['cancelled_at'] = Variable<int>(cancelledAt);
    }
    return map;
  }

  NotificationRequestsCompanion toCompanion(bool nullToAbsent) {
    return NotificationRequestsCompanion(
      id: Value(id),
      cardId: Value(cardId),
      platformNotificationId: Value(platformNotificationId),
      scheduledFor: Value(scheduledFor),
      timezone: Value(timezone),
      status: Value(status),
      title: Value(title),
      body: Value(body),
      actionsJson: Value(actionsJson),
      failureReason: failureReason == null && nullToAbsent
          ? const Value.absent()
          : Value(failureReason),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      cancelledAt: cancelledAt == null && nullToAbsent
          ? const Value.absent()
          : Value(cancelledAt),
    );
  }

  factory NotificationRequest.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NotificationRequest(
      id: serializer.fromJson<String>(json['id']),
      cardId: serializer.fromJson<String>(json['cardId']),
      platformNotificationId: serializer.fromJson<int>(
        json['platformNotificationId'],
      ),
      scheduledFor: serializer.fromJson<int>(json['scheduledFor']),
      timezone: serializer.fromJson<String>(json['timezone']),
      status: serializer.fromJson<String>(json['status']),
      title: serializer.fromJson<String>(json['title']),
      body: serializer.fromJson<String>(json['body']),
      actionsJson: serializer.fromJson<String>(json['actionsJson']),
      failureReason: serializer.fromJson<String?>(json['failureReason']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      cancelledAt: serializer.fromJson<int?>(json['cancelledAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'cardId': serializer.toJson<String>(cardId),
      'platformNotificationId': serializer.toJson<int>(platformNotificationId),
      'scheduledFor': serializer.toJson<int>(scheduledFor),
      'timezone': serializer.toJson<String>(timezone),
      'status': serializer.toJson<String>(status),
      'title': serializer.toJson<String>(title),
      'body': serializer.toJson<String>(body),
      'actionsJson': serializer.toJson<String>(actionsJson),
      'failureReason': serializer.toJson<String?>(failureReason),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'cancelledAt': serializer.toJson<int?>(cancelledAt),
    };
  }

  NotificationRequest copyWith({
    String? id,
    String? cardId,
    int? platformNotificationId,
    int? scheduledFor,
    String? timezone,
    String? status,
    String? title,
    String? body,
    String? actionsJson,
    Value<String?> failureReason = const Value.absent(),
    int? createdAt,
    int? updatedAt,
    Value<int?> cancelledAt = const Value.absent(),
  }) => NotificationRequest(
    id: id ?? this.id,
    cardId: cardId ?? this.cardId,
    platformNotificationId:
        platformNotificationId ?? this.platformNotificationId,
    scheduledFor: scheduledFor ?? this.scheduledFor,
    timezone: timezone ?? this.timezone,
    status: status ?? this.status,
    title: title ?? this.title,
    body: body ?? this.body,
    actionsJson: actionsJson ?? this.actionsJson,
    failureReason: failureReason.present
        ? failureReason.value
        : this.failureReason,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    cancelledAt: cancelledAt.present ? cancelledAt.value : this.cancelledAt,
  );
  NotificationRequest copyWithCompanion(NotificationRequestsCompanion data) {
    return NotificationRequest(
      id: data.id.present ? data.id.value : this.id,
      cardId: data.cardId.present ? data.cardId.value : this.cardId,
      platformNotificationId: data.platformNotificationId.present
          ? data.platformNotificationId.value
          : this.platformNotificationId,
      scheduledFor: data.scheduledFor.present
          ? data.scheduledFor.value
          : this.scheduledFor,
      timezone: data.timezone.present ? data.timezone.value : this.timezone,
      status: data.status.present ? data.status.value : this.status,
      title: data.title.present ? data.title.value : this.title,
      body: data.body.present ? data.body.value : this.body,
      actionsJson: data.actionsJson.present
          ? data.actionsJson.value
          : this.actionsJson,
      failureReason: data.failureReason.present
          ? data.failureReason.value
          : this.failureReason,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      cancelledAt: data.cancelledAt.present
          ? data.cancelledAt.value
          : this.cancelledAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NotificationRequest(')
          ..write('id: $id, ')
          ..write('cardId: $cardId, ')
          ..write('platformNotificationId: $platformNotificationId, ')
          ..write('scheduledFor: $scheduledFor, ')
          ..write('timezone: $timezone, ')
          ..write('status: $status, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('actionsJson: $actionsJson, ')
          ..write('failureReason: $failureReason, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('cancelledAt: $cancelledAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    cardId,
    platformNotificationId,
    scheduledFor,
    timezone,
    status,
    title,
    body,
    actionsJson,
    failureReason,
    createdAt,
    updatedAt,
    cancelledAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NotificationRequest &&
          other.id == this.id &&
          other.cardId == this.cardId &&
          other.platformNotificationId == this.platformNotificationId &&
          other.scheduledFor == this.scheduledFor &&
          other.timezone == this.timezone &&
          other.status == this.status &&
          other.title == this.title &&
          other.body == this.body &&
          other.actionsJson == this.actionsJson &&
          other.failureReason == this.failureReason &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.cancelledAt == this.cancelledAt);
}

class NotificationRequestsCompanion
    extends UpdateCompanion<NotificationRequest> {
  final Value<String> id;
  final Value<String> cardId;
  final Value<int> platformNotificationId;
  final Value<int> scheduledFor;
  final Value<String> timezone;
  final Value<String> status;
  final Value<String> title;
  final Value<String> body;
  final Value<String> actionsJson;
  final Value<String?> failureReason;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> cancelledAt;
  final Value<int> rowid;
  const NotificationRequestsCompanion({
    this.id = const Value.absent(),
    this.cardId = const Value.absent(),
    this.platformNotificationId = const Value.absent(),
    this.scheduledFor = const Value.absent(),
    this.timezone = const Value.absent(),
    this.status = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.actionsJson = const Value.absent(),
    this.failureReason = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.cancelledAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NotificationRequestsCompanion.insert({
    required String id,
    required String cardId,
    required int platformNotificationId,
    required int scheduledFor,
    required String timezone,
    required String status,
    required String title,
    required String body,
    this.actionsJson = const Value.absent(),
    this.failureReason = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.cancelledAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       cardId = Value(cardId),
       platformNotificationId = Value(platformNotificationId),
       scheduledFor = Value(scheduledFor),
       timezone = Value(timezone),
       status = Value(status),
       title = Value(title),
       body = Value(body),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<NotificationRequest> custom({
    Expression<String>? id,
    Expression<String>? cardId,
    Expression<int>? platformNotificationId,
    Expression<int>? scheduledFor,
    Expression<String>? timezone,
    Expression<String>? status,
    Expression<String>? title,
    Expression<String>? body,
    Expression<String>? actionsJson,
    Expression<String>? failureReason,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? cancelledAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cardId != null) 'card_id': cardId,
      if (platformNotificationId != null)
        'platform_notification_id': platformNotificationId,
      if (scheduledFor != null) 'scheduled_for': scheduledFor,
      if (timezone != null) 'timezone': timezone,
      if (status != null) 'status': status,
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (actionsJson != null) 'actions_json': actionsJson,
      if (failureReason != null) 'failure_reason': failureReason,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (cancelledAt != null) 'cancelled_at': cancelledAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NotificationRequestsCompanion copyWith({
    Value<String>? id,
    Value<String>? cardId,
    Value<int>? platformNotificationId,
    Value<int>? scheduledFor,
    Value<String>? timezone,
    Value<String>? status,
    Value<String>? title,
    Value<String>? body,
    Value<String>? actionsJson,
    Value<String?>? failureReason,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? cancelledAt,
    Value<int>? rowid,
  }) {
    return NotificationRequestsCompanion(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      platformNotificationId:
          platformNotificationId ?? this.platformNotificationId,
      scheduledFor: scheduledFor ?? this.scheduledFor,
      timezone: timezone ?? this.timezone,
      status: status ?? this.status,
      title: title ?? this.title,
      body: body ?? this.body,
      actionsJson: actionsJson ?? this.actionsJson,
      failureReason: failureReason ?? this.failureReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (cardId.present) {
      map['card_id'] = Variable<String>(cardId.value);
    }
    if (platformNotificationId.present) {
      map['platform_notification_id'] = Variable<int>(
        platformNotificationId.value,
      );
    }
    if (scheduledFor.present) {
      map['scheduled_for'] = Variable<int>(scheduledFor.value);
    }
    if (timezone.present) {
      map['timezone'] = Variable<String>(timezone.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (actionsJson.present) {
      map['actions_json'] = Variable<String>(actionsJson.value);
    }
    if (failureReason.present) {
      map['failure_reason'] = Variable<String>(failureReason.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (cancelledAt.present) {
      map['cancelled_at'] = Variable<int>(cancelledAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotificationRequestsCompanion(')
          ..write('id: $id, ')
          ..write('cardId: $cardId, ')
          ..write('platformNotificationId: $platformNotificationId, ')
          ..write('scheduledFor: $scheduledFor, ')
          ..write('timezone: $timezone, ')
          ..write('status: $status, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('actionsJson: $actionsJson, ')
          ..write('failureReason: $failureReason, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('cancelledAt: $cancelledAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AiProcessingJobsTable extends AiProcessingJobs
    with TableInfo<$AiProcessingJobsTable, AiProcessingJob> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AiProcessingJobsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jobTypeMeta = const VerificationMeta(
    'jobType',
  );
  @override
  late final GeneratedColumn<String> jobType = GeneratedColumn<String>(
    'job_type',
    aliasedName,
    false,
    check: () => jobType.isIn(TagDatabaseValues.aiJobTypes),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    check: () => status.isIn(TagDatabaseValues.aiJobStatuses),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES source_items (id)',
    ),
  );
  static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
  @override
  late final GeneratedColumn<String> cardId = GeneratedColumn<String>(
    'card_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tag_cards (id)',
    ),
  );
  static const VerificationMeta _spaceIdMeta = const VerificationMeta(
    'spaceId',
  );
  @override
  late final GeneratedColumn<String> spaceId = GeneratedColumn<String>(
    'space_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES spaces (id)',
    ),
  );
  static const VerificationMeta _chatSessionIdMeta = const VerificationMeta(
    'chatSessionId',
  );
  @override
  late final GeneratedColumn<String> chatSessionId = GeneratedColumn<String>(
    'chat_session_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES chat_sessions (id)',
    ),
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(100),
  );
  static const VerificationMeta _attemptCountMeta = const VerificationMeta(
    'attemptCount',
  );
  @override
  late final GeneratedColumn<int> attemptCount = GeneratedColumn<int>(
    'attempt_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _maxAttemptsMeta = const VerificationMeta(
    'maxAttempts',
  );
  @override
  late final GeneratedColumn<int> maxAttempts = GeneratedColumn<int>(
    'max_attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(3),
  );
  static const VerificationMeta _inputJsonMeta = const VerificationMeta(
    'inputJson',
  );
  @override
  late final GeneratedColumn<String> inputJson = GeneratedColumn<String>(
    'input_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _outputJsonMeta = const VerificationMeta(
    'outputJson',
  );
  @override
  late final GeneratedColumn<String> outputJson = GeneratedColumn<String>(
    'output_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _errorMessageMeta = const VerificationMeta(
    'errorMessage',
  );
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
    'error_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _modelSlugMeta = const VerificationMeta(
    'modelSlug',
  );
  @override
  late final GeneratedColumn<String> modelSlug = GeneratedColumn<String>(
    'model_slug',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _queuedAtMeta = const VerificationMeta(
    'queuedAt',
  );
  @override
  late final GeneratedColumn<int> queuedAt = GeneratedColumn<int>(
    'queued_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<int> startedAt = GeneratedColumn<int>(
    'started_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<int> completedAt = GeneratedColumn<int>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    jobType,
    status,
    sourceId,
    cardId,
    spaceId,
    chatSessionId,
    priority,
    attemptCount,
    maxAttempts,
    inputJson,
    outputJson,
    errorMessage,
    modelSlug,
    queuedAt,
    startedAt,
    completedAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ai_processing_jobs';
  @override
  VerificationContext validateIntegrity(
    Insertable<AiProcessingJob> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('job_type')) {
      context.handle(
        _jobTypeMeta,
        jobType.isAcceptableOrUnknown(data['job_type']!, _jobTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_jobTypeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    }
    if (data.containsKey('card_id')) {
      context.handle(
        _cardIdMeta,
        cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta),
      );
    }
    if (data.containsKey('space_id')) {
      context.handle(
        _spaceIdMeta,
        spaceId.isAcceptableOrUnknown(data['space_id']!, _spaceIdMeta),
      );
    }
    if (data.containsKey('chat_session_id')) {
      context.handle(
        _chatSessionIdMeta,
        chatSessionId.isAcceptableOrUnknown(
          data['chat_session_id']!,
          _chatSessionIdMeta,
        ),
      );
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    }
    if (data.containsKey('attempt_count')) {
      context.handle(
        _attemptCountMeta,
        attemptCount.isAcceptableOrUnknown(
          data['attempt_count']!,
          _attemptCountMeta,
        ),
      );
    }
    if (data.containsKey('max_attempts')) {
      context.handle(
        _maxAttemptsMeta,
        maxAttempts.isAcceptableOrUnknown(
          data['max_attempts']!,
          _maxAttemptsMeta,
        ),
      );
    }
    if (data.containsKey('input_json')) {
      context.handle(
        _inputJsonMeta,
        inputJson.isAcceptableOrUnknown(data['input_json']!, _inputJsonMeta),
      );
    }
    if (data.containsKey('output_json')) {
      context.handle(
        _outputJsonMeta,
        outputJson.isAcceptableOrUnknown(data['output_json']!, _outputJsonMeta),
      );
    }
    if (data.containsKey('error_message')) {
      context.handle(
        _errorMessageMeta,
        errorMessage.isAcceptableOrUnknown(
          data['error_message']!,
          _errorMessageMeta,
        ),
      );
    }
    if (data.containsKey('model_slug')) {
      context.handle(
        _modelSlugMeta,
        modelSlug.isAcceptableOrUnknown(data['model_slug']!, _modelSlugMeta),
      );
    }
    if (data.containsKey('queued_at')) {
      context.handle(
        _queuedAtMeta,
        queuedAt.isAcceptableOrUnknown(data['queued_at']!, _queuedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_queuedAtMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AiProcessingJob map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AiProcessingJob(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      jobType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}job_type'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      ),
      cardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}card_id'],
      ),
      spaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}space_id'],
      ),
      chatSessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chat_session_id'],
      ),
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}priority'],
      )!,
      attemptCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempt_count'],
      )!,
      maxAttempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_attempts'],
      )!,
      inputJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}input_json'],
      )!,
      outputJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}output_json'],
      ),
      errorMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_message'],
      ),
      modelSlug: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_slug'],
      ),
      queuedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}queued_at'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}started_at'],
      ),
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AiProcessingJobsTable createAlias(String alias) {
    return $AiProcessingJobsTable(attachedDatabase, alias);
  }
}

class AiProcessingJob extends DataClass implements Insertable<AiProcessingJob> {
  final String id;
  final String jobType;
  final String status;
  final String? sourceId;
  final String? cardId;
  final String? spaceId;
  final String? chatSessionId;
  final int priority;
  final int attemptCount;
  final int maxAttempts;
  final String inputJson;
  final String? outputJson;
  final String? errorMessage;
  final String? modelSlug;
  final int queuedAt;
  final int? startedAt;
  final int? completedAt;
  final int updatedAt;
  const AiProcessingJob({
    required this.id,
    required this.jobType,
    required this.status,
    this.sourceId,
    this.cardId,
    this.spaceId,
    this.chatSessionId,
    required this.priority,
    required this.attemptCount,
    required this.maxAttempts,
    required this.inputJson,
    this.outputJson,
    this.errorMessage,
    this.modelSlug,
    required this.queuedAt,
    this.startedAt,
    this.completedAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['job_type'] = Variable<String>(jobType);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || sourceId != null) {
      map['source_id'] = Variable<String>(sourceId);
    }
    if (!nullToAbsent || cardId != null) {
      map['card_id'] = Variable<String>(cardId);
    }
    if (!nullToAbsent || spaceId != null) {
      map['space_id'] = Variable<String>(spaceId);
    }
    if (!nullToAbsent || chatSessionId != null) {
      map['chat_session_id'] = Variable<String>(chatSessionId);
    }
    map['priority'] = Variable<int>(priority);
    map['attempt_count'] = Variable<int>(attemptCount);
    map['max_attempts'] = Variable<int>(maxAttempts);
    map['input_json'] = Variable<String>(inputJson);
    if (!nullToAbsent || outputJson != null) {
      map['output_json'] = Variable<String>(outputJson);
    }
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    if (!nullToAbsent || modelSlug != null) {
      map['model_slug'] = Variable<String>(modelSlug);
    }
    map['queued_at'] = Variable<int>(queuedAt);
    if (!nullToAbsent || startedAt != null) {
      map['started_at'] = Variable<int>(startedAt);
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<int>(completedAt);
    }
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  AiProcessingJobsCompanion toCompanion(bool nullToAbsent) {
    return AiProcessingJobsCompanion(
      id: Value(id),
      jobType: Value(jobType),
      status: Value(status),
      sourceId: sourceId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceId),
      cardId: cardId == null && nullToAbsent
          ? const Value.absent()
          : Value(cardId),
      spaceId: spaceId == null && nullToAbsent
          ? const Value.absent()
          : Value(spaceId),
      chatSessionId: chatSessionId == null && nullToAbsent
          ? const Value.absent()
          : Value(chatSessionId),
      priority: Value(priority),
      attemptCount: Value(attemptCount),
      maxAttempts: Value(maxAttempts),
      inputJson: Value(inputJson),
      outputJson: outputJson == null && nullToAbsent
          ? const Value.absent()
          : Value(outputJson),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
      modelSlug: modelSlug == null && nullToAbsent
          ? const Value.absent()
          : Value(modelSlug),
      queuedAt: Value(queuedAt),
      startedAt: startedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(startedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory AiProcessingJob.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AiProcessingJob(
      id: serializer.fromJson<String>(json['id']),
      jobType: serializer.fromJson<String>(json['jobType']),
      status: serializer.fromJson<String>(json['status']),
      sourceId: serializer.fromJson<String?>(json['sourceId']),
      cardId: serializer.fromJson<String?>(json['cardId']),
      spaceId: serializer.fromJson<String?>(json['spaceId']),
      chatSessionId: serializer.fromJson<String?>(json['chatSessionId']),
      priority: serializer.fromJson<int>(json['priority']),
      attemptCount: serializer.fromJson<int>(json['attemptCount']),
      maxAttempts: serializer.fromJson<int>(json['maxAttempts']),
      inputJson: serializer.fromJson<String>(json['inputJson']),
      outputJson: serializer.fromJson<String?>(json['outputJson']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
      modelSlug: serializer.fromJson<String?>(json['modelSlug']),
      queuedAt: serializer.fromJson<int>(json['queuedAt']),
      startedAt: serializer.fromJson<int?>(json['startedAt']),
      completedAt: serializer.fromJson<int?>(json['completedAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'jobType': serializer.toJson<String>(jobType),
      'status': serializer.toJson<String>(status),
      'sourceId': serializer.toJson<String?>(sourceId),
      'cardId': serializer.toJson<String?>(cardId),
      'spaceId': serializer.toJson<String?>(spaceId),
      'chatSessionId': serializer.toJson<String?>(chatSessionId),
      'priority': serializer.toJson<int>(priority),
      'attemptCount': serializer.toJson<int>(attemptCount),
      'maxAttempts': serializer.toJson<int>(maxAttempts),
      'inputJson': serializer.toJson<String>(inputJson),
      'outputJson': serializer.toJson<String?>(outputJson),
      'errorMessage': serializer.toJson<String?>(errorMessage),
      'modelSlug': serializer.toJson<String?>(modelSlug),
      'queuedAt': serializer.toJson<int>(queuedAt),
      'startedAt': serializer.toJson<int?>(startedAt),
      'completedAt': serializer.toJson<int?>(completedAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  AiProcessingJob copyWith({
    String? id,
    String? jobType,
    String? status,
    Value<String?> sourceId = const Value.absent(),
    Value<String?> cardId = const Value.absent(),
    Value<String?> spaceId = const Value.absent(),
    Value<String?> chatSessionId = const Value.absent(),
    int? priority,
    int? attemptCount,
    int? maxAttempts,
    String? inputJson,
    Value<String?> outputJson = const Value.absent(),
    Value<String?> errorMessage = const Value.absent(),
    Value<String?> modelSlug = const Value.absent(),
    int? queuedAt,
    Value<int?> startedAt = const Value.absent(),
    Value<int?> completedAt = const Value.absent(),
    int? updatedAt,
  }) => AiProcessingJob(
    id: id ?? this.id,
    jobType: jobType ?? this.jobType,
    status: status ?? this.status,
    sourceId: sourceId.present ? sourceId.value : this.sourceId,
    cardId: cardId.present ? cardId.value : this.cardId,
    spaceId: spaceId.present ? spaceId.value : this.spaceId,
    chatSessionId: chatSessionId.present
        ? chatSessionId.value
        : this.chatSessionId,
    priority: priority ?? this.priority,
    attemptCount: attemptCount ?? this.attemptCount,
    maxAttempts: maxAttempts ?? this.maxAttempts,
    inputJson: inputJson ?? this.inputJson,
    outputJson: outputJson.present ? outputJson.value : this.outputJson,
    errorMessage: errorMessage.present ? errorMessage.value : this.errorMessage,
    modelSlug: modelSlug.present ? modelSlug.value : this.modelSlug,
    queuedAt: queuedAt ?? this.queuedAt,
    startedAt: startedAt.present ? startedAt.value : this.startedAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AiProcessingJob copyWithCompanion(AiProcessingJobsCompanion data) {
    return AiProcessingJob(
      id: data.id.present ? data.id.value : this.id,
      jobType: data.jobType.present ? data.jobType.value : this.jobType,
      status: data.status.present ? data.status.value : this.status,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      cardId: data.cardId.present ? data.cardId.value : this.cardId,
      spaceId: data.spaceId.present ? data.spaceId.value : this.spaceId,
      chatSessionId: data.chatSessionId.present
          ? data.chatSessionId.value
          : this.chatSessionId,
      priority: data.priority.present ? data.priority.value : this.priority,
      attemptCount: data.attemptCount.present
          ? data.attemptCount.value
          : this.attemptCount,
      maxAttempts: data.maxAttempts.present
          ? data.maxAttempts.value
          : this.maxAttempts,
      inputJson: data.inputJson.present ? data.inputJson.value : this.inputJson,
      outputJson: data.outputJson.present
          ? data.outputJson.value
          : this.outputJson,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
      modelSlug: data.modelSlug.present ? data.modelSlug.value : this.modelSlug,
      queuedAt: data.queuedAt.present ? data.queuedAt.value : this.queuedAt,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AiProcessingJob(')
          ..write('id: $id, ')
          ..write('jobType: $jobType, ')
          ..write('status: $status, ')
          ..write('sourceId: $sourceId, ')
          ..write('cardId: $cardId, ')
          ..write('spaceId: $spaceId, ')
          ..write('chatSessionId: $chatSessionId, ')
          ..write('priority: $priority, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('maxAttempts: $maxAttempts, ')
          ..write('inputJson: $inputJson, ')
          ..write('outputJson: $outputJson, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('modelSlug: $modelSlug, ')
          ..write('queuedAt: $queuedAt, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    jobType,
    status,
    sourceId,
    cardId,
    spaceId,
    chatSessionId,
    priority,
    attemptCount,
    maxAttempts,
    inputJson,
    outputJson,
    errorMessage,
    modelSlug,
    queuedAt,
    startedAt,
    completedAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AiProcessingJob &&
          other.id == this.id &&
          other.jobType == this.jobType &&
          other.status == this.status &&
          other.sourceId == this.sourceId &&
          other.cardId == this.cardId &&
          other.spaceId == this.spaceId &&
          other.chatSessionId == this.chatSessionId &&
          other.priority == this.priority &&
          other.attemptCount == this.attemptCount &&
          other.maxAttempts == this.maxAttempts &&
          other.inputJson == this.inputJson &&
          other.outputJson == this.outputJson &&
          other.errorMessage == this.errorMessage &&
          other.modelSlug == this.modelSlug &&
          other.queuedAt == this.queuedAt &&
          other.startedAt == this.startedAt &&
          other.completedAt == this.completedAt &&
          other.updatedAt == this.updatedAt);
}

class AiProcessingJobsCompanion extends UpdateCompanion<AiProcessingJob> {
  final Value<String> id;
  final Value<String> jobType;
  final Value<String> status;
  final Value<String?> sourceId;
  final Value<String?> cardId;
  final Value<String?> spaceId;
  final Value<String?> chatSessionId;
  final Value<int> priority;
  final Value<int> attemptCount;
  final Value<int> maxAttempts;
  final Value<String> inputJson;
  final Value<String?> outputJson;
  final Value<String?> errorMessage;
  final Value<String?> modelSlug;
  final Value<int> queuedAt;
  final Value<int?> startedAt;
  final Value<int?> completedAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const AiProcessingJobsCompanion({
    this.id = const Value.absent(),
    this.jobType = const Value.absent(),
    this.status = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.cardId = const Value.absent(),
    this.spaceId = const Value.absent(),
    this.chatSessionId = const Value.absent(),
    this.priority = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.maxAttempts = const Value.absent(),
    this.inputJson = const Value.absent(),
    this.outputJson = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.modelSlug = const Value.absent(),
    this.queuedAt = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AiProcessingJobsCompanion.insert({
    required String id,
    required String jobType,
    required String status,
    this.sourceId = const Value.absent(),
    this.cardId = const Value.absent(),
    this.spaceId = const Value.absent(),
    this.chatSessionId = const Value.absent(),
    this.priority = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.maxAttempts = const Value.absent(),
    this.inputJson = const Value.absent(),
    this.outputJson = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.modelSlug = const Value.absent(),
    required int queuedAt,
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       jobType = Value(jobType),
       status = Value(status),
       queuedAt = Value(queuedAt),
       updatedAt = Value(updatedAt);
  static Insertable<AiProcessingJob> custom({
    Expression<String>? id,
    Expression<String>? jobType,
    Expression<String>? status,
    Expression<String>? sourceId,
    Expression<String>? cardId,
    Expression<String>? spaceId,
    Expression<String>? chatSessionId,
    Expression<int>? priority,
    Expression<int>? attemptCount,
    Expression<int>? maxAttempts,
    Expression<String>? inputJson,
    Expression<String>? outputJson,
    Expression<String>? errorMessage,
    Expression<String>? modelSlug,
    Expression<int>? queuedAt,
    Expression<int>? startedAt,
    Expression<int>? completedAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (jobType != null) 'job_type': jobType,
      if (status != null) 'status': status,
      if (sourceId != null) 'source_id': sourceId,
      if (cardId != null) 'card_id': cardId,
      if (spaceId != null) 'space_id': spaceId,
      if (chatSessionId != null) 'chat_session_id': chatSessionId,
      if (priority != null) 'priority': priority,
      if (attemptCount != null) 'attempt_count': attemptCount,
      if (maxAttempts != null) 'max_attempts': maxAttempts,
      if (inputJson != null) 'input_json': inputJson,
      if (outputJson != null) 'output_json': outputJson,
      if (errorMessage != null) 'error_message': errorMessage,
      if (modelSlug != null) 'model_slug': modelSlug,
      if (queuedAt != null) 'queued_at': queuedAt,
      if (startedAt != null) 'started_at': startedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AiProcessingJobsCompanion copyWith({
    Value<String>? id,
    Value<String>? jobType,
    Value<String>? status,
    Value<String?>? sourceId,
    Value<String?>? cardId,
    Value<String?>? spaceId,
    Value<String?>? chatSessionId,
    Value<int>? priority,
    Value<int>? attemptCount,
    Value<int>? maxAttempts,
    Value<String>? inputJson,
    Value<String?>? outputJson,
    Value<String?>? errorMessage,
    Value<String?>? modelSlug,
    Value<int>? queuedAt,
    Value<int?>? startedAt,
    Value<int?>? completedAt,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return AiProcessingJobsCompanion(
      id: id ?? this.id,
      jobType: jobType ?? this.jobType,
      status: status ?? this.status,
      sourceId: sourceId ?? this.sourceId,
      cardId: cardId ?? this.cardId,
      spaceId: spaceId ?? this.spaceId,
      chatSessionId: chatSessionId ?? this.chatSessionId,
      priority: priority ?? this.priority,
      attemptCount: attemptCount ?? this.attemptCount,
      maxAttempts: maxAttempts ?? this.maxAttempts,
      inputJson: inputJson ?? this.inputJson,
      outputJson: outputJson ?? this.outputJson,
      errorMessage: errorMessage ?? this.errorMessage,
      modelSlug: modelSlug ?? this.modelSlug,
      queuedAt: queuedAt ?? this.queuedAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (jobType.present) {
      map['job_type'] = Variable<String>(jobType.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (cardId.present) {
      map['card_id'] = Variable<String>(cardId.value);
    }
    if (spaceId.present) {
      map['space_id'] = Variable<String>(spaceId.value);
    }
    if (chatSessionId.present) {
      map['chat_session_id'] = Variable<String>(chatSessionId.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (attemptCount.present) {
      map['attempt_count'] = Variable<int>(attemptCount.value);
    }
    if (maxAttempts.present) {
      map['max_attempts'] = Variable<int>(maxAttempts.value);
    }
    if (inputJson.present) {
      map['input_json'] = Variable<String>(inputJson.value);
    }
    if (outputJson.present) {
      map['output_json'] = Variable<String>(outputJson.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    if (modelSlug.present) {
      map['model_slug'] = Variable<String>(modelSlug.value);
    }
    if (queuedAt.present) {
      map['queued_at'] = Variable<int>(queuedAt.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<int>(startedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<int>(completedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AiProcessingJobsCompanion(')
          ..write('id: $id, ')
          ..write('jobType: $jobType, ')
          ..write('status: $status, ')
          ..write('sourceId: $sourceId, ')
          ..write('cardId: $cardId, ')
          ..write('spaceId: $spaceId, ')
          ..write('chatSessionId: $chatSessionId, ')
          ..write('priority: $priority, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('maxAttempts: $maxAttempts, ')
          ..write('inputJson: $inputJson, ')
          ..write('outputJson: $outputJson, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('modelSlug: $modelSlug, ')
          ..write('queuedAt: $queuedAt, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AiModelAssetsTable extends AiModelAssets
    with TableInfo<$AiModelAssetsTable, AiModelAsset> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AiModelAssetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _slugMeta = const VerificationMeta('slug');
  @override
  late final GeneratedColumn<String> slug = GeneratedColumn<String>(
    'slug',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _capabilitiesJsonMeta = const VerificationMeta(
    'capabilitiesJson',
  );
  @override
  late final GeneratedColumn<String> capabilitiesJson = GeneratedColumn<String>(
    'capabilities_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _sizeMbMeta = const VerificationMeta('sizeMb');
  @override
  late final GeneratedColumn<double> sizeMb = GeneratedColumn<double>(
    'size_mb',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _quantizationMeta = const VerificationMeta(
    'quantization',
  );
  @override
  late final GeneratedColumn<String> quantization = GeneratedColumn<String>(
    'quantization',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDownloadedMeta = const VerificationMeta(
    'isDownloaded',
  );
  @override
  late final GeneratedColumn<bool> isDownloaded = GeneratedColumn<bool>(
    'is_downloaded',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_downloaded" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isInitializedMeta = const VerificationMeta(
    'isInitialized',
  );
  @override
  late final GeneratedColumn<bool> isInitialized = GeneratedColumn<bool>(
    'is_initialized',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_initialized" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastCheckedAtMeta = const VerificationMeta(
    'lastCheckedAt',
  );
  @override
  late final GeneratedColumn<int> lastCheckedAt = GeneratedColumn<int>(
    'last_checked_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastInitializedAtMeta = const VerificationMeta(
    'lastInitializedAt',
  );
  @override
  late final GeneratedColumn<int> lastInitializedAt = GeneratedColumn<int>(
    'last_initialized_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _failureReasonMeta = const VerificationMeta(
    'failureReason',
  );
  @override
  late final GeneratedColumn<String> failureReason = GeneratedColumn<String>(
    'failure_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _downloadStatusMeta = const VerificationMeta(
    'downloadStatus',
  );
  @override
  late final GeneratedColumn<String> downloadStatus = GeneratedColumn<String>(
    'download_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('not_downloaded'),
  );
  static const VerificationMeta _downloadProgressMeta = const VerificationMeta(
    'downloadProgress',
  );
  @override
  late final GeneratedColumn<double> downloadProgress = GeneratedColumn<double>(
    'download_progress',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _downloadStatusMessageMeta =
      const VerificationMeta('downloadStatusMessage');
  @override
  late final GeneratedColumn<String> downloadStatusMessage =
      GeneratedColumn<String>(
        'download_status_message',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _downloadStartedAtMeta = const VerificationMeta(
    'downloadStartedAt',
  );
  @override
  late final GeneratedColumn<int> downloadStartedAt = GeneratedColumn<int>(
    'download_started_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _downloadCompletedAtMeta =
      const VerificationMeta('downloadCompletedAt');
  @override
  late final GeneratedColumn<int> downloadCompletedAt = GeneratedColumn<int>(
    'download_completed_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    slug,
    displayName,
    capabilitiesJson,
    sizeMb,
    quantization,
    isDownloaded,
    isInitialized,
    localPath,
    lastCheckedAt,
    lastInitializedAt,
    failureReason,
    downloadStatus,
    downloadProgress,
    downloadStatusMessage,
    downloadStartedAt,
    downloadCompletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ai_model_assets';
  @override
  VerificationContext validateIntegrity(
    Insertable<AiModelAsset> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('slug')) {
      context.handle(
        _slugMeta,
        slug.isAcceptableOrUnknown(data['slug']!, _slugMeta),
      );
    } else if (isInserting) {
      context.missing(_slugMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('capabilities_json')) {
      context.handle(
        _capabilitiesJsonMeta,
        capabilitiesJson.isAcceptableOrUnknown(
          data['capabilities_json']!,
          _capabilitiesJsonMeta,
        ),
      );
    }
    if (data.containsKey('size_mb')) {
      context.handle(
        _sizeMbMeta,
        sizeMb.isAcceptableOrUnknown(data['size_mb']!, _sizeMbMeta),
      );
    }
    if (data.containsKey('quantization')) {
      context.handle(
        _quantizationMeta,
        quantization.isAcceptableOrUnknown(
          data['quantization']!,
          _quantizationMeta,
        ),
      );
    }
    if (data.containsKey('is_downloaded')) {
      context.handle(
        _isDownloadedMeta,
        isDownloaded.isAcceptableOrUnknown(
          data['is_downloaded']!,
          _isDownloadedMeta,
        ),
      );
    }
    if (data.containsKey('is_initialized')) {
      context.handle(
        _isInitializedMeta,
        isInitialized.isAcceptableOrUnknown(
          data['is_initialized']!,
          _isInitializedMeta,
        ),
      );
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    }
    if (data.containsKey('last_checked_at')) {
      context.handle(
        _lastCheckedAtMeta,
        lastCheckedAt.isAcceptableOrUnknown(
          data['last_checked_at']!,
          _lastCheckedAtMeta,
        ),
      );
    }
    if (data.containsKey('last_initialized_at')) {
      context.handle(
        _lastInitializedAtMeta,
        lastInitializedAt.isAcceptableOrUnknown(
          data['last_initialized_at']!,
          _lastInitializedAtMeta,
        ),
      );
    }
    if (data.containsKey('failure_reason')) {
      context.handle(
        _failureReasonMeta,
        failureReason.isAcceptableOrUnknown(
          data['failure_reason']!,
          _failureReasonMeta,
        ),
      );
    }
    if (data.containsKey('download_status')) {
      context.handle(
        _downloadStatusMeta,
        downloadStatus.isAcceptableOrUnknown(
          data['download_status']!,
          _downloadStatusMeta,
        ),
      );
    }
    if (data.containsKey('download_progress')) {
      context.handle(
        _downloadProgressMeta,
        downloadProgress.isAcceptableOrUnknown(
          data['download_progress']!,
          _downloadProgressMeta,
        ),
      );
    }
    if (data.containsKey('download_status_message')) {
      context.handle(
        _downloadStatusMessageMeta,
        downloadStatusMessage.isAcceptableOrUnknown(
          data['download_status_message']!,
          _downloadStatusMessageMeta,
        ),
      );
    }
    if (data.containsKey('download_started_at')) {
      context.handle(
        _downloadStartedAtMeta,
        downloadStartedAt.isAcceptableOrUnknown(
          data['download_started_at']!,
          _downloadStartedAtMeta,
        ),
      );
    }
    if (data.containsKey('download_completed_at')) {
      context.handle(
        _downloadCompletedAtMeta,
        downloadCompletedAt.isAcceptableOrUnknown(
          data['download_completed_at']!,
          _downloadCompletedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {slug};
  @override
  AiModelAsset map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AiModelAsset(
      slug: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}slug'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      capabilitiesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}capabilities_json'],
      )!,
      sizeMb: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}size_mb'],
      ),
      quantization: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quantization'],
      ),
      isDownloaded: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_downloaded'],
      )!,
      isInitialized: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_initialized'],
      )!,
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      ),
      lastCheckedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_checked_at'],
      ),
      lastInitializedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_initialized_at'],
      ),
      failureReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}failure_reason'],
      ),
      downloadStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}download_status'],
      )!,
      downloadProgress: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}download_progress'],
      ),
      downloadStatusMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}download_status_message'],
      ),
      downloadStartedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}download_started_at'],
      ),
      downloadCompletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}download_completed_at'],
      ),
    );
  }

  @override
  $AiModelAssetsTable createAlias(String alias) {
    return $AiModelAssetsTable(attachedDatabase, alias);
  }
}

class AiModelAsset extends DataClass implements Insertable<AiModelAsset> {
  final String slug;
  final String displayName;
  final String capabilitiesJson;
  final double? sizeMb;
  final String? quantization;
  final bool isDownloaded;
  final bool isInitialized;
  final String? localPath;
  final int? lastCheckedAt;
  final int? lastInitializedAt;
  final String? failureReason;
  final String downloadStatus;
  final double? downloadProgress;
  final String? downloadStatusMessage;
  final int? downloadStartedAt;
  final int? downloadCompletedAt;
  const AiModelAsset({
    required this.slug,
    required this.displayName,
    required this.capabilitiesJson,
    this.sizeMb,
    this.quantization,
    required this.isDownloaded,
    required this.isInitialized,
    this.localPath,
    this.lastCheckedAt,
    this.lastInitializedAt,
    this.failureReason,
    required this.downloadStatus,
    this.downloadProgress,
    this.downloadStatusMessage,
    this.downloadStartedAt,
    this.downloadCompletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['slug'] = Variable<String>(slug);
    map['display_name'] = Variable<String>(displayName);
    map['capabilities_json'] = Variable<String>(capabilitiesJson);
    if (!nullToAbsent || sizeMb != null) {
      map['size_mb'] = Variable<double>(sizeMb);
    }
    if (!nullToAbsent || quantization != null) {
      map['quantization'] = Variable<String>(quantization);
    }
    map['is_downloaded'] = Variable<bool>(isDownloaded);
    map['is_initialized'] = Variable<bool>(isInitialized);
    if (!nullToAbsent || localPath != null) {
      map['local_path'] = Variable<String>(localPath);
    }
    if (!nullToAbsent || lastCheckedAt != null) {
      map['last_checked_at'] = Variable<int>(lastCheckedAt);
    }
    if (!nullToAbsent || lastInitializedAt != null) {
      map['last_initialized_at'] = Variable<int>(lastInitializedAt);
    }
    if (!nullToAbsent || failureReason != null) {
      map['failure_reason'] = Variable<String>(failureReason);
    }
    map['download_status'] = Variable<String>(downloadStatus);
    if (!nullToAbsent || downloadProgress != null) {
      map['download_progress'] = Variable<double>(downloadProgress);
    }
    if (!nullToAbsent || downloadStatusMessage != null) {
      map['download_status_message'] = Variable<String>(downloadStatusMessage);
    }
    if (!nullToAbsent || downloadStartedAt != null) {
      map['download_started_at'] = Variable<int>(downloadStartedAt);
    }
    if (!nullToAbsent || downloadCompletedAt != null) {
      map['download_completed_at'] = Variable<int>(downloadCompletedAt);
    }
    return map;
  }

  AiModelAssetsCompanion toCompanion(bool nullToAbsent) {
    return AiModelAssetsCompanion(
      slug: Value(slug),
      displayName: Value(displayName),
      capabilitiesJson: Value(capabilitiesJson),
      sizeMb: sizeMb == null && nullToAbsent
          ? const Value.absent()
          : Value(sizeMb),
      quantization: quantization == null && nullToAbsent
          ? const Value.absent()
          : Value(quantization),
      isDownloaded: Value(isDownloaded),
      isInitialized: Value(isInitialized),
      localPath: localPath == null && nullToAbsent
          ? const Value.absent()
          : Value(localPath),
      lastCheckedAt: lastCheckedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastCheckedAt),
      lastInitializedAt: lastInitializedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastInitializedAt),
      failureReason: failureReason == null && nullToAbsent
          ? const Value.absent()
          : Value(failureReason),
      downloadStatus: Value(downloadStatus),
      downloadProgress: downloadProgress == null && nullToAbsent
          ? const Value.absent()
          : Value(downloadProgress),
      downloadStatusMessage: downloadStatusMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(downloadStatusMessage),
      downloadStartedAt: downloadStartedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(downloadStartedAt),
      downloadCompletedAt: downloadCompletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(downloadCompletedAt),
    );
  }

  factory AiModelAsset.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AiModelAsset(
      slug: serializer.fromJson<String>(json['slug']),
      displayName: serializer.fromJson<String>(json['displayName']),
      capabilitiesJson: serializer.fromJson<String>(json['capabilitiesJson']),
      sizeMb: serializer.fromJson<double?>(json['sizeMb']),
      quantization: serializer.fromJson<String?>(json['quantization']),
      isDownloaded: serializer.fromJson<bool>(json['isDownloaded']),
      isInitialized: serializer.fromJson<bool>(json['isInitialized']),
      localPath: serializer.fromJson<String?>(json['localPath']),
      lastCheckedAt: serializer.fromJson<int?>(json['lastCheckedAt']),
      lastInitializedAt: serializer.fromJson<int?>(json['lastInitializedAt']),
      failureReason: serializer.fromJson<String?>(json['failureReason']),
      downloadStatus: serializer.fromJson<String>(json['downloadStatus']),
      downloadProgress: serializer.fromJson<double?>(json['downloadProgress']),
      downloadStatusMessage: serializer.fromJson<String?>(
        json['downloadStatusMessage'],
      ),
      downloadStartedAt: serializer.fromJson<int?>(json['downloadStartedAt']),
      downloadCompletedAt: serializer.fromJson<int?>(
        json['downloadCompletedAt'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'slug': serializer.toJson<String>(slug),
      'displayName': serializer.toJson<String>(displayName),
      'capabilitiesJson': serializer.toJson<String>(capabilitiesJson),
      'sizeMb': serializer.toJson<double?>(sizeMb),
      'quantization': serializer.toJson<String?>(quantization),
      'isDownloaded': serializer.toJson<bool>(isDownloaded),
      'isInitialized': serializer.toJson<bool>(isInitialized),
      'localPath': serializer.toJson<String?>(localPath),
      'lastCheckedAt': serializer.toJson<int?>(lastCheckedAt),
      'lastInitializedAt': serializer.toJson<int?>(lastInitializedAt),
      'failureReason': serializer.toJson<String?>(failureReason),
      'downloadStatus': serializer.toJson<String>(downloadStatus),
      'downloadProgress': serializer.toJson<double?>(downloadProgress),
      'downloadStatusMessage': serializer.toJson<String?>(
        downloadStatusMessage,
      ),
      'downloadStartedAt': serializer.toJson<int?>(downloadStartedAt),
      'downloadCompletedAt': serializer.toJson<int?>(downloadCompletedAt),
    };
  }

  AiModelAsset copyWith({
    String? slug,
    String? displayName,
    String? capabilitiesJson,
    Value<double?> sizeMb = const Value.absent(),
    Value<String?> quantization = const Value.absent(),
    bool? isDownloaded,
    bool? isInitialized,
    Value<String?> localPath = const Value.absent(),
    Value<int?> lastCheckedAt = const Value.absent(),
    Value<int?> lastInitializedAt = const Value.absent(),
    Value<String?> failureReason = const Value.absent(),
    String? downloadStatus,
    Value<double?> downloadProgress = const Value.absent(),
    Value<String?> downloadStatusMessage = const Value.absent(),
    Value<int?> downloadStartedAt = const Value.absent(),
    Value<int?> downloadCompletedAt = const Value.absent(),
  }) => AiModelAsset(
    slug: slug ?? this.slug,
    displayName: displayName ?? this.displayName,
    capabilitiesJson: capabilitiesJson ?? this.capabilitiesJson,
    sizeMb: sizeMb.present ? sizeMb.value : this.sizeMb,
    quantization: quantization.present ? quantization.value : this.quantization,
    isDownloaded: isDownloaded ?? this.isDownloaded,
    isInitialized: isInitialized ?? this.isInitialized,
    localPath: localPath.present ? localPath.value : this.localPath,
    lastCheckedAt: lastCheckedAt.present
        ? lastCheckedAt.value
        : this.lastCheckedAt,
    lastInitializedAt: lastInitializedAt.present
        ? lastInitializedAt.value
        : this.lastInitializedAt,
    failureReason: failureReason.present
        ? failureReason.value
        : this.failureReason,
    downloadStatus: downloadStatus ?? this.downloadStatus,
    downloadProgress: downloadProgress.present
        ? downloadProgress.value
        : this.downloadProgress,
    downloadStatusMessage: downloadStatusMessage.present
        ? downloadStatusMessage.value
        : this.downloadStatusMessage,
    downloadStartedAt: downloadStartedAt.present
        ? downloadStartedAt.value
        : this.downloadStartedAt,
    downloadCompletedAt: downloadCompletedAt.present
        ? downloadCompletedAt.value
        : this.downloadCompletedAt,
  );
  AiModelAsset copyWithCompanion(AiModelAssetsCompanion data) {
    return AiModelAsset(
      slug: data.slug.present ? data.slug.value : this.slug,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      capabilitiesJson: data.capabilitiesJson.present
          ? data.capabilitiesJson.value
          : this.capabilitiesJson,
      sizeMb: data.sizeMb.present ? data.sizeMb.value : this.sizeMb,
      quantization: data.quantization.present
          ? data.quantization.value
          : this.quantization,
      isDownloaded: data.isDownloaded.present
          ? data.isDownloaded.value
          : this.isDownloaded,
      isInitialized: data.isInitialized.present
          ? data.isInitialized.value
          : this.isInitialized,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      lastCheckedAt: data.lastCheckedAt.present
          ? data.lastCheckedAt.value
          : this.lastCheckedAt,
      lastInitializedAt: data.lastInitializedAt.present
          ? data.lastInitializedAt.value
          : this.lastInitializedAt,
      failureReason: data.failureReason.present
          ? data.failureReason.value
          : this.failureReason,
      downloadStatus: data.downloadStatus.present
          ? data.downloadStatus.value
          : this.downloadStatus,
      downloadProgress: data.downloadProgress.present
          ? data.downloadProgress.value
          : this.downloadProgress,
      downloadStatusMessage: data.downloadStatusMessage.present
          ? data.downloadStatusMessage.value
          : this.downloadStatusMessage,
      downloadStartedAt: data.downloadStartedAt.present
          ? data.downloadStartedAt.value
          : this.downloadStartedAt,
      downloadCompletedAt: data.downloadCompletedAt.present
          ? data.downloadCompletedAt.value
          : this.downloadCompletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AiModelAsset(')
          ..write('slug: $slug, ')
          ..write('displayName: $displayName, ')
          ..write('capabilitiesJson: $capabilitiesJson, ')
          ..write('sizeMb: $sizeMb, ')
          ..write('quantization: $quantization, ')
          ..write('isDownloaded: $isDownloaded, ')
          ..write('isInitialized: $isInitialized, ')
          ..write('localPath: $localPath, ')
          ..write('lastCheckedAt: $lastCheckedAt, ')
          ..write('lastInitializedAt: $lastInitializedAt, ')
          ..write('failureReason: $failureReason, ')
          ..write('downloadStatus: $downloadStatus, ')
          ..write('downloadProgress: $downloadProgress, ')
          ..write('downloadStatusMessage: $downloadStatusMessage, ')
          ..write('downloadStartedAt: $downloadStartedAt, ')
          ..write('downloadCompletedAt: $downloadCompletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    slug,
    displayName,
    capabilitiesJson,
    sizeMb,
    quantization,
    isDownloaded,
    isInitialized,
    localPath,
    lastCheckedAt,
    lastInitializedAt,
    failureReason,
    downloadStatus,
    downloadProgress,
    downloadStatusMessage,
    downloadStartedAt,
    downloadCompletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AiModelAsset &&
          other.slug == this.slug &&
          other.displayName == this.displayName &&
          other.capabilitiesJson == this.capabilitiesJson &&
          other.sizeMb == this.sizeMb &&
          other.quantization == this.quantization &&
          other.isDownloaded == this.isDownloaded &&
          other.isInitialized == this.isInitialized &&
          other.localPath == this.localPath &&
          other.lastCheckedAt == this.lastCheckedAt &&
          other.lastInitializedAt == this.lastInitializedAt &&
          other.failureReason == this.failureReason &&
          other.downloadStatus == this.downloadStatus &&
          other.downloadProgress == this.downloadProgress &&
          other.downloadStatusMessage == this.downloadStatusMessage &&
          other.downloadStartedAt == this.downloadStartedAt &&
          other.downloadCompletedAt == this.downloadCompletedAt);
}

class AiModelAssetsCompanion extends UpdateCompanion<AiModelAsset> {
  final Value<String> slug;
  final Value<String> displayName;
  final Value<String> capabilitiesJson;
  final Value<double?> sizeMb;
  final Value<String?> quantization;
  final Value<bool> isDownloaded;
  final Value<bool> isInitialized;
  final Value<String?> localPath;
  final Value<int?> lastCheckedAt;
  final Value<int?> lastInitializedAt;
  final Value<String?> failureReason;
  final Value<String> downloadStatus;
  final Value<double?> downloadProgress;
  final Value<String?> downloadStatusMessage;
  final Value<int?> downloadStartedAt;
  final Value<int?> downloadCompletedAt;
  final Value<int> rowid;
  const AiModelAssetsCompanion({
    this.slug = const Value.absent(),
    this.displayName = const Value.absent(),
    this.capabilitiesJson = const Value.absent(),
    this.sizeMb = const Value.absent(),
    this.quantization = const Value.absent(),
    this.isDownloaded = const Value.absent(),
    this.isInitialized = const Value.absent(),
    this.localPath = const Value.absent(),
    this.lastCheckedAt = const Value.absent(),
    this.lastInitializedAt = const Value.absent(),
    this.failureReason = const Value.absent(),
    this.downloadStatus = const Value.absent(),
    this.downloadProgress = const Value.absent(),
    this.downloadStatusMessage = const Value.absent(),
    this.downloadStartedAt = const Value.absent(),
    this.downloadCompletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AiModelAssetsCompanion.insert({
    required String slug,
    required String displayName,
    this.capabilitiesJson = const Value.absent(),
    this.sizeMb = const Value.absent(),
    this.quantization = const Value.absent(),
    this.isDownloaded = const Value.absent(),
    this.isInitialized = const Value.absent(),
    this.localPath = const Value.absent(),
    this.lastCheckedAt = const Value.absent(),
    this.lastInitializedAt = const Value.absent(),
    this.failureReason = const Value.absent(),
    this.downloadStatus = const Value.absent(),
    this.downloadProgress = const Value.absent(),
    this.downloadStatusMessage = const Value.absent(),
    this.downloadStartedAt = const Value.absent(),
    this.downloadCompletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : slug = Value(slug),
       displayName = Value(displayName);
  static Insertable<AiModelAsset> custom({
    Expression<String>? slug,
    Expression<String>? displayName,
    Expression<String>? capabilitiesJson,
    Expression<double>? sizeMb,
    Expression<String>? quantization,
    Expression<bool>? isDownloaded,
    Expression<bool>? isInitialized,
    Expression<String>? localPath,
    Expression<int>? lastCheckedAt,
    Expression<int>? lastInitializedAt,
    Expression<String>? failureReason,
    Expression<String>? downloadStatus,
    Expression<double>? downloadProgress,
    Expression<String>? downloadStatusMessage,
    Expression<int>? downloadStartedAt,
    Expression<int>? downloadCompletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (slug != null) 'slug': slug,
      if (displayName != null) 'display_name': displayName,
      if (capabilitiesJson != null) 'capabilities_json': capabilitiesJson,
      if (sizeMb != null) 'size_mb': sizeMb,
      if (quantization != null) 'quantization': quantization,
      if (isDownloaded != null) 'is_downloaded': isDownloaded,
      if (isInitialized != null) 'is_initialized': isInitialized,
      if (localPath != null) 'local_path': localPath,
      if (lastCheckedAt != null) 'last_checked_at': lastCheckedAt,
      if (lastInitializedAt != null) 'last_initialized_at': lastInitializedAt,
      if (failureReason != null) 'failure_reason': failureReason,
      if (downloadStatus != null) 'download_status': downloadStatus,
      if (downloadProgress != null) 'download_progress': downloadProgress,
      if (downloadStatusMessage != null)
        'download_status_message': downloadStatusMessage,
      if (downloadStartedAt != null) 'download_started_at': downloadStartedAt,
      if (downloadCompletedAt != null)
        'download_completed_at': downloadCompletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AiModelAssetsCompanion copyWith({
    Value<String>? slug,
    Value<String>? displayName,
    Value<String>? capabilitiesJson,
    Value<double?>? sizeMb,
    Value<String?>? quantization,
    Value<bool>? isDownloaded,
    Value<bool>? isInitialized,
    Value<String?>? localPath,
    Value<int?>? lastCheckedAt,
    Value<int?>? lastInitializedAt,
    Value<String?>? failureReason,
    Value<String>? downloadStatus,
    Value<double?>? downloadProgress,
    Value<String?>? downloadStatusMessage,
    Value<int?>? downloadStartedAt,
    Value<int?>? downloadCompletedAt,
    Value<int>? rowid,
  }) {
    return AiModelAssetsCompanion(
      slug: slug ?? this.slug,
      displayName: displayName ?? this.displayName,
      capabilitiesJson: capabilitiesJson ?? this.capabilitiesJson,
      sizeMb: sizeMb ?? this.sizeMb,
      quantization: quantization ?? this.quantization,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      isInitialized: isInitialized ?? this.isInitialized,
      localPath: localPath ?? this.localPath,
      lastCheckedAt: lastCheckedAt ?? this.lastCheckedAt,
      lastInitializedAt: lastInitializedAt ?? this.lastInitializedAt,
      failureReason: failureReason ?? this.failureReason,
      downloadStatus: downloadStatus ?? this.downloadStatus,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      downloadStatusMessage:
          downloadStatusMessage ?? this.downloadStatusMessage,
      downloadStartedAt: downloadStartedAt ?? this.downloadStartedAt,
      downloadCompletedAt: downloadCompletedAt ?? this.downloadCompletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (slug.present) {
      map['slug'] = Variable<String>(slug.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (capabilitiesJson.present) {
      map['capabilities_json'] = Variable<String>(capabilitiesJson.value);
    }
    if (sizeMb.present) {
      map['size_mb'] = Variable<double>(sizeMb.value);
    }
    if (quantization.present) {
      map['quantization'] = Variable<String>(quantization.value);
    }
    if (isDownloaded.present) {
      map['is_downloaded'] = Variable<bool>(isDownloaded.value);
    }
    if (isInitialized.present) {
      map['is_initialized'] = Variable<bool>(isInitialized.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (lastCheckedAt.present) {
      map['last_checked_at'] = Variable<int>(lastCheckedAt.value);
    }
    if (lastInitializedAt.present) {
      map['last_initialized_at'] = Variable<int>(lastInitializedAt.value);
    }
    if (failureReason.present) {
      map['failure_reason'] = Variable<String>(failureReason.value);
    }
    if (downloadStatus.present) {
      map['download_status'] = Variable<String>(downloadStatus.value);
    }
    if (downloadProgress.present) {
      map['download_progress'] = Variable<double>(downloadProgress.value);
    }
    if (downloadStatusMessage.present) {
      map['download_status_message'] = Variable<String>(
        downloadStatusMessage.value,
      );
    }
    if (downloadStartedAt.present) {
      map['download_started_at'] = Variable<int>(downloadStartedAt.value);
    }
    if (downloadCompletedAt.present) {
      map['download_completed_at'] = Variable<int>(downloadCompletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AiModelAssetsCompanion(')
          ..write('slug: $slug, ')
          ..write('displayName: $displayName, ')
          ..write('capabilitiesJson: $capabilitiesJson, ')
          ..write('sizeMb: $sizeMb, ')
          ..write('quantization: $quantization, ')
          ..write('isDownloaded: $isDownloaded, ')
          ..write('isInitialized: $isInitialized, ')
          ..write('localPath: $localPath, ')
          ..write('lastCheckedAt: $lastCheckedAt, ')
          ..write('lastInitializedAt: $lastInitializedAt, ')
          ..write('failureReason: $failureReason, ')
          ..write('downloadStatus: $downloadStatus, ')
          ..write('downloadProgress: $downloadProgress, ')
          ..write('downloadStatusMessage: $downloadStatusMessage, ')
          ..write('downloadStartedAt: $downloadStartedAt, ')
          ..write('downloadCompletedAt: $downloadCompletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RagIndexRecordsTable extends RagIndexRecords
    with TableInfo<$RagIndexRecordsTable, RagIndexRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RagIndexRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _indexNameMeta = const VerificationMeta(
    'indexName',
  );
  @override
  late final GeneratedColumn<String> indexName = GeneratedColumn<String>(
    'index_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _externalIdMeta = const VerificationMeta(
    'externalId',
  );
  @override
  late final GeneratedColumn<String> externalId = GeneratedColumn<String>(
    'external_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceChunkIdMeta = const VerificationMeta(
    'sourceChunkId',
  );
  @override
  late final GeneratedColumn<String> sourceChunkId = GeneratedColumn<String>(
    'source_chunk_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES source_text_chunks (id)',
    ),
  );
  static const VerificationMeta _embeddingModelSlugMeta =
      const VerificationMeta('embeddingModelSlug');
  @override
  late final GeneratedColumn<String> embeddingModelSlug =
      GeneratedColumn<String>(
        'embedding_model_slug',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _embeddingDimensionMeta =
      const VerificationMeta('embeddingDimension');
  @override
  late final GeneratedColumn<int> embeddingDimension = GeneratedColumn<int>(
    'embedding_dimension',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _documentTextHashMeta = const VerificationMeta(
    'documentTextHash',
  );
  @override
  late final GeneratedColumn<String> documentTextHash = GeneratedColumn<String>(
    'document_text_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    indexName,
    externalId,
    sourceChunkId,
    embeddingModelSlug,
    embeddingDimension,
    documentTextHash,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rag_index_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<RagIndexRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('index_name')) {
      context.handle(
        _indexNameMeta,
        indexName.isAcceptableOrUnknown(data['index_name']!, _indexNameMeta),
      );
    } else if (isInserting) {
      context.missing(_indexNameMeta);
    }
    if (data.containsKey('external_id')) {
      context.handle(
        _externalIdMeta,
        externalId.isAcceptableOrUnknown(data['external_id']!, _externalIdMeta),
      );
    } else if (isInserting) {
      context.missing(_externalIdMeta);
    }
    if (data.containsKey('source_chunk_id')) {
      context.handle(
        _sourceChunkIdMeta,
        sourceChunkId.isAcceptableOrUnknown(
          data['source_chunk_id']!,
          _sourceChunkIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceChunkIdMeta);
    }
    if (data.containsKey('embedding_model_slug')) {
      context.handle(
        _embeddingModelSlugMeta,
        embeddingModelSlug.isAcceptableOrUnknown(
          data['embedding_model_slug']!,
          _embeddingModelSlugMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_embeddingModelSlugMeta);
    }
    if (data.containsKey('embedding_dimension')) {
      context.handle(
        _embeddingDimensionMeta,
        embeddingDimension.isAcceptableOrUnknown(
          data['embedding_dimension']!,
          _embeddingDimensionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_embeddingDimensionMeta);
    }
    if (data.containsKey('document_text_hash')) {
      context.handle(
        _documentTextHashMeta,
        documentTextHash.isAcceptableOrUnknown(
          data['document_text_hash']!,
          _documentTextHashMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_documentTextHashMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RagIndexRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RagIndexRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      indexName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}index_name'],
      )!,
      externalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}external_id'],
      )!,
      sourceChunkId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_chunk_id'],
      )!,
      embeddingModelSlug: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}embedding_model_slug'],
      )!,
      embeddingDimension: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}embedding_dimension'],
      )!,
      documentTextHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}document_text_hash'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $RagIndexRecordsTable createAlias(String alias) {
    return $RagIndexRecordsTable(attachedDatabase, alias);
  }
}

class RagIndexRecord extends DataClass implements Insertable<RagIndexRecord> {
  final String id;
  final String indexName;
  final String externalId;
  final String sourceChunkId;
  final String embeddingModelSlug;
  final int embeddingDimension;
  final String documentTextHash;
  final int createdAt;
  final int updatedAt;
  const RagIndexRecord({
    required this.id,
    required this.indexName,
    required this.externalId,
    required this.sourceChunkId,
    required this.embeddingModelSlug,
    required this.embeddingDimension,
    required this.documentTextHash,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['index_name'] = Variable<String>(indexName);
    map['external_id'] = Variable<String>(externalId);
    map['source_chunk_id'] = Variable<String>(sourceChunkId);
    map['embedding_model_slug'] = Variable<String>(embeddingModelSlug);
    map['embedding_dimension'] = Variable<int>(embeddingDimension);
    map['document_text_hash'] = Variable<String>(documentTextHash);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  RagIndexRecordsCompanion toCompanion(bool nullToAbsent) {
    return RagIndexRecordsCompanion(
      id: Value(id),
      indexName: Value(indexName),
      externalId: Value(externalId),
      sourceChunkId: Value(sourceChunkId),
      embeddingModelSlug: Value(embeddingModelSlug),
      embeddingDimension: Value(embeddingDimension),
      documentTextHash: Value(documentTextHash),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory RagIndexRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RagIndexRecord(
      id: serializer.fromJson<String>(json['id']),
      indexName: serializer.fromJson<String>(json['indexName']),
      externalId: serializer.fromJson<String>(json['externalId']),
      sourceChunkId: serializer.fromJson<String>(json['sourceChunkId']),
      embeddingModelSlug: serializer.fromJson<String>(
        json['embeddingModelSlug'],
      ),
      embeddingDimension: serializer.fromJson<int>(json['embeddingDimension']),
      documentTextHash: serializer.fromJson<String>(json['documentTextHash']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'indexName': serializer.toJson<String>(indexName),
      'externalId': serializer.toJson<String>(externalId),
      'sourceChunkId': serializer.toJson<String>(sourceChunkId),
      'embeddingModelSlug': serializer.toJson<String>(embeddingModelSlug),
      'embeddingDimension': serializer.toJson<int>(embeddingDimension),
      'documentTextHash': serializer.toJson<String>(documentTextHash),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  RagIndexRecord copyWith({
    String? id,
    String? indexName,
    String? externalId,
    String? sourceChunkId,
    String? embeddingModelSlug,
    int? embeddingDimension,
    String? documentTextHash,
    int? createdAt,
    int? updatedAt,
  }) => RagIndexRecord(
    id: id ?? this.id,
    indexName: indexName ?? this.indexName,
    externalId: externalId ?? this.externalId,
    sourceChunkId: sourceChunkId ?? this.sourceChunkId,
    embeddingModelSlug: embeddingModelSlug ?? this.embeddingModelSlug,
    embeddingDimension: embeddingDimension ?? this.embeddingDimension,
    documentTextHash: documentTextHash ?? this.documentTextHash,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  RagIndexRecord copyWithCompanion(RagIndexRecordsCompanion data) {
    return RagIndexRecord(
      id: data.id.present ? data.id.value : this.id,
      indexName: data.indexName.present ? data.indexName.value : this.indexName,
      externalId: data.externalId.present
          ? data.externalId.value
          : this.externalId,
      sourceChunkId: data.sourceChunkId.present
          ? data.sourceChunkId.value
          : this.sourceChunkId,
      embeddingModelSlug: data.embeddingModelSlug.present
          ? data.embeddingModelSlug.value
          : this.embeddingModelSlug,
      embeddingDimension: data.embeddingDimension.present
          ? data.embeddingDimension.value
          : this.embeddingDimension,
      documentTextHash: data.documentTextHash.present
          ? data.documentTextHash.value
          : this.documentTextHash,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RagIndexRecord(')
          ..write('id: $id, ')
          ..write('indexName: $indexName, ')
          ..write('externalId: $externalId, ')
          ..write('sourceChunkId: $sourceChunkId, ')
          ..write('embeddingModelSlug: $embeddingModelSlug, ')
          ..write('embeddingDimension: $embeddingDimension, ')
          ..write('documentTextHash: $documentTextHash, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    indexName,
    externalId,
    sourceChunkId,
    embeddingModelSlug,
    embeddingDimension,
    documentTextHash,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RagIndexRecord &&
          other.id == this.id &&
          other.indexName == this.indexName &&
          other.externalId == this.externalId &&
          other.sourceChunkId == this.sourceChunkId &&
          other.embeddingModelSlug == this.embeddingModelSlug &&
          other.embeddingDimension == this.embeddingDimension &&
          other.documentTextHash == this.documentTextHash &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class RagIndexRecordsCompanion extends UpdateCompanion<RagIndexRecord> {
  final Value<String> id;
  final Value<String> indexName;
  final Value<String> externalId;
  final Value<String> sourceChunkId;
  final Value<String> embeddingModelSlug;
  final Value<int> embeddingDimension;
  final Value<String> documentTextHash;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const RagIndexRecordsCompanion({
    this.id = const Value.absent(),
    this.indexName = const Value.absent(),
    this.externalId = const Value.absent(),
    this.sourceChunkId = const Value.absent(),
    this.embeddingModelSlug = const Value.absent(),
    this.embeddingDimension = const Value.absent(),
    this.documentTextHash = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RagIndexRecordsCompanion.insert({
    required String id,
    required String indexName,
    required String externalId,
    required String sourceChunkId,
    required String embeddingModelSlug,
    required int embeddingDimension,
    required String documentTextHash,
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       indexName = Value(indexName),
       externalId = Value(externalId),
       sourceChunkId = Value(sourceChunkId),
       embeddingModelSlug = Value(embeddingModelSlug),
       embeddingDimension = Value(embeddingDimension),
       documentTextHash = Value(documentTextHash),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<RagIndexRecord> custom({
    Expression<String>? id,
    Expression<String>? indexName,
    Expression<String>? externalId,
    Expression<String>? sourceChunkId,
    Expression<String>? embeddingModelSlug,
    Expression<int>? embeddingDimension,
    Expression<String>? documentTextHash,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (indexName != null) 'index_name': indexName,
      if (externalId != null) 'external_id': externalId,
      if (sourceChunkId != null) 'source_chunk_id': sourceChunkId,
      if (embeddingModelSlug != null)
        'embedding_model_slug': embeddingModelSlug,
      if (embeddingDimension != null) 'embedding_dimension': embeddingDimension,
      if (documentTextHash != null) 'document_text_hash': documentTextHash,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RagIndexRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? indexName,
    Value<String>? externalId,
    Value<String>? sourceChunkId,
    Value<String>? embeddingModelSlug,
    Value<int>? embeddingDimension,
    Value<String>? documentTextHash,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return RagIndexRecordsCompanion(
      id: id ?? this.id,
      indexName: indexName ?? this.indexName,
      externalId: externalId ?? this.externalId,
      sourceChunkId: sourceChunkId ?? this.sourceChunkId,
      embeddingModelSlug: embeddingModelSlug ?? this.embeddingModelSlug,
      embeddingDimension: embeddingDimension ?? this.embeddingDimension,
      documentTextHash: documentTextHash ?? this.documentTextHash,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (indexName.present) {
      map['index_name'] = Variable<String>(indexName.value);
    }
    if (externalId.present) {
      map['external_id'] = Variable<String>(externalId.value);
    }
    if (sourceChunkId.present) {
      map['source_chunk_id'] = Variable<String>(sourceChunkId.value);
    }
    if (embeddingModelSlug.present) {
      map['embedding_model_slug'] = Variable<String>(embeddingModelSlug.value);
    }
    if (embeddingDimension.present) {
      map['embedding_dimension'] = Variable<int>(embeddingDimension.value);
    }
    if (documentTextHash.present) {
      map['document_text_hash'] = Variable<String>(documentTextHash.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RagIndexRecordsCompanion(')
          ..write('id: $id, ')
          ..write('indexName: $indexName, ')
          ..write('externalId: $externalId, ')
          ..write('sourceChunkId: $sourceChunkId, ')
          ..write('embeddingModelSlug: $embeddingModelSlug, ')
          ..write('embeddingDimension: $embeddingDimension, ')
          ..write('documentTextHash: $documentTextHash, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$TagDatabase extends GeneratedDatabase {
  _$TagDatabase(QueryExecutor e) : super(e);
  $TagDatabaseManager get managers => $TagDatabaseManager(this);
  late final $UserProfilesTable userProfiles = $UserProfilesTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $SourceItemsTable sourceItems = $SourceItemsTable(this);
  late final $SourceTextChunksTable sourceTextChunks = $SourceTextChunksTable(
    this,
  );
  late final $SpacesTable spaces = $SpacesTable(this);
  late final $TagCardsTable tagCards = $TagCardsTable(this);
  late final $CardSourcesTable cardSources = $CardSourcesTable(this);
  late final $GoalPlansTable goalPlans = $GoalPlansTable(this);
  late final $GoalPlanCardsTable goalPlanCards = $GoalPlanCardsTable(this);
  late final $ChatSessionsTable chatSessions = $ChatSessionsTable(this);
  late final $ChatMessagesTable chatMessages = $ChatMessagesTable(this);
  late final $FeedbackEventsTable feedbackEvents = $FeedbackEventsTable(this);
  late final $PreferenceMemoryTable preferenceMemory = $PreferenceMemoryTable(
    this,
  );
  late final $NotificationRequestsTable notificationRequests =
      $NotificationRequestsTable(this);
  late final $AiProcessingJobsTable aiProcessingJobs = $AiProcessingJobsTable(
    this,
  );
  late final $AiModelAssetsTable aiModelAssets = $AiModelAssetsTable(this);
  late final $RagIndexRecordsTable ragIndexRecords = $RagIndexRecordsTable(
    this,
  );
  late final Index idxSourceItemsCreatedAt = Index(
    'idx_source_items_created_at',
    'CREATE INDEX idx_source_items_created_at ON source_items (created_at)',
  );
  late final Index idxSourceItemsType = Index(
    'idx_source_items_type',
    'CREATE INDEX idx_source_items_type ON source_items (type)',
  );
  late final Index idxSourceItemsProcessingState = Index(
    'idx_source_items_processing_state',
    'CREATE INDEX idx_source_items_processing_state ON source_items (processing_state)',
  );
  late final Index idxSourceItemsContentType = Index(
    'idx_source_items_content_type',
    'CREATE INDEX idx_source_items_content_type ON source_items (content_type)',
  );
  late final Index idxSourceTextChunksSourceId = Index(
    'idx_source_text_chunks_source_id',
    'CREATE INDEX idx_source_text_chunks_source_id ON source_text_chunks (source_id)',
  );
  late final Index idxSourceTextChunksSourceChunk = Index(
    'idx_source_text_chunks_source_chunk',
    'CREATE UNIQUE INDEX idx_source_text_chunks_source_chunk ON source_text_chunks (source_id, chunk_index)',
  );
  late final Index idxSourceTextChunksVectorExternalId = Index(
    'idx_source_text_chunks_vector_external_id',
    'CREATE INDEX idx_source_text_chunks_vector_external_id ON source_text_chunks (vector_external_id)',
  );
  late final Index idxSpacesType = Index(
    'idx_spaces_type',
    'CREATE INDEX idx_spaces_type ON spaces (type)',
  );
  late final Index idxSpacesUpdatedAt = Index(
    'idx_spaces_updated_at',
    'CREATE INDEX idx_spaces_updated_at ON spaces (updated_at)',
  );
  late final Index idxSpacesNormalizedName = Index(
    'idx_spaces_normalized_name',
    'CREATE INDEX idx_spaces_normalized_name ON spaces (normalized_name)',
  );
  late final Index idxTagCardsStatus = Index(
    'idx_tag_cards_status',
    'CREATE INDEX idx_tag_cards_status ON tag_cards (status)',
  );
  late final Index idxTagCardsCardType = Index(
    'idx_tag_cards_card_type',
    'CREATE INDEX idx_tag_cards_card_type ON tag_cards (card_type)',
  );
  late final Index idxTagCardsSpaceId = Index(
    'idx_tag_cards_space_id',
    'CREATE INDEX idx_tag_cards_space_id ON tag_cards (space_id)',
  );
  late final Index idxTagCardsNextActiveDeadline = Index(
    'idx_tag_cards_next_active_deadline',
    'CREATE INDEX idx_tag_cards_next_active_deadline ON tag_cards (next_active_deadline)',
  );
  late final Index idxTagCardsStatusDeadline = Index(
    'idx_tag_cards_status_deadline',
    'CREATE INDEX idx_tag_cards_status_deadline ON tag_cards (status, next_active_deadline)',
  );
  late final Index idxTagCardsTypeStatusDeadline = Index(
    'idx_tag_cards_type_status_deadline',
    'CREATE INDEX idx_tag_cards_type_status_deadline ON tag_cards (card_type, status, next_active_deadline)',
  );
  late final Index idxCardSourcesCardId = Index(
    'idx_card_sources_card_id',
    'CREATE INDEX idx_card_sources_card_id ON card_sources (card_id)',
  );
  late final Index idxCardSourcesSourceId = Index(
    'idx_card_sources_source_id',
    'CREATE INDEX idx_card_sources_source_id ON card_sources (source_id)',
  );
  late final Index idxGoalPlansSpaceId = Index(
    'idx_goal_plans_space_id',
    'CREATE INDEX idx_goal_plans_space_id ON goal_plans (space_id)',
  );
  late final Index idxGoalPlansStatus = Index(
    'idx_goal_plans_status',
    'CREATE INDEX idx_goal_plans_status ON goal_plans (status)',
  );
  late final Index idxGoalPlanCardsGoalPlanId = Index(
    'idx_goal_plan_cards_goal_plan_id',
    'CREATE INDEX idx_goal_plan_cards_goal_plan_id ON goal_plan_cards (goal_plan_id)',
  );
  late final Index idxGoalPlanCardsSequence = Index(
    'idx_goal_plan_cards_sequence',
    'CREATE UNIQUE INDEX idx_goal_plan_cards_sequence ON goal_plan_cards (goal_plan_id, sequence_index)',
  );
  late final Index idxChatSessionsPurpose = Index(
    'idx_chat_sessions_purpose',
    'CREATE INDEX idx_chat_sessions_purpose ON chat_sessions (purpose)',
  );
  late final Index idxChatSessionsLinkedCardId = Index(
    'idx_chat_sessions_linked_card_id',
    'CREATE INDEX idx_chat_sessions_linked_card_id ON chat_sessions (linked_card_id)',
  );
  late final Index idxChatSessionsUpdatedAt = Index(
    'idx_chat_sessions_updated_at',
    'CREATE INDEX idx_chat_sessions_updated_at ON chat_sessions (updated_at)',
  );
  late final Index idxChatMessagesSessionId = Index(
    'idx_chat_messages_session_id',
    'CREATE INDEX idx_chat_messages_session_id ON chat_messages (chat_session_id)',
  );
  late final Index idxChatMessagesCreatedAt = Index(
    'idx_chat_messages_created_at',
    'CREATE INDEX idx_chat_messages_created_at ON chat_messages (created_at)',
  );
  late final Index idxFeedbackEventsType = Index(
    'idx_feedback_events_type',
    'CREATE INDEX idx_feedback_events_type ON feedback_events (event_type)',
  );
  late final Index idxFeedbackEventsCardId = Index(
    'idx_feedback_events_card_id',
    'CREATE INDEX idx_feedback_events_card_id ON feedback_events (card_id)',
  );
  late final Index idxFeedbackEventsSpaceId = Index(
    'idx_feedback_events_space_id',
    'CREATE INDEX idx_feedback_events_space_id ON feedback_events (space_id)',
  );
  late final Index idxFeedbackEventsCreatedAt = Index(
    'idx_feedback_events_created_at',
    'CREATE INDEX idx_feedback_events_created_at ON feedback_events (created_at)',
  );
  late final Index idxPreferenceMemoryCategoryKey = Index(
    'idx_preference_memory_category_key',
    'CREATE UNIQUE INDEX idx_preference_memory_category_key ON preference_memory (category, "key")',
  );
  late final Index idxPreferenceMemoryConfidence = Index(
    'idx_preference_memory_confidence',
    'CREATE INDEX idx_preference_memory_confidence ON preference_memory (confidence)',
  );
  late final Index idxNotificationRequestsCardId = Index(
    'idx_notification_requests_card_id',
    'CREATE INDEX idx_notification_requests_card_id ON notification_requests (card_id)',
  );
  late final Index idxNotificationRequestsStatus = Index(
    'idx_notification_requests_status',
    'CREATE INDEX idx_notification_requests_status ON notification_requests (status)',
  );
  late final Index idxNotificationRequestsScheduledFor = Index(
    'idx_notification_requests_scheduled_for',
    'CREATE INDEX idx_notification_requests_scheduled_for ON notification_requests (scheduled_for)',
  );
  late final Index idxAiProcessingJobsStatusPriority = Index(
    'idx_ai_processing_jobs_status_priority',
    'CREATE INDEX idx_ai_processing_jobs_status_priority ON ai_processing_jobs (status, priority)',
  );
  late final Index idxAiProcessingJobsSourceId = Index(
    'idx_ai_processing_jobs_source_id',
    'CREATE INDEX idx_ai_processing_jobs_source_id ON ai_processing_jobs (source_id)',
  );
  late final Index idxAiProcessingJobsChatSessionId = Index(
    'idx_ai_processing_jobs_chat_session_id',
    'CREATE INDEX idx_ai_processing_jobs_chat_session_id ON ai_processing_jobs (chat_session_id)',
  );
  late final Index idxRagIndexRecordsIndexExternal = Index(
    'idx_rag_index_records_index_external',
    'CREATE UNIQUE INDEX idx_rag_index_records_index_external ON rag_index_records (index_name, external_id)',
  );
  late final Index idxRagIndexRecordsChunkId = Index(
    'idx_rag_index_records_chunk_id',
    'CREATE INDEX idx_rag_index_records_chunk_id ON rag_index_records (source_chunk_id)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    userProfiles,
    appSettings,
    sourceItems,
    sourceTextChunks,
    spaces,
    tagCards,
    cardSources,
    goalPlans,
    goalPlanCards,
    chatSessions,
    chatMessages,
    feedbackEvents,
    preferenceMemory,
    notificationRequests,
    aiProcessingJobs,
    aiModelAssets,
    ragIndexRecords,
    idxSourceItemsCreatedAt,
    idxSourceItemsType,
    idxSourceItemsProcessingState,
    idxSourceItemsContentType,
    idxSourceTextChunksSourceId,
    idxSourceTextChunksSourceChunk,
    idxSourceTextChunksVectorExternalId,
    idxSpacesType,
    idxSpacesUpdatedAt,
    idxSpacesNormalizedName,
    idxTagCardsStatus,
    idxTagCardsCardType,
    idxTagCardsSpaceId,
    idxTagCardsNextActiveDeadline,
    idxTagCardsStatusDeadline,
    idxTagCardsTypeStatusDeadline,
    idxCardSourcesCardId,
    idxCardSourcesSourceId,
    idxGoalPlansSpaceId,
    idxGoalPlansStatus,
    idxGoalPlanCardsGoalPlanId,
    idxGoalPlanCardsSequence,
    idxChatSessionsPurpose,
    idxChatSessionsLinkedCardId,
    idxChatSessionsUpdatedAt,
    idxChatMessagesSessionId,
    idxChatMessagesCreatedAt,
    idxFeedbackEventsType,
    idxFeedbackEventsCardId,
    idxFeedbackEventsSpaceId,
    idxFeedbackEventsCreatedAt,
    idxPreferenceMemoryCategoryKey,
    idxPreferenceMemoryConfidence,
    idxNotificationRequestsCardId,
    idxNotificationRequestsStatus,
    idxNotificationRequestsScheduledFor,
    idxAiProcessingJobsStatusPriority,
    idxAiProcessingJobsSourceId,
    idxAiProcessingJobsChatSessionId,
    idxRagIndexRecordsIndexExternal,
    idxRagIndexRecordsChunkId,
  ];
}

typedef $$UserProfilesTableCreateCompanionBuilder =
    UserProfilesCompanion Function({
      required String id,
      required String nickname,
      required String avatarKind,
      required String avatarValue,
      Value<bool> localOnly,
      Value<int?> onboardingCompletedAt,
      Value<String> notificationPermissionState,
      required int createdAt,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$UserProfilesTableUpdateCompanionBuilder =
    UserProfilesCompanion Function({
      Value<String> id,
      Value<String> nickname,
      Value<String> avatarKind,
      Value<String> avatarValue,
      Value<bool> localOnly,
      Value<int?> onboardingCompletedAt,
      Value<String> notificationPermissionState,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$UserProfilesTableFilterComposer
    extends Composer<_$TagDatabase, $UserProfilesTable> {
  $$UserProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nickname => $composableBuilder(
    column: $table.nickname,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarKind => $composableBuilder(
    column: $table.avatarKind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarValue => $composableBuilder(
    column: $table.avatarValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get localOnly => $composableBuilder(
    column: $table.localOnly,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get onboardingCompletedAt => $composableBuilder(
    column: $table.onboardingCompletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notificationPermissionState => $composableBuilder(
    column: $table.notificationPermissionState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserProfilesTableOrderingComposer
    extends Composer<_$TagDatabase, $UserProfilesTable> {
  $$UserProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nickname => $composableBuilder(
    column: $table.nickname,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarKind => $composableBuilder(
    column: $table.avatarKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarValue => $composableBuilder(
    column: $table.avatarValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get localOnly => $composableBuilder(
    column: $table.localOnly,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get onboardingCompletedAt => $composableBuilder(
    column: $table.onboardingCompletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notificationPermissionState => $composableBuilder(
    column: $table.notificationPermissionState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserProfilesTableAnnotationComposer
    extends Composer<_$TagDatabase, $UserProfilesTable> {
  $$UserProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nickname =>
      $composableBuilder(column: $table.nickname, builder: (column) => column);

  GeneratedColumn<String> get avatarKind => $composableBuilder(
    column: $table.avatarKind,
    builder: (column) => column,
  );

  GeneratedColumn<String> get avatarValue => $composableBuilder(
    column: $table.avatarValue,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get localOnly =>
      $composableBuilder(column: $table.localOnly, builder: (column) => column);

  GeneratedColumn<int> get onboardingCompletedAt => $composableBuilder(
    column: $table.onboardingCompletedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notificationPermissionState => $composableBuilder(
    column: $table.notificationPermissionState,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UserProfilesTableTableManager
    extends
        RootTableManager<
          _$TagDatabase,
          $UserProfilesTable,
          UserProfile,
          $$UserProfilesTableFilterComposer,
          $$UserProfilesTableOrderingComposer,
          $$UserProfilesTableAnnotationComposer,
          $$UserProfilesTableCreateCompanionBuilder,
          $$UserProfilesTableUpdateCompanionBuilder,
          (
            UserProfile,
            BaseReferences<_$TagDatabase, $UserProfilesTable, UserProfile>,
          ),
          UserProfile,
          PrefetchHooks Function()
        > {
  $$UserProfilesTableTableManager(_$TagDatabase db, $UserProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> nickname = const Value.absent(),
                Value<String> avatarKind = const Value.absent(),
                Value<String> avatarValue = const Value.absent(),
                Value<bool> localOnly = const Value.absent(),
                Value<int?> onboardingCompletedAt = const Value.absent(),
                Value<String> notificationPermissionState =
                    const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserProfilesCompanion(
                id: id,
                nickname: nickname,
                avatarKind: avatarKind,
                avatarValue: avatarValue,
                localOnly: localOnly,
                onboardingCompletedAt: onboardingCompletedAt,
                notificationPermissionState: notificationPermissionState,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String nickname,
                required String avatarKind,
                required String avatarValue,
                Value<bool> localOnly = const Value.absent(),
                Value<int?> onboardingCompletedAt = const Value.absent(),
                Value<String> notificationPermissionState =
                    const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => UserProfilesCompanion.insert(
                id: id,
                nickname: nickname,
                avatarKind: avatarKind,
                avatarValue: avatarValue,
                localOnly: localOnly,
                onboardingCompletedAt: onboardingCompletedAt,
                notificationPermissionState: notificationPermissionState,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$TagDatabase,
      $UserProfilesTable,
      UserProfile,
      $$UserProfilesTableFilterComposer,
      $$UserProfilesTableOrderingComposer,
      $$UserProfilesTableAnnotationComposer,
      $$UserProfilesTableCreateCompanionBuilder,
      $$UserProfilesTableUpdateCompanionBuilder,
      (
        UserProfile,
        BaseReferences<_$TagDatabase, $UserProfilesTable, UserProfile>,
      ),
      UserProfile,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String valueJson,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> valueJson,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$TagDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get valueJson => $composableBuilder(
    column: $table.valueJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$TagDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get valueJson => $composableBuilder(
    column: $table.valueJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$TagDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get valueJson =>
      $composableBuilder(column: $table.valueJson, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$TagDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$TagDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$TagDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> valueJson = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(
                key: key,
                valueJson: valueJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String valueJson,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                valueJson: valueJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$TagDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$TagDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;
typedef $$SourceItemsTableCreateCompanionBuilder =
    SourceItemsCompanion Function({
      required String id,
      required String type,
      Value<String?> originalUri,
      Value<String?> localFilePath,
      Value<String?> thumbnailFilePath,
      Value<String?> rawText,
      Value<String?> extractedText,
      Value<String?> sourceSummary,
      Value<String?> appSource,
      Value<String> contentType,
      Value<String?> languageCode,
      Value<String> detectedDatesJson,
      Value<String> detectedTimesJson,
      Value<String> detectedLinksJson,
      Value<String> detectedEntitiesJson,
      Value<String> visibleEntitiesJson,
      Value<String> metadataJson,
      Value<String> processingState,
      Value<double?> extractionConfidence,
      Value<String?> failureReason,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      Value<int> rowid,
    });
typedef $$SourceItemsTableUpdateCompanionBuilder =
    SourceItemsCompanion Function({
      Value<String> id,
      Value<String> type,
      Value<String?> originalUri,
      Value<String?> localFilePath,
      Value<String?> thumbnailFilePath,
      Value<String?> rawText,
      Value<String?> extractedText,
      Value<String?> sourceSummary,
      Value<String?> appSource,
      Value<String> contentType,
      Value<String?> languageCode,
      Value<String> detectedDatesJson,
      Value<String> detectedTimesJson,
      Value<String> detectedLinksJson,
      Value<String> detectedEntitiesJson,
      Value<String> visibleEntitiesJson,
      Value<String> metadataJson,
      Value<String> processingState,
      Value<double?> extractionConfidence,
      Value<String?> failureReason,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<int> rowid,
    });

final class $$SourceItemsTableReferences
    extends BaseReferences<_$TagDatabase, $SourceItemsTable, SourceItem> {
  $$SourceItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SourceTextChunksTable, List<SourceTextChunk>>
  _sourceTextChunksRefsTable(_$TagDatabase db) => MultiTypedResultKey.fromTable(
    db.sourceTextChunks,
    aliasName: $_aliasNameGenerator(
      db.sourceItems.id,
      db.sourceTextChunks.sourceId,
    ),
  );

  $$SourceTextChunksTableProcessedTableManager get sourceTextChunksRefs {
    final manager = $$SourceTextChunksTableTableManager(
      $_db,
      $_db.sourceTextChunks,
    ).filter((f) => f.sourceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _sourceTextChunksRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CardSourcesTable, List<CardSource>>
  _cardSourcesRefsTable(_$TagDatabase db) => MultiTypedResultKey.fromTable(
    db.cardSources,
    aliasName: $_aliasNameGenerator(db.sourceItems.id, db.cardSources.sourceId),
  );

  $$CardSourcesTableProcessedTableManager get cardSourcesRefs {
    final manager = $$CardSourcesTableTableManager(
      $_db,
      $_db.cardSources,
    ).filter((f) => f.sourceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_cardSourcesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$FeedbackEventsTable, List<FeedbackEvent>>
  _feedbackEventsRefsTable(_$TagDatabase db) => MultiTypedResultKey.fromTable(
    db.feedbackEvents,
    aliasName: $_aliasNameGenerator(
      db.sourceItems.id,
      db.feedbackEvents.sourceId,
    ),
  );

  $$FeedbackEventsTableProcessedTableManager get feedbackEventsRefs {
    final manager = $$FeedbackEventsTableTableManager(
      $_db,
      $_db.feedbackEvents,
    ).filter((f) => f.sourceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_feedbackEventsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AiProcessingJobsTable, List<AiProcessingJob>>
  _aiProcessingJobsRefsTable(_$TagDatabase db) => MultiTypedResultKey.fromTable(
    db.aiProcessingJobs,
    aliasName: $_aliasNameGenerator(
      db.sourceItems.id,
      db.aiProcessingJobs.sourceId,
    ),
  );

  $$AiProcessingJobsTableProcessedTableManager get aiProcessingJobsRefs {
    final manager = $$AiProcessingJobsTableTableManager(
      $_db,
      $_db.aiProcessingJobs,
    ).filter((f) => f.sourceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _aiProcessingJobsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SourceItemsTableFilterComposer
    extends Composer<_$TagDatabase, $SourceItemsTable> {
  $$SourceItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originalUri => $composableBuilder(
    column: $table.originalUri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localFilePath => $composableBuilder(
    column: $table.localFilePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbnailFilePath => $composableBuilder(
    column: $table.thumbnailFilePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawText => $composableBuilder(
    column: $table.rawText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get extractedText => $composableBuilder(
    column: $table.extractedText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceSummary => $composableBuilder(
    column: $table.sourceSummary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appSource => $composableBuilder(
    column: $table.appSource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get languageCode => $composableBuilder(
    column: $table.languageCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get detectedDatesJson => $composableBuilder(
    column: $table.detectedDatesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get detectedTimesJson => $composableBuilder(
    column: $table.detectedTimesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get detectedLinksJson => $composableBuilder(
    column: $table.detectedLinksJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get detectedEntitiesJson => $composableBuilder(
    column: $table.detectedEntitiesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get visibleEntitiesJson => $composableBuilder(
    column: $table.visibleEntitiesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get processingState => $composableBuilder(
    column: $table.processingState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get extractionConfidence => $composableBuilder(
    column: $table.extractionConfidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get failureReason => $composableBuilder(
    column: $table.failureReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> sourceTextChunksRefs(
    Expression<bool> Function($$SourceTextChunksTableFilterComposer f) f,
  ) {
    final $$SourceTextChunksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sourceTextChunks,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourceTextChunksTableFilterComposer(
            $db: $db,
            $table: $db.sourceTextChunks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> cardSourcesRefs(
    Expression<bool> Function($$CardSourcesTableFilterComposer f) f,
  ) {
    final $$CardSourcesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cardSources,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardSourcesTableFilterComposer(
            $db: $db,
            $table: $db.cardSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> feedbackEventsRefs(
    Expression<bool> Function($$FeedbackEventsTableFilterComposer f) f,
  ) {
    final $$FeedbackEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.feedbackEvents,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FeedbackEventsTableFilterComposer(
            $db: $db,
            $table: $db.feedbackEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> aiProcessingJobsRefs(
    Expression<bool> Function($$AiProcessingJobsTableFilterComposer f) f,
  ) {
    final $$AiProcessingJobsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.aiProcessingJobs,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AiProcessingJobsTableFilterComposer(
            $db: $db,
            $table: $db.aiProcessingJobs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SourceItemsTableOrderingComposer
    extends Composer<_$TagDatabase, $SourceItemsTable> {
  $$SourceItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalUri => $composableBuilder(
    column: $table.originalUri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localFilePath => $composableBuilder(
    column: $table.localFilePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbnailFilePath => $composableBuilder(
    column: $table.thumbnailFilePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawText => $composableBuilder(
    column: $table.rawText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get extractedText => $composableBuilder(
    column: $table.extractedText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceSummary => $composableBuilder(
    column: $table.sourceSummary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appSource => $composableBuilder(
    column: $table.appSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get languageCode => $composableBuilder(
    column: $table.languageCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get detectedDatesJson => $composableBuilder(
    column: $table.detectedDatesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get detectedTimesJson => $composableBuilder(
    column: $table.detectedTimesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get detectedLinksJson => $composableBuilder(
    column: $table.detectedLinksJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get detectedEntitiesJson => $composableBuilder(
    column: $table.detectedEntitiesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get visibleEntitiesJson => $composableBuilder(
    column: $table.visibleEntitiesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get processingState => $composableBuilder(
    column: $table.processingState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get extractionConfidence => $composableBuilder(
    column: $table.extractionConfidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get failureReason => $composableBuilder(
    column: $table.failureReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SourceItemsTableAnnotationComposer
    extends Composer<_$TagDatabase, $SourceItemsTable> {
  $$SourceItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get originalUri => $composableBuilder(
    column: $table.originalUri,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localFilePath => $composableBuilder(
    column: $table.localFilePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get thumbnailFilePath => $composableBuilder(
    column: $table.thumbnailFilePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rawText =>
      $composableBuilder(column: $table.rawText, builder: (column) => column);

  GeneratedColumn<String> get extractedText => $composableBuilder(
    column: $table.extractedText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceSummary => $composableBuilder(
    column: $table.sourceSummary,
    builder: (column) => column,
  );

  GeneratedColumn<String> get appSource =>
      $composableBuilder(column: $table.appSource, builder: (column) => column);

  GeneratedColumn<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get languageCode => $composableBuilder(
    column: $table.languageCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get detectedDatesJson => $composableBuilder(
    column: $table.detectedDatesJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get detectedTimesJson => $composableBuilder(
    column: $table.detectedTimesJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get detectedLinksJson => $composableBuilder(
    column: $table.detectedLinksJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get detectedEntitiesJson => $composableBuilder(
    column: $table.detectedEntitiesJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get visibleEntitiesJson => $composableBuilder(
    column: $table.visibleEntitiesJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get processingState => $composableBuilder(
    column: $table.processingState,
    builder: (column) => column,
  );

  GeneratedColumn<double> get extractionConfidence => $composableBuilder(
    column: $table.extractionConfidence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get failureReason => $composableBuilder(
    column: $table.failureReason,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  Expression<T> sourceTextChunksRefs<T extends Object>(
    Expression<T> Function($$SourceTextChunksTableAnnotationComposer a) f,
  ) {
    final $$SourceTextChunksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sourceTextChunks,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourceTextChunksTableAnnotationComposer(
            $db: $db,
            $table: $db.sourceTextChunks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> cardSourcesRefs<T extends Object>(
    Expression<T> Function($$CardSourcesTableAnnotationComposer a) f,
  ) {
    final $$CardSourcesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cardSources,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardSourcesTableAnnotationComposer(
            $db: $db,
            $table: $db.cardSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> feedbackEventsRefs<T extends Object>(
    Expression<T> Function($$FeedbackEventsTableAnnotationComposer a) f,
  ) {
    final $$FeedbackEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.feedbackEvents,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FeedbackEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.feedbackEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> aiProcessingJobsRefs<T extends Object>(
    Expression<T> Function($$AiProcessingJobsTableAnnotationComposer a) f,
  ) {
    final $$AiProcessingJobsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.aiProcessingJobs,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AiProcessingJobsTableAnnotationComposer(
            $db: $db,
            $table: $db.aiProcessingJobs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SourceItemsTableTableManager
    extends
        RootTableManager<
          _$TagDatabase,
          $SourceItemsTable,
          SourceItem,
          $$SourceItemsTableFilterComposer,
          $$SourceItemsTableOrderingComposer,
          $$SourceItemsTableAnnotationComposer,
          $$SourceItemsTableCreateCompanionBuilder,
          $$SourceItemsTableUpdateCompanionBuilder,
          (SourceItem, $$SourceItemsTableReferences),
          SourceItem,
          PrefetchHooks Function({
            bool sourceTextChunksRefs,
            bool cardSourcesRefs,
            bool feedbackEventsRefs,
            bool aiProcessingJobsRefs,
          })
        > {
  $$SourceItemsTableTableManager(_$TagDatabase db, $SourceItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SourceItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SourceItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SourceItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> originalUri = const Value.absent(),
                Value<String?> localFilePath = const Value.absent(),
                Value<String?> thumbnailFilePath = const Value.absent(),
                Value<String?> rawText = const Value.absent(),
                Value<String?> extractedText = const Value.absent(),
                Value<String?> sourceSummary = const Value.absent(),
                Value<String?> appSource = const Value.absent(),
                Value<String> contentType = const Value.absent(),
                Value<String?> languageCode = const Value.absent(),
                Value<String> detectedDatesJson = const Value.absent(),
                Value<String> detectedTimesJson = const Value.absent(),
                Value<String> detectedLinksJson = const Value.absent(),
                Value<String> detectedEntitiesJson = const Value.absent(),
                Value<String> visibleEntitiesJson = const Value.absent(),
                Value<String> metadataJson = const Value.absent(),
                Value<String> processingState = const Value.absent(),
                Value<double?> extractionConfidence = const Value.absent(),
                Value<String?> failureReason = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SourceItemsCompanion(
                id: id,
                type: type,
                originalUri: originalUri,
                localFilePath: localFilePath,
                thumbnailFilePath: thumbnailFilePath,
                rawText: rawText,
                extractedText: extractedText,
                sourceSummary: sourceSummary,
                appSource: appSource,
                contentType: contentType,
                languageCode: languageCode,
                detectedDatesJson: detectedDatesJson,
                detectedTimesJson: detectedTimesJson,
                detectedLinksJson: detectedLinksJson,
                detectedEntitiesJson: detectedEntitiesJson,
                visibleEntitiesJson: visibleEntitiesJson,
                metadataJson: metadataJson,
                processingState: processingState,
                extractionConfidence: extractionConfidence,
                failureReason: failureReason,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String type,
                Value<String?> originalUri = const Value.absent(),
                Value<String?> localFilePath = const Value.absent(),
                Value<String?> thumbnailFilePath = const Value.absent(),
                Value<String?> rawText = const Value.absent(),
                Value<String?> extractedText = const Value.absent(),
                Value<String?> sourceSummary = const Value.absent(),
                Value<String?> appSource = const Value.absent(),
                Value<String> contentType = const Value.absent(),
                Value<String?> languageCode = const Value.absent(),
                Value<String> detectedDatesJson = const Value.absent(),
                Value<String> detectedTimesJson = const Value.absent(),
                Value<String> detectedLinksJson = const Value.absent(),
                Value<String> detectedEntitiesJson = const Value.absent(),
                Value<String> visibleEntitiesJson = const Value.absent(),
                Value<String> metadataJson = const Value.absent(),
                Value<String> processingState = const Value.absent(),
                Value<double?> extractionConfidence = const Value.absent(),
                Value<String?> failureReason = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SourceItemsCompanion.insert(
                id: id,
                type: type,
                originalUri: originalUri,
                localFilePath: localFilePath,
                thumbnailFilePath: thumbnailFilePath,
                rawText: rawText,
                extractedText: extractedText,
                sourceSummary: sourceSummary,
                appSource: appSource,
                contentType: contentType,
                languageCode: languageCode,
                detectedDatesJson: detectedDatesJson,
                detectedTimesJson: detectedTimesJson,
                detectedLinksJson: detectedLinksJson,
                detectedEntitiesJson: detectedEntitiesJson,
                visibleEntitiesJson: visibleEntitiesJson,
                metadataJson: metadataJson,
                processingState: processingState,
                extractionConfidence: extractionConfidence,
                failureReason: failureReason,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SourceItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                sourceTextChunksRefs = false,
                cardSourcesRefs = false,
                feedbackEventsRefs = false,
                aiProcessingJobsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (sourceTextChunksRefs) db.sourceTextChunks,
                    if (cardSourcesRefs) db.cardSources,
                    if (feedbackEventsRefs) db.feedbackEvents,
                    if (aiProcessingJobsRefs) db.aiProcessingJobs,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (sourceTextChunksRefs)
                        await $_getPrefetchedData<
                          SourceItem,
                          $SourceItemsTable,
                          SourceTextChunk
                        >(
                          currentTable: table,
                          referencedTable: $$SourceItemsTableReferences
                              ._sourceTextChunksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SourceItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).sourceTextChunksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sourceId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (cardSourcesRefs)
                        await $_getPrefetchedData<
                          SourceItem,
                          $SourceItemsTable,
                          CardSource
                        >(
                          currentTable: table,
                          referencedTable: $$SourceItemsTableReferences
                              ._cardSourcesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SourceItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).cardSourcesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sourceId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (feedbackEventsRefs)
                        await $_getPrefetchedData<
                          SourceItem,
                          $SourceItemsTable,
                          FeedbackEvent
                        >(
                          currentTable: table,
                          referencedTable: $$SourceItemsTableReferences
                              ._feedbackEventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SourceItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).feedbackEventsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sourceId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (aiProcessingJobsRefs)
                        await $_getPrefetchedData<
                          SourceItem,
                          $SourceItemsTable,
                          AiProcessingJob
                        >(
                          currentTable: table,
                          referencedTable: $$SourceItemsTableReferences
                              ._aiProcessingJobsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SourceItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).aiProcessingJobsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sourceId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SourceItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$TagDatabase,
      $SourceItemsTable,
      SourceItem,
      $$SourceItemsTableFilterComposer,
      $$SourceItemsTableOrderingComposer,
      $$SourceItemsTableAnnotationComposer,
      $$SourceItemsTableCreateCompanionBuilder,
      $$SourceItemsTableUpdateCompanionBuilder,
      (SourceItem, $$SourceItemsTableReferences),
      SourceItem,
      PrefetchHooks Function({
        bool sourceTextChunksRefs,
        bool cardSourcesRefs,
        bool feedbackEventsRefs,
        bool aiProcessingJobsRefs,
      })
    >;
typedef $$SourceTextChunksTableCreateCompanionBuilder =
    SourceTextChunksCompanion Function({
      required String id,
      required String sourceId,
      required int chunkIndex,
      required String chunkText,
      Value<int?> charStart,
      Value<int?> charEnd,
      Value<int?> tokenCountEstimate,
      Value<String?> embeddingModelSlug,
      Value<String?> vectorIndexName,
      Value<String?> vectorExternalId,
      Value<int?> embeddingDimension,
      required int createdAt,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$SourceTextChunksTableUpdateCompanionBuilder =
    SourceTextChunksCompanion Function({
      Value<String> id,
      Value<String> sourceId,
      Value<int> chunkIndex,
      Value<String> chunkText,
      Value<int?> charStart,
      Value<int?> charEnd,
      Value<int?> tokenCountEstimate,
      Value<String?> embeddingModelSlug,
      Value<String?> vectorIndexName,
      Value<String?> vectorExternalId,
      Value<int?> embeddingDimension,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> rowid,
    });

final class $$SourceTextChunksTableReferences
    extends
        BaseReferences<_$TagDatabase, $SourceTextChunksTable, SourceTextChunk> {
  $$SourceTextChunksTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SourceItemsTable _sourceIdTable(_$TagDatabase db) =>
      db.sourceItems.createAlias(
        $_aliasNameGenerator(db.sourceTextChunks.sourceId, db.sourceItems.id),
      );

  $$SourceItemsTableProcessedTableManager get sourceId {
    final $_column = $_itemColumn<String>('source_id')!;

    final manager = $$SourceItemsTableTableManager(
      $_db,
      $_db.sourceItems,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$RagIndexRecordsTable, List<RagIndexRecord>>
  _ragIndexRecordsRefsTable(_$TagDatabase db) => MultiTypedResultKey.fromTable(
    db.ragIndexRecords,
    aliasName: $_aliasNameGenerator(
      db.sourceTextChunks.id,
      db.ragIndexRecords.sourceChunkId,
    ),
  );

  $$RagIndexRecordsTableProcessedTableManager get ragIndexRecordsRefs {
    final manager = $$RagIndexRecordsTableTableManager(
      $_db,
      $_db.ragIndexRecords,
    ).filter((f) => f.sourceChunkId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _ragIndexRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SourceTextChunksTableFilterComposer
    extends Composer<_$TagDatabase, $SourceTextChunksTable> {
  $$SourceTextChunksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chunkIndex => $composableBuilder(
    column: $table.chunkIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chunkText => $composableBuilder(
    column: $table.chunkText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get charStart => $composableBuilder(
    column: $table.charStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get charEnd => $composableBuilder(
    column: $table.charEnd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tokenCountEstimate => $composableBuilder(
    column: $table.tokenCountEstimate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get embeddingModelSlug => $composableBuilder(
    column: $table.embeddingModelSlug,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vectorIndexName => $composableBuilder(
    column: $table.vectorIndexName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vectorExternalId => $composableBuilder(
    column: $table.vectorExternalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get embeddingDimension => $composableBuilder(
    column: $table.embeddingDimension,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SourceItemsTableFilterComposer get sourceId {
    final $$SourceItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.sourceItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourceItemsTableFilterComposer(
            $db: $db,
            $table: $db.sourceItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> ragIndexRecordsRefs(
    Expression<bool> Function($$RagIndexRecordsTableFilterComposer f) f,
  ) {
    final $$RagIndexRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ragIndexRecords,
      getReferencedColumn: (t) => t.sourceChunkId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RagIndexRecordsTableFilterComposer(
            $db: $db,
            $table: $db.ragIndexRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SourceTextChunksTableOrderingComposer
    extends Composer<_$TagDatabase, $SourceTextChunksTable> {
  $$SourceTextChunksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chunkIndex => $composableBuilder(
    column: $table.chunkIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chunkText => $composableBuilder(
    column: $table.chunkText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get charStart => $composableBuilder(
    column: $table.charStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get charEnd => $composableBuilder(
    column: $table.charEnd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tokenCountEstimate => $composableBuilder(
    column: $table.tokenCountEstimate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get embeddingModelSlug => $composableBuilder(
    column: $table.embeddingModelSlug,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vectorIndexName => $composableBuilder(
    column: $table.vectorIndexName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vectorExternalId => $composableBuilder(
    column: $table.vectorExternalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get embeddingDimension => $composableBuilder(
    column: $table.embeddingDimension,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SourceItemsTableOrderingComposer get sourceId {
    final $$SourceItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.sourceItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourceItemsTableOrderingComposer(
            $db: $db,
            $table: $db.sourceItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SourceTextChunksTableAnnotationComposer
    extends Composer<_$TagDatabase, $SourceTextChunksTable> {
  $$SourceTextChunksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get chunkIndex => $composableBuilder(
    column: $table.chunkIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get chunkText =>
      $composableBuilder(column: $table.chunkText, builder: (column) => column);

  GeneratedColumn<int> get charStart =>
      $composableBuilder(column: $table.charStart, builder: (column) => column);

  GeneratedColumn<int> get charEnd =>
      $composableBuilder(column: $table.charEnd, builder: (column) => column);

  GeneratedColumn<int> get tokenCountEstimate => $composableBuilder(
    column: $table.tokenCountEstimate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get embeddingModelSlug => $composableBuilder(
    column: $table.embeddingModelSlug,
    builder: (column) => column,
  );

  GeneratedColumn<String> get vectorIndexName => $composableBuilder(
    column: $table.vectorIndexName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get vectorExternalId => $composableBuilder(
    column: $table.vectorExternalId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get embeddingDimension => $composableBuilder(
    column: $table.embeddingDimension,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$SourceItemsTableAnnotationComposer get sourceId {
    final $$SourceItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.sourceItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourceItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.sourceItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> ragIndexRecordsRefs<T extends Object>(
    Expression<T> Function($$RagIndexRecordsTableAnnotationComposer a) f,
  ) {
    final $$RagIndexRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ragIndexRecords,
      getReferencedColumn: (t) => t.sourceChunkId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RagIndexRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.ragIndexRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SourceTextChunksTableTableManager
    extends
        RootTableManager<
          _$TagDatabase,
          $SourceTextChunksTable,
          SourceTextChunk,
          $$SourceTextChunksTableFilterComposer,
          $$SourceTextChunksTableOrderingComposer,
          $$SourceTextChunksTableAnnotationComposer,
          $$SourceTextChunksTableCreateCompanionBuilder,
          $$SourceTextChunksTableUpdateCompanionBuilder,
          (SourceTextChunk, $$SourceTextChunksTableReferences),
          SourceTextChunk,
          PrefetchHooks Function({bool sourceId, bool ragIndexRecordsRefs})
        > {
  $$SourceTextChunksTableTableManager(
    _$TagDatabase db,
    $SourceTextChunksTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SourceTextChunksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SourceTextChunksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SourceTextChunksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sourceId = const Value.absent(),
                Value<int> chunkIndex = const Value.absent(),
                Value<String> chunkText = const Value.absent(),
                Value<int?> charStart = const Value.absent(),
                Value<int?> charEnd = const Value.absent(),
                Value<int?> tokenCountEstimate = const Value.absent(),
                Value<String?> embeddingModelSlug = const Value.absent(),
                Value<String?> vectorIndexName = const Value.absent(),
                Value<String?> vectorExternalId = const Value.absent(),
                Value<int?> embeddingDimension = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SourceTextChunksCompanion(
                id: id,
                sourceId: sourceId,
                chunkIndex: chunkIndex,
                chunkText: chunkText,
                charStart: charStart,
                charEnd: charEnd,
                tokenCountEstimate: tokenCountEstimate,
                embeddingModelSlug: embeddingModelSlug,
                vectorIndexName: vectorIndexName,
                vectorExternalId: vectorExternalId,
                embeddingDimension: embeddingDimension,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sourceId,
                required int chunkIndex,
                required String chunkText,
                Value<int?> charStart = const Value.absent(),
                Value<int?> charEnd = const Value.absent(),
                Value<int?> tokenCountEstimate = const Value.absent(),
                Value<String?> embeddingModelSlug = const Value.absent(),
                Value<String?> vectorIndexName = const Value.absent(),
                Value<String?> vectorExternalId = const Value.absent(),
                Value<int?> embeddingDimension = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => SourceTextChunksCompanion.insert(
                id: id,
                sourceId: sourceId,
                chunkIndex: chunkIndex,
                chunkText: chunkText,
                charStart: charStart,
                charEnd: charEnd,
                tokenCountEstimate: tokenCountEstimate,
                embeddingModelSlug: embeddingModelSlug,
                vectorIndexName: vectorIndexName,
                vectorExternalId: vectorExternalId,
                embeddingDimension: embeddingDimension,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SourceTextChunksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({sourceId = false, ragIndexRecordsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (ragIndexRecordsRefs) db.ragIndexRecords,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (sourceId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.sourceId,
                                    referencedTable:
                                        $$SourceTextChunksTableReferences
                                            ._sourceIdTable(db),
                                    referencedColumn:
                                        $$SourceTextChunksTableReferences
                                            ._sourceIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (ragIndexRecordsRefs)
                        await $_getPrefetchedData<
                          SourceTextChunk,
                          $SourceTextChunksTable,
                          RagIndexRecord
                        >(
                          currentTable: table,
                          referencedTable: $$SourceTextChunksTableReferences
                              ._ragIndexRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SourceTextChunksTableReferences(
                                db,
                                table,
                                p0,
                              ).ragIndexRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sourceChunkId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SourceTextChunksTableProcessedTableManager =
    ProcessedTableManager<
      _$TagDatabase,
      $SourceTextChunksTable,
      SourceTextChunk,
      $$SourceTextChunksTableFilterComposer,
      $$SourceTextChunksTableOrderingComposer,
      $$SourceTextChunksTableAnnotationComposer,
      $$SourceTextChunksTableCreateCompanionBuilder,
      $$SourceTextChunksTableUpdateCompanionBuilder,
      (SourceTextChunk, $$SourceTextChunksTableReferences),
      SourceTextChunk,
      PrefetchHooks Function({bool sourceId, bool ragIndexRecordsRefs})
    >;
typedef $$SpacesTableCreateCompanionBuilder =
    SpacesCompanion Function({
      required String id,
      required String name,
      required String normalizedName,
      required String type,
      Value<String?> description,
      Value<String?> primaryIntentionType,
      required String createdBy,
      Value<double?> confidence,
      Value<String> sourceIdsSnapshotJson,
      Value<String> metadataJson,
      required int createdAt,
      required int updatedAt,
      Value<int?> archivedAt,
      Value<int?> deletedAt,
      Value<int> rowid,
    });
typedef $$SpacesTableUpdateCompanionBuilder =
    SpacesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> normalizedName,
      Value<String> type,
      Value<String?> description,
      Value<String?> primaryIntentionType,
      Value<String> createdBy,
      Value<double?> confidence,
      Value<String> sourceIdsSnapshotJson,
      Value<String> metadataJson,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> archivedAt,
      Value<int?> deletedAt,
      Value<int> rowid,
    });

final class $$SpacesTableReferences
    extends BaseReferences<_$TagDatabase, $SpacesTable, Space> {
  $$SpacesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TagCardsTable, List<TagCard>> _tagCardsRefsTable(
    _$TagDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.tagCards,
    aliasName: $_aliasNameGenerator(db.spaces.id, db.tagCards.spaceId),
  );

  $$TagCardsTableProcessedTableManager get tagCardsRefs {
    final manager = $$TagCardsTableTableManager(
      $_db,
      $_db.tagCards,
    ).filter((f) => f.spaceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_tagCardsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$GoalPlansTable, List<GoalPlan>>
  _goalPlansRefsTable(_$TagDatabase db) => MultiTypedResultKey.fromTable(
    db.goalPlans,
    aliasName: $_aliasNameGenerator(db.spaces.id, db.goalPlans.spaceId),
  );

  $$GoalPlansTableProcessedTableManager get goalPlansRefs {
    final manager = $$GoalPlansTableTableManager(
      $_db,
      $_db.goalPlans,
    ).filter((f) => f.spaceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_goalPlansRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ChatSessionsTable, List<ChatSession>>
  _chatSessionsRefsTable(_$TagDatabase db) => MultiTypedResultKey.fromTable(
    db.chatSessions,
    aliasName: $_aliasNameGenerator(
      db.spaces.id,
      db.chatSessions.linkedSpaceId,
    ),
  );

  $$ChatSessionsTableProcessedTableManager get chatSessionsRefs {
    final manager = $$ChatSessionsTableTableManager(
      $_db,
      $_db.chatSessions,
    ).filter((f) => f.linkedSpaceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_chatSessionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$FeedbackEventsTable, List<FeedbackEvent>>
  _feedbackEventsRefsTable(_$TagDatabase db) => MultiTypedResultKey.fromTable(
    db.feedbackEvents,
    aliasName: $_aliasNameGenerator(db.spaces.id, db.feedbackEvents.spaceId),
  );

  $$FeedbackEventsTableProcessedTableManager get feedbackEventsRefs {
    final manager = $$FeedbackEventsTableTableManager(
      $_db,
      $_db.feedbackEvents,
    ).filter((f) => f.spaceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_feedbackEventsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AiProcessingJobsTable, List<AiProcessingJob>>
  _aiProcessingJobsRefsTable(_$TagDatabase db) => MultiTypedResultKey.fromTable(
    db.aiProcessingJobs,
    aliasName: $_aliasNameGenerator(db.spaces.id, db.aiProcessingJobs.spaceId),
  );

  $$AiProcessingJobsTableProcessedTableManager get aiProcessingJobsRefs {
    final manager = $$AiProcessingJobsTableTableManager(
      $_db,
      $_db.aiProcessingJobs,
    ).filter((f) => f.spaceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _aiProcessingJobsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SpacesTableFilterComposer
    extends Composer<_$TagDatabase, $SpacesTable> {
  $$SpacesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get primaryIntentionType => $composableBuilder(
    column: $table.primaryIntentionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceIdsSnapshotJson => $composableBuilder(
    column: $table.sourceIdsSnapshotJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> tagCardsRefs(
    Expression<bool> Function($$TagCardsTableFilterComposer f) f,
  ) {
    final $$TagCardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tagCards,
      getReferencedColumn: (t) => t.spaceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagCardsTableFilterComposer(
            $db: $db,
            $table: $db.tagCards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> goalPlansRefs(
    Expression<bool> Function($$GoalPlansTableFilterComposer f) f,
  ) {
    final $$GoalPlansTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.goalPlans,
      getReferencedColumn: (t) => t.spaceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GoalPlansTableFilterComposer(
            $db: $db,
            $table: $db.goalPlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> chatSessionsRefs(
    Expression<bool> Function($$ChatSessionsTableFilterComposer f) f,
  ) {
    final $$ChatSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chatSessions,
      getReferencedColumn: (t) => t.linkedSpaceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatSessionsTableFilterComposer(
            $db: $db,
            $table: $db.chatSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> feedbackEventsRefs(
    Expression<bool> Function($$FeedbackEventsTableFilterComposer f) f,
  ) {
    final $$FeedbackEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.feedbackEvents,
      getReferencedColumn: (t) => t.spaceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FeedbackEventsTableFilterComposer(
            $db: $db,
            $table: $db.feedbackEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> aiProcessingJobsRefs(
    Expression<bool> Function($$AiProcessingJobsTableFilterComposer f) f,
  ) {
    final $$AiProcessingJobsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.aiProcessingJobs,
      getReferencedColumn: (t) => t.spaceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AiProcessingJobsTableFilterComposer(
            $db: $db,
            $table: $db.aiProcessingJobs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SpacesTableOrderingComposer
    extends Composer<_$TagDatabase, $SpacesTable> {
  $$SpacesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get primaryIntentionType => $composableBuilder(
    column: $table.primaryIntentionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceIdsSnapshotJson => $composableBuilder(
    column: $table.sourceIdsSnapshotJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SpacesTableAnnotationComposer
    extends Composer<_$TagDatabase, $SpacesTable> {
  $$SpacesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get primaryIntentionType => $composableBuilder(
    column: $table.primaryIntentionType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceIdsSnapshotJson => $composableBuilder(
    column: $table.sourceIdsSnapshotJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  Expression<T> tagCardsRefs<T extends Object>(
    Expression<T> Function($$TagCardsTableAnnotationComposer a) f,
  ) {
    final $$TagCardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tagCards,
      getReferencedColumn: (t) => t.spaceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagCardsTableAnnotationComposer(
            $db: $db,
            $table: $db.tagCards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> goalPlansRefs<T extends Object>(
    Expression<T> Function($$GoalPlansTableAnnotationComposer a) f,
  ) {
    final $$GoalPlansTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.goalPlans,
      getReferencedColumn: (t) => t.spaceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GoalPlansTableAnnotationComposer(
            $db: $db,
            $table: $db.goalPlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> chatSessionsRefs<T extends Object>(
    Expression<T> Function($$ChatSessionsTableAnnotationComposer a) f,
  ) {
    final $$ChatSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chatSessions,
      getReferencedColumn: (t) => t.linkedSpaceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.chatSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> feedbackEventsRefs<T extends Object>(
    Expression<T> Function($$FeedbackEventsTableAnnotationComposer a) f,
  ) {
    final $$FeedbackEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.feedbackEvents,
      getReferencedColumn: (t) => t.spaceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FeedbackEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.feedbackEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> aiProcessingJobsRefs<T extends Object>(
    Expression<T> Function($$AiProcessingJobsTableAnnotationComposer a) f,
  ) {
    final $$AiProcessingJobsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.aiProcessingJobs,
      getReferencedColumn: (t) => t.spaceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AiProcessingJobsTableAnnotationComposer(
            $db: $db,
            $table: $db.aiProcessingJobs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SpacesTableTableManager
    extends
        RootTableManager<
          _$TagDatabase,
          $SpacesTable,
          Space,
          $$SpacesTableFilterComposer,
          $$SpacesTableOrderingComposer,
          $$SpacesTableAnnotationComposer,
          $$SpacesTableCreateCompanionBuilder,
          $$SpacesTableUpdateCompanionBuilder,
          (Space, $$SpacesTableReferences),
          Space,
          PrefetchHooks Function({
            bool tagCardsRefs,
            bool goalPlansRefs,
            bool chatSessionsRefs,
            bool feedbackEventsRefs,
            bool aiProcessingJobsRefs,
          })
        > {
  $$SpacesTableTableManager(_$TagDatabase db, $SpacesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SpacesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SpacesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SpacesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> normalizedName = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> primaryIntentionType = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<double?> confidence = const Value.absent(),
                Value<String> sourceIdsSnapshotJson = const Value.absent(),
                Value<String> metadataJson = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> archivedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SpacesCompanion(
                id: id,
                name: name,
                normalizedName: normalizedName,
                type: type,
                description: description,
                primaryIntentionType: primaryIntentionType,
                createdBy: createdBy,
                confidence: confidence,
                sourceIdsSnapshotJson: sourceIdsSnapshotJson,
                metadataJson: metadataJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                archivedAt: archivedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String normalizedName,
                required String type,
                Value<String?> description = const Value.absent(),
                Value<String?> primaryIntentionType = const Value.absent(),
                required String createdBy,
                Value<double?> confidence = const Value.absent(),
                Value<String> sourceIdsSnapshotJson = const Value.absent(),
                Value<String> metadataJson = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int?> archivedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SpacesCompanion.insert(
                id: id,
                name: name,
                normalizedName: normalizedName,
                type: type,
                description: description,
                primaryIntentionType: primaryIntentionType,
                createdBy: createdBy,
                confidence: confidence,
                sourceIdsSnapshotJson: sourceIdsSnapshotJson,
                metadataJson: metadataJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                archivedAt: archivedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$SpacesTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                tagCardsRefs = false,
                goalPlansRefs = false,
                chatSessionsRefs = false,
                feedbackEventsRefs = false,
                aiProcessingJobsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (tagCardsRefs) db.tagCards,
                    if (goalPlansRefs) db.goalPlans,
                    if (chatSessionsRefs) db.chatSessions,
                    if (feedbackEventsRefs) db.feedbackEvents,
                    if (aiProcessingJobsRefs) db.aiProcessingJobs,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (tagCardsRefs)
                        await $_getPrefetchedData<Space, $SpacesTable, TagCard>(
                          currentTable: table,
                          referencedTable: $$SpacesTableReferences
                              ._tagCardsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SpacesTableReferences(
                                db,
                                table,
                                p0,
                              ).tagCardsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.spaceId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (goalPlansRefs)
                        await $_getPrefetchedData<
                          Space,
                          $SpacesTable,
                          GoalPlan
                        >(
                          currentTable: table,
                          referencedTable: $$SpacesTableReferences
                              ._goalPlansRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SpacesTableReferences(
                                db,
                                table,
                                p0,
                              ).goalPlansRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.spaceId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (chatSessionsRefs)
                        await $_getPrefetchedData<
                          Space,
                          $SpacesTable,
                          ChatSession
                        >(
                          currentTable: table,
                          referencedTable: $$SpacesTableReferences
                              ._chatSessionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SpacesTableReferences(
                                db,
                                table,
                                p0,
                              ).chatSessionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.linkedSpaceId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (feedbackEventsRefs)
                        await $_getPrefetchedData<
                          Space,
                          $SpacesTable,
                          FeedbackEvent
                        >(
                          currentTable: table,
                          referencedTable: $$SpacesTableReferences
                              ._feedbackEventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SpacesTableReferences(
                                db,
                                table,
                                p0,
                              ).feedbackEventsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.spaceId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (aiProcessingJobsRefs)
                        await $_getPrefetchedData<
                          Space,
                          $SpacesTable,
                          AiProcessingJob
                        >(
                          currentTable: table,
                          referencedTable: $$SpacesTableReferences
                              ._aiProcessingJobsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SpacesTableReferences(
                                db,
                                table,
                                p0,
                              ).aiProcessingJobsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.spaceId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SpacesTableProcessedTableManager =
    ProcessedTableManager<
      _$TagDatabase,
      $SpacesTable,
      Space,
      $$SpacesTableFilterComposer,
      $$SpacesTableOrderingComposer,
      $$SpacesTableAnnotationComposer,
      $$SpacesTableCreateCompanionBuilder,
      $$SpacesTableUpdateCompanionBuilder,
      (Space, $$SpacesTableReferences),
      Space,
      PrefetchHooks Function({
        bool tagCardsRefs,
        bool goalPlansRefs,
        bool chatSessionsRefs,
        bool feedbackEventsRefs,
        bool aiProcessingJobsRefs,
      })
    >;
typedef $$TagCardsTableCreateCompanionBuilder =
    TagCardsCompanion Function({
      required String id,
      required String cardType,
      Value<String> status,
      required String title,
      required String reason,
      required String spaceId,
      Value<int?> nextActiveDeadline,
      Value<String?> deadlineTimezone,
      Value<int?> snoozedUntil,
      Value<bool> notificationEnabled,
      Value<String> actionsJson,
      Value<double?> confidence,
      required String sourceSummary,
      required String evidenceSummary,
      Value<String?> parentGoalPlanId,
      Value<String?> suggestionClusterId,
      required String createdBy,
      Value<String?> modelSlug,
      Value<String?> modelOutputJson,
      Value<String> metadataJson,
      required int createdAt,
      required int updatedAt,
      Value<int?> completedAt,
      Value<int?> cancelledAt,
      Value<int?> dismissedAt,
      Value<int?> archivedAt,
      Value<int?> deletedAt,
      Value<int> rowid,
    });
typedef $$TagCardsTableUpdateCompanionBuilder =
    TagCardsCompanion Function({
      Value<String> id,
      Value<String> cardType,
      Value<String> status,
      Value<String> title,
      Value<String> reason,
      Value<String> spaceId,
      Value<int?> nextActiveDeadline,
      Value<String?> deadlineTimezone,
      Value<int?> snoozedUntil,
      Value<bool> notificationEnabled,
      Value<String> actionsJson,
      Value<double?> confidence,
      Value<String> sourceSummary,
      Value<String> evidenceSummary,
      Value<String?> parentGoalPlanId,
      Value<String?> suggestionClusterId,
      Value<String> createdBy,
      Value<String?> modelSlug,
      Value<String?> modelOutputJson,
      Value<String> metadataJson,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> completedAt,
      Value<int?> cancelledAt,
      Value<int?> dismissedAt,
      Value<int?> archivedAt,
      Value<int?> deletedAt,
      Value<int> rowid,
    });

final class $$TagCardsTableReferences
    extends BaseReferences<_$TagDatabase, $TagCardsTable, TagCard> {
  $$TagCardsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SpacesTable _spaceIdTable(_$TagDatabase db) => db.spaces.createAlias(
    $_aliasNameGenerator(db.tagCards.spaceId, db.spaces.id),
  );

  $$SpacesTableProcessedTableManager get spaceId {
    final $_column = $_itemColumn<String>('space_id')!;

    final manager = $$SpacesTableTableManager(
      $_db,
      $_db.spaces,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_spaceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$CardSourcesTable, List<CardSource>>
  _cardSourcesRefsTable(_$TagDatabase db) => MultiTypedResultKey.fromTable(
    db.cardSources,
    aliasName: $_aliasNameGenerator(db.tagCards.id, db.cardSources.cardId),
  );

  $$CardSourcesTableProcessedTableManager get cardSourcesRefs {
    final manager = $$CardSourcesTableTableManager(
      $_db,
      $_db.cardSources,
    ).filter((f) => f.cardId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_cardSourcesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$GoalPlanCardsTable, List<GoalPlanCard>>
  _goalPlanCardsRefsTable(_$TagDatabase db) => MultiTypedResultKey.fromTable(
    db.goalPlanCards,
    aliasName: $_aliasNameGenerator(db.tagCards.id, db.goalPlanCards.cardId),
  );

  $$GoalPlanCardsTableProcessedTableManager get goalPlanCardsRefs {
    final manager = $$GoalPlanCardsTableTableManager(
      $_db,
      $_db.goalPlanCards,
    ).filter((f) => f.cardId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_goalPlanCardsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$FeedbackEventsTable, List<FeedbackEvent>>
  _feedbackEventsRefsTable(_$TagDatabase db) => MultiTypedResultKey.fromTable(
    db.feedbackEvents,
    aliasName: $_aliasNameGenerator(db.tagCards.id, db.feedbackEvents.cardId),
  );

  $$FeedbackEventsTableProcessedTableManager get feedbackEventsRefs {
    final manager = $$FeedbackEventsTableTableManager(
      $_db,
      $_db.feedbackEvents,
    ).filter((f) => f.cardId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_feedbackEventsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $NotificationRequestsTable,
    List<NotificationRequest>
  >
  _notificationRequestsRefsTable(_$TagDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.notificationRequests,
        aliasName: $_aliasNameGenerator(
          db.tagCards.id,
          db.notificationRequests.cardId,
        ),
      );

  $$NotificationRequestsTableProcessedTableManager
  get notificationRequestsRefs {
    final manager = $$NotificationRequestsTableTableManager(
      $_db,
      $_db.notificationRequests,
    ).filter((f) => f.cardId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _notificationRequestsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AiProcessingJobsTable, List<AiProcessingJob>>
  _aiProcessingJobsRefsTable(_$TagDatabase db) => MultiTypedResultKey.fromTable(
    db.aiProcessingJobs,
    aliasName: $_aliasNameGenerator(db.tagCards.id, db.aiProcessingJobs.cardId),
  );

  $$AiProcessingJobsTableProcessedTableManager get aiProcessingJobsRefs {
    final manager = $$AiProcessingJobsTableTableManager(
      $_db,
      $_db.aiProcessingJobs,
    ).filter((f) => f.cardId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _aiProcessingJobsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TagCardsTableFilterComposer
    extends Composer<_$TagDatabase, $TagCardsTable> {
  $$TagCardsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cardType => $composableBuilder(
    column: $table.cardType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nextActiveDeadline => $composableBuilder(
    column: $table.nextActiveDeadline,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deadlineTimezone => $composableBuilder(
    column: $table.deadlineTimezone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get snoozedUntil => $composableBuilder(
    column: $table.snoozedUntil,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get notificationEnabled => $composableBuilder(
    column: $table.notificationEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actionsJson => $composableBuilder(
    column: $table.actionsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceSummary => $composableBuilder(
    column: $table.sourceSummary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get evidenceSummary => $composableBuilder(
    column: $table.evidenceSummary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentGoalPlanId => $composableBuilder(
    column: $table.parentGoalPlanId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get suggestionClusterId => $composableBuilder(
    column: $table.suggestionClusterId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelSlug => $composableBuilder(
    column: $table.modelSlug,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelOutputJson => $composableBuilder(
    column: $table.modelOutputJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cancelledAt => $composableBuilder(
    column: $table.cancelledAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dismissedAt => $composableBuilder(
    column: $table.dismissedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SpacesTableFilterComposer get spaceId {
    final $$SpacesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.spaceId,
      referencedTable: $db.spaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SpacesTableFilterComposer(
            $db: $db,
            $table: $db.spaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> cardSourcesRefs(
    Expression<bool> Function($$CardSourcesTableFilterComposer f) f,
  ) {
    final $$CardSourcesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cardSources,
      getReferencedColumn: (t) => t.cardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardSourcesTableFilterComposer(
            $db: $db,
            $table: $db.cardSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> goalPlanCardsRefs(
    Expression<bool> Function($$GoalPlanCardsTableFilterComposer f) f,
  ) {
    final $$GoalPlanCardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.goalPlanCards,
      getReferencedColumn: (t) => t.cardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GoalPlanCardsTableFilterComposer(
            $db: $db,
            $table: $db.goalPlanCards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> feedbackEventsRefs(
    Expression<bool> Function($$FeedbackEventsTableFilterComposer f) f,
  ) {
    final $$FeedbackEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.feedbackEvents,
      getReferencedColumn: (t) => t.cardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FeedbackEventsTableFilterComposer(
            $db: $db,
            $table: $db.feedbackEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> notificationRequestsRefs(
    Expression<bool> Function($$NotificationRequestsTableFilterComposer f) f,
  ) {
    final $$NotificationRequestsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.notificationRequests,
      getReferencedColumn: (t) => t.cardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotificationRequestsTableFilterComposer(
            $db: $db,
            $table: $db.notificationRequests,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> aiProcessingJobsRefs(
    Expression<bool> Function($$AiProcessingJobsTableFilterComposer f) f,
  ) {
    final $$AiProcessingJobsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.aiProcessingJobs,
      getReferencedColumn: (t) => t.cardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AiProcessingJobsTableFilterComposer(
            $db: $db,
            $table: $db.aiProcessingJobs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagCardsTableOrderingComposer
    extends Composer<_$TagDatabase, $TagCardsTable> {
  $$TagCardsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cardType => $composableBuilder(
    column: $table.cardType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nextActiveDeadline => $composableBuilder(
    column: $table.nextActiveDeadline,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deadlineTimezone => $composableBuilder(
    column: $table.deadlineTimezone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get snoozedUntil => $composableBuilder(
    column: $table.snoozedUntil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get notificationEnabled => $composableBuilder(
    column: $table.notificationEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actionsJson => $composableBuilder(
    column: $table.actionsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceSummary => $composableBuilder(
    column: $table.sourceSummary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get evidenceSummary => $composableBuilder(
    column: $table.evidenceSummary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentGoalPlanId => $composableBuilder(
    column: $table.parentGoalPlanId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get suggestionClusterId => $composableBuilder(
    column: $table.suggestionClusterId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelSlug => $composableBuilder(
    column: $table.modelSlug,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelOutputJson => $composableBuilder(
    column: $table.modelOutputJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cancelledAt => $composableBuilder(
    column: $table.cancelledAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dismissedAt => $composableBuilder(
    column: $table.dismissedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SpacesTableOrderingComposer get spaceId {
    final $$SpacesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.spaceId,
      referencedTable: $db.spaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SpacesTableOrderingComposer(
            $db: $db,
            $table: $db.spaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TagCardsTableAnnotationComposer
    extends Composer<_$TagDatabase, $TagCardsTable> {
  $$TagCardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get cardType =>
      $composableBuilder(column: $table.cardType, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<int> get nextActiveDeadline => $composableBuilder(
    column: $table.nextActiveDeadline,
    builder: (column) => column,
  );

  GeneratedColumn<String> get deadlineTimezone => $composableBuilder(
    column: $table.deadlineTimezone,
    builder: (column) => column,
  );

  GeneratedColumn<int> get snoozedUntil => $composableBuilder(
    column: $table.snoozedUntil,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get notificationEnabled => $composableBuilder(
    column: $table.notificationEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<String> get actionsJson => $composableBuilder(
    column: $table.actionsJson,
    builder: (column) => column,
  );

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceSummary => $composableBuilder(
    column: $table.sourceSummary,
    builder: (column) => column,
  );

  GeneratedColumn<String> get evidenceSummary => $composableBuilder(
    column: $table.evidenceSummary,
    builder: (column) => column,
  );

  GeneratedColumn<String> get parentGoalPlanId => $composableBuilder(
    column: $table.parentGoalPlanId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get suggestionClusterId => $composableBuilder(
    column: $table.suggestionClusterId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get modelSlug =>
      $composableBuilder(column: $table.modelSlug, builder: (column) => column);

  GeneratedColumn<String> get modelOutputJson => $composableBuilder(
    column: $table.modelOutputJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cancelledAt => $composableBuilder(
    column: $table.cancelledAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dismissedAt => $composableBuilder(
    column: $table.dismissedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$SpacesTableAnnotationComposer get spaceId {
    final $$SpacesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.spaceId,
      referencedTable: $db.spaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SpacesTableAnnotationComposer(
            $db: $db,
            $table: $db.spaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> cardSourcesRefs<T extends Object>(
    Expression<T> Function($$CardSourcesTableAnnotationComposer a) f,
  ) {
    final $$CardSourcesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cardSources,
      getReferencedColumn: (t) => t.cardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardSourcesTableAnnotationComposer(
            $db: $db,
            $table: $db.cardSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> goalPlanCardsRefs<T extends Object>(
    Expression<T> Function($$GoalPlanCardsTableAnnotationComposer a) f,
  ) {
    final $$GoalPlanCardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.goalPlanCards,
      getReferencedColumn: (t) => t.cardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GoalPlanCardsTableAnnotationComposer(
            $db: $db,
            $table: $db.goalPlanCards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> feedbackEventsRefs<T extends Object>(
    Expression<T> Function($$FeedbackEventsTableAnnotationComposer a) f,
  ) {
    final $$FeedbackEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.feedbackEvents,
      getReferencedColumn: (t) => t.cardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FeedbackEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.feedbackEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> notificationRequestsRefs<T extends Object>(
    Expression<T> Function($$NotificationRequestsTableAnnotationComposer a) f,
  ) {
    final $$NotificationRequestsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.notificationRequests,
          getReferencedColumn: (t) => t.cardId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$NotificationRequestsTableAnnotationComposer(
                $db: $db,
                $table: $db.notificationRequests,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> aiProcessingJobsRefs<T extends Object>(
    Expression<T> Function($$AiProcessingJobsTableAnnotationComposer a) f,
  ) {
    final $$AiProcessingJobsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.aiProcessingJobs,
      getReferencedColumn: (t) => t.cardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AiProcessingJobsTableAnnotationComposer(
            $db: $db,
            $table: $db.aiProcessingJobs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagCardsTableTableManager
    extends
        RootTableManager<
          _$TagDatabase,
          $TagCardsTable,
          TagCard,
          $$TagCardsTableFilterComposer,
          $$TagCardsTableOrderingComposer,
          $$TagCardsTableAnnotationComposer,
          $$TagCardsTableCreateCompanionBuilder,
          $$TagCardsTableUpdateCompanionBuilder,
          (TagCard, $$TagCardsTableReferences),
          TagCard,
          PrefetchHooks Function({
            bool spaceId,
            bool cardSourcesRefs,
            bool goalPlanCardsRefs,
            bool feedbackEventsRefs,
            bool notificationRequestsRefs,
            bool aiProcessingJobsRefs,
          })
        > {
  $$TagCardsTableTableManager(_$TagDatabase db, $TagCardsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagCardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagCardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagCardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> cardType = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> reason = const Value.absent(),
                Value<String> spaceId = const Value.absent(),
                Value<int?> nextActiveDeadline = const Value.absent(),
                Value<String?> deadlineTimezone = const Value.absent(),
                Value<int?> snoozedUntil = const Value.absent(),
                Value<bool> notificationEnabled = const Value.absent(),
                Value<String> actionsJson = const Value.absent(),
                Value<double?> confidence = const Value.absent(),
                Value<String> sourceSummary = const Value.absent(),
                Value<String> evidenceSummary = const Value.absent(),
                Value<String?> parentGoalPlanId = const Value.absent(),
                Value<String?> suggestionClusterId = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<String?> modelSlug = const Value.absent(),
                Value<String?> modelOutputJson = const Value.absent(),
                Value<String> metadataJson = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> completedAt = const Value.absent(),
                Value<int?> cancelledAt = const Value.absent(),
                Value<int?> dismissedAt = const Value.absent(),
                Value<int?> archivedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TagCardsCompanion(
                id: id,
                cardType: cardType,
                status: status,
                title: title,
                reason: reason,
                spaceId: spaceId,
                nextActiveDeadline: nextActiveDeadline,
                deadlineTimezone: deadlineTimezone,
                snoozedUntil: snoozedUntil,
                notificationEnabled: notificationEnabled,
                actionsJson: actionsJson,
                confidence: confidence,
                sourceSummary: sourceSummary,
                evidenceSummary: evidenceSummary,
                parentGoalPlanId: parentGoalPlanId,
                suggestionClusterId: suggestionClusterId,
                createdBy: createdBy,
                modelSlug: modelSlug,
                modelOutputJson: modelOutputJson,
                metadataJson: metadataJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                completedAt: completedAt,
                cancelledAt: cancelledAt,
                dismissedAt: dismissedAt,
                archivedAt: archivedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String cardType,
                Value<String> status = const Value.absent(),
                required String title,
                required String reason,
                required String spaceId,
                Value<int?> nextActiveDeadline = const Value.absent(),
                Value<String?> deadlineTimezone = const Value.absent(),
                Value<int?> snoozedUntil = const Value.absent(),
                Value<bool> notificationEnabled = const Value.absent(),
                Value<String> actionsJson = const Value.absent(),
                Value<double?> confidence = const Value.absent(),
                required String sourceSummary,
                required String evidenceSummary,
                Value<String?> parentGoalPlanId = const Value.absent(),
                Value<String?> suggestionClusterId = const Value.absent(),
                required String createdBy,
                Value<String?> modelSlug = const Value.absent(),
                Value<String?> modelOutputJson = const Value.absent(),
                Value<String> metadataJson = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int?> completedAt = const Value.absent(),
                Value<int?> cancelledAt = const Value.absent(),
                Value<int?> dismissedAt = const Value.absent(),
                Value<int?> archivedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TagCardsCompanion.insert(
                id: id,
                cardType: cardType,
                status: status,
                title: title,
                reason: reason,
                spaceId: spaceId,
                nextActiveDeadline: nextActiveDeadline,
                deadlineTimezone: deadlineTimezone,
                snoozedUntil: snoozedUntil,
                notificationEnabled: notificationEnabled,
                actionsJson: actionsJson,
                confidence: confidence,
                sourceSummary: sourceSummary,
                evidenceSummary: evidenceSummary,
                parentGoalPlanId: parentGoalPlanId,
                suggestionClusterId: suggestionClusterId,
                createdBy: createdBy,
                modelSlug: modelSlug,
                modelOutputJson: modelOutputJson,
                metadataJson: metadataJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                completedAt: completedAt,
                cancelledAt: cancelledAt,
                dismissedAt: dismissedAt,
                archivedAt: archivedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TagCardsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                spaceId = false,
                cardSourcesRefs = false,
                goalPlanCardsRefs = false,
                feedbackEventsRefs = false,
                notificationRequestsRefs = false,
                aiProcessingJobsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (cardSourcesRefs) db.cardSources,
                    if (goalPlanCardsRefs) db.goalPlanCards,
                    if (feedbackEventsRefs) db.feedbackEvents,
                    if (notificationRequestsRefs) db.notificationRequests,
                    if (aiProcessingJobsRefs) db.aiProcessingJobs,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (spaceId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.spaceId,
                                    referencedTable: $$TagCardsTableReferences
                                        ._spaceIdTable(db),
                                    referencedColumn: $$TagCardsTableReferences
                                        ._spaceIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (cardSourcesRefs)
                        await $_getPrefetchedData<
                          TagCard,
                          $TagCardsTable,
                          CardSource
                        >(
                          currentTable: table,
                          referencedTable: $$TagCardsTableReferences
                              ._cardSourcesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TagCardsTableReferences(
                                db,
                                table,
                                p0,
                              ).cardSourcesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.cardId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (goalPlanCardsRefs)
                        await $_getPrefetchedData<
                          TagCard,
                          $TagCardsTable,
                          GoalPlanCard
                        >(
                          currentTable: table,
                          referencedTable: $$TagCardsTableReferences
                              ._goalPlanCardsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TagCardsTableReferences(
                                db,
                                table,
                                p0,
                              ).goalPlanCardsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.cardId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (feedbackEventsRefs)
                        await $_getPrefetchedData<
                          TagCard,
                          $TagCardsTable,
                          FeedbackEvent
                        >(
                          currentTable: table,
                          referencedTable: $$TagCardsTableReferences
                              ._feedbackEventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TagCardsTableReferences(
                                db,
                                table,
                                p0,
                              ).feedbackEventsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.cardId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (notificationRequestsRefs)
                        await $_getPrefetchedData<
                          TagCard,
                          $TagCardsTable,
                          NotificationRequest
                        >(
                          currentTable: table,
                          referencedTable: $$TagCardsTableReferences
                              ._notificationRequestsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TagCardsTableReferences(
                                db,
                                table,
                                p0,
                              ).notificationRequestsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.cardId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (aiProcessingJobsRefs)
                        await $_getPrefetchedData<
                          TagCard,
                          $TagCardsTable,
                          AiProcessingJob
                        >(
                          currentTable: table,
                          referencedTable: $$TagCardsTableReferences
                              ._aiProcessingJobsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TagCardsTableReferences(
                                db,
                                table,
                                p0,
                              ).aiProcessingJobsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.cardId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TagCardsTableProcessedTableManager =
    ProcessedTableManager<
      _$TagDatabase,
      $TagCardsTable,
      TagCard,
      $$TagCardsTableFilterComposer,
      $$TagCardsTableOrderingComposer,
      $$TagCardsTableAnnotationComposer,
      $$TagCardsTableCreateCompanionBuilder,
      $$TagCardsTableUpdateCompanionBuilder,
      (TagCard, $$TagCardsTableReferences),
      TagCard,
      PrefetchHooks Function({
        bool spaceId,
        bool cardSourcesRefs,
        bool goalPlanCardsRefs,
        bool feedbackEventsRefs,
        bool notificationRequestsRefs,
        bool aiProcessingJobsRefs,
      })
    >;
typedef $$CardSourcesTableCreateCompanionBuilder =
    CardSourcesCompanion Function({
      required String cardId,
      required String sourceId,
      required String role,
      Value<String?> evidenceText,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$CardSourcesTableUpdateCompanionBuilder =
    CardSourcesCompanion Function({
      Value<String> cardId,
      Value<String> sourceId,
      Value<String> role,
      Value<String?> evidenceText,
      Value<int> createdAt,
      Value<int> rowid,
    });

final class $$CardSourcesTableReferences
    extends BaseReferences<_$TagDatabase, $CardSourcesTable, CardSource> {
  $$CardSourcesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TagCardsTable _cardIdTable(_$TagDatabase db) => db.tagCards
      .createAlias($_aliasNameGenerator(db.cardSources.cardId, db.tagCards.id));

  $$TagCardsTableProcessedTableManager get cardId {
    final $_column = $_itemColumn<String>('card_id')!;

    final manager = $$TagCardsTableTableManager(
      $_db,
      $_db.tagCards,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cardIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SourceItemsTable _sourceIdTable(_$TagDatabase db) =>
      db.sourceItems.createAlias(
        $_aliasNameGenerator(db.cardSources.sourceId, db.sourceItems.id),
      );

  $$SourceItemsTableProcessedTableManager get sourceId {
    final $_column = $_itemColumn<String>('source_id')!;

    final manager = $$SourceItemsTableTableManager(
      $_db,
      $_db.sourceItems,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CardSourcesTableFilterComposer
    extends Composer<_$TagDatabase, $CardSourcesTable> {
  $$CardSourcesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get evidenceText => $composableBuilder(
    column: $table.evidenceText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$TagCardsTableFilterComposer get cardId {
    final $$TagCardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.tagCards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagCardsTableFilterComposer(
            $db: $db,
            $table: $db.tagCards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SourceItemsTableFilterComposer get sourceId {
    final $$SourceItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.sourceItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourceItemsTableFilterComposer(
            $db: $db,
            $table: $db.sourceItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CardSourcesTableOrderingComposer
    extends Composer<_$TagDatabase, $CardSourcesTable> {
  $$CardSourcesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get evidenceText => $composableBuilder(
    column: $table.evidenceText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$TagCardsTableOrderingComposer get cardId {
    final $$TagCardsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.tagCards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagCardsTableOrderingComposer(
            $db: $db,
            $table: $db.tagCards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SourceItemsTableOrderingComposer get sourceId {
    final $$SourceItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.sourceItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourceItemsTableOrderingComposer(
            $db: $db,
            $table: $db.sourceItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CardSourcesTableAnnotationComposer
    extends Composer<_$TagDatabase, $CardSourcesTable> {
  $$CardSourcesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get evidenceText => $composableBuilder(
    column: $table.evidenceText,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$TagCardsTableAnnotationComposer get cardId {
    final $$TagCardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.tagCards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagCardsTableAnnotationComposer(
            $db: $db,
            $table: $db.tagCards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SourceItemsTableAnnotationComposer get sourceId {
    final $$SourceItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.sourceItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourceItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.sourceItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CardSourcesTableTableManager
    extends
        RootTableManager<
          _$TagDatabase,
          $CardSourcesTable,
          CardSource,
          $$CardSourcesTableFilterComposer,
          $$CardSourcesTableOrderingComposer,
          $$CardSourcesTableAnnotationComposer,
          $$CardSourcesTableCreateCompanionBuilder,
          $$CardSourcesTableUpdateCompanionBuilder,
          (CardSource, $$CardSourcesTableReferences),
          CardSource,
          PrefetchHooks Function({bool cardId, bool sourceId})
        > {
  $$CardSourcesTableTableManager(_$TagDatabase db, $CardSourcesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CardSourcesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CardSourcesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CardSourcesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> cardId = const Value.absent(),
                Value<String> sourceId = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String?> evidenceText = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CardSourcesCompanion(
                cardId: cardId,
                sourceId: sourceId,
                role: role,
                evidenceText: evidenceText,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String cardId,
                required String sourceId,
                required String role,
                Value<String?> evidenceText = const Value.absent(),
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => CardSourcesCompanion.insert(
                cardId: cardId,
                sourceId: sourceId,
                role: role,
                evidenceText: evidenceText,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CardSourcesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({cardId = false, sourceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (cardId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.cardId,
                                referencedTable: $$CardSourcesTableReferences
                                    ._cardIdTable(db),
                                referencedColumn: $$CardSourcesTableReferences
                                    ._cardIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (sourceId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sourceId,
                                referencedTable: $$CardSourcesTableReferences
                                    ._sourceIdTable(db),
                                referencedColumn: $$CardSourcesTableReferences
                                    ._sourceIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CardSourcesTableProcessedTableManager =
    ProcessedTableManager<
      _$TagDatabase,
      $CardSourcesTable,
      CardSource,
      $$CardSourcesTableFilterComposer,
      $$CardSourcesTableOrderingComposer,
      $$CardSourcesTableAnnotationComposer,
      $$CardSourcesTableCreateCompanionBuilder,
      $$CardSourcesTableUpdateCompanionBuilder,
      (CardSource, $$CardSourcesTableReferences),
      CardSource,
      PrefetchHooks Function({bool cardId, bool sourceId})
    >;
typedef $$GoalPlansTableCreateCompanionBuilder =
    GoalPlansCompanion Function({
      required String id,
      required String spaceId,
      Value<String?> originCardId,
      Value<String?> chatSessionId,
      required String name,
      Value<String?> description,
      Value<int?> durationWeeks,
      Value<String> preferredDaysJson,
      Value<int?> sessionLengthMinutes,
      Value<String> reminderPreferenceJson,
      required String status,
      required String createdBy,
      Value<String?> modelSlug,
      Value<String?> planPreviewJson,
      required int createdAt,
      required int updatedAt,
      Value<int?> completedAt,
      Value<int?> cancelledAt,
      Value<int> rowid,
    });
typedef $$GoalPlansTableUpdateCompanionBuilder =
    GoalPlansCompanion Function({
      Value<String> id,
      Value<String> spaceId,
      Value<String?> originCardId,
      Value<String?> chatSessionId,
      Value<String> name,
      Value<String?> description,
      Value<int?> durationWeeks,
      Value<String> preferredDaysJson,
      Value<int?> sessionLengthMinutes,
      Value<String> reminderPreferenceJson,
      Value<String> status,
      Value<String> createdBy,
      Value<String?> modelSlug,
      Value<String?> planPreviewJson,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> completedAt,
      Value<int?> cancelledAt,
      Value<int> rowid,
    });

final class $$GoalPlansTableReferences
    extends BaseReferences<_$TagDatabase, $GoalPlansTable, GoalPlan> {
  $$GoalPlansTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SpacesTable _spaceIdTable(_$TagDatabase db) => db.spaces.createAlias(
    $_aliasNameGenerator(db.goalPlans.spaceId, db.spaces.id),
  );

  $$SpacesTableProcessedTableManager get spaceId {
    final $_column = $_itemColumn<String>('space_id')!;

    final manager = $$SpacesTableTableManager(
      $_db,
      $_db.spaces,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_spaceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$GoalPlanCardsTable, List<GoalPlanCard>>
  _goalPlanCardsRefsTable(_$TagDatabase db) => MultiTypedResultKey.fromTable(
    db.goalPlanCards,
    aliasName: $_aliasNameGenerator(
      db.goalPlans.id,
      db.goalPlanCards.goalPlanId,
    ),
  );

  $$GoalPlanCardsTableProcessedTableManager get goalPlanCardsRefs {
    final manager = $$GoalPlanCardsTableTableManager(
      $_db,
      $_db.goalPlanCards,
    ).filter((f) => f.goalPlanId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_goalPlanCardsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$GoalPlansTableFilterComposer
    extends Composer<_$TagDatabase, $GoalPlansTable> {
  $$GoalPlansTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originCardId => $composableBuilder(
    column: $table.originCardId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chatSessionId => $composableBuilder(
    column: $table.chatSessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationWeeks => $composableBuilder(
    column: $table.durationWeeks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get preferredDaysJson => $composableBuilder(
    column: $table.preferredDaysJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sessionLengthMinutes => $composableBuilder(
    column: $table.sessionLengthMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reminderPreferenceJson => $composableBuilder(
    column: $table.reminderPreferenceJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelSlug => $composableBuilder(
    column: $table.modelSlug,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get planPreviewJson => $composableBuilder(
    column: $table.planPreviewJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cancelledAt => $composableBuilder(
    column: $table.cancelledAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SpacesTableFilterComposer get spaceId {
    final $$SpacesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.spaceId,
      referencedTable: $db.spaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SpacesTableFilterComposer(
            $db: $db,
            $table: $db.spaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> goalPlanCardsRefs(
    Expression<bool> Function($$GoalPlanCardsTableFilterComposer f) f,
  ) {
    final $$GoalPlanCardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.goalPlanCards,
      getReferencedColumn: (t) => t.goalPlanId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GoalPlanCardsTableFilterComposer(
            $db: $db,
            $table: $db.goalPlanCards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GoalPlansTableOrderingComposer
    extends Composer<_$TagDatabase, $GoalPlansTable> {
  $$GoalPlansTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originCardId => $composableBuilder(
    column: $table.originCardId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chatSessionId => $composableBuilder(
    column: $table.chatSessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationWeeks => $composableBuilder(
    column: $table.durationWeeks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get preferredDaysJson => $composableBuilder(
    column: $table.preferredDaysJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sessionLengthMinutes => $composableBuilder(
    column: $table.sessionLengthMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reminderPreferenceJson => $composableBuilder(
    column: $table.reminderPreferenceJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelSlug => $composableBuilder(
    column: $table.modelSlug,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get planPreviewJson => $composableBuilder(
    column: $table.planPreviewJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cancelledAt => $composableBuilder(
    column: $table.cancelledAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SpacesTableOrderingComposer get spaceId {
    final $$SpacesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.spaceId,
      referencedTable: $db.spaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SpacesTableOrderingComposer(
            $db: $db,
            $table: $db.spaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GoalPlansTableAnnotationComposer
    extends Composer<_$TagDatabase, $GoalPlansTable> {
  $$GoalPlansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get originCardId => $composableBuilder(
    column: $table.originCardId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get chatSessionId => $composableBuilder(
    column: $table.chatSessionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationWeeks => $composableBuilder(
    column: $table.durationWeeks,
    builder: (column) => column,
  );

  GeneratedColumn<String> get preferredDaysJson => $composableBuilder(
    column: $table.preferredDaysJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sessionLengthMinutes => $composableBuilder(
    column: $table.sessionLengthMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reminderPreferenceJson => $composableBuilder(
    column: $table.reminderPreferenceJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get modelSlug =>
      $composableBuilder(column: $table.modelSlug, builder: (column) => column);

  GeneratedColumn<String> get planPreviewJson => $composableBuilder(
    column: $table.planPreviewJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cancelledAt => $composableBuilder(
    column: $table.cancelledAt,
    builder: (column) => column,
  );

  $$SpacesTableAnnotationComposer get spaceId {
    final $$SpacesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.spaceId,
      referencedTable: $db.spaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SpacesTableAnnotationComposer(
            $db: $db,
            $table: $db.spaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> goalPlanCardsRefs<T extends Object>(
    Expression<T> Function($$GoalPlanCardsTableAnnotationComposer a) f,
  ) {
    final $$GoalPlanCardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.goalPlanCards,
      getReferencedColumn: (t) => t.goalPlanId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GoalPlanCardsTableAnnotationComposer(
            $db: $db,
            $table: $db.goalPlanCards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GoalPlansTableTableManager
    extends
        RootTableManager<
          _$TagDatabase,
          $GoalPlansTable,
          GoalPlan,
          $$GoalPlansTableFilterComposer,
          $$GoalPlansTableOrderingComposer,
          $$GoalPlansTableAnnotationComposer,
          $$GoalPlansTableCreateCompanionBuilder,
          $$GoalPlansTableUpdateCompanionBuilder,
          (GoalPlan, $$GoalPlansTableReferences),
          GoalPlan,
          PrefetchHooks Function({bool spaceId, bool goalPlanCardsRefs})
        > {
  $$GoalPlansTableTableManager(_$TagDatabase db, $GoalPlansTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GoalPlansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GoalPlansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GoalPlansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> spaceId = const Value.absent(),
                Value<String?> originCardId = const Value.absent(),
                Value<String?> chatSessionId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int?> durationWeeks = const Value.absent(),
                Value<String> preferredDaysJson = const Value.absent(),
                Value<int?> sessionLengthMinutes = const Value.absent(),
                Value<String> reminderPreferenceJson = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<String?> modelSlug = const Value.absent(),
                Value<String?> planPreviewJson = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> completedAt = const Value.absent(),
                Value<int?> cancelledAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GoalPlansCompanion(
                id: id,
                spaceId: spaceId,
                originCardId: originCardId,
                chatSessionId: chatSessionId,
                name: name,
                description: description,
                durationWeeks: durationWeeks,
                preferredDaysJson: preferredDaysJson,
                sessionLengthMinutes: sessionLengthMinutes,
                reminderPreferenceJson: reminderPreferenceJson,
                status: status,
                createdBy: createdBy,
                modelSlug: modelSlug,
                planPreviewJson: planPreviewJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                completedAt: completedAt,
                cancelledAt: cancelledAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String spaceId,
                Value<String?> originCardId = const Value.absent(),
                Value<String?> chatSessionId = const Value.absent(),
                required String name,
                Value<String?> description = const Value.absent(),
                Value<int?> durationWeeks = const Value.absent(),
                Value<String> preferredDaysJson = const Value.absent(),
                Value<int?> sessionLengthMinutes = const Value.absent(),
                Value<String> reminderPreferenceJson = const Value.absent(),
                required String status,
                required String createdBy,
                Value<String?> modelSlug = const Value.absent(),
                Value<String?> planPreviewJson = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int?> completedAt = const Value.absent(),
                Value<int?> cancelledAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GoalPlansCompanion.insert(
                id: id,
                spaceId: spaceId,
                originCardId: originCardId,
                chatSessionId: chatSessionId,
                name: name,
                description: description,
                durationWeeks: durationWeeks,
                preferredDaysJson: preferredDaysJson,
                sessionLengthMinutes: sessionLengthMinutes,
                reminderPreferenceJson: reminderPreferenceJson,
                status: status,
                createdBy: createdBy,
                modelSlug: modelSlug,
                planPreviewJson: planPreviewJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                completedAt: completedAt,
                cancelledAt: cancelledAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$GoalPlansTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({spaceId = false, goalPlanCardsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (goalPlanCardsRefs) db.goalPlanCards,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (spaceId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.spaceId,
                                    referencedTable: $$GoalPlansTableReferences
                                        ._spaceIdTable(db),
                                    referencedColumn: $$GoalPlansTableReferences
                                        ._spaceIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (goalPlanCardsRefs)
                        await $_getPrefetchedData<
                          GoalPlan,
                          $GoalPlansTable,
                          GoalPlanCard
                        >(
                          currentTable: table,
                          referencedTable: $$GoalPlansTableReferences
                              ._goalPlanCardsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GoalPlansTableReferences(
                                db,
                                table,
                                p0,
                              ).goalPlanCardsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.goalPlanId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$GoalPlansTableProcessedTableManager =
    ProcessedTableManager<
      _$TagDatabase,
      $GoalPlansTable,
      GoalPlan,
      $$GoalPlansTableFilterComposer,
      $$GoalPlansTableOrderingComposer,
      $$GoalPlansTableAnnotationComposer,
      $$GoalPlansTableCreateCompanionBuilder,
      $$GoalPlansTableUpdateCompanionBuilder,
      (GoalPlan, $$GoalPlansTableReferences),
      GoalPlan,
      PrefetchHooks Function({bool spaceId, bool goalPlanCardsRefs})
    >;
typedef $$GoalPlanCardsTableCreateCompanionBuilder =
    GoalPlanCardsCompanion Function({
      required String goalPlanId,
      required String cardId,
      required int sequenceIndex,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$GoalPlanCardsTableUpdateCompanionBuilder =
    GoalPlanCardsCompanion Function({
      Value<String> goalPlanId,
      Value<String> cardId,
      Value<int> sequenceIndex,
      Value<int> createdAt,
      Value<int> rowid,
    });

final class $$GoalPlanCardsTableReferences
    extends BaseReferences<_$TagDatabase, $GoalPlanCardsTable, GoalPlanCard> {
  $$GoalPlanCardsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $GoalPlansTable _goalPlanIdTable(_$TagDatabase db) =>
      db.goalPlans.createAlias(
        $_aliasNameGenerator(db.goalPlanCards.goalPlanId, db.goalPlans.id),
      );

  $$GoalPlansTableProcessedTableManager get goalPlanId {
    final $_column = $_itemColumn<String>('goal_plan_id')!;

    final manager = $$GoalPlansTableTableManager(
      $_db,
      $_db.goalPlans,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_goalPlanIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TagCardsTable _cardIdTable(_$TagDatabase db) =>
      db.tagCards.createAlias(
        $_aliasNameGenerator(db.goalPlanCards.cardId, db.tagCards.id),
      );

  $$TagCardsTableProcessedTableManager get cardId {
    final $_column = $_itemColumn<String>('card_id')!;

    final manager = $$TagCardsTableTableManager(
      $_db,
      $_db.tagCards,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cardIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$GoalPlanCardsTableFilterComposer
    extends Composer<_$TagDatabase, $GoalPlanCardsTable> {
  $$GoalPlanCardsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get sequenceIndex => $composableBuilder(
    column: $table.sequenceIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$GoalPlansTableFilterComposer get goalPlanId {
    final $$GoalPlansTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.goalPlanId,
      referencedTable: $db.goalPlans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GoalPlansTableFilterComposer(
            $db: $db,
            $table: $db.goalPlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagCardsTableFilterComposer get cardId {
    final $$TagCardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.tagCards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagCardsTableFilterComposer(
            $db: $db,
            $table: $db.tagCards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GoalPlanCardsTableOrderingComposer
    extends Composer<_$TagDatabase, $GoalPlanCardsTable> {
  $$GoalPlanCardsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get sequenceIndex => $composableBuilder(
    column: $table.sequenceIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$GoalPlansTableOrderingComposer get goalPlanId {
    final $$GoalPlansTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.goalPlanId,
      referencedTable: $db.goalPlans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GoalPlansTableOrderingComposer(
            $db: $db,
            $table: $db.goalPlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagCardsTableOrderingComposer get cardId {
    final $$TagCardsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.tagCards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagCardsTableOrderingComposer(
            $db: $db,
            $table: $db.tagCards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GoalPlanCardsTableAnnotationComposer
    extends Composer<_$TagDatabase, $GoalPlanCardsTable> {
  $$GoalPlanCardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get sequenceIndex => $composableBuilder(
    column: $table.sequenceIndex,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$GoalPlansTableAnnotationComposer get goalPlanId {
    final $$GoalPlansTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.goalPlanId,
      referencedTable: $db.goalPlans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GoalPlansTableAnnotationComposer(
            $db: $db,
            $table: $db.goalPlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagCardsTableAnnotationComposer get cardId {
    final $$TagCardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.tagCards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagCardsTableAnnotationComposer(
            $db: $db,
            $table: $db.tagCards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GoalPlanCardsTableTableManager
    extends
        RootTableManager<
          _$TagDatabase,
          $GoalPlanCardsTable,
          GoalPlanCard,
          $$GoalPlanCardsTableFilterComposer,
          $$GoalPlanCardsTableOrderingComposer,
          $$GoalPlanCardsTableAnnotationComposer,
          $$GoalPlanCardsTableCreateCompanionBuilder,
          $$GoalPlanCardsTableUpdateCompanionBuilder,
          (GoalPlanCard, $$GoalPlanCardsTableReferences),
          GoalPlanCard,
          PrefetchHooks Function({bool goalPlanId, bool cardId})
        > {
  $$GoalPlanCardsTableTableManager(_$TagDatabase db, $GoalPlanCardsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GoalPlanCardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GoalPlanCardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GoalPlanCardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> goalPlanId = const Value.absent(),
                Value<String> cardId = const Value.absent(),
                Value<int> sequenceIndex = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GoalPlanCardsCompanion(
                goalPlanId: goalPlanId,
                cardId: cardId,
                sequenceIndex: sequenceIndex,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String goalPlanId,
                required String cardId,
                required int sequenceIndex,
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => GoalPlanCardsCompanion.insert(
                goalPlanId: goalPlanId,
                cardId: cardId,
                sequenceIndex: sequenceIndex,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$GoalPlanCardsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({goalPlanId = false, cardId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (goalPlanId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.goalPlanId,
                                referencedTable: $$GoalPlanCardsTableReferences
                                    ._goalPlanIdTable(db),
                                referencedColumn: $$GoalPlanCardsTableReferences
                                    ._goalPlanIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (cardId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.cardId,
                                referencedTable: $$GoalPlanCardsTableReferences
                                    ._cardIdTable(db),
                                referencedColumn: $$GoalPlanCardsTableReferences
                                    ._cardIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$GoalPlanCardsTableProcessedTableManager =
    ProcessedTableManager<
      _$TagDatabase,
      $GoalPlanCardsTable,
      GoalPlanCard,
      $$GoalPlanCardsTableFilterComposer,
      $$GoalPlanCardsTableOrderingComposer,
      $$GoalPlanCardsTableAnnotationComposer,
      $$GoalPlanCardsTableCreateCompanionBuilder,
      $$GoalPlanCardsTableUpdateCompanionBuilder,
      (GoalPlanCard, $$GoalPlanCardsTableReferences),
      GoalPlanCard,
      PrefetchHooks Function({bool goalPlanId, bool cardId})
    >;
typedef $$ChatSessionsTableCreateCompanionBuilder =
    ChatSessionsCompanion Function({
      required String id,
      required String title,
      required String purpose,
      Value<String?> linkedCardId,
      Value<String?> linkedSpaceId,
      Value<String?> linkedGoalPlanId,
      required String status,
      Value<String?> pendingConfirmationJson,
      required int createdAt,
      required int updatedAt,
      Value<int?> archivedAt,
      Value<int> rowid,
    });
typedef $$ChatSessionsTableUpdateCompanionBuilder =
    ChatSessionsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> purpose,
      Value<String?> linkedCardId,
      Value<String?> linkedSpaceId,
      Value<String?> linkedGoalPlanId,
      Value<String> status,
      Value<String?> pendingConfirmationJson,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> archivedAt,
      Value<int> rowid,
    });

final class $$ChatSessionsTableReferences
    extends BaseReferences<_$TagDatabase, $ChatSessionsTable, ChatSession> {
  $$ChatSessionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SpacesTable _linkedSpaceIdTable(_$TagDatabase db) =>
      db.spaces.createAlias(
        $_aliasNameGenerator(db.chatSessions.linkedSpaceId, db.spaces.id),
      );

  $$SpacesTableProcessedTableManager? get linkedSpaceId {
    final $_column = $_itemColumn<String>('linked_space_id');
    if ($_column == null) return null;
    final manager = $$SpacesTableTableManager(
      $_db,
      $_db.spaces,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_linkedSpaceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ChatMessagesTable, List<ChatMessage>>
  _chatMessagesRefsTable(_$TagDatabase db) => MultiTypedResultKey.fromTable(
    db.chatMessages,
    aliasName: $_aliasNameGenerator(
      db.chatSessions.id,
      db.chatMessages.chatSessionId,
    ),
  );

  $$ChatMessagesTableProcessedTableManager get chatMessagesRefs {
    final manager = $$ChatMessagesTableTableManager(
      $_db,
      $_db.chatMessages,
    ).filter((f) => f.chatSessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_chatMessagesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AiProcessingJobsTable, List<AiProcessingJob>>
  _aiProcessingJobsRefsTable(_$TagDatabase db) => MultiTypedResultKey.fromTable(
    db.aiProcessingJobs,
    aliasName: $_aliasNameGenerator(
      db.chatSessions.id,
      db.aiProcessingJobs.chatSessionId,
    ),
  );

  $$AiProcessingJobsTableProcessedTableManager get aiProcessingJobsRefs {
    final manager = $$AiProcessingJobsTableTableManager(
      $_db,
      $_db.aiProcessingJobs,
    ).filter((f) => f.chatSessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _aiProcessingJobsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ChatSessionsTableFilterComposer
    extends Composer<_$TagDatabase, $ChatSessionsTable> {
  $$ChatSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get purpose => $composableBuilder(
    column: $table.purpose,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get linkedCardId => $composableBuilder(
    column: $table.linkedCardId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get linkedGoalPlanId => $composableBuilder(
    column: $table.linkedGoalPlanId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pendingConfirmationJson => $composableBuilder(
    column: $table.pendingConfirmationJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SpacesTableFilterComposer get linkedSpaceId {
    final $$SpacesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.linkedSpaceId,
      referencedTable: $db.spaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SpacesTableFilterComposer(
            $db: $db,
            $table: $db.spaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> chatMessagesRefs(
    Expression<bool> Function($$ChatMessagesTableFilterComposer f) f,
  ) {
    final $$ChatMessagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chatMessages,
      getReferencedColumn: (t) => t.chatSessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatMessagesTableFilterComposer(
            $db: $db,
            $table: $db.chatMessages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> aiProcessingJobsRefs(
    Expression<bool> Function($$AiProcessingJobsTableFilterComposer f) f,
  ) {
    final $$AiProcessingJobsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.aiProcessingJobs,
      getReferencedColumn: (t) => t.chatSessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AiProcessingJobsTableFilterComposer(
            $db: $db,
            $table: $db.aiProcessingJobs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ChatSessionsTableOrderingComposer
    extends Composer<_$TagDatabase, $ChatSessionsTable> {
  $$ChatSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get purpose => $composableBuilder(
    column: $table.purpose,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get linkedCardId => $composableBuilder(
    column: $table.linkedCardId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get linkedGoalPlanId => $composableBuilder(
    column: $table.linkedGoalPlanId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pendingConfirmationJson => $composableBuilder(
    column: $table.pendingConfirmationJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SpacesTableOrderingComposer get linkedSpaceId {
    final $$SpacesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.linkedSpaceId,
      referencedTable: $db.spaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SpacesTableOrderingComposer(
            $db: $db,
            $table: $db.spaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChatSessionsTableAnnotationComposer
    extends Composer<_$TagDatabase, $ChatSessionsTable> {
  $$ChatSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get purpose =>
      $composableBuilder(column: $table.purpose, builder: (column) => column);

  GeneratedColumn<String> get linkedCardId => $composableBuilder(
    column: $table.linkedCardId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get linkedGoalPlanId => $composableBuilder(
    column: $table.linkedGoalPlanId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get pendingConfirmationJson => $composableBuilder(
    column: $table.pendingConfirmationJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => column,
  );

  $$SpacesTableAnnotationComposer get linkedSpaceId {
    final $$SpacesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.linkedSpaceId,
      referencedTable: $db.spaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SpacesTableAnnotationComposer(
            $db: $db,
            $table: $db.spaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> chatMessagesRefs<T extends Object>(
    Expression<T> Function($$ChatMessagesTableAnnotationComposer a) f,
  ) {
    final $$ChatMessagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chatMessages,
      getReferencedColumn: (t) => t.chatSessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatMessagesTableAnnotationComposer(
            $db: $db,
            $table: $db.chatMessages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> aiProcessingJobsRefs<T extends Object>(
    Expression<T> Function($$AiProcessingJobsTableAnnotationComposer a) f,
  ) {
    final $$AiProcessingJobsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.aiProcessingJobs,
      getReferencedColumn: (t) => t.chatSessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AiProcessingJobsTableAnnotationComposer(
            $db: $db,
            $table: $db.aiProcessingJobs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ChatSessionsTableTableManager
    extends
        RootTableManager<
          _$TagDatabase,
          $ChatSessionsTable,
          ChatSession,
          $$ChatSessionsTableFilterComposer,
          $$ChatSessionsTableOrderingComposer,
          $$ChatSessionsTableAnnotationComposer,
          $$ChatSessionsTableCreateCompanionBuilder,
          $$ChatSessionsTableUpdateCompanionBuilder,
          (ChatSession, $$ChatSessionsTableReferences),
          ChatSession,
          PrefetchHooks Function({
            bool linkedSpaceId,
            bool chatMessagesRefs,
            bool aiProcessingJobsRefs,
          })
        > {
  $$ChatSessionsTableTableManager(_$TagDatabase db, $ChatSessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> purpose = const Value.absent(),
                Value<String?> linkedCardId = const Value.absent(),
                Value<String?> linkedSpaceId = const Value.absent(),
                Value<String?> linkedGoalPlanId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> pendingConfirmationJson = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChatSessionsCompanion(
                id: id,
                title: title,
                purpose: purpose,
                linkedCardId: linkedCardId,
                linkedSpaceId: linkedSpaceId,
                linkedGoalPlanId: linkedGoalPlanId,
                status: status,
                pendingConfirmationJson: pendingConfirmationJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String purpose,
                Value<String?> linkedCardId = const Value.absent(),
                Value<String?> linkedSpaceId = const Value.absent(),
                Value<String?> linkedGoalPlanId = const Value.absent(),
                required String status,
                Value<String?> pendingConfirmationJson = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int?> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChatSessionsCompanion.insert(
                id: id,
                title: title,
                purpose: purpose,
                linkedCardId: linkedCardId,
                linkedSpaceId: linkedSpaceId,
                linkedGoalPlanId: linkedGoalPlanId,
                status: status,
                pendingConfirmationJson: pendingConfirmationJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ChatSessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                linkedSpaceId = false,
                chatMessagesRefs = false,
                aiProcessingJobsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (chatMessagesRefs) db.chatMessages,
                    if (aiProcessingJobsRefs) db.aiProcessingJobs,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (linkedSpaceId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.linkedSpaceId,
                                    referencedTable:
                                        $$ChatSessionsTableReferences
                                            ._linkedSpaceIdTable(db),
                                    referencedColumn:
                                        $$ChatSessionsTableReferences
                                            ._linkedSpaceIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (chatMessagesRefs)
                        await $_getPrefetchedData<
                          ChatSession,
                          $ChatSessionsTable,
                          ChatMessage
                        >(
                          currentTable: table,
                          referencedTable: $$ChatSessionsTableReferences
                              ._chatMessagesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ChatSessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).chatMessagesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.chatSessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (aiProcessingJobsRefs)
                        await $_getPrefetchedData<
                          ChatSession,
                          $ChatSessionsTable,
                          AiProcessingJob
                        >(
                          currentTable: table,
                          referencedTable: $$ChatSessionsTableReferences
                              ._aiProcessingJobsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ChatSessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).aiProcessingJobsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.chatSessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ChatSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$TagDatabase,
      $ChatSessionsTable,
      ChatSession,
      $$ChatSessionsTableFilterComposer,
      $$ChatSessionsTableOrderingComposer,
      $$ChatSessionsTableAnnotationComposer,
      $$ChatSessionsTableCreateCompanionBuilder,
      $$ChatSessionsTableUpdateCompanionBuilder,
      (ChatSession, $$ChatSessionsTableReferences),
      ChatSession,
      PrefetchHooks Function({
        bool linkedSpaceId,
        bool chatMessagesRefs,
        bool aiProcessingJobsRefs,
      })
    >;
typedef $$ChatMessagesTableCreateCompanionBuilder =
    ChatMessagesCompanion Function({
      required String id,
      required String chatSessionId,
      required String role,
      required String content,
      Value<String?> contentJson,
      Value<String?> toolCallsJson,
      Value<String> sourceIdsJson,
      Value<String> cardIdsJson,
      Value<String?> modelSlug,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$ChatMessagesTableUpdateCompanionBuilder =
    ChatMessagesCompanion Function({
      Value<String> id,
      Value<String> chatSessionId,
      Value<String> role,
      Value<String> content,
      Value<String?> contentJson,
      Value<String?> toolCallsJson,
      Value<String> sourceIdsJson,
      Value<String> cardIdsJson,
      Value<String?> modelSlug,
      Value<int> createdAt,
      Value<int> rowid,
    });

final class $$ChatMessagesTableReferences
    extends BaseReferences<_$TagDatabase, $ChatMessagesTable, ChatMessage> {
  $$ChatMessagesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ChatSessionsTable _chatSessionIdTable(_$TagDatabase db) =>
      db.chatSessions.createAlias(
        $_aliasNameGenerator(db.chatMessages.chatSessionId, db.chatSessions.id),
      );

  $$ChatSessionsTableProcessedTableManager get chatSessionId {
    final $_column = $_itemColumn<String>('chat_session_id')!;

    final manager = $$ChatSessionsTableTableManager(
      $_db,
      $_db.chatSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_chatSessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ChatMessagesTableFilterComposer
    extends Composer<_$TagDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentJson => $composableBuilder(
    column: $table.contentJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toolCallsJson => $composableBuilder(
    column: $table.toolCallsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceIdsJson => $composableBuilder(
    column: $table.sourceIdsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cardIdsJson => $composableBuilder(
    column: $table.cardIdsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelSlug => $composableBuilder(
    column: $table.modelSlug,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ChatSessionsTableFilterComposer get chatSessionId {
    final $$ChatSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chatSessionId,
      referencedTable: $db.chatSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatSessionsTableFilterComposer(
            $db: $db,
            $table: $db.chatSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChatMessagesTableOrderingComposer
    extends Composer<_$TagDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentJson => $composableBuilder(
    column: $table.contentJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toolCallsJson => $composableBuilder(
    column: $table.toolCallsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceIdsJson => $composableBuilder(
    column: $table.sourceIdsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cardIdsJson => $composableBuilder(
    column: $table.cardIdsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelSlug => $composableBuilder(
    column: $table.modelSlug,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ChatSessionsTableOrderingComposer get chatSessionId {
    final $$ChatSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chatSessionId,
      referencedTable: $db.chatSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.chatSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChatMessagesTableAnnotationComposer
    extends Composer<_$TagDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get contentJson => $composableBuilder(
    column: $table.contentJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get toolCallsJson => $composableBuilder(
    column: $table.toolCallsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceIdsJson => $composableBuilder(
    column: $table.sourceIdsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cardIdsJson => $composableBuilder(
    column: $table.cardIdsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get modelSlug =>
      $composableBuilder(column: $table.modelSlug, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ChatSessionsTableAnnotationComposer get chatSessionId {
    final $$ChatSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chatSessionId,
      referencedTable: $db.chatSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.chatSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChatMessagesTableTableManager
    extends
        RootTableManager<
          _$TagDatabase,
          $ChatMessagesTable,
          ChatMessage,
          $$ChatMessagesTableFilterComposer,
          $$ChatMessagesTableOrderingComposer,
          $$ChatMessagesTableAnnotationComposer,
          $$ChatMessagesTableCreateCompanionBuilder,
          $$ChatMessagesTableUpdateCompanionBuilder,
          (ChatMessage, $$ChatMessagesTableReferences),
          ChatMessage,
          PrefetchHooks Function({bool chatSessionId})
        > {
  $$ChatMessagesTableTableManager(_$TagDatabase db, $ChatMessagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatMessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatMessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> chatSessionId = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String?> contentJson = const Value.absent(),
                Value<String?> toolCallsJson = const Value.absent(),
                Value<String> sourceIdsJson = const Value.absent(),
                Value<String> cardIdsJson = const Value.absent(),
                Value<String?> modelSlug = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChatMessagesCompanion(
                id: id,
                chatSessionId: chatSessionId,
                role: role,
                content: content,
                contentJson: contentJson,
                toolCallsJson: toolCallsJson,
                sourceIdsJson: sourceIdsJson,
                cardIdsJson: cardIdsJson,
                modelSlug: modelSlug,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String chatSessionId,
                required String role,
                required String content,
                Value<String?> contentJson = const Value.absent(),
                Value<String?> toolCallsJson = const Value.absent(),
                Value<String> sourceIdsJson = const Value.absent(),
                Value<String> cardIdsJson = const Value.absent(),
                Value<String?> modelSlug = const Value.absent(),
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ChatMessagesCompanion.insert(
                id: id,
                chatSessionId: chatSessionId,
                role: role,
                content: content,
                contentJson: contentJson,
                toolCallsJson: toolCallsJson,
                sourceIdsJson: sourceIdsJson,
                cardIdsJson: cardIdsJson,
                modelSlug: modelSlug,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ChatMessagesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({chatSessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (chatSessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.chatSessionId,
                                referencedTable: $$ChatMessagesTableReferences
                                    ._chatSessionIdTable(db),
                                referencedColumn: $$ChatMessagesTableReferences
                                    ._chatSessionIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ChatMessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$TagDatabase,
      $ChatMessagesTable,
      ChatMessage,
      $$ChatMessagesTableFilterComposer,
      $$ChatMessagesTableOrderingComposer,
      $$ChatMessagesTableAnnotationComposer,
      $$ChatMessagesTableCreateCompanionBuilder,
      $$ChatMessagesTableUpdateCompanionBuilder,
      (ChatMessage, $$ChatMessagesTableReferences),
      ChatMessage,
      PrefetchHooks Function({bool chatSessionId})
    >;
typedef $$FeedbackEventsTableCreateCompanionBuilder =
    FeedbackEventsCompanion Function({
      required String id,
      required String eventType,
      Value<String?> cardId,
      Value<String?> spaceId,
      Value<String?> sourceId,
      Value<String?> goalPlanId,
      Value<String> detailsJson,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$FeedbackEventsTableUpdateCompanionBuilder =
    FeedbackEventsCompanion Function({
      Value<String> id,
      Value<String> eventType,
      Value<String?> cardId,
      Value<String?> spaceId,
      Value<String?> sourceId,
      Value<String?> goalPlanId,
      Value<String> detailsJson,
      Value<int> createdAt,
      Value<int> rowid,
    });

final class $$FeedbackEventsTableReferences
    extends BaseReferences<_$TagDatabase, $FeedbackEventsTable, FeedbackEvent> {
  $$FeedbackEventsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TagCardsTable _cardIdTable(_$TagDatabase db) =>
      db.tagCards.createAlias(
        $_aliasNameGenerator(db.feedbackEvents.cardId, db.tagCards.id),
      );

  $$TagCardsTableProcessedTableManager? get cardId {
    final $_column = $_itemColumn<String>('card_id');
    if ($_column == null) return null;
    final manager = $$TagCardsTableTableManager(
      $_db,
      $_db.tagCards,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cardIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SpacesTable _spaceIdTable(_$TagDatabase db) => db.spaces.createAlias(
    $_aliasNameGenerator(db.feedbackEvents.spaceId, db.spaces.id),
  );

  $$SpacesTableProcessedTableManager? get spaceId {
    final $_column = $_itemColumn<String>('space_id');
    if ($_column == null) return null;
    final manager = $$SpacesTableTableManager(
      $_db,
      $_db.spaces,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_spaceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SourceItemsTable _sourceIdTable(_$TagDatabase db) =>
      db.sourceItems.createAlias(
        $_aliasNameGenerator(db.feedbackEvents.sourceId, db.sourceItems.id),
      );

  $$SourceItemsTableProcessedTableManager? get sourceId {
    final $_column = $_itemColumn<String>('source_id');
    if ($_column == null) return null;
    final manager = $$SourceItemsTableTableManager(
      $_db,
      $_db.sourceItems,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$FeedbackEventsTableFilterComposer
    extends Composer<_$TagDatabase, $FeedbackEventsTable> {
  $$FeedbackEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get goalPlanId => $composableBuilder(
    column: $table.goalPlanId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get detailsJson => $composableBuilder(
    column: $table.detailsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$TagCardsTableFilterComposer get cardId {
    final $$TagCardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.tagCards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagCardsTableFilterComposer(
            $db: $db,
            $table: $db.tagCards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SpacesTableFilterComposer get spaceId {
    final $$SpacesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.spaceId,
      referencedTable: $db.spaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SpacesTableFilterComposer(
            $db: $db,
            $table: $db.spaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SourceItemsTableFilterComposer get sourceId {
    final $$SourceItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.sourceItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourceItemsTableFilterComposer(
            $db: $db,
            $table: $db.sourceItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FeedbackEventsTableOrderingComposer
    extends Composer<_$TagDatabase, $FeedbackEventsTable> {
  $$FeedbackEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get goalPlanId => $composableBuilder(
    column: $table.goalPlanId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get detailsJson => $composableBuilder(
    column: $table.detailsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$TagCardsTableOrderingComposer get cardId {
    final $$TagCardsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.tagCards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagCardsTableOrderingComposer(
            $db: $db,
            $table: $db.tagCards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SpacesTableOrderingComposer get spaceId {
    final $$SpacesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.spaceId,
      referencedTable: $db.spaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SpacesTableOrderingComposer(
            $db: $db,
            $table: $db.spaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SourceItemsTableOrderingComposer get sourceId {
    final $$SourceItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.sourceItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourceItemsTableOrderingComposer(
            $db: $db,
            $table: $db.sourceItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FeedbackEventsTableAnnotationComposer
    extends Composer<_$TagDatabase, $FeedbackEventsTable> {
  $$FeedbackEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<String> get goalPlanId => $composableBuilder(
    column: $table.goalPlanId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get detailsJson => $composableBuilder(
    column: $table.detailsJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$TagCardsTableAnnotationComposer get cardId {
    final $$TagCardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.tagCards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagCardsTableAnnotationComposer(
            $db: $db,
            $table: $db.tagCards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SpacesTableAnnotationComposer get spaceId {
    final $$SpacesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.spaceId,
      referencedTable: $db.spaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SpacesTableAnnotationComposer(
            $db: $db,
            $table: $db.spaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SourceItemsTableAnnotationComposer get sourceId {
    final $$SourceItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.sourceItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourceItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.sourceItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FeedbackEventsTableTableManager
    extends
        RootTableManager<
          _$TagDatabase,
          $FeedbackEventsTable,
          FeedbackEvent,
          $$FeedbackEventsTableFilterComposer,
          $$FeedbackEventsTableOrderingComposer,
          $$FeedbackEventsTableAnnotationComposer,
          $$FeedbackEventsTableCreateCompanionBuilder,
          $$FeedbackEventsTableUpdateCompanionBuilder,
          (FeedbackEvent, $$FeedbackEventsTableReferences),
          FeedbackEvent,
          PrefetchHooks Function({bool cardId, bool spaceId, bool sourceId})
        > {
  $$FeedbackEventsTableTableManager(
    _$TagDatabase db,
    $FeedbackEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FeedbackEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FeedbackEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FeedbackEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> eventType = const Value.absent(),
                Value<String?> cardId = const Value.absent(),
                Value<String?> spaceId = const Value.absent(),
                Value<String?> sourceId = const Value.absent(),
                Value<String?> goalPlanId = const Value.absent(),
                Value<String> detailsJson = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FeedbackEventsCompanion(
                id: id,
                eventType: eventType,
                cardId: cardId,
                spaceId: spaceId,
                sourceId: sourceId,
                goalPlanId: goalPlanId,
                detailsJson: detailsJson,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String eventType,
                Value<String?> cardId = const Value.absent(),
                Value<String?> spaceId = const Value.absent(),
                Value<String?> sourceId = const Value.absent(),
                Value<String?> goalPlanId = const Value.absent(),
                Value<String> detailsJson = const Value.absent(),
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => FeedbackEventsCompanion.insert(
                id: id,
                eventType: eventType,
                cardId: cardId,
                spaceId: spaceId,
                sourceId: sourceId,
                goalPlanId: goalPlanId,
                detailsJson: detailsJson,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$FeedbackEventsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({cardId = false, spaceId = false, sourceId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (cardId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.cardId,
                                    referencedTable:
                                        $$FeedbackEventsTableReferences
                                            ._cardIdTable(db),
                                    referencedColumn:
                                        $$FeedbackEventsTableReferences
                                            ._cardIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (spaceId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.spaceId,
                                    referencedTable:
                                        $$FeedbackEventsTableReferences
                                            ._spaceIdTable(db),
                                    referencedColumn:
                                        $$FeedbackEventsTableReferences
                                            ._spaceIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (sourceId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.sourceId,
                                    referencedTable:
                                        $$FeedbackEventsTableReferences
                                            ._sourceIdTable(db),
                                    referencedColumn:
                                        $$FeedbackEventsTableReferences
                                            ._sourceIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$FeedbackEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$TagDatabase,
      $FeedbackEventsTable,
      FeedbackEvent,
      $$FeedbackEventsTableFilterComposer,
      $$FeedbackEventsTableOrderingComposer,
      $$FeedbackEventsTableAnnotationComposer,
      $$FeedbackEventsTableCreateCompanionBuilder,
      $$FeedbackEventsTableUpdateCompanionBuilder,
      (FeedbackEvent, $$FeedbackEventsTableReferences),
      FeedbackEvent,
      PrefetchHooks Function({bool cardId, bool spaceId, bool sourceId})
    >;
typedef $$PreferenceMemoryTableCreateCompanionBuilder =
    PreferenceMemoryCompanion Function({
      required String id,
      required String category,
      required String key,
      required String valueJson,
      required double confidence,
      Value<String> evidenceEventIdsJson,
      required int createdAt,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$PreferenceMemoryTableUpdateCompanionBuilder =
    PreferenceMemoryCompanion Function({
      Value<String> id,
      Value<String> category,
      Value<String> key,
      Value<String> valueJson,
      Value<double> confidence,
      Value<String> evidenceEventIdsJson,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$PreferenceMemoryTableFilterComposer
    extends Composer<_$TagDatabase, $PreferenceMemoryTable> {
  $$PreferenceMemoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get valueJson => $composableBuilder(
    column: $table.valueJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get evidenceEventIdsJson => $composableBuilder(
    column: $table.evidenceEventIdsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PreferenceMemoryTableOrderingComposer
    extends Composer<_$TagDatabase, $PreferenceMemoryTable> {
  $$PreferenceMemoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get valueJson => $composableBuilder(
    column: $table.valueJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get evidenceEventIdsJson => $composableBuilder(
    column: $table.evidenceEventIdsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PreferenceMemoryTableAnnotationComposer
    extends Composer<_$TagDatabase, $PreferenceMemoryTable> {
  $$PreferenceMemoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get valueJson =>
      $composableBuilder(column: $table.valueJson, builder: (column) => column);

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get evidenceEventIdsJson => $composableBuilder(
    column: $table.evidenceEventIdsJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PreferenceMemoryTableTableManager
    extends
        RootTableManager<
          _$TagDatabase,
          $PreferenceMemoryTable,
          PreferenceMemoryData,
          $$PreferenceMemoryTableFilterComposer,
          $$PreferenceMemoryTableOrderingComposer,
          $$PreferenceMemoryTableAnnotationComposer,
          $$PreferenceMemoryTableCreateCompanionBuilder,
          $$PreferenceMemoryTableUpdateCompanionBuilder,
          (
            PreferenceMemoryData,
            BaseReferences<
              _$TagDatabase,
              $PreferenceMemoryTable,
              PreferenceMemoryData
            >,
          ),
          PreferenceMemoryData,
          PrefetchHooks Function()
        > {
  $$PreferenceMemoryTableTableManager(
    _$TagDatabase db,
    $PreferenceMemoryTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PreferenceMemoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PreferenceMemoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PreferenceMemoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> key = const Value.absent(),
                Value<String> valueJson = const Value.absent(),
                Value<double> confidence = const Value.absent(),
                Value<String> evidenceEventIdsJson = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PreferenceMemoryCompanion(
                id: id,
                category: category,
                key: key,
                valueJson: valueJson,
                confidence: confidence,
                evidenceEventIdsJson: evidenceEventIdsJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String category,
                required String key,
                required String valueJson,
                required double confidence,
                Value<String> evidenceEventIdsJson = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => PreferenceMemoryCompanion.insert(
                id: id,
                category: category,
                key: key,
                valueJson: valueJson,
                confidence: confidence,
                evidenceEventIdsJson: evidenceEventIdsJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PreferenceMemoryTableProcessedTableManager =
    ProcessedTableManager<
      _$TagDatabase,
      $PreferenceMemoryTable,
      PreferenceMemoryData,
      $$PreferenceMemoryTableFilterComposer,
      $$PreferenceMemoryTableOrderingComposer,
      $$PreferenceMemoryTableAnnotationComposer,
      $$PreferenceMemoryTableCreateCompanionBuilder,
      $$PreferenceMemoryTableUpdateCompanionBuilder,
      (
        PreferenceMemoryData,
        BaseReferences<
          _$TagDatabase,
          $PreferenceMemoryTable,
          PreferenceMemoryData
        >,
      ),
      PreferenceMemoryData,
      PrefetchHooks Function()
    >;
typedef $$NotificationRequestsTableCreateCompanionBuilder =
    NotificationRequestsCompanion Function({
      required String id,
      required String cardId,
      required int platformNotificationId,
      required int scheduledFor,
      required String timezone,
      required String status,
      required String title,
      required String body,
      Value<String> actionsJson,
      Value<String?> failureReason,
      required int createdAt,
      required int updatedAt,
      Value<int?> cancelledAt,
      Value<int> rowid,
    });
typedef $$NotificationRequestsTableUpdateCompanionBuilder =
    NotificationRequestsCompanion Function({
      Value<String> id,
      Value<String> cardId,
      Value<int> platformNotificationId,
      Value<int> scheduledFor,
      Value<String> timezone,
      Value<String> status,
      Value<String> title,
      Value<String> body,
      Value<String> actionsJson,
      Value<String?> failureReason,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> cancelledAt,
      Value<int> rowid,
    });

final class $$NotificationRequestsTableReferences
    extends
        BaseReferences<
          _$TagDatabase,
          $NotificationRequestsTable,
          NotificationRequest
        > {
  $$NotificationRequestsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TagCardsTable _cardIdTable(_$TagDatabase db) =>
      db.tagCards.createAlias(
        $_aliasNameGenerator(db.notificationRequests.cardId, db.tagCards.id),
      );

  $$TagCardsTableProcessedTableManager get cardId {
    final $_column = $_itemColumn<String>('card_id')!;

    final manager = $$TagCardsTableTableManager(
      $_db,
      $_db.tagCards,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cardIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$NotificationRequestsTableFilterComposer
    extends Composer<_$TagDatabase, $NotificationRequestsTable> {
  $$NotificationRequestsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get platformNotificationId => $composableBuilder(
    column: $table.platformNotificationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get scheduledFor => $composableBuilder(
    column: $table.scheduledFor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timezone => $composableBuilder(
    column: $table.timezone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actionsJson => $composableBuilder(
    column: $table.actionsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get failureReason => $composableBuilder(
    column: $table.failureReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cancelledAt => $composableBuilder(
    column: $table.cancelledAt,
    builder: (column) => ColumnFilters(column),
  );

  $$TagCardsTableFilterComposer get cardId {
    final $$TagCardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.tagCards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagCardsTableFilterComposer(
            $db: $db,
            $table: $db.tagCards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NotificationRequestsTableOrderingComposer
    extends Composer<_$TagDatabase, $NotificationRequestsTable> {
  $$NotificationRequestsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get platformNotificationId => $composableBuilder(
    column: $table.platformNotificationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get scheduledFor => $composableBuilder(
    column: $table.scheduledFor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timezone => $composableBuilder(
    column: $table.timezone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actionsJson => $composableBuilder(
    column: $table.actionsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get failureReason => $composableBuilder(
    column: $table.failureReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cancelledAt => $composableBuilder(
    column: $table.cancelledAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$TagCardsTableOrderingComposer get cardId {
    final $$TagCardsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.tagCards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagCardsTableOrderingComposer(
            $db: $db,
            $table: $db.tagCards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NotificationRequestsTableAnnotationComposer
    extends Composer<_$TagDatabase, $NotificationRequestsTable> {
  $$NotificationRequestsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get platformNotificationId => $composableBuilder(
    column: $table.platformNotificationId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get scheduledFor => $composableBuilder(
    column: $table.scheduledFor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get timezone =>
      $composableBuilder(column: $table.timezone, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get actionsJson => $composableBuilder(
    column: $table.actionsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get failureReason => $composableBuilder(
    column: $table.failureReason,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get cancelledAt => $composableBuilder(
    column: $table.cancelledAt,
    builder: (column) => column,
  );

  $$TagCardsTableAnnotationComposer get cardId {
    final $$TagCardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.tagCards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagCardsTableAnnotationComposer(
            $db: $db,
            $table: $db.tagCards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NotificationRequestsTableTableManager
    extends
        RootTableManager<
          _$TagDatabase,
          $NotificationRequestsTable,
          NotificationRequest,
          $$NotificationRequestsTableFilterComposer,
          $$NotificationRequestsTableOrderingComposer,
          $$NotificationRequestsTableAnnotationComposer,
          $$NotificationRequestsTableCreateCompanionBuilder,
          $$NotificationRequestsTableUpdateCompanionBuilder,
          (NotificationRequest, $$NotificationRequestsTableReferences),
          NotificationRequest,
          PrefetchHooks Function({bool cardId})
        > {
  $$NotificationRequestsTableTableManager(
    _$TagDatabase db,
    $NotificationRequestsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotificationRequestsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotificationRequestsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$NotificationRequestsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> cardId = const Value.absent(),
                Value<int> platformNotificationId = const Value.absent(),
                Value<int> scheduledFor = const Value.absent(),
                Value<String> timezone = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String> actionsJson = const Value.absent(),
                Value<String?> failureReason = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> cancelledAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotificationRequestsCompanion(
                id: id,
                cardId: cardId,
                platformNotificationId: platformNotificationId,
                scheduledFor: scheduledFor,
                timezone: timezone,
                status: status,
                title: title,
                body: body,
                actionsJson: actionsJson,
                failureReason: failureReason,
                createdAt: createdAt,
                updatedAt: updatedAt,
                cancelledAt: cancelledAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String cardId,
                required int platformNotificationId,
                required int scheduledFor,
                required String timezone,
                required String status,
                required String title,
                required String body,
                Value<String> actionsJson = const Value.absent(),
                Value<String?> failureReason = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int?> cancelledAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotificationRequestsCompanion.insert(
                id: id,
                cardId: cardId,
                platformNotificationId: platformNotificationId,
                scheduledFor: scheduledFor,
                timezone: timezone,
                status: status,
                title: title,
                body: body,
                actionsJson: actionsJson,
                failureReason: failureReason,
                createdAt: createdAt,
                updatedAt: updatedAt,
                cancelledAt: cancelledAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$NotificationRequestsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({cardId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (cardId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.cardId,
                                referencedTable:
                                    $$NotificationRequestsTableReferences
                                        ._cardIdTable(db),
                                referencedColumn:
                                    $$NotificationRequestsTableReferences
                                        ._cardIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$NotificationRequestsTableProcessedTableManager =
    ProcessedTableManager<
      _$TagDatabase,
      $NotificationRequestsTable,
      NotificationRequest,
      $$NotificationRequestsTableFilterComposer,
      $$NotificationRequestsTableOrderingComposer,
      $$NotificationRequestsTableAnnotationComposer,
      $$NotificationRequestsTableCreateCompanionBuilder,
      $$NotificationRequestsTableUpdateCompanionBuilder,
      (NotificationRequest, $$NotificationRequestsTableReferences),
      NotificationRequest,
      PrefetchHooks Function({bool cardId})
    >;
typedef $$AiProcessingJobsTableCreateCompanionBuilder =
    AiProcessingJobsCompanion Function({
      required String id,
      required String jobType,
      required String status,
      Value<String?> sourceId,
      Value<String?> cardId,
      Value<String?> spaceId,
      Value<String?> chatSessionId,
      Value<int> priority,
      Value<int> attemptCount,
      Value<int> maxAttempts,
      Value<String> inputJson,
      Value<String?> outputJson,
      Value<String?> errorMessage,
      Value<String?> modelSlug,
      required int queuedAt,
      Value<int?> startedAt,
      Value<int?> completedAt,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$AiProcessingJobsTableUpdateCompanionBuilder =
    AiProcessingJobsCompanion Function({
      Value<String> id,
      Value<String> jobType,
      Value<String> status,
      Value<String?> sourceId,
      Value<String?> cardId,
      Value<String?> spaceId,
      Value<String?> chatSessionId,
      Value<int> priority,
      Value<int> attemptCount,
      Value<int> maxAttempts,
      Value<String> inputJson,
      Value<String?> outputJson,
      Value<String?> errorMessage,
      Value<String?> modelSlug,
      Value<int> queuedAt,
      Value<int?> startedAt,
      Value<int?> completedAt,
      Value<int> updatedAt,
      Value<int> rowid,
    });

final class $$AiProcessingJobsTableReferences
    extends
        BaseReferences<_$TagDatabase, $AiProcessingJobsTable, AiProcessingJob> {
  $$AiProcessingJobsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SourceItemsTable _sourceIdTable(_$TagDatabase db) =>
      db.sourceItems.createAlias(
        $_aliasNameGenerator(db.aiProcessingJobs.sourceId, db.sourceItems.id),
      );

  $$SourceItemsTableProcessedTableManager? get sourceId {
    final $_column = $_itemColumn<String>('source_id');
    if ($_column == null) return null;
    final manager = $$SourceItemsTableTableManager(
      $_db,
      $_db.sourceItems,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TagCardsTable _cardIdTable(_$TagDatabase db) =>
      db.tagCards.createAlias(
        $_aliasNameGenerator(db.aiProcessingJobs.cardId, db.tagCards.id),
      );

  $$TagCardsTableProcessedTableManager? get cardId {
    final $_column = $_itemColumn<String>('card_id');
    if ($_column == null) return null;
    final manager = $$TagCardsTableTableManager(
      $_db,
      $_db.tagCards,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cardIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SpacesTable _spaceIdTable(_$TagDatabase db) => db.spaces.createAlias(
    $_aliasNameGenerator(db.aiProcessingJobs.spaceId, db.spaces.id),
  );

  $$SpacesTableProcessedTableManager? get spaceId {
    final $_column = $_itemColumn<String>('space_id');
    if ($_column == null) return null;
    final manager = $$SpacesTableTableManager(
      $_db,
      $_db.spaces,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_spaceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ChatSessionsTable _chatSessionIdTable(_$TagDatabase db) =>
      db.chatSessions.createAlias(
        $_aliasNameGenerator(
          db.aiProcessingJobs.chatSessionId,
          db.chatSessions.id,
        ),
      );

  $$ChatSessionsTableProcessedTableManager? get chatSessionId {
    final $_column = $_itemColumn<String>('chat_session_id');
    if ($_column == null) return null;
    final manager = $$ChatSessionsTableTableManager(
      $_db,
      $_db.chatSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_chatSessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AiProcessingJobsTableFilterComposer
    extends Composer<_$TagDatabase, $AiProcessingJobsTable> {
  $$AiProcessingJobsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jobType => $composableBuilder(
    column: $table.jobType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxAttempts => $composableBuilder(
    column: $table.maxAttempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get inputJson => $composableBuilder(
    column: $table.inputJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get outputJson => $composableBuilder(
    column: $table.outputJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelSlug => $composableBuilder(
    column: $table.modelSlug,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get queuedAt => $composableBuilder(
    column: $table.queuedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SourceItemsTableFilterComposer get sourceId {
    final $$SourceItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.sourceItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourceItemsTableFilterComposer(
            $db: $db,
            $table: $db.sourceItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagCardsTableFilterComposer get cardId {
    final $$TagCardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.tagCards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagCardsTableFilterComposer(
            $db: $db,
            $table: $db.tagCards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SpacesTableFilterComposer get spaceId {
    final $$SpacesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.spaceId,
      referencedTable: $db.spaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SpacesTableFilterComposer(
            $db: $db,
            $table: $db.spaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ChatSessionsTableFilterComposer get chatSessionId {
    final $$ChatSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chatSessionId,
      referencedTable: $db.chatSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatSessionsTableFilterComposer(
            $db: $db,
            $table: $db.chatSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AiProcessingJobsTableOrderingComposer
    extends Composer<_$TagDatabase, $AiProcessingJobsTable> {
  $$AiProcessingJobsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jobType => $composableBuilder(
    column: $table.jobType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxAttempts => $composableBuilder(
    column: $table.maxAttempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get inputJson => $composableBuilder(
    column: $table.inputJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get outputJson => $composableBuilder(
    column: $table.outputJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelSlug => $composableBuilder(
    column: $table.modelSlug,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get queuedAt => $composableBuilder(
    column: $table.queuedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SourceItemsTableOrderingComposer get sourceId {
    final $$SourceItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.sourceItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourceItemsTableOrderingComposer(
            $db: $db,
            $table: $db.sourceItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagCardsTableOrderingComposer get cardId {
    final $$TagCardsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.tagCards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagCardsTableOrderingComposer(
            $db: $db,
            $table: $db.tagCards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SpacesTableOrderingComposer get spaceId {
    final $$SpacesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.spaceId,
      referencedTable: $db.spaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SpacesTableOrderingComposer(
            $db: $db,
            $table: $db.spaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ChatSessionsTableOrderingComposer get chatSessionId {
    final $$ChatSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chatSessionId,
      referencedTable: $db.chatSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.chatSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AiProcessingJobsTableAnnotationComposer
    extends Composer<_$TagDatabase, $AiProcessingJobsTable> {
  $$AiProcessingJobsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get jobType =>
      $composableBuilder(column: $table.jobType, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get maxAttempts => $composableBuilder(
    column: $table.maxAttempts,
    builder: (column) => column,
  );

  GeneratedColumn<String> get inputJson =>
      $composableBuilder(column: $table.inputJson, builder: (column) => column);

  GeneratedColumn<String> get outputJson => $composableBuilder(
    column: $table.outputJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get modelSlug =>
      $composableBuilder(column: $table.modelSlug, builder: (column) => column);

  GeneratedColumn<int> get queuedAt =>
      $composableBuilder(column: $table.queuedAt, builder: (column) => column);

  GeneratedColumn<int> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$SourceItemsTableAnnotationComposer get sourceId {
    final $$SourceItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.sourceItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourceItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.sourceItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagCardsTableAnnotationComposer get cardId {
    final $$TagCardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.tagCards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagCardsTableAnnotationComposer(
            $db: $db,
            $table: $db.tagCards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SpacesTableAnnotationComposer get spaceId {
    final $$SpacesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.spaceId,
      referencedTable: $db.spaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SpacesTableAnnotationComposer(
            $db: $db,
            $table: $db.spaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ChatSessionsTableAnnotationComposer get chatSessionId {
    final $$ChatSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chatSessionId,
      referencedTable: $db.chatSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.chatSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AiProcessingJobsTableTableManager
    extends
        RootTableManager<
          _$TagDatabase,
          $AiProcessingJobsTable,
          AiProcessingJob,
          $$AiProcessingJobsTableFilterComposer,
          $$AiProcessingJobsTableOrderingComposer,
          $$AiProcessingJobsTableAnnotationComposer,
          $$AiProcessingJobsTableCreateCompanionBuilder,
          $$AiProcessingJobsTableUpdateCompanionBuilder,
          (AiProcessingJob, $$AiProcessingJobsTableReferences),
          AiProcessingJob,
          PrefetchHooks Function({
            bool sourceId,
            bool cardId,
            bool spaceId,
            bool chatSessionId,
          })
        > {
  $$AiProcessingJobsTableTableManager(
    _$TagDatabase db,
    $AiProcessingJobsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AiProcessingJobsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AiProcessingJobsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AiProcessingJobsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> jobType = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> sourceId = const Value.absent(),
                Value<String?> cardId = const Value.absent(),
                Value<String?> spaceId = const Value.absent(),
                Value<String?> chatSessionId = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<int> attemptCount = const Value.absent(),
                Value<int> maxAttempts = const Value.absent(),
                Value<String> inputJson = const Value.absent(),
                Value<String?> outputJson = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<String?> modelSlug = const Value.absent(),
                Value<int> queuedAt = const Value.absent(),
                Value<int?> startedAt = const Value.absent(),
                Value<int?> completedAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AiProcessingJobsCompanion(
                id: id,
                jobType: jobType,
                status: status,
                sourceId: sourceId,
                cardId: cardId,
                spaceId: spaceId,
                chatSessionId: chatSessionId,
                priority: priority,
                attemptCount: attemptCount,
                maxAttempts: maxAttempts,
                inputJson: inputJson,
                outputJson: outputJson,
                errorMessage: errorMessage,
                modelSlug: modelSlug,
                queuedAt: queuedAt,
                startedAt: startedAt,
                completedAt: completedAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String jobType,
                required String status,
                Value<String?> sourceId = const Value.absent(),
                Value<String?> cardId = const Value.absent(),
                Value<String?> spaceId = const Value.absent(),
                Value<String?> chatSessionId = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<int> attemptCount = const Value.absent(),
                Value<int> maxAttempts = const Value.absent(),
                Value<String> inputJson = const Value.absent(),
                Value<String?> outputJson = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<String?> modelSlug = const Value.absent(),
                required int queuedAt,
                Value<int?> startedAt = const Value.absent(),
                Value<int?> completedAt = const Value.absent(),
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => AiProcessingJobsCompanion.insert(
                id: id,
                jobType: jobType,
                status: status,
                sourceId: sourceId,
                cardId: cardId,
                spaceId: spaceId,
                chatSessionId: chatSessionId,
                priority: priority,
                attemptCount: attemptCount,
                maxAttempts: maxAttempts,
                inputJson: inputJson,
                outputJson: outputJson,
                errorMessage: errorMessage,
                modelSlug: modelSlug,
                queuedAt: queuedAt,
                startedAt: startedAt,
                completedAt: completedAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AiProcessingJobsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                sourceId = false,
                cardId = false,
                spaceId = false,
                chatSessionId = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (sourceId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.sourceId,
                                    referencedTable:
                                        $$AiProcessingJobsTableReferences
                                            ._sourceIdTable(db),
                                    referencedColumn:
                                        $$AiProcessingJobsTableReferences
                                            ._sourceIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (cardId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.cardId,
                                    referencedTable:
                                        $$AiProcessingJobsTableReferences
                                            ._cardIdTable(db),
                                    referencedColumn:
                                        $$AiProcessingJobsTableReferences
                                            ._cardIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (spaceId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.spaceId,
                                    referencedTable:
                                        $$AiProcessingJobsTableReferences
                                            ._spaceIdTable(db),
                                    referencedColumn:
                                        $$AiProcessingJobsTableReferences
                                            ._spaceIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (chatSessionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.chatSessionId,
                                    referencedTable:
                                        $$AiProcessingJobsTableReferences
                                            ._chatSessionIdTable(db),
                                    referencedColumn:
                                        $$AiProcessingJobsTableReferences
                                            ._chatSessionIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$AiProcessingJobsTableProcessedTableManager =
    ProcessedTableManager<
      _$TagDatabase,
      $AiProcessingJobsTable,
      AiProcessingJob,
      $$AiProcessingJobsTableFilterComposer,
      $$AiProcessingJobsTableOrderingComposer,
      $$AiProcessingJobsTableAnnotationComposer,
      $$AiProcessingJobsTableCreateCompanionBuilder,
      $$AiProcessingJobsTableUpdateCompanionBuilder,
      (AiProcessingJob, $$AiProcessingJobsTableReferences),
      AiProcessingJob,
      PrefetchHooks Function({
        bool sourceId,
        bool cardId,
        bool spaceId,
        bool chatSessionId,
      })
    >;
typedef $$AiModelAssetsTableCreateCompanionBuilder =
    AiModelAssetsCompanion Function({
      required String slug,
      required String displayName,
      Value<String> capabilitiesJson,
      Value<double?> sizeMb,
      Value<String?> quantization,
      Value<bool> isDownloaded,
      Value<bool> isInitialized,
      Value<String?> localPath,
      Value<int?> lastCheckedAt,
      Value<int?> lastInitializedAt,
      Value<String?> failureReason,
      Value<String> downloadStatus,
      Value<double?> downloadProgress,
      Value<String?> downloadStatusMessage,
      Value<int?> downloadStartedAt,
      Value<int?> downloadCompletedAt,
      Value<int> rowid,
    });
typedef $$AiModelAssetsTableUpdateCompanionBuilder =
    AiModelAssetsCompanion Function({
      Value<String> slug,
      Value<String> displayName,
      Value<String> capabilitiesJson,
      Value<double?> sizeMb,
      Value<String?> quantization,
      Value<bool> isDownloaded,
      Value<bool> isInitialized,
      Value<String?> localPath,
      Value<int?> lastCheckedAt,
      Value<int?> lastInitializedAt,
      Value<String?> failureReason,
      Value<String> downloadStatus,
      Value<double?> downloadProgress,
      Value<String?> downloadStatusMessage,
      Value<int?> downloadStartedAt,
      Value<int?> downloadCompletedAt,
      Value<int> rowid,
    });

class $$AiModelAssetsTableFilterComposer
    extends Composer<_$TagDatabase, $AiModelAssetsTable> {
  $$AiModelAssetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get slug => $composableBuilder(
    column: $table.slug,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get capabilitiesJson => $composableBuilder(
    column: $table.capabilitiesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sizeMb => $composableBuilder(
    column: $table.sizeMb,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get quantization => $composableBuilder(
    column: $table.quantization,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDownloaded => $composableBuilder(
    column: $table.isDownloaded,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isInitialized => $composableBuilder(
    column: $table.isInitialized,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastCheckedAt => $composableBuilder(
    column: $table.lastCheckedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastInitializedAt => $composableBuilder(
    column: $table.lastInitializedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get failureReason => $composableBuilder(
    column: $table.failureReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get downloadStatus => $composableBuilder(
    column: $table.downloadStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get downloadProgress => $composableBuilder(
    column: $table.downloadProgress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get downloadStatusMessage => $composableBuilder(
    column: $table.downloadStatusMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get downloadStartedAt => $composableBuilder(
    column: $table.downloadStartedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get downloadCompletedAt => $composableBuilder(
    column: $table.downloadCompletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AiModelAssetsTableOrderingComposer
    extends Composer<_$TagDatabase, $AiModelAssetsTable> {
  $$AiModelAssetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get slug => $composableBuilder(
    column: $table.slug,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get capabilitiesJson => $composableBuilder(
    column: $table.capabilitiesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sizeMb => $composableBuilder(
    column: $table.sizeMb,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quantization => $composableBuilder(
    column: $table.quantization,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDownloaded => $composableBuilder(
    column: $table.isDownloaded,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isInitialized => $composableBuilder(
    column: $table.isInitialized,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastCheckedAt => $composableBuilder(
    column: $table.lastCheckedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastInitializedAt => $composableBuilder(
    column: $table.lastInitializedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get failureReason => $composableBuilder(
    column: $table.failureReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get downloadStatus => $composableBuilder(
    column: $table.downloadStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get downloadProgress => $composableBuilder(
    column: $table.downloadProgress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get downloadStatusMessage => $composableBuilder(
    column: $table.downloadStatusMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get downloadStartedAt => $composableBuilder(
    column: $table.downloadStartedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get downloadCompletedAt => $composableBuilder(
    column: $table.downloadCompletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AiModelAssetsTableAnnotationComposer
    extends Composer<_$TagDatabase, $AiModelAssetsTable> {
  $$AiModelAssetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get slug =>
      $composableBuilder(column: $table.slug, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get capabilitiesJson => $composableBuilder(
    column: $table.capabilitiesJson,
    builder: (column) => column,
  );

  GeneratedColumn<double> get sizeMb =>
      $composableBuilder(column: $table.sizeMb, builder: (column) => column);

  GeneratedColumn<String> get quantization => $composableBuilder(
    column: $table.quantization,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDownloaded => $composableBuilder(
    column: $table.isDownloaded,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isInitialized => $composableBuilder(
    column: $table.isInitialized,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<int> get lastCheckedAt => $composableBuilder(
    column: $table.lastCheckedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastInitializedAt => $composableBuilder(
    column: $table.lastInitializedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get failureReason => $composableBuilder(
    column: $table.failureReason,
    builder: (column) => column,
  );

  GeneratedColumn<String> get downloadStatus => $composableBuilder(
    column: $table.downloadStatus,
    builder: (column) => column,
  );

  GeneratedColumn<double> get downloadProgress => $composableBuilder(
    column: $table.downloadProgress,
    builder: (column) => column,
  );

  GeneratedColumn<String> get downloadStatusMessage => $composableBuilder(
    column: $table.downloadStatusMessage,
    builder: (column) => column,
  );

  GeneratedColumn<int> get downloadStartedAt => $composableBuilder(
    column: $table.downloadStartedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get downloadCompletedAt => $composableBuilder(
    column: $table.downloadCompletedAt,
    builder: (column) => column,
  );
}

class $$AiModelAssetsTableTableManager
    extends
        RootTableManager<
          _$TagDatabase,
          $AiModelAssetsTable,
          AiModelAsset,
          $$AiModelAssetsTableFilterComposer,
          $$AiModelAssetsTableOrderingComposer,
          $$AiModelAssetsTableAnnotationComposer,
          $$AiModelAssetsTableCreateCompanionBuilder,
          $$AiModelAssetsTableUpdateCompanionBuilder,
          (
            AiModelAsset,
            BaseReferences<_$TagDatabase, $AiModelAssetsTable, AiModelAsset>,
          ),
          AiModelAsset,
          PrefetchHooks Function()
        > {
  $$AiModelAssetsTableTableManager(_$TagDatabase db, $AiModelAssetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AiModelAssetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AiModelAssetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AiModelAssetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> slug = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String> capabilitiesJson = const Value.absent(),
                Value<double?> sizeMb = const Value.absent(),
                Value<String?> quantization = const Value.absent(),
                Value<bool> isDownloaded = const Value.absent(),
                Value<bool> isInitialized = const Value.absent(),
                Value<String?> localPath = const Value.absent(),
                Value<int?> lastCheckedAt = const Value.absent(),
                Value<int?> lastInitializedAt = const Value.absent(),
                Value<String?> failureReason = const Value.absent(),
                Value<String> downloadStatus = const Value.absent(),
                Value<double?> downloadProgress = const Value.absent(),
                Value<String?> downloadStatusMessage = const Value.absent(),
                Value<int?> downloadStartedAt = const Value.absent(),
                Value<int?> downloadCompletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AiModelAssetsCompanion(
                slug: slug,
                displayName: displayName,
                capabilitiesJson: capabilitiesJson,
                sizeMb: sizeMb,
                quantization: quantization,
                isDownloaded: isDownloaded,
                isInitialized: isInitialized,
                localPath: localPath,
                lastCheckedAt: lastCheckedAt,
                lastInitializedAt: lastInitializedAt,
                failureReason: failureReason,
                downloadStatus: downloadStatus,
                downloadProgress: downloadProgress,
                downloadStatusMessage: downloadStatusMessage,
                downloadStartedAt: downloadStartedAt,
                downloadCompletedAt: downloadCompletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String slug,
                required String displayName,
                Value<String> capabilitiesJson = const Value.absent(),
                Value<double?> sizeMb = const Value.absent(),
                Value<String?> quantization = const Value.absent(),
                Value<bool> isDownloaded = const Value.absent(),
                Value<bool> isInitialized = const Value.absent(),
                Value<String?> localPath = const Value.absent(),
                Value<int?> lastCheckedAt = const Value.absent(),
                Value<int?> lastInitializedAt = const Value.absent(),
                Value<String?> failureReason = const Value.absent(),
                Value<String> downloadStatus = const Value.absent(),
                Value<double?> downloadProgress = const Value.absent(),
                Value<String?> downloadStatusMessage = const Value.absent(),
                Value<int?> downloadStartedAt = const Value.absent(),
                Value<int?> downloadCompletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AiModelAssetsCompanion.insert(
                slug: slug,
                displayName: displayName,
                capabilitiesJson: capabilitiesJson,
                sizeMb: sizeMb,
                quantization: quantization,
                isDownloaded: isDownloaded,
                isInitialized: isInitialized,
                localPath: localPath,
                lastCheckedAt: lastCheckedAt,
                lastInitializedAt: lastInitializedAt,
                failureReason: failureReason,
                downloadStatus: downloadStatus,
                downloadProgress: downloadProgress,
                downloadStatusMessage: downloadStatusMessage,
                downloadStartedAt: downloadStartedAt,
                downloadCompletedAt: downloadCompletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AiModelAssetsTableProcessedTableManager =
    ProcessedTableManager<
      _$TagDatabase,
      $AiModelAssetsTable,
      AiModelAsset,
      $$AiModelAssetsTableFilterComposer,
      $$AiModelAssetsTableOrderingComposer,
      $$AiModelAssetsTableAnnotationComposer,
      $$AiModelAssetsTableCreateCompanionBuilder,
      $$AiModelAssetsTableUpdateCompanionBuilder,
      (
        AiModelAsset,
        BaseReferences<_$TagDatabase, $AiModelAssetsTable, AiModelAsset>,
      ),
      AiModelAsset,
      PrefetchHooks Function()
    >;
typedef $$RagIndexRecordsTableCreateCompanionBuilder =
    RagIndexRecordsCompanion Function({
      required String id,
      required String indexName,
      required String externalId,
      required String sourceChunkId,
      required String embeddingModelSlug,
      required int embeddingDimension,
      required String documentTextHash,
      required int createdAt,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$RagIndexRecordsTableUpdateCompanionBuilder =
    RagIndexRecordsCompanion Function({
      Value<String> id,
      Value<String> indexName,
      Value<String> externalId,
      Value<String> sourceChunkId,
      Value<String> embeddingModelSlug,
      Value<int> embeddingDimension,
      Value<String> documentTextHash,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> rowid,
    });

final class $$RagIndexRecordsTableReferences
    extends
        BaseReferences<_$TagDatabase, $RagIndexRecordsTable, RagIndexRecord> {
  $$RagIndexRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SourceTextChunksTable _sourceChunkIdTable(_$TagDatabase db) =>
      db.sourceTextChunks.createAlias(
        $_aliasNameGenerator(
          db.ragIndexRecords.sourceChunkId,
          db.sourceTextChunks.id,
        ),
      );

  $$SourceTextChunksTableProcessedTableManager get sourceChunkId {
    final $_column = $_itemColumn<String>('source_chunk_id')!;

    final manager = $$SourceTextChunksTableTableManager(
      $_db,
      $_db.sourceTextChunks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceChunkIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RagIndexRecordsTableFilterComposer
    extends Composer<_$TagDatabase, $RagIndexRecordsTable> {
  $$RagIndexRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get indexName => $composableBuilder(
    column: $table.indexName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get embeddingModelSlug => $composableBuilder(
    column: $table.embeddingModelSlug,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get embeddingDimension => $composableBuilder(
    column: $table.embeddingDimension,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get documentTextHash => $composableBuilder(
    column: $table.documentTextHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SourceTextChunksTableFilterComposer get sourceChunkId {
    final $$SourceTextChunksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceChunkId,
      referencedTable: $db.sourceTextChunks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourceTextChunksTableFilterComposer(
            $db: $db,
            $table: $db.sourceTextChunks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RagIndexRecordsTableOrderingComposer
    extends Composer<_$TagDatabase, $RagIndexRecordsTable> {
  $$RagIndexRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get indexName => $composableBuilder(
    column: $table.indexName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get embeddingModelSlug => $composableBuilder(
    column: $table.embeddingModelSlug,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get embeddingDimension => $composableBuilder(
    column: $table.embeddingDimension,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get documentTextHash => $composableBuilder(
    column: $table.documentTextHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SourceTextChunksTableOrderingComposer get sourceChunkId {
    final $$SourceTextChunksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceChunkId,
      referencedTable: $db.sourceTextChunks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourceTextChunksTableOrderingComposer(
            $db: $db,
            $table: $db.sourceTextChunks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RagIndexRecordsTableAnnotationComposer
    extends Composer<_$TagDatabase, $RagIndexRecordsTable> {
  $$RagIndexRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get indexName =>
      $composableBuilder(column: $table.indexName, builder: (column) => column);

  GeneratedColumn<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get embeddingModelSlug => $composableBuilder(
    column: $table.embeddingModelSlug,
    builder: (column) => column,
  );

  GeneratedColumn<int> get embeddingDimension => $composableBuilder(
    column: $table.embeddingDimension,
    builder: (column) => column,
  );

  GeneratedColumn<String> get documentTextHash => $composableBuilder(
    column: $table.documentTextHash,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$SourceTextChunksTableAnnotationComposer get sourceChunkId {
    final $$SourceTextChunksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceChunkId,
      referencedTable: $db.sourceTextChunks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourceTextChunksTableAnnotationComposer(
            $db: $db,
            $table: $db.sourceTextChunks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RagIndexRecordsTableTableManager
    extends
        RootTableManager<
          _$TagDatabase,
          $RagIndexRecordsTable,
          RagIndexRecord,
          $$RagIndexRecordsTableFilterComposer,
          $$RagIndexRecordsTableOrderingComposer,
          $$RagIndexRecordsTableAnnotationComposer,
          $$RagIndexRecordsTableCreateCompanionBuilder,
          $$RagIndexRecordsTableUpdateCompanionBuilder,
          (RagIndexRecord, $$RagIndexRecordsTableReferences),
          RagIndexRecord,
          PrefetchHooks Function({bool sourceChunkId})
        > {
  $$RagIndexRecordsTableTableManager(
    _$TagDatabase db,
    $RagIndexRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RagIndexRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RagIndexRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RagIndexRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> indexName = const Value.absent(),
                Value<String> externalId = const Value.absent(),
                Value<String> sourceChunkId = const Value.absent(),
                Value<String> embeddingModelSlug = const Value.absent(),
                Value<int> embeddingDimension = const Value.absent(),
                Value<String> documentTextHash = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RagIndexRecordsCompanion(
                id: id,
                indexName: indexName,
                externalId: externalId,
                sourceChunkId: sourceChunkId,
                embeddingModelSlug: embeddingModelSlug,
                embeddingDimension: embeddingDimension,
                documentTextHash: documentTextHash,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String indexName,
                required String externalId,
                required String sourceChunkId,
                required String embeddingModelSlug,
                required int embeddingDimension,
                required String documentTextHash,
                required int createdAt,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => RagIndexRecordsCompanion.insert(
                id: id,
                indexName: indexName,
                externalId: externalId,
                sourceChunkId: sourceChunkId,
                embeddingModelSlug: embeddingModelSlug,
                embeddingDimension: embeddingDimension,
                documentTextHash: documentTextHash,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RagIndexRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sourceChunkId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sourceChunkId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sourceChunkId,
                                referencedTable:
                                    $$RagIndexRecordsTableReferences
                                        ._sourceChunkIdTable(db),
                                referencedColumn:
                                    $$RagIndexRecordsTableReferences
                                        ._sourceChunkIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RagIndexRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$TagDatabase,
      $RagIndexRecordsTable,
      RagIndexRecord,
      $$RagIndexRecordsTableFilterComposer,
      $$RagIndexRecordsTableOrderingComposer,
      $$RagIndexRecordsTableAnnotationComposer,
      $$RagIndexRecordsTableCreateCompanionBuilder,
      $$RagIndexRecordsTableUpdateCompanionBuilder,
      (RagIndexRecord, $$RagIndexRecordsTableReferences),
      RagIndexRecord,
      PrefetchHooks Function({bool sourceChunkId})
    >;

class $TagDatabaseManager {
  final _$TagDatabase _db;
  $TagDatabaseManager(this._db);
  $$UserProfilesTableTableManager get userProfiles =>
      $$UserProfilesTableTableManager(_db, _db.userProfiles);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$SourceItemsTableTableManager get sourceItems =>
      $$SourceItemsTableTableManager(_db, _db.sourceItems);
  $$SourceTextChunksTableTableManager get sourceTextChunks =>
      $$SourceTextChunksTableTableManager(_db, _db.sourceTextChunks);
  $$SpacesTableTableManager get spaces =>
      $$SpacesTableTableManager(_db, _db.spaces);
  $$TagCardsTableTableManager get tagCards =>
      $$TagCardsTableTableManager(_db, _db.tagCards);
  $$CardSourcesTableTableManager get cardSources =>
      $$CardSourcesTableTableManager(_db, _db.cardSources);
  $$GoalPlansTableTableManager get goalPlans =>
      $$GoalPlansTableTableManager(_db, _db.goalPlans);
  $$GoalPlanCardsTableTableManager get goalPlanCards =>
      $$GoalPlanCardsTableTableManager(_db, _db.goalPlanCards);
  $$ChatSessionsTableTableManager get chatSessions =>
      $$ChatSessionsTableTableManager(_db, _db.chatSessions);
  $$ChatMessagesTableTableManager get chatMessages =>
      $$ChatMessagesTableTableManager(_db, _db.chatMessages);
  $$FeedbackEventsTableTableManager get feedbackEvents =>
      $$FeedbackEventsTableTableManager(_db, _db.feedbackEvents);
  $$PreferenceMemoryTableTableManager get preferenceMemory =>
      $$PreferenceMemoryTableTableManager(_db, _db.preferenceMemory);
  $$NotificationRequestsTableTableManager get notificationRequests =>
      $$NotificationRequestsTableTableManager(_db, _db.notificationRequests);
  $$AiProcessingJobsTableTableManager get aiProcessingJobs =>
      $$AiProcessingJobsTableTableManager(_db, _db.aiProcessingJobs);
  $$AiModelAssetsTableTableManager get aiModelAssets =>
      $$AiModelAssetsTableTableManager(_db, _db.aiModelAssets);
  $$RagIndexRecordsTableTableManager get ragIndexRecords =>
      $$RagIndexRecordsTableTableManager(_db, _db.ragIndexRecords);
}
