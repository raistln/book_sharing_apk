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

/// Estadísticas semanales (Tiempo / Páginas totales / Páginas por día)
final weeklyStatsProvider = FutureProvider<WeeklyReadingStats>((ref) async {
  final repository = ref.watch(readingRepositoryProvider);
  return repository.getWeeklyStats();
});

/// Estadísticas mensuales (Tiempo / Páginas totales / Libros terminados)
final monthlyStatsProvider = FutureProvider<MonthlyReadingStats>((ref) async {
  final repository = ref.watch(readingRepositoryProvider);
  return repository.getMonthlyStats();
});

final bookProgressProvider =
    StreamProvider.family<ReadingTimelineEntry?, int>((ref, bookId) {
  final repository = ref.watch(readingRepositoryProvider);
  return repository.watchLatestProgress(bookId);
});

/// Controller para manejar el estado de la sesión de lectura activa
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
    await _sessionSubscription?.cancel();
    state = const AsyncValue.loading();

    print('[SessionController] 🎬 initializeSession: bookId=$bookId');

    try {
      final existingSession = await _repository.getActiveSession(bookId);

      if (existingSession != null) {
        final sessionAge = DateTime.now().difference(existingSession.startTime);
        print(
            '[SessionController] 📌 Sesión existente encontrada: id=${existingSession.id}, edad=${sessionAge.inHours}h');

        if (sessionAge.inHours > 12) {
          print(
              '[SessionController] 🧟 Sesión zombie detectada, eliminando...');
          await _repository.deleteSession(existingSession.id);
          final newSession = await _repository.startSession(
            bookId: bookId,
            bookUuid: bookUuid,
          );
          state = AsyncValue.data(newSession);
        } else {
          print('[SessionController] ▶️  Reanudando sesión existente');
          state = AsyncValue.data(existingSession);
        }
      } else {
        print('[SessionController] ➕ No hay sesión activa, creando nueva...');
        final newSession = await _repository.startSession(
          bookId: bookId,
          bookUuid: bookUuid,
        );
        state = AsyncValue.data(newSession);
      }
    } catch (e, st) {
      print('[SessionController] ❌ ERROR en initializeSession: $e');
      state = AsyncValue.error(e, st);
      return;
    }

    _sessionSubscription = _repository.watchActiveSession(bookId).listen(
      (session) {
        if (mounted) {
          print(
              '[SessionController] 🔄 Stream update: session=${session?.id}, endTime=${session?.endTime}');
          state = AsyncValue.data(session);
        }
      },
      onError: (e, st) {
        if (mounted) {
          print('[SessionController] ❌ Stream error: $e');
          state = AsyncValue.error(e, st);
        }
      },
    );
  }

  Future<void> endSession(int endPage, {String? notes, String? mood}) async {
    final currentSession = state.value;
    if (currentSession == null) {
      print('[SessionController] ⚠️  endSession: No hay sesión activa');
      return;
    }

    final activeUser = _ref.read(activeUserProvider).value;
    if (activeUser == null) {
      print('[SessionController] ❌ endSession: No hay usuario activo');
      state = AsyncValue.error('No active user', StackTrace.current);
      return;
    }

    print('[SessionController] 💾 endSession INICIO:');
    print('  sessionId = ${currentSession.id}');
    print('  endPage = $endPage');
    print('  notes = "$notes"');
    print('  mood = "$mood"');
    print('  userId = ${activeUser.id}');

    try {
      await _repository.endSessionWithContext(
        session: currentSession,
        endPage: endPage,
        notes: notes,
        mood: mood,
        userId: activeUser.id,
      );

      print('[SessionController] ✅ endSession: Guardado exitoso');

      state = const AsyncValue.data(null);

      // Invalidar ambos providers de estadísticas
      _ref.invalidate(weeklyStatsProvider);
      _ref.invalidate(monthlyStatsProvider);
      _ref.invalidate(readingBooksProvider);
      _ref.invalidate(readingTimelineProvider(currentSession.bookId));

      print('[SessionController] 🔄 Providers invalidados');
    } catch (e, st) {
      print('[SessionController] ❌ ERROR en endSession:');
      print('  Error: $e');
      print('  StackTrace: $st');
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> cancelSession() async {
    final currentSession = state.value;
    if (currentSession == null) return;

    print(
        '[SessionController] 🗑️  cancelSession: Eliminando sesión ${currentSession.id}');

    try {
      await _repository.deleteSession(currentSession.id);
      state = const AsyncValue.data(null);
      print('[SessionController] ✅ Sesión cancelada y eliminada');
    } catch (e, st) {
      print('[SessionController] ❌ ERROR en cancelSession: $e');
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> finishBook(int endPage, {String? notes}) async {
    final currentSession = state.value;

    final activeUser = _ref.read(activeUserProvider).value;
    if (activeUser == null) {
      print('[SessionController] ❌ finishBook: No hay usuario activo');
      state = AsyncValue.error('No active user', StackTrace.current);
      return;
    }

    final bookId = currentSession?.bookId;
    if (bookId == null) {
      print('[SessionController] ❌ finishBook: No se pudo determinar el libro');
      state = AsyncValue.error(
        'No se pudo determinar el libro activo.',
        StackTrace.current,
      );
      return;
    }

    print('[SessionController] 🏁 finishBook INICIO:');
    print('  bookId = $bookId');
    print('  endPage = $endPage');
    print('  notes = "$notes"');

    try {
      if (currentSession != null) {
        print(
            '[SessionController] 💾 Cerrando sesión antes de marcar como terminado...');
        await _repository.endSessionWithContext(
          session: currentSession,
          endPage: endPage,
          notes: notes,
          userId: activeUser.id,
        );
      }

      print('[SessionController] 🏁 Marcando libro como terminado...');
      await _repository.finishBook(
        bookId: bookId,
        userId: activeUser.id,
        finalPage: endPage,
        notes: notes,
      );

      print('[SessionController] ✅ finishBook: Libro terminado exitosamente');

      state = const AsyncValue.data(null);

      // Invalidar ambos providers de estadísticas
      _ref.invalidate(weeklyStatsProvider);
      _ref.invalidate(monthlyStatsProvider);
      _ref.invalidate(readingBooksProvider);
      _ref.invalidate(readingTimelineProvider(bookId));

      print('[SessionController] 🔄 Providers invalidados');
    } catch (e, st) {
      print('[SessionController] ❌ ERROR en finishBook:');
      print('  Error: $e');
      print('  StackTrace: $st');
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
    } catch (e) {
      print('[SessionController] ⚠️  ERROR en updateProgress: $e');
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
