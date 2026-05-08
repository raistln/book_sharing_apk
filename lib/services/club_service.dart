import 'package:drift/drift.dart' hide isNotNull;
import 'package:uuid/uuid.dart';

import '../data/local/club_dao.dart';
import '../data/local/database.dart';
import '../models/club_enums.dart';
import '../models/global_sync_state.dart' show SyncEntity;
import '../models/reading_section.dart';
import 'unified_sync_coordinator.dart';

/// Service for managing reading clubs
class ClubService {
  ClubService({
    required this.dao,
    required this.syncCoordinator,
  });

  final ClubDao dao;
  final UnifiedSyncCoordinator syncCoordinator;
  final _uuid = const Uuid();

  void _markDirty() {
    syncCoordinator.markPendingChanges(SyncEntity.clubs);
  }

  Future<ReadingClub> _requireClub(String clubUuid) async {
    final club = await dao.getClubByUuid(clubUuid);
    if (club == null) {
      throw Exception('El club con código "$clubUuid" no existe.');
    }
    return club;
  }

  // =====================================================================
  // CLUB CRUD
  // =====================================================================

  /// Create a new reading club
  Future<String> createClub({
    required int ownerUserId,
    required String ownerRemoteId,
    required String name,
    required String description,
    required String city,
    String? meetingPlace,
    required ClubFrequency frequency,
    int? frequencyDays,
    int nextBooksVisible = 1,
  }) async {
    final clubUuid = _uuid.v4();

    final companion = ReadingClubsCompanion.insert(
      uuid: clubUuid,
      name: name,
      description: description,
      city: city,
      meetingPlace: Value(meetingPlace),
      frequency: frequency.value,
      frequencyDays: Value(frequencyDays ?? frequency.defaultDays),
      visibility: const Value('privado'), // v1: always private
      nextBooksVisible: Value(nextBooksVisible),
      ownerUserId: ownerUserId,
      ownerRemoteId: Value(ownerRemoteId),
      isDirty: const Value(true),
    );

    await dao.upsertClub(companion);

    final createdClub = await dao.getClubByUuid(clubUuid);
    if (createdClub == null) {
      throw Exception('No se pudo crear el club localmente.');
    }

    // Auto-add owner as member with 'dueño' role
    await dao.upsertClubMember(ClubMembersCompanion.insert(
      uuid: _uuid.v4(),
      clubId: createdClub.id,
      clubUuid: clubUuid,
      memberUserId: ownerUserId,
      memberRemoteId: Value(ownerRemoteId),
      role: const Value('dueño'),
      status: const Value('activo'),
      isDirty: const Value(true),
    ));

    _markDirty();
    return clubUuid;
  }

  /// Update club settings (owner only)
  Future<void> updateClubSettings({
    required String clubUuid,
    String? name,
    String? description,
    String? meetingPlace,
    ClubFrequency? frequency,
    int? frequencyDays,
    int? nextBooksVisible,
  }) async {
    final updates = ReadingClubsCompanion(
      uuid: Value(clubUuid),
      name: name != null ? Value(name) : const Value.absent(),
      description:
          description != null ? Value(description) : const Value.absent(),
      meetingPlace:
          meetingPlace != null ? Value(meetingPlace) : const Value.absent(),
      frequency:
          frequency != null ? Value(frequency.value) : const Value.absent(),
      frequencyDays:
          frequencyDays != null ? Value(frequencyDays) : const Value.absent(),
      nextBooksVisible: nextBooksVisible != null
          ? Value(nextBooksVisible)
          : const Value.absent(),
      isDirty: const Value(true),
      updatedAt: Value(DateTime.now()),
    );

    await dao.upsertClub(updates);
    _markDirty();
  }

  /// Delete a club (soft delete)
  Future<void> deleteClub(String clubUuid) async {
    await dao.deleteClub(clubUuid);
    _markDirty();
  }

  /// Get a specific club
  Future<ReadingClub?> getClub(String clubUuid) async {
    return dao.getClubByUuid(clubUuid);
  }

  /// Stream a specific club
  Stream<ReadingClub?> watchClub(String clubUuid) {
    return dao.watchClubByUuid(clubUuid);
  }

  /// Stream all clubs the user is a member of
  Stream<List<ReadingClub>> watchUserClubs(String userUuid) {
    return dao.watchUserClubs(userUuid);
  }

  // =====================================================================
  // CLUB MEMBERS
  // =====================================================================

  /// Get club members
  Stream<List<ClubMember>> watchClubMembers(String clubUuid) {
    return dao.watchClubMembers(clubUuid);
  }

  /// Check if user is a member of the club
  Future<bool> isUserMember(String clubUuid, String userUuid) async {
    final member = await dao.getClubMember(clubUuid, userUuid);
    return member != null;
  }

  /// Get user's role in the club
  Future<ClubMemberRole?> getUserRole(String clubUuid, String userUuid) async {
    final member = await dao.getClubMember(clubUuid, userUuid);
    return member != null ? ClubMemberRole.fromString(member.role) : null;
  }

  /// Check if user is owner of the club
  Future<bool> isUserOwner(String clubUuid, String userUuid) async {
    final role = await getUserRole(clubUuid, userUuid);
    return role?.isOwner ?? false;
  }

  /// Check if user is admin (owner or admin role)
  Future<bool> isUserAdmin(String clubUuid, String userUuid) async {
    final role = await getUserRole(clubUuid, userUuid);
    return role?.isAdmin ?? false;
  }

  /// Leave a club
  Future<void> leaveClub(String clubUuid, String userUuid) async {
    // Check if user is the owner
    final isOwner = await isUserOwner(clubUuid, userUuid);
    if (isOwner) {
      throw Exception('Owner cannot leave club. Delete the club instead.');
    }

    await dao.removeClubMember(clubUuid, userUuid);
    _markDirty();
  }

  /// Join a club by its UUID
  Future<void> joinClubByUuid({
    required String clubUuid,
    required int userId,
    required String userRemoteId,
  }) async {
    // Check if club exists
    final club = await _requireClub(clubUuid);

    // Check if user is already a member
    final isMember = await isUserMember(clubUuid, userRemoteId);
    if (isMember) {
      throw Exception('Ya eres miembro de este club.');
    }

    // Add member
    await dao.upsertClubMember(ClubMembersCompanion.insert(
      uuid: _uuid.v4(),
      clubId: club.id,
      clubUuid: clubUuid,
      memberUserId: userId,
      memberRemoteId: Value(userRemoteId),
      role: const Value('miembro'),
      status: const Value('activo'),
      isDirty: const Value(true),
    ));
    _markDirty();
  }

  /// Kick a member (admin/owner only)
  Future<void> kickMember({
    required String clubUuid,
    required String targetUserUuid,
    required String performedByUuid,
  }) async {
    // Verify performer is admin
    final isAdmin = await isUserAdmin(clubUuid, performedByUuid);
    if (!isAdmin) {
      throw Exception('Only admins can kick members');
    }

    // Cannot kick the owner
    final targetRole = await getUserRole(clubUuid, targetUserUuid);
    if (targetRole?.isOwner ?? false) {
      throw Exception('Cannot kick the owner');
    }

    await dao.removeClubMember(clubUuid, targetUserUuid);

    // Log moderation action
    final club = await _requireClub(clubUuid);
    final performerMember = await dao.getClubMember(clubUuid, performedByUuid);
    if (performerMember == null) {
      throw Exception('No se encontró la membresía del usuario ejecutor.');
    }

    await dao.insertModerationLog(ModerationLogsCompanion.insert(
      uuid: _uuid.v4(),
      clubId: club.id,
      clubUuid: clubUuid,
      action: 'expulsar_miembro',
      performedByUserId: performerMember.memberUserId,
      performedByRemoteId: Value(performedByUuid),
      targetId: targetUserUuid,
      isDirty: const Value(true),
    ));
    _markDirty();
  }

  /// Update member activity timestamp
  Future<void> updateMemberActivity(String clubUuid, String userUuid) async {
    await dao.updateMemberActivity(clubUuid, userUuid);
  }

  // =====================================================================
  // CLUB BOOKS
  // =====================================================================

  /// Get max order position for club books
  Future<int> _getMaxOrderPosition(String clubUuid) async {
    final books = await dao.watchClubBooks(clubUuid).first;
    if (books.isEmpty) return 0;
    return books.map((e) => e.orderPosition).reduce((a, b) => a > b ? a : b);
  }

  List<ReadingSection> _generateAutomaticSections({
    required int totalChapters,
    required ClubFrequency frequency,
    int? frequencyDays,
    required DateTime startDate,
  }) {
    if (totalChapters <= 0) return const [];

    final daysPerSection = frequencyDays ?? frequency.defaultDays ?? 30;
    const idealSectionsCount = 4;
    final chaptersPerSection = (totalChapters / idealSectionsCount).ceil();

    final sections = <ReadingSection>[];
    var currentChapter = 1;
    var sectionNumber = 1;
    var currentStartDate = startDate;

    while (currentChapter <= totalChapters) {
      final endChapter =
          (currentChapter + chaptersPerSection - 1).clamp(1, totalChapters);
      final closeDate = currentStartDate.add(Duration(days: daysPerSection));

      sections.add(
        ReadingSection(
          numero: sectionNumber,
          capituloInicio: currentChapter,
          capituloFin: endChapter,
          fechaApertura: currentStartDate,
          fechaCierre: closeDate,
        ),
      );

      currentChapter = endChapter + 1;
      sectionNumber++;
      currentStartDate = closeDate;
    }

    return sections;
  }

  String _buildSectionsJson({
    required ReadingClub club,
    required SectionMode sectionMode,
    required int totalChapters,
    String? sectionsJson,
    DateTime? startDate,
  }) {
    if (sectionMode == SectionMode.manual) {
      return sectionsJson ?? '[]';
    }

    final safeStartDate = startDate ?? DateTime.now();

    if (sectionMode == SectionMode.total) {
      return ReadingSectionListHelper.toJsonString([
        ReadingSection(
          numero: 1,
          capituloInicio: 1,
          capituloFin: totalChapters,
          fechaApertura: safeStartDate,
          fechaCierre: safeStartDate.add(
            Duration(days: club.frequencyDays ?? 30),
          ),
        ),
      ]);
    }

    final sections = _generateAutomaticSections(
      totalChapters: totalChapters,
      frequency: ClubFrequency.fromString(club.frequency),
      frequencyDays: club.frequencyDays,
      startDate: safeStartDate,
    );
    return ReadingSectionListHelper.toJsonString(sections);
  }

  Future<void> repairBookSectionsIfMissing(String clubBookUuid) async {
    final clubBook = await dao.getClubBookByUuid(clubBookUuid);
    if (clubBook == null) return;
    if (clubBook.sections.trim().isNotEmpty && clubBook.sections.trim() != '[]') {
      return;
    }

    final club = await dao.getClubByUuid(clubBook.clubUuid);
    if (club == null) return;

    final repairedSections = _buildSectionsJson(
      club: club,
      sectionMode: SectionMode.fromString(clubBook.sectionMode),
      totalChapters: clubBook.totalChapters,
      startDate: clubBook.startDate,
    );

    await dao.upsertClubBook(
      ClubBooksCompanion(
        uuid: Value(clubBook.uuid),
        clubUuid: Value(clubBook.clubUuid),
        sections: Value(repairedSections),
        isDirty: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
    _markDirty();
  }

  /// Add a book to a club (admin action)
  Future<void> addBookToClub({
    required String clubUuid,
    required String bookUuid,
    required int totalChapters,
    required SectionMode sectionMode,
    String? sectionsJson, // For manual mode
    DateTime? startDate,
  }) async {
    final club = await _requireClub(clubUuid);
    final maxOrder = await _getMaxOrderPosition(clubUuid);
    final resolvedSectionsJson = _buildSectionsJson(
      club: club,
      sectionMode: sectionMode,
      totalChapters: totalChapters,
      sectionsJson: sectionsJson,
      startDate: startDate,
    );

    // Check if there is an active book
    final currentBook = await dao.getCurrentBook(clubUuid);
    final status =
        currentBook == null ? ClubBookStatus.activo : ClubBookStatus.proximo;

    await dao.upsertClubBook(ClubBooksCompanion.insert(
      uuid: _uuid.v4(),
      clubId: club.id,
      clubUuid: clubUuid,
      bookUuid: bookUuid,
      orderPosition: Value(maxOrder + 1),
      status: Value(status.value),
      sectionMode: Value(sectionMode.value),
      totalChapters: totalChapters,
      sections: resolvedSectionsJson,
      startDate: startDate != null ? Value(startDate) : const Value.absent(),
      isDirty: const Value(true),
    ));
    _markDirty();
  }

  /// Stream all club books
  Stream<List<ClubBook>> watchClubBooks(String clubUuid) {
    return dao.watchClubBooks(clubUuid);
  }

  /// Get current active book
  Future<ClubBook?> getCurrentBook(String clubUuid) async {
    return dao.getCurrentBook(clubUuid);
  }

  /// Stream current active book
  Stream<ClubBook?> watchCurrentBook(String clubUuid) {
    return dao.watchCurrentBook(clubUuid);
  }

  /// Get upcoming books (limited by club settings)
  Future<List<ClubBook>> getUpcomingBooks(String clubUuid) async {
    final club = await dao.getClubByUuid(clubUuid);
    if (club == null) return [];

    return dao.getUpcomingBooks(clubUuid, club.nextBooksVisible);
  }

  /// Stream completed books history
  Stream<List<ClubBook>> watchCompletedBooks(String clubUuid) {
    return dao.watchCompletedBooks(clubUuid);
  }

  /// Propose a book
  Future<void> proposeBook({
    required String clubUuid,
    required String bookUuid,
    required String userUuid,
    required int totalChapters,
  }) async {
    final club = await _requireClub(clubUuid);
    final proposerMember = await dao.getClubMember(clubUuid, userUuid);
    if (proposerMember == null) {
      throw Exception('Debes ser miembro del club para proponer libros.');
    }

    // Check if already proposed using dao query if needed, or rely on unique constraints if any.
    // Assuming UI handles duplicate check or we allow multiple proposals but maybe checking first is better.

    // For now simple insert
    await dao.upsertProposal(BookProposalsCompanion.insert(
      uuid: _uuid.v4(),
      clubId: club.id,
      clubUuid: clubUuid,
      // bookId removed as it doesn't exist
      bookUuid: bookUuid,
      proposedByUserId: proposerMember.memberUserId,
      proposedByRemoteId: Value(userUuid),
      status: const Value('abierta'),
      voteCount: const Value(0),
      totalChapters: totalChapters,
      isDirty: const Value(true),
    ));
    _markDirty();
  }

  // =====================================================================
  // READING PROGRESS
  // =====================================================================

  /// Stream all members' progress for a specific book
  Stream<List<ClubReadingProgressData>> watchBookProgress(
      String clubUuid, String bookUuid) {
    return dao.watchBookProgress(clubUuid, bookUuid);
  }

  /// Get user's personal progress
  Future<ClubReadingProgressData?> getUserProgress(
      String clubUuid, String bookUuid, String userUuid) async {
    return dao.getUserProgress(clubUuid, bookUuid, userUuid);
  }

  /// Stream user's personal progress
  Stream<ClubReadingProgressData?> watchUserProgress(
      String clubUuid, String bookUuid, String userUuid) {
    return dao.watchUserProgress(clubUuid, bookUuid, userUuid);
  }

  /// Update user's reading progress
  Future<void> updateProgress({
    required String clubUuid,
    required String bookUuid,
    required String userUuid,
    required ReadingProgressStatus status,
    int? currentChapter,
    int? currentSection,
  }) async {
    final club = await _requireClub(clubUuid);
    final clubBook = await dao.getClubBookByBookUuid(clubUuid, bookUuid);
    if (clubBook == null) {
      throw Exception('No se encontró el libro del club para registrar avance.');
    }
    final progressMember = await dao.getClubMember(clubUuid, userUuid);
    if (progressMember == null) {
      throw Exception('Debes ser miembro del club para actualizar avance.');
    }

    // Get existing progress or create new
    final existing = await dao.getUserProgress(clubUuid, bookUuid, userUuid);

    if (existing == null) {
      // Create new progress entry
      await dao.upsertProgress(ClubReadingProgressCompanion.insert(
        uuid: _uuid.v4(),
        clubId: club.id,
        clubUuid: clubUuid,
        bookId: clubBook.id,
        bookUuid: bookUuid,
        userId: progressMember.memberUserId,
        userRemoteId: Value(userUuid),
        status: Value(status.value),
        currentChapter: Value(currentChapter ?? 0),
        currentSection: Value(currentSection ?? 0),
      ));
    } else {
      // Update existing
      await dao.upsertProgress(ClubReadingProgressCompanion(
        uuid: Value(existing.uuid),
        clubUuid: Value(clubUuid),
        bookUuid: Value(bookUuid),
        userRemoteId: Value(userUuid),
        status: Value(status.value),
        currentChapter: currentChapter != null
            ? Value(currentChapter)
            : const Value.absent(),
        currentSection: currentSection != null
            ? Value(currentSection)
            : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      ));
    }

    // Update member activity timestamp
    await updateMemberActivity(clubUuid, userUuid);
    _markDirty();
  }

  // =====================================================================
  // STATISTICS
  // =====================================================================

  /// Calculate club-wide progress for a book
  Future<Map<String, dynamic>> calculateClubProgress(
      String clubUuid, String bookUuid) async {
    final allProgress = await dao.watchBookProgress(clubUuid, bookUuid).first;

    if (allProgress.isEmpty) {
      return {
        'total': 0,
        'notStarted': 0,
        'onTrack': 0,
        'behind': 0,
        'finished': 0
      };
    }

    final stats = {
      'total': allProgress.length,
      'notStarted': 0,
      'onTrack': 0,
      'behind': 0,
      'finished': 0,
    };

    for (final progress in allProgress) {
      switch (progress.status) {
        case 'no_empezado':
          stats['notStarted'] = (stats['notStarted'] as int) + 1;
          break;
        case 'al_dia':
          stats['onTrack'] = (stats['onTrack'] as int) + 1;
          break;
        case 'atrasado':
          stats['behind'] = (stats['behind'] as int) + 1;
          break;
        case 'terminado':
          stats['finished'] = (stats['finished'] as int) + 1;
          break;
      }
    }

    return stats;
  }

  /// Check for inactive members (missed entire book)
  Future<List<ClubMember>> checkInactiveMembers(
      String clubUuid, String completedBookUuid) async {
    final members = await dao.watchClubMembers(clubUuid).first;
    final inactiveMembers = <ClubMember>[];

    for (final member in members) {
      if (member.memberRemoteId == null) continue;

      final progress = await dao.getUserProgress(
        clubUuid,
        completedBookUuid,
        member.memberRemoteId!,
      );

      // If no progress or never started, mark as inactive
      if (progress == null || progress.status == 'no_empezado') {
        inactiveMembers.add(member);

        // Mark member as inactive
        await dao.markMemberInactive(clubUuid, member.memberRemoteId!);
      }
    }

    return inactiveMembers;
  }
}
