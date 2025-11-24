import 'package:collection/collection.dart';

import '../data/local/database.dart';
import '../data/local/group_dao.dart';
import '../data/repositories/book_repository.dart';
import '../data/repositories/loan_repository.dart';

class StatsSummary {
  const StatsSummary({
    required this.totalBooks,
    required this.totalLoans,
    required this.activeLoans,
    required this.returnedLoans,
    required this.expiredLoans,
    required this.topBooks,
    required this.activeLoanDetails,
  });

  final int totalBooks;
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
    required this.loanUuid,
    required this.bookTitle,
    required this.borrowerName,
    required this.status,
    required this.startDate,
    this.dueDate,
    this.groupId,
    this.sharedBookId,
  });

  final String loanUuid;
  final String bookTitle;
  final String borrowerName;
  final String status;
  final DateTime startDate;
  final DateTime? dueDate;
  final int? groupId;
  final int? sharedBookId;
}

class StatsService {
  StatsService(this._bookRepository, this._loanRepository);

  final BookRepository _bookRepository;
  final LoanRepository _loanRepository;

  static const _countableStatuses = {'accepted', 'returned', 'expired'};

  Future<StatsSummary> loadSummary({LocalUser? owner}) async {
    final books = await _bookRepository.fetchActiveBooks(ownerUserId: owner?.id);
    final loanDetails = await _loanRepository.getAllLoanDetails();

    final totalLoans = loanDetails.length;
    final activeLoanDetails = loanDetails
        .where(
          (detail) => detail.loan.status == 'accepted' || detail.loan.status == 'pending' || detail.loan.status == 'loaned',
        )
        .map(
          (detail) => StatsActiveLoan(
            loanUuid: detail.loan.uuid,
            bookTitle: _resolveActiveLoanTitle(detail, books),
            borrowerName: detail.loan.externalBorrowerName ?? _resolveUserName(detail.borrower),
            status: detail.loan.status,
            startDate: detail.loan.startDate,
            dueDate: detail.loan.dueDate,
            groupId: detail.sharedBook?.groupId,
            sharedBookId: detail.sharedBook?.id,
          ),
        )
        .toList(growable: false);
    final activeLoans = activeLoanDetails.length;
    final returnedLoans = loanDetails.where((detail) => detail.loan.status == 'returned').length;
    final expiredLoans = loanDetails.where((detail) => detail.loan.status == 'expired').length;

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

    return StatsSummary(
      totalBooks: books.length,
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
      final book = books.firstWhereOrNull((element) => element.id == sharedBookId);
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
}

class _TopAccumulator {
  _TopAccumulator({required this.title});

  final String title;
  int count = 0;
}
