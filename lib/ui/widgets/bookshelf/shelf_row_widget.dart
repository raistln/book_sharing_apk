import 'package:flutter/material.dart';
import '../../../models/bookshelf_models.dart';
import '../../../providers/bookshelf_providers.dart';
import 'book_spine_widget.dart';

class ShelfRowWidget extends StatelessWidget {
  final List<BookWithRating> books;
  final ShelfThemeConfig themeConfig;

  const ShelfRowWidget({
    super.key,
    required this.books,
    required this.themeConfig,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // The books row
        Container(
          height: 190, // Slightly taller than spines
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.bottomLeft,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: books
                .map((bwr) => BookSpineWidget(
                      book: bwr.book,
                      rating: bwr.rating,
                    ))
                .toList(),
          ),
        ),

        // The wooden shelf plank
        Stack(
          children: [
            // Top surface shadow
            Container(
              height: 12,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.2),
                    themeConfig.shelfColor,
                  ],
                ),
              ),
            ),

            // Front edge
            Container(
              margin: const EdgeInsets.only(top: 10),
              height: 14,
              decoration: BoxDecoration(
                color: themeConfig.shelfEdgeColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 32), // Space between shelves
      ],
    );
  }
}
