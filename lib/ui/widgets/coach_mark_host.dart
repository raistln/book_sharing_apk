import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/coach_marks/coach_mark_controller.dart';

class CoachMarkOverlayHost extends ConsumerStatefulWidget {
  const CoachMarkOverlayHost({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<CoachMarkOverlayHost> createState() => _CoachMarkOverlayHostState();
}

class _CoachMarkOverlayHostState extends ConsumerState<CoachMarkOverlayHost> {
  OverlayState? _attachedOverlay;
  late final CoachMarkController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ref.read(coachMarkControllerProvider.notifier);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _attachOverlay();
  }

  @override
  void dispose() {
    _detachOverlay();
    super.dispose();
  }

  void _attachOverlay() {
    if (!mounted) {
      return;
    }

    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _attachOverlay());
      return;
    }
    if (overlay == _attachedOverlay) {
      return;
    }

    _detachOverlay();

    if (!mounted) {
      return;
    }

    _attachedOverlay = overlay;
    _controller.attachOverlay(overlay);
  }

  void _detachOverlay() {
    final overlay = _attachedOverlay;
    if (overlay == null) {
      return;
    }
    _attachedOverlay = null;

    if (!mounted) {
      return;
    }

    _controller.detachOverlay(overlay);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
