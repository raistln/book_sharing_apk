import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/group_dao.dart';
import 'book_providers.dart';

/// Provides a stream of all loan details for the active user
final allLoansProvider = StreamProvider.autoDispose<List<LoanDetail>>((ref) {
  final repository = ref.watch(loanRepositoryProvider);
  final activeUser = ref.watch(activeUserProvider).value;

  if (activeUser == null) {
    return Stream.value([]);
  }

  // We need to access the DAO directly or via repository if exposed
  // Since repository doesn't expose the stream directly yet, we might need to add it there
  // or access the DAO. Given LoanRepository holds _groupDao privately,
  // we should add a method to LoanRepository to expose this stream.

  return repository.watchAllLoansForUser(activeUser.id);
});

/// Incoming requests: Loans where I am the lender and status is 'requested'
final incomingLoanRequestsProvider =
    Provider.autoDispose<List<LoanDetail>>((ref) {
  final allLoans = ref.watch(allLoansProvider).value ?? [];
  final activeUser = ref.watch(activeUserProvider).value;

  if (activeUser == null) return [];

  return allLoans.where((detail) {
    return detail.loan.lenderUserId == activeUser.id &&
        detail.loan.status == 'requested';
  }).toList();
});

/// Outgoing requests: Loans where I am the borrower and status is 'requested'
final outgoingLoanRequestsProvider =
    Provider.autoDispose<List<LoanDetail>>((ref) {
  final allLoans = ref.watch(allLoansProvider).value ?? [];
  final activeUser = ref.watch(activeUserProvider).value;

  if (activeUser == null) return [];

  return allLoans.where((detail) {
    return detail.loan.borrowerUserId == activeUser.id &&
        detail.loan.status == 'requested';
  }).toList();
});

/// Active loans as lender: Loans where I am the lender and status is 'active'
/// Includes manual loans (where borrowerUserId might be null)
final activeLoansAsLenderProvider =
    Provider.autoDispose<List<LoanDetail>>((ref) {
  final allLoans = ref.watch(allLoansProvider).value ?? [];
  final activeUser = ref.watch(activeUserProvider).value;

  if (activeUser == null) return [];

  return allLoans.where((detail) {
    // Exclude books that I "borrowed externally" (where I am lender proxy but book is external)
    final isExternalBorrowing = detail.book?.isBorrowedExternal == true;
    return detail.loan.lenderUserId == activeUser.id &&
        detail.loan.status == 'active' &&
        !isExternalBorrowing;
  }).toList();
});

/// Active loans as borrower: Loans where I am the borrower and status is 'active'
final activeLoansAsBorrowerProvider =
    Provider.autoDispose<List<LoanDetail>>((ref) {
  final allLoans = ref.watch(allLoansProvider).value ?? [];
  final activeUser = ref.watch(activeUserProvider).value;

  if (activeUser == null) return [];

  return allLoans.where((detail) {
    return detail.loan.borrowerUserId == activeUser.id &&
        detail.loan.status == 'active';
  }).toList();
});

/// Loan history: Loans where status is 'completed', 'returned', 'rejected', 'cancelled', or 'expired'
/// Only shows loans involving the active user in valid roles for history
final loanHistoryProvider = Provider.autoDispose<List<LoanDetail>>((ref) {
  final allLoans = ref.watch(allLoansProvider).value ?? [];

  // Define history statuses - 'completed' is the final state when both parties confirm return
  const historyStatuses = {
    'completed',
    'returned',
    'rejected',
    'cancelled',
    'expired'
  };

  final history = allLoans.where((detail) {
    return historyStatuses.contains(detail.loan.status);
  }).toList();

  history.sort((a, b) {
    final aDate = a.loan.updatedAt;
    final bDate = b.loan.updatedAt;
    return bDate.compareTo(aDate); // Descending
  });

  return history;
});

/// Successful loan history: Active and completed loans (excludes rejected/cancelled)
final successfulLoanHistoryProvider =
    Provider.autoDispose<List<LoanDetail>>((ref) {
  final allLoans = ref.watch(allLoansProvider).value ?? [];

  const validStatuses = {
    'active',
    'returned',
    'completed',
    'expired',
  };

  final history = allLoans.where((detail) {
    return validStatuses.contains(detail.loan.status);
  }).toList();

  history.sort((a, b) {
    final aDate = a.loan.updatedAt;
    final bDate = b.loan.updatedAt;
    return bDate.compareTo(aDate); // Descending
  });

  return history;
});
