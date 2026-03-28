import 'package:book_sharing_app/data/local/book_dao.dart';
import 'package:book_sharing_app/data/local/database.dart';
import 'package:book_sharing_app/data/local/group_dao.dart';
import 'package:book_sharing_app/data/repositories/book_repository.dart';
import 'package:book_sharing_app/models/global_sync_state.dart';
import 'package:book_sharing_app/services/group_sync_controller.dart';
import 'package:book_sharing_app/services/unified_sync_coordinator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uuid/uuid.dart';

class _MockBookDao extends Mock implements BookDao {}

class _MockGroupDao extends Mock implements GroupDao {}

class _MockGroupSyncController extends Mock implements GroupSyncController {}

class _MockUnifiedSyncCoordinator extends Mock implements UnifiedSyncCoordinator {}

class _MockUuid extends Mock implements Uuid {}

void main() {
  late _MockBookDao bookDao;
  late _MockGroupDao groupDao;
  late _MockGroupSyncController groupSyncController;
  late _MockUnifiedSyncCoordinator syncCoordinator;
  late _MockUuid uuid;
  late BookRepository repository;

  LocalUser buildUser({
    int id = 1,
    String? remoteId,
  }) {
    return LocalUser(
      id: id,
      uuid: 'uuid-$id',
      username: 'user$id',
      remoteId: remoteId,
      isDirty: false,
      isDeleted: false,
      syncedAt: null,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now(),
    );
  }

  setUpAll(() {
    registerFallbackValue(const BooksCompanion());
    registerFallbackValue(const SharedBooksCompanion());
    registerFallbackValue(const BookReviewsCompanion());
    registerFallbackValue(SyncEntity.books);
  });

  setUp(() {
    bookDao = _MockBookDao();
    groupDao = _MockGroupDao();
    groupSyncController = _MockGroupSyncController();
    syncCoordinator = _MockUnifiedSyncCoordinator();
    uuid = _MockUuid();

    repository = BookRepository(
      bookDao,
      groupDao: groupDao,
      groupSyncController: groupSyncController,
      uuid: uuid,
      syncCoordinator: syncCoordinator,
    );
  });

  group('BookRepository', () {
    test('addBook inserts a new book and returns the id', () async {
      final owner = buildUser();
      const title = 'Test Book';
      const author = 'Test Author';
      const bookId = 123;

      final insertedBook = Book(
        id: bookId,
        uuid: 'test-uuid',
        title: title,
        author: author,
        status: 'available',
        readingStatus: 'pending',
        isRead: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isPhysical: true,
        isBorrowedExternal: false,
        isDirty: false,
        isDeleted: false,
      );

      when(() => uuid.v4()).thenReturn('test-uuid');
      when(() => bookDao.findByIsbn(any(), ownerUserId: any(named: 'ownerUserId')))
          .thenAnswer((_) async => null);
      when(() => bookDao.findByTitleAndAuthor(any(), any(), ownerUserId: any(named: 'ownerUserId')))
          .thenAnswer((_) async => null);
      when(() => bookDao.insertBook(any())).thenAnswer((_) async => bookId);
      when(() => bookDao.findById(bookId)).thenAnswer((_) async => insertedBook);
      when(() => groupDao.getGroupsForUser(any())).thenAnswer((_) async => []);
      when(() => syncCoordinator.markPendingChanges(any())).thenReturn(null);

      final result = await repository.addBook(
        title: title,
        author: author,
        owner: owner,
      );

      expect(result, bookId);
      verify(() => bookDao.insertBook(any())).called(1);
      verify(() => syncCoordinator.markPendingChanges(SyncEntity.books)).called(1);
    });

    test('addBook throws exception for duplicate ISBN', () async {
      final owner = buildUser();
      const title = 'Test Book';
      const isbn = '1234567890';
      final existingBook = Book(
        id: 1,
        uuid: 'existing-uuid',
        title: title,
        status: 'available',
        readingStatus: 'pending',
        isRead: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isPhysical: true,
        isBorrowedExternal: false,
        isDirty: false,
        isDeleted: false,
      );

      when(() => bookDao.findByIsbn(isbn, ownerUserId: owner.id))
          .thenAnswer((_) async => existingBook);

      expect(
        () => repository.addBook(
          title: title,
          isbn: isbn,
          owner: owner,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('updateBook updates the book successfully', () async {
      final book = Book(
        id: 1,
        uuid: 'book-uuid',
        title: 'Test Book',
        status: 'available',
        readingStatus: 'pending',
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
        isPhysical: true,
        isBorrowedExternal: false,
        isDirty: false,
        isDeleted: false,
      );

      when(() => bookDao.updateBook(any())).thenAnswer((_) async => true);
      when(() => bookDao.findById(book.id)).thenAnswer((_) async => book);
      when(() => groupDao.getGroupsForUser(any())).thenAnswer((_) async => []);
      when(() => syncCoordinator.markPendingChanges(any())).thenReturn(null);

      final result = await repository.updateBook(book);

      expect(result, true);
      verify(() => bookDao.updateBook(any())).called(1);
      verify(() => syncCoordinator.markPendingChanges(SyncEntity.books)).called(1);
    });

    test('fetchActiveBooks delegates to bookDao', () async {
      final books = <Book>[];
      when(() => bookDao.getActiveBooks(ownerUserId: any(named: 'ownerUserId')))
          .thenAnswer((_) async => books);

      final result = await repository.fetchActiveBooks(ownerUserId: 1);

      expect(result, books);
      verify(() => bookDao.getActiveBooks(ownerUserId: 1)).called(1);
    });
  });
}
