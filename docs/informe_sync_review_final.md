# Informe de Revisión — Sistema de Sincronización Flutter/Supabase
**Versión:** 4 (revisión completa de todos los archivos)
**Fecha:** 2026-02-24
**Archivos revisados:** `club_dao.dart`, `sync_cursor_dao.dart`, `supabase_book_sync_repository.dart`, `supabase_club_book_sync_repository.dart`, `supabase_club_sync_repository.dart`, `supabase_group_repository.dart`, `supabase_loan_sync_repository.dart`, `supabase_notification_sync_repository.dart`, `supabase_user_sync_repository.dart`, `global_sync_state.dart`, `supabase_book_service.dart`, `supabase_club_service.dart`, `supabase_group_service.dart`, `supabase_loan_service.dart`, `supabase_notification_service.dart`, `supabase_user_service.dart`, `supabase_config_service.dart`

---

## Resumen ejecutivo

El PR está en muy buen estado. El bug original (`isRead`) está confirmado resuelto y la arquitectura general es sólida. Quedan **3 problemas activos** que hay que corregir antes de considerar el sistema estable en producción. Uno nuevo encontrado en esta revisión (`supabase_user_sync_repository.dart`). Los `rethrow` de `group_repository` y `notification_sync` del informe anterior están **confirmados resueltos**.

---

## Estado de bugs anteriores — actualización

| Bug | Estado anterior | Estado actual |
|-----|----------------|---------------|
| #12 `markClubSynced` guarda remoteId | ⚠️ Pendiente verificar | ✅ Confirmado resuelto |
| `rethrow` en `group_repository` (shared books) | ❌ Pendiente | ✅ Confirmado resuelto — usa `continue` |
| `rethrow` en `notification_sync` | ❌ Pendiente | ✅ Confirmado resuelto — comentario `// No relanzar` |
| `getAllDirtyEntities` sin filtro en progress | ❌ Detectado en v3 | ✅ Confirmado resuelto — ahora filtra `isDirty` |

---

## Problemas pendientes (3 activos)

---

### 🔴 1. Sin guard de concurrencia `_isSyncing` — Bugs #7 y #15

**Archivo:** `lib/services/unified_sync_coordinator.dart` (no subido al repositorio)

**Problema:** Sin protección contra llamadas simultáneas a `syncNow`, dos eventos paralelos (reconexión de red + timer periódico, por ejemplo) ejecutan el sync en paralelo sobre los mismos DAOs. Esto puede producir escrituras duplicadas, cursores corruptos o estados inconsistentes en SQLite.

**Fix:**
```dart
bool _isSyncing = false;

Future<void> syncNow({List<SyncEntity>? entities}) async {
  if (_isSyncing) {
    developer.log(
      'syncNow ignorado: sincronización ya en curso.',
      name: 'UnifiedSyncCoordinator',
    );
    return;
  }

  _isSyncing = true;
  try {
    // ... lógica de sync existente ...
  } finally {
    _isSyncing = false; // Se libera siempre, incluso si hay excepción
  }
}
```

**Tiempo estimado:** 15 minutos.

---

### 🟠 2. `supabase_user_sync_repository.dart` — `rethrow` demasiado agresivo en el bucle

**Archivo:** `lib/data/repositories/supabase_user_sync_repository.dart` — `pushLocalChanges`, líneas del bloque `catch`

**Problema:** Cuando falla la sincronización de un usuario, el `catch` relanza como `SupabaseUserSyncException`, lo que rompe el bucle completo. Si hay 3 usuarios sucios y el primero falla, los otros 2 nunca se intentan.

```dart
// Código actual
} on SupabaseUserServiceException {
  rethrow; // ✅ Este está bien — errores de servicio críticos
} catch (error) {
  developer.log(...);
  throw SupabaseUserSyncException(error.toString()); // ❌ Rompe el bucle
}
```

El `on SupabaseUserServiceException { rethrow }` es **correcto e intencional** — propaga errores críticos del servicio (auth, permisos) que el coordinator debe manejar. El problema es el `catch (error)` genérico que convierte cualquier error en una excepción que también rompe el bucle.

**Fix:** Loggear y continuar en el `catch` genérico, manteniendo el `rethrow` del `SupabaseUserServiceException`:
```dart
} on SupabaseUserServiceException {
  rethrow; // ✅ Mantener: el coordinator necesita saber de estos
} catch (error) {
  developer.log(
    'Error sincronizando usuario ${user.username}: $error',
    name: 'SupabaseUserSyncRepository',
    level: 1000,
  );
  // ✅ No relanzar: continúa con el siguiente usuario sucio
}
```

**Tiempo estimado:** 5 minutos.

---

### 🟠 3. `supabase_club_book_sync_repository.dart` — `getAllDirtyEntities` se llama dos veces por ciclo

**Archivo:** `lib/data/repositories/supabase_club_book_sync_repository.dart` — `pushLocalChanges`

**Problema:** `pushLocalChanges` llama a `_clubDao.getAllDirtyEntities()` una vez al principio y almacena el resultado en `allDirty`. Luego usa esa misma variable para leer `books`, `proposals`, `progress`, `comments`, `reports` y `logs`. Esto es correcto.

Sin embargo, en `supabase_club_sync_repository.dart`, `pushLocalChanges` también llama a `_clubDao.getAllDirtyEntities()` para leer los `members`. Esto significa que en un ciclo de sync completo donde el coordinator llama a ambos repositorios, se ejecutan **dos queries completos** de `getAllDirtyEntities` (8 SELECT cada uno = 16 queries en total) cuando podrían ser 8.

Esto no es un bug funcional, pero sí un problema de rendimiento innecesario dado que `getAllDirtyEntities` es un método caro (8 SELECT secuenciales).

**Fix recomendado:** Extraer `getDirtyMembers()` como método propio en `ClubDao` para que `supabase_club_sync_repository` no tenga que llamar al batch completo solo para obtener members:

```dart
// En club_dao.dart, añadir:
Future<List<ClubMember>> getDirtyMembers() {
  return (select(clubMembers)
        ..where((t) => t.isDirty.equals(true)))
      .get();
}
```

Y en `supabase_club_sync_repository.dart`, cambiar:
```dart
// Antes:
final allDirty = await _clubDao.getAllDirtyEntities();
final dirtyMembers = allDirty['members'] as List<ClubMember>? ?? [];

// Después:
final dirtyMembers = await _clubDao.getDirtyMembers();
```

**Tiempo estimado:** 10 minutos.

---

## Resumen de pendientes

| # | Problema | Archivo | Urgencia | Tiempo |
|---|----------|---------|----------|--------|
| 1 | Guard `_isSyncing` en `syncNow` | `unified_sync_coordinator.dart` | 🔴 Alta | 15 min |
| 2 | `throw` en catch genérico de usuarios | `supabase_user_sync_repository.dart` | 🟠 Media | 5 min |
| 3 | `getAllDirtyEntities` llamado dos veces por ciclo | `supabase_club_sync_repository.dart` + `club_dao.dart` | 🟠 Baja | 10 min |

**Total estimado:** 30 minutos.

---

## Verificaciones positivas de esta revisión

Lo siguiente está correctamente implementado en los archivos revisados:

**`club_dao.dart`**
- `markClubSynced` usa `Value.absent()` cuando `remoteId` es null — correcto en Drift.
- `getAllDirtyEntities` filtra `isDirty.equals(true)` en todas las entidades, incluyendo `progress`.
- `getDirtyClubs` excluye correctamente clubs con `isDeleted` — los otros `getDirty*` no necesitan este filtro porque los repos los manejan por separado.

**`sync_cursor_dao.dart`**
- `updateCursor` usa `insertOnConflictUpdate` — correcto, siempre persiste el cursor más reciente.
- `resetAllCursors` pensado para logout — buena práctica.
- El comentario "SOLO si la nueva fecha es más reciente" en la firma de `updateCursor` está desactualizado: el código actual siempre sobreescribe (no compara). Esto es en realidad correcto porque quien llama ya pasa el `MAX(updatedAt)` calculado externamente. El comentario es el que está mal, no el código.

**`supabase_book_sync_repository.dart`**
- `Future.wait` con `catchError` individual en `syncFromRemote` — fetches paralelos con aislamiento de errores correcto.
- Cursores actualizados al final de la transacción con `_maxUpdatedAt` — correcto.
- `isRead`, `readingStatus`, `readAt`, `isBorrowedExternal`, `externalLenderName` presentes tanto en INSERT como en UPDATE — bug original #16 resuelto.
- `InsertMode.insertOrIgnore` en timeline — evita el ciclo dirty infinito (bug #2).
- `upsert: true` en wishlist — evita 409 (correcto).
- Resolución de conflictos por `updatedAt` en books, reviews, timeline, sessions, wishlist — implementada correctamente.

**`supabase_club_book_sync_repository.dart`**
- Todos los loops usan `continue` en el `catch` — no hay `rethrow`.
- `allDirty['progress']` ahora llega con filtro `isDirty` gracias al fix en `club_dao.dart`.
- `upsertReadingProgress` en el service — manejo con upsert, correcto.

**`supabase_club_sync_repository.dart`**
- `markClubSynced(club.uuid, syncedAt: syncTime, remoteId: ensuredRemoteId)` — pasa `remoteId` correctamente.
- `continue` en catch de clubs y members — bug #8 resuelto.
- Reconciliación de members orphans con guard `isDirty` — no borra cambios locales pendientes.

**`supabase_group_repository.dart`**
- `continue` en shared books (delete y create/update) — rethrow eliminado.
- `// Don't rethrow, continue with other loans` en loans — correcto.
- Guard de borrado masivo cuando `sharedRecords.isEmpty` — bug #9 resuelto.
- Validación `sharedBookId`, `bookUuid`, `borrowerUuid` antes de push de loans — bug #6 resuelto.

**`supabase_loan_sync_repository.dart`**
- `SyncCursorDao.getCursor('loans')` y `updateCursor('loans', maxUpdatedAt)` — cursor correcto (bug #1 resuelto).
- Guard `isDirty` antes de sobreescribir loan local — bug #5 resuelto.
- Resolución de conflictos por `updatedAt` en loans — bug #14 resuelto.

**`supabase_notification_sync_repository.dart`**
- `// ✅ No relanzar: continúa con la siguiente notificación` — rethrow eliminado correctamente.

**`supabase_user_sync_repository.dart`**
- `on SupabaseUserServiceException { rethrow }` — intencional y correcto.
- El único problema es el `throw` en el `catch` genérico (ver problema #2 arriba).

**`global_sync_state.dart`**
- `GlobalSyncState` con `isSyncing`, `entityStates`, `isConnected` — modelo bien diseñado.
- `copyWith` con `String? Function()? lastError` (nulleable) — patrón correcto para limpiar errores.
- `operator ==` y `hashCode` implementados manualmente — evita rebuilds innecesarios en Riverpod/BLoC.

**Servicios (`supabase_*_service.dart`)**
- `_buildHeaders` con lógica `serviceRole vs anonKey` consistente en todos los servicios.
- `preferRepresentation: true` en POST para recuperar el `id` generado por Supabase — correcto.
- `insertOnConflictUpdate` con `resolution=merge-duplicates` en upserts — correcto.
- `SupabaseLoanService` usa el cliente de Supabase Flutter (no HTTP manual) — coherente con que loans usa `SupabaseClient` directamente, el resto usa HTTP. No es inconsistencia, es una decisión de diseño válida.
