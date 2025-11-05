import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/database.dart';
import '../data/repositories/loan_repository.dart';
import 'group_sync_controller.dart';

class LoanActionState {
  const LoanActionState({
    this.isLoading = false,
    this.lastError,
    this.lastSuccess,
  });

  final bool isLoading;
  final String? lastError;
  final String? lastSuccess;

  LoanActionState copyWith({
    bool? isLoading,
    ValueGetter<String?>? lastError,
    ValueGetter<String?>? lastSuccess,
  }) {
    return LoanActionState(
      isLoading: isLoading ?? this.isLoading,
      lastError: lastError != null ? lastError() : this.lastError,
      lastSuccess: lastSuccess != null ? lastSuccess() : this.lastSuccess,
    );
  }
}

class LoanController extends StateNotifier<LoanActionState> {
  LoanController({
    required LoanRepository loanRepository,
    required GroupSyncController groupSyncController,
  })  : _loanRepository = loanRepository,
        _groupSyncController = groupSyncController,
        super(const LoanActionState());

  final LoanRepository _loanRepository;
  final GroupSyncController _groupSyncController;

  void dismissError() {
    state = state.copyWith(lastError: () => null);
  }

  void dismissSuccess() {
    state = state.copyWith(lastSuccess: () => null);
  }

  Future<Loan> requestLoan({
    required SharedBook sharedBook,
    required LocalUser borrower,
    DateTime? dueDate,
  }) async {
    state = state.copyWith(isLoading: true, lastError: () => null, lastSuccess: () => null);
    try {
      final loan = await _loanRepository.requestLoan(
        sharedBook: sharedBook,
        borrower: borrower,
        dueDate: dueDate,
      );
      _groupSyncController.markPendingChanges();
      state = state.copyWith(
        isLoading: false,
        lastSuccess: () => 'Solicitud enviada.',
      );
      return loan;
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        lastError: () => error.toString(),
      );
      rethrow;
    }
  }

  Future<Loan> cancelLoan({
    required Loan loan,
    required LocalUser borrower,
  }) async {
    state = state.copyWith(isLoading: true, lastError: () => null, lastSuccess: () => null);
    try {
      final result = await _loanRepository.cancelLoan(
        loan: loan,
        borrower: borrower,
      );
      _groupSyncController.markPendingChanges();
      state = state.copyWith(
        isLoading: false,
        lastSuccess: () => 'Solicitud cancelada.',
      );
      return result;
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        lastError: () => error.toString(),
      );
      rethrow;
    }
  }

  Future<Loan> rejectLoan({
    required Loan loan,
    required LocalUser owner,
  }) async {
    state = state.copyWith(isLoading: true, lastError: () => null, lastSuccess: () => null);
    try {
      final result = await _loanRepository.rejectLoan(
        loan: loan,
        owner: owner,
      );
      _groupSyncController.markPendingChanges();
      state = state.copyWith(
        isLoading: false,
        lastSuccess: () => 'Solicitud rechazada.',
      );
      return result;
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        lastError: () => error.toString(),
      );
      rethrow;
    }
  }

  Future<Loan> acceptLoan({
    required Loan loan,
    required LocalUser owner,
  }) async {
    state = state.copyWith(isLoading: true, lastError: () => null, lastSuccess: () => null);
    try {
      final result = await _loanRepository.acceptLoan(
        loan: loan,
        owner: owner,
      );
      _groupSyncController.markPendingChanges();
      state = state.copyWith(
        isLoading: false,
        lastSuccess: () => 'Préstamo aceptado.',
      );
      return result;
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        lastError: () => error.toString(),
      );
      rethrow;
    }
  }

  Future<Loan> markReturned({
    required Loan loan,
    required LocalUser actor,
  }) async {
    state = state.copyWith(isLoading: true, lastError: () => null, lastSuccess: () => null);
    try {
      final result = await _loanRepository.markReturned(
        loan: loan,
        actor: actor,
      );
      _groupSyncController.markPendingChanges();
      state = state.copyWith(
        isLoading: false,
        lastSuccess: () => 'Préstamo marcado como devuelto.',
      );
      return result;
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        lastError: () => error.toString(),
      );
      rethrow;
    }
  }

  Future<Loan> expireLoan({
    required Loan loan,
  }) async {
    state = state.copyWith(isLoading: true, lastError: () => null, lastSuccess: () => null);
    try {
      final result = await _loanRepository.expireLoan(loan: loan);
      _groupSyncController.markPendingChanges();
      state = state.copyWith(
        isLoading: false,
        lastSuccess: () => 'Préstamo marcado como expirado.',
      );
      return result;
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        lastError: () => error.toString(),
      );
      rethrow;
    }
  }
}
