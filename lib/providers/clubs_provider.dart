import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'sync_providers.dart';
import '../data/local/club_dao.dart';
import '../data/local/database.dart';
import '../services/club_service.dart';
import '../services/book_proposal_service.dart';
import '../services/section_comment_service.dart';
import 'book_providers.dart';

// DAO Provider
final clubDaoProvider = Provider<ClubDao>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return ClubDao(database);
});

final userClubsProvider = StreamProvider.autoDispose<List<ReadingClub>>((ref) {
  final activeUserAsync = ref.watch(activeUserProvider);
  final dao = ref.watch(clubDaoProvider);

  return activeUserAsync.when<Stream<List<ReadingClub>>>(
    data: (user) {
      if (user?.remoteId == null) {
        return Stream.value(const <ReadingClub>[]);
      }
      return dao.watchUserClubs(user!.remoteId!);
    },
    loading: () => Stream.value(const <ReadingClub>[]),
    error: (_, __) => Stream.value(const <ReadingClub>[]),
  );
});

// Service Providers
final clubServiceProvider = Provider<ClubService>((ref) {
  return ClubService(
    dao: ref.watch(clubDaoProvider),
    syncCoordinator: ref.watch(unifiedSyncCoordinatorProvider),
  );
});

final bookProposalServiceProvider = Provider<BookProposalService>((ref) {
  return BookProposalService(
    dao: ref.watch(clubDaoProvider),
    syncCoordinator: ref.watch(unifiedSyncCoordinatorProvider),
  );
});

final sectionCommentServiceProvider = Provider<SectionCommentService>((ref) {
  return SectionCommentService(
    dao: ref.watch(clubDaoProvider),
    syncCoordinator: ref.watch(unifiedSyncCoordinatorProvider),
  );
});

// Club members with user details
final clubMembersProvider =
    StreamProvider.family<List<ClubMemberWithUser>, String>((ref, clubUuid) {
  final dao = ref.watch(clubDaoProvider);
  return dao.watchClubMembersWithDetails(clubUuid);
});

final activeClubBooksProvider =
    StreamProvider.family<List<ClubBook>, String>((ref, clubUuid) {
  final dao = ref.watch(clubDaoProvider);
  return dao.watchClubBooks(clubUuid);
});

final activeClubBookDetailsProvider =
    StreamProvider.family<ClubBookWithDetails?, String>((ref, clubUuid) {
  final dao = ref.watch(clubDaoProvider);
  return dao.watchActiveClubBookWithDetails(clubUuid);
});

final clubBookQueueProvider =
    StreamProvider.family<List<ClubBookWithDetails>, String>((ref, clubUuid) {
  final dao = ref.watch(clubDaoProvider);
  return dao.watchClubBooksWithDetails(clubUuid);
});

final activeBookUserProgressProvider =
    StreamProvider.family<ClubReadingProgressData?, String>((ref, clubUuid) {
  final activeBookAsync = ref.watch(activeClubBookDetailsProvider(clubUuid));
  final userAsync = ref.watch(activeUserProvider);

  return activeBookAsync.when(
    data: (details) {
      if (details == null) return Stream.value(null);

      return userAsync.when(
        data: (user) {
          if (user == null || user.remoteId == null) return Stream.value(null);
          final dao = ref.watch(clubDaoProvider);
          return dao.watchUserProgress(
              clubUuid, details.book.uuid, user.remoteId!);
        },
        loading: () => Stream.value(null),
        error: (_, __) => Stream.value(null),
      );
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});

final clubProposalsProvider =
    StreamProvider.family<List<BookProposal>, String>((ref, clubUuid) {
  final dao = ref.watch(clubDaoProvider);
  return dao.watchActiveProposals(clubUuid);
});

final sectionCommentsProvider = StreamProvider.family<List<CommentWithUser>,
    ({String clubUuid, String? bookUuid, int sectionNumber})>((ref, params) {
  final dao = ref.watch(clubDaoProvider);
  return dao.watchSectionComments(
    params.clubUuid,
    params.bookUuid,
    params.sectionNumber,
  );
});
