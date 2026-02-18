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
    this.initialZenMode =
        false, // ← Este parámetro controla si viene en modo zen desde antes
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

  bool _isNightMode = false; // Modo visual (colores oscuros)
  bool _isZenMode = false; // Modo descanso (DND + brillo bajo)
  int _lastKnownPage = 0;

  @override
  void initState() {
    super.initState();

    // CAMBIO 3: Modo zen solo se activa si se pasó el parámetro initialZenMode
    _isZenMode = widget.initialZenMode;
    _isNightMode = widget
        .initialZenMode; // Si viene en zen, también activa modo noche visual

    WakelockPlus.enable();

    // Solo aplicar configuración de zen (DND + brillo) si se pasó como parámetro inicial
    if (_isZenMode) {
      _initZenMode();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref
          .read(readingSessionControllerProvider.notifier)
          .initializeSession(widget.book.id, widget.book.uuid);

      if (mounted) {
        final initialSession = ref.read(readingSessionControllerProvider).value;
        if (initialSession != null) {
          _startTimer(initialSession.startTime);
        }
      }
    });
  }

  /// Inicializa modo zen (solo si se activó antes de entrar)
  Future<void> _initZenMode() async {
    try {
      // Activar DND si es Android
      if (Platform.isAndroid) {
        final status = await Permission.accessNotificationPolicy.status;
        if (!status.isGranted) {
          await Permission.accessNotificationPolicy.request();
        }
      }

      // Bajar brillo
      await ScreenBrightness().setScreenBrightness(0.05);
    } catch (e) {
      debugPrint('Error inicializando zen mode: $e');
    }
  }

  /// CAMBIO 2: Modo noche ahora solo cambia los colores (sin DND ni brillo)
  /// El modo zen (DND + brillo) solo se activa si se pasó initialZenMode = true
  Future<void> _toggleNightMode() async {
    setState(() {
      _isNightMode = !_isNightMode;
    });

    // No cambiamos el brillo ni activamos DND
    // Solo es un toggle visual de colores
  }

  void _startTimer(DateTime startTime) {
    _startTime = startTime;

    if (_timer != null && _timer!.isActive) {
      setState(() {
        _elapsed = DateTime.now().difference(_startTime!);
      });
      return;
    }

    _elapsed = DateTime.now().difference(_startTime!);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _elapsed = DateTime.now().difference(_startTime!);
      });

      if (widget.targetDuration != null && _elapsed >= widget.targetDuration!) {
        timer.cancel();
        _showTimeIsUpDialog();
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
            onPressed: () => Navigator.pop(context),
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

    // Restaurar brillo solo si estaba en modo zen
    if (_isZenMode) {
      ScreenBrightness().resetScreenBrightness();
    }

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
        await controller.cancelSession();
      } else if (result.finishBook) {
        await controller.finishBook(
          result.page,
          notes: result.notes,
        );

        if (mounted) {
          await showAddReviewDialog(context, ref, widget.book);
        }
      } else {
        await controller.endSession(result.page, notes: result.notes);
      }

      if (mounted) {
        Navigator.pop(context);

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

  /// CAMBIO 1: Al presionar la X, cancelar sesión y parar el timer
  Future<void> _closeSessionWithoutSaving() async {
    // Mostrar confirmación
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Cerrar sin guardar?'),
        content: const Text(
          'Se perderá el progreso de esta sesión de lectura.\n'
          '¿Estás seguro?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Cerrar sin guardar'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // Cancelar la sesión en el controller (la elimina de DB)
      await ref.read(readingSessionControllerProvider.notifier).cancelSession();

      // Parar el timer
      _timer?.cancel();

      // Resetear el elapsed a cero (opcional, porque vamos a cerrar la pantalla)
      setState(() {
        _elapsed = Duration.zero;
      });

      // Cerrar la pantalla
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(readingSessionControllerProvider);

    ref.listen(readingSessionControllerProvider, (previous, next) {
      final previousSession = previous?.value;
      final nextSession = next.value;

      if (nextSession != null && nextSession.id != previousSession?.id) {
        _startTimer(nextSession.startTime);
      }

      if (nextSession == null && previousSession != null) {
        _timer?.cancel();
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
      colorFilter: _isNightMode
          ? const ColorFilter.mode(Colors.grey, BlendMode.saturation)
          : const ColorFilter.mode(Colors.transparent, BlendMode.saturation),
      child: Scaffold(
        backgroundColor: _isNightMode ? Colors.black : null,
        appBar: AppBar(
          title: Text(widget.book.title),
          backgroundColor: _isNightMode ? Colors.black : null,
          foregroundColor: _isNightMode ? Colors.white54 : null,
          actions: [
            // CAMBIO 2: Botón solo cambia modo visual noche/día
            IconButton(
              icon:
                  Icon(_isNightMode ? Icons.nightlight_round : Icons.wb_sunny),
              onPressed: _toggleNightMode,
              tooltip: _isNightMode ? 'Modo Día' : 'Modo Noche',
            ),
          ],
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed:
                _closeSessionWithoutSaving, // ← CAMBIO 1: Usar nuevo método
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
              return const Center(child: CircularProgressIndicator());
            }

            if (session.startPage != null && session.startPage! > 0) {
              _lastKnownPage = session.startPage!;
            }

            return SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Spacer(),
                    // Portada del libro
                    Opacity(
                      opacity: _isNightMode ? 0.6 : 1.0,
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

                    // Temporizador circular
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
                              _isNightMode
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
                                color: _isNightMode ? Colors.grey : null,
                              ),
                            ),
                            if (widget.targetDuration != null)
                              Text(
                                'restante',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium
                                    ?.copyWith(
                                      color: _isNightMode ? Colors.grey : null,
                                    ),
                              ),
                          ],
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Botón terminar
                    TextButton.icon(
                      onPressed: () => _endSession(),
                      icon: Icon(
                        Icons.stop,
                        color: _isNightMode
                            ? Colors.grey
                            : Theme.of(context).colorScheme.error,
                      ),
                      label: Text(
                        'TERMINAR SESIÓN',
                        style: TextStyle(
                          color: _isNightMode
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

// ---------------------------------------------------------------------------
// Clases auxiliares del diálogo (sin cambios)
// ---------------------------------------------------------------------------

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
                  Navigator.pop(
                    context,
                    _EndSessionResult(
                      page,
                      _notesController.text,
                      false,
                      finishBook: _finishBook,
                      cancelSession: true,
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
                      true,
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
