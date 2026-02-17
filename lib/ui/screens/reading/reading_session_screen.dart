import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:screen_brightness/screen_brightness.dart';

import 'package:permission_handler/permission_handler.dart';

import '../../../data/local/database.dart';
import '../../../providers/reading_providers.dart';
import '../../widgets/library/review_dialog.dart';
import '../../widgets/library/book_details_page.dart';

class ReadingSessionScreen extends ConsumerStatefulWidget {
  const ReadingSessionScreen({
    super.key,
    required this.book,
    this.targetDuration,
    this.initialZenMode = false,
  });

  final Book book;
  final Duration? targetDuration;
  final bool initialZenMode;

  @override
  ConsumerState<ReadingSessionScreen> createState() =>
      _ReadingSessionScreenState();
}

class _ReadingSessionScreenState extends ConsumerState<ReadingSessionScreen> {
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  DateTime? _startTime;

  bool _isZenMode = false;
  int _lastKnownPage = 0;

  @override
  void initState() {
    super.initState();
    _isZenMode = widget.initialZenMode;
    // Keep screen on while reading
    WakelockPlus.enable();
    _initBrightness();

    // Defer session initialization to controller
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(readingSessionControllerProvider.notifier)
          .initializeSession(widget.book.id, widget.book.uuid);
    });
  }

  Future<void> _initBrightness() async {
    try {
      if (_isZenMode) {
        await ScreenBrightness().setScreenBrightness(0.05);
      }
    } catch (e) {
      debugPrint('Error getting brightness: $e');
    }
  }

  Future<void> _toggleZenMode() async {
    final newZenMode = !_isZenMode;

    // If enabling Zen Mode, check/request DND permission
    if (newZenMode) {
      if (Platform.isAndroid) {
        final status = await Permission.accessNotificationPolicy.status;
        if (!status.isGranted) {
          await Permission.accessNotificationPolicy.request();
        }
      }
    }

    setState(() {
      _isZenMode = newZenMode;
    });

    try {
      if (_isZenMode) {
        await ScreenBrightness().setScreenBrightness(0.05); // Very low
      } else {
        await ScreenBrightness().resetScreenBrightness();
      }
    } catch (e) {
      debugPrint('Error setting brightness: $e');
    }
  }

  void _startTimer(DateTime startTime) {
    _startTime = startTime;
    _elapsed = DateTime.now().difference(_startTime!);

    if (_timer != null && _timer!.isActive) return;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _elapsed = DateTime.now().difference(_startTime!);
        });

        // Strict Timer Check
        if (widget.targetDuration != null &&
            _elapsed >= widget.targetDuration!) {
          timer.cancel();
          _showTimeIsUpDialog();
        }
      }
    });
  }

  void _showTimeIsUpDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('¡Tiempo cumplido!'),
        content: const Text('Has alcanzado tu objetivo de lectura.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Optionally continue reading or end session?
              // For now, just let them stay on screen or end manually.
            },
            child: const Text('Continuar leyendo'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _endSession();
            },
            child: const Text('Terminar sesión'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    WakelockPlus.disable();
    ScreenBrightness().resetScreenBrightness();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return duration.inHours > 0
        ? "$hours:$minutes:$seconds"
        : "$minutes:$seconds";
  }

  Future<void> _endSession() async {
    final controller = ref.read(readingSessionControllerProvider.notifier);

    // Show dialog to get end page
    final result = await showDialog<_EndSessionResult>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _EndSessionDialog(
        initialPage: _lastKnownPage,
        bookTitle: widget.book.title,
        duration: _elapsed,
      ),
    );

    if (result != null && mounted) {
      if (result.cancelSession) {
        // Cancel logic: Delete the session
        await controller.cancelSession();
      } else if (result.finishBook) {
        // Mark as finished
        await controller.finishBook(
          result.page,
          notes: result.notes,
        );

        if (mounted) {
          // Show review dialog
          await showAddReviewDialog(context, ref, widget.book);
        }
      } else {
        // Just end session
        await controller.endSession(result.page, notes: result.notes);
      }

      if (mounted) {
        Navigator.pop(context); // Close session screen

        if (!result.cancelSession && result.viewBook) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookDetailsPage(bookId: widget.book.id),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(readingSessionControllerProvider);

    // Listen to state changes to start timer when data is available
    ref.listen(readingSessionControllerProvider, (previous, next) {
      if (next.value != null) {
        _startTimer(next.value!.startTime);
      }
    });

    final remaining = widget.targetDuration != null
        ? widget.targetDuration! - _elapsed
        : _elapsed;
    double progress = 0.0;
    if (widget.targetDuration != null && widget.targetDuration!.inSeconds > 0) {
      progress = (_elapsed.inSeconds / widget.targetDuration!.inSeconds)
          .clamp(0.0, 1.0);
    }

    return ColorFiltered(
      colorFilter: _isZenMode
          ? const ColorFilter.mode(Colors.grey, BlendMode.saturation)
          : const ColorFilter.mode(Colors.transparent, BlendMode.saturation),
      child: Scaffold(
        backgroundColor: _isZenMode ? Colors.black : null,
        appBar: AppBar(
          title: Text(widget.book.title),
          backgroundColor: _isZenMode ? Colors.black : null,
          foregroundColor: _isZenMode ? Colors.white54 : null,
          actions: [
            IconButton(
              icon: Icon(_isZenMode ? Icons.nightlight_round : Icons.wb_sunny),
              onPressed: _toggleZenMode,
              tooltip: _isZenMode ? 'Modo Normal' : 'Modo Lectura Nocturna',
            ),
          ],
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              // Just close screen, session continues in background
              Navigator.pop(context);
            },
          ),
        ),
        body: sessionState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error al iniciar sesión: $err',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      ref
                          .read(readingSessionControllerProvider.notifier)
                          .initializeSession(widget.book.id, widget.book.uuid);
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          ),
          data: (session) {
            if (session == null) {
              // Should essentially be loading or initial state
              return const Center(child: CircularProgressIndicator());
            }

            return SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Spacer(),
                    // Book Cover (Opaque)
                    Opacity(
                      opacity: _isZenMode ? 0.6 : 1.0,
                      child: Container(
                        height: 200,
                        width: 130,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                          image: widget.book.coverPath != null
                              ? DecorationImage(
                                  image: File(widget.book.coverPath!)
                                          .existsSync()
                                      ? FileImage(File(widget.book.coverPath!))
                                          as ImageProvider
                                      : NetworkImage(widget.book.coverPath!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: widget.book.coverPath == null
                            ? const Icon(Icons.book,
                                size: 64, color: Colors.grey)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 60),

                    // Circular Timer
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 240,
                          height: 240,
                          child: CircularProgressIndicator(
                            value:
                                widget.targetDuration != null ? progress : null,
                            strokeWidth: 6,
                            backgroundColor: Theme.of(context)
                                .dividerColor
                                .withValues(alpha: 0.1),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _isZenMode
                                  ? Colors.grey.shade700
                                  : Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _formatDuration(remaining),
                              style: Theme.of(context)
                                  .textTheme
                                  .displayLarge
                                  ?.copyWith(
                                fontFeatures: [
                                  const FontFeature.tabularFigures()
                                ],
                                color: _isZenMode ? Colors.grey : null,
                              ),
                            ),
                            if (widget.targetDuration != null)
                              Text(
                                'restante',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium
                                    ?.copyWith(
                                      color: _isZenMode ? Colors.grey : null,
                                    ),
                              ),
                          ],
                        ),
                      ],
                    ),

                    const Spacer(),

                    // End Session Button
                    TextButton.icon(
                      onPressed: () => _endSession(),
                      icon: Icon(
                        Icons.stop,
                        color: _isZenMode
                            ? Colors.grey
                            : Theme.of(context).colorScheme.error,
                      ),
                      label: Text(
                        'TERMINAR SESIÓN',
                        style: TextStyle(
                          color: _isZenMode
                              ? Colors.grey
                              : Theme.of(context).colorScheme.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _EndSessionResult {
  final int page;
  final String? notes;
  final bool viewBook;
  final bool finishBook;
  final bool cancelSession;

  _EndSessionResult(
    this.page,
    this.notes,
    this.viewBook, {
    this.finishBook = false,
    this.cancelSession = false,
  });
}

class _EndSessionDialog extends StatefulWidget {
  const _EndSessionDialog({
    required this.initialPage,
    required this.bookTitle,
    required this.duration,
  });

  final int initialPage;
  final String bookTitle;
  final Duration duration;

  @override
  State<_EndSessionDialog> createState() => _EndSessionDialogState();
}

class _EndSessionDialogState extends State<_EndSessionDialog> {
  late TextEditingController _pageController;
  late TextEditingController _notesController;

  bool _finishBook = false;

  @override
  void initState() {
    super.initState();
    _pageController = TextEditingController(
        text: widget.initialPage > 0 ? widget.initialPage.toString() : '');
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.auto_awesome, color: Colors.amber),
          SizedBox(width: 8),
          Text('Sesión completada'),
        ],
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${widget.duration.inMinutes} minutos dedicados a "${widget.bookTitle}"',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _pageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: '¿En qué página te has quedado?',
                  hintText: 'Ej: 145',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: '¿Algo que quieras recordar?',
                  hintText:
                      'Ej: "El capítulo con Maga me hizo llorar. Increíble."',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignLabelWithHint: true,
                ),
                maxLength: 280,
                maxLines: 4,
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Marcar libro como terminado'),
                value: _finishBook,
                onChanged: (val) {
                  setState(() {
                    _finishBook = val ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ],
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  final page = int.tryParse(_pageController.text) ?? 0;
                  // NO GUARDAR -> Returns false for viewBook, and imply cancel/delete
                  Navigator.pop(
                    context,
                    _EndSessionResult(
                      page,
                      _notesController.text,
                      false,
                      finishBook: _finishBook,
                      cancelSession: true, // New flag to signal cancellation
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                  side: BorderSide(color: Theme.of(context).colorScheme.error),
                ),
                child: const Text('NO GUARDAR'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton(
                onPressed: () {
                  final page = int.tryParse(_pageController.text) ?? 0;
                  Navigator.pop(
                    context,
                    _EndSessionResult(
                      page,
                      _notesController.text,
                      true, // Default to viewing book or just saving
                      finishBook: _finishBook,
                    ),
                  );
                },
                child: const Text(
                  'GUARDAR',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
