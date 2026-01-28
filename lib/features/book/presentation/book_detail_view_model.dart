import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/enums.dart';
import '../../../data/db/app_database.dart';
import '../data/repositories/book_repository.dart';

/// View model state for Book Detail + Copy management.
class BookDetailState {
  const BookDetailState({
    required this.book,
    required this.copies,
    required this.authorName,
    required this.categoryName,
    required this.publisherName,
  });

  final Book book;
  final List<BookCopy> copies;

  // Display fields (because current repo returns DTO for list queries).
  final String authorName;
  final String categoryName;
  final String publisherName;
}

class BookDetailViewModel
    extends AutoDisposeFamilyAsyncNotifier<BookDetailState, String> {
  String? _bookId;

  @override
  Future<BookDetailState> build(String arg) async {
    _bookId = arg;

    final repo = ref.watch(bookRepositoryProvider);
    final dto = await repo.getBookById(arg);
    if (dto == null) {
      throw StateError('Không tìm thấy sách $arg');
    }

    final db = ref.watch(databaseProvider);
    final copies = await (db.select(db.bookCopies)
          ..where((c) => c.bookId.equals(arg))
          ..orderBy([(c) => drift.OrderingTerm(expression: c.id)]))
        .get();

    return BookDetailState(
      book: dto.book,
      copies: copies,
      authorName: dto.authorName,
      categoryName: dto.categoryName,
      publisherName: dto.publisherName,
    );
  }

  /// Add a new copy with auto-generated barcode.
  ///
  /// Barcode rule: <bookId>-NN (NN is 2 digits).
  /// Example: BK001 -> BK001-01, BK001-02...
  Future<void> addBookCopy() async {
    final bookId = _bookId;
    if (bookId == null) {
      throw StateError('BookDetailViewModel chưa được khởi tạo bookId.');
    }

    final db = ref.read(databaseProvider);

    // Load current copies fresh to avoid stale state.
    final existing = await (db.select(db.bookCopies)
          ..where((c) => c.bookId.equals(bookId)))
        .get();

    final nextBarcode = _generateNextBarcode(bookId, existing);

    await db.into(db.bookCopies).insert(
          BookCopiesCompanion.insert(
            id: nextBarcode,
            bookId: bookId,
            status: drift.Value(BookStatus.available.code),
            location: const drift.Value.absent(),
            condition: const drift.Value.absent(),
          ),
        );

    // Refresh screen.
    ref.invalidateSelf();
    await future;
  }

  Future<void> deleteCopy(String copyId) async {
    final repo = ref.read(bookRepositoryProvider);
    await repo.deleteBookCopy(copyId);

    ref.invalidateSelf();
    await future;
  }

  Future<void> deleteBook() async {
    final bookId = _bookId;
    if (bookId == null) {
      throw StateError('BookDetailViewModel chưa được khởi tạo bookId.');
    }

    final repo = ref.read(bookRepositoryProvider);
    await repo.deleteBook(bookId);
  }

  String _generateNextBarcode(String bookId, List<BookCopy> existing) {
    var maxNum = 0;
    for (final c in existing) {
      final id = c.id.trim();
      if (!id.startsWith('$bookId-')) continue;
      final suffix = id.substring(bookId.length + 1);
      final n = int.tryParse(suffix);
      if (n == null) continue;
      if (n > maxNum) maxNum = n;
    }
    final next = maxNum + 1;
    return '$bookId-${next.toString().padLeft(2, '0')}';
  }
}

final bookDetailViewModelProvider = AutoDisposeAsyncNotifierProviderFamily<
    BookDetailViewModel, BookDetailState, String>(BookDetailViewModel.new);
