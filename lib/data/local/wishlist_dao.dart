import 'package:drift/drift.dart';
import 'database.dart';

part 'wishlist_dao.g.dart';

@DriftAccessor(tables: [WishlistItems])
class WishlistDao extends DatabaseAccessor<AppDatabase>
    with _$WishlistDaoMixin {
  WishlistDao(super.db);

  Stream<List<WishlistItem>> watchForUser(int userId) {
    return (select(wishlistItems)
          ..where((t) => t.userId.equals(userId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  Future<int> insertItem(WishlistItemsCompanion item) =>
      into(wishlistItems).insert(item);

  Future<bool> deleteItem(int id) =>
      (delete(wishlistItems)..where((t) => t.id.equals(id)))
          .go()
          .then((count) => count > 0);

  Future<List<WishlistItem>> getAllForUser(int userId) {
    return (select(wishlistItems)..where((t) => t.userId.equals(userId))).get();
  }

  Future<List<WishlistItem>> getDirtyItems() {
    return (select(wishlistItems)..where((t) => t.isDirty.equals(true))).get();
  }

  Future<WishlistItem?> findByRemoteId(String remoteId) {
    return (select(wishlistItems)..where((t) => t.remoteId.equals(remoteId)))
        .getSingleOrNull();
  }

  Future<WishlistItem?> findByUuid(String uuid) {
    return (select(wishlistItems)..where((t) => t.uuid.equals(uuid)))
        .getSingleOrNull();
  }

  Future<bool> updateItemFields(
      int itemId, WishlistItemsCompanion entry) async {
    final rows = await (update(wishlistItems)
          ..where((t) => t.id.equals(itemId)))
        .write(entry);
    return rows > 0;
  }
}
