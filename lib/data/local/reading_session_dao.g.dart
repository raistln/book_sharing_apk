// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_session_dao.dart';

// ignore_for_file: type=lint
mixin _$ReadingSessionDaoMixin on DatabaseAccessor<AppDatabase> {
  $LocalUsersTable get localUsers => attachedDatabase.localUsers;
  $BooksTable get books => attachedDatabase.books;
  $ReadingSessionsTable get readingSessions => attachedDatabase.readingSessions;
  ReadingSessionDaoManager get managers => ReadingSessionDaoManager(this);
}

class ReadingSessionDaoManager {
  final _$ReadingSessionDaoMixin _db;
  ReadingSessionDaoManager(this._db);
  $$LocalUsersTableTableManager get localUsers =>
      $$LocalUsersTableTableManager(_db.attachedDatabase, _db.localUsers);
  $$BooksTableTableManager get books =>
      $$BooksTableTableManager(_db.attachedDatabase, _db.books);
  $$ReadingSessionsTableTableManager get readingSessions =>
      $$ReadingSessionsTableTableManager(
          _db.attachedDatabase, _db.readingSessions);
}
