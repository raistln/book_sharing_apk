import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../local/book_dao.dart';
import '../local/database.dart';
import '../local/group_dao.dart';
import '../local/user_dao.dart';

class LoanException implements Exception {
  const LoanException(this.message);

  final String message;

  @override
  String toString() => 'LoanException: $message';
}

class LoanRepository {
  LoanRepository({
    required GroupDao groupDao,
    required BookDao bookDao,
    required UserDao userDao,
    Uuid? uuid,
  })  : _groupDao = groupDao,
        _bookDao = bookDao,
        _userDao = userDao,
        _uuid = uuid ?? const Uuid();

  final GroupDao _groupDao;
  final BookDao _bookDao;
  final UserDao _userDao;
  final Uuid _uuid;

  AppDatabase get _db => _groupDao.attachedDatabase;

  Future<Loan> requestLoan({
    required SharedBook sharedBook,
    required LocalUser borrower,
    DateTime? dueDate,
  }) async {
    final owner = await _requireUser(sharedBook.ownerUserId);

    if (borrower.id == owner.id) {
      throw const LoanException('No puedes solicitar un préstamo de tu propio libro.');
    }

    if (!sharedBook.isAvailable) {
      throw const LoanException('El libro compartido no está disponible para préstamo.');
    }

    final now = DateTime.now();

    return _db.transaction(() async {
      final loanId = await _groupDao.insertLoan(
        LoansCompanion.insert(
          uuid: _uuid.v4(),
          sharedBookId: sharedBook.id,
          sharedBookUuid: sharedBook.uuid,
          fromUserId: Value(borrower.id),
          fromRemoteId: borrower.remoteId != null
              ? Value(borrower.remoteId)
              : const Value.absent(),
          toUserId: owner.id,
          toRemoteId: owner.remoteId != null
              ? Value(owner.remoteId)
              : const Value.absent(),
          status: const Value('pending'),
          startDate: Value(now),
          dueDate: dueDate != null ? Value(dueDate) : const Value.absent(),
          returnedAt: const Value<DateTime?>(null),
          cancelledAt: const Value<DateTime?>(null),
          isDirty: const Value(true),
          isDeleted: const Value(false),
          syncedAt: const Value<DateTime?>(null),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );

      final inserted = await _groupDao.findLoanById(loanId);
      if (inserted == null) {
        throw const LoanException('No se pudo crear el préstamo.');
      }
      return inserted;
    });
  }

  Future<Loan> createManualLoan({
    required SharedBook sharedBook,
    required LocalUser owner,
    required String borrowerName,
    required DateTime dueDate,
    String? borrowerContact,
  }) async {
    if (borrowerName.trim().isEmpty) {
      throw const LoanException('El nombre del prestatario es requerido.');
    }

    if (!sharedBook.isAvailable) {
      throw const LoanException('El libro compartido no está disponible para préstamo.');
    }

    final book = await _requireBook(sharedBook.bookId);
    final now = DateTime.now();

    return _db.transaction(() async {
      final loanId = await _groupDao.insertLoan(
        LoansCompanion.insert(
          uuid: _uuid.v4(),
          sharedBookId: sharedBook.id,
          sharedBookUuid: sharedBook.uuid,
          fromUserId: const Value<int?>(null), // No user for manual loans
          fromRemoteId: const Value.absent(),
          toUserId: owner.id,
          toRemoteId: owner.remoteId != null
              ? Value(owner.remoteId)
              : const Value.absent(),
          externalBorrowerName: Value(borrowerName.trim()),
          externalBorrowerContact: borrowerContact != null
              ? Value(borrowerContact.trim())
              : const Value.absent(),
          status: const Value('loaned'), // Goes directly to loaned
          dueDate: Value(dueDate),
          startDate: Value(now),
          isDirty: const Value(true),
          isDeleted: const Value(false),
          syncedAt: const Value<DateTime?>(null),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );

      await _groupDao.updateSharedBookFields(
        sharedBookId: sharedBook.id,
        entry: SharedBooksCompanion(
          isAvailable: const Value(false),
          isDirty: const Value(true),
          syncedAt: const Value<DateTime?>(null),
          updatedAt: Value(now),
        ),
      );

      await _bookDao.updateBookFields(
        bookId: book.id,
        entry: BooksCompanion(
          status: const Value('loaned'),
          isDirty: const Value(true),
          syncedAt: const Value<DateTime?>(null),
          updatedAt: Value(now),
        ),
      );

      final inserted = await _groupDao.findLoanById(loanId);
      if (inserted == null) {
        throw const LoanException('No se pudo crear el préstamo manual.');
      }
      return inserted;
    });
  }

  Future<Loan> cancelLoan({
    required Loan loan,
    required LocalUser borrower,
  }) async {
    final current = await _requireLoan(loan.id);

    if (current.status != 'pending') {
      throw const LoanException('Solo los préstamos pendientes se pueden cancelar.');
    }

    if (current.fromUserId != borrower.id) {
      throw const LoanException('Solo el solicitante puede cancelar el préstamo.');
    }

    final now = DateTime.now();

    await _db.transaction(() async {
      await _groupDao.updateLoanStatus(
        loanId: current.id,
        entry: LoansCompanion(
          status: const Value('cancelled'),
          cancelledAt: Value(now),
          returnedAt: const Value<DateTime?>(null),
          isDirty: const Value(true),
          syncedAt: const Value<DateTime?>(null),
          updatedAt: Value(now),
        ),
      );
    });

    return _requireLoan(current.id);
  }

  Future<Loan> rejectLoan({
    required Loan loan,
    required LocalUser owner,
  }) async {
    final current = await _requireLoan(loan.id);

    if (current.status != 'pending') {
      throw const LoanException('Solo los préstamos pendientes se pueden rechazar.');
    }

    if (current.toUserId != owner.id) {
      throw const LoanException('Solo el propietario puede rechazar la solicitud.');
    }

    final now = DateTime.now();

    await _db.transaction(() async {
      await _groupDao.updateLoanStatus(
        loanId: current.id,
        entry: LoansCompanion(
          status: const Value('rejected'),
          returnedAt: const Value<DateTime?>(null),
          cancelledAt: const Value<DateTime?>(null),
          isDirty: const Value(true),
          syncedAt: const Value<DateTime?>(null),
          updatedAt: Value(now),
        ),
      );
    });

    return _requireLoan(current.id);
  }

  Future<Loan> acceptLoan({
    required Loan loan,
    required LocalUser owner,
  }) async {
    final current = await _requireLoan(loan.id);

    if (current.status != 'pending') {
      throw const LoanException('Solo los préstamos pendientes se pueden aceptar.');
    }

    if (current.toUserId != owner.id) {
      throw const LoanException('Solo el propietario puede aceptar la solicitud.');
    }

    final sharedBook = await _requireSharedBook(current.sharedBookId);
    final now = DateTime.now();

    await _db.transaction(() async {
      await _groupDao.updateLoanStatus(
        loanId: current.id,
        entry: LoansCompanion(
          status: const Value('accepted'),
          startDate: Value(now),
          returnedAt: const Value<DateTime?>(null),
          cancelledAt: const Value<DateTime?>(null),
          isDirty: const Value(true),
          syncedAt: const Value<DateTime?>(null),
          updatedAt: Value(now),
        ),
      );

      await _groupDao.updateSharedBookFields(
        sharedBookId: sharedBook.id,
        entry: SharedBooksCompanion(
          isAvailable: const Value(false),
          isDirty: const Value(true),
          syncedAt: const Value<DateTime?>(null),
          updatedAt: Value(now),
        ),
      );

      // Note: Book status is NOT set to 'loaned' here
      // It will be set when markAsLoaned is called after physical handoff
    });

    return _requireLoan(current.id);
  }

  Future<Loan> markAsLoaned({
    required Loan loan,
    required LocalUser actor,
    required DateTime dueDate,
  }) async {
    final current = await _requireLoan(loan.id);

    if (current.status != 'accepted') {
      throw const LoanException('Solo los préstamos aceptados se pueden marcar como prestados.');
    }

    // Verify actor is owner or borrower
    if (actor.id != current.toUserId && actor.id != current.fromUserId) {
      throw const LoanException('Solo el propietario o el solicitante pueden marcar como prestado.');
    }

    final sharedBook = await _requireSharedBook(current.sharedBookId);
    final book = await _requireBook(sharedBook.bookId);
    final now = DateTime.now();

    await _db.transaction(() async {
      await _groupDao.updateLoanStatus(
        loanId: current.id,
        entry: LoansCompanion(
          status: const Value('loaned'),
          dueDate: Value(dueDate),
          isDirty: const Value(true),
          syncedAt: const Value<DateTime?>(null),
          updatedAt: Value(now),
        ),
      );

      await _bookDao.updateBookFields(
        bookId: book.id,
        entry: BooksCompanion(
          status: const Value('loaned'),
          isDirty: const Value(true),
          syncedAt: const Value<DateTime?>(null),
          updatedAt: Value(now),
        ),
      );
    });

    return _requireLoan(current.id);
  }

  Future<Loan> markReturned({
    required Loan loan,
    required LocalUser actor,
  }) async {
    final current = await _requireLoan(loan.id);

    if (current.status != 'loaned') {
      throw const LoanException('Solo los préstamos activos se pueden marcar como devueltos.');
    }

    if (actor.id != current.toUserId && actor.id != current.fromUserId) {
      throw const LoanException('Solo el propietario o el solicitante pueden cerrar el préstamo.');
    }

    final sharedBook = await _requireSharedBook(current.sharedBookId);
    final book = await _requireBook(sharedBook.bookId);
    final now = DateTime.now();

    await _db.transaction(() async {
      await _groupDao.updateLoanStatus(
        loanId: current.id,
        entry: LoansCompanion(
          status: const Value('returned'),
          returnedAt: Value(now),
          cancelledAt: const Value<DateTime?>(null),
          isDirty: const Value(true),
          syncedAt: const Value<DateTime?>(null),
          updatedAt: Value(now),
        ),
      );

      await _groupDao.updateSharedBookFields(
        sharedBookId: sharedBook.id,
        entry: SharedBooksCompanion(
          isAvailable: const Value(true),
          isDirty: const Value(true),
          syncedAt: const Value<DateTime?>(null),
          updatedAt: Value(now),
        ),
      );

      await _bookDao.updateBookFields(
        bookId: book.id,
        entry: BooksCompanion(
          status: const Value('available'),
          isDirty: const Value(true),
          syncedAt: const Value<DateTime?>(null),
          updatedAt: Value(now),
        ),
      );
    });

    return _requireLoan(current.id);
  }

  Future<Loan> expireLoan({required Loan loan}) async {
    final current = await _requireLoan(loan.id);

    if (current.status != 'accepted') {
      throw const LoanException('Solo los préstamos aceptados se pueden marcar como expirados.');
    }

    final sharedBook = await _requireSharedBook(current.sharedBookId);
    final book = await _requireBook(sharedBook.bookId);
    final now = DateTime.now();

    await _db.transaction(() async {
      await _groupDao.updateLoanStatus(
        loanId: current.id,
        entry: LoansCompanion(
          status: const Value('expired'),
          returnedAt: const Value<DateTime?>(null),
          cancelledAt: const Value<DateTime?>(null),
          isDirty: const Value(true),
          syncedAt: const Value<DateTime?>(null),
          updatedAt: Value(now),
        ),
      );

      await _groupDao.updateSharedBookFields(
        sharedBookId: sharedBook.id,
        entry: SharedBooksCompanion(
          isAvailable: const Value(true),
          isDirty: const Value(true),
          syncedAt: const Value<DateTime?>(null),
          updatedAt: Value(now),
        ),
      );

      await _bookDao.updateBookFields(
        bookId: book.id,
        entry: BooksCompanion(
          status: const Value('available'),
          isDirty: const Value(true),
          syncedAt: const Value<DateTime?>(null),
          updatedAt: Value(now),
        ),
      );
    });

    return _requireLoan(current.id);
  }

  Future<List<LoanDetail>> getAllLoanDetails() {
    return _groupDao.getAllLoanDetails();
  }

  Future<Loan?> findLoanById(int id) {
    return _groupDao.findLoanById(id);
  }

  Future<Loan?> findLoanByUuid(String uuid) {
    return _groupDao.findLoanByUuid(uuid);
  }

  Future<SharedBook?> findSharedBookById(int id) {
    return _groupDao.findSharedBookById(id);
  }

  Future<Book?> findBookById(int id) {
    return _bookDao.findById(id);
  }

  Future<LocalUser?> findUserById(int id) {
    return _userDao.getById(id);
  }

  Future<Loan> _requireLoan(int id) async {
    final loan = await _groupDao.findLoanById(id);
    if (loan == null) {
      throw const LoanException('Préstamo no encontrado.');
    }
    return loan;
  }

  Future<SharedBook> _requireSharedBook(int id) async {
    final sharedBook = await _groupDao.findSharedBookById(id);
    if (sharedBook == null) {
      throw const LoanException('Libro compartido no encontrado.');
    }
    return sharedBook;
  }

  Future<Book> _requireBook(int id) async {
    final book = await _bookDao.findById(id);
    if (book == null) {
      throw const LoanException('Libro local no encontrado.');
    }
    return book;
  }

  Future<LocalUser> _requireUser(int? id) async {
    if (id == null) {
      throw const LoanException('No hay propietario asignado al libro.');
    }
    final user = await _userDao.getById(id);
    if (user == null) {
      throw const LoanException('Usuario local no encontrado.');
    }
    return user;
  }
}
