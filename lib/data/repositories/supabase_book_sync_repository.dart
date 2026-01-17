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

  /// Mapea visibility y isAvailable de Supabase al status local
  String _mapVisibilityToStatus(String? visibility, bool? isAvailable) {
    // Si es privado, el status es 'private'
    if (visibility == 'private') {
      return 'private';
    }

    // Si está archivado, el status es 'archived'
    if (visibility == 'archived') {
      return 'archived';
    }

    // Para libros públicos/ grupales, usar isAvailable
    if (isAvailable == true) {
      return 'available';
    } else {
      return 'loaned';
    }
  }

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
      accessToken: accessToken,
    );

    final db = _bookDao.attachedDatabase;
    final now = DateTime.now();

    await db.transaction(() async {
      for (final remote in remoteBooks) {
        final existingByRemote = await _bookDao.findByRemoteId(remote.id);
        final existing =
            existingByRemote ?? await _bookDao.findByUuid(remote.id);

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
              author:
                  (remote.author != null && remote.author!.trim().isNotEmpty)
                      ? Value(remote.author!.trim())
                      : const Value.absent(),
              isbn: (remote.isbn != null && remote.isbn!.trim().isNotEmpty)
                  ? Value(remote.isbn!.trim())
                  : const Value.absent(),
              coverPath: Value(remote.coverUrl),
              status: Value(_mapVisibilityToStatus(
                  remote.visibility, remote.isAvailable)),
              notes: const Value(null), // Notes not stored in shared_books
              isRead: Value(remote.isRead),
              isDeleted: Value(remote.isDeleted),
              genre: Value(remote.genre),
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
          // Triple-check for duplicates before inserting:
          // 1. By UUID (already checked above)
          // 2. By remoteId (already checked above)
          // 3. By title + author + ISBN combination to catch any edge cases
          var existingByContent = await _bookDao.findByTitleAndAuthor(
            remote.title,
            remote.author ?? '',
            ownerUserId: owner.id,
          );

          // If found by title+author, also verify ISBN matches if both have ISBN
          if (existingByContent != null &&
              remote.isbn != null &&
              existingByContent.isbn != null) {
            if (existingByContent.isbn != remote.isbn) {
              // Different ISBN, might be different edition - allow as separate book
              existingByContent = null;
            }
          }

          // Final check: ensure we're not about to create a duplicate
          final finalCheck = await _bookDao.findByUuid(remote.id);
          if (finalCheck == null && existingByContent == null) {
            await _bookDao.insertBook(
              BooksCompanion.insert(
                uuid: remote.id,
                remoteId: Value(remote.id),
                ownerUserId: Value(owner.id),
                ownerRemoteId: Value(ownerRemoteId),
                title: remote.title,
                author:
                    (remote.author != null && remote.author!.trim().isNotEmpty)
                        ? Value(remote.author!.trim())
                        : const Value.absent(),
                isbn: (remote.isbn != null && remote.isbn!.trim().isNotEmpty)
                    ? Value(remote.isbn!.trim())
                    : const Value.absent(),
                coverPath: Value(remote.coverUrl),
                status: Value(_mapVisibilityToStatus(
                    remote.visibility, remote.isAvailable)),
                notes: const Value(null), // Notes not stored in shared_books
                isRead: Value(remote.isRead),
                isDeleted: Value(remote.isDeleted),
                genre: Value(remote.genre),
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
          } else if (finalCheck != null) {
            developer.log(
              'Libro ${remote.id} ya existe (encontrado en verificación final), omitiendo inserción.',
              name: 'SupabaseBookSyncRepository',
            );
          } else if (existingByContent != null) {
            developer.log(
              'Libro "${remote.title}" por "${remote.author}" ya existe localmente como ID ${existingByContent.id}, reutilizando.',
              name: 'SupabaseBookSyncRepository',
            );
            // Update the existing book's UUID and remoteId to match remote
            // This prevents future sync attempts from creating duplicates
            await _bookDao.updateBookFields(
              bookId: existingByContent.id,
              entry: BooksCompanion(
                uuid: Value(remote.id), // Update UUID to match remote
                remoteId: Value(remote.id), // Update remoteId to match remote
                syncedAt: Value(now),
                isDirty: const Value(false),
              ),
            );
          }
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
    // Books are handled by GroupSyncController, but Reviews are handled here.

    final dirtyReviews = await _bookDao.getDirtyReviews();
    if (dirtyReviews.isEmpty) {
      return;
    }

    developer.log(
      'Pushing ${dirtyReviews.length} dirty reviews...',
      name: 'SupabaseBookSyncRepository',
    );

    final ownerRemoteId = owner.remoteId;
    if (ownerRemoteId == null) {
      developer.log(
        'Cannot push reviews: User has no remote ID.',
        name: 'SupabaseBookSyncRepository',
      );
      return;
    }

    for (final review in dirtyReviews) {
      // Ensure we have a remote book ID
      final book = await _bookDao.findById(review.bookId);
      final bookRemoteId = book?.remoteId;

      if (book == null || bookRemoteId == null) {
        developer.log(
          'Skipping review ${review.id}: Associated book not synced/found.',
          name: 'SupabaseBookSyncRepository',
        );
        continue;
      }

      try {
        if (review.remoteId == null) {
          // CREATE
          final remoteId = await _bookService.createReview(
            id: review.uuid,
            bookId: bookRemoteId,
            authorId: ownerRemoteId,
            rating: review.rating,
            review: review.review,
            isDeleted: review.isDeleted == true,
            createdAt: review.createdAt,
            updatedAt: review.updatedAt,
            accessToken: accessToken,
          );

          await _bookDao.updateReviewFields(
            reviewId: review.id,
            entry: BookReviewsCompanion(
              remoteId: Value(remoteId),
              syncedAt: Value(DateTime.now()),
              isDirty: const Value(false),
            ),
          );
        } else {
          // UPDATE
          await _bookService.updateReview(
            id: review.remoteId!,
            rating: review.rating,
            review: review.review,
            isDeleted: review.isDeleted == true,
            updatedAt: review.updatedAt,
            accessToken: accessToken,
          );

          await _bookDao.updateReviewFields(
            reviewId: review.id,
            entry: BookReviewsCompanion(
              syncedAt: Value(DateTime.now()),
              isDirty: const Value(false),
            ),
          );
        }
      } catch (e, st) {
        developer.log(
          'Error syncing review ${review.id}',
          name: 'SupabaseBookSyncRepository',
          error: e,
          stackTrace: st,
        );
      }
    }
  }
}
