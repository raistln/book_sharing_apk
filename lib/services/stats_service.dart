import 'package:collection/collection.dart';

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
  });

  final int totalBooks;
  final int totalLoans;
  final int activeLoans;
  final int returnedLoans;
  final int expiredLoans;
  final List<StatsTopBook> topBooks;
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

class StatsService {
  StatsService(this._bookRepository, this._loanRepository);

  final BookRepository _bookRepository;
  final LoanRepository _loanRepository;

  static const _countableStatuses = {'accepted', 'returned', 'expired'};

  Future<StatsSummary> loadSummary() async {
    final books = await _bookRepository.fetchActiveBooks();
    final loanDetails = await _loanRepository.getAllLoanDetails();

    final totalLoans = loanDetails.length;
    final activeLoans = loanDetails.where((detail) => detail.loan.status == 'accepted').length;
    final returnedLoans = loanDetails.where((detail) => detail.loan.status == 'returned').length;
    final expiredLoans = loanDetails.where((detail) => detail.loan.status == 'expired').length;

    final booksById = {for (final book in books) book.id: book};

    final topAggregates = <int?, _TopAccumulator>{};

    for (final detail in loanDetails) {
      if (!_countableStatuses.contains(detail.loan.status)) {
        continue;
      }

      final bookId = detail.book?.id ?? detail.sharedBook?.bookId;
      final bookTitle = detail.book?.title ??
          booksById[detail.sharedBook?.bookId]?.title ??
          'Libro desconocido';

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
    );
  }
}

class _TopAccumulator {
  _TopAccumulator({required this.title});

  final String title;
  int count = 0;
}
