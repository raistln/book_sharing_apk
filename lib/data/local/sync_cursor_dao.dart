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
  Future<void> updateCursor(
      String entity, DateTime? lastRemoteUpdatedAt) async {
    if (lastRemoteUpdatedAt == null) return;

    // We use insertOnConflictUpdate to ensure we always have the latest cursor for the entity
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
    await (delete(syncCursors)..where((t) => t.entity.equals(entity))).go();
  }

  /// Resetea todos los cursores (útil al cambiar de usuario o en logout).
  Future<void> resetAllCursors() async {
    await delete(syncCursors).go();
  }
}
