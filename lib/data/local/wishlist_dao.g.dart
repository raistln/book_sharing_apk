// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wishlist_dao.dart';

// ignore_for_file: type=lint
mixin _$WishlistDaoMixin on DatabaseAccessor<AppDatabase> {
  $LocalUsersTable get localUsers => attachedDatabase.localUsers;
  $WishlistItemsTable get wishlistItems => attachedDatabase.wishlistItems;
  WishlistDaoManager get managers => WishlistDaoManager(this);
}

class WishlistDaoManager {
  final _$WishlistDaoMixin _db;
  WishlistDaoManager(this._db);
  $$LocalUsersTableTableManager get localUsers =>
      $$LocalUsersTableTableManager(_db.attachedDatabase, _db.localUsers);
  $$WishlistItemsTableTableManager get wishlistItems =>
      $$WishlistItemsTableTableManager(_db.attachedDatabase, _db.wishlistItems);
}
