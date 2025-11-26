import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/group_dao.dart';
import 'book_providers.dart';

class LoanBuckets {
  const LoanBuckets({
    required this.incoming,
    required this.outgoing,
    required this.history,
    required this.dueSoon,
  });

  final List<LoanDetail> incoming;
  final List<LoanDetail> outgoing;
  final List<LoanDetail> history;
  final List<LoanDetail> dueSoon;

  bool get isEmpty =>
      incoming.isEmpty && outgoing.isEmpty && history.isEmpty && dueSoon.isEmpty;
}

final loanOverviewProvider = FutureProvider<LoanBuckets>((ref) async {
  final loanRepository = ref.watch(loanRepositoryProvider);
  final activeUser = await ref.watch(activeUserProvider.future);
  final details = await loanRepository.getAllLoanDetails();
  final now = DateTime.now();

  if (activeUser == null) {
    final history = details
        .where((detail) => _historyStatuses.contains(detail.loan.status))
        .toList();
    return LoanBuckets(
      incoming: const [],
      outgoing: const [],
      history: history,
      dueSoon: _buildDueSoon(details, now),
    );
  }

  final incoming = <LoanDetail>[];
  final outgoing = <LoanDetail>[];
  final history = <LoanDetail>[];

  for (final detail in details) {
    final loan = detail.loan;
    final status = loan.status;

    final isOwner = loan.lenderUserId == activeUser.id;
    final isBorrower = loan.borrowerUserId == activeUser.id;

    if (status == 'requested') {
      if (isOwner) {
        incoming.add(detail);
      } else if (isBorrower) {
        outgoing.add(detail);
      }
      continue;
    }

    if (status == 'active') {
      if (isOwner) {
        incoming.add(detail);
      }
      if (isBorrower) {
        outgoing.add(detail);
      }
      continue;
    }

    if (_historyStatuses.contains(status) && (isOwner || isBorrower)) {
      history.add(detail);
    }
  }

  return LoanBuckets(
    incoming: incoming,
    outgoing: outgoing,
    history: history,
    dueSoon: _buildDueSoon(details, now),
  );
});

const _historyStatuses = {'returned', 'cancelled', 'rejected', 'expired'};

List<LoanDetail> _buildDueSoon(List<LoanDetail> all, DateTime now) {
  final dueList = all
      .where(
        (detail) =>
            detail.loan.status == 'active' &&
            detail.loan.dueDate != null &&
            detail.loan.dueDate!.isAfter(now),
      )
      .toList()
    ..sort((a, b) => a.loan.dueDate!.compareTo(b.loan.dueDate!));

  return dueList.take(5).toList();
}
