import 'package:collection/collection.dart';

import '../data/local/database.dart';
import '../data/local/group_dao.dart';
import '../data/repositories/book_repository.dart';
import '../data/repositories/loan_repository.dart';

class StatsSummary {
  const StatsSummary({
    required this.totalBooks,
    required this.totalBooksRead,
    required this.availableBooks,
    required this.totalLoans,
    required this.activeLoans,
    required this.returnedLoans,
    required this.expiredLoans,
    required this.topBooks,
    required this.activeLoanDetails,
  });

  final int totalBooks;
  final int totalBooksRead;
  final int availableBooks;
  final int totalLoans;
  final int activeLoans;
  final int returnedLoans;
  final int expiredLoans;
  final List<StatsTopBook> topBooks;
  final List<StatsActiveLoan> activeLoanDetails;
}

class StatsTopBook {
  const StatsTopBook({
    required this.bookId,
    required this.title,
    required this.loanCount,
  });

  final int? bookId;
  final String title;
  final int loanCount;
}

class StatsActiveLoan {
  const StatsActiveLoan({
    required this.loanId,
    required this.loan,
    required this.loanUuid,
    required this.bookTitle,
    required this.borrowerName,
    required this.status,
    required this.requestedAt,
    required this.isManualLoan,
    this.dueDate,
    this.groupId,
    this.sharedBookId,
    this.isExternalReceived = false,
    this.lenderName,
  });

  final Loan loan;
  final int loanId;
  final String loanUuid;
  final String bookTitle;
  final String borrowerName;
  final String? lenderName;
  final String status;
  final DateTime requestedAt;
  final DateTime? dueDate;
  final int? groupId;
  final int? sharedBookId;
  final bool isManualLoan;
  final bool isExternalReceived;
}

class StatsService {
  StatsService(this._bookRepository, this._loanRepository);

  final BookRepository _bookRepository;
  final LoanRepository _loanRepository;

  static const _countableStatuses = {'active', 'returned', 'expired'};

  Future<StatsSummary> loadSummary({LocalUser? owner}) async {
    final books =
        await _bookRepository.fetchActiveBooks(ownerUserId: owner?.id);
    final loanDetails = await _loanRepository.getAllLoanDetails();

    final totalLoans = loanDetails.length;
    final activeLoanDetails = loanDetails
        .where(
      (detail) =>
          detail.loan.status == 'active' || detail.loan.status == 'requested',
    )
        .map(
      (detail) {
        final isExternalReceived = detail.book?.isBorrowedExternal ?? false;
        return StatsActiveLoan(
          loan: detail.loan,
          loanId: detail.loan.id,
          loanUuid: detail.loan.uuid,
          bookTitle: _resolveActiveLoanTitle(detail, books),
          borrowerName: detail.loan.externalBorrowerName ??
              _resolveUserName(detail.borrower),
          lenderName: isExternalReceived
              ? (detail.book?.externalLenderName ?? 'Alguien')
              : null,
          status: detail.loan.status,
          requestedAt: detail.loan.requestedAt,
          dueDate: detail.loan.dueDate,
          groupId: detail.sharedBook?.groupId,
          sharedBookId: detail.sharedBook?.id,
          isManualLoan: detail.loan.externalBorrowerName != null,
          isExternalReceived: isExternalReceived,
        );
      },
    ).toList(growable: false);
    final activeLoans = activeLoanDetails.length;
    final returnedLoans =
        loanDetails.where((detail) => detail.loan.status == 'returned').length;
    final expiredLoans =
        loanDetails.where((detail) => detail.loan.status == 'expired').length;

    final booksById = {for (final book in books) book.id: book};

    final topAggregates = <int?, _TopAccumulator>{};

    for (final detail in loanDetails) {
      if (!_countableStatuses.contains(detail.loan.status)) {
        continue;
      }

      final bookId = detail.book?.id ?? detail.sharedBook?.bookId;
      final bookTitle = _resolveTopBookTitle(detail, booksById);

      final entry = topAggregates.putIfAbsent(
        bookId,
        () => _TopAccumulator(title: bookTitle),
      );
      entry.count += 1;
    }

    final topBooks = topAggregates.entries
        .map((entry) => StatsTopBook(
              bookId: entry.key,
              title: entry.value.title,
              loanCount: entry.value.count,
            ))
        .sortedBy<num>((item) => -item.loanCount)
        .take(3)
        .toList();

    // Calculate total books (only owned ones)
    final ownedBooks =
        books.where((b) => b.isBorrowedExternal == false).toList();

    // Calculate total books read
    final booksReadOwned = ownedBooks.where((b) => b.isRead).length;
    final booksReadBorrowed = loanDetails
        .where((detail) =>
            detail.loan.wasRead == true &&
            detail.loan.borrowerUserId == owner?.id)
        .length;
    final totalBooksRead = booksReadOwned + booksReadBorrowed;

    return StatsSummary(
      totalBooks: ownedBooks.length,
      totalBooksRead: totalBooksRead,
      availableBooks: ownedBooks.where((b) => b.status == 'available').length,
      totalLoans: totalLoans,
      activeLoans: activeLoans,
      returnedLoans: returnedLoans,
      expiredLoans: expiredLoans,
      topBooks: topBooks,
      activeLoanDetails: activeLoanDetails,
    );
  }

  String _resolveBookTitle(LoanDetail detail, List<Book> books) {
    final sharedBookId = detail.sharedBook?.bookId;
    if (sharedBookId != null) {
      final book =
          books.firstWhereOrNull((element) => element.id == sharedBookId);
      if (book != null && !_isBookDeleted(book) && book.title.isNotEmpty) {
        return book.title;
      }
    }
    return 'Libro sin título';
  }

  String _resolveActiveLoanTitle(LoanDetail detail, List<Book> books) {
    final book = detail.book;
    if (book != null && !_isBookDeleted(book) && book.title.isNotEmpty) {
      return book.title;
    }
    return _resolveBookTitle(detail, books);
  }

  String _resolveTopBookTitle(LoanDetail detail, Map<int?, Book> booksById) {
    final book = detail.book;
    if (book != null && !_isBookDeleted(book) && book.title.isNotEmpty) {
      return book.title;
    }

    final resolved = booksById[detail.sharedBook?.bookId];
    if (resolved != null && resolved.title.isNotEmpty) {
      return resolved.title;
    }

    return 'Libro desconocido';
  }

  bool _isBookDeleted(Book book) => book.isDeleted;

  String _resolveUserName(LocalUser? user) {
    return user?.username ?? 'Usuario';
  }

  Future<List<ReadBookItem>> getReadBooks({required int userId}) async {
    final books = await _bookRepository.fetchActiveBooks(ownerUserId: userId);
    final allLoans = await _loanRepository.getAllLoanDetails();
    final allReviews =
        await _bookRepository.fetchActiveReviews(); // Fetch all reviews

    // Filter reviews by current user
    final myReviews = allReviews.where((r) => r.authorUserId == userId);
    final reviewsByBookId = {for (final r in myReviews) r.bookId: r};

    final List<ReadBookItem> readItems = [];

    // 1. Owned books marked as read
    for (final book in books) {
      if (book.isRead) {
        final review = reviewsByBookId[book.id];
        readItems.add(ReadBookItem(
          title: book.title,
          author: book.author ?? 'Autor desconocido',
          readAt: book.readAt ?? book.updatedAt,
          coverPath: book.coverPath,
          isBorrowed: false,
          book: book,
          personalRating: review?.rating,
        ));
      }
    }

    // 2. Borrowed books (loans) marked as read
    // Filter for loans where I am the borrower and wasRead is true
    final myReadLoans = allLoans.where((detail) =>
        detail.loan.borrowerUserId == userId && detail.loan.wasRead == true);

    for (final detail in myReadLoans) {
      // Resolve the book object
      Book? book = detail.book;

      // If book is not directly linked (e.g. shared book), try to find it in my owned books (unlikely if I borrowed it)
      // or we rely on what we have.
      // If detail.book is null but sharedBook exists, we need the Book object for the dialog via ID.
      // However, getAllLoanDetails might not preload the Book if it's via SharedBooks and not direct BookId?
      // Actually Loan has nullable bookId and nullable sharedBookId.
      // If sharedBookId is used, the Book record still exists in DB.
      // We might need to fetch it if detail.book is null.
      if (book == null && detail.sharedBook != null) {
        // We can't synchronously fetch here easily without N+1, but let's try to look it up
        // if we had a full list.
        // For now, if we can't find the book object, we can't review it easily in UI (button disabled).
        // But usually detail.book SHOULD be populated if the query joins correctly.
        // Checking LoanRepository.getAllLoanDetails usually joins everything.
      }

      final title = book?.title ??
          (detail.sharedBook != null
              ? _resolveBookTitle(detail, [])
              : 'Libro desconocido');

      final author = book?.author ?? 'Autor desconocido';
      final readDate = detail.loan.markedReadAt ??
          detail.loan.returnedAt ??
          detail.loan.updatedAt;

      final review = book != null ? reviewsByBookId[book.id] : null;

      readItems.add(ReadBookItem(
        title: title,
        author: author,
        readAt: readDate,
        coverPath: book?.coverPath,
        isBorrowed: true,
        book: book,
        personalRating: review?.rating,
      ));
    }

    // Sort by date descending (latest read first)
    readItems.sort((a, b) => b.readAt.compareTo(a.readAt));

    return readItems;
  }
}

class _TopAccumulator {
  _TopAccumulator({required this.title});

  final String title;
  int count = 0;
}

class ReadBookItem {
  const ReadBookItem({
    required this.title,
    required this.author,
    required this.readAt,
    this.coverPath,
    this.isBorrowed = false,
    this.book,
    this.personalRating,
  });

  final String title;
  final String author;
  final DateTime readAt;
  final String? coverPath;
  final bool isBorrowed;
  final Book? book;
  final int? personalRating;
}
