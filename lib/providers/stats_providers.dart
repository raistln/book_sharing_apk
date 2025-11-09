import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/stats_service.dart';
import 'book_providers.dart';

final statsServiceProvider = Provider<StatsService>((ref) {
  final bookRepository = ref.watch(bookRepositoryProvider);
  final loanRepository = ref.watch(loanRepositoryProvider);
  return StatsService(bookRepository, loanRepository);
});

final statsSummaryProvider = FutureProvider<StatsSummary>((ref) async {
  final service = ref.watch(statsServiceProvider);
  return service.loadSummary();
});
