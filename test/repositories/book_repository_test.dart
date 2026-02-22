import 'package:book_sharing_app/data/local/book_dao.dart';
import 'package:book_sharing_app/data/local/database.dart';
import 'package:book_sharing_app/data/local/group_dao.dart';
import 'package:book_sharing_app/data/local/user_dao.dart';
import 'package:book_sharing_app/data/repositories/book_repository.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';

void main() {
  group('BookRepository', () {
    late AppDatabase db;
    late BookDao bookDao;
    late UserDao userDao;
    late GroupDao groupDao;
    late BookRepository bookRepository;

    late LocalUser owner;

    setUp(() async {
      db = AppDatabase.test(NativeDatabase.memory());
      bookDao = BookDao(db);
      userDao = UserDao(db);
      groupDao = GroupDao(db);

      // Create repository with real dependencies
      bookRepository = BookRepository(
        bookDao,
        groupDao: groupDao,
        uuid: const Uuid(),
      );

      // Setup test data
      owner = await _insertUser(userDao, username: 'owner');
    });

    tearDown(() async {
      await db.close();
    });

    group('CRUD Operations', () {
      test('addBook creates book successfully', () async {
        final bookId = await bookRepository.addBook(
          title: 'Clean Code',
          author: 'Robert C. Martin',
          isbn: '978-0132350884',
          owner: owner,
        );

        expect(bookId, isA<int>());
        expect(bookId, greaterThan(0));

        final book = await bookRepository.findById(bookId);
        expect(book, isNotNull);
        expect(book!.title, 'Clean Code');
        expect(book.author, 'Robert C. Martin');
        expect(book.isbn, '978-0132350884');
        expect(book.ownerUserId, owner.id);
      });

      test('updateBook updates book successfully', () async {
        // First create a book
        final bookId = await bookRepository.addBook(
          title: 'Original Title',
          author: 'Original Author',
          owner: owner,
        );

        final book = await bookRepository.findById(bookId);
        expect(book, isNotNull);
        final updatedBook = book!.copyWith(
          title: 'Updated Title',
          author: const drift.Value('Updated Author'),
          updatedAt: DateTime.now(),
          isDirty: true,
        );

        final result = await bookRepository.updateBook(updatedBook);

        expect(result, isTrue);

        final retrievedBook = await bookRepository.findById(bookId);
        expect(retrievedBook!.title, 'Updated Title');
        expect(retrievedBook.author, 'Updated Author');
        expect(retrievedBook.isDirty, isTrue);
      });

      test('deleteBook soft deletes book successfully', () async {
        // First create a book
        final bookId = await bookRepository.addBook(
          title: 'Book to Delete',
          author: 'Test Author',
          owner: owner,
        );

        final book = await bookRepository.findById(bookId);
        expect(book, isNotNull);
        final removedSharedBooks = await bookRepository.deleteBook(book!);

        expect(removedSharedBooks, isA<List<SharedBook>>());

        // Verify book is soft deleted
        final deletedBook = await bookRepository.findById(bookId);
        expect(deletedBook, isNotNull);
        expect(deletedBook!.isDeleted, isTrue);
      });

      test('findById returns correct book', () async {
        final bookId = await bookRepository.addBook(
          title: 'Find Me Book',
          author: 'Find Author',
          owner: owner,
        );

        final book = await bookRepository.findById(bookId);

        expect(book, isNotNull);
        expect(book!.title, 'Find Me Book');
        expect(book.author, 'Find Author');
      });

      test('findById returns null for non-existent book', () async {
        final book = await bookRepository.findById(99999);
        expect(book, isNull);
      });
    });

    group('Query Operations', () {
      test('fetchActiveBooks returns books for specific owner', () async {
        // Create books for owner
        await bookRepository.addBook(
          title: 'Owner Book 1',
          author: 'Author 1',
          owner: owner,
        );
        await bookRepository.addBook(
          title: 'Owner Book 2',
          author: 'Author 2',
          owner: owner,
        );

        // Create another user and book
        final otherUser = await _insertUser(userDao, username: 'other');
        await bookRepository.addBook(
          title: 'Other User Book',
          author: 'Other Author',
          owner: otherUser,
        );

        final ownerBooks =
            await bookRepository.fetchActiveBooks(ownerUserId: owner.id);
        final allBooks = await bookRepository.fetchActiveBooks();

        expect(ownerBooks.length, 2);
        expect(allBooks.length, 3);

        expect(
            ownerBooks.every((book) => book.ownerUserId == owner.id), isTrue);
      });

      test('watchAll provides stream of books', () async {
        await bookRepository.addBook(
          title: 'Stream Book',
          author: 'Stream Author',
          owner: owner,
        );

        final stream = bookRepository.watchAll(ownerUserId: owner.id);
        expect(stream, isA<Stream<List<Book>>>());

        final books = await stream.first;
        expect(books.length, 1);
        expect(books.first.title, 'Stream Book');
      });

      test('fetchActiveBooks filters by status', () async {
        await bookRepository.addBook(
          title: 'Available Book',
          author: 'Author 1',
          status: 'available',
          owner: owner,
        );

        await bookRepository.addBook(
          title: 'Loaned Book',
          author: 'Author 2',
          status: 'loaned',
          owner: owner,
        );

        final allBooks =
            await bookRepository.fetchActiveBooks(ownerUserId: owner.id);
        expect(allBooks.length, 2);

        // Both should be returned since they are not deleted
        expect(allBooks.any((book) => book.status == 'available'), isTrue);
        expect(allBooks.any((book) => book.status == 'loaned'), isTrue);
      });
    });

    group('Review Operations', () {
      test('addReview creates review successfully', () async {
        final book =
            await _insertBook(bookDao, owner: owner, title: 'Test Book');

        final reviewId = await bookRepository.addReview(
          book: book,
          rating: 4,
          review: 'Excellent book!',
          author: owner,
        );

        expect(reviewId, isA<int>());
        expect(reviewId, greaterThan(0));

        final reviews = await bookRepository.fetchActiveReviews();
        expect(reviews.length, 1);
        expect(reviews.first.rating, 4);
        expect(reviews.first.review, 'Excellent book!');
      });

      test('addReview updates existing review', () async {
        final book =
            await _insertBook(bookDao, owner: owner, title: 'Test Book');

        // Add initial review
        await bookRepository.addReview(
          book: book,
          rating: 3,
          review: 'Average book',
          author: owner,
        );

        // Update the same review
        final reviewId = await bookRepository.addReview(
          book: book,
          rating: 4,
          review: 'Better than average',
          author: owner,
        );

        expect(reviewId, isA<int>());

        final reviews = await bookRepository.fetchActiveReviews();
        expect(reviews.length, 1); // Still only one review
        expect(reviews.first.rating, 4);
        expect(reviews.first.review, 'Better than average');
      });

      test('watchReviews provides stream of reviews', () async {
        final book =
            await _insertBook(bookDao, owner: owner, title: 'Test Book');

        await bookRepository.addReview(
          book: book,
          rating: 4,
          review: 'Good book',
          author: owner,
        );

        final stream = bookRepository.watchReviews(book.id);
        expect(stream, isA<Stream<List<ReviewWithAuthor>>>());

        final reviews = await stream.first;
        expect(reviews.length, 1);
        expect(reviews.first.review.rating, 4);
      });
    });

    group('Error Handling', () {
      test('updateBook handles non-existent book gracefully', () async {
        final nonExistentBook = Book(
          id: 99999,
          uuid: 'non-existent-uuid',
          remoteId: 'remote-99999',
          title: 'Non-existent',
          author: 'Author',
          isbn: '1234567890',
          barcode: '456',
          coverPath: 'path',
          status: 'available',
          description: 'notes',
          readingStatus: 'pending',
          isRead: false,
          isBorrowedExternal: false,
          ownerUserId: owner.id,
          ownerRemoteId: owner.remoteId ?? 'remote-owner',
          isDirty: false,
          isDeleted: false,
          syncedAt: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          genre: null,
          isPhysical: true,
          pageCount: null,
          publicationYear: null,
        );

        final result = await bookRepository.updateBook(nonExistentBook);
        expect(result, isFalse);
      });
    });
  });
}

// Helper functions
Future<LocalUser> _insertUser(UserDao userDao,
    {required String username}) async {
  final now = DateTime(2024, 1, 1, 12);
  final remoteId = 'remote-$username';
  final userId = await userDao.insertUser(
    LocalUsersCompanion.insert(
      uuid: 'user-$username',
      username: username,
      remoteId: drift.Value(remoteId),
      isDirty: const drift.Value(false),
      isDeleted: const drift.Value(false),
      createdAt: drift.Value(now),
      updatedAt: drift.Value(now),
    ),
  );
  return (await userDao.getById(userId))!;
}

Future<Book> _insertBook(BookDao bookDao,
    {required LocalUser owner, required String title}) async {
  final now = DateTime(2024, 1, 1, 12);
  final bookId = await bookDao.insertBook(
    BooksCompanion.insert(
      uuid: 'book-$title',
      remoteId: const drift.Value('book-remote-1'),
      title: title,
      author: const drift.Value('Test Author'),
      status: const drift.Value('available'),
      ownerUserId: drift.Value(owner.id),
      ownerRemoteId: drift.Value(owner.remoteId ?? 'remote-owner'),
      isDirty: const drift.Value(false),
      isDeleted: const drift.Value(false),
      syncedAt: drift.Value(now),
      createdAt: drift.Value(now),
      updatedAt: drift.Value(now),
    ),
  );
  return (await bookDao.findById(bookId))!;
}
