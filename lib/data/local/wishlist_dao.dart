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
}
