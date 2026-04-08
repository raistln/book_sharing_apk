import 'package:book_sharing_app/data/local/book_dao.dart';
import 'package:book_sharing_app/data/local/database.dart';
import 'package:book_sharing_app/data/local/group_dao.dart';
import 'package:book_sharing_app/data/repositories/book_repository.dart';
import 'package:book_sharing_app/models/global_sync_state.dart';
import 'package:book_sharing_app/services/unified_sync_coordinator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uuid/uuid.dart';

class _MockBookDao extends Mock implements BookDao {}

class _MockGroupDao extends Mock implements GroupDao {}

class _MockUnifiedSyncCoordinator extends Mock
    implements UnifiedSyncCoordinator {}

class _MockUuid extends Mock implements Uuid {}

void main() {
  late _MockBookDao bookDao;
  late _MockGroupDao groupDao;
  late _MockUnifiedSyncCoordinator syncCoordinator;
  late _MockUuid uuid;
  late BookRepository repository;

  setUpAll(() {
    registerFallbackValue(const BooksCompanion());
    registerFallbackValue(SyncEntity.books);
  });

  setUp(() {
    bookDao = _MockBookDao();
    groupDao = _MockGroupDao();
    syncCoordinator = _MockUnifiedSyncCoordinator();
    uuid = _MockUuid();

    repository = BookRepository(
      bookDao,
      groupDao: groupDao,
      uuid: uuid,
      syncCoordinator: syncCoordinator,
    );
  });

  group('BookRepository Bookshelf Logic', () {
    final testUser = LocalUser(
      id: 1,
      uuid: 'user-1',
      username: 'test',
      isDirty: false,
      isDeleted: false,
      updatedAt: DateTime.now(),
      createdAt: DateTime.now(),
    );

    test('addBook sets isOnShelf=true if status is finished', () async {
      when(() => uuid.v4()).thenReturn('new-uuid');
      when(() =>
              bookDao.findByIsbn(any(), ownerUserId: any(named: 'ownerUserId')))
          .thenAnswer((_) async => null);
      when(() => bookDao.findByTitleAndAuthor(any(), any(),
              ownerUserId: any(named: 'ownerUserId')))
          .thenAnswer((_) async => null);
      when(() => bookDao.insertBook(any())).thenAnswer((_) async => 1);
      when(() => groupDao.getGroupsForUser(any())).thenAnswer((_) async => []);
      when(() => syncCoordinator.markPendingChanges(any())).thenReturn(null);
      // Mock findById for the auto-share logic if needed
      when(() => bookDao.findById(any())).thenAnswer((_) async => null);

      await repository.addBook(
        title: 'Finished Book',
        owner: testUser,
        readingStatus: 'finished',
      );

      final captured = verify(() => bookDao.insertBook(captureAny()))
          .captured
          .first as BooksCompanion;
      expect(captured.isOnShelf.value, isTrue);
      expect(captured.isOnShelfAt.value, isNotNull);
    });

    test('updateBook sets isOnShelf=true when changing status to finished',
        () async {
      final oldBook = Book(
        id: 1,
        uuid: 'uuid-1',
        title: 'Title',
        readingStatus: 'reading',
        isOnShelf: false,
        status: 'available',
        isRead: false,
        updatedAt: DateTime.now(),
        createdAt: DateTime.now(),
        isPhysical: true,
        isBorrowedExternal: false,
        isDirty: false,
        isDeleted: false,
      );

      final updatedBook = oldBook.copyWith(readingStatus: 'finished');

      when(() => bookDao.findById(1)).thenAnswer((_) async => oldBook);
      when(() => bookDao.updateBook(any())).thenAnswer((_) async => true);
      when(() => groupDao.getGroupsForUser(any())).thenAnswer((_) async => []);
      when(() => syncCoordinator.markPendingChanges(any())).thenReturn(null);

      await repository.updateBook(updatedBook);

      final captured = verify(() => bookDao.updateBook(captureAny()))
          .captured
          .first as BooksCompanion;
      expect(captured.isOnShelf.value, isTrue);
      expect(captured.isOnShelfAt.value, isNotNull);
    });

    test('toggleBookshelfPresence updates the book correctly', () async {
      // Corrected to use updateBookFields as in the implementation
      when(() => bookDao.updateBookFields(
            bookId: any(named: 'bookId'),
            entry: any(named: 'entry'),
          )).thenAnswer((_) async => 1);
      when(() => syncCoordinator.markPendingChanges(any())).thenReturn(null);

      await repository.toggleBookshelfPresence(1, true);

      final verification = verify(() => bookDao.updateBookFields(
            bookId: 1,
            entry: captureAny(named: 'entry'),
          ));
      final captured = verification.captured.first as BooksCompanion;
      expect(captured.isOnShelf.value, isTrue);
      expect(captured.isOnShelfAt.value, isNotNull);
      verify(() => syncCoordinator.markPendingChanges(SyncEntity.books))
          .called(1);
    });
  });
}
