import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

class LocalUsers extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get uuid => text().withLength(min: 1, max: 36).unique()();
  TextColumn get username => text().withLength(min: 3, max: 64).unique()();
  TextColumn get remoteId => text().nullable()();

  BoolColumn get isDirty => boolean().withDefault(const Constant(true))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class Books extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get uuid => text().withLength(min: 1, max: 36).unique()();
  TextColumn get remoteId => text().nullable()();

  IntColumn get ownerUserId => integer().references(LocalUsers, #id).nullable()();
  TextColumn get ownerRemoteId => text().nullable()();

  TextColumn get title => text().withLength(min: 1, max: 255)();
  TextColumn get author => text().withLength(min: 1, max: 255).nullable()();
  TextColumn get isbn => text().withLength(min: 10, max: 20).nullable()();
  TextColumn get barcode => text().withLength(min: 1, max: 64).nullable()();

  TextColumn get coverPath => text().nullable()();

  TextColumn get status => text().withDefault(const Constant('available'))();
  TextColumn get notes => text().nullable()();

  BoolColumn get isDirty => boolean().withDefault(const Constant(true))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class BookReviews extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get uuid => text().withLength(min: 1, max: 36).unique()();
  TextColumn get remoteId => text().nullable()();

  IntColumn get bookId =>
      integer().references(Books, #id, onDelete: KeyAction.cascade)();
  TextColumn get bookUuid => text().withLength(min: 1, max: 36)();

  IntColumn get authorUserId => integer().references(LocalUsers, #id)();
  TextColumn get authorRemoteId => text().nullable()();

  IntColumn get rating =>
      integer().customConstraint('NOT NULL CHECK (rating BETWEEN 1 AND 5)')();
  TextColumn get review => text().nullable()();

  BoolColumn get isDirty => boolean().withDefault(const Constant(true))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column<Object>>>? get uniqueKeys => [
        {bookId, authorUserId},
      ];
}

@DriftDatabase(tables: [LocalUsers, Books, BookReviews])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.test(super.executor);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 3) {
            await customStatement('DROP TABLE IF EXISTS book_reviews');
            await customStatement('DROP TABLE IF EXISTS books');

            await m.createTable(localUsers);
            await m.createTable(books);
            await m.createTable(bookReviews);
          } else if (from < 4) {
            await customStatement('DROP TABLE IF EXISTS book_reviews');
            await m.createTable(bookReviews);
          }
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final dbFile = File(p.join(dir.path, 'book_sharing.sqlite'));
    return NativeDatabase.createInBackground(dbFile);
  });
}
