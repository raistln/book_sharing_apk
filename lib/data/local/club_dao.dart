import 'package:drift/drift.dart';

import 'database.dart';

part 'club_dao.g.dart';

@DriftAccessor(tables: [
  ClubMembers,
  ClubBooks,
  ClubReadingProgress,
  ReadingClubs,
  BookProposals,
  Books,
  SectionComments,
  CommentReports,
  ModerationLogs,
  LocalUsers,
])
class ClubDao extends DatabaseAccessor<AppDatabase> with _$ClubDaoMixin {
  ClubDao(super.db);

  // =====================================================================
  // READING CLUBS
  // =====================================================================

  /// Stream all non-deleted clubs where the user is a member
  Stream<List<ReadingClub>> watchUserClubs(String userUuid) {
    return (select(readingClubs)
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([
            (t) => OrderingTerm.desc(t.createdAt),
          ]))
        .join([
          innerJoin(
            clubMembers,
            clubMembers.clubId.equalsExp(readingClubs.id) &
                clubMembers.memberRemoteId.equals(userUuid) &
                clubMembers.isDeleted.equals(false),
          ),
        ])
        .map((row) => row.readTable(readingClubs))
        .watch();
  }

  /// Get a single club by UUID
  Future<ReadingClub?> getClubByUuid(String clubUuid) {
    return (select(readingClubs)
          ..where((t) => t.uuid.equals(clubUuid) & t.isDeleted.equals(false)))
        .getSingleOrNull();
  }

  /// Stream a single club by UUID
  Stream<ReadingClub?> watchClubByUuid(String clubUuid) {
    return (select(readingClubs)
          ..where((t) => t.uuid.equals(clubUuid) & t.isDeleted.equals(false)))
        .watchSingleOrNull();
  }

  /// Insert or update a club
  Future<void> upsertClub(ReadingClubsCompanion club) {
    return into(readingClubs).insertOnConflictUpdate(club);
  }

  /// Soft delete a club
  Future<void> deleteClub(String clubUuid) {
    return (update(readingClubs)..where((t) => t.uuid.equals(clubUuid)))
        .write(ReadingClubsCompanion(
      isDeleted: const Value(true),
      updatedAt: Value(DateTime.now()),
    ));
  }

  // =====================================================================
  // CLUB MEMBERS
  // =====================================================================

  /// Stream all active members of a club
  Stream<List<ClubMember>> watchClubMembers(String clubUuid) {
    return (select(clubMembers)
          ..where(
              (t) => t.clubUuid.equals(clubUuid) & t.isDeleted.equals(false))
          ..orderBy([
            (t) => OrderingTerm.asc(t.role), // Owner/admin first
            (t) => OrderingTerm.desc(t.lastActivity),
          ]))
        .watch();
  }

  /// Get a specific member by club UUID and user UUID
  Future<ClubMember?> getClubMember(String clubUuid, String userUuid) {
    return (select(clubMembers)
          ..where((t) =>
              t.clubUuid.equals(clubUuid) &
              t.memberRemoteId.equals(userUuid) &
              t.isDeleted.equals(false)))
        .getSingleOrNull();
  }

  /// Insert or update a club member
  Future<void> upsertClubMember(ClubMembersCompanion member) {
    return into(clubMembers).insertOnConflictUpdate(member);
  }

  /// Soft delete a member (kick/leave)
  Future<void> removeClubMember(String clubUuid, String userUuid) {
    return (update(clubMembers)
          ..where((t) =>
              t.clubUuid.equals(clubUuid) & t.memberRemoteId.equals(userUuid)))
        .write(ClubMembersCompanion(
      isDeleted: const Value(true),
      updatedAt: Value(DateTime.now()),
    ));
  }

  /// Update member's last activity timestamp
  Future<void> updateMemberActivity(String clubUuid, String userUuid) {
    return (update(clubMembers)
          ..where((t) =>
              t.clubUuid.equals(clubUuid) & t.memberRemoteId.equals(userUuid)))
        .write(ClubMembersCompanion(
      lastActivity: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    ));
  }

  /// Mark member as inactive (used after missing a whole book)
  Future<void> markMemberInactive(String clubUuid, String userUuid) {
    return (update(clubMembers)
          ..where((t) =>
              t.clubUuid.equals(clubUuid) & t.memberRemoteId.equals(userUuid)))
        .write(ClubMembersCompanion(
      status: const Value('inactivo'),
      updatedAt: Value(DateTime.now()),
    ));
  }

  // =====================================================================
  // CLUB BOOKS
  // =====================================================================

  /// Stream all books for a club, ordered by position
  Stream<List<ClubBook>> watchClubBooks(String clubUuid) {
    return (select(clubBooks)
          ..where(
              (t) => t.clubUuid.equals(clubUuid) & t.isDeleted.equals(false))
          ..orderBy([
            (t) => OrderingTerm.asc(t.orderPosition),
          ]))
        .watch();
  }

  Future<ClubBook?> getCurrentBook(String clubUuid) {
    return (select(clubBooks)
          ..where((t) =>
              t.clubUuid.equals(clubUuid) &
              t.status.equals('activo') &
              t.isDeleted.equals(false)))
        .getSingleOrNull();
  }

  /// Get a book by its UUID
  Future<ClubBook?> getClubBookByUuid(String bookUuid) {
    return (select(clubBooks)..where((t) => t.uuid.equals(bookUuid)))
        .getSingleOrNull();
  }

  /// Stream the current active book for a club
  Stream<ClubBook?> watchCurrentBook(String clubUuid) {
    return (select(clubBooks)
          ..where((t) =>
              t.clubUuid.equals(clubUuid) &
              t.status.equals('activo') &
              t.isDeleted.equals(false)))
        .watchSingleOrNull();
  }

  /// Get upcoming books (status 'proximo')
  Future<List<ClubBook>> getUpcomingBooks(String clubUuid, int limit) {
    return (select(clubBooks)
          ..where((t) =>
              t.clubUuid.equals(clubUuid) &
              t.status.equals('proximo') &
              t.isDeleted.equals(false))
          ..orderBy([
            (t) => OrderingTerm.asc(t.orderPosition),
          ])
          ..limit(limit))
        .get();
  }

  /// Get completed books history
  Stream<List<ClubBook>> watchCompletedBooks(String clubUuid) {
    return (select(clubBooks)
          ..where((t) =>
              t.clubUuid.equals(clubUuid) &
              t.status.equals('completado') &
              t.isDeleted.equals(false))
          ..orderBy([
            (t) => OrderingTerm.desc(t.endDate),
          ]))
        .watch();
  }

  /// Insert or update a club book
  Future<void> upsertClubBook(ClubBooksCompanion book) {
    return into(clubBooks).insertOnConflictUpdate(book);
  }

  // =====================================================================
  // READING PROGRESS
  // =====================================================================

  /// Stream all progress entries for a specific book in a club
  Stream<List<ClubReadingProgressData>> watchBookProgress(
      String clubUuid, String bookUuid) {
    return (select(clubReadingProgress)
          ..where(
              (t) => t.clubUuid.equals(clubUuid) & t.bookUuid.equals(bookUuid))
          ..orderBy([
            (t) => OrderingTerm.desc(t.currentSection),
            (t) => OrderingTerm.desc(t.currentChapter),
          ]))
        .watch();
  }

  /// Get user's progress for a specific book in a club
  Future<ClubReadingProgressData?> getUserProgress(
      String clubUuid, String bookUuid, String userUuid) {
    return (select(clubReadingProgress)
          ..where((t) =>
              t.clubUuid.equals(clubUuid) &
              t.bookUuid.equals(bookUuid) &
              t.userRemoteId.equals(userUuid)))
        .getSingleOrNull();
  }

  /// Stream user's progress for a specific book in a club
  Stream<ClubReadingProgressData?> watchUserProgress(
      String clubUuid, String bookUuid, String userUuid) {
    return (select(clubReadingProgress)
          ..where((t) =>
              t.clubUuid.equals(clubUuid) &
              t.bookUuid.equals(bookUuid) &
              t.userRemoteId.equals(userUuid)))
        .watchSingleOrNull();
  }

  /// Insert or update reading progress
  Future<void> upsertProgress(ClubReadingProgressCompanion progress) {
    return into(clubReadingProgress).insertOnConflictUpdate(progress);
  }

  // =====================================================================
  // BOOK PROPOSALS
  // =====================================================================

  /// Stream all active proposals for a club
  Stream<List<BookProposal>> watchActiveProposals(String clubUuid) {
    return (select(bookProposals)
          ..where((t) =>
              t.clubUuid.equals(clubUuid) &
              t.status.equals('abierta') &
              t.isDeleted.equals(false))
          ..orderBy([
            (t) => OrderingTerm.desc(t.voteCount),
            (t) => OrderingTerm.asc(t.createdAt),
          ]))
        .watch();
  }

  /// Get a proposal by UUID
  Future<BookProposal?> getProposalByUuid(String proposalUuid) {
    return (select(bookProposals)
          ..where(
              (t) => t.uuid.equals(proposalUuid) & t.isDeleted.equals(false)))
        .getSingleOrNull();
  }

  /// Insert or update a proposal
  Future<void> upsertProposal(BookProposalsCompanion proposal) {
    return into(bookProposals).insertOnConflictUpdate(proposal);
  }

  /// Close a proposal (update status)
  Future<void> closeProposal(String proposalUuid, String newStatus) {
    return (update(bookProposals)..where((t) => t.uuid.equals(proposalUuid)))
        .write(BookProposalsCompanion(
      status: Value(newStatus),
      updatedAt: Value(DateTime.now()),
    ));
  }

  // =====================================================================
  // SECTION COMMENTS
  // =====================================================================

  /// Insert a new comment
  Future<int> insertComment(SectionCommentsCompanion comment) {
    return into(sectionComments).insert(comment);
  }

  /// Soft delete a comment
  Future<void> deleteComment(String commentUuid) {
    return (update(sectionComments)..where((t) => t.uuid.equals(commentUuid)))
        .write(SectionCommentsCompanion(
      deletedAt: Value(DateTime.now()),
    ));
  }

  /// Hide a comment (after reports)
  Future<void> hideComment(String commentUuid) {
    return (update(sectionComments)..where((t) => t.uuid.equals(commentUuid)))
        .write(const SectionCommentsCompanion(
      isHidden: Value(true),
    ));
  }

  /// Increment reports count
  Future<void> incrementCommentReports(String commentUuid) async {
    final comment = await (select(sectionComments)
          ..where((t) => t.uuid.equals(commentUuid)))
        .getSingleOrNull();

    if (comment != null) {
      await (update(sectionComments)..where((t) => t.uuid.equals(commentUuid)))
          .write(SectionCommentsCompanion(
        reportsCount: Value(comment.reportsCount + 1),
      ));
    }
  }

  // =====================================================================
  // COMMENT REPORTS
  // =====================================================================

  /// Insert a report
  Future<void> insertReport(CommentReportsCompanion report) {
    return into(commentReports).insertOnConflictUpdate(report);
  }

  /// Check if user already reported a comment
  Future<bool> hasUserReportedComment(
      String commentUuid, String userUuid) async {
    final report = await (select(commentReports)
          ..where((t) =>
              t.commentUuid.equals(commentUuid) &
              t.reportedByRemoteId.equals(userUuid)))
        .getSingleOrNull();
    return report != null;
  }

  // =====================================================================
  // MODERATION LOGS
  // =====================================================================

  /// Stream moderation logs for a club
  Stream<List<ModerationLog>> watchModerationLogs(String clubUuid, int limit) {
    return (select(moderationLogs)
          ..where((t) => t.clubUuid.equals(clubUuid))
          ..orderBy([
            (t) => OrderingTerm.desc(t.createdAt),
          ])
          ..limit(limit))
        .watch();
  }

  /// Insert a moderation log entry
  Future<void> insertModerationLog(ModerationLogsCompanion log) {
    return into(moderationLogs).insert(log);
  }

  // =====================================================================
  // HELPER METHODS
  // =====================================================================

  /// Get dirty (unsynced) clubs
  Future<List<ReadingClub>> getDirtyClubs() {
    return (select(readingClubs)
          ..where((t) => t.isDirty.equals(true) & t.isDeleted.equals(false)))
        .get();
  }

  /// Mark club as synced
  Future<void> markClubSynced(String clubUuid, [DateTime? syncedAt]) {
    return (update(readingClubs)..where((t) => t.uuid.equals(clubUuid)))
        .write(ReadingClubsCompanion(
      isDirty: const Value(false),
      syncedAt: Value(syncedAt ?? DateTime.now()),
    ));
  }

  /// Get all dirty entities for sync (batch query helper)
  Future<Map<String, dynamic>> getAllDirtyEntities() async {
    return {
      'clubs': await (select(readingClubs)
            ..where((t) => t.isDirty.equals(true)))
          .get(),
      'members': await (select(clubMembers)
            ..where((t) => t.isDirty.equals(true)))
          .get(),
      'books':
          await (select(clubBooks)..where((t) => t.isDirty.equals(true))).get(),
      'progress': await (select(clubReadingProgress)).get(),
      'proposals': await (select(bookProposals)
            ..where((t) => t.isDirty.equals(true)))
          .get(),
      'comments': await (select(sectionComments)
            ..where((t) => t.isDirty.equals(true)))
          .get(),
      'reports': await (select(commentReports)
            ..where((t) => t.isDirty.equals(true)))
          .get(),
      'logs': await (select(moderationLogs)
            ..where((t) => t.isDirty.equals(true)))
          .get(),
    };
  }

  // =====================================================================
  // REMOTE ID LOOKUPS (for sync)
  // =====================================================================

  Future<ReadingClub?> getClubByRemoteId(String remoteId) {
    return (select(readingClubs)..where((t) => t.remoteId.equals(remoteId)))
        .getSingleOrNull();
  }

  Future<ClubMember?> getMemberByRemoteId(String remoteId) {
    return (select(clubMembers)..where((t) => t.remoteId.equals(remoteId)))
        .getSingleOrNull();
  }

  Future<ClubBook?> getClubBookByRemoteId(String remoteId) {
    return (select(clubBooks)..where((t) => t.remoteId.equals(remoteId)))
        .getSingleOrNull();
  }

  // =====================================================================
  // ADDITIONAL COMMENT METHODS
  // =====================================================================

  Future<SectionComment?> getCommentByUuid(String uuid) {
    return (select(sectionComments)..where((t) => t.uuid.equals(uuid)))
        .getSingleOrNull();
  }

  Future<SectionComment?> getCommentByRemoteId(String remoteId) {
    return (select(sectionComments)..where((t) => t.remoteId.equals(remoteId)))
        .getSingleOrNull();
  }

  Future<List<CommentReport>> getReportsByCommentUuid(String uuid) {
    return (select(commentReports)..where((t) => t.commentUuid.equals(uuid)))
        .get();
  }

  Future<CommentReport?> getReportByRemoteId(String remoteId) {
    return (select(commentReports)..where((t) => t.remoteId.equals(remoteId)))
        .getSingleOrNull();
  }

  Future<ModerationLog?> getModerationLogByRemoteId(String remoteId) {
    return (select(moderationLogs)..where((t) => t.remoteId.equals(remoteId)))
        .getSingleOrNull();
  }

  // =====================================================================
  // JOINED QUERIES (UI HELPERS)
  // =====================================================================

  /// Stream active book with full book details
  Stream<ClubBookWithDetails?> watchActiveClubBookWithDetails(String clubUuid) {
    return (select(clubBooks)
          ..where((t) =>
              t.clubUuid.equals(clubUuid) &
              t.status.equals('activo') &
              t.isDeleted.equals(false)))
        .join([
      innerJoin(db.books, db.books.uuid.equalsExp(clubBooks.bookUuid)),
    ]).map((row) {
      return ClubBookWithDetails(
        clubBook: row.readTable(clubBooks),
        book: row.readTable(db.books),
      );
    }).watchSingleOrNull();
  }

  /// Stream members with user details
  Stream<List<ClubMemberWithUser>> watchClubMembersWithDetails(
      String clubUuid) {
    return (select(clubMembers)
          ..where(
              (t) => t.clubUuid.equals(clubUuid) & t.isDeleted.equals(false))
          ..orderBy([
            (t) => OrderingTerm.asc(t.role),
          ]))
        .join([
      innerJoin(localUsers, localUsers.id.equalsExp(clubMembers.memberUserId)),
    ]).map((row) {
      return ClubMemberWithUser(
        member: row.readTable(clubMembers),
        user: row.readTable(localUsers),
      );
    }).watch();
  }

  Stream<List<CommentWithUser>> watchSectionComments(
      String bookUuid, int sectionNumber) {
    return (select(sectionComments)
          ..where((t) =>
              t.bookUuid.equals(bookUuid) &
              t.sectionNumber.equals(sectionNumber) &
              (t.isDeleted.equals(false) | t.isDeleted.isNull()))
          ..orderBy([
            (t) => OrderingTerm.asc(t.createdAt),
          ]))
        .join([
      innerJoin(localUsers, localUsers.id.equalsExp(sectionComments.userId)),
    ]).map((row) {
      return CommentWithUser(
        comment: row.readTable(sectionComments),
        user: row.readTable(localUsers),
      );
    }).watch();
  }
}

class ClubBookWithDetails {
  final ClubBook clubBook;
  final Book book;

  ClubBookWithDetails({required this.clubBook, required this.book});
}

class ClubMemberWithUser {
  final ClubMember member;
  final LocalUser user;

  ClubMemberWithUser({required this.member, required this.user});
}

class CommentWithUser {
  final SectionComment comment;
  final LocalUser user;

  CommentWithUser({required this.comment, required this.user});
}
