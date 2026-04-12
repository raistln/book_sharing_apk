import 'package:flutter_test/flutter_test.dart';
import 'package:book_sharing_app/data/local/database.dart';
import 'package:book_sharing_app/data/local/group_dao.dart';
import 'package:book_sharing_app/models/grouped_shared_book.dart';

// ────────────────────────────────────────────────────────────────
// Helpers
// ────────────────────────────────────────────────────────────────

Book _makeBook({
  int id = 1,
  String uuid = 'book-1',
  String title = 'Test Book',
  String? author = 'Test Author',
  String? coverPath,
  int? ownerUserId = 1,
}) =>
    Book(
      id: id,
      uuid: uuid,
      title: title,
      author: author,
      coverPath: coverPath,
      isPhysical: true,
      isRead: false,
      ownerUserId: ownerUserId,
      status: 'available',
      readingStatus: 'pending',
      isBorrowedExternal: false,
      isOnShelf: false,
      createdAt: DateTime(2024),
      updatedAt: DateTime(2024),
      isDirty: false,
      isDeleted: false,
    );

SharedBookDetail _makeCopy({
  required int id,
  required String uuid,
  required Book book,
  required int ownerUserId,
  bool isAvailable = true,
}) =>
    SharedBookDetail(
      sharedBook: SharedBook(
        id: id,
        uuid: uuid,
        groupId: 1,
        groupUuid: 'group-1',
        bookId: book.id,
        bookUuid: book.uuid,
        ownerUserId: ownerUserId,
        isAvailable: isAvailable,
        isPhysical: true,
        isBorrowedExternal: false,
        isRead: false,
        visibility: 'group',
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
        isDirty: false,
        isDeleted: false,
      ),
      book: book,
    );

// ────────────────────────────────────────────────────────────────
// Tests
// ────────────────────────────────────────────────────────────────

void main() {
  group('GroupedSharedBook', () {
    // ─── count & basic properties ────────────────────────────────
    group('count and title', () {
      test('count reflects allCopies.length', () {
        final book = _makeBook();
        final grouped = GroupedSharedBook(
          book: book,
          allCopies: [
            _makeCopy(id: 1, uuid: 'sb-1', book: book, ownerUserId: 1),
            _makeCopy(id: 2, uuid: 'sb-2', book: book, ownerUserId: 2),
            _makeCopy(id: 3, uuid: 'sb-3', book: book, ownerUserId: 3),
          ],
        );
        expect(grouped.count, 3);
      });

      test('count is 1 for a single copy', () {
        final book = _makeBook();
        final grouped = GroupedSharedBook(
          book: book,
          allCopies: [_makeCopy(id: 1, uuid: 'sb-1', book: book, ownerUserId: 1)],
        );
        expect(grouped.count, 1);
      });

      test('title falls back to "Sin título" when book is null', () {
        final grouped = GroupedSharedBook(book: null, allCopies: []);
        expect(grouped.title, 'Sin título');
      });

      test('author falls back to "Anónimo" when book has no author', () {
        final book = _makeBook(author: null);
        final grouped = GroupedSharedBook(book: book, allCopies: []);
        expect(grouped.author, 'Anónimo');
      });

      test('coverPath returns empty string when book is null', () {
        final grouped = GroupedSharedBook(book: null, allCopies: []);
        expect(grouped.coverPath, '');
      });

      test('coverPath returns book cover when set', () {
        final book = _makeBook(coverPath: '/path/to/cover.jpg');
        final grouped = GroupedSharedBook(book: book, allCopies: []);
        expect(grouped.coverPath, '/path/to/cover.jpg');
      });
    });

    // ─── isAnyAvailable ──────────────────────────────────────────
    group('isAnyAvailable', () {
      test('returns true if at least one copy is available', () {
        final book = _makeBook();
        final grouped = GroupedSharedBook(
          book: book,
          allCopies: [
            _makeCopy(id: 1, uuid: 'sb-1', book: book, ownerUserId: 1, isAvailable: false),
            _makeCopy(id: 2, uuid: 'sb-2', book: book, ownerUserId: 2, isAvailable: true),
          ],
        );
        expect(grouped.isAnyAvailable, isTrue);
      });

      test('returns false when all copies are unavailable', () {
        final book = _makeBook();
        final grouped = GroupedSharedBook(
          book: book,
          allCopies: [
            _makeCopy(id: 1, uuid: 'sb-1', book: book, ownerUserId: 1, isAvailable: false),
            _makeCopy(id: 2, uuid: 'sb-2', book: book, ownerUserId: 2, isAvailable: false),
          ],
        );
        expect(grouped.isAnyAvailable, isFalse);
      });

      test('returns false when allCopies is empty', () {
        final grouped = GroupedSharedBook(book: _makeBook(), allCopies: []);
        expect(grouped.isAnyAvailable, isFalse);
      });

      test('returns true when only copy is available', () {
        final book = _makeBook();
        final grouped = GroupedSharedBook(
          book: book,
          allCopies: [
            _makeCopy(id: 1, uuid: 'sb-1', book: book, ownerUserId: 1, isAvailable: true),
          ],
        );
        expect(grouped.isAnyAvailable, isTrue);
      });
    });

    // ─── ownership identity ───────────────────────────────────────
    group('owner identification', () {
      test('each copy belongs to a different owner', () {
        final book = _makeBook();
        final copy1 = _makeCopy(id: 1, uuid: 'sb-1', book: book, ownerUserId: 10);
        final copy2 = _makeCopy(id: 2, uuid: 'sb-2', book: book, ownerUserId: 20);

        final grouped = GroupedSharedBook(book: book, allCopies: [copy1, copy2]);

        final ownerIds = grouped.allCopies.map((c) => c.sharedBook.ownerUserId).toList();
        expect(ownerIds, containsAll([10, 20]));
      });

      test('copies retain their distinct sharedBook IDs', () {
        final book = _makeBook();
        final copy1 = _makeCopy(id: 101, uuid: 'sb-101', book: book, ownerUserId: 1);
        final copy2 = _makeCopy(id: 202, uuid: 'sb-202', book: book, ownerUserId: 2);

        final grouped = GroupedSharedBook(book: book, allCopies: [copy1, copy2]);

        expect(grouped.allCopies[0].sharedBook.id, 101);
        expect(grouped.allCopies[1].sharedBook.id, 202);
      });
    });
  });
}
