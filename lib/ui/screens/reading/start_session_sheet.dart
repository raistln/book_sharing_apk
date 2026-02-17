import 'dart:io';
import 'package:flutter/material.dart';

import '../../../data/local/database.dart';
import 'reading_session_screen.dart';
import '../../widgets/library/book_details_page.dart';

class StartSessionSheet extends StatefulWidget {
  const StartSessionSheet({super.key, required this.book});

  final Book book;

  @override
  State<StartSessionSheet> createState() => _StartSessionSheetState();
}

class _StartSessionSheetState extends State<StartSessionSheet> {
  int? _selectedDurationMinutes;
  bool _isZenMode = false;

  final List<int> _durationOptions = [15, 30, 45, 60];

  void _startSession() {
    Navigator.pop(context); // Close sheet
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReadingSessionScreen(
          book: widget.book,
          targetDuration: _selectedDurationMinutes != null
              ? Duration(minutes: _selectedDurationMinutes!)
              : null,
          initialZenMode: _isZenMode,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Small cover
              Container(
                width: 40,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.grey[300],
                  image: widget.book.coverPath != null
                      ? DecorationImage(
                          image: File(widget.book.coverPath!).existsSync()
                              ? FileImage(File(widget.book.coverPath!))
                                  as ImageProvider
                              : NetworkImage(widget.book.coverPath!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: widget.book.coverPath == null
                    ? const Icon(Icons.book, size: 20, color: Colors.grey)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Comenzar sesión',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context); // Close sheet first
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    BookDetailsPage(bookId: widget.book.id),
                              ),
                            );
                          },
                          icon: const Icon(Icons.arrow_forward_ios, size: 16),
                          tooltip: 'Ver detalles del libro',
                        ),
                      ],
                    ),
                    Text(
                      widget.book.title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Objetivo de tiempo',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _durationOptions.map((minutes) {
              final isSelected = _selectedDurationMinutes == minutes;
              return Material(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedDurationMinutes = null;
                      } else {
                        _selectedDurationMinutes = minutes;
                      }
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$minutes',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          'min',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Modo Lectura Zen'),
            subtitle: const Text(
                'Pantalla oscura, brillo mínimo y sin distracciones'),
            secondary: const Icon(Icons.nights_stay_outlined),
            value: _isZenMode,
            onChanged: (value) {
              setState(() {
                _isZenMode = value;
              });
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton.icon(
              onPressed: _startSession,
              icon: const Icon(Icons.play_arrow),
              label: const Text('EMPEZAR A LEER'),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }
}
