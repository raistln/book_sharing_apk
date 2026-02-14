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
  IntColumn get sharedBookId =>
      integer().nullable().references(SharedBooks, #id)();
  TextColumn get sharedBookUuid => text().nullable()();

  @ReferenceName('notificationsAuthored')
  IntColumn get actorUserId =>
      integer().nullable().references(LocalUsers, #id)();
  @ReferenceName('notificationsReceived')
  IntColumn get targetUserId => integer().references(LocalUsers, #id)();

  TextColumn get title => text().nullable()();
  TextColumn get message => text().nullable()();
  TextColumn get status => text()
      .withDefault(const Constant('unread'))
      .withLength(min: 1, max: 32)();

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
  IntColumn get ownerUserId =>
      integer().references(LocalUsers, #id).nullable()();
  TextColumn get ownerRemoteId => text().nullable()();

  TextColumn get title => text().withLength(min: 1, max: 255)();
  TextColumn get author => text().withLength(min: 1, max: 255).nullable()();
  TextColumn get isbn => text().withLength(min: 10, max: 20).nullable()();
  TextColumn get barcode => text().withLength(min: 1, max: 64).nullable()();

  TextColumn get coverPath => text().nullable()();

  TextColumn get status => text().withDefault(const Constant('available'))();
  TextColumn get description =>
      text().nullable()(); // Renamed from 'notes' - book synopsis/metadata

  // Reading status (expanded from simple isRead boolean)
  TextColumn get readingStatus =>
      text().withDefault(const Constant('pending')).withLength(
          min: 1,
          max:
              32)(); // 'pending', 'reading', 'paused', 'finished', 'abandoned', 'rereading'

  // Legacy read status (derived from readingStatus for backwards compatibility)
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
  DateTimeColumn get readAt => dateTime().nullable()();

  // External loan tracking (when someone lends you a book)
  BoolColumn get isBorrowedExternal =>
      boolean().withDefault(const Constant(false))();
  TextColumn get externalLenderName => text().nullable()();

  // Metadata
  TextColumn get genre => text().nullable()();
  BoolColumn get isPhysical => boolean().withDefault(const Constant(true))();
  IntColumn get pageCount => integer().nullable()();
  IntColumn get publicationYear => integer().nullable()();

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
      integer().customConstraint('NOT NULL CHECK (rating BETWEEN 1 AND 4)')();
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
  TextColumn get description =>
      text().nullable().withLength(min: 0, max: 512)();

  IntColumn get ownerUserId =>
      integer().references(LocalUsers, #id).nullable()();
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
  BoolColumn get isAvailable => boolean().withDefault(const Constant(true))();

  // Metadata
  TextColumn get genre => text().nullable()();

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
  IntColumn get acceptedUserId =>
      integer().references(LocalUsers, #id).nullable()();
  TextColumn get acceptedUserRemoteId => text().nullable()();

  TextColumn get role => text()
      .withDefault(const Constant('member'))
      .withLength(min: 1, max: 32)();

  TextColumn get code => text().withLength(min: 1, max: 64).unique()();
  TextColumn get status => text()
      .withDefault(const Constant('pending'))
      .withLength(min: 1, max: 32)();

  DateTimeColumn get expiresAt => dateTime()();
  DateTimeColumn get respondedAt => dateTime().nullable()();

  BoolColumn get isDirty => boolean().withDefault(const Constant(true))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class ReadingTimelineEntries extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get uuid => text().withLength(min: 1, max: 36).unique()();
  TextColumn get remoteId => text().nullable()();

  IntColumn get bookId =>
      integer().references(Books, #id, onDelete: KeyAction.cascade)();
  TextColumn get bookUuid => text().withLength(min: 1, max: 36).nullable()();

  IntColumn get ownerUserId => integer().references(LocalUsers, #id)();

  // Progress tracking
  IntColumn get currentPage => integer().nullable()();
  IntColumn get percentageRead => integer().nullable()(); // 0-100

  // Event metadata
  TextColumn get eventType => text().withLength(
      min: 1, max: 32)(); // 'start', 'progress', 'pause', 'resume', 'finish'
  TextColumn get note => text().nullable()(); // Optional reader comment

  DateTimeColumn get eventDate => dateTime().withDefault(currentDateAndTime)();

  BoolColumn get isDirty => boolean().withDefault(const Constant(true))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class ReadingClubs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().withLength(min: 1, max: 36).unique()();
  TextColumn get remoteId => text().nullable()();

  TextColumn get name => text().withLength(min: 1, max: 128)();
  TextColumn get description => text().withLength(min: 1, max: 512)();
  TextColumn get city => text().withLength(min: 1, max: 128)();
  TextColumn get meetingPlace => text().nullable().withLength(max: 256)();

  // Frequency configuration
  TextColumn get frequency => text().withLength(
      min: 1, max: 32)(); // 'semanal', 'quincenal', 'mensual', 'personalizada'
  IntColumn get frequencyDays => integer().nullable()();

  // Visibility
  TextColumn get visibility => text()
      .withDefault(const Constant('privado'))
      .withLength(min: 1, max: 32)(); // 'privado', 'publico'

  // UI configuration
  IntColumn get nextBooksVisible => integer().withDefault(const Constant(1))();

  // Relationships
  IntColumn get ownerUserId => integer().references(LocalUsers, #id)();
  TextColumn get ownerRemoteId => text().nullable()();

  IntColumn get currentBookId =>
      integer().nullable()(); // Will reference ClubBooks, added after
  TextColumn get currentBookUuid => text().nullable()();

  BoolColumn get isDirty => boolean().withDefault(const Constant(true))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class ClubMembers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().withLength(min: 1, max: 36).unique()();
  TextColumn get remoteId => text().nullable()();

  IntColumn get clubId =>
      integer().references(ReadingClubs, #id, onDelete: KeyAction.cascade)();
  TextColumn get clubUuid => text().withLength(min: 1, max: 36)();

  @ReferenceName('clubMemberships')
  IntColumn get memberUserId => integer().references(LocalUsers, #id)();
  TextColumn get memberRemoteId => text().nullable()();

  TextColumn get role => text()
      .withDefault(const Constant('miembro'))
      .withLength(min: 1, max: 32)(); // 'dueño', 'admin', 'miembro'
  TextColumn get status => text()
      .withDefault(const Constant('activo'))
      .withLength(min: 1, max: 32)(); // 'activo', 'inactivo'

  DateTimeColumn get joinedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastActivity =>
      dateTime().withDefault(currentDateAndTime)();

  BoolColumn get isDirty => boolean().withDefault(const Constant(true))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column<Object>>>? get uniqueKeys => [
        {clubId, memberUserId},
      ];
}

class ClubBooks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().withLength(min: 1, max: 36).unique()();
  TextColumn get remoteId => text().nullable()();

  IntColumn get clubId =>
      integer().references(ReadingClubs, #id, onDelete: KeyAction.cascade)();
  TextColumn get clubUuid => text().withLength(min: 1, max: 36)();

  // Book reference (UUID from Books table)
  TextColumn get bookUuid => text().withLength(min: 1, max: 36)();

  // Order and status
  IntColumn get orderPosition => integer().withDefault(const Constant(0))();
  TextColumn get status => text()
      .withDefault(const Constant('propuesto'))
      .withLength(min: 1, max: 32)();
  // Status: 'propuesto', 'votando', 'proximo', 'activo', 'completado'

  // Section configuration
  TextColumn get sectionMode => text()
      .withDefault(const Constant('automatico'))
      .withLength(min: 1, max: 32)(); // 'automatico', 'manual'
  IntColumn get totalChapters => integer()();
  TextColumn get sections => text()(); // JSON array of sections

  DateTimeColumn get startDate => dateTime().nullable()();
  DateTimeColumn get endDate => dateTime().nullable()();

  BoolColumn get isDirty => boolean().withDefault(const Constant(true))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class ClubReadingProgress extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().withLength(min: 1, max: 36).unique()();

  IntColumn get clubId =>
      integer().references(ReadingClubs, #id, onDelete: KeyAction.cascade)();
  TextColumn get clubUuid => text().withLength(min: 1, max: 36)();

  IntColumn get bookId =>
      integer().references(ClubBooks, #id, onDelete: KeyAction.cascade)();
  TextColumn get bookUuid => text().withLength(min: 1, max: 36)();

  @ReferenceName('clubProgressUser')
  IntColumn get userId => integer().references(LocalUsers, #id)();
  TextColumn get userRemoteId => text().nullable()();
  TextColumn get remoteId => text().nullable()();

  TextColumn get status => text()
      .withDefault(const Constant('no_empezado'))
      .withLength(min: 1, max: 32)();
  // Status: 'no_empezado', 'al_dia', 'atrasado', 'terminado'

  IntColumn get currentChapter => integer().withDefault(const Constant(0))();
  IntColumn get currentSection => integer().withDefault(const Constant(0))();

  BoolColumn get isDirty => boolean().withDefault(const Constant(true))();
  DateTimeColumn get syncedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column<Object>>>? get uniqueKeys => [
        {clubId, bookId, userId},
      ];
}

class BookProposals extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().withLength(min: 1, max: 36).unique()();
  TextColumn get remoteId => text().nullable()();

  IntColumn get clubId =>
      integer().references(ReadingClubs, #id, onDelete: KeyAction.cascade)();
  TextColumn get clubUuid => text().withLength(min: 1, max: 36)();

  TextColumn get bookUuid => text().withLength(min: 1, max: 36)();

  @ReferenceName('proposalAuthor')
  IntColumn get proposedByUserId => integer().references(LocalUsers, #id)();
  TextColumn get proposedByRemoteId => text().nullable()();

  // Book metadata for the proposal
  TextColumn get title => text().nullable()();
  TextColumn get author => text().nullable()();
  TextColumn get isbn => text().nullable()();
  TextColumn get coverUrl => text().nullable()();
  DateTimeColumn get closingDate => dateTime().nullable()();

  IntColumn get totalChapters => integer()();

  // Voting (stored as comma-separated UUIDs)
  TextColumn get votes =>
      text().withDefault(const Constant(''))(); // CSV of user UUIDs
  IntColumn get voteCount => integer().withDefault(const Constant(0))();

  TextColumn get status => text()
      .withDefault(const Constant('abierta'))
      .withLength(min: 1, max: 32)();
  // Status: 'abierta', 'cerrada', 'ganadora', 'descartada'

  DateTimeColumn get closeDate => dateTime().nullable()();

  BoolColumn get isDirty => boolean().withDefault(const Constant(true))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class SectionComments extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().withLength(min: 1, max: 36).unique()();
  TextColumn get remoteId => text().nullable()();

  IntColumn get clubId =>
      integer().references(ReadingClubs, #id, onDelete: KeyAction.cascade)();
  TextColumn get clubUuid => text().withLength(min: 1, max: 36)();

  IntColumn get bookId =>
      integer().references(ClubBooks, #id, onDelete: KeyAction.cascade)();
  TextColumn get bookUuid => text().withLength(min: 1, max: 36)();

  IntColumn get sectionNumber => integer()();

  @ReferenceName('commentAuthor')
  IntColumn get userId => integer().references(LocalUsers, #id)();
  TextColumn get userRemoteId => text().nullable()();
  TextColumn get authorRemoteId =>
      text().nullable()(); // Alias for userRemoteId for consistency

  TextColumn get content => text()();

  IntColumn get reportsCount => integer().withDefault(const Constant(0))();
  BoolColumn get isHidden => boolean().withDefault(const Constant(false))();

  BoolColumn get isDirty => boolean().withDefault(const Constant(true))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class CommentReports extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().withLength(min: 1, max: 36).unique()();
  TextColumn get remoteId => text().nullable()();

  IntColumn get commentId =>
      integer().references(SectionComments, #id, onDelete: KeyAction.cascade)();
  TextColumn get commentUuid => text().withLength(min: 1, max: 36)();

  @ReferenceName('reportAuthor')
  IntColumn get reportedByUserId => integer().references(LocalUsers, #id)();
  TextColumn get reportedByRemoteId => text().nullable()();

  TextColumn get reason => text().nullable()();

  BoolColumn get isDirty => boolean().withDefault(const Constant(true))();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column<Object>>>? get uniqueKeys => [
        {commentId, reportedByUserId},
      ];
}

class ModerationLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().withLength(min: 1, max: 36).unique()();
  TextColumn get remoteId => text().nullable()();

  IntColumn get clubId =>
      integer().references(ReadingClubs, #id, onDelete: KeyAction.cascade)();
  TextColumn get clubUuid => text().withLength(min: 1, max: 36)();

  TextColumn get action => text().withLength(min: 1, max: 64)();
  // Actions: 'borrar_comentario', 'expulsar_miembro', 'cerrar_votacion', 'ocultar_comentario'

  @ReferenceName('moderationPerformer')
  IntColumn get performedByUserId => integer().references(LocalUsers, #id)();
  TextColumn get performedByRemoteId => text().nullable()();

  TextColumn get targetId => text()
      .withLength(min: 1, max: 36)(); // UUID of target (comment, member, etc.)
  TextColumn get reason => text().nullable()();

  BoolColumn get isDirty => boolean().withDefault(const Constant(true))();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class WishlistItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().withLength(min: 1, max: 36).unique()();

  @ReferenceName('wishlistUser')
  IntColumn get userId => integer().references(LocalUsers, #id)();

  TextColumn get title => text().withLength(min: 1, max: 255)();
  TextColumn get author => text().withLength(min: 1, max: 255).nullable()();
  TextColumn get isbn => text().withLength(min: 10, max: 20).nullable()();
  TextColumn get notes => text().nullable()();

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
  IntColumn get bookId => integer()
      .nullable()
      .references(Books, #id, onDelete: KeyAction.cascade)();

  @ReferenceName('loansBorrower')
  IntColumn get borrowerUserId =>
      integer().nullable().references(LocalUsers, #id)();

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

  // Read tracking for borrowed books
  BoolColumn get wasRead => boolean().nullable()();
  DateTimeColumn get markedReadAt => dateTime().nullable()();

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
    ReadingTimelineEntries,
    Groups,
    GroupMembers,
    SharedBooks,
    GroupInvitations,
    Loans,
    InAppNotifications,
    WishlistItems,
    ReadingClubs,
    ClubMembers,
    ClubBooks,
    ClubReadingProgress,
    BookProposals,
    SectionComments,
    CommentReports,
    ModerationLogs,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.test(super.executor);

  @override
  int get schemaVersion => 23;

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
              developer.log(
                  'Column borrowerUserId already exists or could not be added: $e');
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

          if (from < 14) {
            // Migration to v14: Add readAt column to Books
            await m.addColumn(books, books.readAt);
          }

          if (from < 15) {
            // Migration to v15: Add read tracking fields
            // Books: isBorrowedExternal, externalLenderName
            await m.addColumn(books, books.isBorrowedExternal);
            await m.addColumn(books, books.externalLenderName);

            // Loans: wasRead, markedReadAt
            await m.addColumn(loans, loans.wasRead);
            await m.addColumn(loans, loans.markedReadAt);
          }

          if (from < 16) {
            // Migration to v16: Add genre to SharedBooks
            await m.addColumn(sharedBooks, sharedBooks.genre);
            // Optional: You could backfill genre from Books table here if needed,
            // but since it's a new feature, null is acceptable for existing shared books.
          }

          if (from < 17) {
            // Migration to v17: Add pageCount and publicationYear to Books
            await m.addColumn(books, books.pageCount);
            await m.addColumn(books, books.publicationYear);
          }

          if (from < 18) {
            // Migration to v18: Reading Timeline feature
            // 1. Create ReadingTimelineEntries table
            await m.createTable(readingTimelineEntries);
            // 2. Add readingStatus column to Books
            await m.addColumn(books, books.readingStatus);
            // 3. Migrate existing data: if isRead = true, set readingStatus = 'finished'
            await customStatement(
              "UPDATE books SET reading_status = 'finished' WHERE is_read = 1",
            );
          }

          if (from < 19) {
            // Migration to v19: Add remoteId to ReadingTimelineEntries
            // Wrapped in try-catch because m.createTable at v18 may have
            // already created these columns using the current schema definition.
            try {
              await m.addColumn(
                  readingTimelineEntries, readingTimelineEntries.remoteId);
            } catch (_) {
              // Column already exists from createTable
            }
            try {
              await m.addColumn(
                  readingTimelineEntries, readingTimelineEntries.bookUuid);
            } catch (_) {
              // Column already exists from createTable
            }

            // Migration to v19: Change rating system from 5 stars to 4 levels
            // Map existing ratings: 1-2 -> 1, 3 -> 2, 4 -> 3, 5 -> 4
            await customStatement(
                "UPDATE book_reviews SET rating = 1 WHERE rating IN (1, 2)");
            await customStatement(
                "UPDATE book_reviews SET rating = 2 WHERE rating = 3");
            await customStatement(
                "UPDATE book_reviews SET rating = 3 WHERE rating = 4");
            await customStatement(
                "UPDATE book_reviews SET rating = 4 WHERE rating = 5");
          }

          if (from < 20) {
            // Migration to v20: Add sync fields to ReadingTimelineEntries
            // Wrapped in try-catch: columns may already exist from createTable at v18.
            try {
              await m.addColumn(
                  readingTimelineEntries, readingTimelineEntries.isDirty);
            } catch (_) {}
            try {
              await m.addColumn(
                  readingTimelineEntries, readingTimelineEntries.isDeleted);
            } catch (_) {}
            try {
              await m.addColumn(
                  readingTimelineEntries, readingTimelineEntries.syncedAt);
            } catch (_) {}

            await m.createTable(wishlistItems);
          }

          if (from < 21) {
            // Migration to v21: Book Clubs feature
            await m.createTable(readingClubs);
            await m.createTable(clubMembers);
            await m.createTable(clubBooks);
            await m.createTable(clubReadingProgress);
            await m.createTable(bookProposals);
            await m.createTable(sectionComments);
            await m.createTable(commentReports);
            await m.createTable(moderationLogs);
          }

          // Duplicate from < 21 block removed (was identical to the one above)

          if (from < 23) {
            // Repair migration: retroactively add columns that may be missing
            // due to m.createTable at v18 using current schema, then v19/v20
            // failing with "duplicate column" for users who upgraded through v18.
            await customStatement(
              'ALTER TABLE reading_timeline_entries ADD COLUMN remote_id TEXT',
            ).catchError((_) {});
            await customStatement(
              'ALTER TABLE reading_timeline_entries ADD COLUMN book_uuid TEXT',
            ).catchError((_) {});
            await customStatement(
              'ALTER TABLE reading_timeline_entries ADD COLUMN is_dirty INTEGER NOT NULL DEFAULT 1',
            ).catchError((_) {});
            await customStatement(
              'ALTER TABLE reading_timeline_entries ADD COLUMN is_deleted INTEGER NOT NULL DEFAULT 0',
            ).catchError((_) {});
            await customStatement(
              'ALTER TABLE reading_timeline_entries ADD COLUMN synced_at INTEGER',
            ).catchError((_) {});
          }
        },
      );

  /// Clears all data from the database (for logout/reset)
  Future<void> clearAllData() async {
    await transaction(() async {
      // Delete in reverse order of dependencies
      await delete(inAppNotifications).go();
      await delete(moderationLogs).go();
      await delete(commentReports).go();
      await delete(sectionComments).go();
      await delete(bookProposals).go();
      await delete(clubReadingProgress).go();
      await delete(clubBooks).go();
      await delete(clubMembers).go();
      await delete(readingClubs).go();
      await delete(loans).go();
      await delete(groupInvitations).go();
      await delete(sharedBooks).go();
      await delete(groupMembers).go();
      await delete(groups).go();
      await delete(readingTimelineEntries).go();
      await delete(bookReviews).go();
      await delete(books).go();
      await delete(wishlistItems).go();
      await delete(localUsers).go();
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(dir.path, 'book_sharing_v2.sqlite');
    assert(() {
      developer.log('Opening local database at $dbPath', name: 'AppDatabase');
      return true;
    }());
    final dbFile = File(dbPath);
    return NativeDatabase.createInBackground(dbFile);
  });
}
