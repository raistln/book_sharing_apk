import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/database.dart';
import '../data/local/reading_session_dao.dart';
import '../data/repositories/reading_repository.dart';
import 'book_providers.dart';
import 'reading_list_provider.dart';

/// DAO Provider
final readingSessionDaoProvider = Provider<ReadingSessionDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ReadingSessionDao(db);
});

/// Repository Provider
final readingRepositoryProvider = Provider<ReadingRepository>((ref) {
  final readingSessionDao = ref.watch(readingSessionDaoProvider);
  final bookDao = ref.watch(bookDaoProvider);
  final timelineEntryDao = ref.watch(timelineEntryDaoProvider);
  return ReadingRepository(readingSessionDao, bookDao, timelineEntryDao);
});

/// Watch all sessions for a specific book
final bookSessionsProvider =
    StreamProvider.family<List<ReadingSession>, int>((ref, bookId) {
  final dao = ref.watch(readingSessionDaoProvider);
  return dao.watchSessionsForBook(bookId);
});

/// Get active session for a specific book (if any)
final activeSessionProvider =
    FutureProvider.family<ReadingSession?, int>((ref, bookId) async {
  final repository = ref.watch(readingRepositoryProvider);
  return repository.getActiveSession(bookId);
});

final readingStatsProvider = FutureProvider<ReadingStats>((ref) async {
  final repository = ref.watch(readingRepositoryProvider);
  return repository.getWeeklyStats();
});

final bookProgressProvider =
    StreamProvider.family<ReadingTimelineEntry?, int>((ref, bookId) {
  final repository = ref.watch(readingRepositoryProvider);
  return repository.watchLatestProgress(bookId);
});

/// Controller for managing the current reading session state
class ReadingSessionController
    extends StateNotifier<AsyncValue<ReadingSession?>> {
  ReadingSessionController(this._repository, this._ref)
      : super(const AsyncValue.data(null));

  final ReadingRepository _repository;
  final Ref _ref;
  StreamSubscription? _sessionSubscription;

  @override
  void dispose() {
    _sessionSubscription?.cancel();
    super.dispose();
  }

  Future<void> initializeSession(int bookId, String bookUuid) async {
    // 1. Cancel previous subscription if any
    await _sessionSubscription?.cancel();
    state = const AsyncValue.loading();

    try {
      // 1. Check for existing session
      final existingSession = await _repository.getActiveSession(bookId);

      if (existingSession != null) {
        // 2. Check if stale (> 12 hours)
        final sessionAge = DateTime.now().difference(existingSession.startTime);
        if (sessionAge.inHours > 12) {
          // Stale: Close it (repository handles logic to set end time = start time if needed,
          // but we can just use deleteSession or endSession here to be sure)
          // For safety, let's just close it as 'abandoned'/zombie
          await _repository.deleteSession(existingSession.id);

          // Start fresh
          final newSession = await _repository.startSession(
            bookId: bookId,
            bookUuid: bookUuid,
          );
          state = AsyncValue.data(newSession);
        } else {
          // Resume
          state = AsyncValue.data(existingSession);
        }
      } else {
        // 3. Start new session
        final newSession = await _repository.startSession(
          bookId: bookId,
          bookUuid: bookUuid,
        );
        state = AsyncValue.data(newSession);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return;
    }

    // 3. Subscribe to the stream for updates (The Truth)
    _sessionSubscription = _repository.watchActiveSession(bookId).listen(
      (session) {
        if (mounted) {
          state = AsyncValue.data(session);
        }
      },
      onError: (e, st) {
        if (mounted) {
          state = AsyncValue.error(e, st);
        }
      },
    );
  }

  Future<void> endSession(int endPage, {String? notes, String? mood}) async {
    final currentSession = state.value;
    if (currentSession == null) return;

    final activeUser = _ref.read(activeUserProvider).value;
    if (activeUser == null) {
      state = AsyncValue.error('No active user', StackTrace.current);
      return;
    }

    state = const AsyncValue.loading();
    try {
      // Use the improved endSessionWithContext method
      await _repository.endSessionWithContext(
        session: currentSession,
        endPage: endPage,
        notes: notes,
        mood: mood,
        userId: activeUser.id,
      );
      state = const AsyncValue.data(null);
      _ref.invalidate(readingStatsProvider);
      _ref.invalidate(readingBooksProvider);
      // Invalidate timeline so UI updates
      _ref.invalidate(readingTimelineProvider(currentSession.bookId));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Cancels the current session (deletes it)
  Future<void> cancelSession() async {
    final currentSession = state.value;
    if (currentSession == null) return;

    state = const AsyncValue.loading();
    try {
      // We need a method in repository to delete/cancel
      await _repository.deleteSession(currentSession.id);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> finishBook(int endPage, {String? notes}) async {
    final currentSession = state.value;
    // We can finish a book even without an active session (e.g. just updating progress),
    // but here we likely have one. If we have one, let's end it first.

    final activeUser = _ref.read(activeUserProvider).value;
    if (activeUser == null) {
      state = AsyncValue.error('No active user', StackTrace.current);
      return;
    }

    state = const AsyncValue.loading();
    try {
      if (currentSession != null) {
        // End current session first
        await _repository.endSessionWithContext(
          session: currentSession,
          endPage: endPage,
          notes: notes,
          userId: activeUser.id,
        );
      }

      // Then mark book as finished
      await _repository.finishBook(
        bookId: currentSession?.bookId ??
            -1, // Fallback or handle error? Ideally we need bookId
        userId: activeUser.id,
        finalPage: endPage,
        notes: notes,
      );

      state = const AsyncValue.data(null);
      _ref.invalidate(readingStatsProvider);
      _ref.invalidate(readingBooksProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateProgress(int currentPage) async {
    final currentSession = state.value;
    if (currentSession == null) return;

    try {
      await _repository.updateSessionProgress(
        sessionId: currentSession.id,
        currentPage: currentPage,
      );
      // Optimistically update state or fetch fresh?
      // For now, assume success and keep current session but maybe update page count in memory if needed
    } catch (e) {
      // Handle error silently or log
    }
  }

  void setSession(ReadingSession? session) {
    state = AsyncValue.data(session);
  }
}

final readingSessionControllerProvider = StateNotifierProvider<
    ReadingSessionController, AsyncValue<ReadingSession?>>((ref) {
  final repository = ref.watch(readingRepositoryProvider);
  return ReadingSessionController(repository, ref);
});
