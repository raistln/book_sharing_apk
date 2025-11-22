import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/stats_service.dart';
import 'book_providers.dart';

final statsServiceProvider = Provider<StatsService>((ref) {
  final bookRepository = ref.watch(bookRepositoryProvider);
  final loanRepository = ref.watch(loanRepositoryProvider);
  return StatsService(bookRepository, loanRepository);
});

final statsSummaryProvider = StreamProvider.autoDispose<StatsSummary>((ref) {
  final service = ref.watch(statsServiceProvider);
  final activeUserAsync = ref.watch(activeUserProvider);
  final controller = StreamController<StatsSummary>();

  Future<void> emitSummary() async {
    try {
      final owner = activeUserAsync.asData?.value;
      if (owner == null) {
        if (!controller.isClosed) {
          controller.add(
            const StatsSummary(
              totalBooks: 0,
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

  emitSummary();

  final timer = Timer.periodic(const Duration(seconds: 5), (_) {
    emitSummary();
  });

  ref.onDispose(() {
    timer.cancel();
    controller.close();
  });

  return controller.stream;
});
