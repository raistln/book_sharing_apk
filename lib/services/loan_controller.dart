import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/database.dart';
import '../data/models/in_app_notification_status.dart';
import '../data/models/in_app_notification_type.dart';
import '../data/repositories/loan_repository.dart';
import '../data/repositories/notification_repository.dart';
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
    required NotificationRepository notificationRepository,
  })  : _loanRepository = loanRepository,
        _groupSyncController = groupSyncController,
        _notificationClient = notificationClient,
        _notificationRepository = notificationRepository,
        super(const LoanActionState());

  final LoanRepository _loanRepository;
  final GroupSyncController _groupSyncController;
  final NotificationClient _notificationClient;
  final NotificationRepository _notificationRepository;

  static const Duration _dueSoonLeadTime = Duration(hours: 24);

  void dismissError() {
    state = state.copyWith(lastError: () => null);
  }

  void dismissSuccess() {
    state = state.copyWith(lastSuccess: () => null);
  }

  Future<Loan> createManualLoan({
    required SharedBook sharedBook,
    required LocalUser owner,
    required String borrowerName,
    required DateTime dueDate,
    String? borrowerContact,
  }) async {
    state = state.copyWith(isLoading: true, lastError: () => null, lastSuccess: () => null);
    try {
      final result = await _loanRepository.createManualLoan(
        sharedBook: sharedBook,
        owner: owner,
        borrowerName: borrowerName,
        dueDate: dueDate,
        borrowerContact: borrowerContact,
      );
      _groupSyncController.markPendingChanges();
      state = state.copyWith(
        isLoading: false,
        lastSuccess: () => 'Préstamo manual registrado.',
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
      
      // Mark group sync as pending (includes loans)
      _groupSyncController.markPendingChanges();
      
      // Wait for loan to sync to Supabase before creating notification
      // This prevents FK constraint violations
      await _groupSyncController.syncGroups();
      
      // Now create the notification (it will reference the synced loan)
      await _notifyLoanRequest(
        loan: loan,
        sharedBook: sharedBook,
        borrower: borrower,
      );
      
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
      await _notifyLoanCancelled(
        loan: result,
        borrower: borrower,
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
      await _cancelLoanNotifications(result);
      await _notifyLoanRejected(
        loan: result,
        owner: owner,
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
      await _notifyLoanAccepted(
        loan: result,
        owner: owner,
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
      await _notifyLoanReturned(
        loan: result,
        actor: actor,
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
      await _cancelLoanNotifications(result);
      await _notifyLoanExpired(result);
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

    if (loan.status != 'active') {
      return;
    }

    final sharedBook = await _loanRepository.findSharedBookById(loan.sharedBookId);

    final payload = <String, String>{
      NotificationPayloadKeys.loanId: loan.uuid,
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

  Future<void> _notifyLoanRequest({
    required Loan loan,
    required SharedBook sharedBook,
    required LocalUser borrower,
  }) async {
    await _runNotificationTask(() async {
      final message = await _messageWithBook(
        loan: loan,
        sharedBook: sharedBook,
        fallback: '${borrower.username} solicitó un préstamo.',
        withTitle: (title) => '${borrower.username} quiere pedir prestado "$title".',
      );

      await _notificationRepository.createLoanNotification(
        type: InAppNotificationType.loanRequested,
        loan: loan,
        targetUserId: sharedBook.ownerUserId,
        actorUserId: borrower.id,
        title: 'Nueva solicitud de préstamo',
        message: message,
      );
    });
  }

  Future<void> _notifyLoanCancelled({
    required Loan loan,
    required LocalUser borrower,
  }) async {
    await _runNotificationTask(() async {
      await _notificationRepository.markLoanNotifications(
        loanId: loan.id,
        status: InAppNotificationStatus.dismissed,
      );

      final message = await _messageWithBook(
        loan: loan,
        fallback: '${borrower.username} canceló la solicitud de préstamo.',
        withTitle: (title) => '${borrower.username} canceló la solicitud para "$title".',
      );

      await _notificationRepository.createLoanNotification(
        type: InAppNotificationType.loanCancelled,
        loan: loan,
        targetUserId: loan.lenderUserId,
        actorUserId: borrower.id,
        title: 'Solicitud de préstamo cancelada',
        message: message,
      );
    });
  }

  Future<void> _notifyLoanRejected({
    required Loan loan,
    required LocalUser owner,
  }) async {
    await _runNotificationTask(() async {
      // Only notify if borrower has an account (not a manual loan)
      if (loan.borrowerUserId == null) return;

      await _notificationRepository.markLoanNotifications(
        loanId: loan.id,
        status: InAppNotificationStatus.dismissed,
      );

      final message = await _messageWithBook(
        loan: loan,
        fallback: '${owner.username} rechazó tu solicitud de préstamo.',
        withTitle: (title) => '${owner.username} rechazó tu solicitud para "$title".',
      );

      await _notificationRepository.createLoanNotification(
        type: InAppNotificationType.loanRejected,
        loan: loan,
        targetUserId: loan.borrowerUserId!,
        actorUserId: owner.id,
        title: 'Solicitud de préstamo rechazada',
        message: message,
      );
    });
  }

  Future<void> _notifyLoanAccepted({
    required Loan loan,
    required LocalUser owner,
  }) async {
    await _runNotificationTask(() async {
      // Only notify if borrower has an account (not a manual loan)
      if (loan.borrowerUserId == null) return;

      await _notificationRepository.markLoanNotifications(
        loanId: loan.id,
        status: InAppNotificationStatus.dismissed,
      );

      final message = await _messageWithBook(
        loan: loan,
        fallback: '${owner.username} aceptó tu solicitud de préstamo.',
        withTitle: (title) => '${owner.username} aceptó tu solicitud para "$title".',
      );

      await _notificationRepository.createLoanNotification(
        type: InAppNotificationType.loanApproved,
        loan: loan,
        targetUserId: loan.borrowerUserId!,
        actorUserId: owner.id,
        title: 'Préstamo aceptado',
        message: message,
      );
    });
  }

  Future<void> _notifyLoanReturned({
    required Loan loan,
    required LocalUser actor,
  }) async {
    await _runNotificationTask(() async {
      await _notificationRepository.markLoanNotifications(
        loanId: loan.id,
        status: InAppNotificationStatus.read,
      );

      // Determine counterpart: if actor is borrower, notify owner; if actor is owner, notify borrower
      final int? counterpartId = actor.id == loan.borrowerUserId ? loan.lenderUserId : loan.borrowerUserId;
      
      // Don't notify if counterpart is null (manual loan) or is the same as actor
      if (counterpartId == null || counterpartId == actor.id) {
        return;
      }

      final message = await _messageWithBook(
        loan: loan,
        fallback: '${actor.username} marcó el préstamo como devuelto.',
        withTitle: (title) => '${actor.username} marcó como devuelto "$title".',
      );

      await _notificationRepository.createLoanNotification(
        type: InAppNotificationType.loanReturned,
        loan: loan,
        targetUserId: counterpartId,
        actorUserId: actor.id,
        title: 'Préstamo marcado como devuelto',
        message: message,
      );
    });
  }

  Future<void> _notifyLoanExpired(Loan loan) async {
    await _runNotificationTask(() async {
      await _notificationRepository.markLoanNotifications(
        loanId: loan.id,
        status: InAppNotificationStatus.read,
      );

      // Only notify borrower if they have an account (not a manual loan)
      if (loan.borrowerUserId != null) {
        final borrowerMessage = await _messageWithBook(
          loan: loan,
          fallback: 'Tu préstamo ha expirado.',
          withTitle: (title) => 'Tu préstamo de "$title" ha expirado.',
        );

        await _notificationRepository.createLoanNotification(
          type: InAppNotificationType.loanExpired,
          loan: loan,
          targetUserId: loan.borrowerUserId!,
          title: 'Préstamo expirado',
          message: borrowerMessage,
        );
      }

      final ownerMessage = await _messageWithBook(
        loan: loan,
        fallback: 'Un préstamo pendiente ha expirado.',
        withTitle: (title) => 'El préstamo de "$title" ha expirado.',
      );

      await _notificationRepository.createLoanNotification(
        type: InAppNotificationType.loanExpired,
        loan: loan,
        targetUserId: loan.lenderUserId,
        title: 'Préstamo expirado',
        message: ownerMessage,
      );
    });
  }

  Future<String> _messageWithBook({
    required Loan loan,
    SharedBook? sharedBook,
    required String fallback,
    required String Function(String title) withTitle,
  }) async {
    final bookTitle = await _resolveBookTitle(
      sharedBookId: loan.sharedBookId,
      sharedBook: sharedBook,
    );

    if (bookTitle != null && bookTitle.isNotEmpty) {
      return withTitle(bookTitle);
    }
    return fallback;
  }

  Future<String?> _resolveBookTitle({
    required int sharedBookId,
    SharedBook? sharedBook,
  }) async {
    final localShared = sharedBook ?? await _loanRepository.findSharedBookById(sharedBookId);
    if (localShared == null) {
      return null;
    }

    final book = await _loanRepository.findBookById(localShared.bookId);
    return book?.title;
  }

  Future<void> _runNotificationTask(Future<void> Function() task) async {
    try {
      await task();
    } catch (error, stackTrace) {
      // Always log, not just in debug mode
      developer.log(
        'Notification task failed: $error',
        name: 'LoanController',
        error: error,
        stackTrace: stackTrace,
        level: 900,
      );
    }
  }
}
