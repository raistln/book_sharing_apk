import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';
import '../local/database.dart';
import '../local/wishlist_dao.dart';
import '../../models/global_sync_state.dart';
import '../../services/unified_sync_coordinator.dart';

class WishlistRepository {
  final WishlistDao _dao;
  final Uuid _uuid;
  final UnifiedSyncCoordinator? syncCoordinator;

  WishlistRepository(this._dao, {Uuid? uuid, this.syncCoordinator})
      : _uuid = uuid ?? const Uuid();

  Stream<List<WishlistItem>> watchWishlist(int userId) =>
      _dao.watchForUser(userId);

  Future<void> addItem({
    required int userId,
    required String title,
    String? author,
    String? isbn,
    String? notes,
  }) async {
    final companion = WishlistItemsCompanion.insert(
      uuid: _uuid.v4(),
      userId: userId,
      title: title,
      author: Value(author),
      isbn: Value(isbn),
      notes: Value(notes),
      isDirty: const Value(true),
    );
    await _dao.insertItem(companion);
    syncCoordinator?.markPendingChanges(SyncEntity.books);
  }

  Future<void> removeItem(int id) async {
    await _dao.deleteItem(id);
    syncCoordinator?.markPendingChanges(SyncEntity.books);
  }
}
