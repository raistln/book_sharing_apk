import 'package:flutter_riverpod/flutter_riverpod.dart';

class LibraryFilters {
  const LibraryFilters({
    this.status = 'all',
    this.author,
    this.query = '',
  });

  final String status;
  final String? author;
  final String query;

  LibraryFilters copyWith({
    String? status,
    String? author,
    bool resetAuthor = false,
    String? query,
  }) {
    return LibraryFilters(
      status: status ?? this.status,
      author: resetAuthor ? null : author ?? this.author,
      query: query ?? this.query,
    );
  }
}

class LibraryFiltersNotifier extends StateNotifier<LibraryFilters> {
  LibraryFiltersNotifier() : super(const LibraryFilters());

  void setStatus(String status) {
    state = state.copyWith(status: status);
  }

  void setAuthor(String? author) {
    state = state.copyWith(author: author, resetAuthor: author == null);
  }

  void setQuery(String query) {
    if (query == state.query) {
      return;
    }
    state = state.copyWith(query: query);
  }

  void reset() {
    state = const LibraryFilters();
  }
}

final libraryFiltersProvider =
    StateNotifierProvider<LibraryFiltersNotifier, LibraryFilters>(
  (ref) => LibraryFiltersNotifier(),
);
