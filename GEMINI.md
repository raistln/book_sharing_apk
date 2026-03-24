# GEMINI.md — PassTheBook

> Contexto completo del proyecto para Gemini Code Assist.
> Léelo íntegramente antes de sugerir cualquier cambio de código, esquema o arquitectura.
> Basado en auditoría directa del código fuente. Última actualización: Marzo 2026.

---

## Qué es este proyecto

**PassTheBook** es una app móvil Flutter para gestionar bibliotecas personales, préstamos de libros entre personas y clubes de lectura. Proyecto personal con enfoque contemplativo, no competitivo. Filosofía: privacidad primero, funciona offline, la nube es opcional.

---

## Stack tecnológico

| Capa | Tecnología | Notas |
|---|---|---|
| UI | Flutter 3.4+ / Dart 3.4+ | Material Design 3 |
| Estado | Riverpod | Providers reactivos y type-safe |
| BD local | Drift (SQLite) | ORM reactivo, local-first |
| BD remota | Supabase (PostgreSQL) | Sync opcional, auth, RLS |
| APIs | Google Books API, Open Library | Metadatos bibliográficos |
| Escáner | mobile_scanner | ISBN por cámara |
| Notificaciones | flutter_local_notifications | Local y push |
| Background | workmanager | Sync, backups, limpieza |
| Auth biométrica | local_auth | PIN + biometría |
| QR | qr_flutter | Invitaciones a grupos |
| PDF | pdf (dart) | Exportación de reportes |
| Conectividad | connectivity_plus | Monitoreo de red en sync |
| Batería | battery_plus | Ajuste de intervalo de sync |

---

## Arquitectura — Local-first con sync bidireccional

### Principio fundamental

**La fuente de verdad es SQLite local.** Supabase es una capa de sincronización, no el origen de los datos. La app funciona completamente sin conexión.

### Campos de control de sincronización

Todas las tablas principales tienen estos tres campos:

```dart
BoolColumn get isDirty    // true = cambios pendientes de subir a Supabase
BoolColumn get isDeleted  // true = borrado lógico, pendiente de propagar
DateTimeColumn get syncedAt  // cuándo se sincronizó por última vez con éxito
```

El flujo siempre es: escribir en SQLite local primero (`isDirty = true`) → el `UnifiedSyncCoordinator` lo detecta y sube → al confirmar: `isDirty = false`, `syncedAt = now()`.

### Cursores de sincronización incremental — tabla `SyncCursors`

`SyncCursors` almacena el `MAX(updatedAt)` del servidor por entidad para sync incremental:

```dart
// PK: entity TEXT — valores: 'books', 'reviews', 'timeline', 'sessions', 'wishlist'
DateTimeColumn get lastRemoteUpdatedAt  // MAX(updatedAt) del servidor
DateTimeColumn get lastSyncedAt         // cuándo ocurrió el último sync local
```

Al hacer `fetchFromRemote`, se pasa `updatedAfter: cursor`. Al terminar, se actualiza el cursor con el `MAX(updatedAt)` de los registros recibidos **dentro de la misma transacción**. Ver `SupabaseBookSyncRepository._maxUpdatedAt()`.

**Crítico:** `syncedAt` en cada tabla es informativo del último sync local. **No usarlo como cursor de sync remoto.** Usar siempre `SyncCursors.lastRemoteUpdatedAt`.

### Puente entre local y remoto

Cada entidad tiene tres identificadores:

```dart
IntColumn get id        // PK local autoincremental — SOLO para FKs internas Drift
TextColumn get uuid     // UUID v4 — identificador global, usado en toda la lógica
TextColumn get remoteId // UUID de Supabase — se rellena tras el primer sync exitoso
```

**Regla crítica:** Nunca usar `id` (local) para referencias entre entidades en lógica de negocio. Siempre `uuid`. El `id` local solo existe para las foreign keys de Drift.

### Resolución de conflictos

```dart
// En SupabaseBookSyncRepository.syncFromRemote():
if (existing.isDirty) {
  if (remoteUpdatedAt.isAfter(localUpdatedAt)) {
    // Gana el remoto → sobrescribir local
  } else {
    // Gana el local → solo actualizar remoteId y syncedAt, hacer continue
  }
}
```

---

## Esquema de base de datos

### Versiones

- **SQLite/Drift:** versión **27** (`AppDatabase.schemaVersion = 27`)
- **Supabase:** versión **9** 

### Tablas locales (Drift) — `lib/data/local/database.dart`

```
LocalUsers              — Usuarios del dispositivo (pinHash, pinSalt, pinUpdatedAt incluidos)
Books                   — Biblioteca personal
BookReviews             — Reseñas (rating 1-4, constraint CHECK en DB)
ReadingTimelineEntries  — Eventos de lectura (bookUuid nullable en DB)
ReadingSessions         — Sesiones cronometradas
Groups                  — Grupos (allowedGenres TEXT nullable, primaryColor TEXT nullable)
GroupMembers            — Membresías
GroupInvitations        — Invitaciones (code UNIQUE, expiresAt, status)
SharedBooks             — Libros expuestos (groupId FK obligatorio en Drift)
Loans                   — Préstamos (sharedBookId nullable, bookId nullable para manuales)
InAppNotifications      — Notificaciones internas
WishlistItems           — Lista de deseos
ReadingClubs            — Clubes de lectura
ClubMembers             — Miembros de clubes
ClubBooks               — Libros de clubes (sectionMode, sections JSON, orderPosition)
ClubReadingProgress     — Progreso por sección/capítulo
BookProposals           — Propuestas con votos CSV
SectionComments         — Comentarios por sección
CommentReports          — Reportes de comentarios
ModerationLogs          — Acciones de moderación
SyncCursors             — Cursores incrementales (PK: entity TEXT)
```

**Nota importante sobre `SharedBooks` en Drift:** `groupId` es FK obligatoria (no nullable). Los libros de backup personal (digitales) en Supabase tienen `group_id = NULL`, pero en SQLite local `SharedBooks` siempre tiene un `groupId`. Esto significa que **las filas de backup personal solo existen en Supabase**, no en la tabla local `SharedBooks`.

### Tablas remotas (Supabase) — `docs/supabase_schema_v8_COMPLETE.sql`

```
profiles                — Espejo de LocalUsers
groups                  — Grupos (allowed_genres JSONB, primary_color TEXT)
group_members           — Membresías
group_invitations       — Invitaciones
shared_books            — group_id nullable (NULL = backup personal sin grupo)
loans                   — Préstamos
loan_notifications      — Notificaciones de préstamos
reading_timeline_entries
reading_sessions
wishlist_items
reading_clubs
club_members
club_books
club_reading_progress
section_comments
book_proposals
literary_bulletins      — Cache por (province, month, year) UNIQUE — solo lectura
system_logs
system_metrics
```

---

## Lógica de SharedBooks — la más crítica del proyecto

### Dos conceptos distintos que NO deben confundirse

**1. SharedBooks en grupos (préstamo):**
- Solo libros físicos, no privados, no prestados externamente
- Tienen `group_id` apuntando a un grupo real
- En Drift: fila en tabla `SharedBooks` local con `groupId` FK
- En Supabase: fila con `group_id NOT NULL` y `visibility = 'group'`

**2. SharedBooks como backup personal en Supabase:**
- Todos los libros del usuario, incluyendo digitales
- Solo existen en Supabase, **no en SQLite local**
- `group_id = NULL`, `visibility = 'private'`
- Son backup personal para sync entre dispositivos, no para préstamo

### `_shouldShare()` — qué va a grupos

```dart
// BookRepository._shouldShare()
bool _shouldShare(String status, bool isPhysical, bool isBorrowedExternal) {
  if (!isPhysical) return false;          // Los digitales nunca van a grupos
  if (isBorrowedExternal) return false;   // Los prestados de fuera tampoco
  return status == 'available' || status == 'loaned'; // Solo estos dos
}
```

### `_mapStatusToSharedBookValues()` — cómo se mapea el status

```dart
// BookRepository._mapStatusToSharedBookValues()
'private'   → visibility: 'private',  isAvailable: false
'archived'  → visibility: 'archived', isAvailable: false
'loaned'    → visibility: 'group',    isAvailable: false
'available' → visibility: 'group',    isAvailable: true  (default)
```

### Filtro de géneros temáticos (ya implementado ✅)

```dart
// En BookRepository._autoShareBook() — dentro del bucle por grupos:
final allowedGenres = BookGenre.allowedFromJson(group.allowedGenres);
if (allowedGenres.isNotEmpty) {
  final parsedGenre = BookGenre.fromString(bookGenre);
  if (parsedGenre == null || !allowedGenres.contains(parsedGenre)) {
    // Si ya estaba compartido → softDeleteSharedBook
    // Si no estaba → omitir inserción con continue
    continue;
  }
}
```

- `allowedGenres = null` → sin filtro (comportamiento por defecto)
- Libros con `genre = null` se excluyen si hay filtro activo
- El filtro aplica a **todos los miembros del grupo**, no solo al dueño
- Implementado en: `BookRepository._autoShareBook()` y `shareExistingBooksWithGroup()`

### Flujo completo de auto-share

1. `addBook()` o `updateBook()` llaman a `_autoShareBook()`
2. Se obtienen todos los grupos del usuario vía `_groupDao.getGroupsForUser(ownerUserId)`
3. Si `!_shouldShare()` → `_softDeleteSharedBooks()` para limpiar
4. Por cada grupo: verificar filtro de géneros → insertar o actualizar `SharedBooks`
5. Si `changed = true` → `_markGroupSyncPending()` para sync de grupos
6. Al unirse a un nuevo grupo: `shareExistingBooksWithGroup()` aplica el mismo filtro

### Push de libros personales a Supabase (backup)

En `SupabaseBookSyncRepository.pushLocalChanges()`:
- Si el libro está en algún `SharedBook` activo → es libro de grupo. Se elimina la fila personal de Supabase (si existía) y se pone `remoteId = null` localmente
- Si no está en ningún grupo → se sube como backup personal con `visibility = 'private'`, sin `group_id`

---

## Sincronización unificada — UnifiedSyncCoordinator

`lib/services/unified_sync_coordinator.dart` — orquestador central.

### Fases de sincronización (orden obligatorio)

```
Fase 1: Users       — base para todo lo demás
Fase 2: Groups + Clubs — base para SharedBooks y progreso
Fase 3: Books       — base para sesiones y timeline
Fase 4: Loans       — depende de Books y Users
Fase 5: Notifications — siempre al final
```

**No alterar este orden.** Respeta dependencias de foreign keys en Supabase.

### SyncEntity enum

```dart
enum SyncEntity { users, books, groups, loans, notifications, clubs, sessions, timeline }
// sessions y timeline delegan en _bookSyncController.sync()
```

### Métodos principales

```dart
void markPendingChanges(SyncEntity entity, {SyncPriority priority})
// → marca dirty en estado interno + propaga a controlador + debounce timer

Future<void> syncNow({List<SyncEntity>? entities})
// → guard _isSyncing para evitar concurrencia + respeta fases

Future<void> syncOnCriticalEvent(SyncEvent event)
// → cancela debounce timers + await completo + sin debounce
```

### SyncEvent enum

```dart
enum SyncEvent {
  groupInvitationAccepted,
  groupInvitationRejected,
  userJoinedGroup,
  userLeftGroup,
  loanCreated,
  loanReturned,
  loanCancelled,
  criticalNotification,
}
```

### Comportamiento inteligente

- Pausa sin conexión (`connectivity_plus`) — `SyncConfig.pauseOnNoConnection`
- Intervalo adaptativo: base → base+(max-base)/2 → max según tiempo desde última actividad
- Retry exponencial: 1s, 2s, 4s, 8s... máx 30s (`SyncConfig.maxRetryDelay`)
- Se suspende automáticamente si no hay cambios pendientes y hay inactividad > umbral
- Modo ahorro de batería duplica todos los intervalos

### Acceso desde providers

```dart
// En book_providers.dart:
final syncCoordinator = ref.watch(unifiedSyncCoordinatorProvider);
// Luego en el repositorio:
syncCoordinator.markPendingChanges(SyncEntity.books);
syncCoordinator.syncOnCriticalEvent(SyncEvent.loanCreated);
```

---

## Inyección de dependencias (Riverpod)

Todo el grafo de dependencias está en `lib/providers/book_providers.dart` y `lib/providers/sync_providers.dart`.

Patrón de acceso en providers:

```dart
// DAO → Repository → Controller → Provider
final appDatabaseProvider → bookDaoProvider → bookRepositoryProvider → bookListProvider
                          → groupDaoProvider ↗
                          → syncCursorDaoProvider → supabaseBookSyncRepositoryProvider
```

**Providers clave:**

```dart
appDatabaseProvider             // AppDatabase singleton
bookRepositoryProvider          // BookRepository (auto-share logic)
groupSyncControllerProvider     // GroupSyncController (StateNotifier)
unifiedSyncCoordinatorProvider  // UnifiedSyncCoordinator (en sync_providers.dart)
activeUserProvider              // Stream<LocalUser?> — fuente del usuario activo
bookListProvider                // Stream<List<Book>> filtrado por usuario activo
```

---

## Convenciones de código

### Migraciones de Drift

- Versión actual: **27** — Próxima migración: bloque `if (from < 28)`
- `try/catch` al añadir columnas (el usuario puede venir de cualquier versión previa)
- Para recrear tabla: DROP → CREATE → migrar datos (ver migración v13 para ejemplo)
- Borrado lógico: `isDeleted = true`. Nunca `DELETE` físico en operaciones de usuario

```dart
if (from < 28) {
  try {
    await m.addColumn(tableName, tableName.newColumn);
  } catch (_) {} // puede ya existir en dispositivos que hicieron createAll con nuevo schema
}
```

### Nombrado

- Tablas Drift: `PascalCase` en código Dart → `snake_case` en SQLite (auto-generado)
- Columnas Drift: `camelCase` → `snake_case` en SQLite
- Tablas Supabase: `snake_case`
- Grupos temáticos Drift: `allowedGenres TEXT nullable`, `primaryColor TEXT nullable`
- Grupos temáticos Supabase: `allowed_genres JSONB DEFAULT NULL`, `primary_color TEXT DEFAULT NULL`

### Estados y valores enumerados

**`readingStatus` en `Books`:**
`'pending'` | `'reading'` | `'paused'` | `'finished'` | `'abandoned'` | `'rereading'`

**`status` en `Books`:**
`'available'` | `'loaned'` | `'private'` | `'archived'`

**`status` en `Loans`:**
`'requested'` | `'active'` | `'returned'` | `'cancelled'` | `'rejected'` | `'completed'` | `'expired'`

**`visibility` en `SharedBooks`:**
`'private'` | `'group'` | `'public'` | `'archived'`

**`status` en `ClubBooks`:**
`'propuesto'` | `'votando'` | `'proximo'` | `'activo'` | `'completado'`

**`status` en `ClubReadingProgress`:**
`'no_empezado'` | `'al_dia'` | `'atrasado'` | `'terminado'`

**`status` en `BookProposals`:**
`'abierta'` | `'cerrada'` | `'ganadora'` | `'descartada'`

**`role` en `GroupMembers`:** `'owner'` | `'admin'` | `'member'`
**`role` en `ClubMembers`:** `'dueño'` | `'admin'` | `'miembro'`
**`status` en `ClubMembers`:** `'activo'` | `'inactivo'`

**`sectionMode` en `ClubBooks`:** `'automatico'` | `'manual'`

**Rating en `BookReviews`:** **1 a 4** (constraint `CHECK (rating BETWEEN 1 AND 4)` en DB). No cambiar.

**Votos en `BookProposals`:** CSV de UUIDs en campo TEXT. Ejemplo: `"uuid1,uuid2,uuid3"`. No es array ni JSON.

**`ModerationLogs.action`:** `'borrar_comentario'` | `'expulsar_miembro'` | `'cerrar_votacion'` | `'ocultar_comentario'`

### `SectionComments`

Tiene `authorRemoteId` además de `userRemoteId`. Son alias (el campo `authorRemoteId` es por consistencia con otros modelos). Ambos apuntan al mismo usuario.

---

## Reglas de negocio críticas

1. **Libros digitales y SharedBooks:** Los digitales (`isPhysical = false`) NUNCA van a grupos (`_shouldShare` devuelve false). Sí se suben a Supabase como backup personal con `group_id = NULL` y `visibility = 'private'`. No confundir.

2. **SharedBooks local vs remoto:** La tabla local `SharedBooks` tiene `groupId` FK no nullable → solo existen filas de grupo. Las filas de backup personal (digitales, `group_id = NULL`) solo viven en Supabase.

3. **Grupos temáticos (ya implementado ✅):** Columnas `allowedGenres` y `primaryColor` en `Groups` (Drift v26) y `allowed_genres`/`primary_color` en Supabase. Lógica en `BookRepository._autoShareBook()` y `shareExistingBooksWithGroup()`.

4. **Doble confirmación de devolución:** `borrowerReturnedAt` Y `lenderReturnedAt` deben estar rellenos para pasar a `'completed'`. Gestionado por el trigger `handle_loan_updates` en Supabase. No reimplementar en Flutter.

5. **`accept_loan` es atómico en Supabase:** La función SQL `accept_loan(p_loan_id, p_lender_user_id)` acepta uno y rechaza los demás préstamos solicitados para el mismo libro en una transacción. No replicar en Flutter.

6. **Préstamos manuales:** `Loans.sharedBookId` puede ser NULL si `bookId` está rellenado. `borrowerUserId` puede ser NULL con `externalBorrowerName`/`externalBorrowerContact` para personas sin la app. La FK check en Supabase verifica que una de las dos combinaciones sea válida.

7. **Boletín literario:** `literary_bulletins` tiene UNIQUE en `(province, month, year)`. Política RLS: solo SELECT para todos. No generar si ya existe para la misma clave.

8. **`SyncCursors`:** PK es `entity TEXT`, no hay `id` numérico. No tiene `isDirty`/`isDeleted`. Es solo estado de cursor, no datos de usuario.

9. **Libros de grupo en push:** Si un libro tiene `SharedBooks` activos, `pushLocalChanges` elimina la fila personal de Supabase y pone `remoteId = null` localmente. No intentar mantener ambas filas en paralelo.

---

## Seguridad y RLS en Supabase

- **Propios:** `owner_id = (select auth.uid())` o `user_id = (select auth.uid())`
- **Grupos:** `check_is_group_member(group_id, (select auth.uid()))` — función `SECURITY DEFINER`
- **Clubs:** `check_is_club_member(club_id, (select auth.uid()))` — función `SECURITY DEFINER`
- **Público:** Solo SELECT sin restricción (`profiles`, `literary_bulletins`)

Las funciones helper son `SECURITY DEFINER` para evitar recursión en las políticas RLS.

**Crítico:** Todas las políticas usan `(select auth.uid())` con paréntesis. Es intencional para optimizar el query planner de PostgreSQL. **No cambiar a `auth.uid()` sin paréntesis.**

### Cron jobs (pg_cron)

```
expire-overdue-loans  → 0 * * * *   → expire_overdue_loans()
send-loan-reminders   → 0 9 * * *   → send_loan_reminders()
cleanup-notifications → 0 0 * * *   → cleanup_old_notifications()
cleanup-deleted       → 0 1 * * *   → cleanup_deleted_records()
cleanup-system        → 0 2 * * *   → cleanup_system_data() — también limpia invitaciones expiradas
cleanup-bulletins     → 0 3 1 * *   → cleanup_expired_content() — boletines de hace >2 años
```

---

## Estructura de directorios

```
lib/
  data/
    local/
      database.dart                    — Esquema Drift completo (v27) y migraciones
      database.g.dart                  — Generado por build_runner — NO editar manualmente
      book_dao.dart
      group_dao.dart                   — DAO de Groups, GroupMembers, SharedBooks, Loans
      timeline_entry_dao.dart
      reading_session_dao.dart
      wishlist_dao.dart
      sync_cursor_dao.dart             — DAO de SyncCursors (getCursor / updateCursor)
      notification_dao.dart
      user_dao.dart
    repositories/
      book_repository.dart             — Lógica de Books + auto-share + filtro de géneros
      supabase_book_sync_repository.dart — Sync bidireccional: books, reviews, timeline, sessions, wishlist
      supabase_group_repository.dart   — Sync de Groups/Members/SharedBooks/Loans
      group_push_repository.dart       — Push de cambios de grupo a Supabase
      loan_repository.dart
      user_repository.dart
      wishlist_repository.dart
      notification_repository.dart
      supabase_user_sync_repository.dart
      supabase_notification_sync_repository.dart
  services/
    unified_sync_coordinator.dart      — Orquestador central de sync (leer ANTES de tocar sync)
    group_sync_controller.dart
    loan_controller.dart
    reading_timeline_service.dart
    supabase_book_service.dart
    supabase_group_service.dart
    supabase_notification_service.dart
    supabase_user_service.dart
    supabase_config_service.dart
    sync_service.dart                  — SyncController base (StateNotifier)
    book_export_service.dart
    loan_export_service.dart
    cover_image_service.dart
    onboarding_service.dart
    reading_rhythm_analyzer.dart
    discover_group_controller.dart
    group_push_controller.dart
  providers/
    book_providers.dart                — Grafo completo de DI con Riverpod
    sync_providers.dart                — UnifiedSyncCoordinator provider
    notification_providers.dart
  models/
    book_genre.dart                    — Enum BookGenre: fromString() / allowedFromJson()
    global_sync_state.dart             — GlobalSyncState, EntitySyncState, SyncEntity, SyncEvent
    sync_config.dart                   — Intervalos y configuración del sync

docs/
  supabase_schema_v8_COMPLETE.sql      — Esquema completo Supabase (contenido real: v9)
  supabase_loan_hardening_COMPLETE.sql — Triggers y funciones de préstamos
  manual_test_checklist.md
  future_iterations.md
```

---

## Features planificadas — no implementar sin confirmación explícita

### Próxima iteración

**Perfiles infantiles (Drift v28):**
- Nuevos campos en `LocalUsers`: `isChildProfile BOOL`, `parentUserId INT FK`, `displayName TEXT`, `avatarEmoji TEXT`, `birthYear INT`
- Sin sync a Supabase — completamente local
- UI separada: solo 2 tabs (biblioteca + leyendo)
- Tablas en v29 para gamificación: `ChildAchievements`, `ChildChallenges`

**Libros digitales desde epub/PDF:**
- Nuevos campos en `Books`: `digitalFilePath TEXT`, `bookOrigin TEXT`
- Extracción de metadatos + búsqueda automática en Google Books
- Los digitales no van a grupos (ya garantizado por `_shouldShare`)

**Integración con lectores externos:**
- Lanzar archivo con intent del sistema (Android) / share (iOS)
- Lifecycle observer para detectar regreso a la app
- Diálogo automático de registro de sesión
- Notificación persistente con `flutter_local_notifications` (ya instalado)

### Ya implementado — no reimplementar

- Escáner ISBN, PIN, backup/exportación, importación Goodreads CSV
- Grupos temáticos con filtro de géneros (`allowedGenres` + `primaryColor`) ✅ Drift v26
- Sync incremental con `SyncCursors` ✅ Drift v27
- `UnifiedSyncCoordinator` con fases, debounce, retry y batería ✅
- Wishlist con sync ✅ Drift v25
- ReadingSessions ✅ Drift v24
- Clubes de lectura completos (votaciones, moderación, progreso por sección) ✅ Drift v21
- Préstamos manuales, doble confirmación de devolución
- Modo Zen / No Molestar
- Boletín literario por IA

---

## Qué NO hacer

- ❌ Usar `id` local como referencia entre entidades. Siempre `uuid`.
- ❌ `DELETE` físico en operaciones de usuario. Siempre `isDeleted = true`.
- ❌ Cambiar rating a 5 estrellas. Es 1-4 por diseño (migrado en v19).
- ❌ Usar `syncedAt` como cursor remoto. Usar `SyncCursors.lastRemoteUpdatedAt`.
- ❌ Replicar `accept_loan` en Flutter. Es responsabilidad del trigger SQL.
- ❌ Editar `database.g.dart` manualmente. Regenerar con `dart run build_runner build --delete-conflicting-outputs`.
- ❌ Saltarse migraciones. Cada cambio de esquema necesita su bloque `if (from < N)`.
- ❌ Alterar el orden de fases del `UnifiedSyncCoordinator`. Las fases respetan FKs.
- ❌ Cambiar `(select auth.uid())` por `auth.uid()` en RLS. El paréntesis es intencional.
- ❌ Poner `group_id NOT NULL` a una fila de backup personal en Supabase `shared_books`.
- ❌ Crear filas en la tabla local `SharedBooks` sin `groupId`. No tiene ese caso de uso.
- ❌ Intentar tener fila personal en Supabase y fila de grupo en Supabase para el mismo libro. Son mutuamente excluyentes: si está en un grupo, se elimina la fila personal.

---

*Última actualización: Marzo 2026 — Esquema local Drift v27, Supabase v9. Basado en auditoría directa de database.dart, book_repository.dart, supabase_book_sync_repository.dart, unified_sync_coordinator.dart y supabase_schema_v8_COMPLETE.sql.*
