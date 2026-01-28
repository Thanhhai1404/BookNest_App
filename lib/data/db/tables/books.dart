import 'package:drift/drift.dart';

import 'categories.dart';
import 'publishers.dart';

// Drift table: Books

class Books extends Table {
  @override
  String get tableName => 'books';

  TextColumn get id => text().withLength(min: 1, max: 10)();

  TextColumn get title => text().nullable().withLength(min: 0, max: 200)();

  /// Year of publish.
  IntColumn get publishedYear => integer().nullable()();

  /// Cover price in VND.
  IntColumn get coverPrice => integer().nullable()();

  IntColumn get totalQuantity => integer().nullable()();
  TextColumn get description => text().nullable().withLength(min: 0, max: 200)();

  /// From SQL: THE_LOAI (MaTL).
  IntColumn get categoryId => integer().references(Categories, #id)();

  /// From SQL: NHA_XUAT_BAN (MaNXB).
  IntColumn get publisherId => integer().references(Publishers, #id)();

  /// Added in roadmap: path to cover image on device.
  TextColumn get coverPath => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [];
}
