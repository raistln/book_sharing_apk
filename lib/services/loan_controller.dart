import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/database.dart';
import '../data/repositories/loan_repository.dart';
import 'group_sync_controller.dart';
import 'notification_service.dart';

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
    required NotificationClient notificationClient,
  })  : _loanRepository = loanRepository,
        _groupSyncController = groupSyncController,
        _notificationClient = notificationClient,
        super(const LoanActionState());

  final LoanRepository _loanRepository;
  final GroupSyncController _groupSyncController;
  final NotificationClient _notificationClient;

  static const Duration _dueSoonLeadTime = Duration(hours: 24);

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
      await _cancelLoanNotifications(result);
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
      await _cancelLoanNotifications(result);
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
      await _scheduleLoanNotifications(result);
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
      await _cancelLoanNotifications(result);
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
      await _cancelLoanNotifications(result);
      return result;
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        lastError: () => error.toString(),
      );
      rethrow;
    }
  }

  Future<void> _scheduleLoanNotifications(Loan loan) async {
    final dueDate = loan.dueDate;
    final uuid = loan.uuid;
    if (dueDate == null || uuid.isEmpty) {
      return;
    }

    final dueSoonId = NotificationIds.loanDueSoon(uuid);
    final expiredId = NotificationIds.loanExpired(uuid);
    await _notificationClient.cancelMany([dueSoonId, expiredId]);

    if (loan.status != 'accepted') {
      return;
    }

    final sharedBook = await _loanRepository.findSharedBookById(loan.sharedBookId);

    final payload = <String, String>{
      NotificationPayloadKeys.loanId: loan.uuid,
      NotificationPayloadKeys.sharedBookUuid: loan.sharedBookUuid,
      NotificationPayloadKeys.sharedBookId: loan.sharedBookId.toString(),
      if (sharedBook != null)
        NotificationPayloadKeys.groupId: sharedBook.groupId.toString(),
    };

    final now = DateTime.now();

    if (dueDate.isAfter(now)) {
      final dueSoonAt = dueDate.subtract(_dueSoonLeadTime);
      if (dueSoonAt.isAfter(now)) {
        await _notificationClient.schedule(
          id: dueSoonId,
          type: NotificationType.loanDueSoon,
          title: 'Préstamo próximo a vencer',
          body: 'Tu préstamo vencerá pronto.',
          scheduledAt: dueSoonAt,
          payload: payload,
        );
      } else {
        await _notificationClient.showImmediate(
          id: dueSoonId,
          type: NotificationType.loanDueSoon,
          title: 'Préstamo próximo a vencer',
          body: 'Tu préstamo vencerá pronto.',
          payload: payload,
        );
      }

      await _notificationClient.schedule(
        id: expiredId,
        type: NotificationType.loanExpired,
        title: 'Préstamo vencido',
        body: 'Tu préstamo ha llegado a su fecha límite.',
        scheduledAt: dueDate,
        payload: payload,
      );
    } else {
      await _notificationClient.showImmediate(
        id: expiredId,
        type: NotificationType.loanExpired,
        title: 'Préstamo vencido',
        body: 'Tu préstamo ha llegado a su fecha límite.',
        payload: payload,
      );
    }
  }

  Future<void> _cancelLoanNotifications(Loan loan) async {
    final uuid = loan.uuid;
    if (uuid.isEmpty) {
      return;
    }
    await _notificationClient.cancelMany([
      NotificationIds.loanDueSoon(uuid),
      NotificationIds.loanExpired(uuid),
    ]);
  }
}
