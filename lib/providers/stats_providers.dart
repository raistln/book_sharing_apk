import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/database.dart';
import '../services/stats_service.dart';
import '../utils/reading_rhythm_helper.dart';
import 'book_providers.dart';

final statsServiceProvider = Provider<StatsService>((ref) {
  final bookRepository = ref.watch(bookRepositoryProvider);
  final loanRepository = ref.watch(loanRepositoryProvider);
  return StatsService(bookRepository, loanRepository);
});

final statsSummaryProvider = StreamProvider.autoDispose<StatsSummary>((ref) {
  final service = ref.watch(statsServiceProvider);
  final controller = StreamController<StatsSummary>();

  Future<void> emitForUser(LocalUser? owner) async {
    try {
      if (owner == null) {
        if (!controller.isClosed) {
          controller.add(
            const StatsSummary(
              totalBooks: 0,
              totalBooksRead: 0,
              availableBooks: 0,
              totalLoans: 0,
              activeLoans: 0,
              returnedLoans: 0,
              expiredLoans: 0,
              topBooks: [],
              activeLoanDetails: [],
            ),
          );
        }
        return;
      }

      final summary = await service.loadSummary(owner: owner);
      if (!controller.isClosed) {
        controller.add(summary);
      }
    } catch (error, stackTrace) {
      if (!controller.isClosed) {
        controller.addError(error, stackTrace);
      }
    }
  }

  Future<void> refresh() async {
    final activeUserState = ref.read(activeUserProvider);
    await emitForUser(activeUserState.asData?.value);
  }

  final subscription =
      ref.listen<AsyncValue<LocalUser?>>(activeUserProvider, (_, next) {
    emitForUser(next.asData?.value);
  });

  emitForUser(ref.read(activeUserProvider).asData?.value);

  final timer = Timer.periodic(const Duration(seconds: 5), (_) {
    refresh();
  });

  ref.onDispose(() {
    subscription.close();
    timer.cancel();
    controller.close();
  });

  return controller.stream;
});

final readBooksProvider =
    FutureProvider.autoDispose<List<ReadBookItem>>((ref) async {
  final service = ref.watch(statsServiceProvider);
  final activeUser = ref.watch(activeUserProvider).value;

  if (activeUser == null) return [];

  return service.getReadBooks(userId: activeUser.id);
});

final readingRhythmProvider =
    FutureProvider.autoDispose<ReadingRhythmData>((ref) async {
  final books = await ref.watch(bookListProvider.future);
  if (books.isEmpty) {
    return ReadingRhythmData(
      rows: [],
      startDate: DateTime.now().subtract(const Duration(days: 30)),
      endDate: DateTime.now(),
      insight: "Empieza a leer para ver tu ritmo.",
    );
  }

  // Optimized fetching:
  // 1. Filter locally to find likely candidates (status active or read)
  final candidates = books.where((b) {
    final status = b.readingStatus.toLowerCase();
    return ['reading', 'finished', 'abandoned', 'paused', 'rereading']
            .contains(status) ||
        b.isRead;
  }).toList();

  // 2. Sort by updated/read time to get top 10 relevant books
  candidates.sort((a, b) {
    // Prefer readAt, then updatedAt
    final aTime = a.readAt ?? a.updatedAt;
    final bTime = b.readAt ?? b.updatedAt;
    return bTime.compareTo(aTime);
  });

  final topCandidates = candidates.take(10).toList();

  // 3. Fetch timeline entries for these books
  final timelineDao = ref.watch(timelineEntryDaoProvider);
  final entriesMap = <int, List<ReadingTimelineEntry>>{};

  for (var book in topCandidates) {
    entriesMap[book.id] = await timelineDao.getEntriesForBook(book.id);
  }

  // 4. Process
  return ReadingRhythmHelper.processData(books, entriesMap);
});
