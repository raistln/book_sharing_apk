import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../local/club_dao.dart';
import '../local/database.dart';
import '../local/user_dao.dart';
import '../../services/supabase_club_service.dart';

/// Repository for syncing reading clubs and members with Supabase
class SupabaseClubSyncRepository {
  SupabaseClubSyncRepository({
    required ClubDao clubDao,
    required UserDao userDao,
    SupabaseClubService? clubService,
  })  : _clubDao = clubDao,
        _userDao = userDao,
        _clubService = clubService ?? SupabaseClubService();

  final ClubDao _clubDao;
  final UserDao _userDao;
  final SupabaseClubService _clubService;

  // =====================================================================
  // SYNC FROM REMOTE (Download from Supabase)
  // =====================================================================

  Future<void> syncFromRemote({String? accessToken}) async {
    final remoteClubs = await _clubService.fetchClubs(accessToken: accessToken);
    final remoteCommentsByClub = <String, List<SupabaseSectionCommentRecord>>{};
    final remoteReportsByClub = <String, List<SupabaseCommentReportRecord>>{};
    final remoteLogsByClub = <String, List<SupabaseModerationLogRecord>>{};

    for (final remote in remoteClubs) {
      final bookIds =
          remote.books.map((book) => book.id).toList(growable: false);
      final comments = await _clubService.fetchSectionComments(
        bookIds: bookIds,
        accessToken: accessToken,
      );
      remoteCommentsByClub[remote.id] = comments;

      final commentIds = comments.map((comment) => comment.id).toList();
      final reports = await _clubService.fetchCommentReports(
        commentIds: commentIds,
        accessToken: accessToken,
      );
      remoteReportsByClub[remote.id] = reports;

      final logs = await _clubService.fetchModerationLogs(
        clubId: remote.id,
        accessToken: accessToken,
      );
      remoteLogsByClub[remote.id] = logs;
    }

    final db = _clubDao.db;
    final now = DateTime.now();

    if (kDebugMode) {
      debugPrint(
        '[ClubSync] Received ${remoteClubs.length} clubs from Supabase',
      );
    }

    await db.transaction(() async {
      for (final remote in remoteClubs) {
        if (kDebugMode) {
          debugPrint(
            '[ClubSync] Processing club ${remote.id} — members=${remote.members.length}, books=${remote.books.length}',
          );
        }

        // Ensure owner exists locally
        final ownerUser = await _ensureLocalUser(
          remoteId: remote.ownerId,
          createdAtFallback: remote.createdAt,
        );

        if (ownerUser == null) {
          if (kDebugMode) {
            debugPrint(
              '[ClubSync] Skipping club ${remote.id} — owner ${remote.ownerId} unavailable locally',
            );
          }
          continue;
        }

        // Find or create club
        final existingClub = await _findClubByRemoteId(remote.id);

        int localClubId;
        String localClubUuid;

        if (existingClub != null) {
          localClubId = existingClub.id;
          localClubUuid = existingClub.uuid;

          if (existingClub.isDirty) {
            if (kDebugMode) {
              debugPrint(
                '[ClubSync] Skipping update for dirty club ${existingClub.uuid}',
              );
            }
          } else {
            await _clubDao.upsertClub(ReadingClubsCompanion(
              id: Value(existingClub.id),
              uuid: Value(existingClub.uuid),
              name: Value(remote.name),
              description: Value(remote.description),
              city: Value(remote.city),
              meetingPlace: Value(remote.meetingPlace),
              frequency: Value(remote.frequency),
              frequencyDays: Value(remote.frequencyDays),
              visibility: Value(remote.visibility),
              nextBooksVisible: Value(remote.nextBooksVisible),
              ownerUserId: Value(ownerUser.id),
              ownerRemoteId: Value(remote.ownerId),
              isDeleted: const Value(false),
              isDirty: const Value(false),
              syncedAt: Value(now),
              updatedAt: Value(remote.updatedAt),
            ));

            if (kDebugMode) {
              debugPrint('[ClubSync] Updated club ${remote.id}');
            }
          }
        } else {
          // Create new club
          final companion = ReadingClubsCompanion.insert(
            uuid: remote.id,
            remoteId: Value(remote.id),
            name: remote.name,
            description: remote.description,
            city: remote.city,
            meetingPlace: Value(remote.meetingPlace),
            frequency: remote.frequency,
            frequencyDays: Value(remote.frequencyDays),
            visibility: Value(remote.visibility),
            nextBooksVisible: Value(remote.nextBooksVisible),
            ownerUserId: ownerUser.id,
            ownerRemoteId: Value(remote.ownerId),
            isDeleted: const Value(false),
            isDirty: const Value(false),
            syncedAt: Value(now),
            createdAt: Value(remote.createdAt),
            updatedAt: Value(remote.updatedAt),
          );

          // Insert and get the ID
          await _clubDao.upsertClub(companion);

          // Get the club to retrieve the actual ID
          final club = await _clubDao.getClubByUuid(remote.id);
          localClubId = club?.id ?? 0;
          localClubUuid = remote.id;

          if (kDebugMode) {
            debugPrint('[ClubSync] Created club ${remote.id}');
          }
        }

        // Sync club members
        for (final remoteMember in remote.members) {
          final localMember = await _ensureLocalUser(
            remoteId: remoteMember.memberId,
            username: remoteMember.username,
            createdAtFallback: remoteMember.createdAt,
          );

          if (localMember == null) {
            if (kDebugMode) {
              debugPrint(
                '[ClubSync] Skipping member ${remoteMember.id} — user ${remoteMember.memberId} unavailable locally',
              );
            }
            continue;
          }

          // Find existing member
          final existingMember = await _findMemberByRemoteId(remoteMember.id);

          if (existingMember != null) {
            if (existingMember.isDirty) {
              if (kDebugMode) {
                debugPrint(
                  '[ClubSync] Skipping update for dirty member ${existingMember.uuid}',
                );
              }
            } else {
              await _clubDao.upsertClubMember(ClubMembersCompanion(
                id: Value(existingMember.id),
                uuid: Value(existingMember.uuid),
                clubId: Value(localClubId),
                clubUuid: Value(localClubUuid),
                memberUserId: Value(localMember.id),
                memberRemoteId: Value(remoteMember.memberId),
                role: Value(remoteMember.role),
                status: Value(remoteMember.status),
                lastActivity: Value(remoteMember.lastActivity),
                isDeleted: const Value(false),
                isDirty: const Value(false),
                syncedAt: Value(now),
                updatedAt: Value(remoteMember.updatedAt),
              ));

              if (kDebugMode) {
                debugPrint('[ClubSync] Updated member ${remoteMember.id}');
              }
            }
          } else {
            // Create new member
            await _clubDao.upsertClubMember(ClubMembersCompanion.insert(
              uuid: remoteMember.id,
              remoteId: Value(remoteMember.id),
              clubId: localClubId,
              clubUuid: localClubUuid,
              memberUserId: localMember.id,
              memberRemoteId: Value(remoteMember.memberId),
              role: Value(remoteMember.role),
              status: Value(remoteMember.status),
              lastActivity: Value(remoteMember.lastActivity),
              isDeleted: const Value(false),
              isDirty: const Value(false),
              syncedAt: Value(now),
              createdAt: Value(remoteMember.createdAt),
              updatedAt: Value(remoteMember.updatedAt),
            ));

            if (kDebugMode) {
              debugPrint('[ClubSync] Created member ${remoteMember.id}');
            }
          }
        }

        // Sync club books (Bug #4: Implement downloading of club books)
        for (final remoteBook in remote.books) {
          final existingBook =
              await _clubDao.getClubBookByRemoteId(remoteBook.id);
          if (existingBook != null && existingBook.isDirty) {
            if (kDebugMode) {
              debugPrint(
                '[ClubSync] Skipping update for dirty club book ${existingBook.uuid}',
              );
            }
            continue;
          }

          await _clubDao.upsertClubBook(ClubBooksCompanion.insert(
            uuid: remoteBook.id,
            remoteId: Value(remoteBook.id),
            clubId: localClubId,
            clubUuid: localClubUuid,
            bookUuid: remoteBook.bookUuid,
            orderPosition: Value(remoteBook.orderPosition),
            status: Value(remoteBook.status),
            sectionMode: Value(remoteBook.sectionMode),
            totalChapters: remoteBook.totalChapters,
            sections: remoteBook.sections,
            startDate: Value(remoteBook.startDate),
            endDate: Value(remoteBook.endDate),
            isDeleted: const Value(false),
            isDirty: const Value(false),
            syncedAt: Value(now),
            createdAt: Value(remoteBook.createdAt),
            updatedAt: Value(remoteBook.updatedAt),
          ));
        }

        // Reconciliation: Remove members not in remote list
        final remoteMemberIds = remote.members.map((m) => m.id).toSet();
        final localMembers =
            await _clubDao.watchClubMembers(localClubUuid).first;

        for (final local in localMembers) {
          if (local.remoteId != null &&
              local.remoteId!.isNotEmpty &&
              !remoteMemberIds.contains(local.remoteId) &&
              !local.isDirty) {
            if (kDebugMode) {
              debugPrint(
                '[ClubSync] RECONCILIATION: Removing orphan member ${local.uuid}',
              );
            }
            await _clubDao.removeClubMember(
                localClubUuid, local.memberRemoteId!);
          }
        }

        final remoteComments = remoteCommentsByClub[remote.id] ?? [];
        await _syncSectionComments(
          localClubId: localClubId,
          localClubUuid: localClubUuid,
          remoteComments: remoteComments,
          syncedAt: now,
        );

        final remoteReports = remoteReportsByClub[remote.id] ?? [];
        await _syncCommentReports(
          remoteReports: remoteReports,
          syncedAt: now,
        );

        final remoteLogs = remoteLogsByClub[remote.id] ?? [];
        await _syncModerationLogs(
          localClubId: localClubId,
          localClubUuid: localClubUuid,
          remoteLogs: remoteLogs,
          syncedAt: now,
        );
      }
    });
  }

  // =====================================================================
  // PUSH LOCAL CHANGES (Upload to Supabase)
  // =====================================================================

  Future<void> pushLocalChanges({String? accessToken}) async {
    final syncTime = DateTime.now();

    // Push dirty clubs
    final dirtyClubs = await _clubDao.getDirtyClubs();

    if (kDebugMode) {
      debugPrint('[ClubSync] Found ${dirtyClubs.length} dirty clubs');
    }

    for (final club in dirtyClubs) {
      try {
        // Skip if deleted
        if (club.isDeleted) {
          final remoteId = club.remoteId;
          if (remoteId != null && remoteId.isNotEmpty) {
            await _clubService.deleteClub(
              id: remoteId,
              accessToken: accessToken,
            );

            if (kDebugMode) {
              debugPrint('[ClubSync] Deleted club ${club.uuid} remotely');
            }
          }

          // Mark as synced
          await _clubDao.markClubSynced(club.uuid, syncedAt: syncTime);
          continue;
        }

        // Get owner remote ID
        final owner = await _userDao.getById(club.ownerUserId);
        final ownerRemoteId = club.ownerRemoteId ?? owner?.remoteId;

        if (ownerRemoteId == null || ownerRemoteId.isEmpty) {
          if (kDebugMode) {
            debugPrint(
              '[ClubSync] Skipping club ${club.uuid}: owner lacks remoteId',
            );
          }
          continue;
        }

        final provisionalRemoteId = club.remoteId ?? club.uuid;
        var ensuredRemoteId = provisionalRemoteId;

        if (club.remoteId == null) {
          // Create new club
          ensuredRemoteId = await _clubService.createClub(
            id: provisionalRemoteId,
            name: club.name,
            description: club.description,
            city: club.city,
            meetingPlace: club.meetingPlace,
            frequency: club.frequency,
            frequencyDays: club.frequencyDays ?? 7,
            visibility: club.visibility,
            nextBooksVisible: club.nextBooksVisible,
            ownerId: ownerRemoteId,
            createdAt: club.createdAt,
            updatedAt: club.updatedAt,
            accessToken: accessToken,
          );

          if (kDebugMode) {
            debugPrint(
                '[ClubSync] Created club ${club.uuid} -> $ensuredRemoteId');
          }
        } else {
          // Update existing club
          final updated = await _clubService.updateClub(
            id: provisionalRemoteId,
            name: club.name,
            description: club.description,
            meetingPlace: club.meetingPlace,
            frequency: club.frequency,
            frequencyDays: club.frequencyDays ?? 7,
            nextBooksVisible: club.nextBooksVisible,
            updatedAt: club.updatedAt,
            accessToken: accessToken,
          );

          if (!updated) {
            // Club not found remotely, recreate
            ensuredRemoteId = await _clubService.createClub(
              id: provisionalRemoteId,
              name: club.name,
              description: club.description,
              city: club.city,
              meetingPlace: club.meetingPlace,
              frequency: club.frequency,
              frequencyDays: club.frequencyDays ?? 7,
              visibility: club.visibility,
              nextBooksVisible: club.nextBooksVisible,
              ownerId: ownerRemoteId,
              createdAt: club.createdAt,
              updatedAt: club.updatedAt,
              accessToken: accessToken,
            );

            if (kDebugMode) {
              debugPrint('[ClubSync] Recreated missing club $ensuredRemoteId');
            }
          }
        }

        // Mark as synced
        await _clubDao.markClubSynced(club.uuid,
            syncedAt: syncTime, remoteId: ensuredRemoteId);
      } catch (error) {
        if (kDebugMode) {
          debugPrint('[ClubSync] Failed to push club ${club.uuid}: $error');
        }
        continue; // ✅ Bug #8: Continue instead of rethrow
      }
    }

    // Push dirty members
    final dirtyMembers = await _clubDao.getDirtyMembers();

    if (kDebugMode) {
      debugPrint('[ClubSync] Found ${dirtyMembers.length} dirty members');
    }

    for (final member in dirtyMembers) {
      try {
        // Skip if deleted
        if (member.isDeleted) {
          final remoteId = member.remoteId;
          if (remoteId != null && remoteId.isNotEmpty) {
            await _clubService.deleteClubMember(
              id: remoteId,
              accessToken: accessToken,
            );

            if (kDebugMode) {
              debugPrint('[ClubSync] Deleted member ${member.uuid} remotely');
            }
          }

          // Mark as synced (will be cleaned up later)
          await (_clubDao.update(_clubDao.clubMembers)
                ..where((t) => t.id.equals(member.id)))
              .write(ClubMembersCompanion(
            isDirty: const Value(false),
            syncedAt: Value(syncTime),
          ));
          continue;
        }

        // Get club and member remote IDs
        final club = await _clubDao.getClubByUuid(member.clubUuid);
        if (club == null || club.remoteId == null) {
          if (kDebugMode) {
            debugPrint(
              '[ClubSync] Skipping member ${member.uuid}: club lacks remoteId',
            );
          }
          continue;
        }

        final memberUser = member.memberRemoteId != null
            ? await _userDao.findByRemoteId(member.memberRemoteId!)
            : null;

        final memberRemoteId = member.memberRemoteId ?? memberUser?.remoteId;
        if (memberRemoteId == null || memberRemoteId.isEmpty) {
          if (kDebugMode) {
            debugPrint(
              '[ClubSync] Skipping member ${member.uuid}: user lacks remoteId',
            );
          }
          continue;
        }

        final provisionalRemoteId = member.remoteId ?? member.uuid;
        var ensuredRemoteId = provisionalRemoteId;

        if (member.remoteId == null) {
          // Create new member
          ensuredRemoteId = await _clubService.createClubMember(
            id: provisionalRemoteId,
            clubId: club.remoteId!,
            memberId: memberRemoteId,
            role: member.role,
            status: member.status,
            lastActivity: member.lastActivity,
            createdAt: member.createdAt,
            updatedAt: member.updatedAt,
            accessToken: accessToken,
          );

          if (kDebugMode) {
            debugPrint(
              '[ClubSync] Created member ${member.uuid} -> $ensuredRemoteId',
            );
          }
        } else {
          // Update existing member
          final updated = await _clubService.updateClubMember(
            id: provisionalRemoteId,
            role: member.role,
            status: member.status,
            lastActivity: member.lastActivity,
            updatedAt: member.updatedAt,
            accessToken: accessToken,
          );

          if (!updated) {
            // Member not found remotely, recreate
            ensuredRemoteId = await _clubService.createClubMember(
              id: provisionalRemoteId,
              clubId: club.remoteId!,
              memberId: memberRemoteId,
              role: member.role,
              status: member.status,
              lastActivity: member.lastActivity,
              createdAt: member.createdAt,
              updatedAt: member.updatedAt,
              accessToken: accessToken,
            );

            if (kDebugMode) {
              debugPrint(
                  '[ClubSync] Recreated missing member $ensuredRemoteId');
            }
          }
        }
        await (_clubDao.update(_clubDao.clubMembers)
              ..where((t) => t.id.equals(member.id)))
            .write(ClubMembersCompanion(
          remoteId: Value(ensuredRemoteId),
          isDirty: const Value(false),
          syncedAt: Value(syncTime),
        ));
      } catch (error) {
        if (kDebugMode) {
          debugPrint('[ClubSync] Failed to push member ${member.uuid}: $error');
        }
        continue; // ✅ Bug #8: Continue instead of rethrow
      }
    }
  }

  // =====================================================================
  // HELPER METHODS
  // =====================================================================

  Future<LocalUser?> _ensureLocalUser({
    required String remoteId,
    String? username,
    required DateTime createdAtFallback,
  }) async {
    var user = await _userDao.findByRemoteId(remoteId);

    if (user == null) {
      // Create placeholder user
      final userId = await _userDao.insertUser(
        LocalUsersCompanion.insert(
          uuid: remoteId,
          remoteId: Value(remoteId),
          username: username ?? 'user_$remoteId',
          createdAt: Value(createdAtFallback),
        ),
      );
      user = await _userDao.getById(userId);
    } else if (username != null && user.username != username) {
      // Update username if changed
      await _userDao.updateUser(
        LocalUsersCompanion(
          id: Value(user.id),
          username: Value(username),
        ),
      );
      user = await _userDao.getById(user.id);
    }

    return user;
  }

  Future<ReadingClub?> _findClubByRemoteId(String remoteId) async {
    return _clubDao.getClubByRemoteId(remoteId);
  }

  Future<ClubMember?> _findMemberByRemoteId(String remoteId) async {
    return _clubDao.getMemberByRemoteId(remoteId);
  }

  Future<void> _syncSectionComments({
    required int localClubId,
    required String localClubUuid,
    required List<SupabaseSectionCommentRecord> remoteComments,
    required DateTime syncedAt,
  }) async {
    for (final remote in remoteComments) {
      final clubBook = await _clubDao.getClubBookByRemoteId(remote.bookId);
      if (clubBook == null) {
        continue;
      }

      final author = await _ensureLocalUser(
        remoteId: remote.authorUserId,
        createdAtFallback: remote.createdAt,
      );
      if (author == null) {
        continue;
      }

      final existing = await _clubDao.getCommentByRemoteId(remote.id) ??
          await _clubDao.getCommentByUuid(remote.id);

      if (existing != null && existing.isDirty) {
        continue;
      }

      if (existing != null) {
        await (_clubDao.update(_clubDao.sectionComments)
              ..where((t) => t.id.equals(existing.id)))
            .write(SectionCommentsCompanion(
          clubId: Value(localClubId),
          clubUuid: Value(localClubUuid),
          bookId: Value(clubBook.id),
          bookUuid: Value(clubBook.uuid),
          sectionNumber: Value(remote.sectionNumber),
          userId: Value(author.id),
          userRemoteId: Value(remote.authorUserId),
          authorRemoteId: Value(remote.authorUserId),
          content: Value(remote.content),
          reportsCount: Value(remote.reportCount),
          isHidden: Value(remote.isHidden),
          isDeleted: const Value(false),
          isDirty: const Value(false),
          syncedAt: Value(syncedAt),
          createdAt: Value(remote.createdAt),
          updatedAt: Value(remote.updatedAt),
          remoteId: Value(remote.id),
        ));
        continue;
      }

      await _clubDao.insertComment(SectionCommentsCompanion.insert(
        uuid: remote.id,
        remoteId: Value(remote.id),
        clubId: localClubId,
        clubUuid: localClubUuid,
        bookId: clubBook.id,
        bookUuid: clubBook.uuid,
        sectionNumber: remote.sectionNumber,
        userId: author.id,
        userRemoteId: Value(remote.authorUserId),
        authorRemoteId: Value(remote.authorUserId),
        content: remote.content,
        reportsCount: Value(remote.reportCount),
        isHidden: Value(remote.isHidden),
        isDirty: const Value(false),
        isDeleted: const Value(false),
        syncedAt: Value(syncedAt),
        createdAt: Value(remote.createdAt),
        updatedAt: Value(remote.updatedAt),
      ));
    }
  }

  Future<void> _syncCommentReports({
    required List<SupabaseCommentReportRecord> remoteReports,
    required DateTime syncedAt,
  }) async {
    for (final remote in remoteReports) {
      final comment = await _clubDao.getCommentByRemoteId(remote.commentId);
      if (comment == null) {
        continue;
      }

      final reporter = await _ensureLocalUser(
        remoteId: remote.reportedByUserId,
        createdAtFallback: remote.createdAt,
      );
      if (reporter == null) {
        continue;
      }

      final existing = await _clubDao.getReportByRemoteId(remote.id) ??
          await (_clubDao.select(_clubDao.commentReports)
                ..where((t) =>
                    t.commentId.equals(comment.id) &
                    t.reportedByUserId.equals(reporter.id)))
              .getSingleOrNull();

      if (existing != null && existing.isDirty) {
        continue;
      }

      if (existing != null) {
        await (_clubDao.update(_clubDao.commentReports)
              ..where((t) => t.id.equals(existing.id)))
            .write(CommentReportsCompanion(
          commentId: Value(comment.id),
          commentUuid: Value(comment.uuid),
          reportedByUserId: Value(reporter.id),
          reportedByRemoteId: Value(remote.reportedByUserId),
          reason: Value(remote.reason),
          remoteId: Value(remote.id),
          isDirty: const Value(false),
          syncedAt: Value(syncedAt),
          createdAt: Value(remote.createdAt),
        ));
        continue;
      }

      await _clubDao.into(_clubDao.commentReports).insertOnConflictUpdate(
            CommentReportsCompanion(
              uuid: Value(remote.id),
              remoteId: Value(remote.id),
              commentId: Value(comment.id),
              commentUuid: Value(comment.uuid),
              reportedByUserId: Value(reporter.id),
              reportedByRemoteId: Value(remote.reportedByUserId),
              reason: Value(remote.reason),
              isDirty: const Value(false),
              syncedAt: Value(syncedAt),
              createdAt: Value(remote.createdAt),
            ),
          );
    }
  }

  Future<void> _syncModerationLogs({
    required int localClubId,
    required String localClubUuid,
    required List<SupabaseModerationLogRecord> remoteLogs,
    required DateTime syncedAt,
  }) async {
    for (final remote in remoteLogs) {
      final performer = await _ensureLocalUser(
        remoteId: remote.performedByUserId,
        createdAtFallback: remote.createdAt,
      );
      if (performer == null) {
        continue;
      }

      final existing = await _clubDao.getModerationLogByRemoteId(remote.id);
      if (existing != null && existing.isDirty) {
        continue;
      }

      if (existing != null) {
        await (_clubDao.update(_clubDao.moderationLogs)
              ..where((t) => t.id.equals(existing.id)))
            .write(ModerationLogsCompanion(
          clubId: Value(localClubId),
          clubUuid: Value(localClubUuid),
          action: Value(remote.action),
          performedByUserId: Value(performer.id),
          performedByRemoteId: Value(remote.performedByUserId),
          targetId: Value(remote.targetId),
          reason: Value(remote.reason),
          remoteId: Value(remote.id),
          isDirty: const Value(false),
          syncedAt: Value(syncedAt),
          createdAt: Value(remote.createdAt),
        ));
        continue;
      }

      await _clubDao.insertModerationLog(ModerationLogsCompanion.insert(
        uuid: remote.id,
        remoteId: Value(remote.id),
        clubId: localClubId,
        clubUuid: localClubUuid,
        action: remote.action,
        performedByUserId: performer.id,
        performedByRemoteId: Value(remote.performedByUserId),
        targetId: remote.targetId,
        reason: Value(remote.reason),
        isDirty: const Value(false),
        syncedAt: Value(syncedAt),
        createdAt: Value(remote.createdAt),
      ));
    }
  }
}
