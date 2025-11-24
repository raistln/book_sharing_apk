import 'package:drift/drift.dart';

import 'database.dart';

part 'group_dao.g.dart';

class GroupMemberDetail {
  GroupMemberDetail({required this.membership, required this.user});

  final GroupMember membership;
  final LocalUser? user;
}

class SharedBookDetail {
  SharedBookDetail({required this.sharedBook, required this.book});

  final SharedBook sharedBook;
  final Book? book;
}

class LoanDetail {
  LoanDetail({
    required this.loan,
    required this.sharedBook,
    required this.book,
    this.borrower,
    this.owner,
  });

  final Loan loan;
  final SharedBook? sharedBook;
  final Book? book;
  final LocalUser? borrower;
  final LocalUser? owner;
}

class GroupInvitationDetail {
  GroupInvitationDetail({
    required this.invitation,
    this.inviter,
    this.acceptedUser,
  });

  final GroupInvitation invitation;
  final LocalUser? inviter;
  final LocalUser? acceptedUser;
}

@DriftAccessor(tables: [
  Groups,
  GroupMembers,
  SharedBooks,
  Loans,
  Books,
  LocalUsers,
  GroupInvitations,
])
class GroupDao extends DatabaseAccessor<AppDatabase> with _$GroupDaoMixin {
  GroupDao(super.db);

  // Groups ---------------------------------------------------------------
  Stream<List<Group>> watchActiveGroups() {
    return (select(groups)
          ..where((tbl) => tbl.isDeleted.equals(false) | tbl.isDeleted.isNull()))
        .watch();
  }

  Stream<List<Group>> watchGroupsForUser(int userId) {
    final membershipsForUser = alias(groupMembers, 'memberships_for_user');
    final query = select(groups).join([
      leftOuterJoin(
        membershipsForUser,
        membershipsForUser.groupId.equalsExp(groups.id) &
            membershipsForUser.memberUserId.equals(userId) &
            (membershipsForUser.isDeleted.equals(false) |
                membershipsForUser.isDeleted.isNull()),
      ),
    ])
      ..where(
        (groups.isDeleted.equals(false) | groups.isDeleted.isNull()) &
            (groups.ownerUserId.equals(userId) | membershipsForUser.id.isNotNull()),
      );

    return query.watch().map(
      (rows) => rows.map((row) => row.readTable(groups)).toList(growable: false),
    );
  }

  Future<List<Group>> getActiveGroups() {
    return (select(groups)
          ..where((tbl) => tbl.isDeleted.equals(false) | tbl.isDeleted.isNull()))
        .get();
  }

  Future<List<Group>> getGroupsForUser(int userId) {
    final membershipsForUser = alias(groupMembers, 'memberships_for_user_fetch');
    final query = select(groups).join([
      leftOuterJoin(
        membershipsForUser,
        membershipsForUser.groupId.equalsExp(groups.id) &
            membershipsForUser.memberUserId.equals(userId) &
            (membershipsForUser.isDeleted.equals(false) |
                membershipsForUser.isDeleted.isNull()),
      ),
    ])
      ..where(
        (groups.isDeleted.equals(false) | groups.isDeleted.isNull()) &
            (groups.ownerUserId.equals(userId) | membershipsForUser.id.isNotNull()),
      );

    return query.map((row) => row.readTable(groups)).get();
  }

  Future<Group?> findGroupById(int id) {
    return (select(groups)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<Group?> findGroupByRemoteId(String remoteId) {
    return (select(groups)..where((tbl) => tbl.remoteId.equals(remoteId))).getSingleOrNull();
  }

  Future<int> insertGroup(GroupsCompanion entry) => into(groups).insert(entry);

  Future<bool> updateGroup(GroupsCompanion entry) => update(groups).replace(entry);

  Future<int> updateGroupFields({required int groupId, required GroupsCompanion entry}) {
    return (update(groups)..where((tbl) => tbl.id.equals(groupId))).write(entry);
  }

  Future<void> softDeleteGroup({required int groupId, required DateTime timestamp}) {
    return (update(groups)..where((tbl) => tbl.id.equals(groupId))).write(
      GroupsCompanion(
        isDeleted: const Value(true),
        isDirty: const Value(true),
        updatedAt: Value(timestamp),
      ),
    );
  }

  // Group members -------------------------------------------------------
  Stream<List<GroupMember>> watchMembers(int groupId) {
    return (select(groupMembers)
          ..where((tbl) =>
              tbl.groupId.equals(groupId) &
              (tbl.isDeleted.equals(false) | tbl.isDeleted.isNull())))
        .watch();
  }

  Stream<List<GroupMemberDetail>> watchMemberDetails(int groupId) {
    final query = select(groupMembers).join([
      leftOuterJoin(localUsers, localUsers.id.equalsExp(groupMembers.memberUserId)),
    ])
      ..where(groupMembers.groupId.equals(groupId) &
          (groupMembers.isDeleted.equals(false) | groupMembers.isDeleted.isNull()));

    return query.watch().map(
      (rows) => rows
          .map(
            (row) => GroupMemberDetail(
              membership: row.readTable(groupMembers),
              user: row.readTableOrNull(localUsers),
            ),
          )
          .toList(),
    );
  }

  Future<GroupMember?> findMember({required int groupId, required int userId}) {
    return (select(groupMembers)
          ..where((tbl) =>
              tbl.groupId.equals(groupId) &
              tbl.memberUserId.equals(userId) &
              (tbl.isDeleted.equals(false) | tbl.isDeleted.isNull())))
        .getSingleOrNull();
  }

  Future<GroupMember?> findMemberIncludingDeleted({required int groupId, required int userId}) {
    return (select(groupMembers)
          ..where((tbl) =>
              tbl.groupId.equals(groupId) &
              tbl.memberUserId.equals(userId)))
        .getSingleOrNull();
  }

  Future<GroupMember?> findMemberByRemoteId(String remoteId) {
    return (select(groupMembers)..where((tbl) => tbl.remoteId.equals(remoteId))).getSingleOrNull();
  }

  Future<int> insertMember(GroupMembersCompanion entry) => into(groupMembers).insert(entry);

  Future<int> updateMember({required int memberId, required GroupMembersCompanion entry}) {
    return (update(groupMembers)..where((tbl) => tbl.id.equals(memberId))).write(entry);
  }

  Future<int> updateMemberFields({required int memberId, required GroupMembersCompanion entry}) {
    return (update(groupMembers)..where((tbl) => tbl.id.equals(memberId))).write(entry);
  }

  Future<void> softDeleteMember({required int memberId, required DateTime timestamp}) {
    return (update(groupMembers)..where((tbl) => tbl.id.equals(memberId))).write(
      GroupMembersCompanion(
        isDeleted: const Value(true),
        isDirty: const Value(true),
        updatedAt: Value(timestamp),
      ),
    );
  }

  // Shared books --------------------------------------------------------
  Stream<List<SharedBook>> watchSharedBooks(int groupId) {
    return (select(sharedBooks)
          ..where((tbl) =>
              tbl.groupId.equals(groupId) &
              (tbl.isDeleted.equals(false) | tbl.isDeleted.isNull())))
        .watch();
  }

  Stream<List<SharedBookDetail>> watchSharedBookDetails(int groupId) {
    final query = select(sharedBooks).join([
      leftOuterJoin(books, books.id.equalsExp(sharedBooks.bookId)),
    ])
      ..where(sharedBooks.groupId.equals(groupId) &
          (sharedBooks.isDeleted.equals(false) | sharedBooks.isDeleted.isNull()));

    return query.watch().map(
      (rows) => rows
          .map(
            (row) => SharedBookDetail(
              sharedBook: row.readTable(sharedBooks),
              book: row.readTableOrNull(books),
            ),
          )
          .toList(),
    );
  }

  Future<SharedBook?> findSharedBookByUuid(String uuid) {
    return (select(sharedBooks)
          ..where((tbl) => tbl.uuid.equals(uuid) &
              (tbl.isDeleted.equals(false) | tbl.isDeleted.isNull())))
        .getSingleOrNull();
  }

  Future<SharedBook?> findSharedBookById(int id) {
    return (select(sharedBooks)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<SharedBook?> findSharedBookByRemoteId(String remoteId) {
    return (select(sharedBooks)..where((tbl) => tbl.remoteId.equals(remoteId))).getSingleOrNull();
  }

  Future<int> insertSharedBook(SharedBooksCompanion entry) => into(sharedBooks).insert(entry);

  Future<SharedBook?> findSharedBookByGroupAndBook({
    required int groupId,
    required int bookId,
  }) {
    return (select(sharedBooks)
          ..where(
            (tbl) => tbl.groupId.equals(groupId) & tbl.bookId.equals(bookId),
          ))
        .getSingleOrNull();
  }

  Future<List<SharedBook>> findSharedBooksByBookId(int bookId) {
    return (select(sharedBooks)..where((tbl) => tbl.bookId.equals(bookId))).get();
  }

  Future<List<SharedBook>> getDirtySharedBooks() {
    return (select(sharedBooks)..where((tbl) => tbl.isDirty.equals(true))).get();
  }

  Future<List<SharedBookDetail>> fetchSharedBooksPage({
    required int groupId,
    required int limit,
    required int offset,
    bool includeUnavailable = false,
    String? searchQuery,
    int? ownerUserId,
  }) {
    final query = select(sharedBooks).join([
      leftOuterJoin(books, books.id.equalsExp(sharedBooks.bookId)),
    ])
      ..where(
        sharedBooks.groupId.equals(groupId) &
            (sharedBooks.isDeleted.equals(false) | sharedBooks.isDeleted.isNull()),
      );

    if (ownerUserId != null) {
      query.where(sharedBooks.ownerUserId.equals(ownerUserId));
    }

    if (!includeUnavailable) {
      query.where(sharedBooks.isAvailable.equals(true));
    }

    final trimmedQuery = searchQuery?.trim();
    if (trimmedQuery != null && trimmedQuery.isNotEmpty) {
      final pattern = '%${trimmedQuery.replaceAll('%', '').replaceAll('_', '')}%';
      query.where(
        books.title.like(pattern) |
            books.author.like(pattern) |
            books.isbn.like(pattern),
      );
    }

    query
      ..orderBy([
        OrderingTerm(expression: books.title.lower()),
        OrderingTerm(expression: sharedBooks.id),
      ])
      ..limit(limit, offset: offset);

    return query.map(
      (row) => SharedBookDetail(
        sharedBook: row.readTable(sharedBooks),
        book: row.readTableOrNull(books),
      ),
    ).get();
  }

  Future<int> updateSharedBook({required int sharedBookId, required SharedBooksCompanion entry}) {
    return (update(sharedBooks)..where((tbl) => tbl.id.equals(sharedBookId))).write(entry);
  }

  Future<int> updateSharedBookFields({required int sharedBookId, required SharedBooksCompanion entry}) {
    return (update(sharedBooks)..where((tbl) => tbl.id.equals(sharedBookId))).write(entry);
  }

  Future<void> softDeleteSharedBook({required int sharedBookId, required DateTime timestamp}) {
    return (update(sharedBooks)..where((tbl) => tbl.id.equals(sharedBookId))).write(
      SharedBooksCompanion(
        isDeleted: const Value(true),
        isDirty: const Value(true),
        updatedAt: Value(timestamp),
      ),
    );
  }

  // Invitations ---------------------------------------------------------
  Stream<List<GroupInvitation>> watchInvitationsForGroup(int groupId) {
    return (select(groupInvitations)
          ..where((tbl) =>
              tbl.groupId.equals(groupId) &
              (tbl.isDeleted.equals(false) | tbl.isDeleted.isNull())))
        .watch();
  }

  Stream<List<GroupInvitationDetail>> watchInvitationDetailsForGroup(int groupId) {
    final acceptedAlias = alias(localUsers, 'accepted_users');
    final inviterAlias = alias(localUsers, 'inviter_users');
    final joined = select(groupInvitations).join([
      leftOuterJoin(inviterAlias, inviterAlias.id.equalsExp(groupInvitations.inviterUserId)),
      leftOuterJoin(
        acceptedAlias,
        acceptedAlias.id.equalsExp(groupInvitations.acceptedUserId),
      ),
    ])
      ..where(groupInvitations.groupId.equals(groupId) &
          groupInvitations.status.equals('pending') &
          (groupInvitations.isDeleted.equals(false) | groupInvitations.isDeleted.isNull()));

    return joined.watch().map(
          (rows) => rows
              .map(
                (row) => GroupInvitationDetail(
                  invitation: row.readTable(groupInvitations),
                  inviter: row.readTableOrNull(inviterAlias),
                  acceptedUser: row.readTableOrNull(acceptedAlias),
                ),
              )
              .toList(),
        );
  }

  Future<GroupInvitation?> findInvitationById(int id) {
    return (select(groupInvitations)
          ..where((tbl) => tbl.id.equals(id) &
              (tbl.isDeleted.equals(false) | tbl.isDeleted.isNull())))
        .getSingleOrNull();
  }

  Future<GroupInvitation?> findInvitationByRemoteId(String remoteId) {
    return (select(groupInvitations)..where((tbl) => tbl.remoteId.equals(remoteId))).getSingleOrNull();
  }

  Future<GroupInvitation?> findInvitationByCode(String code) {
    return (select(groupInvitations)
          ..where((tbl) => tbl.code.equals(code) &
              (tbl.isDeleted.equals(false) | tbl.isDeleted.isNull())))
        .getSingleOrNull();
  }

  Future<int> insertInvitation(GroupInvitationsCompanion entry) =>
      into(groupInvitations).insert(entry);

  Future<int> updateInvitation({required int invitationId, required GroupInvitationsCompanion entry}) {
    return (update(groupInvitations)..where((tbl) => tbl.id.equals(invitationId))).write(entry);
  }

  Future<void> softDeleteInvitation({required int invitationId, required DateTime timestamp}) {
    return (update(groupInvitations)..where((tbl) => tbl.id.equals(invitationId))).write(
      GroupInvitationsCompanion(
        isDeleted: const Value(true),
        isDirty: const Value(true),
        updatedAt: Value(timestamp),
      ),
    );
  }

  Future<void> deleteInvitation({required int invitationId}) {
    return (delete(groupInvitations)..where((tbl) => tbl.id.equals(invitationId))).go();
  }

  // Loans ---------------------------------------------------------------
  Stream<List<Loan>> watchLoansForGroup(int groupId) {
    final query = select(loans).join([
      innerJoin(sharedBooks, sharedBooks.id.equalsExp(loans.sharedBookId)),
    ])
      ..where(sharedBooks.groupId.equals(groupId) &
          (loans.isDeleted.equals(false) | loans.isDeleted.isNull()));

    return query.watch().map((rows) => rows.map((row) => row.readTable(loans)).toList());
  }

  Stream<List<LoanDetail>> watchLoanDetailsForGroup(int groupId) {
    final borrowers = alias(localUsers, 'borrowers');
    final owners = alias(localUsers, 'owners');
    final query = select(loans).join([
      leftOuterJoin(sharedBooks, sharedBooks.id.equalsExp(loans.sharedBookId)),
      leftOuterJoin(books, books.id.equalsExp(sharedBooks.bookId)),
      leftOuterJoin(borrowers, borrowers.id.equalsExp(loans.fromUserId)),
      leftOuterJoin(owners, owners.id.equalsExp(loans.toUserId)),
    ])
      ..where(sharedBooks.groupId.equals(groupId) &
          (loans.isDeleted.equals(false) | loans.isDeleted.isNull()));

    return query.watch().map(
      (rows) => rows
          .map(
            (row) => LoanDetail(
              loan: row.readTable(loans),
              sharedBook: row.readTableOrNull(sharedBooks),
              book: row.readTableOrNull(books),
              borrower: row.readTableOrNull(borrowers),
              owner: row.readTableOrNull(owners),
            ),
          )
          .toList(),
    );
  }

  Future<List<LoanDetail>> getAllLoanDetails() {
    final borrowers = alias(localUsers, 'allBorrowers');
    final owners = alias(localUsers, 'allOwners');
    final query = select(loans).join([
      leftOuterJoin(sharedBooks, sharedBooks.id.equalsExp(loans.sharedBookId)),
      leftOuterJoin(books, books.id.equalsExp(sharedBooks.bookId)),
      leftOuterJoin(borrowers, borrowers.id.equalsExp(loans.fromUserId)),
      leftOuterJoin(owners, owners.id.equalsExp(loans.toUserId)),
    ])
      ..where(loans.isDeleted.equals(false) | loans.isDeleted.isNull());

    return query.map(
      (row) => LoanDetail(
        loan: row.readTable(loans),
        sharedBook: row.readTableOrNull(sharedBooks),
        book: row.readTableOrNull(books),
        borrower: row.readTableOrNull(borrowers),
        owner: row.readTableOrNull(owners),
      ),
    ).get();
  }

  Future<int> insertLoan(LoansCompanion entry) => into(loans).insert(entry);

  Future<int> updateLoan({required int loanId, required LoansCompanion entry}) {
    return (update(loans)..where((tbl) => tbl.id.equals(loanId))).write(entry);
  }

  Future<Loan?> findLoanByRemoteId(String remoteId) {
    return (select(loans)..where((tbl) => tbl.remoteId.equals(remoteId))).getSingleOrNull();
  }

  Future<Loan?> findLoanById(int id) {
    return (select(loans)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<Loan?> findLoanByUuid(String uuid) {
    return (select(loans)..where((tbl) => tbl.uuid.equals(uuid))).getSingleOrNull();
  }

  Future<int> updateLoanFields({required int loanId, required LoansCompanion entry}) {
    return (update(loans)..where((tbl) => tbl.id.equals(loanId))).write(entry);
  }

  Future<int> updateLoanStatus({required int loanId, required LoansCompanion entry}) {
    return (update(loans)..where((tbl) => tbl.id.equals(loanId))).write(entry);
  }

  Future<void> softDeleteLoan({required int loanId, required DateTime timestamp}) {
    return (update(loans)..where((tbl) => tbl.id.equals(loanId))).write(
      LoansCompanion(
        isDeleted: const Value(true),
        isDirty: const Value(true),
        updatedAt: Value(timestamp),
      ),
    );
  }
}
