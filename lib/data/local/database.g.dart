// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $LocalUsersTable extends LocalUsers
    with TableInfo<$LocalUsersTable, LocalUser> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalUsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 36),
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _usernameMeta =
      const VerificationMeta('username');
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
      'username', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 3, maxTextLength: 64),
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _remoteIdMeta =
      const VerificationMeta('remoteId');
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
      'remote_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _pinHashMeta =
      const VerificationMeta('pinHash');
  @override
  late final GeneratedColumn<String> pinHash = GeneratedColumn<String>(
      'pin_hash', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _pinSaltMeta =
      const VerificationMeta('pinSalt');
  @override
  late final GeneratedColumn<String> pinSalt = GeneratedColumn<String>(
      'pin_salt', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _pinUpdatedAtMeta =
      const VerificationMeta('pinUpdatedAt');
  @override
  late final GeneratedColumn<DateTime> pinUpdatedAt = GeneratedColumn<DateTime>(
      'pin_updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _isDirtyMeta =
      const VerificationMeta('isDirty');
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
      'is_dirty', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_dirty" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _syncedAtMeta =
      const VerificationMeta('syncedAt');
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
      'synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        uuid,
        username,
        remoteId,
        pinHash,
        pinSalt,
        pinUpdatedAt,
        isDirty,
        isDeleted,
        syncedAt,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_users';
  @override
  VerificationContext validateIntegrity(Insertable<LocalUser> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('username')) {
      context.handle(_usernameMeta,
          username.isAcceptableOrUnknown(data['username']!, _usernameMeta));
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('remote_id')) {
      context.handle(_remoteIdMeta,
          remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta));
    }
    if (data.containsKey('pin_hash')) {
      context.handle(_pinHashMeta,
          pinHash.isAcceptableOrUnknown(data['pin_hash']!, _pinHashMeta));
    }
    if (data.containsKey('pin_salt')) {
      context.handle(_pinSaltMeta,
          pinSalt.isAcceptableOrUnknown(data['pin_salt']!, _pinSaltMeta));
    }
    if (data.containsKey('pin_updated_at')) {
      context.handle(
          _pinUpdatedAtMeta,
          pinUpdatedAt.isAcceptableOrUnknown(
              data['pin_updated_at']!, _pinUpdatedAtMeta));
    }
    if (data.containsKey('is_dirty')) {
      context.handle(_isDirtyMeta,
          isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('synced_at')) {
      context.handle(_syncedAtMeta,
          syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalUser map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalUser(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      username: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}username'])!,
      remoteId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}remote_id']),
      pinHash: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}pin_hash']),
      pinSalt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}pin_salt']),
      pinUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}pin_updated_at']),
      isDirty: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_dirty'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      syncedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}synced_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $LocalUsersTable createAlias(String alias) {
    return $LocalUsersTable(attachedDatabase, alias);
  }
}

class LocalUser extends DataClass implements Insertable<LocalUser> {
  final int id;
  final String uuid;
  final String username;
  final String? remoteId;
  final String? pinHash;
  final String? pinSalt;
  final DateTime? pinUpdatedAt;
  final bool isDirty;
  final bool isDeleted;
  final DateTime? syncedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const LocalUser(
      {required this.id,
      required this.uuid,
      required this.username,
      this.remoteId,
      this.pinHash,
      this.pinSalt,
      this.pinUpdatedAt,
      required this.isDirty,
      required this.isDeleted,
      this.syncedAt,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uuid'] = Variable<String>(uuid);
    map['username'] = Variable<String>(username);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<String>(remoteId);
    }
    if (!nullToAbsent || pinHash != null) {
      map['pin_hash'] = Variable<String>(pinHash);
    }
    if (!nullToAbsent || pinSalt != null) {
      map['pin_salt'] = Variable<String>(pinSalt);
    }
    if (!nullToAbsent || pinUpdatedAt != null) {
      map['pin_updated_at'] = Variable<DateTime>(pinUpdatedAt);
    }
    map['is_dirty'] = Variable<bool>(isDirty);
    map['is_deleted'] = Variable<bool>(isDeleted);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalUsersCompanion toCompanion(bool nullToAbsent) {
    return LocalUsersCompanion(
      id: Value(id),
      uuid: Value(uuid),
      username: Value(username),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      pinHash: pinHash == null && nullToAbsent
          ? const Value.absent()
          : Value(pinHash),
      pinSalt: pinSalt == null && nullToAbsent
          ? const Value.absent()
          : Value(pinSalt),
      pinUpdatedAt: pinUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(pinUpdatedAt),
      isDirty: Value(isDirty),
      isDeleted: Value(isDeleted),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalUser.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalUser(
      id: serializer.fromJson<int>(json['id']),
      uuid: serializer.fromJson<String>(json['uuid']),
      username: serializer.fromJson<String>(json['username']),
      remoteId: serializer.fromJson<String?>(json['remoteId']),
      pinHash: serializer.fromJson<String?>(json['pinHash']),
      pinSalt: serializer.fromJson<String?>(json['pinSalt']),
      pinUpdatedAt: serializer.fromJson<DateTime?>(json['pinUpdatedAt']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uuid': serializer.toJson<String>(uuid),
      'username': serializer.toJson<String>(username),
      'remoteId': serializer.toJson<String?>(remoteId),
      'pinHash': serializer.toJson<String?>(pinHash),
      'pinSalt': serializer.toJson<String?>(pinSalt),
      'pinUpdatedAt': serializer.toJson<DateTime?>(pinUpdatedAt),
      'isDirty': serializer.toJson<bool>(isDirty),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalUser copyWith(
          {int? id,
          String? uuid,
          String? username,
          Value<String?> remoteId = const Value.absent(),
          Value<String?> pinHash = const Value.absent(),
          Value<String?> pinSalt = const Value.absent(),
          Value<DateTime?> pinUpdatedAt = const Value.absent(),
          bool? isDirty,
          bool? isDeleted,
          Value<DateTime?> syncedAt = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      LocalUser(
        id: id ?? this.id,
        uuid: uuid ?? this.uuid,
        username: username ?? this.username,
        remoteId: remoteId.present ? remoteId.value : this.remoteId,
        pinHash: pinHash.present ? pinHash.value : this.pinHash,
        pinSalt: pinSalt.present ? pinSalt.value : this.pinSalt,
        pinUpdatedAt:
            pinUpdatedAt.present ? pinUpdatedAt.value : this.pinUpdatedAt,
        isDirty: isDirty ?? this.isDirty,
        isDeleted: isDeleted ?? this.isDeleted,
        syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  LocalUser copyWithCompanion(LocalUsersCompanion data) {
    return LocalUser(
      id: data.id.present ? data.id.value : this.id,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      username: data.username.present ? data.username.value : this.username,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      pinHash: data.pinHash.present ? data.pinHash.value : this.pinHash,
      pinSalt: data.pinSalt.present ? data.pinSalt.value : this.pinSalt,
      pinUpdatedAt: data.pinUpdatedAt.present
          ? data.pinUpdatedAt.value
          : this.pinUpdatedAt,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalUser(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('username: $username, ')
          ..write('remoteId: $remoteId, ')
          ..write('pinHash: $pinHash, ')
          ..write('pinSalt: $pinSalt, ')
          ..write('pinUpdatedAt: $pinUpdatedAt, ')
          ..write('isDirty: $isDirty, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      uuid,
      username,
      remoteId,
      pinHash,
      pinSalt,
      pinUpdatedAt,
      isDirty,
      isDeleted,
      syncedAt,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalUser &&
          other.id == this.id &&
          other.uuid == this.uuid &&
          other.username == this.username &&
          other.remoteId == this.remoteId &&
          other.pinHash == this.pinHash &&
          other.pinSalt == this.pinSalt &&
          other.pinUpdatedAt == this.pinUpdatedAt &&
          other.isDirty == this.isDirty &&
          other.isDeleted == this.isDeleted &&
          other.syncedAt == this.syncedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LocalUsersCompanion extends UpdateCompanion<LocalUser> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<String> username;
  final Value<String?> remoteId;
  final Value<String?> pinHash;
  final Value<String?> pinSalt;
  final Value<DateTime?> pinUpdatedAt;
  final Value<bool> isDirty;
  final Value<bool> isDeleted;
  final Value<DateTime?> syncedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const LocalUsersCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.username = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.pinHash = const Value.absent(),
    this.pinSalt = const Value.absent(),
    this.pinUpdatedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  LocalUsersCompanion.insert({
    this.id = const Value.absent(),
    required String uuid,
    required String username,
    this.remoteId = const Value.absent(),
    this.pinHash = const Value.absent(),
    this.pinSalt = const Value.absent(),
    this.pinUpdatedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : uuid = Value(uuid),
        username = Value(username);
  static Insertable<LocalUser> custom({
    Expression<int>? id,
    Expression<String>? uuid,
    Expression<String>? username,
    Expression<String>? remoteId,
    Expression<String>? pinHash,
    Expression<String>? pinSalt,
    Expression<DateTime>? pinUpdatedAt,
    Expression<bool>? isDirty,
    Expression<bool>? isDeleted,
    Expression<DateTime>? syncedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (username != null) 'username': username,
      if (remoteId != null) 'remote_id': remoteId,
      if (pinHash != null) 'pin_hash': pinHash,
      if (pinSalt != null) 'pin_salt': pinSalt,
      if (pinUpdatedAt != null) 'pin_updated_at': pinUpdatedAt,
      if (isDirty != null) 'is_dirty': isDirty,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  LocalUsersCompanion copyWith(
      {Value<int>? id,
      Value<String>? uuid,
      Value<String>? username,
      Value<String?>? remoteId,
      Value<String?>? pinHash,
      Value<String?>? pinSalt,
      Value<DateTime?>? pinUpdatedAt,
      Value<bool>? isDirty,
      Value<bool>? isDeleted,
      Value<DateTime?>? syncedAt,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return LocalUsersCompanion(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      username: username ?? this.username,
      remoteId: remoteId ?? this.remoteId,
      pinHash: pinHash ?? this.pinHash,
      pinSalt: pinSalt ?? this.pinSalt,
      pinUpdatedAt: pinUpdatedAt ?? this.pinUpdatedAt,
      isDirty: isDirty ?? this.isDirty,
      isDeleted: isDeleted ?? this.isDeleted,
      syncedAt: syncedAt ?? this.syncedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (pinHash.present) {
      map['pin_hash'] = Variable<String>(pinHash.value);
    }
    if (pinSalt.present) {
      map['pin_salt'] = Variable<String>(pinSalt.value);
    }
    if (pinUpdatedAt.present) {
      map['pin_updated_at'] = Variable<DateTime>(pinUpdatedAt.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalUsersCompanion(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('username: $username, ')
          ..write('remoteId: $remoteId, ')
          ..write('pinHash: $pinHash, ')
          ..write('pinSalt: $pinSalt, ')
          ..write('pinUpdatedAt: $pinUpdatedAt, ')
          ..write('isDirty: $isDirty, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $BooksTable extends Books with TableInfo<$BooksTable, Book> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BooksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 36),
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _remoteIdMeta =
      const VerificationMeta('remoteId');
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
      'remote_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _ownerUserIdMeta =
      const VerificationMeta('ownerUserId');
  @override
  late final GeneratedColumn<int> ownerUserId = GeneratedColumn<int>(
      'owner_user_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES local_users (id)'));
  static const VerificationMeta _ownerRemoteIdMeta =
      const VerificationMeta('ownerRemoteId');
  @override
  late final GeneratedColumn<String> ownerRemoteId = GeneratedColumn<String>(
      'owner_remote_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 255),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
      'author', aliasedName, true,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 255),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _isbnMeta = const VerificationMeta('isbn');
  @override
  late final GeneratedColumn<String> isbn = GeneratedColumn<String>(
      'isbn', aliasedName, true,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 10, maxTextLength: 20),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _barcodeMeta =
      const VerificationMeta('barcode');
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
      'barcode', aliasedName, true,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 64),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _coverPathMeta =
      const VerificationMeta('coverPath');
  @override
  late final GeneratedColumn<String> coverPath = GeneratedColumn<String>(
      'cover_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('available'));
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isReadMeta = const VerificationMeta('isRead');
  @override
  late final GeneratedColumn<bool> isRead = GeneratedColumn<bool>(
      'is_read', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_read" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isDirtyMeta =
      const VerificationMeta('isDirty');
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
      'is_dirty', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_dirty" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _syncedAtMeta =
      const VerificationMeta('syncedAt');
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
      'synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        uuid,
        remoteId,
        ownerUserId,
        ownerRemoteId,
        title,
        author,
        isbn,
        barcode,
        coverPath,
        status,
        notes,
        isRead,
        isDirty,
        isDeleted,
        syncedAt,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'books';
  @override
  VerificationContext validateIntegrity(Insertable<Book> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('remote_id')) {
      context.handle(_remoteIdMeta,
          remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta));
    }
    if (data.containsKey('owner_user_id')) {
      context.handle(
          _ownerUserIdMeta,
          ownerUserId.isAcceptableOrUnknown(
              data['owner_user_id']!, _ownerUserIdMeta));
    }
    if (data.containsKey('owner_remote_id')) {
      context.handle(
          _ownerRemoteIdMeta,
          ownerRemoteId.isAcceptableOrUnknown(
              data['owner_remote_id']!, _ownerRemoteIdMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('author')) {
      context.handle(_authorMeta,
          author.isAcceptableOrUnknown(data['author']!, _authorMeta));
    }
    if (data.containsKey('isbn')) {
      context.handle(
          _isbnMeta, isbn.isAcceptableOrUnknown(data['isbn']!, _isbnMeta));
    }
    if (data.containsKey('barcode')) {
      context.handle(_barcodeMeta,
          barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta));
    }
    if (data.containsKey('cover_path')) {
      context.handle(_coverPathMeta,
          coverPath.isAcceptableOrUnknown(data['cover_path']!, _coverPathMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('is_read')) {
      context.handle(_isReadMeta,
          isRead.isAcceptableOrUnknown(data['is_read']!, _isReadMeta));
    }
    if (data.containsKey('is_dirty')) {
      context.handle(_isDirtyMeta,
          isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('synced_at')) {
      context.handle(_syncedAtMeta,
          syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Book map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Book(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      remoteId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}remote_id']),
      ownerUserId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}owner_user_id']),
      ownerRemoteId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}owner_remote_id']),
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      author: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}author']),
      isbn: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}isbn']),
      barcode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}barcode']),
      coverPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cover_path']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      isRead: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_read'])!,
      isDirty: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_dirty'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      syncedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}synced_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $BooksTable createAlias(String alias) {
    return $BooksTable(attachedDatabase, alias);
  }
}

class Book extends DataClass implements Insertable<Book> {
  final int id;
  final String uuid;
  final String? remoteId;
  final int? ownerUserId;
  final String? ownerRemoteId;
  final String title;
  final String? author;
  final String? isbn;
  final String? barcode;
  final String? coverPath;
  final String status;
  final String? notes;
  final bool isRead;
  final bool isDirty;
  final bool isDeleted;
  final DateTime? syncedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Book(
      {required this.id,
      required this.uuid,
      this.remoteId,
      this.ownerUserId,
      this.ownerRemoteId,
      required this.title,
      this.author,
      this.isbn,
      this.barcode,
      this.coverPath,
      required this.status,
      this.notes,
      required this.isRead,
      required this.isDirty,
      required this.isDeleted,
      this.syncedAt,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uuid'] = Variable<String>(uuid);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<String>(remoteId);
    }
    if (!nullToAbsent || ownerUserId != null) {
      map['owner_user_id'] = Variable<int>(ownerUserId);
    }
    if (!nullToAbsent || ownerRemoteId != null) {
      map['owner_remote_id'] = Variable<String>(ownerRemoteId);
    }
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || author != null) {
      map['author'] = Variable<String>(author);
    }
    if (!nullToAbsent || isbn != null) {
      map['isbn'] = Variable<String>(isbn);
    }
    if (!nullToAbsent || barcode != null) {
      map['barcode'] = Variable<String>(barcode);
    }
    if (!nullToAbsent || coverPath != null) {
      map['cover_path'] = Variable<String>(coverPath);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['is_read'] = Variable<bool>(isRead);
    map['is_dirty'] = Variable<bool>(isDirty);
    map['is_deleted'] = Variable<bool>(isDeleted);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  BooksCompanion toCompanion(bool nullToAbsent) {
    return BooksCompanion(
      id: Value(id),
      uuid: Value(uuid),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      ownerUserId: ownerUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerUserId),
      ownerRemoteId: ownerRemoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerRemoteId),
      title: Value(title),
      author:
          author == null && nullToAbsent ? const Value.absent() : Value(author),
      isbn: isbn == null && nullToAbsent ? const Value.absent() : Value(isbn),
      barcode: barcode == null && nullToAbsent
          ? const Value.absent()
          : Value(barcode),
      coverPath: coverPath == null && nullToAbsent
          ? const Value.absent()
          : Value(coverPath),
      status: Value(status),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      isRead: Value(isRead),
      isDirty: Value(isDirty),
      isDeleted: Value(isDeleted),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Book.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Book(
      id: serializer.fromJson<int>(json['id']),
      uuid: serializer.fromJson<String>(json['uuid']),
      remoteId: serializer.fromJson<String?>(json['remoteId']),
      ownerUserId: serializer.fromJson<int?>(json['ownerUserId']),
      ownerRemoteId: serializer.fromJson<String?>(json['ownerRemoteId']),
      title: serializer.fromJson<String>(json['title']),
      author: serializer.fromJson<String?>(json['author']),
      isbn: serializer.fromJson<String?>(json['isbn']),
      barcode: serializer.fromJson<String?>(json['barcode']),
      coverPath: serializer.fromJson<String?>(json['coverPath']),
      status: serializer.fromJson<String>(json['status']),
      notes: serializer.fromJson<String?>(json['notes']),
      isRead: serializer.fromJson<bool>(json['isRead']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uuid': serializer.toJson<String>(uuid),
      'remoteId': serializer.toJson<String?>(remoteId),
      'ownerUserId': serializer.toJson<int?>(ownerUserId),
      'ownerRemoteId': serializer.toJson<String?>(ownerRemoteId),
      'title': serializer.toJson<String>(title),
      'author': serializer.toJson<String?>(author),
      'isbn': serializer.toJson<String?>(isbn),
      'barcode': serializer.toJson<String?>(barcode),
      'coverPath': serializer.toJson<String?>(coverPath),
      'status': serializer.toJson<String>(status),
      'notes': serializer.toJson<String?>(notes),
      'isRead': serializer.toJson<bool>(isRead),
      'isDirty': serializer.toJson<bool>(isDirty),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Book copyWith(
          {int? id,
          String? uuid,
          Value<String?> remoteId = const Value.absent(),
          Value<int?> ownerUserId = const Value.absent(),
          Value<String?> ownerRemoteId = const Value.absent(),
          String? title,
          Value<String?> author = const Value.absent(),
          Value<String?> isbn = const Value.absent(),
          Value<String?> barcode = const Value.absent(),
          Value<String?> coverPath = const Value.absent(),
          String? status,
          Value<String?> notes = const Value.absent(),
          bool? isRead,
          bool? isDirty,
          bool? isDeleted,
          Value<DateTime?> syncedAt = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Book(
        id: id ?? this.id,
        uuid: uuid ?? this.uuid,
        remoteId: remoteId.present ? remoteId.value : this.remoteId,
        ownerUserId: ownerUserId.present ? ownerUserId.value : this.ownerUserId,
        ownerRemoteId:
            ownerRemoteId.present ? ownerRemoteId.value : this.ownerRemoteId,
        title: title ?? this.title,
        author: author.present ? author.value : this.author,
        isbn: isbn.present ? isbn.value : this.isbn,
        barcode: barcode.present ? barcode.value : this.barcode,
        coverPath: coverPath.present ? coverPath.value : this.coverPath,
        status: status ?? this.status,
        notes: notes.present ? notes.value : this.notes,
        isRead: isRead ?? this.isRead,
        isDirty: isDirty ?? this.isDirty,
        isDeleted: isDeleted ?? this.isDeleted,
        syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Book copyWithCompanion(BooksCompanion data) {
    return Book(
      id: data.id.present ? data.id.value : this.id,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      ownerUserId:
          data.ownerUserId.present ? data.ownerUserId.value : this.ownerUserId,
      ownerRemoteId: data.ownerRemoteId.present
          ? data.ownerRemoteId.value
          : this.ownerRemoteId,
      title: data.title.present ? data.title.value : this.title,
      author: data.author.present ? data.author.value : this.author,
      isbn: data.isbn.present ? data.isbn.value : this.isbn,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      coverPath: data.coverPath.present ? data.coverPath.value : this.coverPath,
      status: data.status.present ? data.status.value : this.status,
      notes: data.notes.present ? data.notes.value : this.notes,
      isRead: data.isRead.present ? data.isRead.value : this.isRead,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Book(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('remoteId: $remoteId, ')
          ..write('ownerUserId: $ownerUserId, ')
          ..write('ownerRemoteId: $ownerRemoteId, ')
          ..write('title: $title, ')
          ..write('author: $author, ')
          ..write('isbn: $isbn, ')
          ..write('barcode: $barcode, ')
          ..write('coverPath: $coverPath, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('isRead: $isRead, ')
          ..write('isDirty: $isDirty, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      uuid,
      remoteId,
      ownerUserId,
      ownerRemoteId,
      title,
      author,
      isbn,
      barcode,
      coverPath,
      status,
      notes,
      isRead,
      isDirty,
      isDeleted,
      syncedAt,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Book &&
          other.id == this.id &&
          other.uuid == this.uuid &&
          other.remoteId == this.remoteId &&
          other.ownerUserId == this.ownerUserId &&
          other.ownerRemoteId == this.ownerRemoteId &&
          other.title == this.title &&
          other.author == this.author &&
          other.isbn == this.isbn &&
          other.barcode == this.barcode &&
          other.coverPath == this.coverPath &&
          other.status == this.status &&
          other.notes == this.notes &&
          other.isRead == this.isRead &&
          other.isDirty == this.isDirty &&
          other.isDeleted == this.isDeleted &&
          other.syncedAt == this.syncedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class BooksCompanion extends UpdateCompanion<Book> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<String?> remoteId;
  final Value<int?> ownerUserId;
  final Value<String?> ownerRemoteId;
  final Value<String> title;
  final Value<String?> author;
  final Value<String?> isbn;
  final Value<String?> barcode;
  final Value<String?> coverPath;
  final Value<String> status;
  final Value<String?> notes;
  final Value<bool> isRead;
  final Value<bool> isDirty;
  final Value<bool> isDeleted;
  final Value<DateTime?> syncedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const BooksCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.ownerUserId = const Value.absent(),
    this.ownerRemoteId = const Value.absent(),
    this.title = const Value.absent(),
    this.author = const Value.absent(),
    this.isbn = const Value.absent(),
    this.barcode = const Value.absent(),
    this.coverPath = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.isRead = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  BooksCompanion.insert({
    this.id = const Value.absent(),
    required String uuid,
    this.remoteId = const Value.absent(),
    this.ownerUserId = const Value.absent(),
    this.ownerRemoteId = const Value.absent(),
    required String title,
    this.author = const Value.absent(),
    this.isbn = const Value.absent(),
    this.barcode = const Value.absent(),
    this.coverPath = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.isRead = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : uuid = Value(uuid),
        title = Value(title);
  static Insertable<Book> custom({
    Expression<int>? id,
    Expression<String>? uuid,
    Expression<String>? remoteId,
    Expression<int>? ownerUserId,
    Expression<String>? ownerRemoteId,
    Expression<String>? title,
    Expression<String>? author,
    Expression<String>? isbn,
    Expression<String>? barcode,
    Expression<String>? coverPath,
    Expression<String>? status,
    Expression<String>? notes,
    Expression<bool>? isRead,
    Expression<bool>? isDirty,
    Expression<bool>? isDeleted,
    Expression<DateTime>? syncedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (remoteId != null) 'remote_id': remoteId,
      if (ownerUserId != null) 'owner_user_id': ownerUserId,
      if (ownerRemoteId != null) 'owner_remote_id': ownerRemoteId,
      if (title != null) 'title': title,
      if (author != null) 'author': author,
      if (isbn != null) 'isbn': isbn,
      if (barcode != null) 'barcode': barcode,
      if (coverPath != null) 'cover_path': coverPath,
      if (status != null) 'status': status,
      if (notes != null) 'notes': notes,
      if (isRead != null) 'is_read': isRead,
      if (isDirty != null) 'is_dirty': isDirty,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  BooksCompanion copyWith(
      {Value<int>? id,
      Value<String>? uuid,
      Value<String?>? remoteId,
      Value<int?>? ownerUserId,
      Value<String?>? ownerRemoteId,
      Value<String>? title,
      Value<String?>? author,
      Value<String?>? isbn,
      Value<String?>? barcode,
      Value<String?>? coverPath,
      Value<String>? status,
      Value<String?>? notes,
      Value<bool>? isRead,
      Value<bool>? isDirty,
      Value<bool>? isDeleted,
      Value<DateTime?>? syncedAt,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return BooksCompanion(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      remoteId: remoteId ?? this.remoteId,
      ownerUserId: ownerUserId ?? this.ownerUserId,
      ownerRemoteId: ownerRemoteId ?? this.ownerRemoteId,
      title: title ?? this.title,
      author: author ?? this.author,
      isbn: isbn ?? this.isbn,
      barcode: barcode ?? this.barcode,
      coverPath: coverPath ?? this.coverPath,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      isRead: isRead ?? this.isRead,
      isDirty: isDirty ?? this.isDirty,
      isDeleted: isDeleted ?? this.isDeleted,
      syncedAt: syncedAt ?? this.syncedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (ownerUserId.present) {
      map['owner_user_id'] = Variable<int>(ownerUserId.value);
    }
    if (ownerRemoteId.present) {
      map['owner_remote_id'] = Variable<String>(ownerRemoteId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (isbn.present) {
      map['isbn'] = Variable<String>(isbn.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (coverPath.present) {
      map['cover_path'] = Variable<String>(coverPath.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isRead.present) {
      map['is_read'] = Variable<bool>(isRead.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BooksCompanion(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('remoteId: $remoteId, ')
          ..write('ownerUserId: $ownerUserId, ')
          ..write('ownerRemoteId: $ownerRemoteId, ')
          ..write('title: $title, ')
          ..write('author: $author, ')
          ..write('isbn: $isbn, ')
          ..write('barcode: $barcode, ')
          ..write('coverPath: $coverPath, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('isRead: $isRead, ')
          ..write('isDirty: $isDirty, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $BookReviewsTable extends BookReviews
    with TableInfo<$BookReviewsTable, BookReview> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookReviewsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 36),
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _remoteIdMeta =
      const VerificationMeta('remoteId');
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
      'remote_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<int> bookId = GeneratedColumn<int>(
      'book_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES books (id) ON DELETE CASCADE'));
  static const VerificationMeta _bookUuidMeta =
      const VerificationMeta('bookUuid');
  @override
  late final GeneratedColumn<String> bookUuid = GeneratedColumn<String>(
      'book_uuid', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 36),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _authorUserIdMeta =
      const VerificationMeta('authorUserId');
  @override
  late final GeneratedColumn<int> authorUserId = GeneratedColumn<int>(
      'author_user_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES local_users (id)'));
  static const VerificationMeta _authorRemoteIdMeta =
      const VerificationMeta('authorRemoteId');
  @override
  late final GeneratedColumn<String> authorRemoteId = GeneratedColumn<String>(
      'author_remote_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<int> rating = GeneratedColumn<int>(
      'rating', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL CHECK (rating BETWEEN 1 AND 5)');
  static const VerificationMeta _reviewMeta = const VerificationMeta('review');
  @override
  late final GeneratedColumn<String> review = GeneratedColumn<String>(
      'review', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isDirtyMeta =
      const VerificationMeta('isDirty');
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
      'is_dirty', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_dirty" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _syncedAtMeta =
      const VerificationMeta('syncedAt');
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
      'synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        uuid,
        remoteId,
        bookId,
        bookUuid,
        authorUserId,
        authorRemoteId,
        rating,
        review,
        isDirty,
        isDeleted,
        syncedAt,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'book_reviews';
  @override
  VerificationContext validateIntegrity(Insertable<BookReview> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('remote_id')) {
      context.handle(_remoteIdMeta,
          remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta));
    }
    if (data.containsKey('book_id')) {
      context.handle(_bookIdMeta,
          bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta));
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('book_uuid')) {
      context.handle(_bookUuidMeta,
          bookUuid.isAcceptableOrUnknown(data['book_uuid']!, _bookUuidMeta));
    } else if (isInserting) {
      context.missing(_bookUuidMeta);
    }
    if (data.containsKey('author_user_id')) {
      context.handle(
          _authorUserIdMeta,
          authorUserId.isAcceptableOrUnknown(
              data['author_user_id']!, _authorUserIdMeta));
    } else if (isInserting) {
      context.missing(_authorUserIdMeta);
    }
    if (data.containsKey('author_remote_id')) {
      context.handle(
          _authorRemoteIdMeta,
          authorRemoteId.isAcceptableOrUnknown(
              data['author_remote_id']!, _authorRemoteIdMeta));
    }
    if (data.containsKey('rating')) {
      context.handle(_ratingMeta,
          rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta));
    } else if (isInserting) {
      context.missing(_ratingMeta);
    }
    if (data.containsKey('review')) {
      context.handle(_reviewMeta,
          review.isAcceptableOrUnknown(data['review']!, _reviewMeta));
    }
    if (data.containsKey('is_dirty')) {
      context.handle(_isDirtyMeta,
          isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('synced_at')) {
      context.handle(_syncedAtMeta,
          syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {bookId, authorUserId},
      ];
  @override
  BookReview map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookReview(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      remoteId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}remote_id']),
      bookId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}book_id'])!,
      bookUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}book_uuid'])!,
      authorUserId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}author_user_id'])!,
      authorRemoteId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}author_remote_id']),
      rating: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}rating'])!,
      review: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}review']),
      isDirty: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_dirty'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      syncedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}synced_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $BookReviewsTable createAlias(String alias) {
    return $BookReviewsTable(attachedDatabase, alias);
  }
}

class BookReview extends DataClass implements Insertable<BookReview> {
  final int id;
  final String uuid;
  final String? remoteId;
  final int bookId;
  final String bookUuid;
  final int authorUserId;
  final String? authorRemoteId;
  final int rating;
  final String? review;
  final bool isDirty;
  final bool isDeleted;
  final DateTime? syncedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const BookReview(
      {required this.id,
      required this.uuid,
      this.remoteId,
      required this.bookId,
      required this.bookUuid,
      required this.authorUserId,
      this.authorRemoteId,
      required this.rating,
      this.review,
      required this.isDirty,
      required this.isDeleted,
      this.syncedAt,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uuid'] = Variable<String>(uuid);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<String>(remoteId);
    }
    map['book_id'] = Variable<int>(bookId);
    map['book_uuid'] = Variable<String>(bookUuid);
    map['author_user_id'] = Variable<int>(authorUserId);
    if (!nullToAbsent || authorRemoteId != null) {
      map['author_remote_id'] = Variable<String>(authorRemoteId);
    }
    map['rating'] = Variable<int>(rating);
    if (!nullToAbsent || review != null) {
      map['review'] = Variable<String>(review);
    }
    map['is_dirty'] = Variable<bool>(isDirty);
    map['is_deleted'] = Variable<bool>(isDeleted);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  BookReviewsCompanion toCompanion(bool nullToAbsent) {
    return BookReviewsCompanion(
      id: Value(id),
      uuid: Value(uuid),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      bookId: Value(bookId),
      bookUuid: Value(bookUuid),
      authorUserId: Value(authorUserId),
      authorRemoteId: authorRemoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(authorRemoteId),
      rating: Value(rating),
      review:
          review == null && nullToAbsent ? const Value.absent() : Value(review),
      isDirty: Value(isDirty),
      isDeleted: Value(isDeleted),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory BookReview.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookReview(
      id: serializer.fromJson<int>(json['id']),
      uuid: serializer.fromJson<String>(json['uuid']),
      remoteId: serializer.fromJson<String?>(json['remoteId']),
      bookId: serializer.fromJson<int>(json['bookId']),
      bookUuid: serializer.fromJson<String>(json['bookUuid']),
      authorUserId: serializer.fromJson<int>(json['authorUserId']),
      authorRemoteId: serializer.fromJson<String?>(json['authorRemoteId']),
      rating: serializer.fromJson<int>(json['rating']),
      review: serializer.fromJson<String?>(json['review']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uuid': serializer.toJson<String>(uuid),
      'remoteId': serializer.toJson<String?>(remoteId),
      'bookId': serializer.toJson<int>(bookId),
      'bookUuid': serializer.toJson<String>(bookUuid),
      'authorUserId': serializer.toJson<int>(authorUserId),
      'authorRemoteId': serializer.toJson<String?>(authorRemoteId),
      'rating': serializer.toJson<int>(rating),
      'review': serializer.toJson<String?>(review),
      'isDirty': serializer.toJson<bool>(isDirty),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  BookReview copyWith(
          {int? id,
          String? uuid,
          Value<String?> remoteId = const Value.absent(),
          int? bookId,
          String? bookUuid,
          int? authorUserId,
          Value<String?> authorRemoteId = const Value.absent(),
          int? rating,
          Value<String?> review = const Value.absent(),
          bool? isDirty,
          bool? isDeleted,
          Value<DateTime?> syncedAt = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      BookReview(
        id: id ?? this.id,
        uuid: uuid ?? this.uuid,
        remoteId: remoteId.present ? remoteId.value : this.remoteId,
        bookId: bookId ?? this.bookId,
        bookUuid: bookUuid ?? this.bookUuid,
        authorUserId: authorUserId ?? this.authorUserId,
        authorRemoteId:
            authorRemoteId.present ? authorRemoteId.value : this.authorRemoteId,
        rating: rating ?? this.rating,
        review: review.present ? review.value : this.review,
        isDirty: isDirty ?? this.isDirty,
        isDeleted: isDeleted ?? this.isDeleted,
        syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  BookReview copyWithCompanion(BookReviewsCompanion data) {
    return BookReview(
      id: data.id.present ? data.id.value : this.id,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      bookUuid: data.bookUuid.present ? data.bookUuid.value : this.bookUuid,
      authorUserId: data.authorUserId.present
          ? data.authorUserId.value
          : this.authorUserId,
      authorRemoteId: data.authorRemoteId.present
          ? data.authorRemoteId.value
          : this.authorRemoteId,
      rating: data.rating.present ? data.rating.value : this.rating,
      review: data.review.present ? data.review.value : this.review,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookReview(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('remoteId: $remoteId, ')
          ..write('bookId: $bookId, ')
          ..write('bookUuid: $bookUuid, ')
          ..write('authorUserId: $authorUserId, ')
          ..write('authorRemoteId: $authorRemoteId, ')
          ..write('rating: $rating, ')
          ..write('review: $review, ')
          ..write('isDirty: $isDirty, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      uuid,
      remoteId,
      bookId,
      bookUuid,
      authorUserId,
      authorRemoteId,
      rating,
      review,
      isDirty,
      isDeleted,
      syncedAt,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookReview &&
          other.id == this.id &&
          other.uuid == this.uuid &&
          other.remoteId == this.remoteId &&
          other.bookId == this.bookId &&
          other.bookUuid == this.bookUuid &&
          other.authorUserId == this.authorUserId &&
          other.authorRemoteId == this.authorRemoteId &&
          other.rating == this.rating &&
          other.review == this.review &&
          other.isDirty == this.isDirty &&
          other.isDeleted == this.isDeleted &&
          other.syncedAt == this.syncedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class BookReviewsCompanion extends UpdateCompanion<BookReview> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<String?> remoteId;
  final Value<int> bookId;
  final Value<String> bookUuid;
  final Value<int> authorUserId;
  final Value<String?> authorRemoteId;
  final Value<int> rating;
  final Value<String?> review;
  final Value<bool> isDirty;
  final Value<bool> isDeleted;
  final Value<DateTime?> syncedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const BookReviewsCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.bookId = const Value.absent(),
    this.bookUuid = const Value.absent(),
    this.authorUserId = const Value.absent(),
    this.authorRemoteId = const Value.absent(),
    this.rating = const Value.absent(),
    this.review = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  BookReviewsCompanion.insert({
    this.id = const Value.absent(),
    required String uuid,
    this.remoteId = const Value.absent(),
    required int bookId,
    required String bookUuid,
    required int authorUserId,
    this.authorRemoteId = const Value.absent(),
    required int rating,
    this.review = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : uuid = Value(uuid),
        bookId = Value(bookId),
        bookUuid = Value(bookUuid),
        authorUserId = Value(authorUserId),
        rating = Value(rating);
  static Insertable<BookReview> custom({
    Expression<int>? id,
    Expression<String>? uuid,
    Expression<String>? remoteId,
    Expression<int>? bookId,
    Expression<String>? bookUuid,
    Expression<int>? authorUserId,
    Expression<String>? authorRemoteId,
    Expression<int>? rating,
    Expression<String>? review,
    Expression<bool>? isDirty,
    Expression<bool>? isDeleted,
    Expression<DateTime>? syncedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (remoteId != null) 'remote_id': remoteId,
      if (bookId != null) 'book_id': bookId,
      if (bookUuid != null) 'book_uuid': bookUuid,
      if (authorUserId != null) 'author_user_id': authorUserId,
      if (authorRemoteId != null) 'author_remote_id': authorRemoteId,
      if (rating != null) 'rating': rating,
      if (review != null) 'review': review,
      if (isDirty != null) 'is_dirty': isDirty,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  BookReviewsCompanion copyWith(
      {Value<int>? id,
      Value<String>? uuid,
      Value<String?>? remoteId,
      Value<int>? bookId,
      Value<String>? bookUuid,
      Value<int>? authorUserId,
      Value<String?>? authorRemoteId,
      Value<int>? rating,
      Value<String?>? review,
      Value<bool>? isDirty,
      Value<bool>? isDeleted,
      Value<DateTime?>? syncedAt,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return BookReviewsCompanion(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      remoteId: remoteId ?? this.remoteId,
      bookId: bookId ?? this.bookId,
      bookUuid: bookUuid ?? this.bookUuid,
      authorUserId: authorUserId ?? this.authorUserId,
      authorRemoteId: authorRemoteId ?? this.authorRemoteId,
      rating: rating ?? this.rating,
      review: review ?? this.review,
      isDirty: isDirty ?? this.isDirty,
      isDeleted: isDeleted ?? this.isDeleted,
      syncedAt: syncedAt ?? this.syncedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<int>(bookId.value);
    }
    if (bookUuid.present) {
      map['book_uuid'] = Variable<String>(bookUuid.value);
    }
    if (authorUserId.present) {
      map['author_user_id'] = Variable<int>(authorUserId.value);
    }
    if (authorRemoteId.present) {
      map['author_remote_id'] = Variable<String>(authorRemoteId.value);
    }
    if (rating.present) {
      map['rating'] = Variable<int>(rating.value);
    }
    if (review.present) {
      map['review'] = Variable<String>(review.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookReviewsCompanion(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('remoteId: $remoteId, ')
          ..write('bookId: $bookId, ')
          ..write('bookUuid: $bookUuid, ')
          ..write('authorUserId: $authorUserId, ')
          ..write('authorRemoteId: $authorRemoteId, ')
          ..write('rating: $rating, ')
          ..write('review: $review, ')
          ..write('isDirty: $isDirty, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $GroupsTable extends Groups with TableInfo<$GroupsTable, Group> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GroupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 36),
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _remoteIdMeta =
      const VerificationMeta('remoteId');
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
      'remote_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 128),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 0, maxTextLength: 512),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _ownerUserIdMeta =
      const VerificationMeta('ownerUserId');
  @override
  late final GeneratedColumn<int> ownerUserId = GeneratedColumn<int>(
      'owner_user_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES local_users (id)'));
  static const VerificationMeta _ownerRemoteIdMeta =
      const VerificationMeta('ownerRemoteId');
  @override
  late final GeneratedColumn<String> ownerRemoteId = GeneratedColumn<String>(
      'owner_remote_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isDirtyMeta =
      const VerificationMeta('isDirty');
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
      'is_dirty', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_dirty" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _syncedAtMeta =
      const VerificationMeta('syncedAt');
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
      'synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        uuid,
        remoteId,
        name,
        description,
        ownerUserId,
        ownerRemoteId,
        isDirty,
        isDeleted,
        syncedAt,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'groups';
  @override
  VerificationContext validateIntegrity(Insertable<Group> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('remote_id')) {
      context.handle(_remoteIdMeta,
          remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('owner_user_id')) {
      context.handle(
          _ownerUserIdMeta,
          ownerUserId.isAcceptableOrUnknown(
              data['owner_user_id']!, _ownerUserIdMeta));
    }
    if (data.containsKey('owner_remote_id')) {
      context.handle(
          _ownerRemoteIdMeta,
          ownerRemoteId.isAcceptableOrUnknown(
              data['owner_remote_id']!, _ownerRemoteIdMeta));
    }
    if (data.containsKey('is_dirty')) {
      context.handle(_isDirtyMeta,
          isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('synced_at')) {
      context.handle(_syncedAtMeta,
          syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Group map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Group(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      remoteId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}remote_id']),
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      ownerUserId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}owner_user_id']),
      ownerRemoteId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}owner_remote_id']),
      isDirty: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_dirty'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      syncedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}synced_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $GroupsTable createAlias(String alias) {
    return $GroupsTable(attachedDatabase, alias);
  }
}

class Group extends DataClass implements Insertable<Group> {
  final int id;
  final String uuid;
  final String? remoteId;
  final String name;
  final String? description;
  final int? ownerUserId;
  final String? ownerRemoteId;
  final bool isDirty;
  final bool isDeleted;
  final DateTime? syncedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Group(
      {required this.id,
      required this.uuid,
      this.remoteId,
      required this.name,
      this.description,
      this.ownerUserId,
      this.ownerRemoteId,
      required this.isDirty,
      required this.isDeleted,
      this.syncedAt,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uuid'] = Variable<String>(uuid);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<String>(remoteId);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || ownerUserId != null) {
      map['owner_user_id'] = Variable<int>(ownerUserId);
    }
    if (!nullToAbsent || ownerRemoteId != null) {
      map['owner_remote_id'] = Variable<String>(ownerRemoteId);
    }
    map['is_dirty'] = Variable<bool>(isDirty);
    map['is_deleted'] = Variable<bool>(isDeleted);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  GroupsCompanion toCompanion(bool nullToAbsent) {
    return GroupsCompanion(
      id: Value(id),
      uuid: Value(uuid),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      ownerUserId: ownerUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerUserId),
      ownerRemoteId: ownerRemoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerRemoteId),
      isDirty: Value(isDirty),
      isDeleted: Value(isDeleted),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Group.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Group(
      id: serializer.fromJson<int>(json['id']),
      uuid: serializer.fromJson<String>(json['uuid']),
      remoteId: serializer.fromJson<String?>(json['remoteId']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      ownerUserId: serializer.fromJson<int?>(json['ownerUserId']),
      ownerRemoteId: serializer.fromJson<String?>(json['ownerRemoteId']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uuid': serializer.toJson<String>(uuid),
      'remoteId': serializer.toJson<String?>(remoteId),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'ownerUserId': serializer.toJson<int?>(ownerUserId),
      'ownerRemoteId': serializer.toJson<String?>(ownerRemoteId),
      'isDirty': serializer.toJson<bool>(isDirty),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Group copyWith(
          {int? id,
          String? uuid,
          Value<String?> remoteId = const Value.absent(),
          String? name,
          Value<String?> description = const Value.absent(),
          Value<int?> ownerUserId = const Value.absent(),
          Value<String?> ownerRemoteId = const Value.absent(),
          bool? isDirty,
          bool? isDeleted,
          Value<DateTime?> syncedAt = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Group(
        id: id ?? this.id,
        uuid: uuid ?? this.uuid,
        remoteId: remoteId.present ? remoteId.value : this.remoteId,
        name: name ?? this.name,
        description: description.present ? description.value : this.description,
        ownerUserId: ownerUserId.present ? ownerUserId.value : this.ownerUserId,
        ownerRemoteId:
            ownerRemoteId.present ? ownerRemoteId.value : this.ownerRemoteId,
        isDirty: isDirty ?? this.isDirty,
        isDeleted: isDeleted ?? this.isDeleted,
        syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Group copyWithCompanion(GroupsCompanion data) {
    return Group(
      id: data.id.present ? data.id.value : this.id,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      ownerUserId:
          data.ownerUserId.present ? data.ownerUserId.value : this.ownerUserId,
      ownerRemoteId: data.ownerRemoteId.present
          ? data.ownerRemoteId.value
          : this.ownerRemoteId,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Group(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('remoteId: $remoteId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('ownerUserId: $ownerUserId, ')
          ..write('ownerRemoteId: $ownerRemoteId, ')
          ..write('isDirty: $isDirty, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      uuid,
      remoteId,
      name,
      description,
      ownerUserId,
      ownerRemoteId,
      isDirty,
      isDeleted,
      syncedAt,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Group &&
          other.id == this.id &&
          other.uuid == this.uuid &&
          other.remoteId == this.remoteId &&
          other.name == this.name &&
          other.description == this.description &&
          other.ownerUserId == this.ownerUserId &&
          other.ownerRemoteId == this.ownerRemoteId &&
          other.isDirty == this.isDirty &&
          other.isDeleted == this.isDeleted &&
          other.syncedAt == this.syncedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class GroupsCompanion extends UpdateCompanion<Group> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<String?> remoteId;
  final Value<String> name;
  final Value<String?> description;
  final Value<int?> ownerUserId;
  final Value<String?> ownerRemoteId;
  final Value<bool> isDirty;
  final Value<bool> isDeleted;
  final Value<DateTime?> syncedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const GroupsCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.ownerUserId = const Value.absent(),
    this.ownerRemoteId = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  GroupsCompanion.insert({
    this.id = const Value.absent(),
    required String uuid,
    this.remoteId = const Value.absent(),
    required String name,
    this.description = const Value.absent(),
    this.ownerUserId = const Value.absent(),
    this.ownerRemoteId = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : uuid = Value(uuid),
        name = Value(name);
  static Insertable<Group> custom({
    Expression<int>? id,
    Expression<String>? uuid,
    Expression<String>? remoteId,
    Expression<String>? name,
    Expression<String>? description,
    Expression<int>? ownerUserId,
    Expression<String>? ownerRemoteId,
    Expression<bool>? isDirty,
    Expression<bool>? isDeleted,
    Expression<DateTime>? syncedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (remoteId != null) 'remote_id': remoteId,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (ownerUserId != null) 'owner_user_id': ownerUserId,
      if (ownerRemoteId != null) 'owner_remote_id': ownerRemoteId,
      if (isDirty != null) 'is_dirty': isDirty,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  GroupsCompanion copyWith(
      {Value<int>? id,
      Value<String>? uuid,
      Value<String?>? remoteId,
      Value<String>? name,
      Value<String?>? description,
      Value<int?>? ownerUserId,
      Value<String?>? ownerRemoteId,
      Value<bool>? isDirty,
      Value<bool>? isDeleted,
      Value<DateTime?>? syncedAt,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return GroupsCompanion(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      remoteId: remoteId ?? this.remoteId,
      name: name ?? this.name,
      description: description ?? this.description,
      ownerUserId: ownerUserId ?? this.ownerUserId,
      ownerRemoteId: ownerRemoteId ?? this.ownerRemoteId,
      isDirty: isDirty ?? this.isDirty,
      isDeleted: isDeleted ?? this.isDeleted,
      syncedAt: syncedAt ?? this.syncedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (ownerUserId.present) {
      map['owner_user_id'] = Variable<int>(ownerUserId.value);
    }
    if (ownerRemoteId.present) {
      map['owner_remote_id'] = Variable<String>(ownerRemoteId.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GroupsCompanion(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('remoteId: $remoteId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('ownerUserId: $ownerUserId, ')
          ..write('ownerRemoteId: $ownerRemoteId, ')
          ..write('isDirty: $isDirty, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $GroupMembersTable extends GroupMembers
    with TableInfo<$GroupMembersTable, GroupMember> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GroupMembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 36),
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _remoteIdMeta =
      const VerificationMeta('remoteId');
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
      'remote_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _groupIdMeta =
      const VerificationMeta('groupId');
  @override
  late final GeneratedColumn<int> groupId = GeneratedColumn<int>(
      'group_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES "groups" (id) ON DELETE CASCADE'));
  static const VerificationMeta _groupUuidMeta =
      const VerificationMeta('groupUuid');
  @override
  late final GeneratedColumn<String> groupUuid = GeneratedColumn<String>(
      'group_uuid', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 36),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _memberUserIdMeta =
      const VerificationMeta('memberUserId');
  @override
  late final GeneratedColumn<int> memberUserId = GeneratedColumn<int>(
      'member_user_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES local_users (id)'));
  static const VerificationMeta _memberRemoteIdMeta =
      const VerificationMeta('memberRemoteId');
  @override
  late final GeneratedColumn<String> memberRemoteId = GeneratedColumn<String>(
      'member_remote_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
      'role', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('member'));
  static const VerificationMeta _isDirtyMeta =
      const VerificationMeta('isDirty');
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
      'is_dirty', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_dirty" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _syncedAtMeta =
      const VerificationMeta('syncedAt');
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
      'synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        uuid,
        remoteId,
        groupId,
        groupUuid,
        memberUserId,
        memberRemoteId,
        role,
        isDirty,
        isDeleted,
        syncedAt,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'group_members';
  @override
  VerificationContext validateIntegrity(Insertable<GroupMember> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('remote_id')) {
      context.handle(_remoteIdMeta,
          remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta));
    }
    if (data.containsKey('group_id')) {
      context.handle(_groupIdMeta,
          groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta));
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('group_uuid')) {
      context.handle(_groupUuidMeta,
          groupUuid.isAcceptableOrUnknown(data['group_uuid']!, _groupUuidMeta));
    } else if (isInserting) {
      context.missing(_groupUuidMeta);
    }
    if (data.containsKey('member_user_id')) {
      context.handle(
          _memberUserIdMeta,
          memberUserId.isAcceptableOrUnknown(
              data['member_user_id']!, _memberUserIdMeta));
    } else if (isInserting) {
      context.missing(_memberUserIdMeta);
    }
    if (data.containsKey('member_remote_id')) {
      context.handle(
          _memberRemoteIdMeta,
          memberRemoteId.isAcceptableOrUnknown(
              data['member_remote_id']!, _memberRemoteIdMeta));
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    }
    if (data.containsKey('is_dirty')) {
      context.handle(_isDirtyMeta,
          isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('synced_at')) {
      context.handle(_syncedAtMeta,
          syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {groupId, memberUserId},
      ];
  @override
  GroupMember map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GroupMember(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      remoteId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}remote_id']),
      groupId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}group_id'])!,
      groupUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}group_uuid'])!,
      memberUserId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}member_user_id'])!,
      memberRemoteId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}member_remote_id']),
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role'])!,
      isDirty: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_dirty'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      syncedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}synced_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $GroupMembersTable createAlias(String alias) {
    return $GroupMembersTable(attachedDatabase, alias);
  }
}

class GroupMember extends DataClass implements Insertable<GroupMember> {
  final int id;
  final String uuid;
  final String? remoteId;
  final int groupId;
  final String groupUuid;
  final int memberUserId;
  final String? memberRemoteId;
  final String role;
  final bool isDirty;
  final bool isDeleted;
  final DateTime? syncedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const GroupMember(
      {required this.id,
      required this.uuid,
      this.remoteId,
      required this.groupId,
      required this.groupUuid,
      required this.memberUserId,
      this.memberRemoteId,
      required this.role,
      required this.isDirty,
      required this.isDeleted,
      this.syncedAt,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uuid'] = Variable<String>(uuid);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<String>(remoteId);
    }
    map['group_id'] = Variable<int>(groupId);
    map['group_uuid'] = Variable<String>(groupUuid);
    map['member_user_id'] = Variable<int>(memberUserId);
    if (!nullToAbsent || memberRemoteId != null) {
      map['member_remote_id'] = Variable<String>(memberRemoteId);
    }
    map['role'] = Variable<String>(role);
    map['is_dirty'] = Variable<bool>(isDirty);
    map['is_deleted'] = Variable<bool>(isDeleted);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  GroupMembersCompanion toCompanion(bool nullToAbsent) {
    return GroupMembersCompanion(
      id: Value(id),
      uuid: Value(uuid),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      groupId: Value(groupId),
      groupUuid: Value(groupUuid),
      memberUserId: Value(memberUserId),
      memberRemoteId: memberRemoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(memberRemoteId),
      role: Value(role),
      isDirty: Value(isDirty),
      isDeleted: Value(isDeleted),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory GroupMember.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GroupMember(
      id: serializer.fromJson<int>(json['id']),
      uuid: serializer.fromJson<String>(json['uuid']),
      remoteId: serializer.fromJson<String?>(json['remoteId']),
      groupId: serializer.fromJson<int>(json['groupId']),
      groupUuid: serializer.fromJson<String>(json['groupUuid']),
      memberUserId: serializer.fromJson<int>(json['memberUserId']),
      memberRemoteId: serializer.fromJson<String?>(json['memberRemoteId']),
      role: serializer.fromJson<String>(json['role']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uuid': serializer.toJson<String>(uuid),
      'remoteId': serializer.toJson<String?>(remoteId),
      'groupId': serializer.toJson<int>(groupId),
      'groupUuid': serializer.toJson<String>(groupUuid),
      'memberUserId': serializer.toJson<int>(memberUserId),
      'memberRemoteId': serializer.toJson<String?>(memberRemoteId),
      'role': serializer.toJson<String>(role),
      'isDirty': serializer.toJson<bool>(isDirty),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  GroupMember copyWith(
          {int? id,
          String? uuid,
          Value<String?> remoteId = const Value.absent(),
          int? groupId,
          String? groupUuid,
          int? memberUserId,
          Value<String?> memberRemoteId = const Value.absent(),
          String? role,
          bool? isDirty,
          bool? isDeleted,
          Value<DateTime?> syncedAt = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      GroupMember(
        id: id ?? this.id,
        uuid: uuid ?? this.uuid,
        remoteId: remoteId.present ? remoteId.value : this.remoteId,
        groupId: groupId ?? this.groupId,
        groupUuid: groupUuid ?? this.groupUuid,
        memberUserId: memberUserId ?? this.memberUserId,
        memberRemoteId:
            memberRemoteId.present ? memberRemoteId.value : this.memberRemoteId,
        role: role ?? this.role,
        isDirty: isDirty ?? this.isDirty,
        isDeleted: isDeleted ?? this.isDeleted,
        syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  GroupMember copyWithCompanion(GroupMembersCompanion data) {
    return GroupMember(
      id: data.id.present ? data.id.value : this.id,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      groupUuid: data.groupUuid.present ? data.groupUuid.value : this.groupUuid,
      memberUserId: data.memberUserId.present
          ? data.memberUserId.value
          : this.memberUserId,
      memberRemoteId: data.memberRemoteId.present
          ? data.memberRemoteId.value
          : this.memberRemoteId,
      role: data.role.present ? data.role.value : this.role,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GroupMember(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('remoteId: $remoteId, ')
          ..write('groupId: $groupId, ')
          ..write('groupUuid: $groupUuid, ')
          ..write('memberUserId: $memberUserId, ')
          ..write('memberRemoteId: $memberRemoteId, ')
          ..write('role: $role, ')
          ..write('isDirty: $isDirty, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      uuid,
      remoteId,
      groupId,
      groupUuid,
      memberUserId,
      memberRemoteId,
      role,
      isDirty,
      isDeleted,
      syncedAt,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GroupMember &&
          other.id == this.id &&
          other.uuid == this.uuid &&
          other.remoteId == this.remoteId &&
          other.groupId == this.groupId &&
          other.groupUuid == this.groupUuid &&
          other.memberUserId == this.memberUserId &&
          other.memberRemoteId == this.memberRemoteId &&
          other.role == this.role &&
          other.isDirty == this.isDirty &&
          other.isDeleted == this.isDeleted &&
          other.syncedAt == this.syncedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class GroupMembersCompanion extends UpdateCompanion<GroupMember> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<String?> remoteId;
  final Value<int> groupId;
  final Value<String> groupUuid;
  final Value<int> memberUserId;
  final Value<String?> memberRemoteId;
  final Value<String> role;
  final Value<bool> isDirty;
  final Value<bool> isDeleted;
  final Value<DateTime?> syncedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const GroupMembersCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.groupId = const Value.absent(),
    this.groupUuid = const Value.absent(),
    this.memberUserId = const Value.absent(),
    this.memberRemoteId = const Value.absent(),
    this.role = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  GroupMembersCompanion.insert({
    this.id = const Value.absent(),
    required String uuid,
    this.remoteId = const Value.absent(),
    required int groupId,
    required String groupUuid,
    required int memberUserId,
    this.memberRemoteId = const Value.absent(),
    this.role = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : uuid = Value(uuid),
        groupId = Value(groupId),
        groupUuid = Value(groupUuid),
        memberUserId = Value(memberUserId);
  static Insertable<GroupMember> custom({
    Expression<int>? id,
    Expression<String>? uuid,
    Expression<String>? remoteId,
    Expression<int>? groupId,
    Expression<String>? groupUuid,
    Expression<int>? memberUserId,
    Expression<String>? memberRemoteId,
    Expression<String>? role,
    Expression<bool>? isDirty,
    Expression<bool>? isDeleted,
    Expression<DateTime>? syncedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (remoteId != null) 'remote_id': remoteId,
      if (groupId != null) 'group_id': groupId,
      if (groupUuid != null) 'group_uuid': groupUuid,
      if (memberUserId != null) 'member_user_id': memberUserId,
      if (memberRemoteId != null) 'member_remote_id': memberRemoteId,
      if (role != null) 'role': role,
      if (isDirty != null) 'is_dirty': isDirty,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  GroupMembersCompanion copyWith(
      {Value<int>? id,
      Value<String>? uuid,
      Value<String?>? remoteId,
      Value<int>? groupId,
      Value<String>? groupUuid,
      Value<int>? memberUserId,
      Value<String?>? memberRemoteId,
      Value<String>? role,
      Value<bool>? isDirty,
      Value<bool>? isDeleted,
      Value<DateTime?>? syncedAt,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return GroupMembersCompanion(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      remoteId: remoteId ?? this.remoteId,
      groupId: groupId ?? this.groupId,
      groupUuid: groupUuid ?? this.groupUuid,
      memberUserId: memberUserId ?? this.memberUserId,
      memberRemoteId: memberRemoteId ?? this.memberRemoteId,
      role: role ?? this.role,
      isDirty: isDirty ?? this.isDirty,
      isDeleted: isDeleted ?? this.isDeleted,
      syncedAt: syncedAt ?? this.syncedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<int>(groupId.value);
    }
    if (groupUuid.present) {
      map['group_uuid'] = Variable<String>(groupUuid.value);
    }
    if (memberUserId.present) {
      map['member_user_id'] = Variable<int>(memberUserId.value);
    }
    if (memberRemoteId.present) {
      map['member_remote_id'] = Variable<String>(memberRemoteId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GroupMembersCompanion(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('remoteId: $remoteId, ')
          ..write('groupId: $groupId, ')
          ..write('groupUuid: $groupUuid, ')
          ..write('memberUserId: $memberUserId, ')
          ..write('memberRemoteId: $memberRemoteId, ')
          ..write('role: $role, ')
          ..write('isDirty: $isDirty, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $SharedBooksTable extends SharedBooks
    with TableInfo<$SharedBooksTable, SharedBook> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SharedBooksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 36),
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _remoteIdMeta =
      const VerificationMeta('remoteId');
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
      'remote_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _groupIdMeta =
      const VerificationMeta('groupId');
  @override
  late final GeneratedColumn<int> groupId = GeneratedColumn<int>(
      'group_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES "groups" (id) ON DELETE CASCADE'));
  static const VerificationMeta _groupUuidMeta =
      const VerificationMeta('groupUuid');
  @override
  late final GeneratedColumn<String> groupUuid = GeneratedColumn<String>(
      'group_uuid', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 36),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<int> bookId = GeneratedColumn<int>(
      'book_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES books (id) ON DELETE CASCADE'));
  static const VerificationMeta _bookUuidMeta =
      const VerificationMeta('bookUuid');
  @override
  late final GeneratedColumn<String> bookUuid = GeneratedColumn<String>(
      'book_uuid', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 36),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _ownerUserIdMeta =
      const VerificationMeta('ownerUserId');
  @override
  late final GeneratedColumn<int> ownerUserId = GeneratedColumn<int>(
      'owner_user_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES local_users (id)'));
  static const VerificationMeta _ownerRemoteIdMeta =
      const VerificationMeta('ownerRemoteId');
  @override
  late final GeneratedColumn<String> ownerRemoteId = GeneratedColumn<String>(
      'owner_remote_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _visibilityMeta =
      const VerificationMeta('visibility');
  @override
  late final GeneratedColumn<String> visibility = GeneratedColumn<String>(
      'visibility', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 32),
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('group'));
  static const VerificationMeta _isAvailableMeta =
      const VerificationMeta('isAvailable');
  @override
  late final GeneratedColumn<bool> isAvailable = GeneratedColumn<bool>(
      'is_available', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_available" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _isDirtyMeta =
      const VerificationMeta('isDirty');
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
      'is_dirty', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_dirty" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _syncedAtMeta =
      const VerificationMeta('syncedAt');
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
      'synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        uuid,
        remoteId,
        groupId,
        groupUuid,
        bookId,
        bookUuid,
        ownerUserId,
        ownerRemoteId,
        visibility,
        isAvailable,
        isDirty,
        isDeleted,
        syncedAt,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shared_books';
  @override
  VerificationContext validateIntegrity(Insertable<SharedBook> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('remote_id')) {
      context.handle(_remoteIdMeta,
          remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta));
    }
    if (data.containsKey('group_id')) {
      context.handle(_groupIdMeta,
          groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta));
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('group_uuid')) {
      context.handle(_groupUuidMeta,
          groupUuid.isAcceptableOrUnknown(data['group_uuid']!, _groupUuidMeta));
    } else if (isInserting) {
      context.missing(_groupUuidMeta);
    }
    if (data.containsKey('book_id')) {
      context.handle(_bookIdMeta,
          bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta));
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('book_uuid')) {
      context.handle(_bookUuidMeta,
          bookUuid.isAcceptableOrUnknown(data['book_uuid']!, _bookUuidMeta));
    } else if (isInserting) {
      context.missing(_bookUuidMeta);
    }
    if (data.containsKey('owner_user_id')) {
      context.handle(
          _ownerUserIdMeta,
          ownerUserId.isAcceptableOrUnknown(
              data['owner_user_id']!, _ownerUserIdMeta));
    } else if (isInserting) {
      context.missing(_ownerUserIdMeta);
    }
    if (data.containsKey('owner_remote_id')) {
      context.handle(
          _ownerRemoteIdMeta,
          ownerRemoteId.isAcceptableOrUnknown(
              data['owner_remote_id']!, _ownerRemoteIdMeta));
    }
    if (data.containsKey('visibility')) {
      context.handle(
          _visibilityMeta,
          visibility.isAcceptableOrUnknown(
              data['visibility']!, _visibilityMeta));
    }
    if (data.containsKey('is_available')) {
      context.handle(
          _isAvailableMeta,
          isAvailable.isAcceptableOrUnknown(
              data['is_available']!, _isAvailableMeta));
    }
    if (data.containsKey('is_dirty')) {
      context.handle(_isDirtyMeta,
          isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('synced_at')) {
      context.handle(_syncedAtMeta,
          syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SharedBook map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SharedBook(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      remoteId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}remote_id']),
      groupId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}group_id'])!,
      groupUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}group_uuid'])!,
      bookId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}book_id'])!,
      bookUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}book_uuid'])!,
      ownerUserId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}owner_user_id'])!,
      ownerRemoteId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}owner_remote_id']),
      visibility: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}visibility'])!,
      isAvailable: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_available'])!,
      isDirty: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_dirty'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      syncedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}synced_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $SharedBooksTable createAlias(String alias) {
    return $SharedBooksTable(attachedDatabase, alias);
  }
}

class SharedBook extends DataClass implements Insertable<SharedBook> {
  final int id;
  final String uuid;
  final String? remoteId;
  final int groupId;
  final String groupUuid;
  final int bookId;
  final String bookUuid;
  final int ownerUserId;
  final String? ownerRemoteId;
  final String visibility;
  final bool isAvailable;
  final bool isDirty;
  final bool isDeleted;
  final DateTime? syncedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const SharedBook(
      {required this.id,
      required this.uuid,
      this.remoteId,
      required this.groupId,
      required this.groupUuid,
      required this.bookId,
      required this.bookUuid,
      required this.ownerUserId,
      this.ownerRemoteId,
      required this.visibility,
      required this.isAvailable,
      required this.isDirty,
      required this.isDeleted,
      this.syncedAt,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uuid'] = Variable<String>(uuid);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<String>(remoteId);
    }
    map['group_id'] = Variable<int>(groupId);
    map['group_uuid'] = Variable<String>(groupUuid);
    map['book_id'] = Variable<int>(bookId);
    map['book_uuid'] = Variable<String>(bookUuid);
    map['owner_user_id'] = Variable<int>(ownerUserId);
    if (!nullToAbsent || ownerRemoteId != null) {
      map['owner_remote_id'] = Variable<String>(ownerRemoteId);
    }
    map['visibility'] = Variable<String>(visibility);
    map['is_available'] = Variable<bool>(isAvailable);
    map['is_dirty'] = Variable<bool>(isDirty);
    map['is_deleted'] = Variable<bool>(isDeleted);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SharedBooksCompanion toCompanion(bool nullToAbsent) {
    return SharedBooksCompanion(
      id: Value(id),
      uuid: Value(uuid),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      groupId: Value(groupId),
      groupUuid: Value(groupUuid),
      bookId: Value(bookId),
      bookUuid: Value(bookUuid),
      ownerUserId: Value(ownerUserId),
      ownerRemoteId: ownerRemoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerRemoteId),
      visibility: Value(visibility),
      isAvailable: Value(isAvailable),
      isDirty: Value(isDirty),
      isDeleted: Value(isDeleted),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory SharedBook.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SharedBook(
      id: serializer.fromJson<int>(json['id']),
      uuid: serializer.fromJson<String>(json['uuid']),
      remoteId: serializer.fromJson<String?>(json['remoteId']),
      groupId: serializer.fromJson<int>(json['groupId']),
      groupUuid: serializer.fromJson<String>(json['groupUuid']),
      bookId: serializer.fromJson<int>(json['bookId']),
      bookUuid: serializer.fromJson<String>(json['bookUuid']),
      ownerUserId: serializer.fromJson<int>(json['ownerUserId']),
      ownerRemoteId: serializer.fromJson<String?>(json['ownerRemoteId']),
      visibility: serializer.fromJson<String>(json['visibility']),
      isAvailable: serializer.fromJson<bool>(json['isAvailable']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uuid': serializer.toJson<String>(uuid),
      'remoteId': serializer.toJson<String?>(remoteId),
      'groupId': serializer.toJson<int>(groupId),
      'groupUuid': serializer.toJson<String>(groupUuid),
      'bookId': serializer.toJson<int>(bookId),
      'bookUuid': serializer.toJson<String>(bookUuid),
      'ownerUserId': serializer.toJson<int>(ownerUserId),
      'ownerRemoteId': serializer.toJson<String?>(ownerRemoteId),
      'visibility': serializer.toJson<String>(visibility),
      'isAvailable': serializer.toJson<bool>(isAvailable),
      'isDirty': serializer.toJson<bool>(isDirty),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SharedBook copyWith(
          {int? id,
          String? uuid,
          Value<String?> remoteId = const Value.absent(),
          int? groupId,
          String? groupUuid,
          int? bookId,
          String? bookUuid,
          int? ownerUserId,
          Value<String?> ownerRemoteId = const Value.absent(),
          String? visibility,
          bool? isAvailable,
          bool? isDirty,
          bool? isDeleted,
          Value<DateTime?> syncedAt = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      SharedBook(
        id: id ?? this.id,
        uuid: uuid ?? this.uuid,
        remoteId: remoteId.present ? remoteId.value : this.remoteId,
        groupId: groupId ?? this.groupId,
        groupUuid: groupUuid ?? this.groupUuid,
        bookId: bookId ?? this.bookId,
        bookUuid: bookUuid ?? this.bookUuid,
        ownerUserId: ownerUserId ?? this.ownerUserId,
        ownerRemoteId:
            ownerRemoteId.present ? ownerRemoteId.value : this.ownerRemoteId,
        visibility: visibility ?? this.visibility,
        isAvailable: isAvailable ?? this.isAvailable,
        isDirty: isDirty ?? this.isDirty,
        isDeleted: isDeleted ?? this.isDeleted,
        syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  SharedBook copyWithCompanion(SharedBooksCompanion data) {
    return SharedBook(
      id: data.id.present ? data.id.value : this.id,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      groupUuid: data.groupUuid.present ? data.groupUuid.value : this.groupUuid,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      bookUuid: data.bookUuid.present ? data.bookUuid.value : this.bookUuid,
      ownerUserId:
          data.ownerUserId.present ? data.ownerUserId.value : this.ownerUserId,
      ownerRemoteId: data.ownerRemoteId.present
          ? data.ownerRemoteId.value
          : this.ownerRemoteId,
      visibility:
          data.visibility.present ? data.visibility.value : this.visibility,
      isAvailable:
          data.isAvailable.present ? data.isAvailable.value : this.isAvailable,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SharedBook(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('remoteId: $remoteId, ')
          ..write('groupId: $groupId, ')
          ..write('groupUuid: $groupUuid, ')
          ..write('bookId: $bookId, ')
          ..write('bookUuid: $bookUuid, ')
          ..write('ownerUserId: $ownerUserId, ')
          ..write('ownerRemoteId: $ownerRemoteId, ')
          ..write('visibility: $visibility, ')
          ..write('isAvailable: $isAvailable, ')
          ..write('isDirty: $isDirty, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      uuid,
      remoteId,
      groupId,
      groupUuid,
      bookId,
      bookUuid,
      ownerUserId,
      ownerRemoteId,
      visibility,
      isAvailable,
      isDirty,
      isDeleted,
      syncedAt,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SharedBook &&
          other.id == this.id &&
          other.uuid == this.uuid &&
          other.remoteId == this.remoteId &&
          other.groupId == this.groupId &&
          other.groupUuid == this.groupUuid &&
          other.bookId == this.bookId &&
          other.bookUuid == this.bookUuid &&
          other.ownerUserId == this.ownerUserId &&
          other.ownerRemoteId == this.ownerRemoteId &&
          other.visibility == this.visibility &&
          other.isAvailable == this.isAvailable &&
          other.isDirty == this.isDirty &&
          other.isDeleted == this.isDeleted &&
          other.syncedAt == this.syncedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SharedBooksCompanion extends UpdateCompanion<SharedBook> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<String?> remoteId;
  final Value<int> groupId;
  final Value<String> groupUuid;
  final Value<int> bookId;
  final Value<String> bookUuid;
  final Value<int> ownerUserId;
  final Value<String?> ownerRemoteId;
  final Value<String> visibility;
  final Value<bool> isAvailable;
  final Value<bool> isDirty;
  final Value<bool> isDeleted;
  final Value<DateTime?> syncedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const SharedBooksCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.groupId = const Value.absent(),
    this.groupUuid = const Value.absent(),
    this.bookId = const Value.absent(),
    this.bookUuid = const Value.absent(),
    this.ownerUserId = const Value.absent(),
    this.ownerRemoteId = const Value.absent(),
    this.visibility = const Value.absent(),
    this.isAvailable = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  SharedBooksCompanion.insert({
    this.id = const Value.absent(),
    required String uuid,
    this.remoteId = const Value.absent(),
    required int groupId,
    required String groupUuid,
    required int bookId,
    required String bookUuid,
    required int ownerUserId,
    this.ownerRemoteId = const Value.absent(),
    this.visibility = const Value.absent(),
    this.isAvailable = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : uuid = Value(uuid),
        groupId = Value(groupId),
        groupUuid = Value(groupUuid),
        bookId = Value(bookId),
        bookUuid = Value(bookUuid),
        ownerUserId = Value(ownerUserId);
  static Insertable<SharedBook> custom({
    Expression<int>? id,
    Expression<String>? uuid,
    Expression<String>? remoteId,
    Expression<int>? groupId,
    Expression<String>? groupUuid,
    Expression<int>? bookId,
    Expression<String>? bookUuid,
    Expression<int>? ownerUserId,
    Expression<String>? ownerRemoteId,
    Expression<String>? visibility,
    Expression<bool>? isAvailable,
    Expression<bool>? isDirty,
    Expression<bool>? isDeleted,
    Expression<DateTime>? syncedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (remoteId != null) 'remote_id': remoteId,
      if (groupId != null) 'group_id': groupId,
      if (groupUuid != null) 'group_uuid': groupUuid,
      if (bookId != null) 'book_id': bookId,
      if (bookUuid != null) 'book_uuid': bookUuid,
      if (ownerUserId != null) 'owner_user_id': ownerUserId,
      if (ownerRemoteId != null) 'owner_remote_id': ownerRemoteId,
      if (visibility != null) 'visibility': visibility,
      if (isAvailable != null) 'is_available': isAvailable,
      if (isDirty != null) 'is_dirty': isDirty,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  SharedBooksCompanion copyWith(
      {Value<int>? id,
      Value<String>? uuid,
      Value<String?>? remoteId,
      Value<int>? groupId,
      Value<String>? groupUuid,
      Value<int>? bookId,
      Value<String>? bookUuid,
      Value<int>? ownerUserId,
      Value<String?>? ownerRemoteId,
      Value<String>? visibility,
      Value<bool>? isAvailable,
      Value<bool>? isDirty,
      Value<bool>? isDeleted,
      Value<DateTime?>? syncedAt,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return SharedBooksCompanion(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      remoteId: remoteId ?? this.remoteId,
      groupId: groupId ?? this.groupId,
      groupUuid: groupUuid ?? this.groupUuid,
      bookId: bookId ?? this.bookId,
      bookUuid: bookUuid ?? this.bookUuid,
      ownerUserId: ownerUserId ?? this.ownerUserId,
      ownerRemoteId: ownerRemoteId ?? this.ownerRemoteId,
      visibility: visibility ?? this.visibility,
      isAvailable: isAvailable ?? this.isAvailable,
      isDirty: isDirty ?? this.isDirty,
      isDeleted: isDeleted ?? this.isDeleted,
      syncedAt: syncedAt ?? this.syncedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<int>(groupId.value);
    }
    if (groupUuid.present) {
      map['group_uuid'] = Variable<String>(groupUuid.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<int>(bookId.value);
    }
    if (bookUuid.present) {
      map['book_uuid'] = Variable<String>(bookUuid.value);
    }
    if (ownerUserId.present) {
      map['owner_user_id'] = Variable<int>(ownerUserId.value);
    }
    if (ownerRemoteId.present) {
      map['owner_remote_id'] = Variable<String>(ownerRemoteId.value);
    }
    if (visibility.present) {
      map['visibility'] = Variable<String>(visibility.value);
    }
    if (isAvailable.present) {
      map['is_available'] = Variable<bool>(isAvailable.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SharedBooksCompanion(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('remoteId: $remoteId, ')
          ..write('groupId: $groupId, ')
          ..write('groupUuid: $groupUuid, ')
          ..write('bookId: $bookId, ')
          ..write('bookUuid: $bookUuid, ')
          ..write('ownerUserId: $ownerUserId, ')
          ..write('ownerRemoteId: $ownerRemoteId, ')
          ..write('visibility: $visibility, ')
          ..write('isAvailable: $isAvailable, ')
          ..write('isDirty: $isDirty, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $GroupInvitationsTable extends GroupInvitations
    with TableInfo<$GroupInvitationsTable, GroupInvitation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GroupInvitationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 36),
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _remoteIdMeta =
      const VerificationMeta('remoteId');
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
      'remote_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _groupIdMeta =
      const VerificationMeta('groupId');
  @override
  late final GeneratedColumn<int> groupId = GeneratedColumn<int>(
      'group_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES "groups" (id) ON DELETE CASCADE'));
  static const VerificationMeta _groupUuidMeta =
      const VerificationMeta('groupUuid');
  @override
  late final GeneratedColumn<String> groupUuid = GeneratedColumn<String>(
      'group_uuid', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 36),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _inviterUserIdMeta =
      const VerificationMeta('inviterUserId');
  @override
  late final GeneratedColumn<int> inviterUserId = GeneratedColumn<int>(
      'inviter_user_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES local_users (id)'));
  static const VerificationMeta _inviterRemoteIdMeta =
      const VerificationMeta('inviterRemoteId');
  @override
  late final GeneratedColumn<String> inviterRemoteId = GeneratedColumn<String>(
      'inviter_remote_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _acceptedUserIdMeta =
      const VerificationMeta('acceptedUserId');
  @override
  late final GeneratedColumn<int> acceptedUserId = GeneratedColumn<int>(
      'accepted_user_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES local_users (id)'));
  static const VerificationMeta _acceptedUserRemoteIdMeta =
      const VerificationMeta('acceptedUserRemoteId');
  @override
  late final GeneratedColumn<String> acceptedUserRemoteId =
      GeneratedColumn<String>('accepted_user_remote_id', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
      'role', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 32),
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('member'));
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
      'code', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 64),
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 32),
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _expiresAtMeta =
      const VerificationMeta('expiresAt');
  @override
  late final GeneratedColumn<DateTime> expiresAt = GeneratedColumn<DateTime>(
      'expires_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _respondedAtMeta =
      const VerificationMeta('respondedAt');
  @override
  late final GeneratedColumn<DateTime> respondedAt = GeneratedColumn<DateTime>(
      'responded_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _isDirtyMeta =
      const VerificationMeta('isDirty');
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
      'is_dirty', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_dirty" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _syncedAtMeta =
      const VerificationMeta('syncedAt');
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
      'synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        uuid,
        remoteId,
        groupId,
        groupUuid,
        inviterUserId,
        inviterRemoteId,
        acceptedUserId,
        acceptedUserRemoteId,
        role,
        code,
        status,
        expiresAt,
        respondedAt,
        isDirty,
        isDeleted,
        syncedAt,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'group_invitations';
  @override
  VerificationContext validateIntegrity(Insertable<GroupInvitation> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('remote_id')) {
      context.handle(_remoteIdMeta,
          remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta));
    }
    if (data.containsKey('group_id')) {
      context.handle(_groupIdMeta,
          groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta));
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('group_uuid')) {
      context.handle(_groupUuidMeta,
          groupUuid.isAcceptableOrUnknown(data['group_uuid']!, _groupUuidMeta));
    } else if (isInserting) {
      context.missing(_groupUuidMeta);
    }
    if (data.containsKey('inviter_user_id')) {
      context.handle(
          _inviterUserIdMeta,
          inviterUserId.isAcceptableOrUnknown(
              data['inviter_user_id']!, _inviterUserIdMeta));
    } else if (isInserting) {
      context.missing(_inviterUserIdMeta);
    }
    if (data.containsKey('inviter_remote_id')) {
      context.handle(
          _inviterRemoteIdMeta,
          inviterRemoteId.isAcceptableOrUnknown(
              data['inviter_remote_id']!, _inviterRemoteIdMeta));
    }
    if (data.containsKey('accepted_user_id')) {
      context.handle(
          _acceptedUserIdMeta,
          acceptedUserId.isAcceptableOrUnknown(
              data['accepted_user_id']!, _acceptedUserIdMeta));
    }
    if (data.containsKey('accepted_user_remote_id')) {
      context.handle(
          _acceptedUserRemoteIdMeta,
          acceptedUserRemoteId.isAcceptableOrUnknown(
              data['accepted_user_remote_id']!, _acceptedUserRemoteIdMeta));
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    }
    if (data.containsKey('code')) {
      context.handle(
          _codeMeta, code.isAcceptableOrUnknown(data['code']!, _codeMeta));
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('expires_at')) {
      context.handle(_expiresAtMeta,
          expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta));
    } else if (isInserting) {
      context.missing(_expiresAtMeta);
    }
    if (data.containsKey('responded_at')) {
      context.handle(
          _respondedAtMeta,
          respondedAt.isAcceptableOrUnknown(
              data['responded_at']!, _respondedAtMeta));
    }
    if (data.containsKey('is_dirty')) {
      context.handle(_isDirtyMeta,
          isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('synced_at')) {
      context.handle(_syncedAtMeta,
          syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GroupInvitation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GroupInvitation(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      remoteId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}remote_id']),
      groupId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}group_id'])!,
      groupUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}group_uuid'])!,
      inviterUserId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}inviter_user_id'])!,
      inviterRemoteId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}inviter_remote_id']),
      acceptedUserId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}accepted_user_id']),
      acceptedUserRemoteId: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}accepted_user_remote_id']),
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role'])!,
      code: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}code'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      expiresAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}expires_at'])!,
      respondedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}responded_at']),
      isDirty: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_dirty'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      syncedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}synced_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $GroupInvitationsTable createAlias(String alias) {
    return $GroupInvitationsTable(attachedDatabase, alias);
  }
}

class GroupInvitation extends DataClass implements Insertable<GroupInvitation> {
  final int id;
  final String uuid;
  final String? remoteId;
  final int groupId;
  final String groupUuid;
  final int inviterUserId;
  final String? inviterRemoteId;
  final int? acceptedUserId;
  final String? acceptedUserRemoteId;
  final String role;
  final String code;
  final String status;
  final DateTime expiresAt;
  final DateTime? respondedAt;
  final bool isDirty;
  final bool isDeleted;
  final DateTime? syncedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const GroupInvitation(
      {required this.id,
      required this.uuid,
      this.remoteId,
      required this.groupId,
      required this.groupUuid,
      required this.inviterUserId,
      this.inviterRemoteId,
      this.acceptedUserId,
      this.acceptedUserRemoteId,
      required this.role,
      required this.code,
      required this.status,
      required this.expiresAt,
      this.respondedAt,
      required this.isDirty,
      required this.isDeleted,
      this.syncedAt,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uuid'] = Variable<String>(uuid);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<String>(remoteId);
    }
    map['group_id'] = Variable<int>(groupId);
    map['group_uuid'] = Variable<String>(groupUuid);
    map['inviter_user_id'] = Variable<int>(inviterUserId);
    if (!nullToAbsent || inviterRemoteId != null) {
      map['inviter_remote_id'] = Variable<String>(inviterRemoteId);
    }
    if (!nullToAbsent || acceptedUserId != null) {
      map['accepted_user_id'] = Variable<int>(acceptedUserId);
    }
    if (!nullToAbsent || acceptedUserRemoteId != null) {
      map['accepted_user_remote_id'] = Variable<String>(acceptedUserRemoteId);
    }
    map['role'] = Variable<String>(role);
    map['code'] = Variable<String>(code);
    map['status'] = Variable<String>(status);
    map['expires_at'] = Variable<DateTime>(expiresAt);
    if (!nullToAbsent || respondedAt != null) {
      map['responded_at'] = Variable<DateTime>(respondedAt);
    }
    map['is_dirty'] = Variable<bool>(isDirty);
    map['is_deleted'] = Variable<bool>(isDeleted);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  GroupInvitationsCompanion toCompanion(bool nullToAbsent) {
    return GroupInvitationsCompanion(
      id: Value(id),
      uuid: Value(uuid),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      groupId: Value(groupId),
      groupUuid: Value(groupUuid),
      inviterUserId: Value(inviterUserId),
      inviterRemoteId: inviterRemoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(inviterRemoteId),
      acceptedUserId: acceptedUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(acceptedUserId),
      acceptedUserRemoteId: acceptedUserRemoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(acceptedUserRemoteId),
      role: Value(role),
      code: Value(code),
      status: Value(status),
      expiresAt: Value(expiresAt),
      respondedAt: respondedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(respondedAt),
      isDirty: Value(isDirty),
      isDeleted: Value(isDeleted),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory GroupInvitation.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GroupInvitation(
      id: serializer.fromJson<int>(json['id']),
      uuid: serializer.fromJson<String>(json['uuid']),
      remoteId: serializer.fromJson<String?>(json['remoteId']),
      groupId: serializer.fromJson<int>(json['groupId']),
      groupUuid: serializer.fromJson<String>(json['groupUuid']),
      inviterUserId: serializer.fromJson<int>(json['inviterUserId']),
      inviterRemoteId: serializer.fromJson<String?>(json['inviterRemoteId']),
      acceptedUserId: serializer.fromJson<int?>(json['acceptedUserId']),
      acceptedUserRemoteId:
          serializer.fromJson<String?>(json['acceptedUserRemoteId']),
      role: serializer.fromJson<String>(json['role']),
      code: serializer.fromJson<String>(json['code']),
      status: serializer.fromJson<String>(json['status']),
      expiresAt: serializer.fromJson<DateTime>(json['expiresAt']),
      respondedAt: serializer.fromJson<DateTime?>(json['respondedAt']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uuid': serializer.toJson<String>(uuid),
      'remoteId': serializer.toJson<String?>(remoteId),
      'groupId': serializer.toJson<int>(groupId),
      'groupUuid': serializer.toJson<String>(groupUuid),
      'inviterUserId': serializer.toJson<int>(inviterUserId),
      'inviterRemoteId': serializer.toJson<String?>(inviterRemoteId),
      'acceptedUserId': serializer.toJson<int?>(acceptedUserId),
      'acceptedUserRemoteId': serializer.toJson<String?>(acceptedUserRemoteId),
      'role': serializer.toJson<String>(role),
      'code': serializer.toJson<String>(code),
      'status': serializer.toJson<String>(status),
      'expiresAt': serializer.toJson<DateTime>(expiresAt),
      'respondedAt': serializer.toJson<DateTime?>(respondedAt),
      'isDirty': serializer.toJson<bool>(isDirty),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  GroupInvitation copyWith(
          {int? id,
          String? uuid,
          Value<String?> remoteId = const Value.absent(),
          int? groupId,
          String? groupUuid,
          int? inviterUserId,
          Value<String?> inviterRemoteId = const Value.absent(),
          Value<int?> acceptedUserId = const Value.absent(),
          Value<String?> acceptedUserRemoteId = const Value.absent(),
          String? role,
          String? code,
          String? status,
          DateTime? expiresAt,
          Value<DateTime?> respondedAt = const Value.absent(),
          bool? isDirty,
          bool? isDeleted,
          Value<DateTime?> syncedAt = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      GroupInvitation(
        id: id ?? this.id,
        uuid: uuid ?? this.uuid,
        remoteId: remoteId.present ? remoteId.value : this.remoteId,
        groupId: groupId ?? this.groupId,
        groupUuid: groupUuid ?? this.groupUuid,
        inviterUserId: inviterUserId ?? this.inviterUserId,
        inviterRemoteId: inviterRemoteId.present
            ? inviterRemoteId.value
            : this.inviterRemoteId,
        acceptedUserId:
            acceptedUserId.present ? acceptedUserId.value : this.acceptedUserId,
        acceptedUserRemoteId: acceptedUserRemoteId.present
            ? acceptedUserRemoteId.value
            : this.acceptedUserRemoteId,
        role: role ?? this.role,
        code: code ?? this.code,
        status: status ?? this.status,
        expiresAt: expiresAt ?? this.expiresAt,
        respondedAt: respondedAt.present ? respondedAt.value : this.respondedAt,
        isDirty: isDirty ?? this.isDirty,
        isDeleted: isDeleted ?? this.isDeleted,
        syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  GroupInvitation copyWithCompanion(GroupInvitationsCompanion data) {
    return GroupInvitation(
      id: data.id.present ? data.id.value : this.id,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      groupUuid: data.groupUuid.present ? data.groupUuid.value : this.groupUuid,
      inviterUserId: data.inviterUserId.present
          ? data.inviterUserId.value
          : this.inviterUserId,
      inviterRemoteId: data.inviterRemoteId.present
          ? data.inviterRemoteId.value
          : this.inviterRemoteId,
      acceptedUserId: data.acceptedUserId.present
          ? data.acceptedUserId.value
          : this.acceptedUserId,
      acceptedUserRemoteId: data.acceptedUserRemoteId.present
          ? data.acceptedUserRemoteId.value
          : this.acceptedUserRemoteId,
      role: data.role.present ? data.role.value : this.role,
      code: data.code.present ? data.code.value : this.code,
      status: data.status.present ? data.status.value : this.status,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
      respondedAt:
          data.respondedAt.present ? data.respondedAt.value : this.respondedAt,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GroupInvitation(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('remoteId: $remoteId, ')
          ..write('groupId: $groupId, ')
          ..write('groupUuid: $groupUuid, ')
          ..write('inviterUserId: $inviterUserId, ')
          ..write('inviterRemoteId: $inviterRemoteId, ')
          ..write('acceptedUserId: $acceptedUserId, ')
          ..write('acceptedUserRemoteId: $acceptedUserRemoteId, ')
          ..write('role: $role, ')
          ..write('code: $code, ')
          ..write('status: $status, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('respondedAt: $respondedAt, ')
          ..write('isDirty: $isDirty, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      uuid,
      remoteId,
      groupId,
      groupUuid,
      inviterUserId,
      inviterRemoteId,
      acceptedUserId,
      acceptedUserRemoteId,
      role,
      code,
      status,
      expiresAt,
      respondedAt,
      isDirty,
      isDeleted,
      syncedAt,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GroupInvitation &&
          other.id == this.id &&
          other.uuid == this.uuid &&
          other.remoteId == this.remoteId &&
          other.groupId == this.groupId &&
          other.groupUuid == this.groupUuid &&
          other.inviterUserId == this.inviterUserId &&
          other.inviterRemoteId == this.inviterRemoteId &&
          other.acceptedUserId == this.acceptedUserId &&
          other.acceptedUserRemoteId == this.acceptedUserRemoteId &&
          other.role == this.role &&
          other.code == this.code &&
          other.status == this.status &&
          other.expiresAt == this.expiresAt &&
          other.respondedAt == this.respondedAt &&
          other.isDirty == this.isDirty &&
          other.isDeleted == this.isDeleted &&
          other.syncedAt == this.syncedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class GroupInvitationsCompanion extends UpdateCompanion<GroupInvitation> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<String?> remoteId;
  final Value<int> groupId;
  final Value<String> groupUuid;
  final Value<int> inviterUserId;
  final Value<String?> inviterRemoteId;
  final Value<int?> acceptedUserId;
  final Value<String?> acceptedUserRemoteId;
  final Value<String> role;
  final Value<String> code;
  final Value<String> status;
  final Value<DateTime> expiresAt;
  final Value<DateTime?> respondedAt;
  final Value<bool> isDirty;
  final Value<bool> isDeleted;
  final Value<DateTime?> syncedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const GroupInvitationsCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.groupId = const Value.absent(),
    this.groupUuid = const Value.absent(),
    this.inviterUserId = const Value.absent(),
    this.inviterRemoteId = const Value.absent(),
    this.acceptedUserId = const Value.absent(),
    this.acceptedUserRemoteId = const Value.absent(),
    this.role = const Value.absent(),
    this.code = const Value.absent(),
    this.status = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.respondedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  GroupInvitationsCompanion.insert({
    this.id = const Value.absent(),
    required String uuid,
    this.remoteId = const Value.absent(),
    required int groupId,
    required String groupUuid,
    required int inviterUserId,
    this.inviterRemoteId = const Value.absent(),
    this.acceptedUserId = const Value.absent(),
    this.acceptedUserRemoteId = const Value.absent(),
    this.role = const Value.absent(),
    required String code,
    this.status = const Value.absent(),
    required DateTime expiresAt,
    this.respondedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : uuid = Value(uuid),
        groupId = Value(groupId),
        groupUuid = Value(groupUuid),
        inviterUserId = Value(inviterUserId),
        code = Value(code),
        expiresAt = Value(expiresAt);
  static Insertable<GroupInvitation> custom({
    Expression<int>? id,
    Expression<String>? uuid,
    Expression<String>? remoteId,
    Expression<int>? groupId,
    Expression<String>? groupUuid,
    Expression<int>? inviterUserId,
    Expression<String>? inviterRemoteId,
    Expression<int>? acceptedUserId,
    Expression<String>? acceptedUserRemoteId,
    Expression<String>? role,
    Expression<String>? code,
    Expression<String>? status,
    Expression<DateTime>? expiresAt,
    Expression<DateTime>? respondedAt,
    Expression<bool>? isDirty,
    Expression<bool>? isDeleted,
    Expression<DateTime>? syncedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (remoteId != null) 'remote_id': remoteId,
      if (groupId != null) 'group_id': groupId,
      if (groupUuid != null) 'group_uuid': groupUuid,
      if (inviterUserId != null) 'inviter_user_id': inviterUserId,
      if (inviterRemoteId != null) 'inviter_remote_id': inviterRemoteId,
      if (acceptedUserId != null) 'accepted_user_id': acceptedUserId,
      if (acceptedUserRemoteId != null)
        'accepted_user_remote_id': acceptedUserRemoteId,
      if (role != null) 'role': role,
      if (code != null) 'code': code,
      if (status != null) 'status': status,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (respondedAt != null) 'responded_at': respondedAt,
      if (isDirty != null) 'is_dirty': isDirty,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  GroupInvitationsCompanion copyWith(
      {Value<int>? id,
      Value<String>? uuid,
      Value<String?>? remoteId,
      Value<int>? groupId,
      Value<String>? groupUuid,
      Value<int>? inviterUserId,
      Value<String?>? inviterRemoteId,
      Value<int?>? acceptedUserId,
      Value<String?>? acceptedUserRemoteId,
      Value<String>? role,
      Value<String>? code,
      Value<String>? status,
      Value<DateTime>? expiresAt,
      Value<DateTime?>? respondedAt,
      Value<bool>? isDirty,
      Value<bool>? isDeleted,
      Value<DateTime?>? syncedAt,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return GroupInvitationsCompanion(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      remoteId: remoteId ?? this.remoteId,
      groupId: groupId ?? this.groupId,
      groupUuid: groupUuid ?? this.groupUuid,
      inviterUserId: inviterUserId ?? this.inviterUserId,
      inviterRemoteId: inviterRemoteId ?? this.inviterRemoteId,
      acceptedUserId: acceptedUserId ?? this.acceptedUserId,
      acceptedUserRemoteId: acceptedUserRemoteId ?? this.acceptedUserRemoteId,
      role: role ?? this.role,
      code: code ?? this.code,
      status: status ?? this.status,
      expiresAt: expiresAt ?? this.expiresAt,
      respondedAt: respondedAt ?? this.respondedAt,
      isDirty: isDirty ?? this.isDirty,
      isDeleted: isDeleted ?? this.isDeleted,
      syncedAt: syncedAt ?? this.syncedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<int>(groupId.value);
    }
    if (groupUuid.present) {
      map['group_uuid'] = Variable<String>(groupUuid.value);
    }
    if (inviterUserId.present) {
      map['inviter_user_id'] = Variable<int>(inviterUserId.value);
    }
    if (inviterRemoteId.present) {
      map['inviter_remote_id'] = Variable<String>(inviterRemoteId.value);
    }
    if (acceptedUserId.present) {
      map['accepted_user_id'] = Variable<int>(acceptedUserId.value);
    }
    if (acceptedUserRemoteId.present) {
      map['accepted_user_remote_id'] =
          Variable<String>(acceptedUserRemoteId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<DateTime>(expiresAt.value);
    }
    if (respondedAt.present) {
      map['responded_at'] = Variable<DateTime>(respondedAt.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GroupInvitationsCompanion(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('remoteId: $remoteId, ')
          ..write('groupId: $groupId, ')
          ..write('groupUuid: $groupUuid, ')
          ..write('inviterUserId: $inviterUserId, ')
          ..write('inviterRemoteId: $inviterRemoteId, ')
          ..write('acceptedUserId: $acceptedUserId, ')
          ..write('acceptedUserRemoteId: $acceptedUserRemoteId, ')
          ..write('role: $role, ')
          ..write('code: $code, ')
          ..write('status: $status, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('respondedAt: $respondedAt, ')
          ..write('isDirty: $isDirty, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $LoansTable extends Loans with TableInfo<$LoansTable, Loan> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LoansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 36),
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _remoteIdMeta =
      const VerificationMeta('remoteId');
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
      'remote_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sharedBookIdMeta =
      const VerificationMeta('sharedBookId');
  @override
  late final GeneratedColumn<int> sharedBookId = GeneratedColumn<int>(
      'shared_book_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES shared_books (id) ON DELETE CASCADE'));
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<int> bookId = GeneratedColumn<int>(
      'book_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES books (id) ON DELETE CASCADE'));
  static const VerificationMeta _borrowerUserIdMeta =
      const VerificationMeta('borrowerUserId');
  @override
  late final GeneratedColumn<int> borrowerUserId = GeneratedColumn<int>(
      'borrower_user_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES local_users (id)'));
  static const VerificationMeta _lenderUserIdMeta =
      const VerificationMeta('lenderUserId');
  @override
  late final GeneratedColumn<int> lenderUserId = GeneratedColumn<int>(
      'lender_user_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES local_users (id)'));
  static const VerificationMeta _externalBorrowerNameMeta =
      const VerificationMeta('externalBorrowerName');
  @override
  late final GeneratedColumn<String> externalBorrowerName =
      GeneratedColumn<String>('external_borrower_name', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _externalBorrowerContactMeta =
      const VerificationMeta('externalBorrowerContact');
  @override
  late final GeneratedColumn<String> externalBorrowerContact =
      GeneratedColumn<String>('external_borrower_contact', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 32),
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('requested'));
  static const VerificationMeta _requestedAtMeta =
      const VerificationMeta('requestedAt');
  @override
  late final GeneratedColumn<DateTime> requestedAt = GeneratedColumn<DateTime>(
      'requested_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _approvedAtMeta =
      const VerificationMeta('approvedAt');
  @override
  late final GeneratedColumn<DateTime> approvedAt = GeneratedColumn<DateTime>(
      'approved_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _dueDateMeta =
      const VerificationMeta('dueDate');
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
      'due_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _borrowerReturnedAtMeta =
      const VerificationMeta('borrowerReturnedAt');
  @override
  late final GeneratedColumn<DateTime> borrowerReturnedAt =
      GeneratedColumn<DateTime>('borrower_returned_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _lenderReturnedAtMeta =
      const VerificationMeta('lenderReturnedAt');
  @override
  late final GeneratedColumn<DateTime> lenderReturnedAt =
      GeneratedColumn<DateTime>('lender_returned_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _returnedAtMeta =
      const VerificationMeta('returnedAt');
  @override
  late final GeneratedColumn<DateTime> returnedAt = GeneratedColumn<DateTime>(
      'returned_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _isDirtyMeta =
      const VerificationMeta('isDirty');
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
      'is_dirty', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_dirty" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _syncedAtMeta =
      const VerificationMeta('syncedAt');
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
      'synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        uuid,
        remoteId,
        sharedBookId,
        bookId,
        borrowerUserId,
        lenderUserId,
        externalBorrowerName,
        externalBorrowerContact,
        status,
        requestedAt,
        approvedAt,
        dueDate,
        borrowerReturnedAt,
        lenderReturnedAt,
        returnedAt,
        isDirty,
        isDeleted,
        syncedAt,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'loans';
  @override
  VerificationContext validateIntegrity(Insertable<Loan> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('remote_id')) {
      context.handle(_remoteIdMeta,
          remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta));
    }
    if (data.containsKey('shared_book_id')) {
      context.handle(
          _sharedBookIdMeta,
          sharedBookId.isAcceptableOrUnknown(
              data['shared_book_id']!, _sharedBookIdMeta));
    }
    if (data.containsKey('book_id')) {
      context.handle(_bookIdMeta,
          bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta));
    }
    if (data.containsKey('borrower_user_id')) {
      context.handle(
          _borrowerUserIdMeta,
          borrowerUserId.isAcceptableOrUnknown(
              data['borrower_user_id']!, _borrowerUserIdMeta));
    }
    if (data.containsKey('lender_user_id')) {
      context.handle(
          _lenderUserIdMeta,
          lenderUserId.isAcceptableOrUnknown(
              data['lender_user_id']!, _lenderUserIdMeta));
    } else if (isInserting) {
      context.missing(_lenderUserIdMeta);
    }
    if (data.containsKey('external_borrower_name')) {
      context.handle(
          _externalBorrowerNameMeta,
          externalBorrowerName.isAcceptableOrUnknown(
              data['external_borrower_name']!, _externalBorrowerNameMeta));
    }
    if (data.containsKey('external_borrower_contact')) {
      context.handle(
          _externalBorrowerContactMeta,
          externalBorrowerContact.isAcceptableOrUnknown(
              data['external_borrower_contact']!,
              _externalBorrowerContactMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('requested_at')) {
      context.handle(
          _requestedAtMeta,
          requestedAt.isAcceptableOrUnknown(
              data['requested_at']!, _requestedAtMeta));
    }
    if (data.containsKey('approved_at')) {
      context.handle(
          _approvedAtMeta,
          approvedAt.isAcceptableOrUnknown(
              data['approved_at']!, _approvedAtMeta));
    }
    if (data.containsKey('due_date')) {
      context.handle(_dueDateMeta,
          dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta));
    }
    if (data.containsKey('borrower_returned_at')) {
      context.handle(
          _borrowerReturnedAtMeta,
          borrowerReturnedAt.isAcceptableOrUnknown(
              data['borrower_returned_at']!, _borrowerReturnedAtMeta));
    }
    if (data.containsKey('lender_returned_at')) {
      context.handle(
          _lenderReturnedAtMeta,
          lenderReturnedAt.isAcceptableOrUnknown(
              data['lender_returned_at']!, _lenderReturnedAtMeta));
    }
    if (data.containsKey('returned_at')) {
      context.handle(
          _returnedAtMeta,
          returnedAt.isAcceptableOrUnknown(
              data['returned_at']!, _returnedAtMeta));
    }
    if (data.containsKey('is_dirty')) {
      context.handle(_isDirtyMeta,
          isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('synced_at')) {
      context.handle(_syncedAtMeta,
          syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Loan map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Loan(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      remoteId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}remote_id']),
      sharedBookId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}shared_book_id']),
      bookId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}book_id']),
      borrowerUserId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}borrower_user_id']),
      lenderUserId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}lender_user_id'])!,
      externalBorrowerName: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}external_borrower_name']),
      externalBorrowerContact: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}external_borrower_contact']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      requestedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}requested_at'])!,
      approvedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}approved_at']),
      dueDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}due_date']),
      borrowerReturnedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}borrower_returned_at']),
      lenderReturnedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}lender_returned_at']),
      returnedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}returned_at']),
      isDirty: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_dirty'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      syncedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}synced_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $LoansTable createAlias(String alias) {
    return $LoansTable(attachedDatabase, alias);
  }
}

class Loan extends DataClass implements Insertable<Loan> {
  final int id;
  final String uuid;
  final String? remoteId;
  final int? sharedBookId;
  final int? bookId;
  final int? borrowerUserId;
  final int lenderUserId;
  final String? externalBorrowerName;
  final String? externalBorrowerContact;
  final String status;
  final DateTime requestedAt;
  final DateTime? approvedAt;
  final DateTime? dueDate;
  final DateTime? borrowerReturnedAt;
  final DateTime? lenderReturnedAt;
  final DateTime? returnedAt;
  final bool isDirty;
  final bool isDeleted;
  final DateTime? syncedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Loan(
      {required this.id,
      required this.uuid,
      this.remoteId,
      this.sharedBookId,
      this.bookId,
      this.borrowerUserId,
      required this.lenderUserId,
      this.externalBorrowerName,
      this.externalBorrowerContact,
      required this.status,
      required this.requestedAt,
      this.approvedAt,
      this.dueDate,
      this.borrowerReturnedAt,
      this.lenderReturnedAt,
      this.returnedAt,
      required this.isDirty,
      required this.isDeleted,
      this.syncedAt,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uuid'] = Variable<String>(uuid);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<String>(remoteId);
    }
    if (!nullToAbsent || sharedBookId != null) {
      map['shared_book_id'] = Variable<int>(sharedBookId);
    }
    if (!nullToAbsent || bookId != null) {
      map['book_id'] = Variable<int>(bookId);
    }
    if (!nullToAbsent || borrowerUserId != null) {
      map['borrower_user_id'] = Variable<int>(borrowerUserId);
    }
    map['lender_user_id'] = Variable<int>(lenderUserId);
    if (!nullToAbsent || externalBorrowerName != null) {
      map['external_borrower_name'] = Variable<String>(externalBorrowerName);
    }
    if (!nullToAbsent || externalBorrowerContact != null) {
      map['external_borrower_contact'] =
          Variable<String>(externalBorrowerContact);
    }
    map['status'] = Variable<String>(status);
    map['requested_at'] = Variable<DateTime>(requestedAt);
    if (!nullToAbsent || approvedAt != null) {
      map['approved_at'] = Variable<DateTime>(approvedAt);
    }
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    if (!nullToAbsent || borrowerReturnedAt != null) {
      map['borrower_returned_at'] = Variable<DateTime>(borrowerReturnedAt);
    }
    if (!nullToAbsent || lenderReturnedAt != null) {
      map['lender_returned_at'] = Variable<DateTime>(lenderReturnedAt);
    }
    if (!nullToAbsent || returnedAt != null) {
      map['returned_at'] = Variable<DateTime>(returnedAt);
    }
    map['is_dirty'] = Variable<bool>(isDirty);
    map['is_deleted'] = Variable<bool>(isDeleted);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LoansCompanion toCompanion(bool nullToAbsent) {
    return LoansCompanion(
      id: Value(id),
      uuid: Value(uuid),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      sharedBookId: sharedBookId == null && nullToAbsent
          ? const Value.absent()
          : Value(sharedBookId),
      bookId:
          bookId == null && nullToAbsent ? const Value.absent() : Value(bookId),
      borrowerUserId: borrowerUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(borrowerUserId),
      lenderUserId: Value(lenderUserId),
      externalBorrowerName: externalBorrowerName == null && nullToAbsent
          ? const Value.absent()
          : Value(externalBorrowerName),
      externalBorrowerContact: externalBorrowerContact == null && nullToAbsent
          ? const Value.absent()
          : Value(externalBorrowerContact),
      status: Value(status),
      requestedAt: Value(requestedAt),
      approvedAt: approvedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(approvedAt),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      borrowerReturnedAt: borrowerReturnedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(borrowerReturnedAt),
      lenderReturnedAt: lenderReturnedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lenderReturnedAt),
      returnedAt: returnedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(returnedAt),
      isDirty: Value(isDirty),
      isDeleted: Value(isDeleted),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Loan.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Loan(
      id: serializer.fromJson<int>(json['id']),
      uuid: serializer.fromJson<String>(json['uuid']),
      remoteId: serializer.fromJson<String?>(json['remoteId']),
      sharedBookId: serializer.fromJson<int?>(json['sharedBookId']),
      bookId: serializer.fromJson<int?>(json['bookId']),
      borrowerUserId: serializer.fromJson<int?>(json['borrowerUserId']),
      lenderUserId: serializer.fromJson<int>(json['lenderUserId']),
      externalBorrowerName:
          serializer.fromJson<String?>(json['externalBorrowerName']),
      externalBorrowerContact:
          serializer.fromJson<String?>(json['externalBorrowerContact']),
      status: serializer.fromJson<String>(json['status']),
      requestedAt: serializer.fromJson<DateTime>(json['requestedAt']),
      approvedAt: serializer.fromJson<DateTime?>(json['approvedAt']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      borrowerReturnedAt:
          serializer.fromJson<DateTime?>(json['borrowerReturnedAt']),
      lenderReturnedAt:
          serializer.fromJson<DateTime?>(json['lenderReturnedAt']),
      returnedAt: serializer.fromJson<DateTime?>(json['returnedAt']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uuid': serializer.toJson<String>(uuid),
      'remoteId': serializer.toJson<String?>(remoteId),
      'sharedBookId': serializer.toJson<int?>(sharedBookId),
      'bookId': serializer.toJson<int?>(bookId),
      'borrowerUserId': serializer.toJson<int?>(borrowerUserId),
      'lenderUserId': serializer.toJson<int>(lenderUserId),
      'externalBorrowerName': serializer.toJson<String?>(externalBorrowerName),
      'externalBorrowerContact':
          serializer.toJson<String?>(externalBorrowerContact),
      'status': serializer.toJson<String>(status),
      'requestedAt': serializer.toJson<DateTime>(requestedAt),
      'approvedAt': serializer.toJson<DateTime?>(approvedAt),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'borrowerReturnedAt': serializer.toJson<DateTime?>(borrowerReturnedAt),
      'lenderReturnedAt': serializer.toJson<DateTime?>(lenderReturnedAt),
      'returnedAt': serializer.toJson<DateTime?>(returnedAt),
      'isDirty': serializer.toJson<bool>(isDirty),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Loan copyWith(
          {int? id,
          String? uuid,
          Value<String?> remoteId = const Value.absent(),
          Value<int?> sharedBookId = const Value.absent(),
          Value<int?> bookId = const Value.absent(),
          Value<int?> borrowerUserId = const Value.absent(),
          int? lenderUserId,
          Value<String?> externalBorrowerName = const Value.absent(),
          Value<String?> externalBorrowerContact = const Value.absent(),
          String? status,
          DateTime? requestedAt,
          Value<DateTime?> approvedAt = const Value.absent(),
          Value<DateTime?> dueDate = const Value.absent(),
          Value<DateTime?> borrowerReturnedAt = const Value.absent(),
          Value<DateTime?> lenderReturnedAt = const Value.absent(),
          Value<DateTime?> returnedAt = const Value.absent(),
          bool? isDirty,
          bool? isDeleted,
          Value<DateTime?> syncedAt = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Loan(
        id: id ?? this.id,
        uuid: uuid ?? this.uuid,
        remoteId: remoteId.present ? remoteId.value : this.remoteId,
        sharedBookId:
            sharedBookId.present ? sharedBookId.value : this.sharedBookId,
        bookId: bookId.present ? bookId.value : this.bookId,
        borrowerUserId:
            borrowerUserId.present ? borrowerUserId.value : this.borrowerUserId,
        lenderUserId: lenderUserId ?? this.lenderUserId,
        externalBorrowerName: externalBorrowerName.present
            ? externalBorrowerName.value
            : this.externalBorrowerName,
        externalBorrowerContact: externalBorrowerContact.present
            ? externalBorrowerContact.value
            : this.externalBorrowerContact,
        status: status ?? this.status,
        requestedAt: requestedAt ?? this.requestedAt,
        approvedAt: approvedAt.present ? approvedAt.value : this.approvedAt,
        dueDate: dueDate.present ? dueDate.value : this.dueDate,
        borrowerReturnedAt: borrowerReturnedAt.present
            ? borrowerReturnedAt.value
            : this.borrowerReturnedAt,
        lenderReturnedAt: lenderReturnedAt.present
            ? lenderReturnedAt.value
            : this.lenderReturnedAt,
        returnedAt: returnedAt.present ? returnedAt.value : this.returnedAt,
        isDirty: isDirty ?? this.isDirty,
        isDeleted: isDeleted ?? this.isDeleted,
        syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Loan copyWithCompanion(LoansCompanion data) {
    return Loan(
      id: data.id.present ? data.id.value : this.id,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      sharedBookId: data.sharedBookId.present
          ? data.sharedBookId.value
          : this.sharedBookId,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      borrowerUserId: data.borrowerUserId.present
          ? data.borrowerUserId.value
          : this.borrowerUserId,
      lenderUserId: data.lenderUserId.present
          ? data.lenderUserId.value
          : this.lenderUserId,
      externalBorrowerName: data.externalBorrowerName.present
          ? data.externalBorrowerName.value
          : this.externalBorrowerName,
      externalBorrowerContact: data.externalBorrowerContact.present
          ? data.externalBorrowerContact.value
          : this.externalBorrowerContact,
      status: data.status.present ? data.status.value : this.status,
      requestedAt:
          data.requestedAt.present ? data.requestedAt.value : this.requestedAt,
      approvedAt:
          data.approvedAt.present ? data.approvedAt.value : this.approvedAt,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      borrowerReturnedAt: data.borrowerReturnedAt.present
          ? data.borrowerReturnedAt.value
          : this.borrowerReturnedAt,
      lenderReturnedAt: data.lenderReturnedAt.present
          ? data.lenderReturnedAt.value
          : this.lenderReturnedAt,
      returnedAt:
          data.returnedAt.present ? data.returnedAt.value : this.returnedAt,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Loan(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('remoteId: $remoteId, ')
          ..write('sharedBookId: $sharedBookId, ')
          ..write('bookId: $bookId, ')
          ..write('borrowerUserId: $borrowerUserId, ')
          ..write('lenderUserId: $lenderUserId, ')
          ..write('externalBorrowerName: $externalBorrowerName, ')
          ..write('externalBorrowerContact: $externalBorrowerContact, ')
          ..write('status: $status, ')
          ..write('requestedAt: $requestedAt, ')
          ..write('approvedAt: $approvedAt, ')
          ..write('dueDate: $dueDate, ')
          ..write('borrowerReturnedAt: $borrowerReturnedAt, ')
          ..write('lenderReturnedAt: $lenderReturnedAt, ')
          ..write('returnedAt: $returnedAt, ')
          ..write('isDirty: $isDirty, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        uuid,
        remoteId,
        sharedBookId,
        bookId,
        borrowerUserId,
        lenderUserId,
        externalBorrowerName,
        externalBorrowerContact,
        status,
        requestedAt,
        approvedAt,
        dueDate,
        borrowerReturnedAt,
        lenderReturnedAt,
        returnedAt,
        isDirty,
        isDeleted,
        syncedAt,
        createdAt,
        updatedAt
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Loan &&
          other.id == this.id &&
          other.uuid == this.uuid &&
          other.remoteId == this.remoteId &&
          other.sharedBookId == this.sharedBookId &&
          other.bookId == this.bookId &&
          other.borrowerUserId == this.borrowerUserId &&
          other.lenderUserId == this.lenderUserId &&
          other.externalBorrowerName == this.externalBorrowerName &&
          other.externalBorrowerContact == this.externalBorrowerContact &&
          other.status == this.status &&
          other.requestedAt == this.requestedAt &&
          other.approvedAt == this.approvedAt &&
          other.dueDate == this.dueDate &&
          other.borrowerReturnedAt == this.borrowerReturnedAt &&
          other.lenderReturnedAt == this.lenderReturnedAt &&
          other.returnedAt == this.returnedAt &&
          other.isDirty == this.isDirty &&
          other.isDeleted == this.isDeleted &&
          other.syncedAt == this.syncedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LoansCompanion extends UpdateCompanion<Loan> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<String?> remoteId;
  final Value<int?> sharedBookId;
  final Value<int?> bookId;
  final Value<int?> borrowerUserId;
  final Value<int> lenderUserId;
  final Value<String?> externalBorrowerName;
  final Value<String?> externalBorrowerContact;
  final Value<String> status;
  final Value<DateTime> requestedAt;
  final Value<DateTime?> approvedAt;
  final Value<DateTime?> dueDate;
  final Value<DateTime?> borrowerReturnedAt;
  final Value<DateTime?> lenderReturnedAt;
  final Value<DateTime?> returnedAt;
  final Value<bool> isDirty;
  final Value<bool> isDeleted;
  final Value<DateTime?> syncedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const LoansCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.sharedBookId = const Value.absent(),
    this.bookId = const Value.absent(),
    this.borrowerUserId = const Value.absent(),
    this.lenderUserId = const Value.absent(),
    this.externalBorrowerName = const Value.absent(),
    this.externalBorrowerContact = const Value.absent(),
    this.status = const Value.absent(),
    this.requestedAt = const Value.absent(),
    this.approvedAt = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.borrowerReturnedAt = const Value.absent(),
    this.lenderReturnedAt = const Value.absent(),
    this.returnedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  LoansCompanion.insert({
    this.id = const Value.absent(),
    required String uuid,
    this.remoteId = const Value.absent(),
    this.sharedBookId = const Value.absent(),
    this.bookId = const Value.absent(),
    this.borrowerUserId = const Value.absent(),
    required int lenderUserId,
    this.externalBorrowerName = const Value.absent(),
    this.externalBorrowerContact = const Value.absent(),
    this.status = const Value.absent(),
    this.requestedAt = const Value.absent(),
    this.approvedAt = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.borrowerReturnedAt = const Value.absent(),
    this.lenderReturnedAt = const Value.absent(),
    this.returnedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : uuid = Value(uuid),
        lenderUserId = Value(lenderUserId);
  static Insertable<Loan> custom({
    Expression<int>? id,
    Expression<String>? uuid,
    Expression<String>? remoteId,
    Expression<int>? sharedBookId,
    Expression<int>? bookId,
    Expression<int>? borrowerUserId,
    Expression<int>? lenderUserId,
    Expression<String>? externalBorrowerName,
    Expression<String>? externalBorrowerContact,
    Expression<String>? status,
    Expression<DateTime>? requestedAt,
    Expression<DateTime>? approvedAt,
    Expression<DateTime>? dueDate,
    Expression<DateTime>? borrowerReturnedAt,
    Expression<DateTime>? lenderReturnedAt,
    Expression<DateTime>? returnedAt,
    Expression<bool>? isDirty,
    Expression<bool>? isDeleted,
    Expression<DateTime>? syncedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (remoteId != null) 'remote_id': remoteId,
      if (sharedBookId != null) 'shared_book_id': sharedBookId,
      if (bookId != null) 'book_id': bookId,
      if (borrowerUserId != null) 'borrower_user_id': borrowerUserId,
      if (lenderUserId != null) 'lender_user_id': lenderUserId,
      if (externalBorrowerName != null)
        'external_borrower_name': externalBorrowerName,
      if (externalBorrowerContact != null)
        'external_borrower_contact': externalBorrowerContact,
      if (status != null) 'status': status,
      if (requestedAt != null) 'requested_at': requestedAt,
      if (approvedAt != null) 'approved_at': approvedAt,
      if (dueDate != null) 'due_date': dueDate,
      if (borrowerReturnedAt != null)
        'borrower_returned_at': borrowerReturnedAt,
      if (lenderReturnedAt != null) 'lender_returned_at': lenderReturnedAt,
      if (returnedAt != null) 'returned_at': returnedAt,
      if (isDirty != null) 'is_dirty': isDirty,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  LoansCompanion copyWith(
      {Value<int>? id,
      Value<String>? uuid,
      Value<String?>? remoteId,
      Value<int?>? sharedBookId,
      Value<int?>? bookId,
      Value<int?>? borrowerUserId,
      Value<int>? lenderUserId,
      Value<String?>? externalBorrowerName,
      Value<String?>? externalBorrowerContact,
      Value<String>? status,
      Value<DateTime>? requestedAt,
      Value<DateTime?>? approvedAt,
      Value<DateTime?>? dueDate,
      Value<DateTime?>? borrowerReturnedAt,
      Value<DateTime?>? lenderReturnedAt,
      Value<DateTime?>? returnedAt,
      Value<bool>? isDirty,
      Value<bool>? isDeleted,
      Value<DateTime?>? syncedAt,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return LoansCompanion(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      remoteId: remoteId ?? this.remoteId,
      sharedBookId: sharedBookId ?? this.sharedBookId,
      bookId: bookId ?? this.bookId,
      borrowerUserId: borrowerUserId ?? this.borrowerUserId,
      lenderUserId: lenderUserId ?? this.lenderUserId,
      externalBorrowerName: externalBorrowerName ?? this.externalBorrowerName,
      externalBorrowerContact:
          externalBorrowerContact ?? this.externalBorrowerContact,
      status: status ?? this.status,
      requestedAt: requestedAt ?? this.requestedAt,
      approvedAt: approvedAt ?? this.approvedAt,
      dueDate: dueDate ?? this.dueDate,
      borrowerReturnedAt: borrowerReturnedAt ?? this.borrowerReturnedAt,
      lenderReturnedAt: lenderReturnedAt ?? this.lenderReturnedAt,
      returnedAt: returnedAt ?? this.returnedAt,
      isDirty: isDirty ?? this.isDirty,
      isDeleted: isDeleted ?? this.isDeleted,
      syncedAt: syncedAt ?? this.syncedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (sharedBookId.present) {
      map['shared_book_id'] = Variable<int>(sharedBookId.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<int>(bookId.value);
    }
    if (borrowerUserId.present) {
      map['borrower_user_id'] = Variable<int>(borrowerUserId.value);
    }
    if (lenderUserId.present) {
      map['lender_user_id'] = Variable<int>(lenderUserId.value);
    }
    if (externalBorrowerName.present) {
      map['external_borrower_name'] =
          Variable<String>(externalBorrowerName.value);
    }
    if (externalBorrowerContact.present) {
      map['external_borrower_contact'] =
          Variable<String>(externalBorrowerContact.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (requestedAt.present) {
      map['requested_at'] = Variable<DateTime>(requestedAt.value);
    }
    if (approvedAt.present) {
      map['approved_at'] = Variable<DateTime>(approvedAt.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (borrowerReturnedAt.present) {
      map['borrower_returned_at'] =
          Variable<DateTime>(borrowerReturnedAt.value);
    }
    if (lenderReturnedAt.present) {
      map['lender_returned_at'] = Variable<DateTime>(lenderReturnedAt.value);
    }
    if (returnedAt.present) {
      map['returned_at'] = Variable<DateTime>(returnedAt.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LoansCompanion(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('remoteId: $remoteId, ')
          ..write('sharedBookId: $sharedBookId, ')
          ..write('bookId: $bookId, ')
          ..write('borrowerUserId: $borrowerUserId, ')
          ..write('lenderUserId: $lenderUserId, ')
          ..write('externalBorrowerName: $externalBorrowerName, ')
          ..write('externalBorrowerContact: $externalBorrowerContact, ')
          ..write('status: $status, ')
          ..write('requestedAt: $requestedAt, ')
          ..write('approvedAt: $approvedAt, ')
          ..write('dueDate: $dueDate, ')
          ..write('borrowerReturnedAt: $borrowerReturnedAt, ')
          ..write('lenderReturnedAt: $lenderReturnedAt, ')
          ..write('returnedAt: $returnedAt, ')
          ..write('isDirty: $isDirty, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $InAppNotificationsTable extends InAppNotifications
    with TableInfo<$InAppNotificationsTable, InAppNotification> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InAppNotificationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 36),
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 64),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _loanIdMeta = const VerificationMeta('loanId');
  @override
  late final GeneratedColumn<int> loanId = GeneratedColumn<int>(
      'loan_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES loans (id)'));
  static const VerificationMeta _loanUuidMeta =
      const VerificationMeta('loanUuid');
  @override
  late final GeneratedColumn<String> loanUuid = GeneratedColumn<String>(
      'loan_uuid', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sharedBookIdMeta =
      const VerificationMeta('sharedBookId');
  @override
  late final GeneratedColumn<int> sharedBookId = GeneratedColumn<int>(
      'shared_book_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES shared_books (id)'));
  static const VerificationMeta _sharedBookUuidMeta =
      const VerificationMeta('sharedBookUuid');
  @override
  late final GeneratedColumn<String> sharedBookUuid = GeneratedColumn<String>(
      'shared_book_uuid', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _actorUserIdMeta =
      const VerificationMeta('actorUserId');
  @override
  late final GeneratedColumn<int> actorUserId = GeneratedColumn<int>(
      'actor_user_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES local_users (id)'));
  static const VerificationMeta _targetUserIdMeta =
      const VerificationMeta('targetUserId');
  @override
  late final GeneratedColumn<int> targetUserId = GeneratedColumn<int>(
      'target_user_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES local_users (id)'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _messageMeta =
      const VerificationMeta('message');
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
      'message', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 32),
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('unread'));
  static const VerificationMeta _isDirtyMeta =
      const VerificationMeta('isDirty');
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
      'is_dirty', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_dirty" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _syncedAtMeta =
      const VerificationMeta('syncedAt');
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
      'synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        uuid,
        type,
        loanId,
        loanUuid,
        sharedBookId,
        sharedBookUuid,
        actorUserId,
        targetUserId,
        title,
        message,
        status,
        isDirty,
        isDeleted,
        syncedAt,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'in_app_notifications';
  @override
  VerificationContext validateIntegrity(Insertable<InAppNotification> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('loan_id')) {
      context.handle(_loanIdMeta,
          loanId.isAcceptableOrUnknown(data['loan_id']!, _loanIdMeta));
    }
    if (data.containsKey('loan_uuid')) {
      context.handle(_loanUuidMeta,
          loanUuid.isAcceptableOrUnknown(data['loan_uuid']!, _loanUuidMeta));
    }
    if (data.containsKey('shared_book_id')) {
      context.handle(
          _sharedBookIdMeta,
          sharedBookId.isAcceptableOrUnknown(
              data['shared_book_id']!, _sharedBookIdMeta));
    }
    if (data.containsKey('shared_book_uuid')) {
      context.handle(
          _sharedBookUuidMeta,
          sharedBookUuid.isAcceptableOrUnknown(
              data['shared_book_uuid']!, _sharedBookUuidMeta));
    }
    if (data.containsKey('actor_user_id')) {
      context.handle(
          _actorUserIdMeta,
          actorUserId.isAcceptableOrUnknown(
              data['actor_user_id']!, _actorUserIdMeta));
    }
    if (data.containsKey('target_user_id')) {
      context.handle(
          _targetUserIdMeta,
          targetUserId.isAcceptableOrUnknown(
              data['target_user_id']!, _targetUserIdMeta));
    } else if (isInserting) {
      context.missing(_targetUserIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    }
    if (data.containsKey('message')) {
      context.handle(_messageMeta,
          message.isAcceptableOrUnknown(data['message']!, _messageMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('is_dirty')) {
      context.handle(_isDirtyMeta,
          isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('synced_at')) {
      context.handle(_syncedAtMeta,
          syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InAppNotification map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InAppNotification(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      loanId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}loan_id']),
      loanUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}loan_uuid']),
      sharedBookId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}shared_book_id']),
      sharedBookUuid: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}shared_book_uuid']),
      actorUserId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}actor_user_id']),
      targetUserId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}target_user_id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title']),
      message: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}message']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      isDirty: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_dirty'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      syncedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}synced_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $InAppNotificationsTable createAlias(String alias) {
    return $InAppNotificationsTable(attachedDatabase, alias);
  }
}

class InAppNotification extends DataClass
    implements Insertable<InAppNotification> {
  final int id;
  final String uuid;
  final String type;
  final int? loanId;
  final String? loanUuid;
  final int? sharedBookId;
  final String? sharedBookUuid;
  final int? actorUserId;
  final int targetUserId;
  final String? title;
  final String? message;
  final String status;
  final bool isDirty;
  final bool isDeleted;
  final DateTime? syncedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const InAppNotification(
      {required this.id,
      required this.uuid,
      required this.type,
      this.loanId,
      this.loanUuid,
      this.sharedBookId,
      this.sharedBookUuid,
      this.actorUserId,
      required this.targetUserId,
      this.title,
      this.message,
      required this.status,
      required this.isDirty,
      required this.isDeleted,
      this.syncedAt,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uuid'] = Variable<String>(uuid);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || loanId != null) {
      map['loan_id'] = Variable<int>(loanId);
    }
    if (!nullToAbsent || loanUuid != null) {
      map['loan_uuid'] = Variable<String>(loanUuid);
    }
    if (!nullToAbsent || sharedBookId != null) {
      map['shared_book_id'] = Variable<int>(sharedBookId);
    }
    if (!nullToAbsent || sharedBookUuid != null) {
      map['shared_book_uuid'] = Variable<String>(sharedBookUuid);
    }
    if (!nullToAbsent || actorUserId != null) {
      map['actor_user_id'] = Variable<int>(actorUserId);
    }
    map['target_user_id'] = Variable<int>(targetUserId);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || message != null) {
      map['message'] = Variable<String>(message);
    }
    map['status'] = Variable<String>(status);
    map['is_dirty'] = Variable<bool>(isDirty);
    map['is_deleted'] = Variable<bool>(isDeleted);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  InAppNotificationsCompanion toCompanion(bool nullToAbsent) {
    return InAppNotificationsCompanion(
      id: Value(id),
      uuid: Value(uuid),
      type: Value(type),
      loanId:
          loanId == null && nullToAbsent ? const Value.absent() : Value(loanId),
      loanUuid: loanUuid == null && nullToAbsent
          ? const Value.absent()
          : Value(loanUuid),
      sharedBookId: sharedBookId == null && nullToAbsent
          ? const Value.absent()
          : Value(sharedBookId),
      sharedBookUuid: sharedBookUuid == null && nullToAbsent
          ? const Value.absent()
          : Value(sharedBookUuid),
      actorUserId: actorUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(actorUserId),
      targetUserId: Value(targetUserId),
      title:
          title == null && nullToAbsent ? const Value.absent() : Value(title),
      message: message == null && nullToAbsent
          ? const Value.absent()
          : Value(message),
      status: Value(status),
      isDirty: Value(isDirty),
      isDeleted: Value(isDeleted),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory InAppNotification.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InAppNotification(
      id: serializer.fromJson<int>(json['id']),
      uuid: serializer.fromJson<String>(json['uuid']),
      type: serializer.fromJson<String>(json['type']),
      loanId: serializer.fromJson<int?>(json['loanId']),
      loanUuid: serializer.fromJson<String?>(json['loanUuid']),
      sharedBookId: serializer.fromJson<int?>(json['sharedBookId']),
      sharedBookUuid: serializer.fromJson<String?>(json['sharedBookUuid']),
      actorUserId: serializer.fromJson<int?>(json['actorUserId']),
      targetUserId: serializer.fromJson<int>(json['targetUserId']),
      title: serializer.fromJson<String?>(json['title']),
      message: serializer.fromJson<String?>(json['message']),
      status: serializer.fromJson<String>(json['status']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uuid': serializer.toJson<String>(uuid),
      'type': serializer.toJson<String>(type),
      'loanId': serializer.toJson<int?>(loanId),
      'loanUuid': serializer.toJson<String?>(loanUuid),
      'sharedBookId': serializer.toJson<int?>(sharedBookId),
      'sharedBookUuid': serializer.toJson<String?>(sharedBookUuid),
      'actorUserId': serializer.toJson<int?>(actorUserId),
      'targetUserId': serializer.toJson<int>(targetUserId),
      'title': serializer.toJson<String?>(title),
      'message': serializer.toJson<String?>(message),
      'status': serializer.toJson<String>(status),
      'isDirty': serializer.toJson<bool>(isDirty),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  InAppNotification copyWith(
          {int? id,
          String? uuid,
          String? type,
          Value<int?> loanId = const Value.absent(),
          Value<String?> loanUuid = const Value.absent(),
          Value<int?> sharedBookId = const Value.absent(),
          Value<String?> sharedBookUuid = const Value.absent(),
          Value<int?> actorUserId = const Value.absent(),
          int? targetUserId,
          Value<String?> title = const Value.absent(),
          Value<String?> message = const Value.absent(),
          String? status,
          bool? isDirty,
          bool? isDeleted,
          Value<DateTime?> syncedAt = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      InAppNotification(
        id: id ?? this.id,
        uuid: uuid ?? this.uuid,
        type: type ?? this.type,
        loanId: loanId.present ? loanId.value : this.loanId,
        loanUuid: loanUuid.present ? loanUuid.value : this.loanUuid,
        sharedBookId:
            sharedBookId.present ? sharedBookId.value : this.sharedBookId,
        sharedBookUuid:
            sharedBookUuid.present ? sharedBookUuid.value : this.sharedBookUuid,
        actorUserId: actorUserId.present ? actorUserId.value : this.actorUserId,
        targetUserId: targetUserId ?? this.targetUserId,
        title: title.present ? title.value : this.title,
        message: message.present ? message.value : this.message,
        status: status ?? this.status,
        isDirty: isDirty ?? this.isDirty,
        isDeleted: isDeleted ?? this.isDeleted,
        syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  InAppNotification copyWithCompanion(InAppNotificationsCompanion data) {
    return InAppNotification(
      id: data.id.present ? data.id.value : this.id,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      type: data.type.present ? data.type.value : this.type,
      loanId: data.loanId.present ? data.loanId.value : this.loanId,
      loanUuid: data.loanUuid.present ? data.loanUuid.value : this.loanUuid,
      sharedBookId: data.sharedBookId.present
          ? data.sharedBookId.value
          : this.sharedBookId,
      sharedBookUuid: data.sharedBookUuid.present
          ? data.sharedBookUuid.value
          : this.sharedBookUuid,
      actorUserId:
          data.actorUserId.present ? data.actorUserId.value : this.actorUserId,
      targetUserId: data.targetUserId.present
          ? data.targetUserId.value
          : this.targetUserId,
      title: data.title.present ? data.title.value : this.title,
      message: data.message.present ? data.message.value : this.message,
      status: data.status.present ? data.status.value : this.status,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InAppNotification(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('type: $type, ')
          ..write('loanId: $loanId, ')
          ..write('loanUuid: $loanUuid, ')
          ..write('sharedBookId: $sharedBookId, ')
          ..write('sharedBookUuid: $sharedBookUuid, ')
          ..write('actorUserId: $actorUserId, ')
          ..write('targetUserId: $targetUserId, ')
          ..write('title: $title, ')
          ..write('message: $message, ')
          ..write('status: $status, ')
          ..write('isDirty: $isDirty, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      uuid,
      type,
      loanId,
      loanUuid,
      sharedBookId,
      sharedBookUuid,
      actorUserId,
      targetUserId,
      title,
      message,
      status,
      isDirty,
      isDeleted,
      syncedAt,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InAppNotification &&
          other.id == this.id &&
          other.uuid == this.uuid &&
          other.type == this.type &&
          other.loanId == this.loanId &&
          other.loanUuid == this.loanUuid &&
          other.sharedBookId == this.sharedBookId &&
          other.sharedBookUuid == this.sharedBookUuid &&
          other.actorUserId == this.actorUserId &&
          other.targetUserId == this.targetUserId &&
          other.title == this.title &&
          other.message == this.message &&
          other.status == this.status &&
          other.isDirty == this.isDirty &&
          other.isDeleted == this.isDeleted &&
          other.syncedAt == this.syncedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class InAppNotificationsCompanion extends UpdateCompanion<InAppNotification> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<String> type;
  final Value<int?> loanId;
  final Value<String?> loanUuid;
  final Value<int?> sharedBookId;
  final Value<String?> sharedBookUuid;
  final Value<int?> actorUserId;
  final Value<int> targetUserId;
  final Value<String?> title;
  final Value<String?> message;
  final Value<String> status;
  final Value<bool> isDirty;
  final Value<bool> isDeleted;
  final Value<DateTime?> syncedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const InAppNotificationsCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.type = const Value.absent(),
    this.loanId = const Value.absent(),
    this.loanUuid = const Value.absent(),
    this.sharedBookId = const Value.absent(),
    this.sharedBookUuid = const Value.absent(),
    this.actorUserId = const Value.absent(),
    this.targetUserId = const Value.absent(),
    this.title = const Value.absent(),
    this.message = const Value.absent(),
    this.status = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  InAppNotificationsCompanion.insert({
    this.id = const Value.absent(),
    required String uuid,
    required String type,
    this.loanId = const Value.absent(),
    this.loanUuid = const Value.absent(),
    this.sharedBookId = const Value.absent(),
    this.sharedBookUuid = const Value.absent(),
    this.actorUserId = const Value.absent(),
    required int targetUserId,
    this.title = const Value.absent(),
    this.message = const Value.absent(),
    this.status = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : uuid = Value(uuid),
        type = Value(type),
        targetUserId = Value(targetUserId);
  static Insertable<InAppNotification> custom({
    Expression<int>? id,
    Expression<String>? uuid,
    Expression<String>? type,
    Expression<int>? loanId,
    Expression<String>? loanUuid,
    Expression<int>? sharedBookId,
    Expression<String>? sharedBookUuid,
    Expression<int>? actorUserId,
    Expression<int>? targetUserId,
    Expression<String>? title,
    Expression<String>? message,
    Expression<String>? status,
    Expression<bool>? isDirty,
    Expression<bool>? isDeleted,
    Expression<DateTime>? syncedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (type != null) 'type': type,
      if (loanId != null) 'loan_id': loanId,
      if (loanUuid != null) 'loan_uuid': loanUuid,
      if (sharedBookId != null) 'shared_book_id': sharedBookId,
      if (sharedBookUuid != null) 'shared_book_uuid': sharedBookUuid,
      if (actorUserId != null) 'actor_user_id': actorUserId,
      if (targetUserId != null) 'target_user_id': targetUserId,
      if (title != null) 'title': title,
      if (message != null) 'message': message,
      if (status != null) 'status': status,
      if (isDirty != null) 'is_dirty': isDirty,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  InAppNotificationsCompanion copyWith(
      {Value<int>? id,
      Value<String>? uuid,
      Value<String>? type,
      Value<int?>? loanId,
      Value<String?>? loanUuid,
      Value<int?>? sharedBookId,
      Value<String?>? sharedBookUuid,
      Value<int?>? actorUserId,
      Value<int>? targetUserId,
      Value<String?>? title,
      Value<String?>? message,
      Value<String>? status,
      Value<bool>? isDirty,
      Value<bool>? isDeleted,
      Value<DateTime?>? syncedAt,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return InAppNotificationsCompanion(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      type: type ?? this.type,
      loanId: loanId ?? this.loanId,
      loanUuid: loanUuid ?? this.loanUuid,
      sharedBookId: sharedBookId ?? this.sharedBookId,
      sharedBookUuid: sharedBookUuid ?? this.sharedBookUuid,
      actorUserId: actorUserId ?? this.actorUserId,
      targetUserId: targetUserId ?? this.targetUserId,
      title: title ?? this.title,
      message: message ?? this.message,
      status: status ?? this.status,
      isDirty: isDirty ?? this.isDirty,
      isDeleted: isDeleted ?? this.isDeleted,
      syncedAt: syncedAt ?? this.syncedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (loanId.present) {
      map['loan_id'] = Variable<int>(loanId.value);
    }
    if (loanUuid.present) {
      map['loan_uuid'] = Variable<String>(loanUuid.value);
    }
    if (sharedBookId.present) {
      map['shared_book_id'] = Variable<int>(sharedBookId.value);
    }
    if (sharedBookUuid.present) {
      map['shared_book_uuid'] = Variable<String>(sharedBookUuid.value);
    }
    if (actorUserId.present) {
      map['actor_user_id'] = Variable<int>(actorUserId.value);
    }
    if (targetUserId.present) {
      map['target_user_id'] = Variable<int>(targetUserId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InAppNotificationsCompanion(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('type: $type, ')
          ..write('loanId: $loanId, ')
          ..write('loanUuid: $loanUuid, ')
          ..write('sharedBookId: $sharedBookId, ')
          ..write('sharedBookUuid: $sharedBookUuid, ')
          ..write('actorUserId: $actorUserId, ')
          ..write('targetUserId: $targetUserId, ')
          ..write('title: $title, ')
          ..write('message: $message, ')
          ..write('status: $status, ')
          ..write('isDirty: $isDirty, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $LoanNotificationsTable extends LoanNotifications
    with TableInfo<$LoanNotificationsTable, LoanNotification> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LoanNotificationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 36),
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _remoteIdMeta =
      const VerificationMeta('remoteId');
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
      'remote_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _loanIdMeta = const VerificationMeta('loanId');
  @override
  late final GeneratedColumn<int> loanId = GeneratedColumn<int>(
      'loan_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES loans (id) ON DELETE CASCADE'));
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
      'user_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES local_users (id) ON DELETE CASCADE'));
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 50),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _messageMeta =
      const VerificationMeta('message');
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
      'message', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('unread'));
  static const VerificationMeta _readAtMeta = const VerificationMeta('readAt');
  @override
  late final GeneratedColumn<DateTime> readAt = GeneratedColumn<DateTime>(
      'read_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _isDirtyMeta =
      const VerificationMeta('isDirty');
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
      'is_dirty', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_dirty" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _syncedAtMeta =
      const VerificationMeta('syncedAt');
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
      'synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        uuid,
        remoteId,
        loanId,
        userId,
        type,
        title,
        message,
        status,
        readAt,
        isDirty,
        syncedAt,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'loan_notifications';
  @override
  VerificationContext validateIntegrity(Insertable<LoanNotification> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('remote_id')) {
      context.handle(_remoteIdMeta,
          remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta));
    }
    if (data.containsKey('loan_id')) {
      context.handle(_loanIdMeta,
          loanId.isAcceptableOrUnknown(data['loan_id']!, _loanIdMeta));
    } else if (isInserting) {
      context.missing(_loanIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('message')) {
      context.handle(_messageMeta,
          message.isAcceptableOrUnknown(data['message']!, _messageMeta));
    } else if (isInserting) {
      context.missing(_messageMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('read_at')) {
      context.handle(_readAtMeta,
          readAt.isAcceptableOrUnknown(data['read_at']!, _readAtMeta));
    }
    if (data.containsKey('is_dirty')) {
      context.handle(_isDirtyMeta,
          isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta));
    }
    if (data.containsKey('synced_at')) {
      context.handle(_syncedAtMeta,
          syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LoanNotification map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LoanNotification(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      remoteId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}remote_id']),
      loanId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}loan_id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}user_id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      message: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}message'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      readAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}read_at']),
      isDirty: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_dirty'])!,
      syncedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}synced_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $LoanNotificationsTable createAlias(String alias) {
    return $LoanNotificationsTable(attachedDatabase, alias);
  }
}

class LoanNotification extends DataClass
    implements Insertable<LoanNotification> {
  final int id;
  final String uuid;
  final String? remoteId;
  final int loanId;
  final int userId;
  final String type;
  final String title;
  final String message;
  final String status;
  final DateTime? readAt;
  final bool isDirty;
  final DateTime? syncedAt;
  final DateTime createdAt;
  const LoanNotification(
      {required this.id,
      required this.uuid,
      this.remoteId,
      required this.loanId,
      required this.userId,
      required this.type,
      required this.title,
      required this.message,
      required this.status,
      this.readAt,
      required this.isDirty,
      this.syncedAt,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uuid'] = Variable<String>(uuid);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<String>(remoteId);
    }
    map['loan_id'] = Variable<int>(loanId);
    map['user_id'] = Variable<int>(userId);
    map['type'] = Variable<String>(type);
    map['title'] = Variable<String>(title);
    map['message'] = Variable<String>(message);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || readAt != null) {
      map['read_at'] = Variable<DateTime>(readAt);
    }
    map['is_dirty'] = Variable<bool>(isDirty);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  LoanNotificationsCompanion toCompanion(bool nullToAbsent) {
    return LoanNotificationsCompanion(
      id: Value(id),
      uuid: Value(uuid),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      loanId: Value(loanId),
      userId: Value(userId),
      type: Value(type),
      title: Value(title),
      message: Value(message),
      status: Value(status),
      readAt:
          readAt == null && nullToAbsent ? const Value.absent() : Value(readAt),
      isDirty: Value(isDirty),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
      createdAt: Value(createdAt),
    );
  }

  factory LoanNotification.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LoanNotification(
      id: serializer.fromJson<int>(json['id']),
      uuid: serializer.fromJson<String>(json['uuid']),
      remoteId: serializer.fromJson<String?>(json['remoteId']),
      loanId: serializer.fromJson<int>(json['loanId']),
      userId: serializer.fromJson<int>(json['userId']),
      type: serializer.fromJson<String>(json['type']),
      title: serializer.fromJson<String>(json['title']),
      message: serializer.fromJson<String>(json['message']),
      status: serializer.fromJson<String>(json['status']),
      readAt: serializer.fromJson<DateTime?>(json['readAt']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uuid': serializer.toJson<String>(uuid),
      'remoteId': serializer.toJson<String?>(remoteId),
      'loanId': serializer.toJson<int>(loanId),
      'userId': serializer.toJson<int>(userId),
      'type': serializer.toJson<String>(type),
      'title': serializer.toJson<String>(title),
      'message': serializer.toJson<String>(message),
      'status': serializer.toJson<String>(status),
      'readAt': serializer.toJson<DateTime?>(readAt),
      'isDirty': serializer.toJson<bool>(isDirty),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  LoanNotification copyWith(
          {int? id,
          String? uuid,
          Value<String?> remoteId = const Value.absent(),
          int? loanId,
          int? userId,
          String? type,
          String? title,
          String? message,
          String? status,
          Value<DateTime?> readAt = const Value.absent(),
          bool? isDirty,
          Value<DateTime?> syncedAt = const Value.absent(),
          DateTime? createdAt}) =>
      LoanNotification(
        id: id ?? this.id,
        uuid: uuid ?? this.uuid,
        remoteId: remoteId.present ? remoteId.value : this.remoteId,
        loanId: loanId ?? this.loanId,
        userId: userId ?? this.userId,
        type: type ?? this.type,
        title: title ?? this.title,
        message: message ?? this.message,
        status: status ?? this.status,
        readAt: readAt.present ? readAt.value : this.readAt,
        isDirty: isDirty ?? this.isDirty,
        syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
        createdAt: createdAt ?? this.createdAt,
      );
  LoanNotification copyWithCompanion(LoanNotificationsCompanion data) {
    return LoanNotification(
      id: data.id.present ? data.id.value : this.id,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      loanId: data.loanId.present ? data.loanId.value : this.loanId,
      userId: data.userId.present ? data.userId.value : this.userId,
      type: data.type.present ? data.type.value : this.type,
      title: data.title.present ? data.title.value : this.title,
      message: data.message.present ? data.message.value : this.message,
      status: data.status.present ? data.status.value : this.status,
      readAt: data.readAt.present ? data.readAt.value : this.readAt,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LoanNotification(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('remoteId: $remoteId, ')
          ..write('loanId: $loanId, ')
          ..write('userId: $userId, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('message: $message, ')
          ..write('status: $status, ')
          ..write('readAt: $readAt, ')
          ..write('isDirty: $isDirty, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, uuid, remoteId, loanId, userId, type,
      title, message, status, readAt, isDirty, syncedAt, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LoanNotification &&
          other.id == this.id &&
          other.uuid == this.uuid &&
          other.remoteId == this.remoteId &&
          other.loanId == this.loanId &&
          other.userId == this.userId &&
          other.type == this.type &&
          other.title == this.title &&
          other.message == this.message &&
          other.status == this.status &&
          other.readAt == this.readAt &&
          other.isDirty == this.isDirty &&
          other.syncedAt == this.syncedAt &&
          other.createdAt == this.createdAt);
}

class LoanNotificationsCompanion extends UpdateCompanion<LoanNotification> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<String?> remoteId;
  final Value<int> loanId;
  final Value<int> userId;
  final Value<String> type;
  final Value<String> title;
  final Value<String> message;
  final Value<String> status;
  final Value<DateTime?> readAt;
  final Value<bool> isDirty;
  final Value<DateTime?> syncedAt;
  final Value<DateTime> createdAt;
  const LoanNotificationsCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.loanId = const Value.absent(),
    this.userId = const Value.absent(),
    this.type = const Value.absent(),
    this.title = const Value.absent(),
    this.message = const Value.absent(),
    this.status = const Value.absent(),
    this.readAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  LoanNotificationsCompanion.insert({
    this.id = const Value.absent(),
    required String uuid,
    this.remoteId = const Value.absent(),
    required int loanId,
    required int userId,
    required String type,
    required String title,
    required String message,
    this.status = const Value.absent(),
    this.readAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : uuid = Value(uuid),
        loanId = Value(loanId),
        userId = Value(userId),
        type = Value(type),
        title = Value(title),
        message = Value(message);
  static Insertable<LoanNotification> custom({
    Expression<int>? id,
    Expression<String>? uuid,
    Expression<String>? remoteId,
    Expression<int>? loanId,
    Expression<int>? userId,
    Expression<String>? type,
    Expression<String>? title,
    Expression<String>? message,
    Expression<String>? status,
    Expression<DateTime>? readAt,
    Expression<bool>? isDirty,
    Expression<DateTime>? syncedAt,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (remoteId != null) 'remote_id': remoteId,
      if (loanId != null) 'loan_id': loanId,
      if (userId != null) 'user_id': userId,
      if (type != null) 'type': type,
      if (title != null) 'title': title,
      if (message != null) 'message': message,
      if (status != null) 'status': status,
      if (readAt != null) 'read_at': readAt,
      if (isDirty != null) 'is_dirty': isDirty,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  LoanNotificationsCompanion copyWith(
      {Value<int>? id,
      Value<String>? uuid,
      Value<String?>? remoteId,
      Value<int>? loanId,
      Value<int>? userId,
      Value<String>? type,
      Value<String>? title,
      Value<String>? message,
      Value<String>? status,
      Value<DateTime?>? readAt,
      Value<bool>? isDirty,
      Value<DateTime?>? syncedAt,
      Value<DateTime>? createdAt}) {
    return LoanNotificationsCompanion(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      remoteId: remoteId ?? this.remoteId,
      loanId: loanId ?? this.loanId,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      status: status ?? this.status,
      readAt: readAt ?? this.readAt,
      isDirty: isDirty ?? this.isDirty,
      syncedAt: syncedAt ?? this.syncedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (loanId.present) {
      map['loan_id'] = Variable<int>(loanId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (readAt.present) {
      map['read_at'] = Variable<DateTime>(readAt.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LoanNotificationsCompanion(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('remoteId: $remoteId, ')
          ..write('loanId: $loanId, ')
          ..write('userId: $userId, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('message: $message, ')
          ..write('status: $status, ')
          ..write('readAt: $readAt, ')
          ..write('isDirty: $isDirty, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocalUsersTable localUsers = $LocalUsersTable(this);
  late final $BooksTable books = $BooksTable(this);
  late final $BookReviewsTable bookReviews = $BookReviewsTable(this);
  late final $GroupsTable groups = $GroupsTable(this);
  late final $GroupMembersTable groupMembers = $GroupMembersTable(this);
  late final $SharedBooksTable sharedBooks = $SharedBooksTable(this);
  late final $GroupInvitationsTable groupInvitations =
      $GroupInvitationsTable(this);
  late final $LoansTable loans = $LoansTable(this);
  late final $InAppNotificationsTable inAppNotifications =
      $InAppNotificationsTable(this);
  late final $LoanNotificationsTable loanNotifications =
      $LoanNotificationsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        localUsers,
        books,
        bookReviews,
        groups,
        groupMembers,
        sharedBooks,
        groupInvitations,
        loans,
        inAppNotifications,
        loanNotifications
      ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('books',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('book_reviews', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('groups',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('group_members', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('groups',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('shared_books', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('books',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('shared_books', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('groups',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('group_invitations', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('shared_books',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('loans', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('books',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('loans', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('loans',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('loan_notifications', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('local_users',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('loan_notifications', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $$LocalUsersTableCreateCompanionBuilder = LocalUsersCompanion Function({
  Value<int> id,
  required String uuid,
  required String username,
  Value<String?> remoteId,
  Value<String?> pinHash,
  Value<String?> pinSalt,
  Value<DateTime?> pinUpdatedAt,
  Value<bool> isDirty,
  Value<bool> isDeleted,
  Value<DateTime?> syncedAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$LocalUsersTableUpdateCompanionBuilder = LocalUsersCompanion Function({
  Value<int> id,
  Value<String> uuid,
  Value<String> username,
  Value<String?> remoteId,
  Value<String?> pinHash,
  Value<String?> pinSalt,
  Value<DateTime?> pinUpdatedAt,
  Value<bool> isDirty,
  Value<bool> isDeleted,
  Value<DateTime?> syncedAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

final class $$LocalUsersTableReferences
    extends BaseReferences<_$AppDatabase, $LocalUsersTable, LocalUser> {
  $$LocalUsersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$BooksTable, List<Book>> _ownedBooksTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.books,
          aliasName:
              $_aliasNameGenerator(db.localUsers.id, db.books.ownerUserId));

  $$BooksTableProcessedTableManager get ownedBooks {
    final manager = $$BooksTableTableManager($_db, $_db.books)
        .filter((f) => f.ownerUserId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_ownedBooksTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$BookReviewsTable, List<BookReview>>
      _bookReviewsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.bookReviews,
              aliasName: $_aliasNameGenerator(
                  db.localUsers.id, db.bookReviews.authorUserId));

  $$BookReviewsTableProcessedTableManager get bookReviewsRefs {
    final manager = $$BookReviewsTableTableManager($_db, $_db.bookReviews)
        .filter((f) => f.authorUserId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_bookReviewsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$GroupsTable, List<Group>> _groupsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.groups,
          aliasName:
              $_aliasNameGenerator(db.localUsers.id, db.groups.ownerUserId));

  $$GroupsTableProcessedTableManager get groupsRefs {
    final manager = $$GroupsTableTableManager($_db, $_db.groups)
        .filter((f) => f.ownerUserId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_groupsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$GroupMembersTable, List<GroupMember>>
      _groupMembershipsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.groupMembers,
              aliasName: $_aliasNameGenerator(
                  db.localUsers.id, db.groupMembers.memberUserId));

  $$GroupMembersTableProcessedTableManager get groupMemberships {
    final manager = $$GroupMembersTableTableManager($_db, $_db.groupMembers)
        .filter((f) => f.memberUserId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_groupMembershipsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$SharedBooksTable, List<SharedBook>>
      _sharedBooksOwnedTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.sharedBooks,
              aliasName: $_aliasNameGenerator(
                  db.localUsers.id, db.sharedBooks.ownerUserId));

  $$SharedBooksTableProcessedTableManager get sharedBooksOwned {
    final manager = $$SharedBooksTableTableManager($_db, $_db.sharedBooks)
        .filter((f) => f.ownerUserId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_sharedBooksOwnedTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$GroupInvitationsTable, List<GroupInvitation>>
      _groupInvitationsSentTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.groupInvitations,
              aliasName: $_aliasNameGenerator(
                  db.localUsers.id, db.groupInvitations.inviterUserId));

  $$GroupInvitationsTableProcessedTableManager get groupInvitationsSent {
    final manager = $$GroupInvitationsTableTableManager(
            $_db, $_db.groupInvitations)
        .filter((f) => f.inviterUserId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_groupInvitationsSentTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$GroupInvitationsTable, List<GroupInvitation>>
      _groupInvitationsAcceptedTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.groupInvitations,
              aliasName: $_aliasNameGenerator(
                  db.localUsers.id, db.groupInvitations.acceptedUserId));

  $$GroupInvitationsTableProcessedTableManager get groupInvitationsAccepted {
    final manager = $$GroupInvitationsTableTableManager(
            $_db, $_db.groupInvitations)
        .filter((f) => f.acceptedUserId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_groupInvitationsAcceptedTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$LoansTable, List<Loan>> _loansBorrowerTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.loans,
          aliasName:
              $_aliasNameGenerator(db.localUsers.id, db.loans.borrowerUserId));

  $$LoansTableProcessedTableManager get loansBorrower {
    final manager = $$LoansTableTableManager($_db, $_db.loans)
        .filter((f) => f.borrowerUserId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_loansBorrowerTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$LoansTable, List<Loan>> _loansLenderTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.loans,
          aliasName:
              $_aliasNameGenerator(db.localUsers.id, db.loans.lenderUserId));

  $$LoansTableProcessedTableManager get loansLender {
    final manager = $$LoansTableTableManager($_db, $_db.loans)
        .filter((f) => f.lenderUserId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_loansLenderTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$InAppNotificationsTable, List<InAppNotification>>
      _notificationsAuthoredTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.inAppNotifications,
              aliasName: $_aliasNameGenerator(
                  db.localUsers.id, db.inAppNotifications.actorUserId));

  $$InAppNotificationsTableProcessedTableManager get notificationsAuthored {
    final manager = $$InAppNotificationsTableTableManager(
            $_db, $_db.inAppNotifications)
        .filter((f) => f.actorUserId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_notificationsAuthoredTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$InAppNotificationsTable, List<InAppNotification>>
      _notificationsReceivedTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.inAppNotifications,
              aliasName: $_aliasNameGenerator(
                  db.localUsers.id, db.inAppNotifications.targetUserId));

  $$InAppNotificationsTableProcessedTableManager get notificationsReceived {
    final manager = $$InAppNotificationsTableTableManager(
            $_db, $_db.inAppNotifications)
        .filter((f) => f.targetUserId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_notificationsReceivedTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$LoanNotificationsTable, List<LoanNotification>>
      _loanNotificationsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.loanNotifications,
              aliasName: $_aliasNameGenerator(
                  db.localUsers.id, db.loanNotifications.userId));

  $$LoanNotificationsTableProcessedTableManager get loanNotificationsRefs {
    final manager =
        $$LoanNotificationsTableTableManager($_db, $_db.loanNotifications)
            .filter((f) => f.userId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_loanNotificationsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$LocalUsersTableFilterComposer
    extends Composer<_$AppDatabase, $LocalUsersTable> {
  $$LocalUsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get username => $composableBuilder(
      column: $table.username, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get remoteId => $composableBuilder(
      column: $table.remoteId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get pinHash => $composableBuilder(
      column: $table.pinHash, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get pinSalt => $composableBuilder(
      column: $table.pinSalt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get pinUpdatedAt => $composableBuilder(
      column: $table.pinUpdatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDirty => $composableBuilder(
      column: $table.isDirty, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> ownedBooks(
      Expression<bool> Function($$BooksTableFilterComposer f) f) {
    final $$BooksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.books,
        getReferencedColumn: (t) => t.ownerUserId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BooksTableFilterComposer(
              $db: $db,
              $table: $db.books,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> bookReviewsRefs(
      Expression<bool> Function($$BookReviewsTableFilterComposer f) f) {
    final $$BookReviewsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.bookReviews,
        getReferencedColumn: (t) => t.authorUserId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BookReviewsTableFilterComposer(
              $db: $db,
              $table: $db.bookReviews,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> groupsRefs(
      Expression<bool> Function($$GroupsTableFilterComposer f) f) {
    final $$GroupsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.groups,
        getReferencedColumn: (t) => t.ownerUserId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GroupsTableFilterComposer(
              $db: $db,
              $table: $db.groups,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> groupMemberships(
      Expression<bool> Function($$GroupMembersTableFilterComposer f) f) {
    final $$GroupMembersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.groupMembers,
        getReferencedColumn: (t) => t.memberUserId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GroupMembersTableFilterComposer(
              $db: $db,
              $table: $db.groupMembers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> sharedBooksOwned(
      Expression<bool> Function($$SharedBooksTableFilterComposer f) f) {
    final $$SharedBooksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.sharedBooks,
        getReferencedColumn: (t) => t.ownerUserId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SharedBooksTableFilterComposer(
              $db: $db,
              $table: $db.sharedBooks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> groupInvitationsSent(
      Expression<bool> Function($$GroupInvitationsTableFilterComposer f) f) {
    final $$GroupInvitationsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.groupInvitations,
        getReferencedColumn: (t) => t.inviterUserId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GroupInvitationsTableFilterComposer(
              $db: $db,
              $table: $db.groupInvitations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> groupInvitationsAccepted(
      Expression<bool> Function($$GroupInvitationsTableFilterComposer f) f) {
    final $$GroupInvitationsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.groupInvitations,
        getReferencedColumn: (t) => t.acceptedUserId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GroupInvitationsTableFilterComposer(
              $db: $db,
              $table: $db.groupInvitations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> loansBorrower(
      Expression<bool> Function($$LoansTableFilterComposer f) f) {
    final $$LoansTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.loans,
        getReferencedColumn: (t) => t.borrowerUserId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LoansTableFilterComposer(
              $db: $db,
              $table: $db.loans,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> loansLender(
      Expression<bool> Function($$LoansTableFilterComposer f) f) {
    final $$LoansTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.loans,
        getReferencedColumn: (t) => t.lenderUserId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LoansTableFilterComposer(
              $db: $db,
              $table: $db.loans,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> notificationsAuthored(
      Expression<bool> Function($$InAppNotificationsTableFilterComposer f) f) {
    final $$InAppNotificationsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.inAppNotifications,
        getReferencedColumn: (t) => t.actorUserId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InAppNotificationsTableFilterComposer(
              $db: $db,
              $table: $db.inAppNotifications,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> notificationsReceived(
      Expression<bool> Function($$InAppNotificationsTableFilterComposer f) f) {
    final $$InAppNotificationsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.inAppNotifications,
        getReferencedColumn: (t) => t.targetUserId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InAppNotificationsTableFilterComposer(
              $db: $db,
              $table: $db.inAppNotifications,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> loanNotificationsRefs(
      Expression<bool> Function($$LoanNotificationsTableFilterComposer f) f) {
    final $$LoanNotificationsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.loanNotifications,
        getReferencedColumn: (t) => t.userId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LoanNotificationsTableFilterComposer(
              $db: $db,
              $table: $db.loanNotifications,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$LocalUsersTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalUsersTable> {
  $$LocalUsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get username => $composableBuilder(
      column: $table.username, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get remoteId => $composableBuilder(
      column: $table.remoteId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get pinHash => $composableBuilder(
      column: $table.pinHash, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get pinSalt => $composableBuilder(
      column: $table.pinSalt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get pinUpdatedAt => $composableBuilder(
      column: $table.pinUpdatedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDirty => $composableBuilder(
      column: $table.isDirty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$LocalUsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalUsersTable> {
  $$LocalUsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get pinHash =>
      $composableBuilder(column: $table.pinHash, builder: (column) => column);

  GeneratedColumn<String> get pinSalt =>
      $composableBuilder(column: $table.pinSalt, builder: (column) => column);

  GeneratedColumn<DateTime> get pinUpdatedAt => $composableBuilder(
      column: $table.pinUpdatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> ownedBooks<T extends Object>(
      Expression<T> Function($$BooksTableAnnotationComposer a) f) {
    final $$BooksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.books,
        getReferencedColumn: (t) => t.ownerUserId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BooksTableAnnotationComposer(
              $db: $db,
              $table: $db.books,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> bookReviewsRefs<T extends Object>(
      Expression<T> Function($$BookReviewsTableAnnotationComposer a) f) {
    final $$BookReviewsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.bookReviews,
        getReferencedColumn: (t) => t.authorUserId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BookReviewsTableAnnotationComposer(
              $db: $db,
              $table: $db.bookReviews,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> groupsRefs<T extends Object>(
      Expression<T> Function($$GroupsTableAnnotationComposer a) f) {
    final $$GroupsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.groups,
        getReferencedColumn: (t) => t.ownerUserId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GroupsTableAnnotationComposer(
              $db: $db,
              $table: $db.groups,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> groupMemberships<T extends Object>(
      Expression<T> Function($$GroupMembersTableAnnotationComposer a) f) {
    final $$GroupMembersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.groupMembers,
        getReferencedColumn: (t) => t.memberUserId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GroupMembersTableAnnotationComposer(
              $db: $db,
              $table: $db.groupMembers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> sharedBooksOwned<T extends Object>(
      Expression<T> Function($$SharedBooksTableAnnotationComposer a) f) {
    final $$SharedBooksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.sharedBooks,
        getReferencedColumn: (t) => t.ownerUserId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SharedBooksTableAnnotationComposer(
              $db: $db,
              $table: $db.sharedBooks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> groupInvitationsSent<T extends Object>(
      Expression<T> Function($$GroupInvitationsTableAnnotationComposer a) f) {
    final $$GroupInvitationsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.groupInvitations,
        getReferencedColumn: (t) => t.inviterUserId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GroupInvitationsTableAnnotationComposer(
              $db: $db,
              $table: $db.groupInvitations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> groupInvitationsAccepted<T extends Object>(
      Expression<T> Function($$GroupInvitationsTableAnnotationComposer a) f) {
    final $$GroupInvitationsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.groupInvitations,
        getReferencedColumn: (t) => t.acceptedUserId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GroupInvitationsTableAnnotationComposer(
              $db: $db,
              $table: $db.groupInvitations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> loansBorrower<T extends Object>(
      Expression<T> Function($$LoansTableAnnotationComposer a) f) {
    final $$LoansTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.loans,
        getReferencedColumn: (t) => t.borrowerUserId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LoansTableAnnotationComposer(
              $db: $db,
              $table: $db.loans,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> loansLender<T extends Object>(
      Expression<T> Function($$LoansTableAnnotationComposer a) f) {
    final $$LoansTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.loans,
        getReferencedColumn: (t) => t.lenderUserId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LoansTableAnnotationComposer(
              $db: $db,
              $table: $db.loans,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> notificationsAuthored<T extends Object>(
      Expression<T> Function($$InAppNotificationsTableAnnotationComposer a) f) {
    final $$InAppNotificationsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.inAppNotifications,
            getReferencedColumn: (t) => t.actorUserId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$InAppNotificationsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.inAppNotifications,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> notificationsReceived<T extends Object>(
      Expression<T> Function($$InAppNotificationsTableAnnotationComposer a) f) {
    final $$InAppNotificationsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.inAppNotifications,
            getReferencedColumn: (t) => t.targetUserId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$InAppNotificationsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.inAppNotifications,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> loanNotificationsRefs<T extends Object>(
      Expression<T> Function($$LoanNotificationsTableAnnotationComposer a) f) {
    final $$LoanNotificationsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.loanNotifications,
            getReferencedColumn: (t) => t.userId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$LoanNotificationsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.loanNotifications,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$LocalUsersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalUsersTable,
    LocalUser,
    $$LocalUsersTableFilterComposer,
    $$LocalUsersTableOrderingComposer,
    $$LocalUsersTableAnnotationComposer,
    $$LocalUsersTableCreateCompanionBuilder,
    $$LocalUsersTableUpdateCompanionBuilder,
    (LocalUser, $$LocalUsersTableReferences),
    LocalUser,
    PrefetchHooks Function(
        {bool ownedBooks,
        bool bookReviewsRefs,
        bool groupsRefs,
        bool groupMemberships,
        bool sharedBooksOwned,
        bool groupInvitationsSent,
        bool groupInvitationsAccepted,
        bool loansBorrower,
        bool loansLender,
        bool notificationsAuthored,
        bool notificationsReceived,
        bool loanNotificationsRefs})> {
  $$LocalUsersTableTableManager(_$AppDatabase db, $LocalUsersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalUsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalUsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalUsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> uuid = const Value.absent(),
            Value<String> username = const Value.absent(),
            Value<String?> remoteId = const Value.absent(),
            Value<String?> pinHash = const Value.absent(),
            Value<String?> pinSalt = const Value.absent(),
            Value<DateTime?> pinUpdatedAt = const Value.absent(),
            Value<bool> isDirty = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<DateTime?> syncedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              LocalUsersCompanion(
            id: id,
            uuid: uuid,
            username: username,
            remoteId: remoteId,
            pinHash: pinHash,
            pinSalt: pinSalt,
            pinUpdatedAt: pinUpdatedAt,
            isDirty: isDirty,
            isDeleted: isDeleted,
            syncedAt: syncedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String uuid,
            required String username,
            Value<String?> remoteId = const Value.absent(),
            Value<String?> pinHash = const Value.absent(),
            Value<String?> pinSalt = const Value.absent(),
            Value<DateTime?> pinUpdatedAt = const Value.absent(),
            Value<bool> isDirty = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<DateTime?> syncedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              LocalUsersCompanion.insert(
            id: id,
            uuid: uuid,
            username: username,
            remoteId: remoteId,
            pinHash: pinHash,
            pinSalt: pinSalt,
            pinUpdatedAt: pinUpdatedAt,
            isDirty: isDirty,
            isDeleted: isDeleted,
            syncedAt: syncedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$LocalUsersTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {ownedBooks = false,
              bookReviewsRefs = false,
              groupsRefs = false,
              groupMemberships = false,
              sharedBooksOwned = false,
              groupInvitationsSent = false,
              groupInvitationsAccepted = false,
              loansBorrower = false,
              loansLender = false,
              notificationsAuthored = false,
              notificationsReceived = false,
              loanNotificationsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (ownedBooks) db.books,
                if (bookReviewsRefs) db.bookReviews,
                if (groupsRefs) db.groups,
                if (groupMemberships) db.groupMembers,
                if (sharedBooksOwned) db.sharedBooks,
                if (groupInvitationsSent) db.groupInvitations,
                if (groupInvitationsAccepted) db.groupInvitations,
                if (loansBorrower) db.loans,
                if (loansLender) db.loans,
                if (notificationsAuthored) db.inAppNotifications,
                if (notificationsReceived) db.inAppNotifications,
                if (loanNotificationsRefs) db.loanNotifications
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (ownedBooks)
                    await $_getPrefetchedData<LocalUser, $LocalUsersTable,
                            Book>(
                        currentTable: table,
                        referencedTable:
                            $$LocalUsersTableReferences._ownedBooksTable(db),
                        managerFromTypedResult: (p0) =>
                            $$LocalUsersTableReferences(db, table, p0)
                                .ownedBooks,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.ownerUserId == item.id),
                        typedResults: items),
                  if (bookReviewsRefs)
                    await $_getPrefetchedData<LocalUser, $LocalUsersTable,
                            BookReview>(
                        currentTable: table,
                        referencedTable: $$LocalUsersTableReferences
                            ._bookReviewsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$LocalUsersTableReferences(db, table, p0)
                                .bookReviewsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.authorUserId == item.id),
                        typedResults: items),
                  if (groupsRefs)
                    await $_getPrefetchedData<LocalUser, $LocalUsersTable,
                            Group>(
                        currentTable: table,
                        referencedTable:
                            $$LocalUsersTableReferences._groupsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$LocalUsersTableReferences(db, table, p0)
                                .groupsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.ownerUserId == item.id),
                        typedResults: items),
                  if (groupMemberships)
                    await $_getPrefetchedData<LocalUser, $LocalUsersTable,
                            GroupMember>(
                        currentTable: table,
                        referencedTable: $$LocalUsersTableReferences
                            ._groupMembershipsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$LocalUsersTableReferences(db, table, p0)
                                .groupMemberships,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.memberUserId == item.id),
                        typedResults: items),
                  if (sharedBooksOwned)
                    await $_getPrefetchedData<LocalUser, $LocalUsersTable,
                            SharedBook>(
                        currentTable: table,
                        referencedTable: $$LocalUsersTableReferences
                            ._sharedBooksOwnedTable(db),
                        managerFromTypedResult: (p0) =>
                            $$LocalUsersTableReferences(db, table, p0)
                                .sharedBooksOwned,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.ownerUserId == item.id),
                        typedResults: items),
                  if (groupInvitationsSent)
                    await $_getPrefetchedData<LocalUser, $LocalUsersTable,
                            GroupInvitation>(
                        currentTable: table,
                        referencedTable: $$LocalUsersTableReferences
                            ._groupInvitationsSentTable(db),
                        managerFromTypedResult: (p0) =>
                            $$LocalUsersTableReferences(db, table, p0)
                                .groupInvitationsSent,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.inviterUserId == item.id),
                        typedResults: items),
                  if (groupInvitationsAccepted)
                    await $_getPrefetchedData<LocalUser, $LocalUsersTable,
                            GroupInvitation>(
                        currentTable: table,
                        referencedTable: $$LocalUsersTableReferences
                            ._groupInvitationsAcceptedTable(db),
                        managerFromTypedResult: (p0) =>
                            $$LocalUsersTableReferences(db, table, p0)
                                .groupInvitationsAccepted,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.acceptedUserId == item.id),
                        typedResults: items),
                  if (loansBorrower)
                    await $_getPrefetchedData<LocalUser, $LocalUsersTable,
                            Loan>(
                        currentTable: table,
                        referencedTable:
                            $$LocalUsersTableReferences._loansBorrowerTable(db),
                        managerFromTypedResult: (p0) =>
                            $$LocalUsersTableReferences(db, table, p0)
                                .loansBorrower,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.borrowerUserId == item.id),
                        typedResults: items),
                  if (loansLender)
                    await $_getPrefetchedData<LocalUser, $LocalUsersTable,
                            Loan>(
                        currentTable: table,
                        referencedTable:
                            $$LocalUsersTableReferences._loansLenderTable(db),
                        managerFromTypedResult: (p0) =>
                            $$LocalUsersTableReferences(db, table, p0)
                                .loansLender,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.lenderUserId == item.id),
                        typedResults: items),
                  if (notificationsAuthored)
                    await $_getPrefetchedData<LocalUser, $LocalUsersTable,
                            InAppNotification>(
                        currentTable: table,
                        referencedTable: $$LocalUsersTableReferences
                            ._notificationsAuthoredTable(db),
                        managerFromTypedResult: (p0) =>
                            $$LocalUsersTableReferences(db, table, p0)
                                .notificationsAuthored,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.actorUserId == item.id),
                        typedResults: items),
                  if (notificationsReceived)
                    await $_getPrefetchedData<LocalUser, $LocalUsersTable,
                            InAppNotification>(
                        currentTable: table,
                        referencedTable: $$LocalUsersTableReferences
                            ._notificationsReceivedTable(db),
                        managerFromTypedResult: (p0) =>
                            $$LocalUsersTableReferences(db, table, p0)
                                .notificationsReceived,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.targetUserId == item.id),
                        typedResults: items),
                  if (loanNotificationsRefs)
                    await $_getPrefetchedData<LocalUser, $LocalUsersTable,
                            LoanNotification>(
                        currentTable: table,
                        referencedTable: $$LocalUsersTableReferences
                            ._loanNotificationsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$LocalUsersTableReferences(db, table, p0)
                                .loanNotificationsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.userId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$LocalUsersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocalUsersTable,
    LocalUser,
    $$LocalUsersTableFilterComposer,
    $$LocalUsersTableOrderingComposer,
    $$LocalUsersTableAnnotationComposer,
    $$LocalUsersTableCreateCompanionBuilder,
    $$LocalUsersTableUpdateCompanionBuilder,
    (LocalUser, $$LocalUsersTableReferences),
    LocalUser,
    PrefetchHooks Function(
        {bool ownedBooks,
        bool bookReviewsRefs,
        bool groupsRefs,
        bool groupMemberships,
        bool sharedBooksOwned,
        bool groupInvitationsSent,
        bool groupInvitationsAccepted,
        bool loansBorrower,
        bool loansLender,
        bool notificationsAuthored,
        bool notificationsReceived,
        bool loanNotificationsRefs})>;
typedef $$BooksTableCreateCompanionBuilder = BooksCompanion Function({
  Value<int> id,
  required String uuid,
  Value<String?> remoteId,
  Value<int?> ownerUserId,
  Value<String?> ownerRemoteId,
  required String title,
  Value<String?> author,
  Value<String?> isbn,
  Value<String?> barcode,
  Value<String?> coverPath,
  Value<String> status,
  Value<String?> notes,
  Value<bool> isRead,
  Value<bool> isDirty,
  Value<bool> isDeleted,
  Value<DateTime?> syncedAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$BooksTableUpdateCompanionBuilder = BooksCompanion Function({
  Value<int> id,
  Value<String> uuid,
  Value<String?> remoteId,
  Value<int?> ownerUserId,
  Value<String?> ownerRemoteId,
  Value<String> title,
  Value<String?> author,
  Value<String?> isbn,
  Value<String?> barcode,
  Value<String?> coverPath,
  Value<String> status,
  Value<String?> notes,
  Value<bool> isRead,
  Value<bool> isDirty,
  Value<bool> isDeleted,
  Value<DateTime?> syncedAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

final class $$BooksTableReferences
    extends BaseReferences<_$AppDatabase, $BooksTable, Book> {
  $$BooksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $LocalUsersTable _ownerUserIdTable(_$AppDatabase db) =>
      db.localUsers.createAlias(
          $_aliasNameGenerator(db.books.ownerUserId, db.localUsers.id));

  $$LocalUsersTableProcessedTableManager? get ownerUserId {
    final $_column = $_itemColumn<int>('owner_user_id');
    if ($_column == null) return null;
    final manager = $$LocalUsersTableTableManager($_db, $_db.localUsers)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ownerUserIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$BookReviewsTable, List<BookReview>>
      _bookReviewsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.bookReviews,
          aliasName: $_aliasNameGenerator(db.books.id, db.bookReviews.bookId));

  $$BookReviewsTableProcessedTableManager get bookReviewsRefs {
    final manager = $$BookReviewsTableTableManager($_db, $_db.bookReviews)
        .filter((f) => f.bookId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_bookReviewsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$SharedBooksTable, List<SharedBook>>
      _sharedBooksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.sharedBooks,
          aliasName: $_aliasNameGenerator(db.books.id, db.sharedBooks.bookId));

  $$SharedBooksTableProcessedTableManager get sharedBooksRefs {
    final manager = $$SharedBooksTableTableManager($_db, $_db.sharedBooks)
        .filter((f) => f.bookId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_sharedBooksRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$LoansTable, List<Loan>> _loansRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.loans,
          aliasName: $_aliasNameGenerator(db.books.id, db.loans.bookId));

  $$LoansTableProcessedTableManager get loansRefs {
    final manager = $$LoansTableTableManager($_db, $_db.loans)
        .filter((f) => f.bookId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_loansRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$BooksTableFilterComposer extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get remoteId => $composableBuilder(
      column: $table.remoteId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ownerRemoteId => $composableBuilder(
      column: $table.ownerRemoteId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get author => $composableBuilder(
      column: $table.author, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get isbn => $composableBuilder(
      column: $table.isbn, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get barcode => $composableBuilder(
      column: $table.barcode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get coverPath => $composableBuilder(
      column: $table.coverPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isRead => $composableBuilder(
      column: $table.isRead, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDirty => $composableBuilder(
      column: $table.isDirty, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$LocalUsersTableFilterComposer get ownerUserId {
    final $$LocalUsersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ownerUserId,
        referencedTable: $db.localUsers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LocalUsersTableFilterComposer(
              $db: $db,
              $table: $db.localUsers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> bookReviewsRefs(
      Expression<bool> Function($$BookReviewsTableFilterComposer f) f) {
    final $$BookReviewsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.bookReviews,
        getReferencedColumn: (t) => t.bookId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BookReviewsTableFilterComposer(
              $db: $db,
              $table: $db.bookReviews,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> sharedBooksRefs(
      Expression<bool> Function($$SharedBooksTableFilterComposer f) f) {
    final $$SharedBooksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.sharedBooks,
        getReferencedColumn: (t) => t.bookId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SharedBooksTableFilterComposer(
              $db: $db,
              $table: $db.sharedBooks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> loansRefs(
      Expression<bool> Function($$LoansTableFilterComposer f) f) {
    final $$LoansTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.loans,
        getReferencedColumn: (t) => t.bookId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LoansTableFilterComposer(
              $db: $db,
              $table: $db.loans,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$BooksTableOrderingComposer
    extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get remoteId => $composableBuilder(
      column: $table.remoteId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ownerRemoteId => $composableBuilder(
      column: $table.ownerRemoteId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get author => $composableBuilder(
      column: $table.author, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get isbn => $composableBuilder(
      column: $table.isbn, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get barcode => $composableBuilder(
      column: $table.barcode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get coverPath => $composableBuilder(
      column: $table.coverPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isRead => $composableBuilder(
      column: $table.isRead, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDirty => $composableBuilder(
      column: $table.isDirty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$LocalUsersTableOrderingComposer get ownerUserId {
    final $$LocalUsersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ownerUserId,
        referencedTable: $db.localUsers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LocalUsersTableOrderingComposer(
              $db: $db,
              $table: $db.localUsers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BooksTableAnnotationComposer
    extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get ownerRemoteId => $composableBuilder(
      column: $table.ownerRemoteId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<String> get isbn =>
      $composableBuilder(column: $table.isbn, builder: (column) => column);

  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);

  GeneratedColumn<String> get coverPath =>
      $composableBuilder(column: $table.coverPath, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isRead =>
      $composableBuilder(column: $table.isRead, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$LocalUsersTableAnnotationComposer get ownerUserId {
    final $$LocalUsersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ownerUserId,
        referencedTable: $db.localUsers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LocalUsersTableAnnotationComposer(
              $db: $db,
              $table: $db.localUsers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> bookReviewsRefs<T extends Object>(
      Expression<T> Function($$BookReviewsTableAnnotationComposer a) f) {
    final $$BookReviewsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.bookReviews,
        getReferencedColumn: (t) => t.bookId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BookReviewsTableAnnotationComposer(
              $db: $db,
              $table: $db.bookReviews,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> sharedBooksRefs<T extends Object>(
      Expression<T> Function($$SharedBooksTableAnnotationComposer a) f) {
    final $$SharedBooksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.sharedBooks,
        getReferencedColumn: (t) => t.bookId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SharedBooksTableAnnotationComposer(
              $db: $db,
              $table: $db.sharedBooks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> loansRefs<T extends Object>(
      Expression<T> Function($$LoansTableAnnotationComposer a) f) {
    final $$LoansTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.loans,
        getReferencedColumn: (t) => t.bookId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LoansTableAnnotationComposer(
              $db: $db,
              $table: $db.loans,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$BooksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BooksTable,
    Book,
    $$BooksTableFilterComposer,
    $$BooksTableOrderingComposer,
    $$BooksTableAnnotationComposer,
    $$BooksTableCreateCompanionBuilder,
    $$BooksTableUpdateCompanionBuilder,
    (Book, $$BooksTableReferences),
    Book,
    PrefetchHooks Function(
        {bool ownerUserId,
        bool bookReviewsRefs,
        bool sharedBooksRefs,
        bool loansRefs})> {
  $$BooksTableTableManager(_$AppDatabase db, $BooksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BooksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BooksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BooksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> uuid = const Value.absent(),
            Value<String?> remoteId = const Value.absent(),
            Value<int?> ownerUserId = const Value.absent(),
            Value<String?> ownerRemoteId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> author = const Value.absent(),
            Value<String?> isbn = const Value.absent(),
            Value<String?> barcode = const Value.absent(),
            Value<String?> coverPath = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<bool> isRead = const Value.absent(),
            Value<bool> isDirty = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<DateTime?> syncedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              BooksCompanion(
            id: id,
            uuid: uuid,
            remoteId: remoteId,
            ownerUserId: ownerUserId,
            ownerRemoteId: ownerRemoteId,
            title: title,
            author: author,
            isbn: isbn,
            barcode: barcode,
            coverPath: coverPath,
            status: status,
            notes: notes,
            isRead: isRead,
            isDirty: isDirty,
            isDeleted: isDeleted,
            syncedAt: syncedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String uuid,
            Value<String?> remoteId = const Value.absent(),
            Value<int?> ownerUserId = const Value.absent(),
            Value<String?> ownerRemoteId = const Value.absent(),
            required String title,
            Value<String?> author = const Value.absent(),
            Value<String?> isbn = const Value.absent(),
            Value<String?> barcode = const Value.absent(),
            Value<String?> coverPath = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<bool> isRead = const Value.absent(),
            Value<bool> isDirty = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<DateTime?> syncedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              BooksCompanion.insert(
            id: id,
            uuid: uuid,
            remoteId: remoteId,
            ownerUserId: ownerUserId,
            ownerRemoteId: ownerRemoteId,
            title: title,
            author: author,
            isbn: isbn,
            barcode: barcode,
            coverPath: coverPath,
            status: status,
            notes: notes,
            isRead: isRead,
            isDirty: isDirty,
            isDeleted: isDeleted,
            syncedAt: syncedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$BooksTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {ownerUserId = false,
              bookReviewsRefs = false,
              sharedBooksRefs = false,
              loansRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (bookReviewsRefs) db.bookReviews,
                if (sharedBooksRefs) db.sharedBooks,
                if (loansRefs) db.loans
              ],
              addJoins: <
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
                      dynamic>>(state) {
                if (ownerUserId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.ownerUserId,
                    referencedTable:
                        $$BooksTableReferences._ownerUserIdTable(db),
                    referencedColumn:
                        $$BooksTableReferences._ownerUserIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (bookReviewsRefs)
                    await $_getPrefetchedData<Book, $BooksTable, BookReview>(
                        currentTable: table,
                        referencedTable:
                            $$BooksTableReferences._bookReviewsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$BooksTableReferences(db, table, p0)
                                .bookReviewsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.bookId == item.id),
                        typedResults: items),
                  if (sharedBooksRefs)
                    await $_getPrefetchedData<Book, $BooksTable, SharedBook>(
                        currentTable: table,
                        referencedTable:
                            $$BooksTableReferences._sharedBooksRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$BooksTableReferences(db, table, p0)
                                .sharedBooksRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.bookId == item.id),
                        typedResults: items),
                  if (loansRefs)
                    await $_getPrefetchedData<Book, $BooksTable, Loan>(
                        currentTable: table,
                        referencedTable:
                            $$BooksTableReferences._loansRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$BooksTableReferences(db, table, p0).loansRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.bookId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$BooksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BooksTable,
    Book,
    $$BooksTableFilterComposer,
    $$BooksTableOrderingComposer,
    $$BooksTableAnnotationComposer,
    $$BooksTableCreateCompanionBuilder,
    $$BooksTableUpdateCompanionBuilder,
    (Book, $$BooksTableReferences),
    Book,
    PrefetchHooks Function(
        {bool ownerUserId,
        bool bookReviewsRefs,
        bool sharedBooksRefs,
        bool loansRefs})>;
typedef $$BookReviewsTableCreateCompanionBuilder = BookReviewsCompanion
    Function({
  Value<int> id,
  required String uuid,
  Value<String?> remoteId,
  required int bookId,
  required String bookUuid,
  required int authorUserId,
  Value<String?> authorRemoteId,
  required int rating,
  Value<String?> review,
  Value<bool> isDirty,
  Value<bool> isDeleted,
  Value<DateTime?> syncedAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$BookReviewsTableUpdateCompanionBuilder = BookReviewsCompanion
    Function({
  Value<int> id,
  Value<String> uuid,
  Value<String?> remoteId,
  Value<int> bookId,
  Value<String> bookUuid,
  Value<int> authorUserId,
  Value<String?> authorRemoteId,
  Value<int> rating,
  Value<String?> review,
  Value<bool> isDirty,
  Value<bool> isDeleted,
  Value<DateTime?> syncedAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

final class $$BookReviewsTableReferences
    extends BaseReferences<_$AppDatabase, $BookReviewsTable, BookReview> {
  $$BookReviewsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BooksTable _bookIdTable(_$AppDatabase db) => db.books
      .createAlias($_aliasNameGenerator(db.bookReviews.bookId, db.books.id));

  $$BooksTableProcessedTableManager get bookId {
    final $_column = $_itemColumn<int>('book_id')!;

    final manager = $$BooksTableTableManager($_db, $_db.books)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $LocalUsersTable _authorUserIdTable(_$AppDatabase db) =>
      db.localUsers.createAlias(
          $_aliasNameGenerator(db.bookReviews.authorUserId, db.localUsers.id));

  $$LocalUsersTableProcessedTableManager get authorUserId {
    final $_column = $_itemColumn<int>('author_user_id')!;

    final manager = $$LocalUsersTableTableManager($_db, $_db.localUsers)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_authorUserIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$BookReviewsTableFilterComposer
    extends Composer<_$AppDatabase, $BookReviewsTable> {
  $$BookReviewsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get remoteId => $composableBuilder(
      column: $table.remoteId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bookUuid => $composableBuilder(
      column: $table.bookUuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get authorRemoteId => $composableBuilder(
      column: $table.authorRemoteId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get rating => $composableBuilder(
      column: $table.rating, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get review => $composableBuilder(
      column: $table.review, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDirty => $composableBuilder(
      column: $table.isDirty, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$BooksTableFilterComposer get bookId {
    final $$BooksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.bookId,
        referencedTable: $db.books,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BooksTableFilterComposer(
              $db: $db,
              $table: $db.books,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$LocalUsersTableFilterComposer get authorUserId {
    final $$LocalUsersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.authorUserId,
        referencedTable: $db.localUsers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LocalUsersTableFilterComposer(
              $db: $db,
              $table: $db.localUsers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BookReviewsTableOrderingComposer
    extends Composer<_$AppDatabase, $BookReviewsTable> {
  $$BookReviewsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get remoteId => $composableBuilder(
      column: $table.remoteId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bookUuid => $composableBuilder(
      column: $table.bookUuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get authorRemoteId => $composableBuilder(
      column: $table.authorRemoteId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get rating => $composableBuilder(
      column: $table.rating, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get review => $composableBuilder(
      column: $table.review, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDirty => $composableBuilder(
      column: $table.isDirty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$BooksTableOrderingComposer get bookId {
    final $$BooksTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.bookId,
        referencedTable: $db.books,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BooksTableOrderingComposer(
              $db: $db,
              $table: $db.books,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$LocalUsersTableOrderingComposer get authorUserId {
    final $$LocalUsersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.authorUserId,
        referencedTable: $db.localUsers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LocalUsersTableOrderingComposer(
              $db: $db,
              $table: $db.localUsers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BookReviewsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookReviewsTable> {
  $$BookReviewsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get bookUuid =>
      $composableBuilder(column: $table.bookUuid, builder: (column) => column);

  GeneratedColumn<String> get authorRemoteId => $composableBuilder(
      column: $table.authorRemoteId, builder: (column) => column);

  GeneratedColumn<int> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<String> get review =>
      $composableBuilder(column: $table.review, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$BooksTableAnnotationComposer get bookId {
    final $$BooksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.bookId,
        referencedTable: $db.books,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BooksTableAnnotationComposer(
              $db: $db,
              $table: $db.books,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$LocalUsersTableAnnotationComposer get authorUserId {
    final $$LocalUsersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.authorUserId,
        referencedTable: $db.localUsers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LocalUsersTableAnnotationComposer(
              $db: $db,
              $table: $db.localUsers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BookReviewsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BookReviewsTable,
    BookReview,
    $$BookReviewsTableFilterComposer,
    $$BookReviewsTableOrderingComposer,
    $$BookReviewsTableAnnotationComposer,
    $$BookReviewsTableCreateCompanionBuilder,
    $$BookReviewsTableUpdateCompanionBuilder,
    (BookReview, $$BookReviewsTableReferences),
    BookReview,
    PrefetchHooks Function({bool bookId, bool authorUserId})> {
  $$BookReviewsTableTableManager(_$AppDatabase db, $BookReviewsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookReviewsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookReviewsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookReviewsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> uuid = const Value.absent(),
            Value<String?> remoteId = const Value.absent(),
            Value<int> bookId = const Value.absent(),
            Value<String> bookUuid = const Value.absent(),
            Value<int> authorUserId = const Value.absent(),
            Value<String?> authorRemoteId = const Value.absent(),
            Value<int> rating = const Value.absent(),
            Value<String?> review = const Value.absent(),
            Value<bool> isDirty = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<DateTime?> syncedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              BookReviewsCompanion(
            id: id,
            uuid: uuid,
            remoteId: remoteId,
            bookId: bookId,
            bookUuid: bookUuid,
            authorUserId: authorUserId,
            authorRemoteId: authorRemoteId,
            rating: rating,
            review: review,
            isDirty: isDirty,
            isDeleted: isDeleted,
            syncedAt: syncedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String uuid,
            Value<String?> remoteId = const Value.absent(),
            required int bookId,
            required String bookUuid,
            required int authorUserId,
            Value<String?> authorRemoteId = const Value.absent(),
            required int rating,
            Value<String?> review = const Value.absent(),
            Value<bool> isDirty = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<DateTime?> syncedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              BookReviewsCompanion.insert(
            id: id,
            uuid: uuid,
            remoteId: remoteId,
            bookId: bookId,
            bookUuid: bookUuid,
            authorUserId: authorUserId,
            authorRemoteId: authorRemoteId,
            rating: rating,
            review: review,
            isDirty: isDirty,
            isDeleted: isDeleted,
            syncedAt: syncedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$BookReviewsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({bookId = false, authorUserId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (bookId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.bookId,
                    referencedTable:
                        $$BookReviewsTableReferences._bookIdTable(db),
                    referencedColumn:
                        $$BookReviewsTableReferences._bookIdTable(db).id,
                  ) as T;
                }
                if (authorUserId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.authorUserId,
                    referencedTable:
                        $$BookReviewsTableReferences._authorUserIdTable(db),
                    referencedColumn:
                        $$BookReviewsTableReferences._authorUserIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$BookReviewsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BookReviewsTable,
    BookReview,
    $$BookReviewsTableFilterComposer,
    $$BookReviewsTableOrderingComposer,
    $$BookReviewsTableAnnotationComposer,
    $$BookReviewsTableCreateCompanionBuilder,
    $$BookReviewsTableUpdateCompanionBuilder,
    (BookReview, $$BookReviewsTableReferences),
    BookReview,
    PrefetchHooks Function({bool bookId, bool authorUserId})>;
typedef $$GroupsTableCreateCompanionBuilder = GroupsCompanion Function({
  Value<int> id,
  required String uuid,
  Value<String?> remoteId,
  required String name,
  Value<String?> description,
  Value<int?> ownerUserId,
  Value<String?> ownerRemoteId,
  Value<bool> isDirty,
  Value<bool> isDeleted,
  Value<DateTime?> syncedAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$GroupsTableUpdateCompanionBuilder = GroupsCompanion Function({
  Value<int> id,
  Value<String> uuid,
  Value<String?> remoteId,
  Value<String> name,
  Value<String?> description,
  Value<int?> ownerUserId,
  Value<String?> ownerRemoteId,
  Value<bool> isDirty,
  Value<bool> isDeleted,
  Value<DateTime?> syncedAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

final class $$GroupsTableReferences
    extends BaseReferences<_$AppDatabase, $GroupsTable, Group> {
  $$GroupsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $LocalUsersTable _ownerUserIdTable(_$AppDatabase db) =>
      db.localUsers.createAlias(
          $_aliasNameGenerator(db.groups.ownerUserId, db.localUsers.id));

  $$LocalUsersTableProcessedTableManager? get ownerUserId {
    final $_column = $_itemColumn<int>('owner_user_id');
    if ($_column == null) return null;
    final manager = $$LocalUsersTableTableManager($_db, $_db.localUsers)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ownerUserIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$GroupMembersTable, List<GroupMember>>
      _groupMembersRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.groupMembers,
              aliasName:
                  $_aliasNameGenerator(db.groups.id, db.groupMembers.groupId));

  $$GroupMembersTableProcessedTableManager get groupMembersRefs {
    final manager = $$GroupMembersTableTableManager($_db, $_db.groupMembers)
        .filter((f) => f.groupId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_groupMembersRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$SharedBooksTable, List<SharedBook>>
      _sharedBooksRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.sharedBooks,
              aliasName:
                  $_aliasNameGenerator(db.groups.id, db.sharedBooks.groupId));

  $$SharedBooksTableProcessedTableManager get sharedBooksRefs {
    final manager = $$SharedBooksTableTableManager($_db, $_db.sharedBooks)
        .filter((f) => f.groupId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_sharedBooksRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$GroupInvitationsTable, List<GroupInvitation>>
      _groupInvitationsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.groupInvitations,
              aliasName: $_aliasNameGenerator(
                  db.groups.id, db.groupInvitations.groupId));

  $$GroupInvitationsTableProcessedTableManager get groupInvitationsRefs {
    final manager =
        $$GroupInvitationsTableTableManager($_db, $_db.groupInvitations)
            .filter((f) => f.groupId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_groupInvitationsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$GroupsTableFilterComposer
    extends Composer<_$AppDatabase, $GroupsTable> {
  $$GroupsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get remoteId => $composableBuilder(
      column: $table.remoteId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ownerRemoteId => $composableBuilder(
      column: $table.ownerRemoteId, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDirty => $composableBuilder(
      column: $table.isDirty, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$LocalUsersTableFilterComposer get ownerUserId {
    final $$LocalUsersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ownerUserId,
        referencedTable: $db.localUsers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LocalUsersTableFilterComposer(
              $db: $db,
              $table: $db.localUsers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> groupMembersRefs(
      Expression<bool> Function($$GroupMembersTableFilterComposer f) f) {
    final $$GroupMembersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.groupMembers,
        getReferencedColumn: (t) => t.groupId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GroupMembersTableFilterComposer(
              $db: $db,
              $table: $db.groupMembers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> sharedBooksRefs(
      Expression<bool> Function($$SharedBooksTableFilterComposer f) f) {
    final $$SharedBooksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.sharedBooks,
        getReferencedColumn: (t) => t.groupId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SharedBooksTableFilterComposer(
              $db: $db,
              $table: $db.sharedBooks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> groupInvitationsRefs(
      Expression<bool> Function($$GroupInvitationsTableFilterComposer f) f) {
    final $$GroupInvitationsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.groupInvitations,
        getReferencedColumn: (t) => t.groupId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GroupInvitationsTableFilterComposer(
              $db: $db,
              $table: $db.groupInvitations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$GroupsTableOrderingComposer
    extends Composer<_$AppDatabase, $GroupsTable> {
  $$GroupsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get remoteId => $composableBuilder(
      column: $table.remoteId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ownerRemoteId => $composableBuilder(
      column: $table.ownerRemoteId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDirty => $composableBuilder(
      column: $table.isDirty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$LocalUsersTableOrderingComposer get ownerUserId {
    final $$LocalUsersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ownerUserId,
        referencedTable: $db.localUsers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LocalUsersTableOrderingComposer(
              $db: $db,
              $table: $db.localUsers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$GroupsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GroupsTable> {
  $$GroupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get ownerRemoteId => $composableBuilder(
      column: $table.ownerRemoteId, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$LocalUsersTableAnnotationComposer get ownerUserId {
    final $$LocalUsersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ownerUserId,
        referencedTable: $db.localUsers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LocalUsersTableAnnotationComposer(
              $db: $db,
              $table: $db.localUsers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> groupMembersRefs<T extends Object>(
      Expression<T> Function($$GroupMembersTableAnnotationComposer a) f) {
    final $$GroupMembersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.groupMembers,
        getReferencedColumn: (t) => t.groupId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GroupMembersTableAnnotationComposer(
              $db: $db,
              $table: $db.groupMembers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> sharedBooksRefs<T extends Object>(
      Expression<T> Function($$SharedBooksTableAnnotationComposer a) f) {
    final $$SharedBooksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.sharedBooks,
        getReferencedColumn: (t) => t.groupId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SharedBooksTableAnnotationComposer(
              $db: $db,
              $table: $db.sharedBooks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> groupInvitationsRefs<T extends Object>(
      Expression<T> Function($$GroupInvitationsTableAnnotationComposer a) f) {
    final $$GroupInvitationsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.groupInvitations,
        getReferencedColumn: (t) => t.groupId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GroupInvitationsTableAnnotationComposer(
              $db: $db,
              $table: $db.groupInvitations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$GroupsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GroupsTable,
    Group,
    $$GroupsTableFilterComposer,
    $$GroupsTableOrderingComposer,
    $$GroupsTableAnnotationComposer,
    $$GroupsTableCreateCompanionBuilder,
    $$GroupsTableUpdateCompanionBuilder,
    (Group, $$GroupsTableReferences),
    Group,
    PrefetchHooks Function(
        {bool ownerUserId,
        bool groupMembersRefs,
        bool sharedBooksRefs,
        bool groupInvitationsRefs})> {
  $$GroupsTableTableManager(_$AppDatabase db, $GroupsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GroupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GroupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GroupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> uuid = const Value.absent(),
            Value<String?> remoteId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<int?> ownerUserId = const Value.absent(),
            Value<String?> ownerRemoteId = const Value.absent(),
            Value<bool> isDirty = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<DateTime?> syncedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              GroupsCompanion(
            id: id,
            uuid: uuid,
            remoteId: remoteId,
            name: name,
            description: description,
            ownerUserId: ownerUserId,
            ownerRemoteId: ownerRemoteId,
            isDirty: isDirty,
            isDeleted: isDeleted,
            syncedAt: syncedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String uuid,
            Value<String?> remoteId = const Value.absent(),
            required String name,
            Value<String?> description = const Value.absent(),
            Value<int?> ownerUserId = const Value.absent(),
            Value<String?> ownerRemoteId = const Value.absent(),
            Value<bool> isDirty = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<DateTime?> syncedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              GroupsCompanion.insert(
            id: id,
            uuid: uuid,
            remoteId: remoteId,
            name: name,
            description: description,
            ownerUserId: ownerUserId,
            ownerRemoteId: ownerRemoteId,
            isDirty: isDirty,
            isDeleted: isDeleted,
            syncedAt: syncedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$GroupsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {ownerUserId = false,
              groupMembersRefs = false,
              sharedBooksRefs = false,
              groupInvitationsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (groupMembersRefs) db.groupMembers,
                if (sharedBooksRefs) db.sharedBooks,
                if (groupInvitationsRefs) db.groupInvitations
              ],
              addJoins: <
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
                      dynamic>>(state) {
                if (ownerUserId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.ownerUserId,
                    referencedTable:
                        $$GroupsTableReferences._ownerUserIdTable(db),
                    referencedColumn:
                        $$GroupsTableReferences._ownerUserIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (groupMembersRefs)
                    await $_getPrefetchedData<Group, $GroupsTable, GroupMember>(
                        currentTable: table,
                        referencedTable:
                            $$GroupsTableReferences._groupMembersRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$GroupsTableReferences(db, table, p0)
                                .groupMembersRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.groupId == item.id),
                        typedResults: items),
                  if (sharedBooksRefs)
                    await $_getPrefetchedData<Group, $GroupsTable, SharedBook>(
                        currentTable: table,
                        referencedTable:
                            $$GroupsTableReferences._sharedBooksRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$GroupsTableReferences(db, table, p0)
                                .sharedBooksRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.groupId == item.id),
                        typedResults: items),
                  if (groupInvitationsRefs)
                    await $_getPrefetchedData<Group, $GroupsTable,
                            GroupInvitation>(
                        currentTable: table,
                        referencedTable: $$GroupsTableReferences
                            ._groupInvitationsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$GroupsTableReferences(db, table, p0)
                                .groupInvitationsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.groupId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$GroupsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $GroupsTable,
    Group,
    $$GroupsTableFilterComposer,
    $$GroupsTableOrderingComposer,
    $$GroupsTableAnnotationComposer,
    $$GroupsTableCreateCompanionBuilder,
    $$GroupsTableUpdateCompanionBuilder,
    (Group, $$GroupsTableReferences),
    Group,
    PrefetchHooks Function(
        {bool ownerUserId,
        bool groupMembersRefs,
        bool sharedBooksRefs,
        bool groupInvitationsRefs})>;
typedef $$GroupMembersTableCreateCompanionBuilder = GroupMembersCompanion
    Function({
  Value<int> id,
  required String uuid,
  Value<String?> remoteId,
  required int groupId,
  required String groupUuid,
  required int memberUserId,
  Value<String?> memberRemoteId,
  Value<String> role,
  Value<bool> isDirty,
  Value<bool> isDeleted,
  Value<DateTime?> syncedAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$GroupMembersTableUpdateCompanionBuilder = GroupMembersCompanion
    Function({
  Value<int> id,
  Value<String> uuid,
  Value<String?> remoteId,
  Value<int> groupId,
  Value<String> groupUuid,
  Value<int> memberUserId,
  Value<String?> memberRemoteId,
  Value<String> role,
  Value<bool> isDirty,
  Value<bool> isDeleted,
  Value<DateTime?> syncedAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

final class $$GroupMembersTableReferences
    extends BaseReferences<_$AppDatabase, $GroupMembersTable, GroupMember> {
  $$GroupMembersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GroupsTable _groupIdTable(_$AppDatabase db) => db.groups
      .createAlias($_aliasNameGenerator(db.groupMembers.groupId, db.groups.id));

  $$GroupsTableProcessedTableManager get groupId {
    final $_column = $_itemColumn<int>('group_id')!;

    final manager = $$GroupsTableTableManager($_db, $_db.groups)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_groupIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $LocalUsersTable _memberUserIdTable(_$AppDatabase db) =>
      db.localUsers.createAlias(
          $_aliasNameGenerator(db.groupMembers.memberUserId, db.localUsers.id));

  $$LocalUsersTableProcessedTableManager get memberUserId {
    final $_column = $_itemColumn<int>('member_user_id')!;

    final manager = $$LocalUsersTableTableManager($_db, $_db.localUsers)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_memberUserIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$GroupMembersTableFilterComposer
    extends Composer<_$AppDatabase, $GroupMembersTable> {
  $$GroupMembersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get remoteId => $composableBuilder(
      column: $table.remoteId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get groupUuid => $composableBuilder(
      column: $table.groupUuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get memberRemoteId => $composableBuilder(
      column: $table.memberRemoteId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDirty => $composableBuilder(
      column: $table.isDirty, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$GroupsTableFilterComposer get groupId {
    final $$GroupsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.groupId,
        referencedTable: $db.groups,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GroupsTableFilterComposer(
              $db: $db,
              $table: $db.groups,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$LocalUsersTableFilterComposer get memberUserId {
    final $$LocalUsersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.memberUserId,
        referencedTable: $db.localUsers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LocalUsersTableFilterComposer(
              $db: $db,
              $table: $db.localUsers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$GroupMembersTableOrderingComposer
    extends Composer<_$AppDatabase, $GroupMembersTable> {
  $$GroupMembersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get remoteId => $composableBuilder(
      column: $table.remoteId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get groupUuid => $composableBuilder(
      column: $table.groupUuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get memberRemoteId => $composableBuilder(
      column: $table.memberRemoteId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDirty => $composableBuilder(
      column: $table.isDirty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$GroupsTableOrderingComposer get groupId {
    final $$GroupsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.groupId,
        referencedTable: $db.groups,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GroupsTableOrderingComposer(
              $db: $db,
              $table: $db.groups,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$LocalUsersTableOrderingComposer get memberUserId {
    final $$LocalUsersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.memberUserId,
        referencedTable: $db.localUsers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LocalUsersTableOrderingComposer(
              $db: $db,
              $table: $db.localUsers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$GroupMembersTableAnnotationComposer
    extends Composer<_$AppDatabase, $GroupMembersTable> {
  $$GroupMembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get groupUuid =>
      $composableBuilder(column: $table.groupUuid, builder: (column) => column);

  GeneratedColumn<String> get memberRemoteId => $composableBuilder(
      column: $table.memberRemoteId, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$GroupsTableAnnotationComposer get groupId {
    final $$GroupsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.groupId,
        referencedTable: $db.groups,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GroupsTableAnnotationComposer(
              $db: $db,
              $table: $db.groups,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$LocalUsersTableAnnotationComposer get memberUserId {
    final $$LocalUsersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.memberUserId,
        referencedTable: $db.localUsers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LocalUsersTableAnnotationComposer(
              $db: $db,
              $table: $db.localUsers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$GroupMembersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GroupMembersTable,
    GroupMember,
    $$GroupMembersTableFilterComposer,
    $$GroupMembersTableOrderingComposer,
    $$GroupMembersTableAnnotationComposer,
    $$GroupMembersTableCreateCompanionBuilder,
    $$GroupMembersTableUpdateCompanionBuilder,
    (GroupMember, $$GroupMembersTableReferences),
    GroupMember,
    PrefetchHooks Function({bool groupId, bool memberUserId})> {
  $$GroupMembersTableTableManager(_$AppDatabase db, $GroupMembersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GroupMembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GroupMembersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GroupMembersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> uuid = const Value.absent(),
            Value<String?> remoteId = const Value.absent(),
            Value<int> groupId = const Value.absent(),
            Value<String> groupUuid = const Value.absent(),
            Value<int> memberUserId = const Value.absent(),
            Value<String?> memberRemoteId = const Value.absent(),
            Value<String> role = const Value.absent(),
            Value<bool> isDirty = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<DateTime?> syncedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              GroupMembersCompanion(
            id: id,
            uuid: uuid,
            remoteId: remoteId,
            groupId: groupId,
            groupUuid: groupUuid,
            memberUserId: memberUserId,
            memberRemoteId: memberRemoteId,
            role: role,
            isDirty: isDirty,
            isDeleted: isDeleted,
            syncedAt: syncedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String uuid,
            Value<String?> remoteId = const Value.absent(),
            required int groupId,
            required String groupUuid,
            required int memberUserId,
            Value<String?> memberRemoteId = const Value.absent(),
            Value<String> role = const Value.absent(),
            Value<bool> isDirty = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<DateTime?> syncedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              GroupMembersCompanion.insert(
            id: id,
            uuid: uuid,
            remoteId: remoteId,
            groupId: groupId,
            groupUuid: groupUuid,
            memberUserId: memberUserId,
            memberRemoteId: memberRemoteId,
            role: role,
            isDirty: isDirty,
            isDeleted: isDeleted,
            syncedAt: syncedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$GroupMembersTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({groupId = false, memberUserId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (groupId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.groupId,
                    referencedTable:
                        $$GroupMembersTableReferences._groupIdTable(db),
                    referencedColumn:
                        $$GroupMembersTableReferences._groupIdTable(db).id,
                  ) as T;
                }
                if (memberUserId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.memberUserId,
                    referencedTable:
                        $$GroupMembersTableReferences._memberUserIdTable(db),
                    referencedColumn:
                        $$GroupMembersTableReferences._memberUserIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$GroupMembersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $GroupMembersTable,
    GroupMember,
    $$GroupMembersTableFilterComposer,
    $$GroupMembersTableOrderingComposer,
    $$GroupMembersTableAnnotationComposer,
    $$GroupMembersTableCreateCompanionBuilder,
    $$GroupMembersTableUpdateCompanionBuilder,
    (GroupMember, $$GroupMembersTableReferences),
    GroupMember,
    PrefetchHooks Function({bool groupId, bool memberUserId})>;
typedef $$SharedBooksTableCreateCompanionBuilder = SharedBooksCompanion
    Function({
  Value<int> id,
  required String uuid,
  Value<String?> remoteId,
  required int groupId,
  required String groupUuid,
  required int bookId,
  required String bookUuid,
  required int ownerUserId,
  Value<String?> ownerRemoteId,
  Value<String> visibility,
  Value<bool> isAvailable,
  Value<bool> isDirty,
  Value<bool> isDeleted,
  Value<DateTime?> syncedAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$SharedBooksTableUpdateCompanionBuilder = SharedBooksCompanion
    Function({
  Value<int> id,
  Value<String> uuid,
  Value<String?> remoteId,
  Value<int> groupId,
  Value<String> groupUuid,
  Value<int> bookId,
  Value<String> bookUuid,
  Value<int> ownerUserId,
  Value<String?> ownerRemoteId,
  Value<String> visibility,
  Value<bool> isAvailable,
  Value<bool> isDirty,
  Value<bool> isDeleted,
  Value<DateTime?> syncedAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

final class $$SharedBooksTableReferences
    extends BaseReferences<_$AppDatabase, $SharedBooksTable, SharedBook> {
  $$SharedBooksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GroupsTable _groupIdTable(_$AppDatabase db) => db.groups
      .createAlias($_aliasNameGenerator(db.sharedBooks.groupId, db.groups.id));

  $$GroupsTableProcessedTableManager get groupId {
    final $_column = $_itemColumn<int>('group_id')!;

    final manager = $$GroupsTableTableManager($_db, $_db.groups)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_groupIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $BooksTable _bookIdTable(_$AppDatabase db) => db.books
      .createAlias($_aliasNameGenerator(db.sharedBooks.bookId, db.books.id));

  $$BooksTableProcessedTableManager get bookId {
    final $_column = $_itemColumn<int>('book_id')!;

    final manager = $$BooksTableTableManager($_db, $_db.books)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $LocalUsersTable _ownerUserIdTable(_$AppDatabase db) =>
      db.localUsers.createAlias(
          $_aliasNameGenerator(db.sharedBooks.ownerUserId, db.localUsers.id));

  $$LocalUsersTableProcessedTableManager get ownerUserId {
    final $_column = $_itemColumn<int>('owner_user_id')!;

    final manager = $$LocalUsersTableTableManager($_db, $_db.localUsers)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ownerUserIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$LoansTable, List<Loan>> _loansRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.loans,
          aliasName:
              $_aliasNameGenerator(db.sharedBooks.id, db.loans.sharedBookId));

  $$LoansTableProcessedTableManager get loansRefs {
    final manager = $$LoansTableTableManager($_db, $_db.loans)
        .filter((f) => f.sharedBookId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_loansRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$InAppNotificationsTable, List<InAppNotification>>
      _notificationSharedBooksTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.inAppNotifications,
              aliasName: $_aliasNameGenerator(
                  db.sharedBooks.id, db.inAppNotifications.sharedBookId));

  $$InAppNotificationsTableProcessedTableManager get notificationSharedBooks {
    final manager = $$InAppNotificationsTableTableManager(
            $_db, $_db.inAppNotifications)
        .filter((f) => f.sharedBookId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_notificationSharedBooksTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$SharedBooksTableFilterComposer
    extends Composer<_$AppDatabase, $SharedBooksTable> {
  $$SharedBooksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get remoteId => $composableBuilder(
      column: $table.remoteId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get groupUuid => $composableBuilder(
      column: $table.groupUuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bookUuid => $composableBuilder(
      column: $table.bookUuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ownerRemoteId => $composableBuilder(
      column: $table.ownerRemoteId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get visibility => $composableBuilder(
      column: $table.visibility, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isAvailable => $composableBuilder(
      column: $table.isAvailable, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDirty => $composableBuilder(
      column: $table.isDirty, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$GroupsTableFilterComposer get groupId {
    final $$GroupsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.groupId,
        referencedTable: $db.groups,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GroupsTableFilterComposer(
              $db: $db,
              $table: $db.groups,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$BooksTableFilterComposer get bookId {
    final $$BooksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.bookId,
        referencedTable: $db.books,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BooksTableFilterComposer(
              $db: $db,
              $table: $db.books,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$LocalUsersTableFilterComposer get ownerUserId {
    final $$LocalUsersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ownerUserId,
        referencedTable: $db.localUsers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LocalUsersTableFilterComposer(
              $db: $db,
              $table: $db.localUsers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> loansRefs(
      Expression<bool> Function($$LoansTableFilterComposer f) f) {
    final $$LoansTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.loans,
        getReferencedColumn: (t) => t.sharedBookId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LoansTableFilterComposer(
              $db: $db,
              $table: $db.loans,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> notificationSharedBooks(
      Expression<bool> Function($$InAppNotificationsTableFilterComposer f) f) {
    final $$InAppNotificationsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.inAppNotifications,
        getReferencedColumn: (t) => t.sharedBookId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InAppNotificationsTableFilterComposer(
              $db: $db,
              $table: $db.inAppNotifications,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SharedBooksTableOrderingComposer
    extends Composer<_$AppDatabase, $SharedBooksTable> {
  $$SharedBooksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get remoteId => $composableBuilder(
      column: $table.remoteId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get groupUuid => $composableBuilder(
      column: $table.groupUuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bookUuid => $composableBuilder(
      column: $table.bookUuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ownerRemoteId => $composableBuilder(
      column: $table.ownerRemoteId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get visibility => $composableBuilder(
      column: $table.visibility, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isAvailable => $composableBuilder(
      column: $table.isAvailable, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDirty => $composableBuilder(
      column: $table.isDirty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$GroupsTableOrderingComposer get groupId {
    final $$GroupsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.groupId,
        referencedTable: $db.groups,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GroupsTableOrderingComposer(
              $db: $db,
              $table: $db.groups,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$BooksTableOrderingComposer get bookId {
    final $$BooksTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.bookId,
        referencedTable: $db.books,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BooksTableOrderingComposer(
              $db: $db,
              $table: $db.books,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$LocalUsersTableOrderingComposer get ownerUserId {
    final $$LocalUsersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ownerUserId,
        referencedTable: $db.localUsers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LocalUsersTableOrderingComposer(
              $db: $db,
              $table: $db.localUsers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SharedBooksTableAnnotationComposer
    extends Composer<_$AppDatabase, $SharedBooksTable> {
  $$SharedBooksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get groupUuid =>
      $composableBuilder(column: $table.groupUuid, builder: (column) => column);

  GeneratedColumn<String> get bookUuid =>
      $composableBuilder(column: $table.bookUuid, builder: (column) => column);

  GeneratedColumn<String> get ownerRemoteId => $composableBuilder(
      column: $table.ownerRemoteId, builder: (column) => column);

  GeneratedColumn<String> get visibility => $composableBuilder(
      column: $table.visibility, builder: (column) => column);

  GeneratedColumn<bool> get isAvailable => $composableBuilder(
      column: $table.isAvailable, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$GroupsTableAnnotationComposer get groupId {
    final $$GroupsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.groupId,
        referencedTable: $db.groups,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GroupsTableAnnotationComposer(
              $db: $db,
              $table: $db.groups,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$BooksTableAnnotationComposer get bookId {
    final $$BooksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.bookId,
        referencedTable: $db.books,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BooksTableAnnotationComposer(
              $db: $db,
              $table: $db.books,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$LocalUsersTableAnnotationComposer get ownerUserId {
    final $$LocalUsersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ownerUserId,
        referencedTable: $db.localUsers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LocalUsersTableAnnotationComposer(
              $db: $db,
              $table: $db.localUsers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> loansRefs<T extends Object>(
      Expression<T> Function($$LoansTableAnnotationComposer a) f) {
    final $$LoansTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.loans,
        getReferencedColumn: (t) => t.sharedBookId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LoansTableAnnotationComposer(
              $db: $db,
              $table: $db.loans,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> notificationSharedBooks<T extends Object>(
      Expression<T> Function($$InAppNotificationsTableAnnotationComposer a) f) {
    final $$InAppNotificationsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.inAppNotifications,
            getReferencedColumn: (t) => t.sharedBookId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$InAppNotificationsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.inAppNotifications,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$SharedBooksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SharedBooksTable,
    SharedBook,
    $$SharedBooksTableFilterComposer,
    $$SharedBooksTableOrderingComposer,
    $$SharedBooksTableAnnotationComposer,
    $$SharedBooksTableCreateCompanionBuilder,
    $$SharedBooksTableUpdateCompanionBuilder,
    (SharedBook, $$SharedBooksTableReferences),
    SharedBook,
    PrefetchHooks Function(
        {bool groupId,
        bool bookId,
        bool ownerUserId,
        bool loansRefs,
        bool notificationSharedBooks})> {
  $$SharedBooksTableTableManager(_$AppDatabase db, $SharedBooksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SharedBooksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SharedBooksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SharedBooksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> uuid = const Value.absent(),
            Value<String?> remoteId = const Value.absent(),
            Value<int> groupId = const Value.absent(),
            Value<String> groupUuid = const Value.absent(),
            Value<int> bookId = const Value.absent(),
            Value<String> bookUuid = const Value.absent(),
            Value<int> ownerUserId = const Value.absent(),
            Value<String?> ownerRemoteId = const Value.absent(),
            Value<String> visibility = const Value.absent(),
            Value<bool> isAvailable = const Value.absent(),
            Value<bool> isDirty = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<DateTime?> syncedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              SharedBooksCompanion(
            id: id,
            uuid: uuid,
            remoteId: remoteId,
            groupId: groupId,
            groupUuid: groupUuid,
            bookId: bookId,
            bookUuid: bookUuid,
            ownerUserId: ownerUserId,
            ownerRemoteId: ownerRemoteId,
            visibility: visibility,
            isAvailable: isAvailable,
            isDirty: isDirty,
            isDeleted: isDeleted,
            syncedAt: syncedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String uuid,
            Value<String?> remoteId = const Value.absent(),
            required int groupId,
            required String groupUuid,
            required int bookId,
            required String bookUuid,
            required int ownerUserId,
            Value<String?> ownerRemoteId = const Value.absent(),
            Value<String> visibility = const Value.absent(),
            Value<bool> isAvailable = const Value.absent(),
            Value<bool> isDirty = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<DateTime?> syncedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              SharedBooksCompanion.insert(
            id: id,
            uuid: uuid,
            remoteId: remoteId,
            groupId: groupId,
            groupUuid: groupUuid,
            bookId: bookId,
            bookUuid: bookUuid,
            ownerUserId: ownerUserId,
            ownerRemoteId: ownerRemoteId,
            visibility: visibility,
            isAvailable: isAvailable,
            isDirty: isDirty,
            isDeleted: isDeleted,
            syncedAt: syncedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$SharedBooksTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {groupId = false,
              bookId = false,
              ownerUserId = false,
              loansRefs = false,
              notificationSharedBooks = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (loansRefs) db.loans,
                if (notificationSharedBooks) db.inAppNotifications
              ],
              addJoins: <
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
                      dynamic>>(state) {
                if (groupId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.groupId,
                    referencedTable:
                        $$SharedBooksTableReferences._groupIdTable(db),
                    referencedColumn:
                        $$SharedBooksTableReferences._groupIdTable(db).id,
                  ) as T;
                }
                if (bookId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.bookId,
                    referencedTable:
                        $$SharedBooksTableReferences._bookIdTable(db),
                    referencedColumn:
                        $$SharedBooksTableReferences._bookIdTable(db).id,
                  ) as T;
                }
                if (ownerUserId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.ownerUserId,
                    referencedTable:
                        $$SharedBooksTableReferences._ownerUserIdTable(db),
                    referencedColumn:
                        $$SharedBooksTableReferences._ownerUserIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (loansRefs)
                    await $_getPrefetchedData<SharedBook, $SharedBooksTable,
                            Loan>(
                        currentTable: table,
                        referencedTable:
                            $$SharedBooksTableReferences._loansRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SharedBooksTableReferences(db, table, p0)
                                .loansRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.sharedBookId == item.id),
                        typedResults: items),
                  if (notificationSharedBooks)
                    await $_getPrefetchedData<SharedBook, $SharedBooksTable,
                            InAppNotification>(
                        currentTable: table,
                        referencedTable: $$SharedBooksTableReferences
                            ._notificationSharedBooksTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SharedBooksTableReferences(db, table, p0)
                                .notificationSharedBooks,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.sharedBookId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$SharedBooksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SharedBooksTable,
    SharedBook,
    $$SharedBooksTableFilterComposer,
    $$SharedBooksTableOrderingComposer,
    $$SharedBooksTableAnnotationComposer,
    $$SharedBooksTableCreateCompanionBuilder,
    $$SharedBooksTableUpdateCompanionBuilder,
    (SharedBook, $$SharedBooksTableReferences),
    SharedBook,
    PrefetchHooks Function(
        {bool groupId,
        bool bookId,
        bool ownerUserId,
        bool loansRefs,
        bool notificationSharedBooks})>;
typedef $$GroupInvitationsTableCreateCompanionBuilder
    = GroupInvitationsCompanion Function({
  Value<int> id,
  required String uuid,
  Value<String?> remoteId,
  required int groupId,
  required String groupUuid,
  required int inviterUserId,
  Value<String?> inviterRemoteId,
  Value<int?> acceptedUserId,
  Value<String?> acceptedUserRemoteId,
  Value<String> role,
  required String code,
  Value<String> status,
  required DateTime expiresAt,
  Value<DateTime?> respondedAt,
  Value<bool> isDirty,
  Value<bool> isDeleted,
  Value<DateTime?> syncedAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$GroupInvitationsTableUpdateCompanionBuilder
    = GroupInvitationsCompanion Function({
  Value<int> id,
  Value<String> uuid,
  Value<String?> remoteId,
  Value<int> groupId,
  Value<String> groupUuid,
  Value<int> inviterUserId,
  Value<String?> inviterRemoteId,
  Value<int?> acceptedUserId,
  Value<String?> acceptedUserRemoteId,
  Value<String> role,
  Value<String> code,
  Value<String> status,
  Value<DateTime> expiresAt,
  Value<DateTime?> respondedAt,
  Value<bool> isDirty,
  Value<bool> isDeleted,
  Value<DateTime?> syncedAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

final class $$GroupInvitationsTableReferences extends BaseReferences<
    _$AppDatabase, $GroupInvitationsTable, GroupInvitation> {
  $$GroupInvitationsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $GroupsTable _groupIdTable(_$AppDatabase db) => db.groups.createAlias(
      $_aliasNameGenerator(db.groupInvitations.groupId, db.groups.id));

  $$GroupsTableProcessedTableManager get groupId {
    final $_column = $_itemColumn<int>('group_id')!;

    final manager = $$GroupsTableTableManager($_db, $_db.groups)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_groupIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $LocalUsersTable _inviterUserIdTable(_$AppDatabase db) =>
      db.localUsers.createAlias($_aliasNameGenerator(
          db.groupInvitations.inviterUserId, db.localUsers.id));

  $$LocalUsersTableProcessedTableManager get inviterUserId {
    final $_column = $_itemColumn<int>('inviter_user_id')!;

    final manager = $$LocalUsersTableTableManager($_db, $_db.localUsers)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_inviterUserIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $LocalUsersTable _acceptedUserIdTable(_$AppDatabase db) =>
      db.localUsers.createAlias($_aliasNameGenerator(
          db.groupInvitations.acceptedUserId, db.localUsers.id));

  $$LocalUsersTableProcessedTableManager? get acceptedUserId {
    final $_column = $_itemColumn<int>('accepted_user_id');
    if ($_column == null) return null;
    final manager = $$LocalUsersTableTableManager($_db, $_db.localUsers)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_acceptedUserIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$GroupInvitationsTableFilterComposer
    extends Composer<_$AppDatabase, $GroupInvitationsTable> {
  $$GroupInvitationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get remoteId => $composableBuilder(
      column: $table.remoteId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get groupUuid => $composableBuilder(
      column: $table.groupUuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get inviterRemoteId => $composableBuilder(
      column: $table.inviterRemoteId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get acceptedUserRemoteId => $composableBuilder(
      column: $table.acceptedUserRemoteId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get expiresAt => $composableBuilder(
      column: $table.expiresAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get respondedAt => $composableBuilder(
      column: $table.respondedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDirty => $composableBuilder(
      column: $table.isDirty, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$GroupsTableFilterComposer get groupId {
    final $$GroupsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.groupId,
        referencedTable: $db.groups,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GroupsTableFilterComposer(
              $db: $db,
              $table: $db.groups,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$LocalUsersTableFilterComposer get inviterUserId {
    final $$LocalUsersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.inviterUserId,
        referencedTable: $db.localUsers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LocalUsersTableFilterComposer(
              $db: $db,
              $table: $db.localUsers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$LocalUsersTableFilterComposer get acceptedUserId {
    final $$LocalUsersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.acceptedUserId,
        referencedTable: $db.localUsers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LocalUsersTableFilterComposer(
              $db: $db,
              $table: $db.localUsers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$GroupInvitationsTableOrderingComposer
    extends Composer<_$AppDatabase, $GroupInvitationsTable> {
  $$GroupInvitationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get remoteId => $composableBuilder(
      column: $table.remoteId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get groupUuid => $composableBuilder(
      column: $table.groupUuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get inviterRemoteId => $composableBuilder(
      column: $table.inviterRemoteId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get acceptedUserRemoteId => $composableBuilder(
      column: $table.acceptedUserRemoteId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get expiresAt => $composableBuilder(
      column: $table.expiresAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get respondedAt => $composableBuilder(
      column: $table.respondedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDirty => $composableBuilder(
      column: $table.isDirty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$GroupsTableOrderingComposer get groupId {
    final $$GroupsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.groupId,
        referencedTable: $db.groups,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GroupsTableOrderingComposer(
              $db: $db,
              $table: $db.groups,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$LocalUsersTableOrderingComposer get inviterUserId {
    final $$LocalUsersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.inviterUserId,
        referencedTable: $db.localUsers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LocalUsersTableOrderingComposer(
              $db: $db,
              $table: $db.localUsers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$LocalUsersTableOrderingComposer get acceptedUserId {
    final $$LocalUsersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.acceptedUserId,
        referencedTable: $db.localUsers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LocalUsersTableOrderingComposer(
              $db: $db,
              $table: $db.localUsers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$GroupInvitationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GroupInvitationsTable> {
  $$GroupInvitationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get groupUuid =>
      $composableBuilder(column: $table.groupUuid, builder: (column) => column);

  GeneratedColumn<String> get inviterRemoteId => $composableBuilder(
      column: $table.inviterRemoteId, builder: (column) => column);

  GeneratedColumn<String> get acceptedUserRemoteId => $composableBuilder(
      column: $table.acceptedUserRemoteId, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);

  GeneratedColumn<DateTime> get respondedAt => $composableBuilder(
      column: $table.respondedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$GroupsTableAnnotationComposer get groupId {
    final $$GroupsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.groupId,
        referencedTable: $db.groups,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GroupsTableAnnotationComposer(
              $db: $db,
              $table: $db.groups,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$LocalUsersTableAnnotationComposer get inviterUserId {
    final $$LocalUsersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.inviterUserId,
        referencedTable: $db.localUsers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LocalUsersTableAnnotationComposer(
              $db: $db,
              $table: $db.localUsers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$LocalUsersTableAnnotationComposer get acceptedUserId {
    final $$LocalUsersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.acceptedUserId,
        referencedTable: $db.localUsers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LocalUsersTableAnnotationComposer(
              $db: $db,
              $table: $db.localUsers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$GroupInvitationsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GroupInvitationsTable,
    GroupInvitation,
    $$GroupInvitationsTableFilterComposer,
    $$GroupInvitationsTableOrderingComposer,
    $$GroupInvitationsTableAnnotationComposer,
    $$GroupInvitationsTableCreateCompanionBuilder,
    $$GroupInvitationsTableUpdateCompanionBuilder,
    (GroupInvitation, $$GroupInvitationsTableReferences),
    GroupInvitation,
    PrefetchHooks Function(
        {bool groupId, bool inviterUserId, bool acceptedUserId})> {
  $$GroupInvitationsTableTableManager(
      _$AppDatabase db, $GroupInvitationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GroupInvitationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GroupInvitationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GroupInvitationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> uuid = const Value.absent(),
            Value<String?> remoteId = const Value.absent(),
            Value<int> groupId = const Value.absent(),
            Value<String> groupUuid = const Value.absent(),
            Value<int> inviterUserId = const Value.absent(),
            Value<String?> inviterRemoteId = const Value.absent(),
            Value<int?> acceptedUserId = const Value.absent(),
            Value<String?> acceptedUserRemoteId = const Value.absent(),
            Value<String> role = const Value.absent(),
            Value<String> code = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime> expiresAt = const Value.absent(),
            Value<DateTime?> respondedAt = const Value.absent(),
            Value<bool> isDirty = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<DateTime?> syncedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              GroupInvitationsCompanion(
            id: id,
            uuid: uuid,
            remoteId: remoteId,
            groupId: groupId,
            groupUuid: groupUuid,
            inviterUserId: inviterUserId,
            inviterRemoteId: inviterRemoteId,
            acceptedUserId: acceptedUserId,
            acceptedUserRemoteId: acceptedUserRemoteId,
            role: role,
            code: code,
            status: status,
            expiresAt: expiresAt,
            respondedAt: respondedAt,
            isDirty: isDirty,
            isDeleted: isDeleted,
            syncedAt: syncedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String uuid,
            Value<String?> remoteId = const Value.absent(),
            required int groupId,
            required String groupUuid,
            required int inviterUserId,
            Value<String?> inviterRemoteId = const Value.absent(),
            Value<int?> acceptedUserId = const Value.absent(),
            Value<String?> acceptedUserRemoteId = const Value.absent(),
            Value<String> role = const Value.absent(),
            required String code,
            Value<String> status = const Value.absent(),
            required DateTime expiresAt,
            Value<DateTime?> respondedAt = const Value.absent(),
            Value<bool> isDirty = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<DateTime?> syncedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              GroupInvitationsCompanion.insert(
            id: id,
            uuid: uuid,
            remoteId: remoteId,
            groupId: groupId,
            groupUuid: groupUuid,
            inviterUserId: inviterUserId,
            inviterRemoteId: inviterRemoteId,
            acceptedUserId: acceptedUserId,
            acceptedUserRemoteId: acceptedUserRemoteId,
            role: role,
            code: code,
            status: status,
            expiresAt: expiresAt,
            respondedAt: respondedAt,
            isDirty: isDirty,
            isDeleted: isDeleted,
            syncedAt: syncedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$GroupInvitationsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {groupId = false,
              inviterUserId = false,
              acceptedUserId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (groupId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.groupId,
                    referencedTable:
                        $$GroupInvitationsTableReferences._groupIdTable(db),
                    referencedColumn:
                        $$GroupInvitationsTableReferences._groupIdTable(db).id,
                  ) as T;
                }
                if (inviterUserId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.inviterUserId,
                    referencedTable: $$GroupInvitationsTableReferences
                        ._inviterUserIdTable(db),
                    referencedColumn: $$GroupInvitationsTableReferences
                        ._inviterUserIdTable(db)
                        .id,
                  ) as T;
                }
                if (acceptedUserId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.acceptedUserId,
                    referencedTable: $$GroupInvitationsTableReferences
                        ._acceptedUserIdTable(db),
                    referencedColumn: $$GroupInvitationsTableReferences
                        ._acceptedUserIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$GroupInvitationsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $GroupInvitationsTable,
    GroupInvitation,
    $$GroupInvitationsTableFilterComposer,
    $$GroupInvitationsTableOrderingComposer,
    $$GroupInvitationsTableAnnotationComposer,
    $$GroupInvitationsTableCreateCompanionBuilder,
    $$GroupInvitationsTableUpdateCompanionBuilder,
    (GroupInvitation, $$GroupInvitationsTableReferences),
    GroupInvitation,
    PrefetchHooks Function(
        {bool groupId, bool inviterUserId, bool acceptedUserId})>;
typedef $$LoansTableCreateCompanionBuilder = LoansCompanion Function({
  Value<int> id,
  required String uuid,
  Value<String?> remoteId,
  Value<int?> sharedBookId,
  Value<int?> bookId,
  Value<int?> borrowerUserId,
  required int lenderUserId,
  Value<String?> externalBorrowerName,
  Value<String?> externalBorrowerContact,
  Value<String> status,
  Value<DateTime> requestedAt,
  Value<DateTime?> approvedAt,
  Value<DateTime?> dueDate,
  Value<DateTime?> borrowerReturnedAt,
  Value<DateTime?> lenderReturnedAt,
  Value<DateTime?> returnedAt,
  Value<bool> isDirty,
  Value<bool> isDeleted,
  Value<DateTime?> syncedAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$LoansTableUpdateCompanionBuilder = LoansCompanion Function({
  Value<int> id,
  Value<String> uuid,
  Value<String?> remoteId,
  Value<int?> sharedBookId,
  Value<int?> bookId,
  Value<int?> borrowerUserId,
  Value<int> lenderUserId,
  Value<String?> externalBorrowerName,
  Value<String?> externalBorrowerContact,
  Value<String> status,
  Value<DateTime> requestedAt,
  Value<DateTime?> approvedAt,
  Value<DateTime?> dueDate,
  Value<DateTime?> borrowerReturnedAt,
  Value<DateTime?> lenderReturnedAt,
  Value<DateTime?> returnedAt,
  Value<bool> isDirty,
  Value<bool> isDeleted,
  Value<DateTime?> syncedAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

final class $$LoansTableReferences
    extends BaseReferences<_$AppDatabase, $LoansTable, Loan> {
  $$LoansTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SharedBooksTable _sharedBookIdTable(_$AppDatabase db) =>
      db.sharedBooks.createAlias(
          $_aliasNameGenerator(db.loans.sharedBookId, db.sharedBooks.id));

  $$SharedBooksTableProcessedTableManager? get sharedBookId {
    final $_column = $_itemColumn<int>('shared_book_id');
    if ($_column == null) return null;
    final manager = $$SharedBooksTableTableManager($_db, $_db.sharedBooks)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sharedBookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $BooksTable _bookIdTable(_$AppDatabase db) =>
      db.books.createAlias($_aliasNameGenerator(db.loans.bookId, db.books.id));

  $$BooksTableProcessedTableManager? get bookId {
    final $_column = $_itemColumn<int>('book_id');
    if ($_column == null) return null;
    final manager = $$BooksTableTableManager($_db, $_db.books)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $LocalUsersTable _borrowerUserIdTable(_$AppDatabase db) =>
      db.localUsers.createAlias(
          $_aliasNameGenerator(db.loans.borrowerUserId, db.localUsers.id));

  $$LocalUsersTableProcessedTableManager? get borrowerUserId {
    final $_column = $_itemColumn<int>('borrower_user_id');
    if ($_column == null) return null;
    final manager = $$LocalUsersTableTableManager($_db, $_db.localUsers)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_borrowerUserIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $LocalUsersTable _lenderUserIdTable(_$AppDatabase db) =>
      db.localUsers.createAlias(
          $_aliasNameGenerator(db.loans.lenderUserId, db.localUsers.id));

  $$LocalUsersTableProcessedTableManager get lenderUserId {
    final $_column = $_itemColumn<int>('lender_user_id')!;

    final manager = $$LocalUsersTableTableManager($_db, $_db.localUsers)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_lenderUserIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$InAppNotificationsTable, List<InAppNotification>>
      _notificationLoansTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.inAppNotifications,
              aliasName: $_aliasNameGenerator(
                  db.loans.id, db.inAppNotifications.loanId));

  $$InAppNotificationsTableProcessedTableManager get notificationLoans {
    final manager =
        $$InAppNotificationsTableTableManager($_db, $_db.inAppNotifications)
            .filter((f) => f.loanId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_notificationLoansTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$LoanNotificationsTable, List<LoanNotification>>
      _loanNotificationsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.loanNotifications,
              aliasName: $_aliasNameGenerator(
                  db.loans.id, db.loanNotifications.loanId));

  $$LoanNotificationsTableProcessedTableManager get loanNotificationsRefs {
    final manager =
        $$LoanNotificationsTableTableManager($_db, $_db.loanNotifications)
            .filter((f) => f.loanId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_loanNotificationsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$LoansTableFilterComposer extends Composer<_$AppDatabase, $LoansTable> {
  $$LoansTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get remoteId => $composableBuilder(
      column: $table.remoteId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get externalBorrowerName => $composableBuilder(
      column: $table.externalBorrowerName,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get externalBorrowerContact => $composableBuilder(
      column: $table.externalBorrowerContact,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get requestedAt => $composableBuilder(
      column: $table.requestedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get approvedAt => $composableBuilder(
      column: $table.approvedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get borrowerReturnedAt => $composableBuilder(
      column: $table.borrowerReturnedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lenderReturnedAt => $composableBuilder(
      column: $table.lenderReturnedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get returnedAt => $composableBuilder(
      column: $table.returnedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDirty => $composableBuilder(
      column: $table.isDirty, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$SharedBooksTableFilterComposer get sharedBookId {
    final $$SharedBooksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sharedBookId,
        referencedTable: $db.sharedBooks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SharedBooksTableFilterComposer(
              $db: $db,
              $table: $db.sharedBooks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$BooksTableFilterComposer get bookId {
    final $$BooksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.bookId,
        referencedTable: $db.books,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BooksTableFilterComposer(
              $db: $db,
              $table: $db.books,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$LocalUsersTableFilterComposer get borrowerUserId {
    final $$LocalUsersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.borrowerUserId,
        referencedTable: $db.localUsers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LocalUsersTableFilterComposer(
              $db: $db,
              $table: $db.localUsers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$LocalUsersTableFilterComposer get lenderUserId {
    final $$LocalUsersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.lenderUserId,
        referencedTable: $db.localUsers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LocalUsersTableFilterComposer(
              $db: $db,
              $table: $db.localUsers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> notificationLoans(
      Expression<bool> Function($$InAppNotificationsTableFilterComposer f) f) {
    final $$InAppNotificationsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.inAppNotifications,
        getReferencedColumn: (t) => t.loanId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InAppNotificationsTableFilterComposer(
              $db: $db,
              $table: $db.inAppNotifications,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> loanNotificationsRefs(
      Expression<bool> Function($$LoanNotificationsTableFilterComposer f) f) {
    final $$LoanNotificationsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.loanNotifications,
        getReferencedColumn: (t) => t.loanId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LoanNotificationsTableFilterComposer(
              $db: $db,
              $table: $db.loanNotifications,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$LoansTableOrderingComposer
    extends Composer<_$AppDatabase, $LoansTable> {
  $$LoansTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get remoteId => $composableBuilder(
      column: $table.remoteId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get externalBorrowerName => $composableBuilder(
      column: $table.externalBorrowerName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get externalBorrowerContact => $composableBuilder(
      column: $table.externalBorrowerContact,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get requestedAt => $composableBuilder(
      column: $table.requestedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get approvedAt => $composableBuilder(
      column: $table.approvedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get borrowerReturnedAt => $composableBuilder(
      column: $table.borrowerReturnedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lenderReturnedAt => $composableBuilder(
      column: $table.lenderReturnedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get returnedAt => $composableBuilder(
      column: $table.returnedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDirty => $composableBuilder(
      column: $table.isDirty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$SharedBooksTableOrderingComposer get sharedBookId {
    final $$SharedBooksTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sharedBookId,
        referencedTable: $db.sharedBooks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SharedBooksTableOrderingComposer(
              $db: $db,
              $table: $db.sharedBooks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$BooksTableOrderingComposer get bookId {
    final $$BooksTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.bookId,
        referencedTable: $db.books,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BooksTableOrderingComposer(
              $db: $db,
              $table: $db.books,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$LocalUsersTableOrderingComposer get borrowerUserId {
    final $$LocalUsersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.borrowerUserId,
        referencedTable: $db.localUsers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LocalUsersTableOrderingComposer(
              $db: $db,
              $table: $db.localUsers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$LocalUsersTableOrderingComposer get lenderUserId {
    final $$LocalUsersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.lenderUserId,
        referencedTable: $db.localUsers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LocalUsersTableOrderingComposer(
              $db: $db,
              $table: $db.localUsers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$LoansTableAnnotationComposer
    extends Composer<_$AppDatabase, $LoansTable> {
  $$LoansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get externalBorrowerName => $composableBuilder(
      column: $table.externalBorrowerName, builder: (column) => column);

  GeneratedColumn<String> get externalBorrowerContact => $composableBuilder(
      column: $table.externalBorrowerContact, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get requestedAt => $composableBuilder(
      column: $table.requestedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get approvedAt => $composableBuilder(
      column: $table.approvedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<DateTime> get borrowerReturnedAt => $composableBuilder(
      column: $table.borrowerReturnedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lenderReturnedAt => $composableBuilder(
      column: $table.lenderReturnedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get returnedAt => $composableBuilder(
      column: $table.returnedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$SharedBooksTableAnnotationComposer get sharedBookId {
    final $$SharedBooksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sharedBookId,
        referencedTable: $db.sharedBooks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SharedBooksTableAnnotationComposer(
              $db: $db,
              $table: $db.sharedBooks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$BooksTableAnnotationComposer get bookId {
    final $$BooksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.bookId,
        referencedTable: $db.books,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BooksTableAnnotationComposer(
              $db: $db,
              $table: $db.books,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$LocalUsersTableAnnotationComposer get borrowerUserId {
    final $$LocalUsersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.borrowerUserId,
        referencedTable: $db.localUsers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LocalUsersTableAnnotationComposer(
              $db: $db,
              $table: $db.localUsers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$LocalUsersTableAnnotationComposer get lenderUserId {
    final $$LocalUsersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.lenderUserId,
        referencedTable: $db.localUsers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LocalUsersTableAnnotationComposer(
              $db: $db,
              $table: $db.localUsers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> notificationLoans<T extends Object>(
      Expression<T> Function($$InAppNotificationsTableAnnotationComposer a) f) {
    final $$InAppNotificationsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.inAppNotifications,
            getReferencedColumn: (t) => t.loanId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$InAppNotificationsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.inAppNotifications,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> loanNotificationsRefs<T extends Object>(
      Expression<T> Function($$LoanNotificationsTableAnnotationComposer a) f) {
    final $$LoanNotificationsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.loanNotifications,
            getReferencedColumn: (t) => t.loanId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$LoanNotificationsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.loanNotifications,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$LoansTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LoansTable,
    Loan,
    $$LoansTableFilterComposer,
    $$LoansTableOrderingComposer,
    $$LoansTableAnnotationComposer,
    $$LoansTableCreateCompanionBuilder,
    $$LoansTableUpdateCompanionBuilder,
    (Loan, $$LoansTableReferences),
    Loan,
    PrefetchHooks Function(
        {bool sharedBookId,
        bool bookId,
        bool borrowerUserId,
        bool lenderUserId,
        bool notificationLoans,
        bool loanNotificationsRefs})> {
  $$LoansTableTableManager(_$AppDatabase db, $LoansTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LoansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LoansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LoansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> uuid = const Value.absent(),
            Value<String?> remoteId = const Value.absent(),
            Value<int?> sharedBookId = const Value.absent(),
            Value<int?> bookId = const Value.absent(),
            Value<int?> borrowerUserId = const Value.absent(),
            Value<int> lenderUserId = const Value.absent(),
            Value<String?> externalBorrowerName = const Value.absent(),
            Value<String?> externalBorrowerContact = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime> requestedAt = const Value.absent(),
            Value<DateTime?> approvedAt = const Value.absent(),
            Value<DateTime?> dueDate = const Value.absent(),
            Value<DateTime?> borrowerReturnedAt = const Value.absent(),
            Value<DateTime?> lenderReturnedAt = const Value.absent(),
            Value<DateTime?> returnedAt = const Value.absent(),
            Value<bool> isDirty = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<DateTime?> syncedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              LoansCompanion(
            id: id,
            uuid: uuid,
            remoteId: remoteId,
            sharedBookId: sharedBookId,
            bookId: bookId,
            borrowerUserId: borrowerUserId,
            lenderUserId: lenderUserId,
            externalBorrowerName: externalBorrowerName,
            externalBorrowerContact: externalBorrowerContact,
            status: status,
            requestedAt: requestedAt,
            approvedAt: approvedAt,
            dueDate: dueDate,
            borrowerReturnedAt: borrowerReturnedAt,
            lenderReturnedAt: lenderReturnedAt,
            returnedAt: returnedAt,
            isDirty: isDirty,
            isDeleted: isDeleted,
            syncedAt: syncedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String uuid,
            Value<String?> remoteId = const Value.absent(),
            Value<int?> sharedBookId = const Value.absent(),
            Value<int?> bookId = const Value.absent(),
            Value<int?> borrowerUserId = const Value.absent(),
            required int lenderUserId,
            Value<String?> externalBorrowerName = const Value.absent(),
            Value<String?> externalBorrowerContact = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime> requestedAt = const Value.absent(),
            Value<DateTime?> approvedAt = const Value.absent(),
            Value<DateTime?> dueDate = const Value.absent(),
            Value<DateTime?> borrowerReturnedAt = const Value.absent(),
            Value<DateTime?> lenderReturnedAt = const Value.absent(),
            Value<DateTime?> returnedAt = const Value.absent(),
            Value<bool> isDirty = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<DateTime?> syncedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              LoansCompanion.insert(
            id: id,
            uuid: uuid,
            remoteId: remoteId,
            sharedBookId: sharedBookId,
            bookId: bookId,
            borrowerUserId: borrowerUserId,
            lenderUserId: lenderUserId,
            externalBorrowerName: externalBorrowerName,
            externalBorrowerContact: externalBorrowerContact,
            status: status,
            requestedAt: requestedAt,
            approvedAt: approvedAt,
            dueDate: dueDate,
            borrowerReturnedAt: borrowerReturnedAt,
            lenderReturnedAt: lenderReturnedAt,
            returnedAt: returnedAt,
            isDirty: isDirty,
            isDeleted: isDeleted,
            syncedAt: syncedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$LoansTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {sharedBookId = false,
              bookId = false,
              borrowerUserId = false,
              lenderUserId = false,
              notificationLoans = false,
              loanNotificationsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (notificationLoans) db.inAppNotifications,
                if (loanNotificationsRefs) db.loanNotifications
              ],
              addJoins: <
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
                      dynamic>>(state) {
                if (sharedBookId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.sharedBookId,
                    referencedTable:
                        $$LoansTableReferences._sharedBookIdTable(db),
                    referencedColumn:
                        $$LoansTableReferences._sharedBookIdTable(db).id,
                  ) as T;
                }
                if (bookId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.bookId,
                    referencedTable: $$LoansTableReferences._bookIdTable(db),
                    referencedColumn:
                        $$LoansTableReferences._bookIdTable(db).id,
                  ) as T;
                }
                if (borrowerUserId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.borrowerUserId,
                    referencedTable:
                        $$LoansTableReferences._borrowerUserIdTable(db),
                    referencedColumn:
                        $$LoansTableReferences._borrowerUserIdTable(db).id,
                  ) as T;
                }
                if (lenderUserId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.lenderUserId,
                    referencedTable:
                        $$LoansTableReferences._lenderUserIdTable(db),
                    referencedColumn:
                        $$LoansTableReferences._lenderUserIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (notificationLoans)
                    await $_getPrefetchedData<Loan, $LoansTable,
                            InAppNotification>(
                        currentTable: table,
                        referencedTable:
                            $$LoansTableReferences._notificationLoansTable(db),
                        managerFromTypedResult: (p0) =>
                            $$LoansTableReferences(db, table, p0)
                                .notificationLoans,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.loanId == item.id),
                        typedResults: items),
                  if (loanNotificationsRefs)
                    await $_getPrefetchedData<Loan, $LoansTable,
                            LoanNotification>(
                        currentTable: table,
                        referencedTable: $$LoansTableReferences
                            ._loanNotificationsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$LoansTableReferences(db, table, p0)
                                .loanNotificationsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.loanId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$LoansTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LoansTable,
    Loan,
    $$LoansTableFilterComposer,
    $$LoansTableOrderingComposer,
    $$LoansTableAnnotationComposer,
    $$LoansTableCreateCompanionBuilder,
    $$LoansTableUpdateCompanionBuilder,
    (Loan, $$LoansTableReferences),
    Loan,
    PrefetchHooks Function(
        {bool sharedBookId,
        bool bookId,
        bool borrowerUserId,
        bool lenderUserId,
        bool notificationLoans,
        bool loanNotificationsRefs})>;
typedef $$InAppNotificationsTableCreateCompanionBuilder
    = InAppNotificationsCompanion Function({
  Value<int> id,
  required String uuid,
  required String type,
  Value<int?> loanId,
  Value<String?> loanUuid,
  Value<int?> sharedBookId,
  Value<String?> sharedBookUuid,
  Value<int?> actorUserId,
  required int targetUserId,
  Value<String?> title,
  Value<String?> message,
  Value<String> status,
  Value<bool> isDirty,
  Value<bool> isDeleted,
  Value<DateTime?> syncedAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$InAppNotificationsTableUpdateCompanionBuilder
    = InAppNotificationsCompanion Function({
  Value<int> id,
  Value<String> uuid,
  Value<String> type,
  Value<int?> loanId,
  Value<String?> loanUuid,
  Value<int?> sharedBookId,
  Value<String?> sharedBookUuid,
  Value<int?> actorUserId,
  Value<int> targetUserId,
  Value<String?> title,
  Value<String?> message,
  Value<String> status,
  Value<bool> isDirty,
  Value<bool> isDeleted,
  Value<DateTime?> syncedAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

final class $$InAppNotificationsTableReferences extends BaseReferences<
    _$AppDatabase, $InAppNotificationsTable, InAppNotification> {
  $$InAppNotificationsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $LoansTable _loanIdTable(_$AppDatabase db) => db.loans.createAlias(
      $_aliasNameGenerator(db.inAppNotifications.loanId, db.loans.id));

  $$LoansTableProcessedTableManager? get loanId {
    final $_column = $_itemColumn<int>('loan_id');
    if ($_column == null) return null;
    final manager = $$LoansTableTableManager($_db, $_db.loans)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_loanIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $SharedBooksTable _sharedBookIdTable(_$AppDatabase db) =>
      db.sharedBooks.createAlias($_aliasNameGenerator(
          db.inAppNotifications.sharedBookId, db.sharedBooks.id));

  $$SharedBooksTableProcessedTableManager? get sharedBookId {
    final $_column = $_itemColumn<int>('shared_book_id');
    if ($_column == null) return null;
    final manager = $$SharedBooksTableTableManager($_db, $_db.sharedBooks)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sharedBookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $LocalUsersTable _actorUserIdTable(_$AppDatabase db) =>
      db.localUsers.createAlias($_aliasNameGenerator(
          db.inAppNotifications.actorUserId, db.localUsers.id));

  $$LocalUsersTableProcessedTableManager? get actorUserId {
    final $_column = $_itemColumn<int>('actor_user_id');
    if ($_column == null) return null;
    final manager = $$LocalUsersTableTableManager($_db, $_db.localUsers)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_actorUserIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $LocalUsersTable _targetUserIdTable(_$AppDatabase db) =>
      db.localUsers.createAlias($_aliasNameGenerator(
          db.inAppNotifications.targetUserId, db.localUsers.id));

  $$LocalUsersTableProcessedTableManager get targetUserId {
    final $_column = $_itemColumn<int>('target_user_id')!;

    final manager = $$LocalUsersTableTableManager($_db, $_db.localUsers)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_targetUserIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$InAppNotificationsTableFilterComposer
    extends Composer<_$AppDatabase, $InAppNotificationsTable> {
  $$InAppNotificationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get loanUuid => $composableBuilder(
      column: $table.loanUuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sharedBookUuid => $composableBuilder(
      column: $table.sharedBookUuid,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get message => $composableBuilder(
      column: $table.message, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDirty => $composableBuilder(
      column: $table.isDirty, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$LoansTableFilterComposer get loanId {
    final $$LoansTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.loanId,
        referencedTable: $db.loans,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LoansTableFilterComposer(
              $db: $db,
              $table: $db.loans,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SharedBooksTableFilterComposer get sharedBookId {
    final $$SharedBooksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sharedBookId,
        referencedTable: $db.sharedBooks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SharedBooksTableFilterComposer(
              $db: $db,
              $table: $db.sharedBooks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$LocalUsersTableFilterComposer get actorUserId {
    final $$LocalUsersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.actorUserId,
        referencedTable: $db.localUsers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LocalUsersTableFilterComposer(
              $db: $db,
              $table: $db.localUsers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$LocalUsersTableFilterComposer get targetUserId {
    final $$LocalUsersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.targetUserId,
        referencedTable: $db.localUsers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LocalUsersTableFilterComposer(
              $db: $db,
              $table: $db.localUsers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$InAppNotificationsTableOrderingComposer
    extends Composer<_$AppDatabase, $InAppNotificationsTable> {
  $$InAppNotificationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get loanUuid => $composableBuilder(
      column: $table.loanUuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sharedBookUuid => $composableBuilder(
      column: $table.sharedBookUuid,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get message => $composableBuilder(
      column: $table.message, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDirty => $composableBuilder(
      column: $table.isDirty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$LoansTableOrderingComposer get loanId {
    final $$LoansTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.loanId,
        referencedTable: $db.loans,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LoansTableOrderingComposer(
              $db: $db,
              $table: $db.loans,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SharedBooksTableOrderingComposer get sharedBookId {
    final $$SharedBooksTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sharedBookId,
        referencedTable: $db.sharedBooks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SharedBooksTableOrderingComposer(
              $db: $db,
              $table: $db.sharedBooks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$LocalUsersTableOrderingComposer get actorUserId {
    final $$LocalUsersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.actorUserId,
        referencedTable: $db.localUsers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LocalUsersTableOrderingComposer(
              $db: $db,
              $table: $db.localUsers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$LocalUsersTableOrderingComposer get targetUserId {
    final $$LocalUsersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.targetUserId,
        referencedTable: $db.localUsers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LocalUsersTableOrderingComposer(
              $db: $db,
              $table: $db.localUsers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$InAppNotificationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InAppNotificationsTable> {
  $$InAppNotificationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get loanUuid =>
      $composableBuilder(column: $table.loanUuid, builder: (column) => column);

  GeneratedColumn<String> get sharedBookUuid => $composableBuilder(
      column: $table.sharedBookUuid, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$LoansTableAnnotationComposer get loanId {
    final $$LoansTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.loanId,
        referencedTable: $db.loans,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LoansTableAnnotationComposer(
              $db: $db,
              $table: $db.loans,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SharedBooksTableAnnotationComposer get sharedBookId {
    final $$SharedBooksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sharedBookId,
        referencedTable: $db.sharedBooks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SharedBooksTableAnnotationComposer(
              $db: $db,
              $table: $db.sharedBooks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$LocalUsersTableAnnotationComposer get actorUserId {
    final $$LocalUsersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.actorUserId,
        referencedTable: $db.localUsers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LocalUsersTableAnnotationComposer(
              $db: $db,
              $table: $db.localUsers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$LocalUsersTableAnnotationComposer get targetUserId {
    final $$LocalUsersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.targetUserId,
        referencedTable: $db.localUsers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LocalUsersTableAnnotationComposer(
              $db: $db,
              $table: $db.localUsers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$InAppNotificationsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $InAppNotificationsTable,
    InAppNotification,
    $$InAppNotificationsTableFilterComposer,
    $$InAppNotificationsTableOrderingComposer,
    $$InAppNotificationsTableAnnotationComposer,
    $$InAppNotificationsTableCreateCompanionBuilder,
    $$InAppNotificationsTableUpdateCompanionBuilder,
    (InAppNotification, $$InAppNotificationsTableReferences),
    InAppNotification,
    PrefetchHooks Function(
        {bool loanId,
        bool sharedBookId,
        bool actorUserId,
        bool targetUserId})> {
  $$InAppNotificationsTableTableManager(
      _$AppDatabase db, $InAppNotificationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InAppNotificationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InAppNotificationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InAppNotificationsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> uuid = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<int?> loanId = const Value.absent(),
            Value<String?> loanUuid = const Value.absent(),
            Value<int?> sharedBookId = const Value.absent(),
            Value<String?> sharedBookUuid = const Value.absent(),
            Value<int?> actorUserId = const Value.absent(),
            Value<int> targetUserId = const Value.absent(),
            Value<String?> title = const Value.absent(),
            Value<String?> message = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<bool> isDirty = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<DateTime?> syncedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              InAppNotificationsCompanion(
            id: id,
            uuid: uuid,
            type: type,
            loanId: loanId,
            loanUuid: loanUuid,
            sharedBookId: sharedBookId,
            sharedBookUuid: sharedBookUuid,
            actorUserId: actorUserId,
            targetUserId: targetUserId,
            title: title,
            message: message,
            status: status,
            isDirty: isDirty,
            isDeleted: isDeleted,
            syncedAt: syncedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String uuid,
            required String type,
            Value<int?> loanId = const Value.absent(),
            Value<String?> loanUuid = const Value.absent(),
            Value<int?> sharedBookId = const Value.absent(),
            Value<String?> sharedBookUuid = const Value.absent(),
            Value<int?> actorUserId = const Value.absent(),
            required int targetUserId,
            Value<String?> title = const Value.absent(),
            Value<String?> message = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<bool> isDirty = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<DateTime?> syncedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              InAppNotificationsCompanion.insert(
            id: id,
            uuid: uuid,
            type: type,
            loanId: loanId,
            loanUuid: loanUuid,
            sharedBookId: sharedBookId,
            sharedBookUuid: sharedBookUuid,
            actorUserId: actorUserId,
            targetUserId: targetUserId,
            title: title,
            message: message,
            status: status,
            isDirty: isDirty,
            isDeleted: isDeleted,
            syncedAt: syncedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$InAppNotificationsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {loanId = false,
              sharedBookId = false,
              actorUserId = false,
              targetUserId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (loanId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.loanId,
                    referencedTable:
                        $$InAppNotificationsTableReferences._loanIdTable(db),
                    referencedColumn:
                        $$InAppNotificationsTableReferences._loanIdTable(db).id,
                  ) as T;
                }
                if (sharedBookId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.sharedBookId,
                    referencedTable: $$InAppNotificationsTableReferences
                        ._sharedBookIdTable(db),
                    referencedColumn: $$InAppNotificationsTableReferences
                        ._sharedBookIdTable(db)
                        .id,
                  ) as T;
                }
                if (actorUserId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.actorUserId,
                    referencedTable: $$InAppNotificationsTableReferences
                        ._actorUserIdTable(db),
                    referencedColumn: $$InAppNotificationsTableReferences
                        ._actorUserIdTable(db)
                        .id,
                  ) as T;
                }
                if (targetUserId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.targetUserId,
                    referencedTable: $$InAppNotificationsTableReferences
                        ._targetUserIdTable(db),
                    referencedColumn: $$InAppNotificationsTableReferences
                        ._targetUserIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$InAppNotificationsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $InAppNotificationsTable,
    InAppNotification,
    $$InAppNotificationsTableFilterComposer,
    $$InAppNotificationsTableOrderingComposer,
    $$InAppNotificationsTableAnnotationComposer,
    $$InAppNotificationsTableCreateCompanionBuilder,
    $$InAppNotificationsTableUpdateCompanionBuilder,
    (InAppNotification, $$InAppNotificationsTableReferences),
    InAppNotification,
    PrefetchHooks Function(
        {bool loanId, bool sharedBookId, bool actorUserId, bool targetUserId})>;
typedef $$LoanNotificationsTableCreateCompanionBuilder
    = LoanNotificationsCompanion Function({
  Value<int> id,
  required String uuid,
  Value<String?> remoteId,
  required int loanId,
  required int userId,
  required String type,
  required String title,
  required String message,
  Value<String> status,
  Value<DateTime?> readAt,
  Value<bool> isDirty,
  Value<DateTime?> syncedAt,
  Value<DateTime> createdAt,
});
typedef $$LoanNotificationsTableUpdateCompanionBuilder
    = LoanNotificationsCompanion Function({
  Value<int> id,
  Value<String> uuid,
  Value<String?> remoteId,
  Value<int> loanId,
  Value<int> userId,
  Value<String> type,
  Value<String> title,
  Value<String> message,
  Value<String> status,
  Value<DateTime?> readAt,
  Value<bool> isDirty,
  Value<DateTime?> syncedAt,
  Value<DateTime> createdAt,
});

final class $$LoanNotificationsTableReferences extends BaseReferences<
    _$AppDatabase, $LoanNotificationsTable, LoanNotification> {
  $$LoanNotificationsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $LoansTable _loanIdTable(_$AppDatabase db) => db.loans.createAlias(
      $_aliasNameGenerator(db.loanNotifications.loanId, db.loans.id));

  $$LoansTableProcessedTableManager get loanId {
    final $_column = $_itemColumn<int>('loan_id')!;

    final manager = $$LoansTableTableManager($_db, $_db.loans)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_loanIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $LocalUsersTable _userIdTable(_$AppDatabase db) =>
      db.localUsers.createAlias(
          $_aliasNameGenerator(db.loanNotifications.userId, db.localUsers.id));

  $$LocalUsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<int>('user_id')!;

    final manager = $$LocalUsersTableTableManager($_db, $_db.localUsers)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$LoanNotificationsTableFilterComposer
    extends Composer<_$AppDatabase, $LoanNotificationsTable> {
  $$LoanNotificationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get remoteId => $composableBuilder(
      column: $table.remoteId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get message => $composableBuilder(
      column: $table.message, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get readAt => $composableBuilder(
      column: $table.readAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDirty => $composableBuilder(
      column: $table.isDirty, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$LoansTableFilterComposer get loanId {
    final $$LoansTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.loanId,
        referencedTable: $db.loans,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LoansTableFilterComposer(
              $db: $db,
              $table: $db.loans,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$LocalUsersTableFilterComposer get userId {
    final $$LocalUsersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.localUsers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LocalUsersTableFilterComposer(
              $db: $db,
              $table: $db.localUsers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$LoanNotificationsTableOrderingComposer
    extends Composer<_$AppDatabase, $LoanNotificationsTable> {
  $$LoanNotificationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get remoteId => $composableBuilder(
      column: $table.remoteId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get message => $composableBuilder(
      column: $table.message, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get readAt => $composableBuilder(
      column: $table.readAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDirty => $composableBuilder(
      column: $table.isDirty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$LoansTableOrderingComposer get loanId {
    final $$LoansTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.loanId,
        referencedTable: $db.loans,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LoansTableOrderingComposer(
              $db: $db,
              $table: $db.loans,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$LocalUsersTableOrderingComposer get userId {
    final $$LocalUsersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.localUsers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LocalUsersTableOrderingComposer(
              $db: $db,
              $table: $db.localUsers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$LoanNotificationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LoanNotificationsTable> {
  $$LoanNotificationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get readAt =>
      $composableBuilder(column: $table.readAt, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$LoansTableAnnotationComposer get loanId {
    final $$LoansTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.loanId,
        referencedTable: $db.loans,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LoansTableAnnotationComposer(
              $db: $db,
              $table: $db.loans,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$LocalUsersTableAnnotationComposer get userId {
    final $$LocalUsersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.localUsers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LocalUsersTableAnnotationComposer(
              $db: $db,
              $table: $db.localUsers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$LoanNotificationsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LoanNotificationsTable,
    LoanNotification,
    $$LoanNotificationsTableFilterComposer,
    $$LoanNotificationsTableOrderingComposer,
    $$LoanNotificationsTableAnnotationComposer,
    $$LoanNotificationsTableCreateCompanionBuilder,
    $$LoanNotificationsTableUpdateCompanionBuilder,
    (LoanNotification, $$LoanNotificationsTableReferences),
    LoanNotification,
    PrefetchHooks Function({bool loanId, bool userId})> {
  $$LoanNotificationsTableTableManager(
      _$AppDatabase db, $LoanNotificationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LoanNotificationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LoanNotificationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LoanNotificationsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> uuid = const Value.absent(),
            Value<String?> remoteId = const Value.absent(),
            Value<int> loanId = const Value.absent(),
            Value<int> userId = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> message = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime?> readAt = const Value.absent(),
            Value<bool> isDirty = const Value.absent(),
            Value<DateTime?> syncedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              LoanNotificationsCompanion(
            id: id,
            uuid: uuid,
            remoteId: remoteId,
            loanId: loanId,
            userId: userId,
            type: type,
            title: title,
            message: message,
            status: status,
            readAt: readAt,
            isDirty: isDirty,
            syncedAt: syncedAt,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String uuid,
            Value<String?> remoteId = const Value.absent(),
            required int loanId,
            required int userId,
            required String type,
            required String title,
            required String message,
            Value<String> status = const Value.absent(),
            Value<DateTime?> readAt = const Value.absent(),
            Value<bool> isDirty = const Value.absent(),
            Value<DateTime?> syncedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              LoanNotificationsCompanion.insert(
            id: id,
            uuid: uuid,
            remoteId: remoteId,
            loanId: loanId,
            userId: userId,
            type: type,
            title: title,
            message: message,
            status: status,
            readAt: readAt,
            isDirty: isDirty,
            syncedAt: syncedAt,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$LoanNotificationsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({loanId = false, userId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (loanId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.loanId,
                    referencedTable:
                        $$LoanNotificationsTableReferences._loanIdTable(db),
                    referencedColumn:
                        $$LoanNotificationsTableReferences._loanIdTable(db).id,
                  ) as T;
                }
                if (userId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.userId,
                    referencedTable:
                        $$LoanNotificationsTableReferences._userIdTable(db),
                    referencedColumn:
                        $$LoanNotificationsTableReferences._userIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$LoanNotificationsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LoanNotificationsTable,
    LoanNotification,
    $$LoanNotificationsTableFilterComposer,
    $$LoanNotificationsTableOrderingComposer,
    $$LoanNotificationsTableAnnotationComposer,
    $$LoanNotificationsTableCreateCompanionBuilder,
    $$LoanNotificationsTableUpdateCompanionBuilder,
    (LoanNotification, $$LoanNotificationsTableReferences),
    LoanNotification,
    PrefetchHooks Function({bool loanId, bool userId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalUsersTableTableManager get localUsers =>
      $$LocalUsersTableTableManager(_db, _db.localUsers);
  $$BooksTableTableManager get books =>
      $$BooksTableTableManager(_db, _db.books);
  $$BookReviewsTableTableManager get bookReviews =>
      $$BookReviewsTableTableManager(_db, _db.bookReviews);
  $$GroupsTableTableManager get groups =>
      $$GroupsTableTableManager(_db, _db.groups);
  $$GroupMembersTableTableManager get groupMembers =>
      $$GroupMembersTableTableManager(_db, _db.groupMembers);
  $$SharedBooksTableTableManager get sharedBooks =>
      $$SharedBooksTableTableManager(_db, _db.sharedBooks);
  $$GroupInvitationsTableTableManager get groupInvitations =>
      $$GroupInvitationsTableTableManager(_db, _db.groupInvitations);
  $$LoansTableTableManager get loans =>
      $$LoansTableTableManager(_db, _db.loans);
  $$InAppNotificationsTableTableManager get inAppNotifications =>
      $$InAppNotificationsTableTableManager(_db, _db.inAppNotifications);
  $$LoanNotificationsTableTableManager get loanNotifications =>
      $$LoanNotificationsTableTableManager(_db, _db.loanNotifications);
}
