import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_providers.dart';
import '../../services/inactivity_service.dart';

class InactivityListener extends ConsumerStatefulWidget {
  const InactivityListener({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<InactivityListener> createState() => _InactivityListenerState();
}

class _InactivityListenerState extends ConsumerState<InactivityListener>
    with WidgetsBindingObserver {
  late final InactivityManager _manager;

  @override
  void initState() {
    super.initState();
    _manager = ref.read(inactivityManagerProvider);
    WidgetsBinding.instance.addObserver(this);
    _registerActivity();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        // No bloqueamos automáticamente al salir al segundo plano.
        // El PIN solo se pedirá en un inicio desde cero (Cold Start).
        break;
      case AppLifecycleState.resumed:
        _registerActivity();
        break;
    }
  }

  void _onPointerEvent(PointerEvent _) {
    _registerActivity();
  }

  void _registerActivity() {
    final authState = ref.read(authControllerProvider);
    if (authState.status == AuthStatus.unlocked) {
      _manager.registerActivity();
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        _registerActivity();
        return false;
      },
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: _onPointerEvent,
        onPointerMove: _onPointerEvent,
        onPointerSignal: (_) => _registerActivity(),
        child: widget.child,
      ),
    );
  }
}
