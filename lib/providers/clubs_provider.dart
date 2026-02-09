import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/club_dao.dart';
import '../../data/local/database.dart';
import '../../services/club_service.dart';
import '../../services/book_proposal_service.dart';
import '../../services/section_comment_service.dart';
import 'book_providers.dart';

// DAO Provider
final clubDaoProvider = Provider<ClubDao>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return ClubDao(database);
});

// Service Providers
final clubServiceProvider = Provider<ClubService>((ref) {
  return ClubService(
    dao: ref.watch(clubDaoProvider),
  );
});

final bookProposalServiceProvider = Provider<BookProposalService>((ref) {
  return BookProposalService(
    dao: ref.watch(clubDaoProvider),
  );
});

final sectionCommentServiceProvider = Provider<SectionCommentService>((ref) {
  return SectionCommentService(
    dao: ref.watch(clubDaoProvider),
  );
});

// Stream Providers for UI
final userClubsProvider = StreamProvider<List<ReadingClub>>((ref) {
  final userAsync = ref.watch(activeUserProvider);
  return userAsync.when(
    data: (user) {
      if (user == null || user.remoteId == null) return Stream.value([]);
      final dao = ref.watch(clubDaoProvider);
      return dao.watchUserClubs(user.remoteId!);
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});

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
    ({String bookUuid, int sectionNumber})>((ref, params) {
  final dao = ref.watch(clubDaoProvider);
  return dao.watchSectionComments(params.bookUuid, params.sectionNumber);
});
