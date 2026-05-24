import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../data/local/club_dao.dart';
import '../data/local/database.dart';
import '../models/reading_section.dart';

/// Service for managing section comments and moderation
class SectionCommentService {
  SectionCommentService({
    required this.dao,
  });

  final ClubDao dao;
  final _uuid = const Uuid();

  // Auto-hide threshold (comments auto-hidden after this many reports)
  static const int autoHideThreshold = 3;

  // =====================================================================
  // COMMENT CRUD
  // =====================================================================

  /// Post a new comment to a section
    Future<String> postComment({
    required String clubUuid,
    String? bookUuid,
    required int sectionNumber,
    required String userUuid,
    required String content,
    String? parentId,
    bool isSpoiler = false,
  }) async {
    final commentUuid = _uuid.v4();

    final club = await dao.getClubByUuid(clubUuid);
    final user = await dao.getClubMember(clubUuid, userUuid);

    if (club == null) throw Exception('Club no encontrado');
    if (user == null) throw Exception('Usuario no es miembro del club');

    ClubBook? book;
    if (bookUuid != null) {
      book = await dao.getClubBookByBookUuid(clubUuid, bookUuid);
      if (book == null) throw Exception('Libro no encontrado en el club');
    }

    if (book != null && sectionNumber > 0) {
      final sections = ReadingSectionListHelper.fromJsonString(book.sections);
      if (sections.isNotEmpty) {
        final matchingSections = sections.where((s) => s.numero == sectionNumber);
        if (matchingSections.isEmpty) {
          throw Exception('La sección seleccionada no existe para este libro.');
        }

        final section = matchingSections.first;
        if (DateTime.now().isBefore(section.fechaApertura)) {
          throw Exception(
            'Esa sección todavía no está abierta. Así evitamos spoilers antes de tiempo.',
          );
        }
      }
    }

    final companion = SectionCommentsCompanion.insert(
      uuid: commentUuid,
      clubId: club.id,
      clubUuid: clubUuid,
      bookId: book != null ? Value(book.id) : const Value.absent(),
      bookUuid: bookUuid != null ? Value(bookUuid) : const Value.absent(),
      sectionNumber: sectionNumber,
      userId: user.memberUserId,
      userRemoteId: Value(userUuid),
      authorRemoteId: Value(userUuid), // Also set authorRemoteId as an alias
      content: content,
      parentId: parentId != null ? Value(parentId) : const Value.absent(),
      isSpoiler: Value(isSpoiler),
      reportsCount: const Value(0),
      isHidden: const Value(false),
      isDirty: const Value(true),
    );

    await dao.insertComment(companion);

    return commentUuid;
  }

  /// Delete own comment
  Future<void> deleteComment({
    required String commentUuid,
    required String userUuid,
  }) async {
        // Verify ownership before deleting
    final comment = await dao.getCommentByUuid(commentUuid);

    if (comment == null) throw Exception('Comment not found');

    if (comment.userRemoteId != userUuid) {
      throw Exception('You can only delete your own comments');
    }

    await dao.deleteComment(commentUuid);
  }

  /// Hide a comment (admin action)
  Future<void> hideComment({
    required String commentUuid,
    required String clubUuid,
    required String performedByUuid,
    required String reason,
  }) async {
    await dao.hideComment(commentUuid);

    // Log moderation action
    await dao.insertModerationLog(ModerationLogsCompanion.insert(
      uuid: _uuid.v4(),
      clubId: 0, // Will be set on sync
      clubUuid: clubUuid,
      action: 'ocultar_comentario',
      performedByUserId: 0, // Will be set on sync
      performedByRemoteId: Value(performedByUuid),
      targetId: commentUuid,
      reason: Value(reason),
      isDirty: const Value(true),
    ));
  }

  /// Unhide a comment (admin action)
  Future<void> unhideComment({
    required String commentUuid,
    required String clubUuid,
    required String performedByUuid,
  }) async {
    // Unhiding requires direct DAO update to set isHidden = false
    await (dao.db.update(dao.db.sectionComments)
          ..where((c) => dao.db.sectionComments.uuid.equals(commentUuid)))
        .write(const SectionCommentsCompanion(
      isHidden: Value(false),
      isDirty: Value(true),
    ));

    // Log moderation action
    await dao.insertModerationLog(ModerationLogsCompanion.insert(
      uuid: _uuid.v4(),
      clubId: 0,
      clubUuid: clubUuid,
      action: 'mostrar_comentario',
      performedByUserId: 0,
      performedByRemoteId: Value(performedByUuid),
      targetId: commentUuid,
      isDirty: const Value(true),
    ));
  }

  // =====================================================================
  // COMMENT REPORTING
  // =====================================================================

  /// Report a comment
  Future<bool> reportComment({
    required String commentUuid,
    required String reportedByUuid,
    required String reason,
  }) async {
    // Check if user already reported this comment
    final alreadyReported =
        await dao.hasUserReportedComment(commentUuid, reportedByUuid);

    if (alreadyReported) {
      return false; // Already reported
    }

    // Get comment to get its ID
    final comment = await dao.getCommentByUuid(commentUuid);

    if (comment == null) return false;

    // Create report
    await dao.insertReport(CommentReportsCompanion.insert(
      uuid: _uuid.v4(),
      commentId: comment.id,
      commentUuid: commentUuid,
      reportedByUserId: 0, // Will be set on sync
      reportedByRemoteId: Value(reportedByUuid),
      reason: Value(reason),
      isDirty: const Value(true),
    ));

    // Increment report count
    await dao.incrementCommentReports(commentUuid);

    // Check if auto-hide threshold reached
    final fetchedComment = await dao.getCommentByUuid(commentUuid);

    if (fetchedComment != null &&
        fetchedComment.reportsCount >= autoHideThreshold) {
      // Auto-hide comment
      await dao.hideComment(commentUuid);
    }

    return true;
  }

  /// Get reports for a comment (admin only)
  Future<List<CommentReport>> getCommentReports(String commentUuid) async {
    return dao.getReportsByCommentUuid(commentUuid);
  }

  /// Check if user has reported a comment
  Future<bool> hasUserReported(String commentUuid, String userUuid) async {
    return dao.hasUserReportedComment(commentUuid, userUuid);
  }

  // =====================================================================
  // COMMENT QUERIES
  // =====================================================================

    /// Stream comments for a section (excludes deleted, includes hidden with flag)
  Stream<List<CommentWithUser>> watchSectionComments({
    required String clubUuid,
    String? bookUuid,
    required int sectionNumber,
  }) {
    return dao.watchSectionComments(clubUuid, bookUuid, sectionNumber);
  }

  /// Count total comments in a section
  Future<int> countSectionComments({
    required String clubUuid,
    String? bookUuid,
    required int sectionNumber,
  }) async {
    final comments =
        await dao.watchSectionComments(clubUuid, bookUuid, sectionNumber).first;
    return comments.length;
  }

  /// Count user's comments in a section
  Future<int> countUserComments({
    required String clubUuid,
    String? bookUuid,
    required int sectionNumber,
    required String userUuid,
  }) async {
    final comments =
        await dao.watchSectionComments(clubUuid, bookUuid, sectionNumber).first;
    return comments.where((c) => c.comment.userRemoteId == userUuid).length;
  }

  // =====================================================================
  // MODERATION QUERIES
  // =====================================================================

  /// Get moderation log for a club
  Stream<List<ModerationLog>> watchModerationLogs(String clubUuid) {
    return dao.watchModerationLogs(clubUuid, 50);
  }

  /// Get all hidden comments in a club (admin view)
  Future<List<SectionComment>> getHiddenComments(String clubUuid) async {
    // This would need a join query to get all comments for books in a club
    // For now, return empty list (would be implemented in DAO)
    return [];
  }

  /// Get most reported comments (admin view)
  Future<List<Map<String, dynamic>>> getMostReportedComments({
    required String clubUuid,
    int limit = 10,
  }) async {
    // This would need aggregation query to find comments with most reports
    // Would be implemented in DAO with proper join
    return [];
  }
}
