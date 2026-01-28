import 'package:drift/drift.dart';

import 'books.dart';

// Drift table: BookCopies

class BookCopies extends Table {
  @override
  String get tableName => 'book_copies';

  /// Barcode / MaVach
  TextColumn get id => text().withLength(min: 1, max: 20)();

  TextColumn get location => text().nullable().withLength(min: 0, max: 50)();

  /// Physical condition (TinhTrang)
  TextColumn get condition => text().nullable().withLength(min: 0, max: 50)();

  /// Tinyint status from SQL (TrangThai). Map to enum later.
  IntColumn get status => integer().nullable()();

  TextColumn get bookId => text().references(Books, #id)();

  @override
  Set<Column> get primaryKey => {id};
}
