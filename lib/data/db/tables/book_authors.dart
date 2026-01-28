import 'package:drift/drift.dart';

import 'authors.dart';
import 'books.dart';

/// SQL: CHI_TIET_TAC_GIA (N-N between Books and Authors)
class BookAuthors extends Table {
  @override
  String get tableName => 'book_authors';

  TextColumn get bookId => text().references(Books, #id)();
  IntColumn get authorId => integer().references(Authors, #id)();
  TextColumn get role => text().nullable().withLength(min: 0, max: 50)();

  @override
  Set<Column> get primaryKey => {bookId, authorId};
}
