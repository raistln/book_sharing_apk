// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'club_dao.dart';

// ignore_for_file: type=lint
mixin _$ClubDaoMixin on DatabaseAccessor<AppDatabase> {
  $LocalUsersTable get localUsers => attachedDatabase.localUsers;
  $ReadingClubsTable get readingClubs => attachedDatabase.readingClubs;
  $ClubMembersTable get clubMembers => attachedDatabase.clubMembers;
  $ClubBooksTable get clubBooks => attachedDatabase.clubBooks;
  $ClubReadingProgressTable get clubReadingProgress =>
      attachedDatabase.clubReadingProgress;
  $BookProposalsTable get bookProposals => attachedDatabase.bookProposals;
  $SectionCommentsTable get sectionComments => attachedDatabase.sectionComments;
  $CommentReportsTable get commentReports => attachedDatabase.commentReports;
  $ModerationLogsTable get moderationLogs => attachedDatabase.moderationLogs;
  ClubDaoManager get managers => ClubDaoManager(this);
}

class ClubDaoManager {
  final _$ClubDaoMixin _db;
  ClubDaoManager(this._db);
  $$LocalUsersTableTableManager get localUsers =>
      $$LocalUsersTableTableManager(_db.attachedDatabase, _db.localUsers);
  $$ReadingClubsTableTableManager get readingClubs =>
      $$ReadingClubsTableTableManager(_db.attachedDatabase, _db.readingClubs);
  $$ClubMembersTableTableManager get clubMembers =>
      $$ClubMembersTableTableManager(_db.attachedDatabase, _db.clubMembers);
  $$ClubBooksTableTableManager get clubBooks =>
      $$ClubBooksTableTableManager(_db.attachedDatabase, _db.clubBooks);
  $$ClubReadingProgressTableTableManager get clubReadingProgress =>
      $$ClubReadingProgressTableTableManager(
          _db.attachedDatabase, _db.clubReadingProgress);
  $$BookProposalsTableTableManager get bookProposals =>
      $$BookProposalsTableTableManager(_db.attachedDatabase, _db.bookProposals);
  $$SectionCommentsTableTableManager get sectionComments =>
      $$SectionCommentsTableTableManager(
          _db.attachedDatabase, _db.sectionComments);
  $$CommentReportsTableTableManager get commentReports =>
      $$CommentReportsTableTableManager(
          _db.attachedDatabase, _db.commentReports);
  $$ModerationLogsTableTableManager get moderationLogs =>
      $$ModerationLogsTableTableManager(
          _db.attachedDatabase, _db.moderationLogs);
}
