import 'package:book_sharing_app/data/local/database.dart';
import 'package:book_sharing_app/data/local/wishlist_dao.dart';
import 'package:book_sharing_app/data/repositories/wishlist_repository.dart';
import 'package:book_sharing_app/models/global_sync_state.dart';
import 'package:book_sharing_app/services/unified_sync_coordinator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uuid/uuid.dart';

class _MockWishlistDao extends Mock implements WishlistDao {}

class _MockUnifiedSyncCoordinator extends Mock implements UnifiedSyncCoordinator {}

class _MockUuid extends Mock implements Uuid {}

void main() {
  late _MockWishlistDao wishlistDao;
  late _MockUnifiedSyncCoordinator syncCoordinator;
  late _MockUuid uuid;
  late WishlistRepository repository;

  setUpAll(() {
    registerFallbackValue(const WishlistItemsCompanion());
    registerFallbackValue(SyncEntity.books);
  });

  setUp(() {
    wishlistDao = _MockWishlistDao();
    syncCoordinator = _MockUnifiedSyncCoordinator();
    uuid = _MockUuid();
    repository = WishlistRepository(wishlistDao, uuid: uuid, syncCoordinator: syncCoordinator);
  });

  group('WishlistRepository', () {
    test('watchWishlist delegates to wishlistDao', () {
      final stream = Stream<List<WishlistItem>>.empty();
      when(() => wishlistDao.watchForUser(1)).thenAnswer((_) => stream);

      final result = repository.watchWishlist(1);

      expect(result, stream);
      verify(() => wishlistDao.watchForUser(1)).called(1);
    });

    test('addItem inserts item and marks sync pending', () async {
      when(() => uuid.v4()).thenReturn('test-uuid');
      when(() => wishlistDao.insertItem(any())).thenAnswer((_) async => 1);
      when(() => syncCoordinator.markPendingChanges(any())).thenReturn(null);

      await repository.addItem(
        userId: 1,
        title: 'Test Book',
        author: 'Test Author',
        isbn: '1234567890',
        notes: 'Test Notes',
      );

      verify(() => wishlistDao.insertItem(any())).called(1);
      verify(() => syncCoordinator.markPendingChanges(SyncEntity.books)).called(1);
    });

    test('removeItem deletes item and marks sync pending', () async {
      when(() => wishlistDao.deleteItem(1)).thenAnswer((_) async => true);
      when(() => syncCoordinator.markPendingChanges(any())).thenReturn(null);

      await repository.removeItem(1);

      verify(() => wishlistDao.deleteItem(1)).called(1);
      verify(() => syncCoordinator.markPendingChanges(SyncEntity.books)).called(1);
    });
  });
}
