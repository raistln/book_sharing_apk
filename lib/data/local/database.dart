import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

class LocalUsers extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get uuid => text().withLength(min: 1, max: 36).unique()();
  TextColumn get username => text().withLength(min: 3, max: 64).unique()();
  TextColumn get remoteId => text().nullable()();

  BoolColumn get isDirty => boolean().withDefault(const Constant(true))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class Books extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get uuid => text().withLength(min: 1, max: 36).unique()();
  TextColumn get remoteId => text().nullable()();

  @ReferenceName('ownedBooks')
  IntColumn get ownerUserId => integer().references(LocalUsers, #id).nullable()();
  TextColumn get ownerRemoteId => text().nullable()();

  TextColumn get title => text().withLength(min: 1, max: 255)();
  TextColumn get author => text().withLength(min: 1, max: 255).nullable()();
  TextColumn get isbn => text().withLength(min: 10, max: 20).nullable()();
  TextColumn get barcode => text().withLength(min: 1, max: 64).nullable()();

  TextColumn get coverPath => text().nullable()();

  TextColumn get status => text().withDefault(const Constant('available'))();
  TextColumn get notes => text().nullable()();

  BoolColumn get isDirty => boolean().withDefault(const Constant(true))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class BookReviews extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get uuid => text().withLength(min: 1, max: 36).unique()();
  TextColumn get remoteId => text().nullable()();

  IntColumn get bookId =>
      integer().references(Books, #id, onDelete: KeyAction.cascade)();
  TextColumn get bookUuid => text().withLength(min: 1, max: 36)();

  IntColumn get authorUserId => integer().references(LocalUsers, #id)();
  TextColumn get authorRemoteId => text().nullable()();

  IntColumn get rating =>
      integer().customConstraint('NOT NULL CHECK (rating BETWEEN 1 AND 5)')();
  TextColumn get review => text().nullable()();

  BoolColumn get isDirty => boolean().withDefault(const Constant(true))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column<Object>>>? get uniqueKeys => [
        {bookId, authorUserId},
      ];
}

class Groups extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get uuid => text().withLength(min: 1, max: 36).unique()();
  TextColumn get remoteId => text().nullable()();

  TextColumn get name => text().withLength(min: 1, max: 128)();
  TextColumn get description => text().nullable().withLength(min: 0, max: 512)();

  IntColumn get ownerUserId => integer().references(LocalUsers, #id).nullable()();
  TextColumn get ownerRemoteId => text().nullable()();

  BoolColumn get isDirty => boolean().withDefault(const Constant(true))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class GroupMembers extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get uuid => text().withLength(min: 1, max: 36).unique()();
  TextColumn get remoteId => text().nullable()();

  IntColumn get groupId =>
      integer().references(Groups, #id, onDelete: KeyAction.cascade)();
  TextColumn get groupUuid => text().withLength(min: 1, max: 36)();

  @ReferenceName('groupMemberships')
  IntColumn get memberUserId => integer().references(LocalUsers, #id)();
  TextColumn get memberRemoteId => text().nullable()();

  TextColumn get role => text().withDefault(const Constant('member'))();

  BoolColumn get isDirty => boolean().withDefault(const Constant(true))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column<Object>>>? get uniqueKeys => [
        {groupId, memberUserId},
      ];
}

class SharedBooks extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get uuid => text().withLength(min: 1, max: 36).unique()();
  TextColumn get remoteId => text().nullable()();

  IntColumn get groupId =>
      integer().references(Groups, #id, onDelete: KeyAction.cascade)();
  TextColumn get groupUuid => text().withLength(min: 1, max: 36)();

  IntColumn get bookId =>
      integer().references(Books, #id, onDelete: KeyAction.cascade)();
  TextColumn get bookUuid => text().withLength(min: 1, max: 36)();

  @ReferenceName('sharedBooksOwned')
  IntColumn get ownerUserId => integer().references(LocalUsers, #id)();
  TextColumn get ownerRemoteId => text().nullable()();

  TextColumn get visibility =>
      text().withDefault(const Constant('group')).withLength(min: 1, max: 32)();
  BoolColumn get isAvailable =>
      boolean().withDefault(const Constant(true))();

  BoolColumn get isDirty => boolean().withDefault(const Constant(true))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class GroupInvitations extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get uuid => text().withLength(min: 1, max: 36).unique()();
  TextColumn get remoteId => text().nullable()();

  IntColumn get groupId =>
      integer().references(Groups, #id, onDelete: KeyAction.cascade)();
  TextColumn get groupUuid => text().withLength(min: 1, max: 36)();

  @ReferenceName('groupInvitationsSent')
  IntColumn get inviterUserId => integer().references(LocalUsers, #id)();
  TextColumn get inviterRemoteId => text().nullable()();

  @ReferenceName('groupInvitationsAccepted')
  IntColumn get acceptedUserId => integer().references(LocalUsers, #id).nullable()();
  TextColumn get acceptedUserRemoteId => text().nullable()();

  TextColumn get role =>
      text().withDefault(const Constant('member')).withLength(min: 1, max: 32)();

  TextColumn get code => text().withLength(min: 1, max: 64).unique()();
  TextColumn get status =>
      text().withDefault(const Constant('pending')).withLength(min: 1, max: 32)();

  DateTimeColumn get expiresAt => dateTime()();
  DateTimeColumn get respondedAt => dateTime().nullable()();

  BoolColumn get isDirty => boolean().withDefault(const Constant(true))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class Loans extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get uuid => text().withLength(min: 1, max: 36).unique()();
  TextColumn get remoteId => text().nullable()();

  IntColumn get sharedBookId => integer()
      .references(SharedBooks, #id, onDelete: KeyAction.cascade)();
  TextColumn get sharedBookUuid => text().withLength(min: 1, max: 36)();

  @ReferenceName('loansRequested')
  IntColumn get fromUserId => integer().references(LocalUsers, #id)();
  TextColumn get fromRemoteId => text().nullable()();

  @ReferenceName('loansReceived')
  IntColumn get toUserId => integer().references(LocalUsers, #id)();
  TextColumn get toRemoteId => text().nullable()();

  TextColumn get status => text()
      .withDefault(const Constant('pending'))
      .withLength(min: 1, max: 32)();

  DateTimeColumn get startDate =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get dueDate => dateTime().nullable()();
  DateTimeColumn get returnedAt => dateTime().nullable()();
  DateTimeColumn get cancelledAt => dateTime().nullable()();

  BoolColumn get isDirty => boolean().withDefault(const Constant(true))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(
  tables: [
    LocalUsers,
    Books,
    BookReviews,
    Groups,
    GroupMembers,
    SharedBooks,
    GroupInvitations,
    Loans,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.test(super.executor);

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 3) {
            await customStatement('DROP TABLE IF EXISTS book_reviews');
            await customStatement('DROP TABLE IF EXISTS books');

            await m.createTable(localUsers);
            await m.createTable(books);
            await m.createTable(bookReviews);
          } else if (from < 4) {
            await customStatement('DROP TABLE IF EXISTS book_reviews');
            await m.createTable(bookReviews);
          }

          if (from < 5) {
            await m.createTable(groups);
            await m.createTable(groupMembers);
            await m.createTable(sharedBooks);
            await m.createTable(loans);
          }

          if (from < 6) {
            await m.addColumn(groups, groups.description);
            await m.createTable(groupInvitations);
          }
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final dbFile = File(p.join(dir.path, 'book_sharing.sqlite'));
    return NativeDatabase.createInBackground(dbFile);
  });
}
