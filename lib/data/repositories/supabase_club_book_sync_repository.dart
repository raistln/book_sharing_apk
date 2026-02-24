import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../local/club_dao.dart';
import '../local/database.dart';
import '../../services/supabase_club_service.dart';

/// Repository for syncing club books, proposals, progress, and comments with Supabase
///
/// This repository handles the more complex club book-related entities.
/// Separated from SupabaseClubSyncRepository for better maintainability.
class SupabaseClubBookSyncRepository {
  SupabaseClubBookSyncRepository({
    required ClubDao clubDao,
    SupabaseClubService? clubService,
  })  : _clubDao = clubDao,
        _clubService = clubService ?? SupabaseClubService();

  final ClubDao _clubDao;
  final SupabaseClubService _clubService;

  // =====================================================================
  // SYNC FROM REMOTE (Download from Supabase)
  // =====================================================================

  /// Sync club books for a specific club
  ///
  /// Note: This assumes club books are already fetched during club sync
  /// in the main SupabaseClubSyncRepository. This method is for manual
  /// refresh or targeted sync.
  Future<void> syncClubBooksForClub({
    required String clubRemoteId,
    required List<SupabaseClubBookRecord> remoteBooks,
  }) async {
    final now = DateTime.now();

    if (kDebugMode) {
      debugPrint(
        '[ClubBookSync] Processing ${remoteBooks.length} books for club $clubRemoteId',
      );
    }

    for (final remote in remoteBooks) {
      // Find existing club book
      final existing = await _findClubBookByRemoteId(remote.id);

      if (existing != null) {
        // Update existing
        await _clubDao.upsertClubBook(ClubBooksCompanion(
          id: Value(existing.id),
          uuid: Value(existing.uuid),
          orderPosition: Value(remote.orderPosition),
          status: Value(remote.status),
          startDate: Value(remote.startDate),
          endDate: Value(remote.endDate),
          isDirty: const Value(false),
          syncedAt: Value(now),
          updatedAt: Value(remote.updatedAt),
        ));

        if (kDebugMode) {
          debugPrint('[ClubBookSync] Updated club book ${remote.id}');
        }
      } else {
        // Note: Creating new club books from remote is handled during
        // club creation in SupabaseClubSyncRepository
        if (kDebugMode) {
          debugPrint(
            '[ClubBookSync] Club book ${remote.id} not found locally, skipping update',
          );
        }
      }
    }
  }

  // =====================================================================
  // PUSH LOCAL CHANGES (Upload to Supabase)
  // =====================================================================

  Future<void> pushLocalChanges({String? accessToken}) async {
    final allDirty = await _clubDao.getAllDirtyEntities();

    // Push dirty club books
    final dirtyBooks = allDirty['books'] as List<ClubBook>? ?? [];

    if (kDebugMode) {
      debugPrint('[ClubBookSync] Found ${dirtyBooks.length} dirty club books');
    }

    for (final book in dirtyBooks) {
      try {
        // Get club remote ID
        final club = await _clubDao.getClubByUuid(book.clubUuid);
        if (club == null || club.remoteId == null) {
          if (kDebugMode) {
            debugPrint(
              '[ClubBookSync] Skipping book ${book.uuid}: club lacks remoteId',
            );
          }
          continue;
        }

        final provisionalRemoteId = book.remoteId ?? book.uuid;
        String ensuredRemoteId = provisionalRemoteId;

        if (book.remoteId == null) {
          // Create new
          ensuredRemoteId = await _clubService.createClubBook(
            id: provisionalRemoteId,
            clubId: club.remoteId!,
            bookUuid: book.bookUuid,
            orderPosition: book.orderPosition,
            status: book.status,
            sectionMode: book.sectionMode,
            totalChapters: book.totalChapters,
            sections: book.sections,
            startDate: book.startDate,
            endDate: book.endDate,
            createdAt: book.createdAt,
            updatedAt: book.updatedAt,
            accessToken: accessToken,
          );

          if (kDebugMode) {
            debugPrint('[ClubBookSync] Created club book ${book.uuid}');
          }
        } else {
          // Update existing
          final updated = await _clubService.updateClubBook(
            id: provisionalRemoteId,
            status: book.status,
            startDate: book.startDate,
            endDate: book.endDate,
            updatedAt: book.updatedAt,
            accessToken: accessToken,
          );

          if (!updated) {
            // Recreate if not found
            ensuredRemoteId = await _clubService.createClubBook(
              id: provisionalRemoteId,
              clubId: club.remoteId!,
              bookUuid: book.bookUuid,
              orderPosition: book.orderPosition,
              status: book.status,
              sectionMode: book.sectionMode,
              totalChapters: book.totalChapters,
              sections: book.sections,
              startDate: book.startDate,
              endDate: book.endDate,
              createdAt: book.createdAt,
              updatedAt: book.updatedAt,
              accessToken: accessToken,
            );

            if (kDebugMode) {
              debugPrint('[ClubBookSync] Recreated missing club book');
            }
          }
        }
        await (_clubDao.update(_clubDao.clubBooks)
              ..where((t) => t.id.equals(book.id)))
            .write(
          ClubBooksCompanion(
            remoteId: Value(ensuredRemoteId),
            isDirty: const Value(false),
            syncedAt: Value(DateTime.now()),
          ),
        );
      } catch (error) {
        if (kDebugMode) {
          debugPrint(
              '[ClubBookSync] Failed to push club book ${book.uuid}: $error');
        }
        continue;
      }
    }

    // Push dirty book proposals
    final dirtyProposals = allDirty['proposals'] as List<BookProposal>? ?? [];

    if (kDebugMode) {
      debugPrint(
        '[ClubBookSync] Found ${dirtyProposals.length} dirty proposals',
      );
    }

    for (final proposal in dirtyProposals) {
      try {
        // Get club remote ID
        final club = await _clubDao.getClubByUuid(proposal.clubUuid);
        if (club == null || club.remoteId == null) {
          if (kDebugMode) {
            debugPrint(
              '[ClubBookSync] Skipping proposal ${proposal.uuid}: club lacks remoteId',
            );
          }
          continue;
        }

        final provisionalRemoteId = proposal.remoteId ?? proposal.uuid;
        String ensuredRemoteId = provisionalRemoteId;

        if (proposal.remoteId == null) {
          // Create new
          ensuredRemoteId = await _clubService.createBookProposal(
            id: provisionalRemoteId,
            clubId: club.remoteId!,
            bookUuid: proposal.bookUuid,
            proposedByUserId: proposal.proposedByRemoteId ?? '',
            title: proposal.title ?? '',
            author: proposal.author ?? '',
            isbn: proposal.isbn ?? '',
            coverUrl: proposal.coverUrl ?? '',
            status: proposal.status,
            closingDate: proposal.closingDate ?? proposal.createdAt,
            createdAt: proposal.createdAt,
            updatedAt: proposal.updatedAt,
            accessToken: accessToken,
          );

          if (kDebugMode) {
            debugPrint('[ClubBookSync] Created proposal ${proposal.uuid}');
          }
        } else {
          // Update existing
          final updated = await _clubService.updateBookProposal(
            id: provisionalRemoteId,
            votes: proposal.votes,
            status: proposal.status,
            updatedAt: proposal.updatedAt,
            accessToken: accessToken,
          );

          if (!updated) {
            // Recreate if not found
            ensuredRemoteId = await _clubService.createBookProposal(
              id: provisionalRemoteId,
              clubId: club.remoteId!,
              bookUuid: proposal.bookUuid,
              proposedByUserId: proposal.proposedByRemoteId ?? '',
              title: proposal.title ?? '',
              author: proposal.author ?? '',
              isbn: proposal.isbn ?? '',
              coverUrl: proposal.coverUrl ?? '',
              status: proposal.status,
              closingDate: proposal.closingDate ?? proposal.createdAt,
              createdAt: proposal.createdAt,
              updatedAt: proposal.updatedAt,
              accessToken: accessToken,
            );

            if (kDebugMode) {
              debugPrint('[ClubBookSync] Recreated missing proposal');
            }
          }
        }
        await (_clubDao.update(_clubDao.bookProposals)
              ..where((t) => t.id.equals(proposal.id)))
            .write(
          BookProposalsCompanion(
            remoteId: Value(ensuredRemoteId),
            isDirty: const Value(false),
            syncedAt: Value(DateTime.now()),
          ),
        );
      } catch (error) {
        if (kDebugMode) {
          debugPrint(
            '[ClubBookSync] Failed to push proposal ${proposal.uuid}: $error',
          );
        }
        continue;
      }
    }

    // Push dirty reading progress
    final dirtyProgress =
        allDirty['progress'] as List<ClubReadingProgressData>? ?? [];

    if (kDebugMode) {
      debugPrint(
        '[ClubBookSync] Found ${dirtyProgress.length} dirty progress records',
      );
    }

    for (final progress in dirtyProgress) {
      try {
        // Get club book remote ID
        final clubBook = await _clubDao.getClubBookByUuid(progress.bookUuid);
        if (clubBook == null || clubBook.remoteId == null) {
          if (kDebugMode) {
            debugPrint(
              '[ClubBookSync] Skipping progress ${progress.uuid}: club book lacks remoteId',
            );
          }
          continue;
        }

        final club = await _clubDao.getClubByUuid(progress.clubUuid);
        if (club == null || club.remoteId == null) {
          if (kDebugMode) {
            debugPrint(
              '[ClubBookSync] Skipping progress ${progress.uuid}: club lacks remoteId',
            );
          }
          continue;
        }

        String? userRemoteId = progress.userRemoteId;
        if (userRemoteId == null || userRemoteId.isEmpty) {
          final user = await (_clubDao.select(_clubDao.localUsers)
                ..where((u) => u.id.equals(progress.userId)))
              .getSingleOrNull();
          userRemoteId = user?.remoteId;
        }

        if (userRemoteId == null || userRemoteId.isEmpty) {
          if (kDebugMode) {
            debugPrint(
              '[ClubBookSync] Skipping progress ${progress.uuid}: user lacks remoteId',
            );
          }
          continue;
        }

        // Upsert progress (Supabase handles insert or update)
        final ensuredRemoteId = await _clubService.upsertReadingProgress(
          id: progress.remoteId ?? progress.uuid,
          clubId: club.remoteId!,
          bookId: clubBook.remoteId!,
          userId: userRemoteId,
          currentSection: progress.currentSection,
          currentChapter: progress.currentChapter,
          progressStatus: progress.status,
          createdAt: progress.createdAt,
          updatedAt: progress.updatedAt,
          accessToken: accessToken,
        );

        await (_clubDao.update(_clubDao.clubReadingProgress)
              ..where((t) => t.id.equals(progress.id)))
            .write(
          ClubReadingProgressCompanion(
            remoteId: Value(ensuredRemoteId),
            isDirty: const Value(false),
            syncedAt: Value(DateTime.now()),
          ),
        );

        if (kDebugMode) {
          debugPrint('[ClubBookSync] Upserted progress ${progress.uuid}');
        }
      } catch (error) {
        if (kDebugMode) {
          debugPrint(
            '[ClubBookSync] Failed to push progress ${progress.uuid}: $error',
          );
        }
        continue;
      }
    }

    // Push dirty section comments
    final dirtyComments = allDirty['comments'] as List<SectionComment>? ?? [];

    if (kDebugMode) {
      debugPrint(
        '[ClubBookSync] Found ${dirtyComments.length} dirty comments',
      );
    }

    for (final comment in dirtyComments) {
      try {
        // Skip if deleted
        if (comment.isDeleted) {
          final remoteId = comment.remoteId;
          if (remoteId != null && remoteId.isNotEmpty) {
            await _clubService.deleteSectionComment(
              id: remoteId,
              accessToken: accessToken,
            );

            if (kDebugMode) {
              debugPrint('[ClubBookSync] Deleted comment ${comment.uuid}');
            }
          }
          await (_clubDao.update(_clubDao.sectionComments)
                ..where((t) => t.id.equals(comment.id)))
              .write(
            SectionCommentsCompanion(
              isDirty: const Value(false),
              syncedAt: Value(DateTime.now()),
            ),
          );
          continue;
        }

        // Get club book remote ID
        final clubBook = await _clubDao.getClubBookByUuid(comment.bookUuid);
        if (clubBook == null || clubBook.remoteId == null) {
          if (kDebugMode) {
            debugPrint(
              '[ClubBookSync] Skipping comment ${comment.uuid}: club book lacks remoteId',
            );
          }
          continue;
        }

        final provisionalRemoteId = comment.remoteId ?? comment.uuid;
        String ensuredRemoteId = provisionalRemoteId;

        if (comment.remoteId == null) {
          // Create new
          ensuredRemoteId = await _clubService.createSectionComment(
            id: provisionalRemoteId,
            bookId: clubBook.remoteId!,
            sectionNumber: comment.sectionNumber,
            authorUserId: comment.userRemoteId ?? '',
            content: comment.content,
            createdAt: comment.createdAt,
            updatedAt: comment.updatedAt,
            accessToken: accessToken,
          );

          if (kDebugMode) {
            debugPrint('[ClubBookSync] Created comment ${comment.uuid}');
          }
        } else {
          // Update existing (for report count and hidden status)
          final updated = await _clubService.updateSectionComment(
            id: provisionalRemoteId,
            reportCount: comment.reportsCount,
            isHidden: comment.isHidden,
            updatedAt: comment.updatedAt,
            accessToken: accessToken,
          );

          if (!updated) {
            // Recreate if not found
            ensuredRemoteId = await _clubService.createSectionComment(
              id: provisionalRemoteId,
              bookId: clubBook.remoteId!,
              sectionNumber: comment.sectionNumber,
              authorUserId: comment.userRemoteId ?? '',
              content: comment.content,
              createdAt: comment.createdAt,
              updatedAt: comment.updatedAt,
              accessToken: accessToken,
            );

            if (kDebugMode) {
              debugPrint('[ClubBookSync] Recreated missing comment');
            }
          }
        }
        await (_clubDao.update(_clubDao.sectionComments)
              ..where((t) => t.id.equals(comment.id)))
            .write(
          SectionCommentsCompanion(
            remoteId: Value(ensuredRemoteId),
            isDirty: const Value(false),
            syncedAt: Value(DateTime.now()),
          ),
        );
      } catch (error) {
        if (kDebugMode) {
          debugPrint(
            '[ClubBookSync] Failed to push comment ${comment.uuid}: $error',
          );
        }
        continue;
      }
    }

    final dirtyReports = allDirty['reports'] as List<CommentReport>? ?? [];

    if (kDebugMode) {
      debugPrint(
        '[ClubBookSync] Found ${dirtyReports.length} dirty reports',
      );
    }

    for (final report in dirtyReports) {
      try {
        final comment = await _clubDao.getCommentByUuid(report.commentUuid);
        if (comment == null || comment.remoteId == null) {
          if (kDebugMode) {
            debugPrint(
              '[ClubBookSync] Skipping report ${report.uuid}: comment lacks remoteId',
            );
          }
          continue;
        }

        String? reporterRemoteId = report.reportedByRemoteId;
        if (reporterRemoteId == null || reporterRemoteId.isEmpty) {
          final user = await (_clubDao.select(_clubDao.localUsers)
                ..where((u) => u.id.equals(report.reportedByUserId)))
              .getSingleOrNull();
          reporterRemoteId = user?.remoteId;
        }

        if (reporterRemoteId == null || reporterRemoteId.isEmpty) {
          if (kDebugMode) {
            debugPrint(
              '[ClubBookSync] Skipping report ${report.uuid}: reporter lacks remoteId',
            );
          }
          continue;
        }

        final provisionalRemoteId = report.remoteId ?? report.uuid;
        final remoteId = await _clubService.createCommentReport(
          id: provisionalRemoteId,
          commentId: comment.remoteId!,
          reportedByUserId: reporterRemoteId,
          reason: report.reason,
          createdAt: report.createdAt,
          accessToken: accessToken,
        );

        await (_clubDao.update(_clubDao.commentReports)
              ..where((t) => t.id.equals(report.id)))
            .write(
          CommentReportsCompanion(
            remoteId: Value(remoteId),
            isDirty: const Value(false),
            syncedAt: Value(DateTime.now()),
          ),
        );

        if (kDebugMode) {
          debugPrint('[ClubBookSync] Created report ${report.uuid}');
        }
      } catch (error) {
        if (kDebugMode) {
          debugPrint(
            '[ClubBookSync] Failed to push report ${report.uuid}: $error',
          );
        }
        continue;
      }
    }

    final dirtyLogs = allDirty['logs'] as List<ModerationLog>? ?? [];

    if (kDebugMode) {
      debugPrint(
        '[ClubBookSync] Found ${dirtyLogs.length} dirty moderation logs',
      );
    }

    for (final log in dirtyLogs) {
      try {
        final club = await _clubDao.getClubByUuid(log.clubUuid);
        if (club == null || club.remoteId == null) {
          if (kDebugMode) {
            debugPrint(
              '[ClubBookSync] Skipping moderation log ${log.uuid}: club lacks remoteId',
            );
          }
          continue;
        }

        String? performerRemoteId = log.performedByRemoteId;
        if (performerRemoteId == null || performerRemoteId.isEmpty) {
          final user = await (_clubDao.select(_clubDao.localUsers)
                ..where((u) => u.id.equals(log.performedByUserId)))
              .getSingleOrNull();
          performerRemoteId = user?.remoteId;
        }

        if (performerRemoteId == null || performerRemoteId.isEmpty) {
          if (kDebugMode) {
            debugPrint(
              '[ClubBookSync] Skipping moderation log ${log.uuid}: performer lacks remoteId',
            );
          }
          continue;
        }

        final provisionalRemoteId = log.remoteId ?? log.uuid;
        final remoteId = await _clubService.createModerationLog(
          id: provisionalRemoteId,
          clubId: club.remoteId!,
          action: log.action,
          performedByUserId: performerRemoteId,
          targetId: log.targetId,
          reason: log.reason,
          createdAt: log.createdAt,
          accessToken: accessToken,
        );

        await (_clubDao.update(_clubDao.moderationLogs)
              ..where((t) => t.id.equals(log.id)))
            .write(
          ModerationLogsCompanion(
            remoteId: Value(remoteId),
            isDirty: const Value(false),
            syncedAt: Value(DateTime.now()),
          ),
        );

        if (kDebugMode) {
          debugPrint('[ClubBookSync] Created moderation log ${log.uuid}');
        }
      } catch (error) {
        if (kDebugMode) {
          debugPrint(
            '[ClubBookSync] Failed to push moderation log ${log.uuid}: $error',
          );
        }
        continue;
      }
    }

    if (kDebugMode) {
      debugPrint('[ClubBookSync] Push completed successfully');
    }
  }

  // =====================================================================
  // HELPER METHODS
  // =====================================================================

  Future<ClubBook?> _findClubBookByRemoteId(String remoteId) async {
    return _clubDao.getClubBookByRemoteId(remoteId);
  }
}
