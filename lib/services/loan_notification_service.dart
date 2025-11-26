import 'package:drift/drift.dart';

import '../data/local/database.dart';
import '../data/local/group_dao.dart';

/// Service responsible for managing loan-related notifications
/// Monitors loan status changes and creates appropriate notifications
class LoanNotificationService {
  LoanNotificationService({
    required GroupDao groupDao,
  }) : _groupDao = groupDao;

  final GroupDao _groupDao;

  AppDatabase get _db => _groupDao.attachedDatabase;

  /// Creates a notification for a loan request
  Future<void> notifyLoanRequested({
    required int loanId,
    required int borrowerUserId,
    required int lenderUserId,
  }) async {
    await _createNotification(
      loanId: loanId,
      userId: lenderUserId,
      type: 'loan_requested',
      title: 'Nueva solicitud de préstamo',
      message: 'Tienes una nueva solicitud de préstamo pendiente',
    );
  }

  /// Creates a notification for a loan approval
  Future<void> notifyLoanApproved({
    required int loanId,
    required int borrowerUserId,
    required int lenderUserId,
  }) async {
    await _createNotification(
      loanId: loanId,
      userId: borrowerUserId,
      type: 'loan_approved',
      title: 'Préstamo aprobado',
      message: 'Tu solicitud de préstamo ha sido aprobada',
    );
  }

  /// Creates a notification for a loan rejection
  Future<void> notifyLoanRejected({
    required int loanId,
    required int borrowerUserId,
    required int lenderUserId,
  }) async {
    await _createNotification(
      loanId: loanId,
      userId: borrowerUserId,
      type: 'loan_rejected',
      title: 'Préstamo rechazado',
      message: 'Tu solicitud de préstamo ha sido rechazada',
    );
  }

  /// Creates a notification for a loan cancellation
  Future<void> notifyLoanCancelled({
    required int loanId,
    required int borrowerUserId,
    required int lenderUserId,
  }) async {
    await _createNotification(
      loanId: loanId,
      userId: lenderUserId,
      type: 'loan_cancelled',
      title: 'Solicitud cancelada',
      message: 'El solicitante ha cancelado la solicitud de préstamo',
    );
  }

  /// Creates a notification for a borrower return confirmation
  Future<void> notifyBorrowerReturned({
    required int loanId,
    required int borrowerUserId,
    required int lenderUserId,
  }) async {
    await _createNotification(
      loanId: loanId,
      userId: lenderUserId,
      type: 'borrower_returned',
      title: 'Devolución pendiente de confirmación',
      message: 'El prestatario ha marcado el libro como devuelto. Por favor confirma la devolución.',
    );
  }

  /// Creates a notification for a lender return confirmation
  Future<void> notifyLenderReturned({
    required int loanId,
    required int borrowerUserId,
    required int lenderUserId,
  }) async {
    await _createNotification(
      loanId: loanId,
      userId: borrowerUserId,
      type: 'lender_returned',
      title: 'Devolución pendiente de confirmación',
      message: 'El propietario ha marcado el libro como devuelto. Por favor confirma la devolución.',
    );
  }

  /// Creates a notification for a completed return (both parties confirmed)
  Future<void> notifyReturnCompleted({
    required int loanId,
    required int borrowerUserId,
    required int lenderUserId,
  }) async {
    // Notify both parties
    await _createNotification(
      loanId: loanId,
      userId: borrowerUserId,
      type: 'return_completed',
      title: 'Devolución completada',
      message: 'La devolución del libro ha sido confirmada por ambas partes',
    );

    await _createNotification(
      loanId: loanId,
      userId: lenderUserId,
      type: 'return_completed',
      title: 'Devolución completada',
      message: 'La devolución del libro ha sido confirmada por ambas partes',
    );
  }

  /// Creates a notification for an expired loan
  Future<void> notifyLoanExpired({
    required int loanId,
    required int borrowerUserId,
    required int lenderUserId,
  }) async {
    // Notify both parties
    await _createNotification(
      loanId: loanId,
      userId: borrowerUserId,
      type: 'loan_expired',
      title: 'Préstamo expirado',
      message: 'Tu préstamo ha expirado. Por favor devuelve el libro.',
    );

    await _createNotification(
      loanId: loanId,
      userId: lenderUserId,
      type: 'loan_expired',
      title: 'Préstamo expirado',
      message: 'Un préstamo ha expirado. Contacta al prestatario.',
    );
  }

  /// Creates a notification for an upcoming due date
  Future<void> notifyDueSoon({
    required int loanId,
    required int borrowerUserId,
    required int lenderUserId,
    required DateTime dueDate,
  }) async {
    final daysUntilDue = dueDate.difference(DateTime.now()).inDays;
    
    await _createNotification(
      loanId: loanId,
      userId: borrowerUserId,
      type: 'loan_due_soon',
      title: 'Préstamo próximo a vencer',
      message: 'Tu préstamo vence en $daysUntilDue días',
    );
  }

  /// Internal method to create a notification
  Future<void> _createNotification({
    required int loanId,
    required int userId,
    required String type,
    required String title,
    required String message,
  }) async {
    final now = DateTime.now();

    await _db.into(_db.loanNotifications).insert(
      LoanNotificationsCompanion.insert(
        uuid: '', // Will be generated by database
        loanId: loanId,
        userId: userId,
        type: type,
        title: title,
        message: message,
        status: const Value('unread'),
        isDirty: const Value(true),
        createdAt: Value(now),
      ),
    );
  }

  /// Marks all notifications for a loan as read
  Future<void> markLoanNotificationsAsRead(int loanId) async {
    final now = DateTime.now();

    await (_db.update(_db.loanNotifications)
          ..where((tbl) => tbl.loanId.equals(loanId)))
        .write(
      LoanNotificationsCompanion(
        status: const Value('read'),
        readAt: Value(now),
        isDirty: const Value(true),
      ),
    );
  }

  /// Marks all notifications for a loan as dismissed
  Future<void> markLoanNotificationsAsDismissed(int loanId) async {
    await (_db.update(_db.loanNotifications)
          ..where((tbl) => tbl.loanId.equals(loanId)))
        .write(
      const LoanNotificationsCompanion(
        status: Value('dismissed'),
        isDirty: Value(true),
      ),
    );
  }

  /// Gets all unread notifications for a user
  Future<List<LoanNotification>> getUnreadNotifications(int userId) async {
    return await (_db.select(_db.loanNotifications)
          ..where((tbl) => tbl.userId.equals(userId) & tbl.status.equals('unread'))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]))
        .get();
  }

  /// Gets all notifications for a loan
  Future<List<LoanNotification>> getLoanNotifications(int loanId) async {
    return await (_db.select(_db.loanNotifications)
          ..where((tbl) => tbl.loanId.equals(loanId))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]))
        .get();
  }

  /// Watches unread notification count for a user
  Stream<int> watchUnreadCount(int userId) {
    final query = _db.select(_db.loanNotifications)
      ..where((tbl) => tbl.userId.equals(userId) & tbl.status.equals('unread'));

    return query.watch().map((notifications) => notifications.length);
  }

  /// Watches all notifications for a user
  Stream<List<LoanNotification>> watchUserNotifications(int userId) {
    return (_db.select(_db.loanNotifications)
          ..where((tbl) => tbl.userId.equals(userId))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]))
        .watch();
  }
}
