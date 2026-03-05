import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';

import '../empty_state.dart';
import '../../../services/google_books_client.dart';
import '../../../services/open_library_client.dart';

/// Export action enum for library export
enum ExportAction { share, download }

/// Shows a feedback snackbar with the given message
void showFeedbackSnackBar({
  required BuildContext context,
  required String message,
  required bool isError,
}) {
  final theme = Theme.of(context);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor:
          isError ? theme.colorScheme.error : theme.colorScheme.primary,
    ),
  );
}

/// Maps file extension to MimeType for file_saver
MimeType mapMimeType(String extension) {
  switch (extension.toLowerCase()) {
    case 'pdf':
      return MimeType.pdf;
    case 'json':
      return MimeType.json;
    case 'csv':
      return MimeType.csv;
    default:
      return MimeType.other;
  }
}

/// Empty state widget for library
class EmptyLibraryState extends StatelessWidget {
  const EmptyLibraryState({super.key, required this.onAddBook});

  final VoidCallback onAddBook;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.menu_book_outlined,
      title: 'Tu biblioteca está vacía',
      message:
          'Registra tu primer libro para organizar préstamos y compartir lecturas con tu grupo.',
      action: EmptyStateAction(
        label: 'Registrar libro',
        icon: Icons.add_circle_outline,
        onPressed: onAddBook,
      ),
    );
  }
}

/// Book source enum for search results
enum BookSource { openLibrary, googleBooks }

/// Book candidate model for search results
class BookCandidate {
  const BookCandidate({
    required this.title,
    this.author,
    this.isbn,
    this.description,
    this.coverUrl,
    this.categories = const [],
    this.pageCount,
    this.publicationYear,
    this.workKey,
    this.editionKey,
    required this.source,
  });

  factory BookCandidate.fromOpenLibrary(OpenLibraryBookResult result) {
    return BookCandidate(
      title: result.title,
      author: result.author,
      isbn: result.isbn,
      coverUrl: result.coverUrl,
      categories: result.subjects,
      pageCount: result.pageCount,
      publicationYear: _extractYear(result.publishedDate),
      workKey: result.key,
      editionKey: result.editionKey,
      source: BookSource.openLibrary,
    );
  }

  factory BookCandidate.fromGoogleBooks(GoogleBooksVolume volume) {
    return BookCandidate(
      title: volume.title,
      author: volume.primaryAuthor,
      isbn: volume.isbn,
      description: volume.description,
      coverUrl: volume.thumbnailUrl,
      categories: volume.categories,
      pageCount: volume.pageCount,
      publicationYear: _extractYear(volume.publishedDate),
      source: BookSource.googleBooks,
    );
  }

  final String title;
  final String? author;
  final String? isbn;
  final String? description;
  final String? coverUrl;
  final List<String> categories;
  final int? pageCount;
  final int? publicationYear;
  final String? workKey;
  final String? editionKey;
  final BookSource source;

  /// Extracts year from date string (e.g., "2020-01-15" -> 2020)
  static int? _extractYear(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    final match = RegExp(r'\d{4}').firstMatch(dateString);
    return match != null ? int.tryParse(match.group(0)!) : null;
  }
}
