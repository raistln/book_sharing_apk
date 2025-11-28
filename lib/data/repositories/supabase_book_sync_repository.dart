import 'dart:developer' as developer;

import 'package:drift/drift.dart';

import '../local/book_dao.dart';
import '../local/database.dart';
import '../../services/supabase_book_service.dart';

class SupabaseBookSyncRepository {
  SupabaseBookSyncRepository({
    required BookDao bookDao,
    SupabaseBookService? bookService,
  })  : _bookDao = bookDao,
        _bookService = bookService ?? SupabaseBookService();

  final BookDao _bookDao;
  final SupabaseBookService _bookService;

  Future<void> syncFromRemote({
    required LocalUser owner,
    String? accessToken,
  }) async {
    final ownerRemoteId = owner.remoteId;
    if (ownerRemoteId == null) {
      developer.log(
        'No se puede sincronizar libros: el usuario activo no tiene remoteId.',
        name: 'SupabaseBookSyncRepository',
        level: 900,
      );
      return;
    }

    developer.log(
      'Descargando libros y reseñas para usuario $ownerRemoteId.',
      name: 'SupabaseBookSyncRepository',
    );

    final remoteBooks = await _bookService.fetchBooks(
      ownerId: ownerRemoteId,
      accessToken: accessToken,
    );
    final remoteReviews = await _bookService.fetchReviews(
      authorId: ownerRemoteId,
      accessToken: accessToken,
    );

    final db = _bookDao.attachedDatabase;
    final now = DateTime.now();

    await db.transaction(() async {
      for (final remote in remoteBooks) {
        final existingByRemote = await _bookDao.findByRemoteId(remote.id);
        final existing = existingByRemote ?? await _bookDao.findByUuid(remote.id);

        if (existing != null) {
          if (existing.isDirty) {
            await _bookDao.updateBookFields(
              bookId: existing.id,
              entry: BooksCompanion(
                remoteId: existing.remoteId == null
                    ? Value(remote.id)
                    : const Value<String?>.absent(),
                syncedAt: Value(now),
              ),
            );
            developer.log(
              'Saltando libro ${existing.title} por cambios locales pendientes.',
              name: 'SupabaseBookSyncRepository',
            );
            continue;
          }

          await _bookDao.updateBookFields(
            bookId: existing.id,
            entry: BooksCompanion(
              remoteId: Value(remote.id),
              ownerUserId: Value(owner.id),
              ownerRemoteId: Value(ownerRemoteId),
              title: Value(remote.title),
              author: Value(remote.author),
              isbn: Value(remote.isbn),
              coverPath: Value(remote.coverUrl),
              status: Value(remote.isAvailable == true ? 'available' : 'loaned'),
              notes: const Value(null), // Notes not stored in shared_books
              isDeleted: Value(remote.isDeleted),
              isDirty: const Value(false),
              syncedAt: Value(now),
              updatedAt: Value(remote.updatedAt ?? remote.createdAt),
            ),
          );
          developer.log(
            'Libro remoto ${remote.title} reconciliado con registro local (id: ${existing.id}).',
            name: 'SupabaseBookSyncRepository',
          );
        } else {
          await _bookDao.insertBook(
            BooksCompanion.insert(
              uuid: remote.id,
              remoteId: Value(remote.id),
              ownerUserId: Value(owner.id),
              ownerRemoteId: Value(ownerRemoteId),
              title: remote.title,
              author: Value(remote.author),
              isbn: Value(remote.isbn),
              coverPath: Value(remote.coverUrl),
              status: Value(remote.isAvailable == true ? 'available' : 'loaned'),
              notes: const Value(null), // Notes not stored in shared_books
              isDeleted: Value(remote.isDeleted),
              isDirty: const Value(false),
              createdAt: Value(remote.createdAt),
              updatedAt: Value(remote.updatedAt ?? remote.createdAt),
              syncedAt: Value(now),
            ),
          );
          developer.log(
            'Libro remoto ${remote.title} insertado localmente.',
            name: 'SupabaseBookSyncRepository',
          );
        }
      }

      for (final remote in remoteReviews) {
        final book = await _bookDao.findByRemoteId(remote.bookId);
        if (book == null) {
          developer.log(
            'Reseña remota ${remote.id} ignorada: libro ${remote.bookId} no encontrado localmente.',
            name: 'SupabaseBookSyncRepository',
            level: 800,
          );
          continue;
        }

        final existingByRemote = await _bookDao.findReviewByRemoteId(remote.id);
        final existing = existingByRemote ??
            await _bookDao.findReviewForUser(
              bookId: book.id,
              authorUserId: owner.id,
            );

        if (existing != null) {
          if (existing.isDirty) {
            await _bookDao.updateReviewFields(
              reviewId: existing.id,
              entry: BookReviewsCompanion(
                remoteId: existing.remoteId == null
                    ? Value(remote.id)
                    : const Value<String?>.absent(),
                syncedAt: Value(now),
              ),
            );
            developer.log(
              'Reseña local ${existing.id} mantiene cambios pendientes, se omite actualización remota.',
              name: 'SupabaseBookSyncRepository',
            );
            continue;
          }

          await _bookDao.updateReviewFields(
            reviewId: existing.id,
            entry: BookReviewsCompanion(
              remoteId: Value(remote.id),
              rating: Value(remote.rating),
              review: Value(remote.review),
              isDeleted: Value(remote.isDeleted),
              isDirty: const Value(false),
              syncedAt: Value(now),
              updatedAt: Value(remote.updatedAt ?? remote.createdAt),
            ),
          );
          developer.log(
            'Reseña remota ${remote.id} reconciliada (local id: ${existing.id}).',
            name: 'SupabaseBookSyncRepository',
          );
        } else {
          await _bookDao.insertReview(
            BookReviewsCompanion.insert(
              uuid: remote.id,
              remoteId: Value(remote.id),
              bookId: book.id,
              bookUuid: book.uuid,
              authorUserId: owner.id,
              authorRemoteId: Value(ownerRemoteId),
              rating: remote.rating,
              review: Value(remote.review),
              isDeleted: Value(remote.isDeleted),
              isDirty: const Value(false),
              createdAt: Value(remote.createdAt),
              updatedAt: Value(remote.updatedAt ?? remote.createdAt),
              syncedAt: Value(now),
            ),
          );
          developer.log(
            'Reseña remota ${remote.id} insertada localmente.',
            name: 'SupabaseBookSyncRepository',
          );
        }
      }
    });
  }

  Future<void> pushLocalChanges({
    required LocalUser owner,
    String? accessToken,
  }) async {
    final ownerRemoteId = owner.remoteId;
    if (ownerRemoteId == null) {
      developer.log(
        'No se puede subir libros: el usuario activo no tiene remoteId.',
        name: 'SupabaseBookSyncRepository',
        level: 900,
      );
      return;
    }

    final dirtyBooks = await _bookDao.getDirtyBooks();
    final dirtyReviews = await _bookDao.getDirtyReviews();

    if (dirtyBooks.isEmpty && dirtyReviews.isEmpty) {
      developer.log(
        'No hay libros ni reseñas con cambios pendientes.',
        name: 'SupabaseBookSyncRepository',
      );
      return;
    }

    final syncTime = DateTime.now();
    developer.log(
      'Sincronizando ${dirtyBooks.length} libro(s) y ${dirtyReviews.length} reseña(s) con Supabase.',
      name: 'SupabaseBookSyncRepository',
    );

    for (final book in dirtyBooks) {
      final bookOwnerRemoteId = book.ownerRemoteId ?? ownerRemoteId;
      if (bookOwnerRemoteId.isEmpty) {
        developer.log(
          'Se omite libro ${book.title} por no tener ownerRemoteId.',
          name: 'SupabaseBookSyncRepository',
          level: 900,
        );
        continue;
      }

      final provisionalRemoteId = book.remoteId ?? book.uuid;
      try {
        var ensuredRemoteId = provisionalRemoteId;

        if (book.remoteId == null) {
          developer.log(
            'Creando libro remoto ${book.title} (uuid: ${book.uuid}).',
            name: 'SupabaseBookSyncRepository',
          );
          ensuredRemoteId = await _bookService.createBook(
            id: provisionalRemoteId,
            ownerId: bookOwnerRemoteId,
            title: book.title,
            author: book.author,
            isbn: book.isbn,
            coverUrl: book.coverPath,
            status: book.status,
            notes: book.notes,
            isDeleted: book.isDeleted,
            createdAt: book.createdAt,
            updatedAt: book.updatedAt,
            accessToken: accessToken,
          );
        } else {
          final updated = await _bookService.updateBook(
            id: provisionalRemoteId,
            title: book.title,
            author: book.author,
            isbn: book.isbn,
            coverUrl: book.coverPath,
            status: book.status,
            notes: book.notes,
            isDeleted: book.isDeleted,
            updatedAt: book.updatedAt,
            accessToken: accessToken,
          );

          if (!updated) {
            developer.log(
              'Libro ${book.title} no encontrado remotamente, se crea.',
              name: 'SupabaseBookSyncRepository',
            );
            ensuredRemoteId = await _bookService.createBook(
              id: provisionalRemoteId,
              ownerId: bookOwnerRemoteId,
              title: book.title,
              author: book.author,
              isbn: book.isbn,
              coverUrl: book.coverPath,
              status: book.status,
              notes: book.notes,
              isDeleted: book.isDeleted,
              createdAt: book.createdAt,
              updatedAt: book.updatedAt,
              accessToken: accessToken,
            );
          }
        }

        await _bookDao.updateBookFields(
          bookId: book.id,
          entry: BooksCompanion(
            remoteId: Value(ensuredRemoteId),
            ownerRemoteId: Value(bookOwnerRemoteId),
            isDirty: const Value(false),
            syncedAt: Value(syncTime),
          ),
        );
        developer.log(
          'Libro ${book.title} sincronizado con éxito (remoteId: $ensuredRemoteId).',
          name: 'SupabaseBookSyncRepository',
        );
      } catch (error) {
        developer.log(
          'Error subiendo libro ${book.title}: $error',
          name: 'SupabaseBookSyncRepository',
          level: 1000,
        );
        rethrow;
      }
    }

    for (final review in dirtyReviews) {
      final book = await _bookDao.findById(review.bookId);
      if (book == null) {
        developer.log(
          'Se omite reseña ${review.id}: libro local ${review.bookId} no encontrado.',
          name: 'SupabaseBookSyncRepository',
          level: 900,
        );
        continue;
      }

      final remoteBookId =
          (book.remoteId != null && book.remoteId!.isNotEmpty) ? book.remoteId! : book.uuid;
      final authorRemoteId = (review.authorRemoteId != null && review.authorRemoteId!.isNotEmpty)
          ? review.authorRemoteId!
          : ownerRemoteId;

      if (remoteBookId.isEmpty || authorRemoteId.isEmpty) {
        developer.log(
          'Se omite reseña ${review.id} por faltar remoteId de libro o autor.',
          name: 'SupabaseBookSyncRepository',
          level: 900,
        );
        continue;
      }

      final provisionalRemoteId = review.remoteId ?? review.uuid;
      try {
        var ensuredRemoteId = provisionalRemoteId;

        if (review.remoteId == null) {
          developer.log(
            'Creando reseña remota ${review.id} para libro $remoteBookId.',
            name: 'SupabaseBookSyncRepository',
          );
          ensuredRemoteId = await _bookService.createReview(
            id: provisionalRemoteId,
            bookId: remoteBookId,
            authorId: authorRemoteId,
            rating: review.rating,
            review: review.review,
            isDeleted: review.isDeleted,
            createdAt: review.createdAt,
            updatedAt: review.updatedAt,
            accessToken: accessToken,
          );
        } else {
          final updated = await _bookService.updateReview(
            id: provisionalRemoteId,
            rating: review.rating,
            review: review.review,
            isDeleted: review.isDeleted,
            updatedAt: review.updatedAt,
            accessToken: accessToken,
          );

          if (!updated) {
            developer.log(
              'Reseña ${review.id} no existe en remoto, se crea.',
              name: 'SupabaseBookSyncRepository',
            );
            ensuredRemoteId = await _bookService.createReview(
              id: provisionalRemoteId,
              bookId: remoteBookId,
              authorId: authorRemoteId,
              rating: review.rating,
              review: review.review,
              isDeleted: review.isDeleted,
              createdAt: review.createdAt,
              updatedAt: review.updatedAt,
              accessToken: accessToken,
            );
          }
        }

        await _bookDao.updateReviewFields(
          reviewId: review.id,
          entry: BookReviewsCompanion(
            remoteId: Value(ensuredRemoteId),
            authorRemoteId: Value(authorRemoteId),
            isDirty: const Value(false),
            syncedAt: Value(syncTime),
          ),
        );
        developer.log(
          'Reseña ${review.id} sincronizada correctamente (remoteId: $ensuredRemoteId).',
          name: 'SupabaseBookSyncRepository',
        );
      } catch (error) {
        developer.log(
          'Error subiendo reseña ${review.id}: $error',
          name: 'SupabaseBookSyncRepository',
          level: 1000,
        );
        rethrow;
      }
    }
  }
}
