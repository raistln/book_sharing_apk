import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ui/widgets/coach_mark_overlay.dart';
import 'coach_mark_models.dart';
import 'coach_marks_service.dart';

final coachMarksServiceProvider = Provider<CoachMarksService>((ref) {
  return CoachMarksService();
});

final coachMarkControllerProvider =
    StateNotifierProvider<CoachMarkController, CoachMarkState>((ref) {
  final service = ref.watch(coachMarksServiceProvider);
  return CoachMarkController(service);
});

typedef CoachMarkRegistrationHandle = void Function();

typedef CoachMarkObserver = void Function(CoachMarkState state);

class CoachMarkController extends StateNotifier<CoachMarkState> {
  CoachMarkController(this._service) : super(const CoachMarkState());

  final CoachMarksService _service;

  final Map<CoachMarkId, CoachMarkTargetRegistration> _targets = {};
  final List<CoachMarkObserver> _observers = [];
  OverlayState? _overlayState;
  OverlayEntry? _overlayEntry;

  CoachMarkRegistrationHandle registerTarget(CoachMarkTargetRegistration registration) {
    _targets[registration.config.id] = registration;
    scheduleMicrotask(_showNext);
    return () => _targets.remove(registration.config.id);
  }

  void addObserver(CoachMarkObserver observer) {
    _observers.add(observer);
  }

  void removeObserver(CoachMarkObserver observer) {
    _observers.remove(observer);
  }

  void attachOverlay(OverlayState overlayState) {
    if (_overlayState == overlayState) {
      return;
    }

    _overlayState = overlayState;

    if (state.active != null) {
      _showOverlay(state.active!);
    } else {
      scheduleMicrotask(_showNext);
    }
  }

  void detachOverlay(OverlayState overlayState) {
    if (_overlayState != overlayState) {
      return;
    }

    _hideOverlay();
    _overlayState = null;
  }

  Future<void> beginSequence(CoachMarkSequence sequence) async {
    if (state.isProcessing) return;
    state = state.copyWith(isProcessing: true);
    final pending = await _service.pendingMarksForSequence(sequence);
    if (pending.isEmpty) {
      state = state.copyWith(isProcessing: false);
      return;
    }

    state = state.copyWith(
      queue: List<CoachMarkId>.from(pending),
      sequence: sequence,
      isProcessing: false,
    );

    await _showNext();
  }

  Future<void> queueMarks(List<CoachMarkId> marks, {CoachMarkSequence? sequence}) async {
    final queue = List<CoachMarkId>.from(state.queue)..addAll(marks);
    state = state.copyWith(queue: queue, sequence: sequence ?? state.sequence);
    if (!state.isVisible) {
      await _showNext();
    }
  }

  Future<void> dismissCurrent({bool markAsSeen = false}) async {
    if (state.active == null) return;
    final activeId = state.active!.id;
    _hideOverlay();
    state = state.copyWith(
      activeSetter: () => null,
      isVisible: false,
    );

    if (markAsSeen) {
      await _service.markSeen(activeId);
    }

    await _showNext();
  }

  Future<void> completeSequence() async {
    final sequence = state.sequence;
    if (sequence != null) {
      await _service.markSequenceCompleted(sequence);
    }
    _hideOverlay();
    state = state.copyWith(
      activeSetter: () => null,
      queue: const [],
      isVisible: false,
      sequenceSetter: () => null,
    );
    _notifyObservers();
  }

  Future<void> _showNext() async {
    if (state.isVisible || state.isProcessing) {
      return;
    }

    if (state.queue.isEmpty) {
      await _handleQueueDrained();
      return;
    }

    final nextId = state.queue.first;
    final registration = _targets[nextId];
    if (registration == null) {
      final updatedQueue = List<CoachMarkId>.from(state.queue)..removeAt(0);
      state = state.copyWith(queue: updatedQueue);
      await _service.markSeen(nextId);
      await _showNext();
      return;
    }

    if (!registration.enabled) {
      final updatedQueue = List<CoachMarkId>.from(state.queue)..removeAt(0);
      state = state.copyWith(queue: updatedQueue);
      await _service.markSeen(nextId);
      await _showNext();
      return;
    }

    final rect = registration.resolver();
    if (rect == null || rect.isEmpty) {
      // Retry later when layout is ready.
      scheduleMicrotask(() => _showNext());
      return;
    }

    final display = CoachMarkDisplay(
      id: nextId,
      config: registration.config,
      targetRect: _expandRect(rect, registration.config.highlightPadding),
    );

    final updatedQueue = List<CoachMarkId>.from(state.queue)..removeAt(0);
    state = state.copyWith(
      active: display,
      queue: updatedQueue,
      isVisible: true,
    );

    _showOverlay(display);
    _notifyObservers();
  }

  void _showOverlay(CoachMarkDisplay display) {
    final overlayState = _overlayState;
    if (overlayState == null) {
      state = state.copyWith(
        activeSetter: () => null,
        queue: [display.id, ...state.queue],
        isVisible: false,
      );
      return;
    }

    _overlayEntry?.remove();
    _overlayEntry = OverlayEntry(
      builder: (context) => CoachMarkOverlay(
        display: display,
        onPrimary: () => unawaited(dismissCurrent(markAsSeen: true)),
        onSecondary: display.config.secondaryActionLabel != null
            ? () => unawaited(dismissCurrent(markAsSeen: true))
            : null,
        onSkip: () => unawaited(completeSequence()),
        onBarrierTap: display.config.barrierDismissible
            ? () => unawaited(dismissCurrent(markAsSeen: true))
            : null,
      ),
    );

    overlayState.insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _notifyObservers() {
    for (final observer in _observers) {
      observer(state);
    }
  }

  Future<void> _handleQueueDrained() async {
    if (state.sequence != null) {
      await _service.markSequenceCompleted(state.sequence!);
    }
    _hideOverlay();
    state = state.copyWith(
      activeSetter: () => null,
      queue: const [],
      isVisible: false,
      sequenceSetter: () => null,
    );
    _notifyObservers();
  }

  Rect _expandRect(Rect rect, EdgeInsets padding) {
    return Rect.fromLTRB(
      rect.left - padding.left,
      rect.top - padding.top,
      rect.right + padding.right,
      rect.bottom + padding.bottom,
    );
  }

  @override
  void dispose() {
    _hideOverlay();
    _observers.clear();
    _targets.clear();
    super.dispose();
  }
}
