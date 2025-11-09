import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'book_providers.dart';
import '../services/book_import_service.dart';

final bookImportServiceProvider = Provider<BookImportService>((ref) {
  final bookRepository = ref.watch(bookRepositoryProvider);
  return BookImportService(bookRepository);
});
