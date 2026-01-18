// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_dao.dart';

// ignore_for_file: type=lint
mixin _$GroupDaoMixin on DatabaseAccessor<AppDatabase> {
  $LocalUsersTable get localUsers => attachedDatabase.localUsers;
  $GroupsTable get groups => attachedDatabase.groups;
  $GroupMembersTable get groupMembers => attachedDatabase.groupMembers;
  $BooksTable get books => attachedDatabase.books;
  $SharedBooksTable get sharedBooks => attachedDatabase.sharedBooks;
  $LoansTable get loans => attachedDatabase.loans;
  $GroupInvitationsTable get groupInvitations =>
      attachedDatabase.groupInvitations;
  GroupDaoManager get managers => GroupDaoManager(this);
}

class GroupDaoManager {
  final _$GroupDaoMixin _db;
  GroupDaoManager(this._db);
  $$LocalUsersTableTableManager get localUsers =>
      $$LocalUsersTableTableManager(_db.attachedDatabase, _db.localUsers);
  $$GroupsTableTableManager get groups =>
      $$GroupsTableTableManager(_db.attachedDatabase, _db.groups);
  $$GroupMembersTableTableManager get groupMembers =>
      $$GroupMembersTableTableManager(_db.attachedDatabase, _db.groupMembers);
  $$BooksTableTableManager get books =>
      $$BooksTableTableManager(_db.attachedDatabase, _db.books);
  $$SharedBooksTableTableManager get sharedBooks =>
      $$SharedBooksTableTableManager(_db.attachedDatabase, _db.sharedBooks);
  $$LoansTableTableManager get loans =>
      $$LoansTableTableManager(_db.attachedDatabase, _db.loans);
  $$GroupInvitationsTableTableManager get groupInvitations =>
      $$GroupInvitationsTableTableManager(
          _db.attachedDatabase, _db.groupInvitations);
}
