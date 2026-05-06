import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/database.dart';
import '../data/models/in_app_notification_status.dart';
import '../data/models/in_app_notification_type.dart';
import '../data/repositories/loan_repository.dart';
import '../data/repositories/notification_repository.dart';
import '../models/global_sync_state.dart';
import 'notification_service.dart';
import 'unified_sync_coordinator.dart';
import '../l10n/generated/app_localizations.dart';

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
    required NotificationClient notificationClient,
    required NotificationRepository notificationRepository,
    required UnifiedSyncCoordinator syncCoordinator,
    required this.s,
  })  : _loanRepository = loanRepository,
        _notificationClient = notificationClient,
        _notificationRepository = notificationRepository,
        _syncCoordinator = syncCoordinator,
        super(const LoanActionState());

  final LoanRepository _loanRepository;
  final NotificationClient _notificationClient;
  final NotificationRepository _notificationRepository;
  final UnifiedSyncCoordinator _syncCoordinator;
  final S s;

  static const Duration _dueSoonLeadTime = Duration(hours: 24);

  void dismissError() {
    state = state.copyWith(lastError: () => null);
  }

  void dismissSuccess() {
    state = state.copyWith(lastSuccess: () => null);
  }

  /// Checks for active loans that are upcoming or expired and creates in-app notifications.
  Future<void> checkUpcomingLoans() async {
    try {
      final loans = await _loanRepository.getAllLoanDetails();
      final now = DateTime.now();
      final sevenDaysFromNow = now.add(const Duration(days: 7));

      for (final detail in loans) {
        final loan = detail.loan;
        if (loan.status != 'active' || loan.dueDate == null) continue;

        final dueDate = loan.dueDate!;

        // Check for expiration
        if (dueDate.isBefore(now)) {
          // Solo notificar una vez al día
          final today = DateTime(now.year, now.month, now.day);
          final existing = await _notificationRepository.findRecentByType(
            type: InAppNotificationType.loanExpired,
            loanId: loan.id,
            since: today,
          );

          if (existing == null) {
            await _notifyLoanExpired(loan);
          }
          continue;
        }

        // Check for "Due Soon" (7 days)
        // We trigger this if the due date is within the next 7 days
        // and we haven't notified for this specific loan yet.
        // For simplicity, we can check if a notification of type loan_due_soon exists for this loan.
        if (dueDate.isBefore(sevenDaysFromNow)) {
          // Solo notificar una vez al día para evitar spam en cada sincronización
          final today = DateTime(now.year, now.month, now.day);
          final existing = await _notificationRepository.findRecentByType(
            type: InAppNotificationType.loanDueSoon,
            loanId: loan.id,
            since: today,
          );

          if (existing == null) {
            await _notifyLoanDueSoon(loan);
          }
        }
      }
    } catch (e, stack) {
      developer.log('Error checking upcoming loans: $e',
          name: 'LoanController', error: e, stackTrace: stack);
    }
  }

  Future<void> _notifyLoanDueSoon(Loan loan) async {
    await _runNotificationTask(() async {
      final message = await _messageWithBook(
        loan: loan,
        fallback: s.notificationLoanDueSoonBody,
        withTitle: (title) => s.notificationLoanDueSoonBodyWithTitle(title),
      );

      await _notificationRepository.createLoanNotification(
        type: InAppNotificationType.loanDueSoon,
        loan: loan,
        targetUserId: loan.borrowerUserId ?? loan.lenderUserId,
        title: s.notificationLoanDueSoonTitle,
        message: message,
      );
    });
  }

  Future<Loan> createManualLoan({
    required SharedBook sharedBook,
    required LocalUser owner,
    required String borrowerName,
    required DateTime dueDate,
    String? borrowerContact,
  }) async {
    if (kDebugMode) {
      debugPrint(
          '[LOAN CONTROLLER] Creating manual loan for book ${sharedBook.bookUuid}');
      debugPrint(
          '[LOAN CONTROLLER] Borrower: $borrowerName, Owner ID: ${owner.id}');
    }

    state = state.copyWith(
        isLoading: true, lastError: () => null, lastSuccess: () => null);
    try {
      final result = await _loanRepository.createManualLoan(
        sharedBook: sharedBook,
        owner: owner,
        borrowerName: borrowerName,
        dueDate: dueDate,
        borrowerContact: borrowerContact,
      );
      // Evento crítico: sincronizar inmediatamente
      await _syncCoordinator.syncOnCriticalEvent(SyncEvent.loanCreated);
      state = state.copyWith(
        isLoading: false,
        lastSuccess: () => s.loanManualRegistered,
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

  Future<Loan> receiveExternalLoan({
    required LocalUser user,
    required String title,
    required String author,
    required String lenderName,
    required DateTime dueDate,
    String? lenderContact,
    String? isbn,
    String? coverPath,
  }) async {
    state = state.copyWith(
        isLoading: true, lastError: () => null, lastSuccess: () => null);
    try {
      final result = await _loanRepository.createReceivedExternalLoan(
        user: user,
        title: title,
        author: author,
        lenderName: lenderName,
        dueDate: dueDate,
        lenderContact: lenderContact,
        isbn: isbn,
        coverPath: coverPath,
      );
      // Evento crítico: sincronizar inmediatamente
      await _syncCoordinator.syncOnCriticalEvent(SyncEvent.loanCreated);
      state = state.copyWith(
        isLoading: false,
        lastSuccess: () => s.loanExternalRegistered,
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
    state = state.copyWith(
        isLoading: true, lastError: () => null, lastSuccess: () => null);
    try {
      final loan = await _loanRepository.requestLoan(
        sharedBook: sharedBook,
        borrower: borrower,
        dueDate: dueDate,
      );

      // Evento crítico: sincronizar inmediatamente antes de crear notificación
      // Esto previene violaciones de FK constraints
      await _syncCoordinator.syncOnCriticalEvent(SyncEvent.loanCreated);

      // Now create the notification (it will reference the synced loan)
      await _notifyLoanRequest(
        loan: loan,
        sharedBook: sharedBook,
        borrower: borrower,
      );

      state = state.copyWith(
        isLoading: false,
        lastSuccess: () => s.loanRequestSent,
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
    state = state.copyWith(
        isLoading: true, lastError: () => null, lastSuccess: () => null);
    try {
      final result = await _loanRepository.cancelLoan(
        loan: loan,
        borrower: borrower,
      );
      // Evento crítico: sincronizar inmediatamente
      await _syncCoordinator.syncOnCriticalEvent(SyncEvent.loanCancelled);
      state = state.copyWith(
        isLoading: false,
        lastSuccess: () => s.loanRequestCancelled,
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
    state = state.copyWith(
        isLoading: true, lastError: () => null, lastSuccess: () => null);
    try {
      final result = await _loanRepository.rejectLoan(
        loan: loan,
        owner: owner,
      );
      // Marcar cambios (no crítico, usa debouncing normal)
      _syncCoordinator.markPendingChanges(SyncEntity.loans,
          priority: SyncPriority.medium);
      _syncCoordinator.markPendingChanges(SyncEntity.books,
          priority: SyncPriority.medium);
      _syncCoordinator.markPendingChanges(SyncEntity.groups,
          priority: SyncPriority.medium);
      state = state.copyWith(
        isLoading: false,
        lastSuccess: () => s.loanRequestRejected,
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
    DateTime? dueDate,
  }) async {
    state = state.copyWith(
        isLoading: true, lastError: () => null, lastSuccess: () => null);
    try {
      final now = DateTime.now();
      if (dueDate != null && dueDate.isBefore(now)) {
        throw Exception(s.errorLoanDueDatePast);
      }

      final result = await _loanRepository.acceptLoan(
        loan: loan,
        owner: owner,
        dueDate: dueDate,
      );
      // Marcar cambios (no crítico, usa debouncing normal)
      _syncCoordinator.markPendingChanges(SyncEntity.loans,
          priority: SyncPriority.medium);
      _syncCoordinator.markPendingChanges(SyncEntity.books,
          priority: SyncPriority.medium);
      _syncCoordinator.markPendingChanges(SyncEntity.groups,
          priority: SyncPriority.medium);
      state = state.copyWith(
        isLoading: false,
        lastSuccess: () => s.loanRequestAccepted,
      );
      await _notifyLoanAccepted(
        loan: result,
        owner: owner,
      );
      await _scheduleLoanNotifications(result);
      return result;
    } catch (error) {
      // Check for specific RPC race condition errors
      final msg = error.toString().toLowerCase();
      String? userFriendlyError;

      if (msg.contains('cancelled') || msg.contains('cancelado')) {
        userFriendlyError = s.errorLoanCancelledByOther;
      } else if (msg.contains('already currently on loan') ||
          msg.contains('ya se encuentra prestado')) {
        userFriendlyError = s.errorLoanAlreadyActive;
      } else if (msg.contains('not in requested state') ||
          msg.contains('no se encuentra en estado')) {
        userFriendlyError = s.errorLoanInvalidState;
      }

      state = state.copyWith(
        isLoading: false,
        lastError: () => userFriendlyError ?? error.toString(),
      );
      rethrow;
    }
  }

  Future<Loan> markReturned({
    required Loan loan,
    required LocalUser actor,
    bool? wasRead,
  }) async {
    state = state.copyWith(
        isLoading: true, lastError: () => null, lastSuccess: () => null);
    try {
      final result = await _loanRepository.markReturned(
        loan: loan,
        actor: actor,
        wasRead: wasRead,
      );
      // Evento crítico: sincronizar inmediatamente
      await _syncCoordinator.syncOnCriticalEvent(SyncEvent.loanReturned);
      state = state.copyWith(
        isLoading: false,
        lastSuccess: () => s.loanMarkedReturned,
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
    state = state.copyWith(
        isLoading: true, lastError: () => null, lastSuccess: () => null);
    try {
      final result = await _loanRepository.expireLoan(loan: loan);
      // Marcar cambios (no crítico, usa debouncing normal)
      _syncCoordinator.markPendingChanges(SyncEntity.loans,
          priority: SyncPriority.medium);
      _syncCoordinator.markPendingChanges(SyncEntity.books,
          priority: SyncPriority.medium);
      _syncCoordinator.markPendingChanges(SyncEntity.groups,
          priority: SyncPriority.medium);
      state = state.copyWith(
        isLoading: false,
        lastSuccess: () => s.loanMarkedExpired,
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

    final sharedBook =
        await _loanRepository.findSharedBookById(loan.sharedBookId!);

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
          title: s.notificationLoanDueSoonTitle,
          body: s.notificationLoanDueSoonBody,
          scheduledAt: dueSoonAt,
          payload: payload,
        );
      } else {
        await _notificationClient.showImmediate(
          id: dueSoonId,
          type: NotificationType.loanDueSoon,
          title: s.notificationLoanDueSoonTitle,
          body: s.notificationLoanDueSoonBody,
          payload: payload,
        );
      }

      await _notificationClient.schedule(
        id: expiredId,
        type: NotificationType.loanExpired,
        title: s.notificationLoanExpiredTitle,
        body: s.notificationLoanExpiredBody,
        scheduledAt: dueDate,
        payload: payload,
      );
    } else {
      await _notificationClient.showImmediate(
        id: expiredId,
        type: NotificationType.loanExpired,
        title: s.notificationLoanExpiredTitle,
        body: s.notificationLoanExpiredBody,
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
        fallback: s.notificationLoanRequestFallback(borrower.username),
        withTitle: (title) => s.notificationLoanRequestWithTitle(borrower.username, title),
      );

      await _notificationRepository.createLoanNotification(
        type: InAppNotificationType.loanRequested,
        loan: loan,
        targetUserId: sharedBook.ownerUserId,
        actorUserId: borrower.id,
        title: s.notificationLoanRequestTitle,
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
        fallback: s.notificationLoanCancelledFallback(borrower.username),
        withTitle: (title) => s.notificationLoanCancelledWithTitle(borrower.username, title),
      );

      await _notificationRepository.createLoanNotification(
        type: InAppNotificationType.loanCancelled,
        loan: loan,
        targetUserId: loan.lenderUserId,
        actorUserId: borrower.id,
        title: s.notificationLoanCancelledTitle,
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
        fallback: s.notificationLoanRejectedFallback(owner.username),
        withTitle: (title) => s.notificationLoanRejectedWithTitle(owner.username, title),
      );

      await _notificationRepository.createLoanNotification(
        type: InAppNotificationType.loanRejected,
        loan: loan,
        targetUserId: loan.borrowerUserId!,
        actorUserId: owner.id,
        title: s.notificationLoanRejectedTitle,
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
        fallback: s.notificationLoanAcceptedFallback(owner.username),
        withTitle: (title) => s.notificationLoanAcceptedWithTitle(owner.username, title),
      );

      await _notificationRepository.createLoanNotification(
        type: InAppNotificationType.loanApproved,
        loan: loan,
        targetUserId: loan.borrowerUserId!,
        actorUserId: owner.id,
        title: s.notificationLoanAcceptedTitle,
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
      final int? counterpartId = actor.id == loan.borrowerUserId
          ? loan.lenderUserId
          : loan.borrowerUserId;

      // Don't notify if counterpart is null (manual loan) or is the same as actor
      if (counterpartId == null || counterpartId == actor.id) {
        return;
      }

      final message = await _messageWithBook(
        loan: loan,
        fallback: s.notificationLoanReturnedFallback(actor.username),
        withTitle: (title) => s.notificationLoanReturnedWithTitle(actor.username, title),
      );

      await _notificationRepository.createLoanNotification(
        type: InAppNotificationType.loanReturned,
        loan: loan,
        targetUserId: counterpartId,
        actorUserId: actor.id,
        title: s.notificationLoanReturnedTitle,
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
          fallback: s.notificationLoanExpiredBody,
          withTitle: (title) => s.notificationLoanExpiredBodyWithTitle(title),
        );

        await _notificationRepository.createLoanNotification(
          type: InAppNotificationType.loanExpired,
          loan: loan,
          targetUserId: loan.borrowerUserId!,
          title: s.notificationLoanExpiredTitle,
          message: borrowerMessage,
        );
      }

      final ownerMessage = await _messageWithBook(
        loan: loan,
        fallback: s.notificationLoanExpiredBody,
        withTitle: (title) => s.notificationLoanExpiredBodyWithTitle(title),
      );

      await _notificationRepository.createLoanNotification(
        type: InAppNotificationType.loanExpired,
        loan: loan,
        targetUserId: loan.lenderUserId,
        title: s.notificationLoanExpiredTitle,
        message: ownerMessage,
      );
    });
  }

  Future<Loan> createManualLoanDirect({
    required Book book,
    required LocalUser owner,
    required String borrowerName,
    required DateTime dueDate,
    String? borrowerContact,
  }) async {
    state = state.copyWith(
        isLoading: true, lastError: () => null, lastSuccess: () => null);
    try {
      final result = await _loanRepository.createManualLoanDirect(
        book: book,
        owner: owner,
        borrowerName: borrowerName,
        dueDate: dueDate,
        borrowerContact: borrowerContact,
      );
      // Evento crítico: sincronizar inmediatamente
      await _syncCoordinator.syncOnCriticalEvent(SyncEvent.loanCreated);
      state = state.copyWith(
        isLoading: false,
        lastSuccess: () => s.loanManualRegistered,
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

  Future<Loan> ownerForceConfirmReturn({
    required Loan loan,
    required LocalUser owner,
  }) async {
    state = state.copyWith(
        isLoading: true, lastError: () => null, lastSuccess: () => null);
    try {
      final result = await _loanRepository.ownerForceConfirmReturn(
        loan: loan,
        owner: owner,
      );
      await _syncCoordinator.syncOnCriticalEvent(SyncEvent.loanReturned);
      state = state.copyWith(
        isLoading: false,
        lastSuccess: () => s.loanReturnConfirmed,
      );
      await _cancelLoanNotifications(result);
      // No need to notify borrower as this is likely for manual loans or unresponsive borrowers
      return result;
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        lastError: () => error.toString(),
      );
      rethrow;
    }
  }

  Future<void> sendReturnReminder({
    required Loan loan,
    required LocalUser actor,
  }) async {
    // Only for non-manual loans where I'm waiting for the other person
    if (loan.borrowerUserId == null) return;

    state = state.copyWith(
        isLoading: true, lastError: () => null, lastSuccess: () => null);
    try {
      final targetUserId = actor.id == loan.lenderUserId
          ? loan.borrowerUserId!
          : loan.lenderUserId;

      await _runNotificationTask(() async {
        final message = await _messageWithBook(
          loan: loan,
          fallback: s.notificationReturnReminderFallback,
          withTitle: (title) => s.notificationReturnReminderWithTitle(title),
        );

        await _notificationRepository.createLoanNotification(
          type: InAppNotificationType.returnReminderSent,
          loan: loan,
          targetUserId: targetUserId,
          actorUserId: actor.id,
          title: s.notificationReturnReminderTitle,
          message: message,
        );
      });

      state = state.copyWith(
        isLoading: false,
        lastSuccess: () => s.loanReminderSent,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        lastError: () => error.toString(),
      );
      rethrow;
    }
  }

  Future<String> _messageWithBook({
    required Loan loan,
    SharedBook? sharedBook,
    required String fallback,
    required String Function(String title) withTitle,
  }) async {
    final bookTitle = await _resolveBookTitle(
      loan: loan,
      sharedBook: sharedBook,
    );

    if (bookTitle != null && bookTitle.isNotEmpty) {
      return withTitle(bookTitle);
    }
    return fallback;
  }

  Future<String?> _resolveBookTitle({
    required Loan loan,
    SharedBook? sharedBook,
  }) async {
    if (loan.bookId != null) {
      final book = await _loanRepository.findBookById(loan.bookId!);
      return book?.title;
    }

    if (loan.sharedBookId != null) {
      final localShared = sharedBook ??
          await _loanRepository.findSharedBookById(loan.sharedBookId!);
      if (localShared != null) {
        final book = await _loanRepository.findBookById(localShared.bookId);
        return book?.title;
      }
    }
    return null;
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
