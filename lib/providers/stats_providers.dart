import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/database.dart';
import '../services/stats_service.dart';
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

  final subscription = ref.listen<AsyncValue<LocalUser?>>(activeUserProvider, (_, next) {
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
