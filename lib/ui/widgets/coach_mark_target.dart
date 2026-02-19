import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/coach_marks/coach_mark_controller.dart';
import '../../services/coach_marks/coach_mark_models.dart';

class CoachMarkTarget extends ConsumerStatefulWidget {
  const CoachMarkTarget({
    super.key,
    required this.id,
    required this.child,
    this.config,
    this.enabled = true,
  });

  final CoachMarkId id;
  final Widget child;
  final CoachMarkConfig? config;
  final bool enabled;

  @override
  ConsumerState<CoachMarkTarget> createState() => _CoachMarkTargetState();
}

class _CoachMarkTargetState extends ConsumerState<CoachMarkTarget> {
  final GlobalKey _targetKey = GlobalKey();
  CoachMarkRegistrationHandle? _registrationHandle;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _registerTarget());
  }

  @override
  void didUpdateWidget(CoachMarkTarget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.id != oldWidget.id ||
        widget.config != oldWidget.config ||
        widget.enabled != oldWidget.enabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _registerTarget());
    }
  }

  @override
  void dispose() {
    _registrationHandle?.call();
    _registrationHandle = null;
    super.dispose();
  }

  void _registerTarget() {
    _registrationHandle?.call();

    final context = _targetKey.currentContext;
    if (context == null) {
      return;
    }

    final controller = ref.read(coachMarkControllerProvider.notifier);
    final config = widget.config ?? defaultCoachMarkConfigs[widget.id];
    if (config == null) {
      return;
    }

    _registrationHandle = controller.registerTarget(
      CoachMarkTargetRegistration(
        config: config,
        resolver: _resolveRect,
        isEnabled: () => widget.enabled,
      ),
    );
  }

  Rect? _resolveRect() {
    final context = _targetKey.currentContext;
    if (context == null) {
      return null;
    }
    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) {
      return null;
    }
    final size = renderObject.size;
    final offset = renderObject.localToGlobal(Offset.zero);
    return offset & size;
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: _targetKey,
      child: widget.child,
    );
  }
}
