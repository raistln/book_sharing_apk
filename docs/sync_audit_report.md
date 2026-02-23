# 🔧 Informe de Auditoría y Plan de Reparación: Sistema de Sincronización

> **Proyecto:** App Flutter con Supabase + Drift (SQLite local)  
> **Archivos auditados:** 8 repositorios/servicios de sincronización  
> **Fecha:** Febrero 2026  
> **Estrategia recomendada:** Reparación incremental por prioridad (NO reescritura completa)

---

## Índice

1. [Resumen ejecutivo](#1-resumen-ejecutivo)
2. [Arquitectura actual y dependencias](#2-arquitectura-actual-y-dependencias)
3. [Nueva tabla requerida: `sync_cursors`](#3-nueva-tabla-requerida-sync_cursors)
4. [Bug #1 — Timestamp incremental incorrecto](#4-bug-1--timestamp-incremental-incorrecto-crítico)
5. [Bug #2 — Timeline entries quedan como dirty tras sync](#5-bug-2--timeline-entries-quedan-como-dirty-tras-sync-crítico)
6. [Bug #3 — Libros duplicados en Supabase al subir](#6-bug-3--libros-duplicados-en-supabase-al-subir-crítico)
7. [Bug #4 — Club books nunca bajan al dispositivo](#7-bug-4--club-books-nunca-bajan-al-dispositivo-crítico)
8. [Bug #5 — Loan sync sobreescribe cambios locales](#8-bug-5--loan-sync-sobreescribe-cambios-locales-crítico)
9. [Bug #6 — Préstamos inválidos subidos a Supabase](#9-bug-6--préstamos-inválidos-subidos-a-supabase-crítico)
10. [Bug #7 — Race condition loans vs shared_books](#10-bug-7--race-condition-loans-vs-shared_books-crítico)
11. [Bug #8 — rethrow rompe sync completo en clubs](#11-bug-8--rethrow-rompe-sync-completo-en-clubs-importante)
12. [Bug #9 — Borrado masivo erróneo de shared_books](#12-bug-9--borrado-masivo-erróneo-de-shared_books-importante)
13. [Bug #10 — Datos perdidos entre fetch y transacción](#13-bug-10--datos-perdidos-entre-fetch-y-transacción-importante)
14. [Bug #11 — Interpolación incorrecta en logs](#14-bug-11--interpolación-incorrecta-en-logs-menor)
15. [Bug #12 — Clubs no guardan remoteId tras creación](#15-bug-12--clubs-no-guardan-remoteid-tras-creación-importante)
16. [Bug #13 — Libros borrados no detectados en fallback de grupos](#16-bug-13--libros-borrados-no-detectados-en-fallback-de-grupos-menor)
17. [Bug #14 — Sin resolución real de conflictos](#17-bug-14--sin-resolución-real-de-conflictos-importante)
18. [Bug #15 — syncNow no es idempotente bajo concurrencia](#18-bug-15--syncnow-no-es-idempotente-bajo-concurrencia-importante)
19. [Orden de implementación recomendado](#19-orden-de-implementación-recomendado)
20. [Tests mínimos a añadir](#20-tests-mínimos-a-añadir)

---

## 1. Resumen ejecutivo

El sistema de sincronización tiene una **arquitectura correcta** (repositories, DAOs, coordinator) pero con **15 bugs** de distinta severidad que afectan tanto la bajada de datos (remote → local) como la subida (local → remote). Los más críticos causan:

- Pérdida silenciosa de cambios del usuario
- Duplicados en Supabase
- Entidades que nunca se sincronizan (club books)
- Race conditions bajo uso normal

La estrategia es **reparar en orden de prioridad**, no reescribir. La única excepción es el mecanismo de cursor de sincronización (Bug #1), que requiere añadir una nueva tabla a la base de datos local.

---

## 2. Arquitectura actual y dependencias

```
UnifiedSyncCoordinator
    │
    ├── userSyncController      → SupabaseUserSyncRepository
    ├── bookSyncController      → SupabaseBookSyncRepository
    ├── groupSyncController     → SupabaseGroupSyncRepository
    ├── loanSyncController      → SupabaseLoanSyncRepository
    ├── notificationSyncCtrl    → SupabaseNotificationSyncRepository
    └── clubSyncController      → SupabaseClubSyncRepository
                                     └── SupabaseClubBookSyncRepository
```

**Orden de dependencias correcto (ya implementado en coordinator):**
```
users → groups → books → loans → notifications → clubs
```

**Problema:** la implementación de cada paso tiene los bugs descritos abajo.

---

## 3. Nueva tabla requerida: `sync_cursors`

Esta tabla es el prerequisito para arreglar el Bug #1. Debe añadirse al schema de Drift antes de cualquier otra corrección.

### 3.1 Crear la tabla en Drift

**Archivo:** `lib/data/local/database.dart` (o donde definas las tablas Drift)

```dart
// Añadir esta clase de tabla al schema de Drift
class SyncCursors extends Table {
  // La entidad: 'books', 'reviews', 'timeline', 'sessions',
  //              'wishlist', 'users', 'loans', 'clubs'
  TextColumn get entity => text()();

  // El MAX(updatedAt) del último registro recibido del servidor
  DateTimeColumn get lastRemoteUpdatedAt => dateTime().nullable()();

  // Cuándo se ejecutó la última sincronización exitosa
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {entity};
}
```

**Añadir al `@DriftDatabase`:**

```dart
@DriftDatabase(
  tables: [
    Books,
    BookReviews,
    ReadingTimelineEntries,
    ReadingSessions,
    WishlistItems,
    LocalUsers,
    Groups,
    GroupMembers,
    SharedBooks,
    Loans,
    InAppNotifications,
    ReadingClubs,
    ClubMembers,
    ClubBooks,
    BookProposals,
    // ... resto de tablas existentes ...
    SyncCursors,  // ← NUEVA
  ],
)
class AppDatabase extends _$AppDatabase {
  // ...
  @override
  int get schemaVersion => X; // Incrementar versión
  
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (migrator, from, to) async {
      if (from < X) { // X = nueva versión
        await migrator.createTable(syncCursors);
      }
    },
  );
}
```

### 3.2 Métodos helper para el cursor

**Archivo:** `lib/data/local/sync_cursor_dao.dart` (archivo nuevo)

```dart
import 'package:drift/drift.dart';
import 'database.dart';

part 'sync_cursor_dao.g.dart';

@DriftAccessor(tables: [SyncCursors])
class SyncCursorDao extends DatabaseAccessor<AppDatabase>
    with _$SyncCursorDaoMixin {
  SyncCursorDao(super.db);

  /// Obtiene el cursor de una entidad. Retorna null si nunca se ha sincronizado.
  Future<DateTime?> getCursor(String entity) async {
    final row = await (select(syncCursors)
          ..where((t) => t.entity.equals(entity)))
        .getSingleOrNull();
    return row?.lastRemoteUpdatedAt;
  }

  /// Actualiza el cursor SOLO si la nueva fecha es más reciente.
  /// Llamar después de una sincronización exitosa.
  Future<void> updateCursor(String entity, DateTime? lastRemoteUpdatedAt) async {
    if (lastRemoteUpdatedAt == null) return;

    await into(syncCursors).insertOnConflictUpdate(
      SyncCursorsCompanion.insert(
        entity: entity,
        lastRemoteUpdatedAt: Value(lastRemoteUpdatedAt),
        lastSyncedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Resetea el cursor de una entidad (fuerza sync completo en el próximo ciclo).
  Future<void> resetCursor(String entity) async {
    await (delete(syncCursors)
          ..where((t) => t.entity.equals(entity)))
        .go();
  }

  /// Resetea todos los cursores (útil al cambiar de usuario o en logout).
  Future<void> resetAllCursors() async {
    await delete(syncCursors).go();
  }
}
```

---

## 4. Bug #1 — Timestamp incremental incorrecto (CRÍTICO)

### Archivo afectado
`lib/data/repositories/supabase_book_sync_repository.dart`

### Descripción del problema

El código actual usa `syncedAt` (cuándo se guardó el registro **localmente**) como filtro `updatedAfter` para pedir cambios al servidor:

```dart
// ❌ CÓDIGO ACTUAL — INCORRECTO
final lastSyncedBook = await (_bookDao.attachedDatabase
        .select(_bookDao.attachedDatabase.books)
      ..orderBy([(t) => OrderingTerm(expression: t.syncedAt, mode: OrderingMode.desc)])
      ..limit(1))
    .getSingleOrNull();

// Luego usa lastSyncedBook?.syncedAt como filtro
await _bookService.fetchBooks(
  updatedAfter: lastSyncedBook?.syncedAt, // ❌ Hora local, no del servidor
);
```

**Por qué falla:** Si el reloj del dispositivo va 5 minutos adelantado respecto al servidor de Supabase, `syncedAt` será siempre mayor que `updatedAt` del servidor, y el filtro `gte` excluirá registros válidos. Además, `syncedAt` es la hora en que se _guardó_ localmente, no cuándo se _actualizó_ en el servidor.

El mismo patrón incorrecto se repite para reviews, timeline, sessions y wishlist.

### Fix completo

**Prerequisito:** Tener creada la tabla `sync_cursors` y el `SyncCursorDao` del punto 3.

**Paso 1:** Inyectar `SyncCursorDao` en el repositorio:

```dart
class SupabaseBookSyncRepository {
  SupabaseBookSyncRepository({
    required BookDao bookDao,
    required TimelineEntryDao timelineDao,
    required ReadingSessionDao sessionDao,
    required WishlistDao wishlistDao,
    required SyncCursorDao syncCursorDao, // ← NUEVO parámetro
    SupabaseBookService? bookService,
  })  : _bookDao = bookDao,
        _timelineDao = timelineDao,
        _sessionDao = sessionDao,
        _wishlistDao = wishlistDao,
        _syncCursorDao = syncCursorDao, // ← NUEVO
        _bookService = bookService ?? SupabaseBookService();

  // ... campos existentes ...
  final SyncCursorDao _syncCursorDao; // ← NUEVO
```

**Paso 2:** Reemplazar TODA la sección de "Fetch last sync timestamps" en `syncFromRemote`:

```dart
// ✅ NUEVO — Leer cursores desde la tabla dedicada
Future<void> syncFromRemote({
  required LocalUser owner,
  String? accessToken,
}) async {
  final ownerRemoteId = owner.remoteId;
  if (ownerRemoteId == null) {
    developer.log('No remoteId para el usuario activo.', name: 'SupabaseBookSyncRepository', level: 900);
    return;
  }

  // ✅ Leer cursores correctos (MAX updatedAt del servidor, no syncedAt local)
  final cursorBooks     = await _syncCursorDao.getCursor('books');
  final cursorReviews   = await _syncCursorDao.getCursor('reviews');
  final cursorTimeline  = await _syncCursorDao.getCursor('timeline');
  final cursorSessions  = await _syncCursorDao.getCursor('sessions');
  final cursorWishlist  = await _syncCursorDao.getCursor('wishlist');

  developer.log('🔄 syncFromRemote para $ownerRemoteId', name: 'SupabaseBookSyncRepository');
  developer.log('  cursors: books=$cursorBooks, reviews=$cursorReviews, timeline=$cursorTimeline', name: 'SupabaseBookSyncRepository');

  // Fetch remoto con los cursores correctos
  final remoteBooks    = await _bookService.fetchBooks(ownerId: ownerRemoteId, accessToken: accessToken, updatedAfter: cursorBooks);
  final remoteReviews  = await _bookService.fetchReviews(accessToken: accessToken, updatedAfter: cursorReviews);
  final remoteTimeline = await _bookService.fetchTimelineEntries(ownerId: ownerRemoteId, accessToken: accessToken, updatedAfter: cursorTimeline);
  final remoteSessions = await _bookService.fetchReadingSessions(ownerId: ownerRemoteId, accessToken: accessToken, updatedAfter: cursorSessions);
  final remoteWishlist = await _bookService.fetchWishlistItems(userId: ownerRemoteId, accessToken: accessToken, updatedAfter: cursorWishlist);

  final db  = _bookDao.attachedDatabase;
  final now = DateTime.now();

  await db.transaction(() async {
    // ... (lógica existente de upsert de registros, sin cambios aquí) ...

    // ✅ AL FINAL DE LA TRANSACCIÓN: actualizar cursores con el MAX(updatedAt) recibido
    // Calcular el updatedAt más reciente de cada lista recibida
    final maxBookDate = _maxUpdatedAt(remoteBooks.map((b) => b.updatedAt ?? b.createdAt));
    final maxReviewDate = _maxUpdatedAt(remoteReviews.map((r) => r.updatedAt ?? r.createdAt));
    final maxTimelineDate = _maxUpdatedAt(remoteTimeline.map((t) => t.updatedAt ?? t.createdAt));
    final maxSessionDate = _maxUpdatedAt(remoteSessions.map((s) => s.updatedAt ?? s.createdAt));
    final maxWishlistDate = _maxUpdatedAt(remoteWishlist.map((w) => w.updatedAt ?? w.createdAt));

    await _syncCursorDao.updateCursor('books',    maxBookDate);
    await _syncCursorDao.updateCursor('reviews',  maxReviewDate);
    await _syncCursorDao.updateCursor('timeline', maxTimelineDate);
    await _syncCursorDao.updateCursor('sessions', maxSessionDate);
    await _syncCursorDao.updateCursor('wishlist', maxWishlistDate);
  });
}

// ✅ Helper para obtener la fecha máxima de una lista
DateTime? _maxUpdatedAt(Iterable<DateTime?> dates) {
  DateTime? max;
  for (final d in dates) {
    if (d == null) continue;
    if (max == null || d.isAfter(max)) max = d;
  }
  return max;
}
```

**Paso 3:** Asegurarse de inyectar `SyncCursorDao` donde se construye el repositorio (en el DI / provider setup):

```dart
// En tu provider o service locator
SupabaseBookSyncRepository(
  bookDao: ref.read(bookDaoProvider),
  timelineDao: ref.read(timelineDaoProv),
  sessionDao: ref.read(sessionDaoProvider),
  wishlistDao: ref.read(wishlistDaoProvider),
  syncCursorDao: ref.read(syncCursorDaoProvider), // ← NUEVO
)
```

---

## 5. Bug #2 — Timeline entries quedan como dirty tras sync (CRÍTICO)

### Archivo afectado
`lib/data/repositories/supabase_book_sync_repository.dart`

### Descripción del problema

Cuando se inserta una nueva timeline entry bajada del servidor, se llama a `createEntry` pero no se pasan `isDirty: false` ni `syncedAt`. Si el DAO usa valores por defecto de `isDirty: true`, el registro recién bajado será subido de vuelta en el próximo `pushLocalChanges`, creando duplicados remotos.

```dart
// ❌ CÓDIGO ACTUAL — en el loop de remoteTimeline
} else {
  // Insert new
  await _timelineDao.createEntry(
    bookId: book.id,
    ownerUserId: owner.id,
    eventType: remote.eventType,
    currentPage: remote.currentPage,
    percentageRead: remote.percentageRead,
    note: remote.note,
    eventDate: remote.eventDate,
    remoteId: remote.id,
    // ❌ Falta: isDirty: false, syncedAt: now, createdAt, updatedAt
  );
}
```

### Fix

Reemplazar la llamada a `createEntry` por una inserción directa con todos los campos de sync:

```dart
// ✅ CÓDIGO CORRECTO
} else {
  // Insertar como CompanionInsert directo para controlar isDirty y syncedAt
  await _timelineDao.db.into(_timelineDao.db.readingTimelineEntries).insert(
    ReadingTimelineEntriesCompanion.insert(
      uuid: remote.id,
      remoteId: Value(remote.id),
      bookId: book.id,
      bookUuid: book.uuid,
      ownerUserId: owner.id,
      eventType: remote.eventType,
      currentPage: Value(remote.currentPage),
      percentageRead: Value(remote.percentageRead),
      note: Value(remote.note),
      eventDate: remote.eventDate,
      isDeleted: Value(remote.isDeleted),
      isDirty: const Value(false),       // ✅ CRÍTICO: no dirty
      syncedAt: Value(now),              // ✅ CRÍTICO: marcar como sincronizado
      createdAt: Value(remote.createdAt),
      updatedAt: Value(remote.updatedAt ?? remote.createdAt),
    ),
    mode: InsertMode.insertOrIgnore,     // ✅ Evita duplicados si se llama dos veces
  );
}
```

> **Nota:** Si `createEntry` en `TimelineEntryDao` ya acepta parámetros `isDirty` y `syncedAt`, úsalo directamente. Si no, añade esos parámetros al método o usa la inserción directa como se muestra.

---

## 6. Bug #3 — Libros duplicados en Supabase al subir (CRÍTICO)

### Archivo afectado
`lib/data/repositories/supabase_book_sync_repository.dart`

### Descripción del problema

En `pushLocalChanges`, cuando un libro local no tiene `remoteId`, se hace un `POST` (create) directamente. Si el libro ya existe en Supabase (creado desde otro dispositivo y aún no bajado), el `POST` fallará con un error de conflicto de clave o, peor, creará un duplicado si Supabase no tiene una constraint adecuada.

```dart
// ❌ CÓDIGO ACTUAL
if (book.remoteId == null) {
  // CREATE — sin verificar si ya existe remotamente
  final remoteId = await _bookService.createBook(
    id: book.uuid,
    // ...
  );
```

### Fix

**Opción A (recomendada): Usar upsert en el servicio**

Modificar `SupabaseBookService.createBook` para usar upsert con `on_conflict`:

```dart
// En supabase_book_service.dart
// Cambiar el header Prefer para usar upsert semántico
Future<String> createBook({...}) async {
  final config = await _loadConfig();
  final uri = Uri.parse('${config.url}/rest/v1/shared_books');

  // Añadir ?on_conflict=id para hacer upsert
  final uriWithConflict = uri.replace(queryParameters: {'on_conflict': 'id'});

  final response = await _client.post(
    uriWithConflict,
    headers: _buildHeaders(
      config,
      accessToken: accessToken,
      preferRepresentation: true,
      // El header Prefer debe incluir resolution=merge-duplicates
    ),
    body: jsonEncode(payload),
  );
  // ...
}
```

**Y actualizar `_buildHeaders` para soportar merge:**

```dart
Map<String, String> _buildHeaders(
  SupabaseConfig config, {
  String? accessToken,
  bool preferRepresentation = false,
  bool mergeDuplicates = false,   // ← NUEVO parámetro
}) {
  // ...
  final preferParts = <String>[
    preferRepresentation ? 'return=representation' : 'return=minimal',
    if (mergeDuplicates) 'resolution=merge-duplicates',
  ];
  headers['Prefer'] = preferParts.join(',');
  return headers;
}
```

**Llamada actualizada en el repositorio:**

```dart
// ✅ CÓDIGO CORRECTO en pushLocalChanges
if (book.remoteId == null) {
  final remoteId = await _bookService.createBook(
    id: book.uuid,
    ownerId: ownerRemoteId,
    bookUuid: book.uuid,
    title: book.title,
    // ... resto de campos ...
    mergeDuplicates: true,  // ← Upsert en lugar de insert puro
    accessToken: accessToken,
  );
  // ...
}
```

**Opción B (más simple, sin modificar el servicio):**

Verificar existencia antes de crear:

```dart
// ✅ ALTERNATIVA en pushLocalChanges
if (book.remoteId == null) {
  // Verificar si ya existe remotamente por UUID
  final existing = await _bookService.fetchBookById(id: book.uuid, accessToken: accessToken);
  
  if (existing != null) {
    // Ya existe: actualizar remoteId local y hacer update
    await _bookDao.updateBookFields(
      bookId: book.id,
      entry: BooksCompanion(remoteId: Value(existing.id)),
    );
    await _bookService.updateBook(id: existing.id, /* campos */, accessToken: accessToken);
  } else {
    // No existe: crear normalmente
    final remoteId = await _bookService.createBook(/* campos */, accessToken: accessToken);
    // ...
  }
}
```

> La Opción A es más eficiente (1 request vs 2). La Opción B es más explícita y fácil de entender.

---

## 7. Bug #4 — Club books nunca bajan al dispositivo (CRÍTICO)

### Archivos afectados
- `lib/data/repositories/supabase_club_sync_repository.dart`
- `lib/data/repositories/supabase_club_book_sync_repository.dart`

### Descripción del problema

`SupabaseClubSyncRepository.syncFromRemote` procesa clubs y members, pero **nunca itera sobre `remote.books`** para crear los `ClubBook` locales. El comentario en `SupabaseClubBookSyncRepository` dice que lo maneja el otro repository, pero ninguno lo hace.

```dart
// En SupabaseClubSyncRepository.syncFromRemote
// ❌ Se procesan members pero NO books
for (final remoteMember in remote.members) {
  // ... se insertan members ...
}

// ← AQUÍ FALTA el loop para remote.books
// Los club_books nunca se insertan localmente
```

### Fix

En `SupabaseClubSyncRepository.syncFromRemote`, añadir el loop de libros **después** del loop de members y antes de la reconciliación:

```dart
// ✅ AÑADIR después del loop de members, dentro del loop de remoteClubs

// Sync club books
for (final remoteBook in remote.books) {
  final existing = await _clubDao.getClubBookByRemoteId(remoteBook.id);

  if (existing != null) {
    // Actualizar libro existente (no sobreescribir si está dirty)
    if (!existing.isDirty) {
      await _clubDao.upsertClubBook(ClubBooksCompanion(
        id: Value(existing.id),
        uuid: Value(existing.uuid),
        clubId: Value(localClubId),
        clubUuid: Value(localClubUuid),
        remoteId: Value(remoteBook.id),
        bookUuid: Value(remoteBook.bookUuid),
        orderPosition: Value(remoteBook.orderPosition),
        status: Value(remoteBook.status),
        sectionMode: Value(remoteBook.sectionMode),
        totalChapters: Value(remoteBook.totalChapters),
        sections: Value(remoteBook.sections),
        startDate: Value(remoteBook.startDate),
        endDate: Value(remoteBook.endDate),
        isDirty: const Value(false),
        syncedAt: Value(now),
        updatedAt: Value(remoteBook.updatedAt),
      ));
      if (kDebugMode) debugPrint('[ClubSync] Updated club book ${remoteBook.id}');
    }
  } else {
    // Insertar nuevo club book
    await _clubDao.upsertClubBook(ClubBooksCompanion.insert(
      uuid: remoteBook.id,
      remoteId: Value(remoteBook.id),
      clubId: localClubId,
      clubUuid: localClubUuid,
      bookUuid: remoteBook.bookUuid,
      orderPosition: remoteBook.orderPosition,
      status: remoteBook.status,
      sectionMode: remoteBook.sectionMode,
      totalChapters: remoteBook.totalChapters,
      sections: remoteBook.sections,
      startDate: Value(remoteBook.startDate),
      endDate: Value(remoteBook.endDate),
      isDirty: const Value(false),
      syncedAt: Value(now),
      createdAt: Value(remoteBook.createdAt),
      updatedAt: Value(remoteBook.updatedAt),
    ));
    if (kDebugMode) debugPrint('[ClubSync] Created club book ${remoteBook.id}');
  }
}

// También sincronizar proposals y reading progress si vienen en el payload
// (Si el endpoint los incluye; si no, hacer fetch adicional aquí)
```

> **Verificar:** Si `upsertClubBook` en tu `ClubDao` acepta `ClubBooksCompanion.insert`, úsalo. Si solo acepta update parcial, añade un método `insertClubBook` al DAO.

---

## 8. Bug #5 — Loan sync sobreescribe cambios locales (CRÍTICO)

### Archivo afectado
`lib/data/repositories/supabase_loan_sync_repository.dart`

### Descripción del problema

En `_pullRemoteChanges`, se usa `InsertMode.insertOrReplace` sin verificar si el préstamo local tiene `isDirty: true`. Esto sobreescribe cambios locales del usuario con la versión del servidor.

```dart
// ❌ CÓDIGO ACTUAL
batch.insert(
  _db.loans,
  LoansCompanion(
    uuid: Value(uuid),
    // ... todos los campos remotos ...
    isDirty: const Value(false),
  ),
  mode: InsertMode.insertOrReplace, // ❌ Borra cambios locales sin mirar isDirty
);
```

### Fix

Reemplazar el `batch.insert` con lógica que respete `isDirty`:

```dart
// ✅ CÓDIGO CORRECTO — fuera del batch, con verificación previa
Future<void> _pullRemoteChanges(String userId) async {
  // ... (código existente hasta obtener remoteLoans) ...

  if (remoteLoans.isEmpty) return;

  // ... (código existente de resolución de UUIDs) ...

  // ✅ NO usar batch con insertOrReplace — verificar isDirty individualmente
  for (final data in remoteLoans) {
    final uuid = data['uuid'] as String;
    
    // Buscar si existe localmente
    final existing = await (_db.select(_db.loans)
          ..where((l) => l.uuid.equals(uuid)))
        .getSingleOrNull();

    // ✅ Si existe y tiene cambios locales, NO sobreescribir
    if (existing != null && existing.isDirty) {
      developer.log(
        'Loan $uuid tiene cambios locales (isDirty=true), omitiendo actualización remota.',
        name: 'SupabaseLoanSyncRepository',
      );
      // Solo actualizar remoteId si no lo tiene
      if (existing.remoteId == null) {
        await (_db.update(_db.loans)..where((l) => l.uuid.equals(uuid)))
            .write(LoansCompanion(remoteId: Value(uuid)));
      }
      continue;
    }

    final updatedAt = DateTime.parse(data['updated_at'] as String);
    final bookUuid = data['book_uuid'] as String?;
    final borrowerUuid = data['borrower_user_id'] as String?;
    final lenderUuid = data['lender_user_id'] as String?;

    final bookId = bookUuid != null ? bookIdMap[bookUuid] : null;
    final borrowerId = borrowerUuid != null ? userIdMap[borrowerUuid] : null;
    final lenderId = lenderUuid != null ? userIdMap[lenderUuid] : null;

    if (lenderId == null) {
      developer.log('Loan $uuid ignorado: lender $lenderUuid no encontrado.', name: 'SupabaseLoanSyncRepository');
      continue;
    }

    final companion = LoansCompanion(
      uuid: Value(uuid),
      remoteId: Value(uuid),
      sharedBookId: Value(data['shared_book_id'] as int?),
      bookId: Value(bookId),
      borrowerUserId: Value(borrowerId),
      lenderUserId: Value(lenderId),
      externalBorrowerName: Value(data['external_borrower_name'] as String?),
      externalBorrowerContact: Value(data['external_borrower_contact'] as String?),
      status: Value(data['status'] as String),
      requestedAt: Value(DateTime.parse(data['requested_at'] as String)),
      approvedAt: Value(data['approved_at'] != null ? DateTime.parse(data['approved_at']) : null),
      dueDate: Value(data['due_date'] != null ? DateTime.parse(data['due_date']) : null),
      lenderReturnedAt: Value(data['lender_returned_at'] != null ? DateTime.parse(data['lender_returned_at']) : null),
      borrowerReturnedAt: Value(data['borrower_returned_at'] != null ? DateTime.parse(data['borrower_returned_at']) : null),
      returnedAt: Value(data['returned_at'] != null ? DateTime.parse(data['returned_at']) : null),
      createdAt: Value(DateTime.parse(data['created_at'] as String)),
      updatedAt: Value(updatedAt),
      isDeleted: Value(data['is_deleted'] as bool? ?? false),
      isDirty: const Value(false),
      syncedAt: Value(DateTime.now()),
    );

    // ✅ Usar insertOrUpdate respetando el flujo
    if (existing == null) {
      await _db.into(_db.loans).insert(companion);
    } else {
      // Existe pero no está dirty: actualizar con versión remota
      await (_db.update(_db.loans)..where((l) => l.uuid.equals(uuid)))
          .write(companion);
    }
  }
}
```

---

## 9. Bug #6 — Préstamos inválidos subidos a Supabase (CRÍTICO)

### Archivo afectado
`lib/data/repositories/supabase_loan_sync_repository.dart`

### Descripción del problema

En `_pushLocalChanges`, se construye el payload sin verificar si el libro asociado ya está sincronizado. Si `bookUuid` es `null` (libro aún no subido) o `sharedBookId` es `null`, se sube un préstamo inválido:

```dart
// ❌ CÓDIGO ACTUAL — sin guards
return {
  'uuid': l.uuid,
  'shared_book_id': l.sharedBookId, // Puede ser null
  'book_uuid': bookUuid,            // Puede ser null si el libro no se sincronizó
  'borrower_user_id': borrowerUuid,
  // ...
};
```

### Fix

Añadir validación antes de incluir el préstamo en el payload:

```dart
// ✅ CÓDIGO CORRECTO
Future<void> _pushLocalChanges(String userId) async {
  final dirtyLoans = await (_db.select(_db.loans)
        ..where((l) => l.isDirty.equals(true)))
      .get();

  if (dirtyLoans.isEmpty) return;

  // ... (resolución de bookMap y userMap existente) ...

  final loansPayload = <Map<String, dynamic>>[];
  final skippedLoanIds = <int>[];

  for (final l in dirtyLoans) {
    final bookUuid = l.bookId != null ? bookMap[l.bookId] : null;
    final lenderUuid = userMap[l.lenderUserId] ?? userId;

    // ✅ Guard: el lender debe existir
    if (lenderUuid.isEmpty) {
      developer.log('Loan ${l.uuid} omitido: lender sin remoteId.', name: 'SupabaseLoanSyncRepository');
      skippedLoanIds.add(l.id);
      continue;
    }

    // ✅ Guard: si tiene sharedBookId, verificar que el shared book esté sincronizado
    if (l.sharedBookId != null) {
      final sharedBook = await (_db.select(_db.sharedBooks)
            ..where((sb) => sb.id.equals(l.sharedBookId!)))
          .getSingleOrNull();
      if (sharedBook == null || sharedBook.remoteId == null) {
        developer.log(
          'Loan ${l.uuid} omitido: shared_book ${l.sharedBookId} no sincronizado aún.',
          name: 'SupabaseLoanSyncRepository',
        );
        skippedLoanIds.add(l.id);
        continue;
      }
    }

    // ✅ Guard: si tiene bookId pero no bookUuid, también omitir
    if (l.bookId != null && bookUuid == null) {
      developer.log(
        'Loan ${l.uuid} omitido: book ${l.bookId} no tiene UUID válido.',
        name: 'SupabaseLoanSyncRepository',
      );
      skippedLoanIds.add(l.id);
      continue;
    }

    loansPayload.add({
      'uuid': l.uuid,
      'shared_book_id': l.sharedBookId,
      'book_uuid': bookUuid,
      'borrower_user_id': userMap[l.borrowerUserId],
      'lender_user_id': lenderUuid,
      'external_borrower_name': l.externalBorrowerName,
      'external_borrower_contact': l.externalBorrowerContact,
      'status': l.status,
      'requested_at': l.requestedAt.toIso8601String(),
      'approved_at': l.approvedAt?.toIso8601String(),
      'due_date': l.dueDate?.toIso8601String(),
      'lender_returned_at': l.lenderReturnedAt?.toIso8601String(),
      'borrower_returned_at': l.borrowerReturnedAt?.toIso8601String(),
      'returned_at': l.returnedAt?.toIso8601String(),
      'created_at': l.createdAt.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'is_deleted': l.isDeleted,
    });
  }

  if (loansPayload.isNotEmpty) {
    await _api.upsertLoans(loansPayload);
  }

  // Marcar como clean solo los que se subieron
  final uploadedLoans = dirtyLoans.where((l) => !skippedLoanIds.contains(l.id));
  await _db.batch((batch) {
    for (final loan in uploadedLoans) {
      batch.update(
        _db.loans,
        LoansCompanion(isDirty: const Value(false), syncedAt: Value(DateTime.now())),
        where: (t) => t.id.equals(loan.id),
      );
    }
  });
  // Los skipped permanecen dirty para reintentarse en el próximo ciclo
}
```

---

## 10. Bug #7 — Race condition loans vs shared_books (CRÍTICO)

### Archivo afectado
`lib/services/unified_sync_coordinator.dart`

### Descripción del problema

El orden actual en `syncNow` es:

```
1. users
2. groups  ← sube shared_books al servidor
3. books   ← sube libros personales
4. loans   ← necesita shared_books ya subidos
```

El problema es que `groupSyncController.syncGroups()` incluye tanto `syncFromRemote` como `pushLocalChanges`. Si `pushLocalChanges` de grupos tarda o falla parcialmente, los `shared_books` no estarán en Supabase cuando `loanSyncController.sync()` intente crearlos.

Además, `syncNow` no tiene guard contra llamadas concurrentes, por lo que dos llamadas simultáneas (reconexión de red + timer) pueden causar condiciones de carrera.

### Fix

**Paso 1:** Añadir guard de concurrencia:

```dart
// ✅ AÑADIR campo en UnifiedSyncCoordinator
bool _isSyncing = false;
final _syncLock = Completer<void>?; // Opcional: usar un Mutex package

Future<void> syncNow({List<SyncEntity>? entities}) async {
  // ✅ Guard de concurrencia
  if (_isSyncing) {
    _log('syncNow ignorado: ya hay una sincronización en curso.');
    return;
  }

  if (!_state.isConnected && SyncConfig.pauseOnNoConnection) {
    _log('Sincronización omitida: sin conexión.');
    return;
  }

  _isSyncing = true;
  _updateState(_state.copyWith(isSyncing: true));

  try {
    // ... (resto del código) ...
  } finally {
    _isSyncing = false; // ✅ Siempre limpiar aunque haya error
    _updateState(_state.copyWith(isSyncing: false));
  }
}
```

**Paso 2:** Separar el sync de grupos en dos fases para garantizar el orden:

```dart
// ✅ CÓDIGO CORRECTO en syncNow
Future<void> syncNow({List<SyncEntity>? entities}) async {
  if (_isSyncing) return;
  if (!_state.isConnected && SyncConfig.pauseOnNoConnection) return;

  _isSyncing = true;
  final entitiesToSync = entities ?? SyncEntity.values;
  _updateState(_state.copyWith(isSyncing: true));

  try {
    // FASE 1: Entidades base (sin dependencias entre sí)
    await _syncEntity(SyncEntity.users);

    // FASE 2: Bajar grupos del servidor primero (para tener shared_books locales)
    if (entitiesToSync.contains(SyncEntity.groups)) {
      await _groupSyncController.syncFromRemote(); // ← Solo bajada
    }

    // FASE 3: Sincronizar libros (depende de usuarios)
    if (entitiesToSync.contains(SyncEntity.books)) {
      await _syncEntity(SyncEntity.books);
    }

    // FASE 4: Subir cambios locales de grupos (shared_books ya están locales)
    if (entitiesToSync.contains(SyncEntity.groups)) {
      await _groupSyncController.pushLocalChanges(); // ← Solo subida
    }

    // FASE 5: Loans (shared_books ya están sincronizados bidirecccionalmente)
    if (entitiesToSync.contains(SyncEntity.loans)) {
      await _syncEntity(SyncEntity.loans);
    }

    // FASE 6: Independientes
    if (entitiesToSync.contains(SyncEntity.notifications)) {
      await _syncEntity(SyncEntity.notifications);
    }
    if (entitiesToSync.contains(SyncEntity.clubs)) {
      await _syncEntity(SyncEntity.clubs);
    }

    _updateState(_state.copyWith(lastFullSync: DateTime.now(), lastError: () => null));
    _log('🏁 FULL SYNC COMPLETED');
  } catch (e, st) {
    _log('❌ Error during sync', error: e, stackTrace: st);
    _updateState(_state.copyWith(lastError: () => e.toString()));
    rethrow;
  } finally {
    _isSyncing = false;
    _updateState(_state.copyWith(isSyncing: false));
  }
}
```

**Paso 3:** Exponer `syncFromRemote` y `pushLocalChanges` en `GroupSyncController`:

```dart
// En GroupSyncController o SupabaseGroupSyncRepository
// Asegurarse de que estos métodos sean públicos y separados
Future<void> syncFromRemote({String? accessToken});
Future<void> pushLocalChanges({String? accessToken});
```

---

## 11. Bug #8 — rethrow rompe sync completo en clubs (IMPORTANTE)

### Archivo afectado
`lib/data/repositories/supabase_club_book_sync_repository.dart`

### Descripción del problema

Todos los loops en `pushLocalChanges` usan `rethrow` en el `catch`. Un solo error en un `ClubBook`, proposal, progress record o comment cancela el procesamiento de todos los siguientes:

```dart
// ❌ CÓDIGO ACTUAL — en TODOS los loops de pushLocalChanges
} catch (error) {
  if (kDebugMode) { debugPrint(...); }
  rethrow; // ❌ Cancela el resto del loop
}
```

### Fix

Cambiar `rethrow` por logging y `continue`, igual que hace `SupabaseBookSyncRepository`:

```dart
// ✅ CÓDIGO CORRECTO — aplicar a TODOS los loops en pushLocalChanges

// Loop de club books
for (final book in dirtyBooks) {
  try {
    // ... lógica existente ...
  } catch (error, stackTrace) {
    // ✅ Log detallado pero NO rethrow
    if (kDebugMode) {
      debugPrint('[ClubBookSync] Failed to push club book ${book.uuid}: $error');
      debugPrint(stackTrace.toString());
    }
    // Continuar con el siguiente item
  }
}

// Loop de proposals
for (final proposal in dirtyProposals) {
  try {
    // ... lógica existente ...
  } catch (error, stackTrace) {
    if (kDebugMode) {
      debugPrint('[ClubBookSync] Failed to push proposal ${proposal.uuid}: $error');
    }
    // No rethrow
  }
}

// Aplicar el mismo patrón a: dirtyProgress, dirtyComments, dirtyReports, dirtyLogs
```

> **Excepción:** Si tienes un error que indica problema de autenticación (401/403), ahí sí querrás propagarlo. Puedes detectarlo así:
> ```dart
> } catch (error, stackTrace) {
>   if (error is SupabaseClubServiceException && (error.message.contains('401') || error.message.contains('403'))) {
>     rethrow; // Auth errors sí propagar
>   }
>   // Resto: solo loguear
> }
> ```

---

## 12. Bug #9 — Borrado masivo erróneo de shared_books (IMPORTANTE)

### Archivo afectado
`lib/data/repositories/supabase_group_repository.dart`

### Descripción del problema

La reconciliación de `sharedBooks` borra libros locales si no están en `remoteSharedIds`. Si `sharedRecords` llegó vacío por un error de red parcial (o si el endpoint devolvió 0 resultados por bug), **todos los libros compartidos locales con `remoteId` se borran**:

```dart
// ❌ CÓDIGO ACTUAL — sin guard contra lista vacía
final remoteSharedIds = sharedRecords.map((r) => r.id).toSet();
final localSharedBooks = await _groupDao.findSharedBooksByGroupId(localGroupId);

for (final local in localSharedBooks) {
  if (local.remoteId != null &&
      !remoteSharedIds.contains(local.remoteId) &&
      !local.isDirty) {
    await _groupDao.deleteSharedBook(local.id); // ❌ Borrado si la lista vino vacía
  }
}
```

### Fix

Añadir un guard que evite la reconciliación si la lista remota viene vacía:

```dart
// ✅ CÓDIGO CORRECTO
final remoteSharedIds = sharedRecords.map((r) => r.id).toSet();
final localSharedBooks = await _groupDao.findSharedBooksByGroupId(localGroupId);

// ✅ Guard: solo reconciliar si recibimos datos del servidor
// Si la lista viene vacía, podría ser un error de red, no que el grupo realmente no tenga libros
if (remoteSharedIds.isEmpty) {
  if (kDebugMode) {
    debugPrint(
      '[GroupSync] Omitiendo reconciliación de shared_books para grupo $localGroupUuid: '
      'la lista remota está vacía (posible error de red o grupo sin libros).',
    );
  }
  // No borrar nada
} else {
  for (final local in localSharedBooks) {
    if (local.remoteId != null &&
        local.remoteId!.isNotEmpty &&
        !remoteSharedIds.contains(local.remoteId) &&
        !local.isDirty) {
      if (kDebugMode) {
        debugPrint(
          '[GroupSync] RECONCILIATION: Borrando shared_book ${local.id} '
          '(remoteId ${local.remoteId} no está en servidor).',
        );
      }
      await _groupDao.deleteSharedBook(local.id);
    }
  }
}
```

> **Nota adicional:** Si un grupo realmente puede quedarse sin libros, necesitas distinguir entre "lista vacía por error" y "lista vacía porque el grupo no tiene libros". Una forma es que el servidor devuelva un campo `totalBooks` en la respuesta del grupo, o registrar en `sync_cursors` si la última sync de ese grupo fue exitosa.

---

## 13. Bug #10 — Datos perdidos entre fetch y transacción (IMPORTANTE)

### Archivo afectado
`lib/data/repositories/supabase_book_sync_repository.dart`

### Descripción del problema

Las llamadas `fetchBooks`, `fetchReviews`, etc. ocurren **fuera** de la transacción de base de datos. Si la app se cierra entre el fetch y el inicio de la transacción, los datos fetched se pierden y no se actualizan los cursores. En el próximo sync, se volverán a pedir con el mismo cursor, lo que no es un bug grave pero sí ineficiente.

El problema más serio es que los 5 fetches son secuenciales y si el segundo falla, el primero ya devolvió datos pero la transacción nunca se ejecuta, perdiendo esos datos.

### Fix

Envolver los fetches en un try-catch y hacer que la falta de alguno sea recuperable:

```dart
// ✅ CÓDIGO CORRECTO
Future<void> syncFromRemote({required LocalUser owner, String? accessToken}) async {
  // ... validaciones previas ...

  // Fetch con manejo de errores individuales
  List<SupabaseBookRecord> remoteBooks = [];
  List<SupabaseBookReviewRecord> remoteReviews = [];
  List<SupabaseTimelineEntryRecord> remoteTimeline = [];
  List<SupabaseReadingSessionRecord> remoteSessions = [];
  List<SupabaseWishlistItemRecord> remoteWishlist = [];

  // Ejecutar fetches en paralelo para mejor performance
  final results = await Future.wait([
    _bookService.fetchBooks(ownerId: ownerRemoteId, accessToken: accessToken, updatedAfter: cursorBooks)
        .catchError((e) { developer.log('Error fetching books: $e'); return <SupabaseBookRecord>[]; }),
    _bookService.fetchReviews(accessToken: accessToken, updatedAfter: cursorReviews)
        .catchError((e) { developer.log('Error fetching reviews: $e'); return <SupabaseBookReviewRecord>[]; }),
    _bookService.fetchTimelineEntries(ownerId: ownerRemoteId, accessToken: accessToken, updatedAfter: cursorTimeline)
        .catchError((e) { developer.log('Error fetching timeline: $e'); return <SupabaseTimelineEntryRecord>[]; }),
    _bookService.fetchReadingSessions(ownerId: ownerRemoteId, accessToken: accessToken, updatedAfter: cursorSessions)
        .catchError((e) { developer.log('Error fetching sessions: $e'); return <SupabaseReadingSessionRecord>[]; }),
    _bookService.fetchWishlistItems(userId: ownerRemoteId, accessToken: accessToken, updatedAfter: cursorWishlist)
        .catchError((e) { developer.log('Error fetching wishlist: $e'); return <SupabaseWishlistItemRecord>[]; }),
  ]);

  remoteBooks    = results[0] as List<SupabaseBookRecord>;
  remoteReviews  = results[1] as List<SupabaseBookReviewRecord>;
  remoteTimeline = results[2] as List<SupabaseTimelineEntryRecord>;
  remoteSessions = results[3] as List<SupabaseReadingSessionRecord>;
  remoteWishlist = results[4] as List<SupabaseWishlistItemRecord>;

  // Si todo vino vacío, no hay nada que hacer
  if (remoteBooks.isEmpty && remoteReviews.isEmpty && remoteTimeline.isEmpty
      && remoteSessions.isEmpty && remoteWishlist.isEmpty) {
    developer.log('No hay datos nuevos del servidor.', name: 'SupabaseBookSyncRepository');
    return;
  }

  // ... transacción con los datos fetched ...
}
```

> **Nota:** Los `Future.wait` en paralelo mejoran la performance significativamente (5 requests secuenciales vs. 5 en paralelo).

---

## 14. Bug #11 — Interpolación incorrecta en logs (MENOR)

### Archivo afectado
`lib/data/repositories/supabase_notification_sync_repository.dart`

### Descripción del problema

String interpolation de Dart sin llaves `{}`, lo que imprime el objeto en lugar del valor:

```dart
// ❌ CÓDIGO ACTUAL — imprime literalmente "$local.uuid"
developer.log(
  'Subiendo notificación $local.uuid (tipo=$local.type → $convertedType)...',
  // Dart interpreta esto como: "${local}.uuid", no "${local.uuid}"
);
```

### Fix

```dart
// ✅ CÓDIGO CORRECTO — añadir llaves en todas las propiedades
developer.log(
  'Subiendo notificación ${local.uuid} (tipo=${local.type} → $convertedType) '
  'para usuario remoto $targetUserRemoteId.',
  name: 'SupabaseNotificationSyncRepository',
);
```

**Buscar y corregir en todo el archivo:**
```dart
// Patrón a buscar: $local.* (sin llaves)
// Corrección:      ${local.*} (con llaves)

// Ejemplos de otras líneas que pueden tener el mismo problema:
'Error al sincronizar notificación ${local.uuid}: $error'  // ✅ Correcto
'Notificación ${local.uuid} sincronizada con id remoto ${remote.id}.' // ✅ Correcto
```

---

## 15. Bug #12 — Clubs no guardan remoteId tras creación (IMPORTANTE)

### Archivo afectado
`lib/data/repositories/supabase_club_sync_repository.dart`

### Descripción del problema

Cuando se crea un club nuevo en Supabase, `ensuredRemoteId` puede ser diferente al `provisionalRemoteId` (si Supabase asigna su propio ID). Pero `markClubSynced` no guarda el `remoteId` devuelto:

```dart
// ❌ CÓDIGO ACTUAL
ensuredRemoteId = await _clubService.createClub(
  id: provisionalRemoteId,
  // ...
);

// ensuredRemoteId puede ser diferente a provisionalRemoteId
await _clubDao.markClubSynced(club.uuid, syncTime); // ❌ No guarda ensuredRemoteId
```

En el próximo sync, `club.remoteId` sigue siendo `null`, por lo que se intentará crear de nuevo.

### Fix

**Opción A:** Modificar `markClubSynced` para aceptar `remoteId`:

```dart
// En ClubDao
Future<void> markClubSynced(String uuid, DateTime syncTime, {String? remoteId}) async {
  await (update(readingClubs)..where((t) => t.uuid.equals(uuid))).write(
    ReadingClubsCompanion(
      isDirty: const Value(false),
      syncedAt: Value(syncTime),
      // ✅ Actualizar remoteId si se proporcionó
      remoteId: remoteId != null ? Value(remoteId) : const Value.absent(),
    ),
  );
}
```

**Llamada actualizada en el repositorio:**

```dart
// ✅ CÓDIGO CORRECTO
await _clubDao.markClubSynced(club.uuid, syncTime, remoteId: ensuredRemoteId);
```

**Opción B (más explícita):** Hacer el update manualmente en el repositorio:

```dart
// ✅ ALTERNATIVA
await (_clubDao.update(_clubDao.readingClubs)
      ..where((t) => t.uuid.equals(club.uuid)))
    .write(ReadingClubsCompanion(
      remoteId: Value(ensuredRemoteId), // ✅ Guardar remoteId real
      isDirty: const Value(false),
      syncedAt: Value(syncTime),
    ));
```

> El mismo patrón aplica para `ClubMember`. Verificar que `pushLocalChanges` para members también guarde el `ensuredRemoteId` devuelto.

---

## 16. Bug #13 — Libros borrados no detectados en fallback de grupos (MENOR)

### Archivo afectado
`lib/data/repositories/supabase_group_repository.dart`  
`lib/services/supabase_group_service.dart`

### Descripción del problema

El fallback `fetchSharedBooksForGroup` no incluye `is_deleted` en el `select`, por lo que libros borrados remotamente no se procesan como borrados localmente:

```dart
// En supabase_group_service.dart — fetchSharedBooksForGroup
'select': 'id,group_id,book_uuid,owner_id,title,author,isbn,cover_url,is_read,'
          'visibility,is_available,created_at,updated_at,page_count,publication_year,'
          // ❌ Falta is_deleted
          'loans(...)',
```

### Fix

Añadir `is_deleted` al select:

```dart
// ✅ CÓDIGO CORRECTO en supabase_group_service.dart
Future<List<SupabaseSharedBookRecord>> fetchSharedBooksForGroup({...}) async {
  // ...
  final uri = Uri.parse('${config.url}/rest/v1/shared_books').replace(
    queryParameters: {
      'select': 'id,group_id,book_uuid,owner_id,title,author,isbn,cover_url,is_read,'
                'visibility,is_available,is_deleted,' // ✅ AÑADIDO
                'created_at,updated_at,page_count,publication_year,'
                'loans(id,shared_book_id,borrower_user_id,lender_user_id,status,'
                'requested_at,approved_at,due_date,borrower_returned_at,'
                'lender_returned_at,returned_at,is_deleted,created_at,updated_at,'
                'borrower:profiles!borrower_user_id(username),'
                'lender:profiles!lender_user_id(username))',
      'group_id': 'eq.$groupId',
      'order': 'created_at.desc',
    },
  );
  // ...
}
```

---

## 17. Bug #14 — Sin resolución real de conflictos (IMPORTANTE)

### Archivos afectados
Todos los repositorios de sync (`supabase_book_sync_repository.dart`, `supabase_group_repository.dart`, etc.)

### Descripción del problema

El sistema actual usa una lógica binaria: si `isDirty: true` gana el local, si `isDirty: false` gana el remoto. No se compara `updatedAt` entre la versión local y la remota. Esto causa pérdida silenciosa de cambios en este escenario:

1. Usuario A edita libro en dispositivo 1 → `isDirty: true`
2. Sync exitoso → `isDirty: false`, `syncedAt` actualizado
3. Usuario A edita el mismo libro en dispositivo 2 → servidor tiene versión más nueva
4. Sync en dispositivo 1 → como `isDirty: false`, el remoto sobreescribe sin comparar fechas

### Fix

Añadir comparación de `updatedAt` antes de decidir qué versión usar:

```dart
// ✅ CÓDIGO CORRECTO — en syncFromRemote, al actualizar libros existentes
if (existing != null) {
  if (existing.isDirty) {
    // Local tiene cambios pendientes de subir: preservar local
    await _bookDao.updateBookFields(
      bookId: existing.id,
      entry: BooksCompanion(
        remoteId: existing.remoteId == null ? Value(remote.id) : const Value<String?>.absent(),
        syncedAt: Value(now),
      ),
    );
    developer.log('Preservando libro ${existing.title}: cambios locales pendientes.');
    continue;
  }

  // ✅ NUEVO: Comparar updatedAt para decidir qué versión usar
  final remoteUpdatedAt = remote.updatedAt ?? remote.createdAt;
  final localUpdatedAt = existing.updatedAt;

  if (localUpdatedAt != null && localUpdatedAt.isAfter(remoteUpdatedAt)) {
    // El local es más nuevo (edge case: sincronización parcial previa)
    developer.log(
      'Libro ${existing.title}: versión local (${localUpdatedAt}) más nueva que remota (${remoteUpdatedAt}). '
      'Marcando como dirty para subir en el próximo push.',
    );
    await _bookDao.updateBookFields(
      bookId: existing.id,
      entry: BooksCompanion(
        remoteId: Value(remote.id),
        isDirty: const Value(true), // Forzar resubida
      ),
    );
    continue;
  }

  // El remoto es igual o más nuevo: actualizar local con versión remota
  await _bookDao.updateBookFields(
    bookId: existing.id,
    entry: BooksCompanion(
      // ... todos los campos del remoto ...
      isDirty: const Value(false),
      syncedAt: Value(now),
    ),
  );
}
```

> **Nota:** Aplicar el mismo patrón en `supabase_group_repository.dart` para `SharedBooks` y `Loans`.

---

## 18. Bug #15 — syncNow no es idempotente bajo concurrencia (IMPORTANTE)

### Archivo afectado
`lib/services/unified_sync_coordinator.dart`

### Descripción del problema

Ya documentado en el Bug #7. El fix del guard de concurrencia está incluido allí. Este punto añade la recomendación de usar un `Mutex` para casos más complejos.

### Fix adicional recomendado

Si la app puede tener múltiples sync en background, usar el paquete `synchronized`:

```yaml
# pubspec.yaml
dependencies:
  synchronized: ^3.1.0
```

```dart
// En UnifiedSyncCoordinator
import 'package:synchronized/synchronized.dart';

class UnifiedSyncCoordinator {
  final _syncLock = Lock(); // ← Mutex real

  Future<void> syncNow({List<SyncEntity>? entities}) async {
    if (!_state.isConnected && SyncConfig.pauseOnNoConnection) return;

    // ✅ Lock que espera si hay otro sync en curso (en lugar de ignorar)
    await _syncLock.synchronized(() async {
      _updateState(_state.copyWith(isSyncing: true));
      try {
        // ... lógica de sync ...
      } finally {
        _updateState(_state.copyWith(isSyncing: false));
      }
    });
  }
}
```

> Si prefieres no añadir dependencia, el bool `_isSyncing` del Bug #7 es suficiente para la mayoría de casos.

---

## 19. Orden de implementación recomendado

Implementar en este orden exacto para minimizar riesgos y poder probar incrementalmente:

### Semana 1 — Base y bugs críticos de datos

| Orden | Bug | Esfuerzo estimado | Riesgo |
|-------|-----|-------------------|--------|
| 1 | Crear tabla `sync_cursors` + `SyncCursorDao` | 2h | Bajo (solo añade tabla) |
| 2 | Bug #5: Loan sync respeta isDirty | 1h | Bajo |
| 3 | Bug #6: Guards en loan push | 1h | Bajo |
| 4 | Bug #1: Cursor de timestamp correcto | 3h | Medio (requiere migración) |
| 5 | Bug #2: Timeline entries con isDirty=false | 30min | Bajo |

### Semana 2 — Funcionalidad rota y estabilidad

| Orden | Bug | Esfuerzo estimado | Riesgo |
|-------|-----|-------------------|--------|
| 6 | Bug #4: Club books se sincronizan hacia abajo | 2h | Medio |
| 7 | Bug #7: Guard de concurrencia en syncNow | 1h | Bajo |
| 8 | Bug #8: rethrow → continue en club book sync | 30min | Bajo |
| 9 | Bug #9: Guard contra borrado masivo | 30min | Bajo |
| 10 | Bug #12: Clubs guardan remoteId | 30min | Bajo |

### Semana 3 — Robustez y correctness

| Orden | Bug | Esfuerzo estimado | Riesgo |
|-------|-----|-------------------|--------|
| 11 | Bug #3: Upsert en lugar de create para libros | 2h | Medio |
| 12 | Bug #10: Fetches en paralelo + resilientes | 1h | Bajo |
| 13 | Bug #14: Resolución de conflictos por updatedAt | 3h | Alto (cambio de comportamiento) |
| 14 | Bug #11: Interpolación en logs | 15min | Nulo |
| 15 | Bug #13: is_deleted en fallback de grupos | 15min | Nulo |

---

## 20. Tests mínimos a añadir

Para verificar que los fixes funcionan sin regressions, añadir estos tests:

### Test 1: Cursor de timestamp (Bug #1)

```dart
test('syncFromRemote actualiza cursor con MAX(updatedAt) de los registros recibidos', () async {
  // Arrange
  final fakeBooks = [
    SupabaseBookRecord(id: '1', updatedAt: DateTime(2024, 1, 10), /* ... */),
    SupabaseBookRecord(id: '2', updatedAt: DateTime(2024, 1, 15), /* ... */),
    SupabaseBookRecord(id: '3', updatedAt: DateTime(2024, 1, 5),  /* ... */),
  ];
  when(mockService.fetchBooks(any)).thenAnswer((_) async => fakeBooks);

  // Act
  await repository.syncFromRemote(owner: testOwner);

  // Assert
  final cursor = await syncCursorDao.getCursor('books');
  expect(cursor, equals(DateTime(2024, 1, 15))); // MAX de los tres
});
```

### Test 2: isDirty preserva cambios locales en loan sync (Bug #5)

```dart
test('_pullRemoteChanges no sobreescribe loans con isDirty=true', () async {
  // Arrange: insertar loan local dirty
  final localLoan = await db.into(db.loans).insert(
    LoansCompanion.insert(uuid: 'loan-1', status: Value('local_change'), isDirty: const Value(true), /* ... */),
  );

  // Simular que el servidor tiene una versión diferente
  when(mockApi.fetchUserLoans(userId: any)).thenAnswer((_) async => [
    {'uuid': 'loan-1', 'status': 'remote_change', /* ... */}
  ]);

  // Act
  await repository.syncLoans('user-1');

  // Assert: el status local se preservó
  final loan = await (db.select(db.loans)..where((l) => l.uuid.equals('loan-1'))).getSingleOrNull();
  expect(loan?.status, equals('local_change')); // No fue sobreescrito
  expect(loan?.isDirty, isTrue);
});
```

### Test 3: Club books se insertan al bajar (Bug #4)

```dart
test('syncFromRemote inserta club_books de la respuesta remota', () async {
  // Arrange
  final remoteClub = SupabaseClubRecord(
    id: 'club-1',
    books: [
      SupabaseClubBookRecord(id: 'book-1', bookUuid: 'uuid-1', /* ... */),
    ],
    /* ... */
  );
  when(mockService.fetchClubs()).thenAnswer((_) async => [remoteClub]);

  // Act
  await repository.syncFromRemote();

  // Assert
  final clubBook = await clubDao.getClubBookByRemoteId('book-1');
  expect(clubBook, isNotNull);
  expect(clubBook?.isDirty, isFalse);
});
```

### Test 4: Guard de concurrencia (Bug #15)

```dart
test('syncNow ignora llamadas concurrentes', () async {
  var syncCount = 0;
  when(mockUserController.sync()).thenAnswer((_) async {
    syncCount++;
    await Future.delayed(const Duration(milliseconds: 100));
  });

  // Lanzar dos syncs simultáneos
  await Future.wait([
    coordinator.syncNow(),
    coordinator.syncNow(), // ← Este debe ser ignorado
  ]);

  // Solo uno debe haberse ejecutado
  expect(syncCount, equals(1));
});
```

---

## Apéndice: Checklist de verificación

Usar este checklist al finalizar cada bug:

- [ ] **Bug #1** — `sync_cursors` table creada y migración añadida
- [ ] **Bug #1** — `SyncCursorDao` implementado con `getCursor`/`updateCursor`/`resetCursor`
- [ ] **Bug #1** — `SupabaseBookSyncRepository` usa cursores en lugar de `syncedAt`
- [ ] **Bug #1** — Actualiza cursores al final de cada transacción exitosa
- [ ] **Bug #2** — Inserción de timeline entries incluye `isDirty: false` y `syncedAt`
- [ ] **Bug #3** — `createBook` usa upsert o verifica existencia previa
- [ ] **Bug #4** — Loop de `remote.books` añadido en `SupabaseClubSyncRepository`
- [ ] **Bug #5** — `_pullRemoteChanges` verifica `isDirty` antes de sobreescribir
- [ ] **Bug #6** — Guards de `sharedBookId`, `bookUuid` y `lenderId` añadidos
- [ ] **Bug #7** — Guard `_isSyncing` en `syncNow`
- [ ] **Bug #7** — Orden de sync separado en fases (down-groups → books → up-groups → loans)
- [ ] **Bug #8** — `rethrow` reemplazado por logging en todos los loops de club book sync
- [ ] **Bug #9** — Guard contra `remoteSharedIds.isEmpty` antes de reconciliación
- [ ] **Bug #10** — Fetches en paralelo con `Future.wait` y manejo de errores individuales
- [ ] **Bug #11** — Interpolaciones de string corregidas con `${}`
- [ ] **Bug #12** — `markClubSynced` actualiza `remoteId` con el valor real devuelto
- [ ] **Bug #13** — `is_deleted` añadido al select del fallback de grupos
- [ ] **Bug #14** — Comparación de `updatedAt` añadida en resolución de conflictos
- [ ] **Bug #15** — Concurrencia manejada con Lock o bool guard
- [ ] Tests añadidos para bugs #1, #5, #4, #15 mínimo
- [ ] Probar sync completo con dos dispositivos simultáneos
- [ ] Probar sync con conexión intermitente (avión mode on/off)
- [ ] Probar logout/login limpia cursores (`syncCursorDao.resetAllCursors()`)

---

*Fin del informe. Versión 1.0 — Febrero 2026*
