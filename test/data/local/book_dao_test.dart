
import 'package:book_sharing_app/data/local/book_dao.dart';
import 'package:book_sharing_app/data/local/database.dart';
import 'package:book_sharing_app/data/local/user_dao.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:matcher/matcher.dart' as m;

void main() {
  late AppDatabase database;
  late BookDao bookDao;
  late UserDao userDao;
  late LocalUser testUser;

  setUp(() async {
    database = AppDatabase.test(NativeDatabase.memory());
    bookDao = BookDao(database);
    userDao = UserDao(database);

    final userCompanion = LocalUsersCompanion.insert(
      uuid: 'user-uuid-1',
      username: 'testuser',
      pinUpdatedAt: Value(DateTime.now()),
    );
    final id = await userDao.insertUser(userCompanion);
    testUser = (await userDao.getById(id))!;
  });

  tearDown(() async {
    await database.close();
  });

  test('insertBook inserts a book and watchActiveBooks retrieves it', () async {
    final book = BooksCompanion(
      uuid: const Value('uuid-1'),
      title: const Value('Test Book'),
      author: const Value('Test Author'),
      isbn: const Value('1234567890'),
      isPhysical: const Value(true),
      status: const Value('available'),
      readingStatus: const Value('pending'),
      ownerUserId: Value(testUser.id),
      createdAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    );

    await bookDao.insertBook(book);

    final booksStream = bookDao.watchActiveBooks(ownerUserId: testUser.id);
    final books = await booksStream.first;

    expect(books.length, 1);
    expect(books[0].title, 'Test Book');
  });

  test('updateBook updates an existing book', () async {
    final book = BooksCompanion(
      uuid: const Value('uuid-1'),
      title: const Value('Test Book'),
      author: const Value('Test Author'),
      isbn: const Value('1234567890'),
      isPhysical: const Value(true),
      status: const Value('available'),
      readingStatus: const Value('pending'),
      ownerUserId: Value(testUser.id),
      createdAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    );
    final insertedId = await bookDao.insertBook(book);
    final insertedBook = (await bookDao.findById(insertedId))!;

    final updatedBook = BooksCompanion(
      id: Value(insertedBook.id),
      uuid: const Value('uuid-1'),
      title: const Value('Updated Title'),
      author: const Value('Test Author'),
      isbn: const Value('1234567890'),
      isPhysical: const Value(true),
      status: const Value('available'),
      readingStatus: const Value('reading'),
      ownerUserId: Value(testUser.id),
      createdAt: Value(insertedBook.createdAt),
      updatedAt: Value(DateTime.now()),
    );

    await bookDao.updateBook(updatedBook);

    final booksStream = bookDao.watchActiveBooks(ownerUserId: testUser.id);
    final books = await booksStream.first;

    expect(books.length, 1);
    expect(books[0].title, 'Updated Title');
    expect(books[0].readingStatus, 'reading');
  });

  test('softDeleteBook soft deletes a book', () async {
    final book = BooksCompanion(
      uuid: const Value('uuid-1'),
      title: const Value('Test Book'),
      author: const Value('Test Author'),
      isbn: const Value('1234567890'),
      isPhysical: const Value(true),
      status: const Value('available'),
      readingStatus: const Value('pending'),
      ownerUserId: Value(testUser.id),
      createdAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    );
    final insertedId = await bookDao.insertBook(book);
    final insertedBook = (await bookDao.findById(insertedId))!;


    await bookDao.softDeleteBook(bookId: insertedBook.id, timestamp: DateTime.now());

    final bookFromDb = await bookDao.findById(insertedBook.id);
    expect(bookFromDb, m.isNotNull);
    expect(bookFromDb!.isDeleted, isTrue);

    final activeBooksStream = bookDao.watchActiveBooks(ownerUserId: testUser.id);
    final activeBooks = await activeBooksStream.first;
    expect(activeBooks.where((b) => b.id == insertedBook.id).isEmpty, isTrue);
  });
}
