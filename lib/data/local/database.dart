import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

class Books extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get title => text().withLength(min: 1, max: 255)();
  TextColumn get author => text().withLength(min: 1, max: 255).nullable()();
  TextColumn get isbn => text().withLength(min: 10, max: 20).nullable()();
  TextColumn get barcode => text().withLength(min: 1, max: 64).nullable()();

  TextColumn get coverPath => text().nullable()();

  TextColumn get status => text().withDefault(const Constant('available'))();
  TextColumn get notes => text().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class BookReviews extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get bookId => integer().references(Books, #id, onDelete: KeyAction.cascade)();

  IntColumn get rating =>
      integer().customConstraint('NOT NULL CHECK (rating BETWEEN 1 AND 5)')();
  TextColumn get review => text().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [Books, BookReviews])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.test(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        beforeOpen: (details) async {
          if (details.wasCreated) {
            await customStatement('PRAGMA foreign_keys = ON');
          }
        },
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
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
