import 'package:flutter/material.dart';

class InfoPop {
  static void show(
    BuildContext context, {
    required String message,
    bool isError = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => _InfoPopWidget(
        message: message,
        isError: isError,
        onDismiss: () => entry.remove(),
        duration: duration,
      ),
    );

    overlay.insert(entry);
  }

  static void success(BuildContext context, String message) {
    show(context, message: message, isError: false);
  }

  static void error(BuildContext context, String message) {
    show(context, message: message, isError: true);
  }
}

class _InfoPopWidget extends StatefulWidget {
  const _InfoPopWidget({
    required this.message,
    required this.isError,
    required this.onDismiss,
    required this.duration,
  });

  final String message;
  final bool isError;
  final VoidCallback onDismiss;
  final Duration duration;

  @override
  State<_InfoPopWidget> createState() => _InfoPopWidgetState();
}

class _InfoPopWidgetState extends State<_InfoPopWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _controller.forward();

    Future.delayed(widget.duration, () {
      if (mounted) {
        _controller.reverse().then((_) => widget.onDismiss());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Add Material and Directionality just in case, as OverlayEntry can be outside of them
    // Although normally MaterialApp provides them, it's safer for top-level OverlayEntry.
    return Material(
      type: MaterialType.transparency,
      child: SafeArea(
        child: ConstrainedBox(
          constraints: const BoxConstraints.expand(),
          child: Stack(
            children: [
              Positioned(
                top: 20,
                left: 20,
                right: 20,
                child: SlideTransition(
                  position: _offsetAnimation,
                  child: FadeTransition(
                    opacity: _opacityAnimation,
                    child: Material(
                      elevation: 8,
                      borderRadius: BorderRadius.circular(16),
                      color: widget.isError
                          ? Theme.of(context).colorScheme.errorContainer
                          : Theme.of(context).colorScheme.primaryContainer,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: (widget.isError
                                    ? Theme.of(context).colorScheme.error
                                    : Theme.of(context).colorScheme.primary)
                                .withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              widget.isError
                                  ? Icons.error_outline
                                  : Icons.check_circle_outline,
                              color: widget.isError
                                  ? Theme.of(context)
                                      .colorScheme
                                      .onErrorContainer
                                  : Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                widget.message,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: widget.isError
                                          ? Theme.of(context)
                                              .colorScheme
                                              .onErrorContainer
                                          : Theme.of(context)
                                              .colorScheme
                                              .onPrimaryContainer,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
