import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';
import '../local/database.dart';
import '../local/wishlist_dao.dart';

class WishlistRepository {
  final WishlistDao _dao;
  final _uuid = const Uuid();

  WishlistRepository(this._dao);

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
    );
    await _dao.insertItem(companion);
  }

  Future<void> removeItem(int id) => _dao.deleteItem(id);
}
