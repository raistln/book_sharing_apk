// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_dao.dart';

// ignore_for_file: type=lint
mixin _$BookDaoMixin on DatabaseAccessor<AppDatabase> {
  $LocalUsersTable get localUsers => attachedDatabase.localUsers;
  $BooksTable get books => attachedDatabase.books;
  $BookReviewsTable get bookReviews => attachedDatabase.bookReviews;
  $GroupsTable get groups => attachedDatabase.groups;
  $SharedBooksTable get sharedBooks => attachedDatabase.sharedBooks;
  $LoansTable get loans => attachedDatabase.loans;
  BookDaoManager get managers => BookDaoManager(this);
}

class BookDaoManager {
  final _$BookDaoMixin _db;
  BookDaoManager(this._db);
  $$LocalUsersTableTableManager get localUsers =>
      $$LocalUsersTableTableManager(_db.attachedDatabase, _db.localUsers);
  $$BooksTableTableManager get books =>
      $$BooksTableTableManager(_db.attachedDatabase, _db.books);
  $$BookReviewsTableTableManager get bookReviews =>
      $$BookReviewsTableTableManager(_db.attachedDatabase, _db.bookReviews);
  $$GroupsTableTableManager get groups =>
      $$GroupsTableTableManager(_db.attachedDatabase, _db.groups);
  $$SharedBooksTableTableManager get sharedBooks =>
      $$SharedBooksTableTableManager(_db.attachedDatabase, _db.sharedBooks);
  $$LoansTableTableManager get loans =>
      $$LoansTableTableManager(_db.attachedDatabase, _db.loans);
}
