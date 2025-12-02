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
    developer.log(
      'pushLocalChanges está deshabilitado en SupabaseBookSyncRepository. '
      'La sincronización de libros se maneja a través de GroupSyncController y SharedBooks.',
      name: 'SupabaseBookSyncRepository',
    );
    return;
  }
}
