import 'package:book_sharing_app/data/local/club_dao.dart';
import 'package:book_sharing_app/data/repositories/supabase_club_book_sync_repository.dart';
import 'package:book_sharing_app/services/supabase_club_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockClubDao extends Mock implements ClubDao {}

class _MockSupabaseClubService extends Mock implements SupabaseClubService {}

void main() {
  late _MockClubDao clubDao;
  late _MockSupabaseClubService clubService;
  late SupabaseClubBookSyncRepository repository;

  setUp(() {
    clubDao = _MockClubDao();
    clubService = _MockSupabaseClubService();
    repository = SupabaseClubBookSyncRepository(
      clubDao: clubDao,
      clubService: clubService,
    );
  });

  group('SupabaseClubBookSyncRepository', () {
    test('syncClubBooksForClub completes when no books are provided', () async {
      await expectLater(
        repository.syncClubBooksForClub(
          clubRemoteId: 'club-1',
          remoteBooks: [],
        ),
        completes,
      );
    });
  });
}
