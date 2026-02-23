import 'dart:developer' as developer;

import 'package:drift/drift.dart';

import '../local/database.dart';
import '../local/book_dao.dart';
import '../local/timeline_entry_dao.dart';
import '../local/reading_session_dao.dart';
import '../local/wishlist_dao.dart';
import '../../services/supabase_book_service.dart';

class SupabaseBookSyncRepository {
  SupabaseBookSyncRepository({
    required BookDao bookDao,
    required TimelineEntryDao timelineDao,
    required ReadingSessionDao sessionDao,
    required WishlistDao wishlistDao,
    SupabaseBookService? bookService,
  })  : _bookDao = bookDao,
        _timelineDao = timelineDao,
        _sessionDao = sessionDao,
        _wishlistDao = wishlistDao,
        _bookService = bookService ?? SupabaseBookService();

  final BookDao _bookDao;
  final TimelineEntryDao _timelineDao;
  final ReadingSessionDao _sessionDao;
  final WishlistDao _wishlistDao;
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
      '🔄 Starting syncFromRemote for user $ownerRemoteId',
      name: 'SupabaseBookSyncRepository',
    );

    // Fetch last sync timestamps
    final lastSyncedBook = await (_bookDao.attachedDatabase
            .select(_bookDao.attachedDatabase.books)
          ..orderBy([
            (t) => OrderingTerm(expression: t.syncedAt, mode: OrderingMode.desc)
          ])
          ..limit(1))
        .getSingleOrNull();

    final lastSyncedReview = await (_bookDao.attachedDatabase
            .select(_bookDao.attachedDatabase.bookReviews)
          ..orderBy([
            (t) => OrderingTerm(expression: t.syncedAt, mode: OrderingMode.desc)
          ])
          ..limit(1))
        .getSingleOrNull();

    final lastSyncedTimeline = await (_timelineDao.db
            .select(_timelineDao.db.readingTimelineEntries)
          ..orderBy([
            (t) => OrderingTerm(expression: t.syncedAt, mode: OrderingMode.desc)
          ])
          ..limit(1))
        .getSingleOrNull();

    final lastSyncedSession = await (_sessionDao.db
            .select(_sessionDao.db.readingSessions)
          ..orderBy([
            (t) => OrderingTerm(expression: t.syncedAt, mode: OrderingMode.desc)
          ])
          ..limit(1))
        .getSingleOrNull();

    final lastSyncedWishlistItem = await (_wishlistDao.db
            .select(_wishlistDao.db.wishlistItems)
          ..orderBy([
            (t) => OrderingTerm(expression: t.syncedAt, mode: OrderingMode.desc)
          ])
          ..limit(1))
        .getSingleOrNull();

    final remoteBooks = await _bookService.fetchBooks(
      ownerId: ownerRemoteId,
      accessToken: accessToken,
      updatedAfter: lastSyncedBook?.syncedAt,
    );
    developer.log(
      'Fetched ${remoteBooks.length} remote books (updated after ${lastSyncedBook?.syncedAt})',
      name: 'SupabaseBookSyncRepository',
    );

    final remoteReviews = await _bookService.fetchReviews(
      accessToken: accessToken,
      updatedAfter: lastSyncedReview?.syncedAt,
    );
    developer.log(
      'Fetched ${remoteReviews.length} remote reviews (updated after ${lastSyncedReview?.syncedAt})',
      name: 'SupabaseBookSyncRepository',
    );

    final remoteTimeline = await _bookService.fetchTimelineEntries(
      ownerId: ownerRemoteId,
      accessToken: accessToken,
      updatedAfter: lastSyncedTimeline?.syncedAt,
    );
    developer.log(
      'Fetched ${remoteTimeline.length} remote timeline entries (updated after ${lastSyncedTimeline?.syncedAt})',
      name: 'SupabaseBookSyncRepository',
    );

    final remoteSessions = await _bookService.fetchReadingSessions(
      ownerId: ownerRemoteId,
      accessToken: accessToken,
      updatedAfter: lastSyncedSession?.syncedAt,
    );
    developer.log(
      'Fetched ${remoteSessions.length} remote reading sessions (updated after ${lastSyncedSession?.syncedAt})',
      name: 'SupabaseBookSyncRepository',
    );

    final remoteWishlist = await _bookService.fetchWishlistItems(
      userId: ownerRemoteId,
      accessToken: accessToken,
      updatedAfter: lastSyncedWishlistItem?.syncedAt,
    );
    developer.log(
      'Fetched ${remoteWishlist.length} remote wishlist items (updated after ${lastSyncedWishlistItem?.syncedAt})',
      name: 'SupabaseBookSyncRepository',
    );

    final db = _bookDao.attachedDatabase;
    final now = DateTime.now();

    await db.transaction(() async {
      for (final remote in remoteBooks) {
        // Skip books that belong to a group (handled by GroupSyncController)
        if (remote.groupId != null) continue;

        final existingByRemote = await _bookDao.findByRemoteId(remote.id);
        final existing =
            existingByRemote ?? await _bookDao.findByUuid(remote.id);

        if (existing != null) {
          // Verify and correct UUID if needed
          final correctUuid = remote.bookUuid ?? remote.id;
          if (existing.uuid != correctUuid) {
            developer.log(
              'Correcting UUID for book ${existing.title} (ID: ${existing.id}): ${existing.uuid} -> $correctUuid',
              name: 'SupabaseBookSyncRepository',
            );

            // Check if target UUID is already taken by another book
            final conflict = await _bookDao.findByUuid(correctUuid);
            if (conflict != null && conflict.id != existing.id) {
              developer.log(
                'Cannot correct UUID: Target UUID $correctUuid is already used by book ${conflict.id}',
                name: 'SupabaseBookSyncRepository',
                level: 900,
              );
            } else {
              // Update Book UUID
              await _bookDao.updateBookFields(
                bookId: existing.id,
                entry: BooksCompanion(
                  uuid: Value(correctUuid),
                  syncedAt: Value(now),
                ),
              );

              // Update dependent tables (Sessions, Timeline)
              // We access the database directly to perform batch updates
              final db = _bookDao.attachedDatabase;

              // Update ReadingSessions
              await (db.update(db.readingSessions)
                    ..where((t) => t.bookId.equals(existing.id)))
                  .write(
                      ReadingSessionsCompanion(bookUuid: Value(correctUuid)));

              // Update ReadingTimelineEntries
              await (db.update(db.readingTimelineEntries)
                    ..where((t) => t.bookId.equals(existing.id)))
                  .write(ReadingTimelineEntriesCompanion(
                      bookUuid: Value(correctUuid)));

              developer.log(
                'Updated dependent tables for book ${existing.id}',
                name: 'SupabaseBookSyncRepository',
              );
            }
          }

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
              readingStatus: Value(remote.readingStatus ?? 'pending'),
              description: Value(remote.description),
              barcode: Value(remote.barcode),
              readAt: Value(remote.readAt),
              isBorrowedExternal: Value(remote.isBorrowedExternal),
              externalLenderName: Value(remote.externalLenderName),
              isRead: Value(remote.isRead),
              isDeleted: Value(remote.isDeleted),
              genre: Value(remote.genre),
              pageCount: Value(remote.pageCount),
              publicationYear: Value(remote.publicationYear),
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
                uuid: remote.bookUuid ?? remote.id,
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
                readingStatus: Value(remote.readingStatus ?? 'pending'),
                description: Value(remote.description),
                barcode: Value(remote.barcode),
                readAt: Value(remote.readAt),
                isBorrowedExternal: Value(remote.isBorrowedExternal),
                externalLenderName: Value(remote.externalLenderName),
                isRead: Value(remote.isRead),
                isDeleted: Value(remote.isDeleted),
                genre: Value(remote.genre),
                pageCount: Value(remote.pageCount),
                publicationYear: Value(remote.publicationYear),
                isPhysical: Value(remote.isPhysical),
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
                uuid: Value(remote.bookUuid ??
                    remote.id), // Update UUID to match remote
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

      // Sync Timeline Entries
      int timelineCount = 0;
      for (final remote in remoteTimeline) {
        // Find local book by UUID (timeline entries are linked by book_uuid)
        final book = await _bookDao.findByUuid(remote.bookUuid);
        if (book == null) {
          developer.log(
            'Timeline entry ${remote.id} ignorada: libro UUID ${remote.bookUuid} no encontrado.',
            name: 'SupabaseBookSyncRepository',
            level: 800,
          );
          continue;
        }

        final existing = await _timelineDao.findByRemoteId(remote.id);
        if (existing != null) {
          if (!existing.isDirty) {
            await _timelineDao.updateEntryFields(
                existing.id,
                ReadingTimelineEntriesCompanion(
                  remoteId: Value(remote.id),
                  currentPage: Value(remote.currentPage),
                  percentageRead: Value(remote.percentageRead),
                  eventType: Value(remote.eventType),
                  note: Value(remote.note),
                  eventDate: Value(remote.eventDate),
                  isDeleted: Value(remote.isDeleted),
                  syncedAt: Value(now),
                  updatedAt: Value(remote.updatedAt ?? remote.createdAt),
                ));
          }
        } else {
          // Insert new
          await _timelineDao.createEntry(
            bookId: book.id,
            ownerUserId: owner.id,
            eventType: remote.eventType,
            currentPage: remote.currentPage,
            percentageRead: remote.percentageRead,
            note: remote.note,
            eventDate: remote.eventDate,
            remoteId: remote.id,
          );
        }
        timelineCount++;
      }
      developer.log('Processed $timelineCount timeline entries.',
          name: 'SupabaseBookSyncRepository');

      // Sync Wishlist Items
      int wishlistCount = 0;
      for (final remote in remoteWishlist) {
        final existing = await _wishlistDao.findByRemoteId(remote.id);
        if (existing != null) {
          if (!existing.isDirty) {
            await _wishlistDao.updateItemFields(
                existing.id,
                WishlistItemsCompanion(
                  remoteId: Value(remote.id),
                  title: Value(remote.title),
                  author: Value(remote.author),
                  isbn: Value(remote.isbn),
                  notes: Value(remote.notes),
                  isDeleted: Value(remote.isDeleted),
                  syncedAt: Value(now),
                  updatedAt: Value(remote.updatedAt ?? remote.createdAt),
                ));
          }
        } else {
          await _wishlistDao.insertItem(WishlistItemsCompanion.insert(
            uuid: remote.uuid,
            remoteId: Value(remote.id),
            userId: owner.id,
            title: remote.title,
            author: Value(remote.author),
            isbn: Value(remote.isbn),
            notes: Value(remote.notes),
            isDeleted: Value(remote.isDeleted),
            createdAt: Value(remote.createdAt),
            updatedAt: Value(remote.updatedAt ?? remote.createdAt),
            syncedAt: Value(now),
          ));
        }
        wishlistCount++;
      }
      developer.log('Processed $wishlistCount wishlist items.',
          name: 'SupabaseBookSyncRepository');

      // Sync Reading Sessions
      int sessionCount = 0;
      for (final remote in remoteSessions) {
        final existing = await _sessionDao.findByRemoteId(remote.id);
        if (existing != null) {
          if (!existing.isDirty) {
            await _sessionDao.updateSession(ReadingSessionsCompanion(
              id: Value(existing.id),
              remoteId: Value(remote.id),
              startTime: Value(remote.startTime),
              endTime: Value(remote.endTime),
              durationSeconds: Value(remote.durationSeconds),
              startPage: Value(remote.startPage),
              endPage: Value(remote.endPage),
              pagesRead: Value(remote.pagesRead),
              notes: Value(remote.notes),
              mood: Value(remote.mood),
              isDeleted: Value(remote.isDeleted),
              syncedAt: Value(now),
              updatedAt: Value(remote.updatedAt ?? remote.createdAt),
            ));
          }
        } else {
          final book = await _bookDao.findByUuid(remote.bookUuid);
          if (book != null) {
            await _sessionDao.insertSession(ReadingSessionsCompanion.insert(
              uuid: remote.id,
              remoteId: Value(remote.id),
              bookUuid: remote.bookUuid,
              startTime: remote.startTime,
              endTime: Value(remote.endTime),
              durationSeconds: Value(remote.durationSeconds),
              startPage: Value(remote.startPage),
              endPage: Value(remote.endPage),
              pagesRead: Value(remote.pagesRead),
              notes: Value(remote.notes),
              mood: Value(remote.mood),
              isDeleted: Value(remote.isDeleted),
              createdAt: Value(remote.createdAt),
              updatedAt: Value(remote.updatedAt ?? remote.createdAt),
              syncedAt: Value(now),
              bookId: book.id,
            ));
          } else {
            developer.log(
              'Reading session ${remote.id} ignored: book UUID ${remote.bookUuid} not found.',
              name: 'SupabaseBookSyncRepository',
              level: 800,
            );
          }
        }
        sessionCount++;
      }
      developer.log(
        '✅ syncFromRemote COMPLETED: $timelineCount timeline, $wishlistCount wishlist, $sessionCount sessions processed.',
        name: 'SupabaseBookSyncRepository',
      );
    });
  }

  Future<void> pushLocalChanges({
    required LocalUser owner,
    String? accessToken,
  }) async {
    // Books are handled by GroupSyncController, but Reviews and Timeline are handled here.

    final dirtyReviews = await _bookDao.getDirtyReviews();
    final dirtyBooks = await _bookDao.getDirtyBooks();
    final dirtyTimeline = await _timelineDao.getDirtyEntries();
    final dirtySessions = await _sessionDao.getDirtySessions();
    final dirtyWishlist = await _wishlistDao.getDirtyItems();

    if (dirtyReviews.isEmpty &&
        dirtyBooks.isEmpty &&
        dirtyTimeline.isEmpty &&
        dirtySessions.isEmpty &&
        dirtyWishlist.isEmpty) {
      return;
    }

    final ownerRemoteId = owner.remoteId;
    if (ownerRemoteId == null) {
      developer.log(
        'Cannot push changes: User has no remote ID.',
        name: 'SupabaseBookSyncRepository',
      );
      return;
    }

    developer.log(
      '📤 Starting pushLocalChanges for user $ownerRemoteId',
      name: 'SupabaseBookSyncRepository',
    );

    // 1. Push Books
    if (dirtyBooks.isNotEmpty) {
      developer.log(
        'Pushing ${dirtyBooks.length} dirty books...',
        name: 'SupabaseBookSyncRepository',
      );

      for (final book in dirtyBooks) {
        try {
          // If book has a remoteId, it's an update. If not, check if it exists by UUID just in case.
          // But usually we trust remoteId.

          if (book.remoteId == null) {
            // CREATE
            final remoteId = await _bookService.createBook(
              id: book
                  .uuid, // Use local UUID as ID if possible, or let Supabase generate (but we pass id here)
              // Note: Supabase shared_books id is UUID. We can try to use the book UUID.
              // However, if we have duplicate UUIDs for different users...
              // Ideally we let Supabase generate, or we use a random UUID.
              // The createBook method takes 'id'. Let's use book.uuid.
              ownerId: ownerRemoteId,
              bookUuid: book.uuid,
              title: book.title,
              author: book.author,
              isbn: book.isbn,
              coverUrl: book.coverPath,
              visibility: 'private', // Always private for personal backup
              isAvailable: book.status == 'available',
              isPhysical: book.isPhysical,
              isDeleted: book.isDeleted == true,
              isRead: book.isRead,
              genre: book.genre,
              pageCount: book.pageCount,
              publicationYear: book.publicationYear,
              readingStatus: book.readingStatus,
              description: book.description,
              barcode: book.barcode,
              readAt: book.readAt,
              isBorrowedExternal: book.isBorrowedExternal,
              externalLenderName: book.externalLenderName,
              createdAt: book.createdAt,
              updatedAt: book.updatedAt,
              accessToken: accessToken,
            );

            await _bookDao.updateBookFields(
              bookId: book.id,
              entry: BooksCompanion(
                remoteId: Value(remoteId),
                ownerRemoteId: Value(ownerRemoteId),
                syncedAt: Value(DateTime.now()),
                isDirty: const Value(false),
              ),
            );
          } else {
            // UPDATE
            await _bookService.updateBook(
              id: book.remoteId!,
              title: book.title,
              author: book.author,
              isbn: book.isbn,
              coverUrl: book.coverPath,
              isAvailable: book.status == 'available',
              isPhysical: book.isPhysical,
              isDeleted: book.isDeleted == true,
              genre: book.genre,
              pageCount: book.pageCount,
              publicationYear: book.publicationYear,
              readingStatus: book.readingStatus,
              description: book.description,
              barcode: book.barcode,
              readAt: book.readAt,
              isBorrowedExternal: book.isBorrowedExternal,
              externalLenderName: book.externalLenderName,
              updatedAt: book.updatedAt,
              accessToken: accessToken,
            );

            await _bookDao.updateBookFields(
              bookId: book.id,
              entry: BooksCompanion(
                syncedAt: Value(DateTime.now()),
                isDirty: const Value(false),
              ),
            );
          }
        } catch (e, st) {
          developer.log(
            'Error syncing book ${book.id}',
            name: 'SupabaseBookSyncRepository',
            error: e,
            stackTrace: st,
          );
        }
      }
    }

    // 2. Push Reviews
    if (dirtyReviews.isNotEmpty) {
      developer.log(
        'Pushing ${dirtyReviews.length} dirty reviews...',
        name: 'SupabaseBookSyncRepository',
      );

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

    // 3. Push Timeline Entries
    if (dirtyTimeline.isNotEmpty) {
      developer.log(
        'Pushing ${dirtyTimeline.length} dirty timeline entries...',
        name: 'SupabaseBookSyncRepository',
      );

      for (final entry in dirtyTimeline) {
        final book = await _bookDao.findById(entry.bookId);
        final bookRemoteId = book?.remoteId;
        final bookUuid = book?.uuid;

        if (book == null || bookRemoteId == null || bookUuid == null) {
          developer.log(
            'Skipping timeline entry ${entry.id}: Associated book not synced/found.',
            name: 'SupabaseBookSyncRepository',
          );
          continue;
        }

        try {
          if (entry.remoteId == null) {
            // CREATE
            final remoteId = await _bookService.createTimelineEntry(
              id: entry.uuid,
              bookUuid:
                  bookUuid, // Timeline entries are linked by UUID in Supabase
              ownerId: ownerRemoteId,
              currentPage: entry.currentPage,
              percentageRead: entry.percentageRead,
              eventType: entry.eventType,
              note: entry.note,
              eventDate: entry.eventDate,
              isDeleted: entry.isDeleted == true,
              createdAt: entry.createdAt,
              updatedAt: entry.updatedAt,
              accessToken: accessToken,
            );

            await _timelineDao.updateEntryFields(
              entry.id,
              ReadingTimelineEntriesCompanion(
                remoteId: Value(remoteId),
                syncedAt: Value(DateTime.now()),
                isDirty: const Value(false),
              ),
            );
          } else {
            // UPDATE
            await _bookService.updateTimelineEntry(
              id: entry.remoteId!,
              currentPage: entry.currentPage,
              percentageRead: entry.percentageRead,
              eventType: entry.eventType,
              note: entry.note,
              eventDate: entry.eventDate,
              isDeleted: entry.isDeleted == true,
              updatedAt: entry.updatedAt,
              accessToken: accessToken,
            );

            await _timelineDao.updateEntryFields(
              entry.id,
              ReadingTimelineEntriesCompanion(
                syncedAt: Value(DateTime.now()),
                isDirty: const Value(false),
              ),
            );
          }
        } catch (e, st) {
          developer.log(
            'Error syncing timeline entry ${entry.id}',
            name: 'SupabaseBookSyncRepository',
            error: e,
            stackTrace: st,
          );
        }
      }
    }

    // 4. Push Reading Sessions
    if (dirtySessions.isNotEmpty) {
      developer.log(
        'Pushing ${dirtySessions.length} dirty sessions...',
        name: 'SupabaseBookSyncRepository',
      );
      int sessionCreated = 0;
      int sessionUpdated = 0;

      for (final session in dirtySessions) {
        // Ensure the book is synced first
        final book = await _bookDao.findById(session.bookId);
        if (book == null || book.remoteId == null) {
          developer.log(
            'Skipping session ${session.uuid}: Associated book not synced/found.',
            name: 'SupabaseBookSyncRepository',
          );
          continue;
        }

        try {
          if (session.remoteId == null) {
            final remoteId = await _bookService.createReadingSession(
              id: session.uuid,
              ownerId: ownerRemoteId,
              bookUuid: session.bookUuid,
              startTime: session.startTime,
              endTime: session.endTime,
              durationSeconds: session.durationSeconds,
              startPage: session.startPage,
              endPage: session.endPage,
              pagesRead: session.pagesRead,
              notes: session.notes,
              mood: session.mood,
              isDeleted: session.isDeleted == true,
              createdAt: session.createdAt,
              updatedAt: session.updatedAt,
              accessToken: accessToken,
            );
            await _sessionDao.updateSession(ReadingSessionsCompanion(
              id: Value(session.id),
              remoteId: Value(remoteId),
              syncedAt: Value(DateTime.now()),
              isDirty: const Value(false),
            ));
            sessionCreated++;
          } else {
            await _bookService.updateReadingSession(
              id: session.remoteId!,
              startTime: session.startTime,
              endTime: session.endTime,
              durationSeconds: session.durationSeconds,
              startPage: session.startPage,
              endPage: session.endPage,
              pagesRead: session.pagesRead,
              notes: session.notes,
              mood: session.mood,
              isDeleted: session.isDeleted == true,
              updatedAt: session.updatedAt,
              accessToken: accessToken,
            );
            await _sessionDao.updateSession(ReadingSessionsCompanion(
              id: Value(session.id),
              syncedAt: Value(DateTime.now()),
              isDirty: const Value(false),
            ));
            sessionUpdated++;
          }
        } catch (e) {
          developer.log(
            'Error syncing session ${session.id}: $e',
            name: 'SupabaseBookSyncRepository',
          );
        }
      }
      developer.log(
        'Pushed sessions: $sessionCreated created, $sessionUpdated updated.',
        name: 'SupabaseBookSyncRepository',
      );
    }

    // 5. Push Wishlist Items
    if (dirtyWishlist.isNotEmpty) {
      developer.log(
        'Pushing ${dirtyWishlist.length} dirty wishlist items...',
        name: 'SupabaseBookSyncRepository',
      );
      int wishlistCreated = 0;
      int wishlistUpdated = 0;
      int wishlistDeleted = 0;

      for (final item in dirtyWishlist) {
        try {
          if (item.remoteId == null) {
            final remoteId = await _bookService.createWishlistItem(
              id: item.uuid,
              uuid: item.uuid,
              userId: ownerRemoteId,
              title: item.title,
              author: item.author,
              isbn: item.isbn,
              notes: item.notes,
              isDeleted: item.isDeleted == true,
              createdAt: item.createdAt,
              updatedAt: item.updatedAt,
              accessToken: accessToken,
            );
            await _wishlistDao.updateItemFields(
              item.id,
              WishlistItemsCompanion(
                remoteId: Value(remoteId),
                syncedAt: Value(DateTime.now()),
                isDirty: const Value(false),
              ),
            );
            wishlistCreated++;
          } else {
            if (item.isDeleted == true) {
              await _bookService.deleteWishlistItem(
                id: item.remoteId!,
                accessToken: accessToken,
              );
              wishlistDeleted++;
            } else {
              await _bookService.createWishlistItem(
                id: item.remoteId!,
                uuid: item.uuid,
                userId: ownerRemoteId,
                title: item.title,
                author: item.author,
                isbn: item.isbn,
                notes: item.notes,
                isDeleted: false,
                createdAt: item.createdAt,
                updatedAt: item.updatedAt,
                accessToken: accessToken,
              );
              wishlistUpdated++;
            }
            await _wishlistDao.updateItemFields(
              item.id,
              WishlistItemsCompanion(
                syncedAt: Value(DateTime.now()),
                isDirty: const Value(false),
              ),
            );
          }
        } catch (e) {
          developer.log(
            'Error syncing wishlist item ${item.id}: $e',
            name: 'SupabaseBookSyncRepository',
          );
        }
      }
      developer.log(
        'Pushed wishlist items: $wishlistCreated created, $wishlistUpdated updated, $wishlistDeleted deleted.',
        name: 'SupabaseBookSyncRepository',
      );
    }
  }
}
