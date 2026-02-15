import 'dart:io';
import 'package:flutter/material.dart';
import '../../../data/local/database.dart';
import '../../widgets/library/book_details_page.dart';

class BookSpineWidget extends StatelessWidget {
  final Book book;
  final int? rating;
  final double height;

  const BookSpineWidget({
    super.key,
    required this.book,
    this.rating,
    this.height = 180,
  });

  @override
  Widget build(BuildContext context) {
    // Width based on page count: minimum 30, maximum 60.
    // Assuming average book is 300 pages.
    final pages = book.pageCount ?? 200;
    final width = (pages / 10).clamp(30.0, 60.0);

    // Spine color: derived from title hash or cover dominant color simulation
    final Color spineColor = _getSpineColor();

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => BookDetailsPage(bookId: book.id),
          ),
        );
      },
      child: Container(
        width: width,
        height: height,
        margin: const EdgeInsets.symmetric(horizontal: 1),
        decoration: BoxDecoration(
          color: spineColor,
          borderRadius: const BorderRadius.horizontal(
            left: Radius.circular(2),
            right: Radius.circular(2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 2,
              offset: const Offset(1, 0),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Cover image overlay (simulated as spine texture)
            if (book.coverPath != null)
              Positioned.fill(
                child: Opacity(
                  opacity: 0.4,
                  child: Image.file(
                    File(book.coverPath!),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              ),

            // Decorative highlights/shadows for spine 3D effect
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.1),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.2),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),

            // Text content (rotated)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              child: RotatedBox(
                quarterTurns: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      book.title.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _getTextColor(spineColor),
                        fontSize: width > 40 ? 12 : 10,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Georgia', // Literary feel
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Rating indicator at the bottom
            if (rating != null)
              Positioned(
                bottom: 8,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      rating.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getSpineColor() {
    // Generate a consistent color based on title hash
    final int hash = book.title.hashCode;
    final List<Color> palette = [
      const Color(0xFF2C3E50), // Midnight Blue
      const Color(0xFF7B241C), // Deep Red
      const Color(0xFF145A32), // Dark Green
      const Color(0xFF512E5F), // Purple
      const Color(0xFF784212), // Brown
      const Color(0xFF154360), // Royal Blue
      const Color(0xFF1B2631), // Charcoal
      const Color(0xFF641E16), // Blood Red
    ];
    return palette[hash.abs() % palette.length];
  }

  Color _getTextColor(Color background) {
    // Basic luminance check
    return background.computeLuminance() > 0.5 ? Colors.black87 : Colors.white;
  }
}
