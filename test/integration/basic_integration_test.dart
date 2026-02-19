import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' as drift;
import 'package:book_sharing_app/data/local/database.dart';
import 'package:book_sharing_app/data/local/book_dao.dart';
import 'package:book_sharing_app/data/local/user_dao.dart';
import 'package:book_sharing_app/data/local/group_dao.dart';
import 'package:book_sharing_app/data/repositories/book_repository.dart';
import 'package:book_sharing_app/ui/widgets/empty_state.dart';

void main() {
  group('Basic Integration Tests', () {
    late AppDatabase db;
    late BookDao bookDao;
    late UserDao userDao;
    late GroupDao groupDao;
    late BookRepository bookRepository;
    late LocalUser testUser;

    setUp(() async {
      db = AppDatabase.test(NativeDatabase.memory());
      bookDao = BookDao(db);
      userDao = UserDao(db);
      groupDao = GroupDao(db);

      bookRepository = BookRepository(
        bookDao,
        groupDao: groupDao,
      );

      // Create test user
      final now = DateTime.now();
      final userId = await userDao.insertUser(
        LocalUsersCompanion.insert(
          uuid: 'test-user',
          username: 'testuser',
          remoteId: const drift.Value('remote-test'),
          isDirty: const drift.Value(false),
          isDeleted: const drift.Value(false),
          createdAt: drift.Value(now),
          updatedAt: drift.Value(now),
        ),
      );
      testUser = (await userDao.getById(userId))!;
    });

    tearDown(() async {
      await db.close();
    });

    testWidgets('database and repository integration', (tester) async {
      // Test that we can add and retrieve books
      final bookId = await bookRepository.addBook(
        title: 'Test Book',
        author: 'Test Author',
        owner: testUser,
      );

      expect(bookId, isNotNull);

      // Retrieve the book
      final book = await bookRepository.findById(bookId);
      expect(book, isNotNull);
      expect(book!.title, 'Test Book');
      expect(book.author, 'Test Author');

      // Update the book
      final updatedBook = book.copyWith(
        title: 'Updated Book',
        author: const drift.Value('Updated Author'),
        updatedAt: DateTime.now(),
        isDirty: true,
      );
      await bookRepository.updateBook(updatedBook);

      // Verify the update
      final retrievedBook = await bookRepository.findById(bookId);
      expect(retrievedBook!.title, 'Updated Book');
      expect(retrievedBook.author, 'Updated Author');

      // Delete the book
      await bookRepository.deleteBook(book);

      // Verify the deletion (note: this might be a soft delete)
      final deletedBook = await bookRepository.findById(bookId);
      // The book might still exist but be marked as deleted
      expect(deletedBook?.isDeleted, true);
    });

    testWidgets('UI integration with empty state', (tester) async {
      List<Book> books = [];

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          // Add a book
                          await bookRepository.addBook(
                            title: 'New Book',
                            author: 'New Author',
                            owner: testUser,
                          );

                          // Refresh the book list
                          books = await bookRepository.fetchActiveBooks();
                          setState(() {});
                        },
                        child: const Text('Add Book'),
                      ),
                      Expanded(
                        child: books.isEmpty
                            ? const EmptyState(
                                icon: Icons.book,
                                title: 'No Books Found',
                                message: 'Add your first book to get started',
                              )
                            : ListView.builder(
                                itemCount: books.length,
                                itemBuilder: (context, index) {
                                  final book = books[index];
                                  return ListTile(
                                    title: Text(book.title),
                                    subtitle:
                                        Text(book.author ?? 'Unknown Author'),
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Initially should show empty state
      expect(find.text('No Books Found'), findsOneWidget);
      expect(find.text('Add your first book to get started'), findsOneWidget);
      expect(find.text('Add Book'), findsOneWidget);

      // Tap the add button
      await tester.tap(find.text('Add Book'));
      await tester.pumpAndSettle();

      // Should now show the book
      expect(find.text('No Books Found'), findsNothing);
      expect(find.text('New Book'), findsOneWidget);
      expect(find.text('New Author'), findsOneWidget);
    });

    testWidgets('multiple books management in UI', (tester) async {
      List<Book> books = [];

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    children: [
                      Text('Books: ${books.length}'),
                      ElevatedButton(
                        onPressed: () async {
                          // Add multiple books
                          await bookRepository.addBook(
                            title: 'Book One',
                            author: 'Author One',
                            owner: testUser,
                          );
                          await bookRepository.addBook(
                            title: 'Book Two',
                            author: 'Author Two',
                            owner: testUser,
                          );

                          // Refresh the book list
                          books = await bookRepository.fetchActiveBooks();
                          setState(() {});
                        },
                        child: const Text('Add Multiple Books'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          // Clear all books
                          for (final book in books) {
                            await bookRepository.deleteBook(book);
                          }

                          // Refresh the book list
                          books = await bookRepository.fetchActiveBooks();
                          setState(() {});
                        },
                        child: const Text('Clear All Books'),
                      ),
                      Expanded(
                        child: books.isEmpty
                            ? const EmptyState(
                                icon: Icons.book,
                                title: 'No Books Found',
                                message: 'Add books to see them here',
                              )
                            : ListView.builder(
                                itemCount: books.length,
                                itemBuilder: (context, index) {
                                  final book = books[index];
                                  return ListTile(
                                    title: Text(book.title),
                                    subtitle:
                                        Text(book.author ?? 'Unknown Author'),
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Initially should show empty state
      expect(find.text('Books: 0'), findsOneWidget);
      expect(find.text('No Books Found'), findsOneWidget);

      // Add multiple books
      await tester.tap(find.text('Add Multiple Books'));
      await tester.pumpAndSettle();

      // Should show the books
      expect(find.text('Books: 2'), findsOneWidget);
      expect(find.text('Book One'), findsOneWidget);
      expect(find.text('Book Two'), findsOneWidget);
      expect(find.text('Author One'), findsOneWidget);
      expect(find.text('Author Two'), findsOneWidget);

      // Clear all books
      await tester.tap(find.text('Clear All Books'));
      await tester.pumpAndSettle();

      // Should show empty state again
      expect(find.text('Books: 0'), findsOneWidget);
      expect(find.text('No Books Found'), findsOneWidget);
      expect(find.text('Book One'), findsNothing);
      expect(find.text('Book Two'), findsNothing);
    });

    testWidgets('search functionality integration', (tester) async {
      List<Book> allBooks = [];
      List<Book> filteredBooks = [];
      String searchQuery = '';

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    children: [
                      TextField(
                        decoration: const InputDecoration(
                          hintText: 'Search books...',
                          prefixIcon: Icon(Icons.search),
                          suffixIcon: Icon(Icons.clear), // Add clear icon
                        ),
                        onChanged: (query) {
                          searchQuery = query.toLowerCase();
                          filteredBooks = allBooks
                              .where((book) =>
                                  book.title
                                      .toLowerCase()
                                      .contains(searchQuery) ||
                                  (book.author
                                          ?.toLowerCase()
                                          .contains(searchQuery) ??
                                      false))
                              .toList();
                          setState(() {});
                        },
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          // Add test books
                          await bookRepository.addBook(
                            title: 'Harry Potter',
                            author: 'J.K. Rowling',
                            owner: testUser,
                          );
                          await bookRepository.addBook(
                            title: 'The Hobbit',
                            author: 'J.R.R. Tolkien',
                            owner: testUser,
                          );

                          // Refresh the book list
                          allBooks = await bookRepository.fetchActiveBooks();
                          filteredBooks = allBooks;
                          setState(() {});
                        },
                        child: const Text('Add Test Books'),
                      ),
                      Expanded(
                        child: filteredBooks.isEmpty
                            ? const EmptyState(
                                icon: Icons.search,
                                title: 'No Books Found',
                                message: 'Try a different search term',
                              )
                            : ListView.builder(
                                itemCount: filteredBooks.length,
                                itemBuilder: (context, index) {
                                  final book = filteredBooks[index];
                                  return ListTile(
                                    title: Text(book.title),
                                    subtitle:
                                        Text(book.author ?? 'Unknown Author'),
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Initially should show empty state
      expect(find.text('No Books Found'), findsOneWidget);

      // Add test books
      await tester.tap(find.text('Add Test Books'));
      await tester.pumpAndSettle();

      // Should show both books
      expect(find.text('Harry Potter'), findsOneWidget);
      expect(find.text('The Hobbit'), findsOneWidget);

      // Search for "Harry"
      await tester.enterText(find.byType(TextField), 'Harry');
      await tester.pump();

      // Should only show Harry Potter
      expect(find.text('Harry Potter'), findsOneWidget);
      expect(find.text('The Hobbit'), findsNothing);

      // Clear search by entering empty text
      await tester.enterText(find.byType(TextField), '');
      await tester.pump();

      // Should show both books again
      expect(find.text('Harry Potter'), findsOneWidget);
      expect(find.text('The Hobbit'), findsOneWidget);
    });
  });
}
