// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_dao.dart';

// ignore_for_file: type=lint
mixin _$NotificationDaoMixin on DatabaseAccessor<AppDatabase> {
  $LocalUsersTable get localUsers => attachedDatabase.localUsers;
  $GroupsTable get groups => attachedDatabase.groups;
  $BooksTable get books => attachedDatabase.books;
  $SharedBooksTable get sharedBooks => attachedDatabase.sharedBooks;
  $LoansTable get loans => attachedDatabase.loans;
  $InAppNotificationsTable get inAppNotifications =>
      attachedDatabase.inAppNotifications;
  NotificationDaoManager get managers => NotificationDaoManager(this);
}

class NotificationDaoManager {
  final _$NotificationDaoMixin _db;
  NotificationDaoManager(this._db);
  $$LocalUsersTableTableManager get localUsers =>
      $$LocalUsersTableTableManager(_db.attachedDatabase, _db.localUsers);
  $$GroupsTableTableManager get groups =>
      $$GroupsTableTableManager(_db.attachedDatabase, _db.groups);
  $$BooksTableTableManager get books =>
      $$BooksTableTableManager(_db.attachedDatabase, _db.books);
  $$SharedBooksTableTableManager get sharedBooks =>
      $$SharedBooksTableTableManager(_db.attachedDatabase, _db.sharedBooks);
  $$LoansTableTableManager get loans =>
      $$LoansTableTableManager(_db.attachedDatabase, _db.loans);
  $$InAppNotificationsTableTableManager get inAppNotifications =>
      $$InAppNotificationsTableTableManager(
          _db.attachedDatabase, _db.inAppNotifications);
}
