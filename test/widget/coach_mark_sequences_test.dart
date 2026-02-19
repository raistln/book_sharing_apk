import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:book_sharing_app/services/coach_marks/coach_mark_controller.dart';
import 'package:book_sharing_app/services/coach_marks/coach_mark_models.dart';
import 'package:book_sharing_app/services/coach_marks/coach_marks_service.dart';
import 'package:book_sharing_app/ui/widgets/coach_mark_host.dart';
import 'package:book_sharing_app/ui/widgets/coach_mark_overlay.dart';
import 'package:book_sharing_app/ui/widgets/coach_mark_target.dart';

class FakeCoachMarksService extends CoachMarksService {
  final Map<CoachMarkId, bool> _pending = {};
  final Map<CoachMarkId, bool> _seen = {};
  final Set<CoachMarkSequence> completedSequences = {};

  void seedSequence(CoachMarkSequence sequence) {
    final marks = coachMarkSequences[sequence] ?? const [];
    for (final mark in marks) {
      _pending[mark] = true;
      _seen[mark] = false;
    }
    completedSequences.remove(sequence);
  }

  @override
  Future<List<CoachMarkId>> pendingMarksForSequence(
      CoachMarkSequence sequence) async {
    final marks = coachMarkSequences[sequence] ?? const [];
    return marks
        .where((mark) => _pending[mark] ?? false || !(_seen[mark] ?? false))
        .toList(growable: false);
  }

  @override
  Future<void> markSeen(CoachMarkId id) async {
    _pending[id] = false;
    _seen[id] = true;
  }

  @override
  Future<void> markSequenceCompleted(CoachMarkSequence sequence) async {
    final marks = coachMarkSequences[sequence] ?? const [];
    for (final mark in marks) {
      _pending[mark] = false;
      _seen[mark] = true;
    }
    completedSequences.add(sequence);
  }

  @override
  Future<void> setPending(CoachMarkId id, bool pending) async {
    _pending[id] = pending;
    if (!pending) {
      _seen[id] = true;
    } else {
      _seen[id] = false;
    }
  }

  @override
  Future<void> resetSequence(CoachMarkSequence sequence) async {
    seedSequence(sequence);
  }

  @override
  Future<void> clearAll() async {
    _pending.clear();
    _seen.clear();
    completedSequences.clear();
  }
}

Future<void> _pumpHarness(
  WidgetTester tester,
  ProviderContainer container,
  Widget child,
) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: CoachMarkOverlayHost(child: child),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('Coach mark sequences', () {
    late FakeCoachMarksService service;
    late ProviderContainer container;
    late CoachMarkController controller;

    setUp(() {
      service = FakeCoachMarksService();
      container = ProviderContainer(
        overrides: [
          coachMarksServiceProvider.overrideWithValue(service),
        ],
      );
      addTearDown(container.dispose);
      controller = container.read(coachMarkControllerProvider.notifier);
    });

    testWidgets('discover sequence displays both marks in order',
        (tester) async {
      service.seedSequence(CoachMarkSequence.discover);

      await _pumpHarness(
        tester,
        container,
        Column(
          children: [
            CoachMarkTarget(
              id: CoachMarkId.discoverFilterChips,
              child: Container(
                key: const ValueKey('filters'),
                width: 200,
                height: 40,
                color: Colors.blue,
              ),
            ),
            CoachMarkTarget(
              id: CoachMarkId.discoverShareBook,
              child: Container(
                key: const ValueKey('shareCard'),
                width: 200,
                height: 80,
                color: Colors.orange,
              ),
            ),
          ],
        ),
      );

      final displayed = <CoachMarkId>[];
      void observer(CoachMarkState state) {
        final active = state.active;
        if (active != null &&
            (displayed.isEmpty || displayed.last != active.id)) {
          displayed.add(active.id);
        }
      }

      controller.addObserver(observer);
      addTearDown(() => controller.removeObserver(observer));

      await controller.beginSequence(CoachMarkSequence.discover);
      await tester.pumpAndSettle();

      expect(find.text('Comparte tus libros'), findsOneWidget);
      expect(find.byType(CoachMarkOverlay), findsOneWidget);

      await controller.dismissCurrent(markAsSeen: true);
      await tester.pumpAndSettle();

      expect(find.text('Filtra resultados'), findsOneWidget);
      expect(find.byType(CoachMarkOverlay), findsOneWidget);

      await controller.dismissCurrent(markAsSeen: true);
      await tester.pumpAndSettle();

      expect(find.text('Filtra resultados'), findsNothing);
      expect(service.completedSequences, contains(CoachMarkSequence.discover));
      expect(
          displayed,
          equals(const [
            CoachMarkId.discoverShareBook,
            CoachMarkId.discoverFilterChips,
          ]));
    });

    testWidgets('detail sequence finishes after both marks', (tester) async {
      service.seedSequence(CoachMarkSequence.detail);

      await _pumpHarness(
        tester,
        container,
        Column(
          children: [
            CoachMarkTarget(
              id: CoachMarkId.bookDetailRequestLoan,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Solicitar'),
              ),
            ),
            const SizedBox(height: 12),
            CoachMarkTarget(
              id: CoachMarkId.groupManageInvitations,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Gestionar'),
              ),
            ),
          ],
        ),
      );

      final displayed = <CoachMarkId>[];
      void observer(CoachMarkState state) {
        final active = state.active;
        if (active != null &&
            (displayed.isEmpty || displayed.last != active.id)) {
          displayed.add(active.id);
        }
      }

      controller.addObserver(observer);
      addTearDown(() => controller.removeObserver(observer));

      await controller.beginSequence(CoachMarkSequence.detail);
      await tester.pumpAndSettle();

      expect(find.text('Solicita un préstamo'), findsOneWidget);
      expect(find.byType(CoachMarkOverlay), findsOneWidget);

      await controller.dismissCurrent(markAsSeen: true);
      await tester.pumpAndSettle();

      expect(find.text('Gestiona invitaciones'), findsOneWidget);
      expect(find.byType(CoachMarkOverlay), findsOneWidget);

      await controller.dismissCurrent(markAsSeen: true);
      await tester.pumpAndSettle();

      expect(find.text('Gestiona invitaciones'), findsNothing);
      expect(service.completedSequences, contains(CoachMarkSequence.detail));
      expect(
          displayed,
          equals(const [
            CoachMarkId.bookDetailRequestLoan,
            CoachMarkId.groupManageInvitations,
          ]));
    });
  });
}
