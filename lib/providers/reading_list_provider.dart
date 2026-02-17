import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local/database.dart';
import 'book_providers.dart';

// Provider to watch books currently being read
final readingBooksProvider = StreamProvider.autoDispose<List<Book>>((ref) {
  final dao = ref.watch(bookDaoProvider);
  final activeUser = ref.watch(activeUserProvider).value;

  if (activeUser == null) {
    return const Stream.empty();
  }

  return dao.watchActiveBooks(ownerUserId: activeUser.id).map((books) {
    final filtered = books.where((book) {
      final status = book.readingStatus;
      return status == 'reading' || status == 'rereading' || status == 'paused';
    }).toList();

    // Sort: Reading/Rereading first, then Paused
    filtered.sort((a, b) {
      final aIsActive =
          a.readingStatus == 'reading' || a.readingStatus == 'rereading';
      final bIsActive =
          b.readingStatus == 'reading' || b.readingStatus == 'rereading';

      if (aIsActive && !bIsActive) return -1;
      if (!aIsActive && bIsActive) return 1;
      return 0;
    });

    return filtered;
  });
});
