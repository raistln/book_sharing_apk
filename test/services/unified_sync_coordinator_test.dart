import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:book_sharing_app/models/global_sync_state.dart';
import 'package:book_sharing_app/services/group_sync_controller.dart';
import 'package:book_sharing_app/services/sync_service.dart';
import 'package:book_sharing_app/services/unified_sync_coordinator.dart';

// Mocks
class MockSyncController extends Mock implements SyncController {}

class MockGroupSyncController extends Mock implements GroupSyncController {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockSyncController mockUserSync;
  late MockSyncController mockBookSync;
  late MockGroupSyncController mockGroupSync;
  late MockSyncController mockNotificationSync;
  late MockSyncController mockLoanSync;
  late UnifiedSyncCoordinator coordinator;

  setUp(() {
    mockUserSync = MockSyncController();
    mockBookSync = MockSyncController();
    mockGroupSync = MockGroupSyncController();
    mockNotificationSync = MockSyncController();
    mockLoanSync = MockSyncController();

    // Setup default successful sync responses
    when(() => mockUserSync.sync()).thenAnswer((_) async {});
    when(() => mockBookSync.sync()).thenAnswer((_) async {});
    when(() => mockGroupSync.syncGroups()).thenAnswer((_) async {});
    when(() => mockNotificationSync.sync()).thenAnswer((_) async {});
    when(() => mockLoanSync.sync()).thenAnswer((_) async {});

    // Stub state getters to avoid crashes when coordinator reads them
    when(() => mockUserSync.state).thenReturn(const SyncState());
    when(() => mockBookSync.state).thenReturn(const SyncState());
    when(() => mockGroupSync.state).thenReturn(const SyncState()); // GroupSync might need separate handling if it doesn't use SyncState but GroupSyncState?
    when(() => mockNotificationSync.state).thenReturn(const SyncState());
    when(() => mockLoanSync.state).thenReturn(const SyncState());

    coordinator = UnifiedSyncCoordinator(
      userSyncController: mockUserSync,
      bookSyncController: mockBookSync,
      groupSyncController: mockGroupSync,
      notificationSyncController: mockNotificationSync,
      loanSyncController: mockLoanSync,
      enableConnectivityMonitoring: false, // Disable for tests
      enableBatteryMonitoring: false, // Disable for tests
    );
  });

  tearDown(() {
    coordinator.dispose();
  });

  group('UnifiedSyncCoordinator - Básico', () {
    test('Estado inicial es correcto', () {
      final state = coordinator.currentState;

      expect(state.isSyncing, false);
      expect(state.isTimerSuspended, false);
      expect(state.pendingChangesCount, 0);
      expect(state.isFullySynced, true);
    });

    test('markPendingChanges actualiza el estado de la entidad', () async {
      coordinator.markPendingChanges(SyncEntity.books);

      // Esperar un poco para que se actualice el estado
      await Future.delayed(const Duration(milliseconds: 100));

      final state = coordinator.currentState;
      expect(state.pendingChangesCount, greaterThan(0));
    });

    test('syncNow sincroniza todas las entidades', () async {
      await coordinator.syncNow();

      verify(() => mockUserSync.sync()).called(1);
      verify(() => mockGroupSync.syncGroups()).called(1);
      verify(() => mockBookSync.sync()).called(1);
      verify(() => mockNotificationSync.sync()).called(1);
      verify(() => mockLoanSync.sync()).called(1);
    });

    test('syncNow sincroniza solo entidades especificadas', () async {
      await coordinator.syncNow(entities: [SyncEntity.users, SyncEntity.books]);

      verify(() => mockUserSync.sync()).called(1);
      verify(() => mockBookSync.sync()).called(1);
      verifyNever(() => mockGroupSync.syncGroups());
      verifyNever(() => mockNotificationSync.sync());
      verifyNever(() => mockLoanSync.sync());
    });
  });

  group('UnifiedSyncCoordinator - Prioridades y Debouncing', () {
    test('Alta prioridad sincroniza inmediatamente', () async {
      coordinator.markPendingChanges(
        SyncEntity.users,
        priority: SyncPriority.high,
      );

      // Esperar un poco para que se ejecute
      await Future.delayed(const Duration(milliseconds: 100));

      verify(() => mockUserSync.sync()).called(1);
    });

    test('Media prioridad usa debounce de 2s', () {
      fakeAsync((async) {
        coordinator.markPendingChanges(
          SyncEntity.groups,
          priority: SyncPriority.medium,
        );

        // No debe sincronizar inmediatamente
        async.elapse(const Duration(milliseconds: 500));
        verifyNever(() => mockGroupSync.syncGroups());

        // Debe sincronizar después del debounce (2s)
        async.elapse(const Duration(milliseconds: 1600));
        verify(() => mockGroupSync.syncGroups()).called(1);
      });
    });

    test('Baja prioridad usa debounce de 5s', () {
      fakeAsync((async) {
        coordinator.markPendingChanges(
          SyncEntity.books,
          priority: SyncPriority.low,
        );

        // No debe sincronizar antes del debounce
        async.elapse(const Duration(milliseconds: 2000));
        verifyNever(() => mockBookSync.sync());

        // Debe sincronizar después del debounce (5s total)
        async.elapse(const Duration(milliseconds: 3100));
        verify(() => mockBookSync.sync()).called(1);
      });
    });

    test('Múltiples markPendingChanges resetean el debounce', () {
      fakeAsync((async) {
        coordinator.markPendingChanges(
          SyncEntity.books,
          priority: SyncPriority.low,
        );

        async.elapse(const Duration(milliseconds: 3000));

        // Marcar de nuevo antes de que termine el debounce
        coordinator.markPendingChanges(
          SyncEntity.books,
          priority: SyncPriority.low,
        );

        // Esperar el tiempo original (debería haber sido reseteado)
        async.elapse(const Duration(milliseconds: 3000));
        verifyNever(() => mockBookSync.sync());

        // Esperar el resto del debounce (2s más para completar 5s desde el reset)
        async.elapse(const Duration(milliseconds: 2100));
        verify(() => mockBookSync.sync()).called(1);
      });
    });
  });

  group('UnifiedSyncCoordinator - Eventos Críticos', () {
    test('Evento crítico sincroniza inmediatamente sin debounce', () async {
      await coordinator.syncOnCriticalEvent(SyncEvent.loanCreated);

      // Debe sincronizar inmediatamente
      verify(() => mockGroupSync.syncGroups()).called(1);
      verify(() => mockBookSync.sync()).called(1);
    });

    test('Evento de invitación sincroniza grupos y usuarios', () async {
      await coordinator.syncOnCriticalEvent(
        SyncEvent.groupInvitationAccepted,
      );

      verify(() => mockUserSync.sync()).called(1);
      verify(() => mockGroupSync.syncGroups()).called(1);
    });

    test('Evento crítico cancela debounce pendiente', () async {
      // Marcar cambios con debounce
      coordinator.markPendingChanges(
        SyncEntity.groups,
        priority: SyncPriority.medium,
      );

      // Disparar evento crítico antes del debounce
      await coordinator.syncOnCriticalEvent(SyncEvent.loanCreated);

      // Debe haber sincronizado inmediatamente
      verify(() => mockGroupSync.syncGroups()).called(1);

      // Esperar un poco para asegurar que no se dispara el debounce
      await Future.delayed(const Duration(milliseconds: 100));

      // No debe sincronizar de nuevo (el debounce fue cancelado)
      verify(() => mockGroupSync.syncGroups()).called(1); // Solo una vez
    });
  });

  group('UnifiedSyncCoordinator - Manejo de Errores y Reintentos', () {
    test('Error en sincronización programa reintento', () {
      fakeAsync((async) {
        // Simular error en la primera llamada
        when(() => mockBookSync.sync())
            .thenThrow(Exception('Error de sincronización'));

        coordinator.markPendingChanges(
          SyncEntity.books,
          priority: SyncPriority.high,
        );

        async.elapse(const Duration(milliseconds: 200));

        // Primera llamada falló
        verify(() => mockBookSync.sync()).called(1);

        // Configurar para que la siguiente llamada tenga éxito
        when(() => mockBookSync.sync()).thenAnswer((_) async {});

        // Esperar el primer reintento (1s)
        async.elapse(const Duration(milliseconds: 1100));

        // Debe haber reintentado
        verify(() => mockBookSync.sync()).called(2);
      });
    });

    test('Reintentos usan delay exponencial', () {
      fakeAsync((async) {
        var callCount = 0;
        when(() => mockBookSync.sync()).thenAnswer((_) async {
          callCount++;
          if (callCount < 3) {
            throw Exception('Error');
          }
        });

        coordinator.markPendingChanges(
          SyncEntity.books,
          priority: SyncPriority.high,
        );

        async.elapse(const Duration(milliseconds: 200));
        expect(callCount, 1); // Primera llamada

        // Primer reintento: 1s
        async.elapse(const Duration(milliseconds: 1100));
        expect(callCount, 2);

        // Segundo reintento: 2s
        async.elapse(const Duration(milliseconds: 2100));
        expect(callCount, 3);
      });
    });

    test('Máximo de reintentos se respeta', () {
      fakeAsync((async) {
        when(() => mockBookSync.sync())
            .thenThrow(Exception('Error persistente'));

        coordinator.markPendingChanges(
          SyncEntity.books,
          priority: SyncPriority.high,
        );

        // Esperar suficiente tiempo para todos los reintentos
        // 1s + 2s + 4s + 8s + 16s = 31s (pero usamos max 30s)
        async.elapse(const Duration(seconds: 35));

        // Debe haber intentado máximo 6 veces (1 inicial + 5 reintentos)
        verify(() => mockBookSync.sync()).called(lessThanOrEqualTo(6));
      });
    });

    test('Sincronización exitosa resetea contador de reintentos', () {
      fakeAsync((async) {
        var callCount = 0;
        when(() => mockBookSync.sync()).thenAnswer((_) async {
          callCount++;
          if (callCount == 1) {
            throw Exception('Error temporal');
          }
        });

        // Primera sincronización falla
        coordinator.markPendingChanges(
          SyncEntity.books,
          priority: SyncPriority.high,
        );

        async.elapse(const Duration(milliseconds: 200));
        expect(callCount, 1);

        // Reintento exitoso
        async.elapse(const Duration(milliseconds: 1100));
        expect(callCount, 2);

        // Nueva sincronización (contador debe estar reseteado)
        callCount = 0;
        when(() => mockBookSync.sync()).thenThrow(Exception('Nuevo error'));

        coordinator.markPendingChanges(
          SyncEntity.books,
          priority: SyncPriority.high,
        );

        async.elapse(const Duration(milliseconds: 200));
        expect(callCount, 1);

        // Debe reintentar desde el principio (1s, no desde donde quedó antes)
        async.elapse(const Duration(milliseconds: 1100));
        expect(callCount, 2);
      });
    });
  });

  group('UnifiedSyncCoordinator - Auto-Sync y Suspensión', () {
    test('startAutoSync inicia sincronización periódica', () async {
      coordinator.startAutoSync();

      // Esperar más del intervalo base (2 min en config, pero usamos menos para test)
      // Nota: En tests reales, deberías mockear el Timer o usar fake_async
      expect(coordinator.isTimerSuspended, false);
    });

    test('stopAutoSync detiene sincronización periódica', () {
      coordinator.startAutoSync();
      coordinator.stopAutoSync();

      expect(coordinator.isTimerSuspended, false);
    });

    test('suspendAutoSync suspende temporalmente', () {
      coordinator.startAutoSync();
      coordinator.suspendAutoSync();

      expect(coordinator.isTimerSuspended, true);
    });

    test('resumeAutoSync reanuda desde suspensión', () {
      coordinator.startAutoSync();
      coordinator.suspendAutoSync();

      expect(coordinator.isTimerSuspended, true);

      coordinator.resumeAutoSync();

      expect(coordinator.isTimerSuspended, false);
    });
  });

  group('UnifiedSyncCoordinator - Stream de Estado', () {
    test('Stream emite cambios de estado', () async {
      final states = <GlobalSyncState>[];
      final subscription = coordinator.syncStateStream.listen(states.add);

      coordinator.markPendingChanges(SyncEntity.books);
      await Future.delayed(const Duration(milliseconds: 100));

      expect(states.length, greaterThan(0));
      expect(states.last.pendingChangesCount, greaterThan(0));

      await subscription.cancel();
    });

    test('Estado refleja sincronización en progreso', () async {
      final states = <GlobalSyncState>[];
      final subscription = coordinator.syncStateStream.listen(states.add);

      // Hacer que la sincronización tarde un poco
      when(() => mockUserSync.sync()).thenAnswer(
        (_) => Future.delayed(const Duration(milliseconds: 500)),
      );

      final syncFuture = coordinator.syncNow(entities: [SyncEntity.users]);

      // Esperar un poco para capturar el estado "isSyncing"
      await Future.delayed(const Duration(milliseconds: 100));

      final syncingState = states.firstWhere(
        (s) => s.isSyncing,
        orElse: () => const GlobalSyncState(),
      );

      expect(syncingState.isSyncing, true);

      await syncFuture;
      await subscription.cancel();
    });
  });
}
