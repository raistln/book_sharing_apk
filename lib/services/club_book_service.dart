import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../data/local/club_dao.dart';
import '../data/local/database.dart';
import '../models/club_enums.dart';
import '../models/reading_section.dart';

/// Service for managing club books and reading sections (tramos)
class ClubBookService {
  ClubBookService({
    required this.dao,
  });

  final ClubDao dao;
  final _uuid = const Uuid();

  // =====================================================================
  // BOOK LIFECYCLE
  // =====================================================================

  /// Add a new book to the club from a proposal
  Future<String> addBookFromProposal({
    required String clubUuid,
    required String proposalUuid,
    required String bookUuid,
    required int totalChapters,
    required SectionMode sectionMode,
    required ClubFrequency clubFrequency,
    int? frequencyDays,
    List<ReadingSection>? manualSections,
    DateTime? startDate,
  }) async {
    final clubBookUuid = _uuid.v4();

    // Generate sections
    final sections = sectionMode == SectionMode.automatico
        ? _generateAutomaticSections(
            totalChapters: totalChapters,
            frequency: clubFrequency,
            frequencyDays: frequencyDays,
            startDate: startDate ?? DateTime.now(),
          )
        : (manualSections ?? []);

    // Determine order position (last + 1)
    final existingBooks = await dao.watchClubBooks(clubUuid).first;
    final maxOrder = existingBooks.isEmpty
        ? 0
        : existingBooks
            .map((b) => b.orderPosition)
            .reduce((a, b) => a > b ? a : b);

    final companion = ClubBooksCompanion.insert(
      uuid: clubBookUuid,
      clubId: 0, // Will be set on sync
      clubUuid: clubUuid,
      bookUuid: bookUuid,
      orderPosition: Value(maxOrder + 1),
      status: const Value('proximo'), // New books start as "próximo"
      sectionMode: Value(sectionMode.value),
      totalChapters: totalChapters,
      sections: ReadingSectionListHelper.toJsonString(sections),
      startDate: Value(startDate),
      isDirty: const Value(true),
    );

    await dao.upsertClubBook(companion);

    // Mark proposal as winner
    await dao.closeProposal(proposalUuid, 'ganadora');

    return clubBookUuid;
  }

  /// Manually add a book (owner/admin only)
  Future<String> addBookDirectly({
    required String clubUuid,
    required String bookUuid,
    required int totalChapters,
    required SectionMode sectionMode,
    required ClubFrequency clubFrequency,
    int? frequencyDays,
    List<ReadingSection>? manualSections,
    DateTime? startDate,
  }) async {
    final clubBookUuid = _uuid.v4();

    final sections = sectionMode == SectionMode.automatico
        ? _generateAutomaticSections(
            totalChapters: totalChapters,
            frequency: clubFrequency,
            frequencyDays: frequencyDays,
            startDate: startDate ?? DateTime.now(),
          )
        : (manualSections ?? []);

    final existingBooks = await dao.watchClubBooks(clubUuid).first;
    final maxOrder = existingBooks.isEmpty
        ? 0
        : existingBooks
            .map((b) => b.orderPosition)
            .reduce((a, b) => a > b ? a : b);

    final companion = ClubBooksCompanion.insert(
      uuid: clubBookUuid,
      clubId: 0,
      clubUuid: clubUuid,
      bookUuid: bookUuid,
      orderPosition: Value(maxOrder + 1),
      status: const Value('proximo'),
      sectionMode: Value(sectionMode.value),
      totalChapters: totalChapters,
      sections: ReadingSectionListHelper.toJsonString(sections),
      startDate: Value(startDate),
      isDirty: const Value(true),
    );

    await dao.upsertClubBook(companion);

    return clubBookUuid;
  }

  /// Start a book (make it active)
  Future<void> startBook(String clubUuid, String bookUuid) async {
    // Get current active book (if any) and mark it as completed
    final currentBook = await dao.getCurrentBook(clubUuid);
    if (currentBook != null) {
      await completeBook(clubUuid, currentBook.uuid);
    }

    // Mark new book as active
    await dao.upsertClubBook(ClubBooksCompanion(
      uuid: Value(bookUuid),
      clubUuid: Value(clubUuid),
      status: const Value('activo'),
      startDate: Value(DateTime.now()),
      isDirty: const Value(true),
      updatedAt: Value(DateTime.now()),
    ));

    // Update club's current_book_id (will be synced to Supabase)
    // This would need to be done at the club level
  }

  /// Complete a book
  Future<void> completeBook(String clubUuid, String bookUuid) async {
    await dao.upsertClubBook(ClubBooksCompanion(
      uuid: Value(bookUuid),
      clubUuid: Value(clubUuid),
      status: const Value('completado'),
      endDate: Value(DateTime.now()),
      isDirty: const Value(true),
      updatedAt: Value(DateTime.now()),
    ));

    // Check for inactive members
    // This would typically be called by the ClubService
  }

  // =====================================================================
  // SECTION MANAGEMENT
  // =====================================================================

  /// Generate automatic sections based on club frequency
  List<ReadingSection> _generateAutomaticSections({
    required int totalChapters,
    required ClubFrequency frequency,
    int? frequencyDays,
    required DateTime startDate,
  }) {
    if (totalChapters <= 0) return [];

    final daysPerSection = frequencyDays ?? frequency.defaultDays ?? 30;

    // Calculate ideal chapters per section
    const idealSectionsCount = 4; // Aim for 4 sections minimum
    final chaptersPerSection = (totalChapters / idealSectionsCount).ceil();

    final sections = <ReadingSection>[];
    var currentChapter = 1;
    var sectionNumber = 1;
    var currentStartDate = startDate;

    while (currentChapter <= totalChapters) {
      final endChapter =
          (currentChapter + chaptersPerSection - 1).clamp(1, totalChapters);
      final closeDate = currentStartDate.add(Duration(days: daysPerSection));

      sections.add(ReadingSection(
        numero: sectionNumber,
        capituloInicio: currentChapter,
        capituloFin: endChapter,
        fechaApertura: currentStartDate,
        fechaCierre: closeDate,
      ));

      currentChapter = endChapter + 1;
      sectionNumber++;
      currentStartDate = closeDate;
    }

    return sections;
  }

  /// Get sections for a book
  Future<List<ReadingSection>> getSections(String bookUuid) async {
    final book = await dao.watchClubBooks('').first.then(
          (books) => books.firstWhere(
            (b) => b.uuid == bookUuid,
            orElse: () => throw Exception('Book not found'),
          ),
        );

    return ReadingSectionListHelper.fromJsonString(book.sections);
  }

  /// Get currently open section
  Future<ReadingSection?> getCurrentSection(String bookUuid) async {
    final sections = await getSections(bookUuid);
    return sections.cast<ReadingSection?>().firstWhere(
          (s) => s!.isAbierto,
          orElse: () => null,
        );
  }

  /// Check if a section is currently accessible
  Future<bool> isSectionAccessible(String bookUuid, int sectionNumber) async {
    final sections = await getSections(bookUuid);
    if (sectionNumber < 1 || sectionNumber > sections.length) {
      return false;
    }

    final section = sections[sectionNumber - 1];
    return section.isAbierto;
  }

  /// Get all accessible sections (opened)
  Future<List<ReadingSection>> getAccessibleSections(String bookUuid) async {
    final sections = await getSections(bookUuid);
    final now = DateTime.now();

    return sections.where((s) => now.isAfter(s.fechaApertura)).toList();
  }

  // =====================================================================
  // SECTION PROGRESSION
  // =====================================================================

  /// Update book status based on section progression
  Future<void> checkAndUpdateBookStatus(
      String clubUuid, String bookUuid) async {
    final sections = await getSections(bookUuid);

    // Check if all sections are closed
    final allClosed = sections.every((s) => s.isCerrado);

    if (allClosed) {
      // Mark book as completed
      await completeBook(clubUuid, bookUuid);
    }
  }

  /// Calculate overall book progress percentage (based on sections)
  Future<double> calculateBookProgress(String bookUuid) async {
    final sections = await getSections(bookUuid);
    if (sections.isEmpty) return 0.0;

    final completedSections = sections.where((s) => s.isCerrado).length;

    return (completedSections / sections.length) * 100;
  }
}
