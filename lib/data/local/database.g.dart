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
          ..write('isDirty: $isDirty, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, uuid, username, remoteId, isDirty,
      isDeleted, syncedAt, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalUser &&
          other.id == this.id &&
          other.uuid == this.uuid &&
          other.username == this.username &&
          other.remoteId == this.remoteId &&
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
  int get hashCode => Object.hash(id, uuid, remoteId, name, ownerUserId,
      ownerRemoteId, isDirty, isDeleted, syncedAt, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Group &&
          other.id == this.id &&
          other.uuid == this.uuid &&
          other.remoteId == this.remoteId &&
          other.name == this.name &&
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
      'shared_book_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES shared_books (id) ON DELETE CASCADE'));
  static const VerificationMeta _sharedBookUuidMeta =
      const VerificationMeta('sharedBookUuid');
  @override
  late final GeneratedColumn<String> sharedBookUuid = GeneratedColumn<String>(
      'shared_book_uuid', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 36),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _fromUserIdMeta =
      const VerificationMeta('fromUserId');
  @override
  late final GeneratedColumn<int> fromUserId = GeneratedColumn<int>(
      'from_user_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES local_users (id)'));
  static const VerificationMeta _fromRemoteIdMeta =
      const VerificationMeta('fromRemoteId');
  @override
  late final GeneratedColumn<String> fromRemoteId = GeneratedColumn<String>(
      'from_remote_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _toUserIdMeta =
      const VerificationMeta('toUserId');
  @override
  late final GeneratedColumn<int> toUserId = GeneratedColumn<int>(
      'to_user_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES local_users (id)'));
  static const VerificationMeta _toRemoteIdMeta =
      const VerificationMeta('toRemoteId');
  @override
  late final GeneratedColumn<String> toRemoteId = GeneratedColumn<String>(
      'to_remote_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 32),
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _startDateMeta =
      const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
      'start_date', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _dueDateMeta =
      const VerificationMeta('dueDate');
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
      'due_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _returnedAtMeta =
      const VerificationMeta('returnedAt');
  @override
  late final GeneratedColumn<DateTime> returnedAt = GeneratedColumn<DateTime>(
      'returned_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _cancelledAtMeta =
      const VerificationMeta('cancelledAt');
  @override
  late final GeneratedColumn<DateTime> cancelledAt = GeneratedColumn<DateTime>(
      'cancelled_at', aliasedName, true,
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
        sharedBookUuid,
        fromUserId,
        fromRemoteId,
        toUserId,
        toRemoteId,
        status,
        startDate,
        dueDate,
        returnedAt,
        cancelledAt,
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
    } else if (isInserting) {
      context.missing(_sharedBookIdMeta);
    }
    if (data.containsKey('shared_book_uuid')) {
      context.handle(
          _sharedBookUuidMeta,
          sharedBookUuid.isAcceptableOrUnknown(
              data['shared_book_uuid']!, _sharedBookUuidMeta));
    } else if (isInserting) {
      context.missing(_sharedBookUuidMeta);
    }
    if (data.containsKey('from_user_id')) {
      context.handle(
          _fromUserIdMeta,
          fromUserId.isAcceptableOrUnknown(
              data['from_user_id']!, _fromUserIdMeta));
    } else if (isInserting) {
      context.missing(_fromUserIdMeta);
    }
    if (data.containsKey('from_remote_id')) {
      context.handle(
          _fromRemoteIdMeta,
          fromRemoteId.isAcceptableOrUnknown(
              data['from_remote_id']!, _fromRemoteIdMeta));
    }
    if (data.containsKey('to_user_id')) {
      context.handle(_toUserIdMeta,
          toUserId.isAcceptableOrUnknown(data['to_user_id']!, _toUserIdMeta));
    } else if (isInserting) {
      context.missing(_toUserIdMeta);
    }
    if (data.containsKey('to_remote_id')) {
      context.handle(
          _toRemoteIdMeta,
          toRemoteId.isAcceptableOrUnknown(
              data['to_remote_id']!, _toRemoteIdMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('start_date')) {
      context.handle(_startDateMeta,
          startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta));
    }
    if (data.containsKey('due_date')) {
      context.handle(_dueDateMeta,
          dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta));
    }
    if (data.containsKey('returned_at')) {
      context.handle(
          _returnedAtMeta,
          returnedAt.isAcceptableOrUnknown(
              data['returned_at']!, _returnedAtMeta));
    }
    if (data.containsKey('cancelled_at')) {
      context.handle(
          _cancelledAtMeta,
          cancelledAt.isAcceptableOrUnknown(
              data['cancelled_at']!, _cancelledAtMeta));
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
          .read(DriftSqlType.int, data['${effectivePrefix}shared_book_id'])!,
      sharedBookUuid: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}shared_book_uuid'])!,
      fromUserId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}from_user_id'])!,
      fromRemoteId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}from_remote_id']),
      toUserId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}to_user_id'])!,
      toRemoteId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}to_remote_id']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      startDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_date'])!,
      dueDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}due_date']),
      returnedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}returned_at']),
      cancelledAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}cancelled_at']),
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
  final int sharedBookId;
  final String sharedBookUuid;
  final int fromUserId;
  final String? fromRemoteId;
  final int toUserId;
  final String? toRemoteId;
  final String status;
  final DateTime startDate;
  final DateTime? dueDate;
  final DateTime? returnedAt;
  final DateTime? cancelledAt;
  final bool isDirty;
  final bool isDeleted;
  final DateTime? syncedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Loan(
      {required this.id,
      required this.uuid,
      this.remoteId,
      required this.sharedBookId,
      required this.sharedBookUuid,
      required this.fromUserId,
      this.fromRemoteId,
      required this.toUserId,
      this.toRemoteId,
      required this.status,
      required this.startDate,
      this.dueDate,
      this.returnedAt,
      this.cancelledAt,
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
    map['shared_book_id'] = Variable<int>(sharedBookId);
    map['shared_book_uuid'] = Variable<String>(sharedBookUuid);
    map['from_user_id'] = Variable<int>(fromUserId);
    if (!nullToAbsent || fromRemoteId != null) {
      map['from_remote_id'] = Variable<String>(fromRemoteId);
    }
    map['to_user_id'] = Variable<int>(toUserId);
    if (!nullToAbsent || toRemoteId != null) {
      map['to_remote_id'] = Variable<String>(toRemoteId);
    }
    map['status'] = Variable<String>(status);
    map['start_date'] = Variable<DateTime>(startDate);
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    if (!nullToAbsent || returnedAt != null) {
      map['returned_at'] = Variable<DateTime>(returnedAt!);
    }
    if (!nullToAbsent || cancelledAt != null) {
      map['cancelled_at'] = Variable<DateTime>(cancelledAt!);
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
      sharedBookId: Value(sharedBookId),
      sharedBookUuid: Value(sharedBookUuid),
      fromUserId: Value(fromUserId),
      fromRemoteId: fromRemoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(fromRemoteId),
      toUserId: Value(toUserId),
      toRemoteId: toRemoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(toRemoteId),
      status: Value(status),
      startDate: Value(startDate),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      returnedAt: returnedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(returnedAt),
      cancelledAt: cancelledAt == null && nullToAbsent
          ? const Value.absent()
          : Value(cancelledAt),
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
      sharedBookId: serializer.fromJson<int>(json['sharedBookId']),
      sharedBookUuid: serializer.fromJson<String>(json['sharedBookUuid']),
      fromUserId: serializer.fromJson<int>(json['fromUserId']),
      fromRemoteId: serializer.fromJson<String?>(json['fromRemoteId']),
      toUserId: serializer.fromJson<int>(json['toUserId']),
      toRemoteId: serializer.fromJson<String?>(json['toRemoteId']),
      status: serializer.fromJson<String>(json['status']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      returnedAt: serializer.fromJson<DateTime?>(json['returnedAt']),
      cancelledAt: serializer.fromJson<DateTime?>(json['cancelledAt']),
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
      'sharedBookId': serializer.toJson<int>(sharedBookId),
      'sharedBookUuid': serializer.toJson<String>(sharedBookUuid),
      'fromUserId': serializer.toJson<int>(fromUserId),
      'fromRemoteId': serializer.toJson<String?>(fromRemoteId),
      'toUserId': serializer.toJson<int>(toUserId),
      'toRemoteId': serializer.toJson<String?>(toRemoteId),
      'status': serializer.toJson<String>(status),
      'startDate': serializer.toJson<DateTime>(startDate),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'returnedAt': serializer.toJson<DateTime?>(returnedAt),
      'cancelledAt': serializer.toJson<DateTime?>(cancelledAt),
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
          int? sharedBookId,
          String? sharedBookUuid,
          int? fromUserId,
          Value<String?> fromRemoteId = const Value.absent(),
          int? toUserId,
          Value<String?> toRemoteId = const Value.absent(),
          String? status,
          DateTime? startDate,
          Value<DateTime?> dueDate = const Value.absent(),
          Value<DateTime?> returnedAt = const Value.absent(),
          Value<DateTime?> cancelledAt = const Value.absent(),
          bool? isDirty,
          bool? isDeleted,
          Value<DateTime?> syncedAt = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Loan(
        id: id ?? this.id,
        uuid: uuid ?? this.uuid,
        remoteId: remoteId.present ? remoteId.value : this.remoteId,
        sharedBookId: sharedBookId ?? this.sharedBookId,
        sharedBookUuid: sharedBookUuid ?? this.sharedBookUuid,
        fromUserId: fromUserId ?? this.fromUserId,
        fromRemoteId:
            fromRemoteId.present ? fromRemoteId.value : this.fromRemoteId,
        toUserId: toUserId ?? this.toUserId,
        toRemoteId: toRemoteId.present ? toRemoteId.value : this.toRemoteId,
        status: status ?? this.status,
        startDate: startDate ?? this.startDate,
        dueDate: dueDate.present ? dueDate.value : this.dueDate,
        returnedAt: returnedAt.present ? returnedAt.value : this.returnedAt,
        cancelledAt:
            cancelledAt.present ? cancelledAt.value : this.cancelledAt,
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
      sharedBookUuid: data.sharedBookUuid.present
          ? data.sharedBookUuid.value
          : this.sharedBookUuid,
      fromUserId:
          data.fromUserId.present ? data.fromUserId.value : this.fromUserId,
      fromRemoteId: data.fromRemoteId.present
          ? data.fromRemoteId.value
          : this.fromRemoteId,
      toUserId: data.toUserId.present ? data.toUserId.value : this.toUserId,
      toRemoteId:
          data.toRemoteId.present ? data.toRemoteId.value : this.toRemoteId,
      status: data.status.present ? data.status.value : this.status,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      returnedAt:
          data.returnedAt.present ? data.returnedAt.value : this.returnedAt,
      cancelledAt:
          data.cancelledAt.present ? data.cancelledAt.value : this.cancelledAt,
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
          ..write('sharedBookUuid: $sharedBookUuid, ')
          ..write('fromUserId: $fromUserId, ')
          ..write('fromRemoteId: $fromRemoteId, ')
          ..write('toUserId: $toUserId, ')
          ..write('toRemoteId: $toRemoteId, ')
          ..write('status: $status, ')
          ..write('startDate: $startDate, ')
          ..write('dueDate: $dueDate, ')
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
  int get hashCode => Object.hash(
      id,
      uuid,
      remoteId,
      sharedBookId,
      sharedBookUuid,
      fromUserId,
      fromRemoteId,
      toUserId,
      toRemoteId,
      status,
      startDate,
      dueDate,
      returnedAt,
      isDirty,
      isDeleted,
      syncedAt,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Loan &&
          other.id == this.id &&
          other.uuid == this.uuid &&
          other.remoteId == this.remoteId &&
          other.sharedBookId == this.sharedBookId &&
          other.sharedBookUuid == this.sharedBookUuid &&
          other.fromUserId == this.fromUserId &&
          other.fromRemoteId == this.fromRemoteId &&
          other.toUserId == this.toUserId &&
          other.toRemoteId == this.toRemoteId &&
          other.status == this.status &&
          other.startDate == this.startDate &&
          other.dueDate == this.dueDate &&
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
  final Value<int> sharedBookId;
  final Value<String> sharedBookUuid;
  final Value<int> fromUserId;
  final Value<String?> fromRemoteId;
  final Value<int> toUserId;
  final Value<String?> toRemoteId;
  final Value<String> status;
  final Value<DateTime> startDate;
  final Value<DateTime?> dueDate;
  final Value<DateTime?> returnedAt;
  final Value<DateTime?> cancelledAt;
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
    this.sharedBookUuid = const Value.absent(),
    this.fromUserId = const Value.absent(),
    this.fromRemoteId = const Value.absent(),
    this.toUserId = const Value.absent(),
    this.toRemoteId = const Value.absent(),
    this.status = const Value.absent(),
    this.startDate = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.returnedAt = const Value.absent(),
    this.cancelledAt = const Value.absent(),
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
    required int sharedBookId,
    required String sharedBookUuid,
    required int fromUserId,
    this.fromRemoteId = const Value.absent(),
    required int toUserId,
    this.toRemoteId = const Value.absent(),
    this.status = const Value.absent(),
    this.startDate = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.returnedAt = const Value.absent(),
    this.cancelledAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : uuid = Value(uuid),
        sharedBookId = Value(sharedBookId),
        sharedBookUuid = Value(sharedBookUuid),
        fromUserId = Value(fromUserId),
        toUserId = Value(toUserId);
  static Insertable<Loan> custom({
    Expression<int>? id,
    Expression<String>? uuid,
    Expression<String>? remoteId,
    Expression<int>? sharedBookId,
    Expression<String>? sharedBookUuid,
    Expression<int>? fromUserId,
    Expression<String>? fromRemoteId,
    Expression<int>? toUserId,
    Expression<String>? toRemoteId,
    Expression<String>? status,
    Expression<DateTime>? startDate,
    Expression<DateTime>? dueDate,
    Expression<DateTime>? returnedAt,
    Expression<DateTime>? cancelledAt,
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
      if (sharedBookUuid != null) 'shared_book_uuid': sharedBookUuid,
      if (fromUserId != null) 'from_user_id': fromUserId,
      if (fromRemoteId != null) 'from_remote_id': fromRemoteId,
      if (toUserId != null) 'to_user_id': toUserId,
      if (toRemoteId != null) 'to_remote_id': toRemoteId,
      if (status != null) 'status': status,
      if (startDate != null) 'start_date': startDate,
      if (dueDate != null) 'due_date': dueDate,
      if (returnedAt != null) 'returned_at': returnedAt,
      if (cancelledAt != null) 'cancelled_at': cancelledAt,
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
      Value<int>? sharedBookId,
      Value<String>? sharedBookUuid,
      Value<int>? fromUserId,
      Value<String?>? fromRemoteId,
      Value<int>? toUserId,
      Value<String?>? toRemoteId,
      Value<String>? status,
      Value<DateTime>? startDate,
      Value<DateTime?>? dueDate,
      Value<DateTime?>? returnedAt,
      Value<DateTime?>? cancelledAt,
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
      sharedBookUuid: sharedBookUuid ?? this.sharedBookUuid,
      fromUserId: fromUserId ?? this.fromUserId,
      fromRemoteId: fromRemoteId ?? this.fromRemoteId,
      toUserId: toUserId ?? this.toUserId,
      toRemoteId: toRemoteId ?? this.toRemoteId,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      dueDate: dueDate ?? this.dueDate,
      returnedAt: returnedAt ?? this.returnedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
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
    if (sharedBookUuid.present) {
      map['shared_book_uuid'] = Variable<String>(sharedBookUuid.value);
    }
    if (fromUserId.present) {
      map['from_user_id'] = Variable<int>(fromUserId.value);
    }
    if (fromRemoteId.present) {
      map['from_remote_id'] = Variable<String>(fromRemoteId.value);
    }
    if (toUserId.present) {
      map['to_user_id'] = Variable<int>(toUserId.value);
    }
    if (toRemoteId.present) {
      map['to_remote_id'] = Variable<String>(toRemoteId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
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
          ..write('sharedBookUuid: $sharedBookUuid, ')
          ..write('fromUserId: $fromUserId, ')
          ..write('fromRemoteId: $fromRemoteId, ')
          ..write('toUserId: $toUserId, ')
          ..write('toRemoteId: $toRemoteId, ')
          ..write('status: $status, ')
          ..write('startDate: $startDate, ')
          ..write('dueDate: $dueDate, ')
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

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocalUsersTable localUsers = $LocalUsersTable(this);
  late final $BooksTable books = $BooksTable(this);
  late final $BookReviewsTable bookReviews = $BookReviewsTable(this);
  late final $GroupsTable groups = $GroupsTable(this);
  late final $GroupMembersTable groupMembers = $GroupMembersTable(this);
  late final $SharedBooksTable sharedBooks = $SharedBooksTable(this);
  late final $LoansTable loans = $LoansTable(this);
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
        loans
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
            on: TableUpdateQuery.onTableName('shared_books',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('loans', kind: UpdateKind.delete),
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

  static MultiTypedResultKey<$LoansTable, List<Loan>> _loansRequestedTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.loans,
          aliasName:
              $_aliasNameGenerator(db.localUsers.id, db.loans.fromUserId));

  $$LoansTableProcessedTableManager get loansRequested {
    final manager = $$LoansTableTableManager($_db, $_db.loans)
        .filter((f) => f.fromUserId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_loansRequestedTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$LoansTable, List<Loan>> _loansReceivedTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.loans,
          aliasName: $_aliasNameGenerator(db.localUsers.id, db.loans.toUserId));

  $$LoansTableProcessedTableManager get loansReceived {
    final manager = $$LoansTableTableManager($_db, $_db.loans)
        .filter((f) => f.toUserId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_loansReceivedTable($_db));
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

  Expression<bool> loansRequested(
      Expression<bool> Function($$LoansTableFilterComposer f) f) {
    final $$LoansTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.loans,
        getReferencedColumn: (t) => t.fromUserId,
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

  Expression<bool> loansReceived(
      Expression<bool> Function($$LoansTableFilterComposer f) f) {
    final $$LoansTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.loans,
        getReferencedColumn: (t) => t.toUserId,
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

  Expression<T> loansRequested<T extends Object>(
      Expression<T> Function($$LoansTableAnnotationComposer a) f) {
    final $$LoansTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.loans,
        getReferencedColumn: (t) => t.fromUserId,
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

  Expression<T> loansReceived<T extends Object>(
      Expression<T> Function($$LoansTableAnnotationComposer a) f) {
    final $$LoansTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.loans,
        getReferencedColumn: (t) => t.toUserId,
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
        bool loansRequested,
        bool loansReceived})> {
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
              loansRequested = false,
              loansReceived = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (ownedBooks) db.books,
                if (bookReviewsRefs) db.bookReviews,
                if (groupsRefs) db.groups,
                if (groupMemberships) db.groupMembers,
                if (sharedBooksOwned) db.sharedBooks,
                if (loansRequested) db.loans,
                if (loansReceived) db.loans
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
                  if (loansRequested)
                    await $_getPrefetchedData<LocalUser, $LocalUsersTable,
                            Loan>(
                        currentTable: table,
                        referencedTable: $$LocalUsersTableReferences
                            ._loansRequestedTable(db),
                        managerFromTypedResult: (p0) =>
                            $$LocalUsersTableReferences(db, table, p0)
                                .loansRequested,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.fromUserId == item.id),
                        typedResults: items),
                  if (loansReceived)
                    await $_getPrefetchedData<LocalUser, $LocalUsersTable,
                            Loan>(
                        currentTable: table,
                        referencedTable:
                            $$LocalUsersTableReferences._loansReceivedTable(db),
                        managerFromTypedResult: (p0) =>
                            $$LocalUsersTableReferences(db, table, p0)
                                .loansReceived,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.toUserId == item.id),
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
        bool loansRequested,
        bool loansReceived})>;
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
        {bool ownerUserId, bool bookReviewsRefs, bool sharedBooksRefs})> {
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
              sharedBooksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (bookReviewsRefs) db.bookReviews,
                if (sharedBooksRefs) db.sharedBooks
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
        {bool ownerUserId, bool bookReviewsRefs, bool sharedBooksRefs})>;
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
        {bool ownerUserId, bool groupMembersRefs, bool sharedBooksRefs})> {
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
              sharedBooksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (groupMembersRefs) db.groupMembers,
                if (sharedBooksRefs) db.sharedBooks
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
        {bool ownerUserId, bool groupMembersRefs, bool sharedBooksRefs})>;
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
        {bool groupId, bool bookId, bool ownerUserId, bool loansRefs})> {
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
              loansRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (loansRefs) db.loans],
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
        {bool groupId, bool bookId, bool ownerUserId, bool loansRefs})>;
typedef $$LoansTableCreateCompanionBuilder = LoansCompanion Function({
  Value<int> id,
  required String uuid,
  Value<String?> remoteId,
  required int sharedBookId,
  required String sharedBookUuid,
  required int fromUserId,
  Value<String?> fromRemoteId,
  required int toUserId,
  Value<String?> toRemoteId,
  Value<String> status,
  Value<DateTime> startDate,
  Value<DateTime?> dueDate,
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
  Value<int> sharedBookId,
  Value<String> sharedBookUuid,
  Value<int> fromUserId,
  Value<String?> fromRemoteId,
  Value<int> toUserId,
  Value<String?> toRemoteId,
  Value<String> status,
  Value<DateTime> startDate,
  Value<DateTime?> dueDate,
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

  $$SharedBooksTableProcessedTableManager get sharedBookId {
    final $_column = $_itemColumn<int>('shared_book_id')!;

    final manager = $$SharedBooksTableTableManager($_db, $_db.sharedBooks)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sharedBookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $LocalUsersTable _fromUserIdTable(_$AppDatabase db) => db.localUsers
      .createAlias($_aliasNameGenerator(db.loans.fromUserId, db.localUsers.id));

  $$LocalUsersTableProcessedTableManager get fromUserId {
    final $_column = $_itemColumn<int>('from_user_id')!;

    final manager = $$LocalUsersTableTableManager($_db, $_db.localUsers)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_fromUserIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $LocalUsersTable _toUserIdTable(_$AppDatabase db) => db.localUsers
      .createAlias($_aliasNameGenerator(db.loans.toUserId, db.localUsers.id));

  $$LocalUsersTableProcessedTableManager get toUserId {
    final $_column = $_itemColumn<int>('to_user_id')!;

    final manager = $$LocalUsersTableTableManager($_db, $_db.localUsers)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_toUserIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
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

  ColumnFilters<String> get sharedBookUuid => $composableBuilder(
      column: $table.sharedBookUuid,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fromRemoteId => $composableBuilder(
      column: $table.fromRemoteId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get toRemoteId => $composableBuilder(
      column: $table.toRemoteId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnFilters(column));

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

  $$LocalUsersTableFilterComposer get fromUserId {
    final $$LocalUsersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.fromUserId,
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

  $$LocalUsersTableFilterComposer get toUserId {
    final $$LocalUsersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.toUserId,
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

  ColumnOrderings<String> get sharedBookUuid => $composableBuilder(
      column: $table.sharedBookUuid,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fromRemoteId => $composableBuilder(
      column: $table.fromRemoteId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get toRemoteId => $composableBuilder(
      column: $table.toRemoteId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnOrderings(column));

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

  $$LocalUsersTableOrderingComposer get fromUserId {
    final $$LocalUsersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.fromUserId,
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

  $$LocalUsersTableOrderingComposer get toUserId {
    final $$LocalUsersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.toUserId,
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

  GeneratedColumn<String> get sharedBookUuid => $composableBuilder(
      column: $table.sharedBookUuid, builder: (column) => column);

  GeneratedColumn<String> get fromRemoteId => $composableBuilder(
      column: $table.fromRemoteId, builder: (column) => column);

  GeneratedColumn<String> get toRemoteId => $composableBuilder(
      column: $table.toRemoteId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

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

  $$LocalUsersTableAnnotationComposer get fromUserId {
    final $$LocalUsersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.fromUserId,
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

  $$LocalUsersTableAnnotationComposer get toUserId {
    final $$LocalUsersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.toUserId,
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
        {bool sharedBookId, bool fromUserId, bool toUserId})> {
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
            Value<int> sharedBookId = const Value.absent(),
            Value<String> sharedBookUuid = const Value.absent(),
            Value<int> fromUserId = const Value.absent(),
            Value<String?> fromRemoteId = const Value.absent(),
            Value<int> toUserId = const Value.absent(),
            Value<String?> toRemoteId = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime> startDate = const Value.absent(),
            Value<DateTime?> dueDate = const Value.absent(),
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
            sharedBookUuid: sharedBookUuid,
            fromUserId: fromUserId,
            fromRemoteId: fromRemoteId,
            toUserId: toUserId,
            toRemoteId: toRemoteId,
            status: status,
            startDate: startDate,
            dueDate: dueDate,
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
            required int sharedBookId,
            required String sharedBookUuid,
            required int fromUserId,
            Value<String?> fromRemoteId = const Value.absent(),
            required int toUserId,
            Value<String?> toRemoteId = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime> startDate = const Value.absent(),
            Value<DateTime?> dueDate = const Value.absent(),
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
            sharedBookUuid: sharedBookUuid,
            fromUserId: fromUserId,
            fromRemoteId: fromRemoteId,
            toUserId: toUserId,
            toRemoteId: toRemoteId,
            status: status,
            startDate: startDate,
            dueDate: dueDate,
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
              {sharedBookId = false, fromUserId = false, toUserId = false}) {
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
                if (fromUserId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.fromUserId,
                    referencedTable:
                        $$LoansTableReferences._fromUserIdTable(db),
                    referencedColumn:
                        $$LoansTableReferences._fromUserIdTable(db).id,
                  ) as T;
                }
                if (toUserId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.toUserId,
                    referencedTable: $$LoansTableReferences._toUserIdTable(db),
                    referencedColumn:
                        $$LoansTableReferences._toUserIdTable(db).id,
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
        {bool sharedBookId, bool fromUserId, bool toUserId})>;

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
  $$LoansTableTableManager get loans =>
      $$LoansTableTableManager(_db, _db.loans);
}
