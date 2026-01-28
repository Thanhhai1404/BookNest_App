import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/db/app_database.dart';
import '../../domain/models/book_with_details.dart';

class BookRepository {
  BookRepository(this.db);

  final AppDatabase db;

  /// Returns all books along with author/category/publisher names.
  ///
  /// Note: Books->Authors is N-N via `BookAuthors`. For UI dropdown / display,
  /// this method returns the first author (by authorId asc) if multiple exist.
  Future<List<BookWithDetails>> getBooks() async {
    final b = db.books;
    final ba = db.bookAuthors;
    final a = db.authors;
    final c = db.categories;
    final p = db.publishers;

    final query = db.select(b).join([
      drift.leftOuterJoin(ba, ba.bookId.equalsExp(b.id)),
      drift.leftOuterJoin(a, a.id.equalsExp(ba.authorId)),
      drift.leftOuterJoin(c, c.id.equalsExp(b.categoryId)),
      drift.leftOuterJoin(p, p.id.equalsExp(b.publisherId)),
    ]);

    query.orderBy([
      drift.OrderingTerm(expression: b.id),
      drift.OrderingTerm(expression: ba.authorId),
    ]);

    final rows = await query.get();

    // Because of N-N author relation, join can produce multiple rows per book.
    // We keep only the first seen author row for each book.
    final map = <String, BookWithDetails>{};
    for (final row in rows) {
      final bookRow = row.readTable(b);

      if (map.containsKey(bookRow.id)) {
        continue;
      }

      final authorRow = row.readTableOrNull(a);
      final categoryRow = row.readTableOrNull(c);
      final publisherRow = row.readTableOrNull(p);

      final authorName = _formatAuthorName(authorRow);

      map[bookRow.id] = BookWithDetails(
        book: bookRow,
        authorName: authorName,
        categoryName: categoryRow?.name ?? '',
        publisherName: publisherRow?.name ?? '',
      );
    }

    return map.values.toList();
  }

  Future<BookWithDetails?> getBookById(String id) async {
    final b = db.books;
    final ba = db.bookAuthors;
    final a = db.authors;
    final c = db.categories;
    final p = db.publishers;

    final query = db.select(b).join([
      drift.leftOuterJoin(ba, ba.bookId.equalsExp(b.id)),
      drift.leftOuterJoin(a, a.id.equalsExp(ba.authorId)),
      drift.leftOuterJoin(c, c.id.equalsExp(b.categoryId)),
      drift.leftOuterJoin(p, p.id.equalsExp(b.publisherId)),
    ]);

    query.where(b.id.equals(id));
    query.orderBy([drift.OrderingTerm(expression: ba.authorId)]);
    query.limit(1);

    final row = await query.getSingleOrNull();
    if (row == null) return null;

    final bookRow = row.readTable(b);
    final authorRow = row.readTableOrNull(a);
    final categoryRow = row.readTableOrNull(c);
    final publisherRow = row.readTableOrNull(p);

    return BookWithDetails(
      book: bookRow,
      authorName: _formatAuthorName(authorRow),
      categoryName: categoryRow?.name ?? '',
      publisherName: publisherRow?.name ?? '',
    );
  }

  Future<int> addBook(BooksCompanion book) {
    return db.into(db.books).insert(book);
  }

  Future<bool> updateBook(BooksCompanion book) {
    return db.update(db.books).replace(book);
  }

  Future<int> deleteBook(String id) {
    return (db.delete(db.books)..where((b) => b.id.equals(id))).go();
  }

  String _formatAuthorName(Author? author) {
    if (author == null) return '';
    final parts = <String>[];
    for (final p in [author.lastName, author.middleName, author.firstName]) {
      final v = (p ?? '').trim();
      if (v.isNotEmpty) parts.add(v);
    }
    return parts.join(' ');
  }
}

final bookRepositoryProvider = Provider<BookRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return BookRepository(db);
});
