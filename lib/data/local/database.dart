import 'dart:developer' as developer;
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

  TextColumn get pinHash => text().nullable()();
  TextColumn get pinSalt => text().nullable()();
  DateTimeColumn get pinUpdatedAt => dateTime().nullable()();

  BoolColumn get isDirty => boolean().withDefault(const Constant(true))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class InAppNotifications extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get uuid => text().withLength(min: 1, max: 36).unique()();
  TextColumn get type => text().withLength(min: 1, max: 64)();

  @ReferenceName('notificationLoans')
  IntColumn get loanId => integer().nullable().references(Loans, #id)();
  TextColumn get loanUuid => text().nullable()();

  @ReferenceName('notificationSharedBooks')
  IntColumn get sharedBookId => integer().nullable().references(SharedBooks, #id)();
  TextColumn get sharedBookUuid => text().nullable()();

  @ReferenceName('notificationsAuthored')
  IntColumn get actorUserId => integer().nullable().references(LocalUsers, #id)();
  @ReferenceName('notificationsReceived')
  IntColumn get targetUserId => integer().references(LocalUsers, #id)();

  TextColumn get title => text().nullable()();
  TextColumn get message => text().nullable()();
  TextColumn get status =>
      text().withDefault(const Constant('unread')).withLength(min: 1, max: 32)();

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
  
  // Read status
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();

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
      .nullable()
      .references(SharedBooks, #id, onDelete: KeyAction.cascade)();
  
  // Reference to Book for manual loans (when sharedBookId is null)
  IntColumn get bookId => integer().nullable().references(Books, #id, onDelete: KeyAction.cascade)();

  @ReferenceName('loansBorrower')
  IntColumn get borrowerUserId => integer().nullable().references(LocalUsers, #id)();

  @ReferenceName('loansLender')
  IntColumn get lenderUserId => integer().references(LocalUsers, #id)();

  // For manual loans (people without the app)
  TextColumn get externalBorrowerName => text().nullable()();
  TextColumn get externalBorrowerContact => text().nullable()();

  TextColumn get status => text()
      .withDefault(const Constant('requested'))
      .withLength(min: 1, max: 32)();

  DateTimeColumn get requestedAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get approvedAt => dateTime().nullable()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  
  // Double-confirmation for returns
  DateTimeColumn get borrowerReturnedAt => dateTime().nullable()();
  DateTimeColumn get lenderReturnedAt => dateTime().nullable()();
  DateTimeColumn get returnedAt => dateTime().nullable()();

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
    InAppNotifications,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.test(super.executor);

  @override
  int get schemaVersion => 13;

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
            // Verificar si la columna description ya existe antes de agregarla
            try {
              await m.addColumn(groups, groups.description);
            } catch (e) {
              // La columna ya existe, continuar
            }
            await m.createTable(groupInvitations);
          }

          if (from < 7) {
            await customStatement(
              'ALTER TABLE local_users ADD COLUMN pin_hash TEXT',
            ).catchError((_) {});
            await customStatement(
              'ALTER TABLE local_users ADD COLUMN pin_salt TEXT',
            ).catchError((_) {});
            await customStatement(
              'ALTER TABLE local_users ADD COLUMN pin_updated_at TIMESTAMP',
            ).catchError((_) {});
          }

          if (from < 8) {
            await m.createTable(inAppNotifications);
          }

          if (from < 9) {
            await m.addColumn(loans, loans.externalBorrowerName);
            await m.addColumn(loans, loans.externalBorrowerContact);
            // Note: Changing fromUserId to nullable is a schema change that Drift handles
            // but SQLite doesn't support ALTER COLUMN easily.
            // For now, we assume existing data is fine.
            // If strict null checks are enforced by SQLite, we might need a more complex migration
            // (create new table, copy data, drop old), but for adding nullable columns, addColumn is enough.
          }

          if (from < 10) {
            // Already handled or no longer needed as LoanNotifications is dropped
          }

          if (from < 11) {
            // Add isRead column to Books table
            await m.addColumn(books, books.isRead);
          }

          if (from < 12) {
            // Fix for missing borrowerUserId column in Loans table
            // This column might be missing if a previous migration (around v9) was incomplete
            try {
              await m.addColumn(loans, loans.borrowerUserId);
            } catch (e) {
              // Column might already exist, ignore error
              developer.log('Column borrowerUserId already exists or could not be added: $e');
            }
          }

          if (from < 13) {
            // Migration to v13: Allow manual loans without sharedBookId
            // 1. Add bookId column to Loans
            // 2. Make sharedBookId nullable (Requires table recreation in SQLite)
            
            // Drop dependent tables first to avoid FK violations during recreation
            await customStatement('DROP TABLE IF EXISTS loans');
            
            await m.createTable(loans);
          }
        },
      );

  /// Clears all data from the database (for logout/reset)
  Future<void> clearAllData() async {
    await transaction(() async {
      // Delete in reverse order of dependencies
      await delete(inAppNotifications).go();
      await delete(loans).go();
      await delete(groupInvitations).go();
      await delete(sharedBooks).go();
      await delete(groupMembers).go();
      await delete(groups).go();
      await delete(bookReviews).go();
      await delete(books).go();
      await delete(localUsers).go();
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(dir.path, 'book_sharing.sqlite');
    assert(() {
      developer.log('Opening local database at $dbPath', name: 'AppDatabase');
      return true;
    }());
    final dbFile = File(dbPath);
    return NativeDatabase.createInBackground(dbFile);
  });
}
