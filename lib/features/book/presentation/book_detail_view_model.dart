import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../books/data/repositories/supabase_author_repository.dart';
import '../../books/data/repositories/supabase_book_repository.dart';
import '../../reservation/data/repositories/reservation_repository.dart';

/// View model state for Book Detail + Copy management.
class BookDetailState {
  const BookDetailState({
    required this.bookTitle,
    required this.copies,
    required this.authors,
    required this.availableCopiesCount,
    required this.hasActiveReservation,
  });

  final SupabaseBookTitle bookTitle;
  final List<SupabaseBookCopy> copies;
  final List<SupabaseAuthor> authors;

  /// Number of available (not borrowed) copies.
  final int availableCopiesCount;

  /// Whether someone has already reserved this book.
  final bool hasActiveReservation;

  // Helper getters
  String get authorName {
    if (authors.isEmpty) return 'Chưa có tác giả';
    return authors.map((a) => a.fullName).join(', ');
  }

  String get categoryName => bookTitle.categoryName ?? 'Chưa phân loại';
  String get publisherName => bookTitle.publisherName ?? 'Chưa có NXB';
}

class BookDetailViewModel
    extends AutoDisposeFamilyAsyncNotifier<BookDetailState, String> {
  String? _bookId;

  @override
  Future<BookDetailState> build(String arg) async {
    _bookId = arg;

    final bookRepo = ref.watch(supabaseBookRepositoryProvider);
    final authorRepo = ref.watch(supabaseAuthorRepositoryProvider);

    // Lấy thông tin đầu sách
    final bookTitle = await bookRepo.getBookTitleById(arg);
    if (bookTitle == null) {
      throw StateError('Không tìm thấy sách $arg');
    }

    // Lấy danh sách bản sao
    final copies = await bookRepo.getBookCopies(arg);

    // Lấy danh sách tác giả
    final authors = await authorRepo.getAuthorsOfBook(arg);

    // Đếm số bản sao sẵn sàng
    final availableCopiesCount = copies.where((c) => c.isAvailable).length;

    // Kiểm tra đặt trước (vẫn dùng local nếu cần, hoặc có thể cập nhật sau)
    bool hasActiveReservation = false;
    try {
      final reservationRepo = ref.watch(reservationRepositoryProvider);
      final reservationCount =
          await reservationRepo.countActiveReservationsForBook(arg);
      hasActiveReservation = reservationCount > 0;
    } catch (_) {
      // Nếu lỗi thì bỏ qua
    }

    return BookDetailState(
      bookTitle: bookTitle,
      copies: copies,
      authors: authors,
      availableCopiesCount: availableCopiesCount,
      hasActiveReservation: hasActiveReservation,
    );
  }

  /// Add a new copy with auto-generated barcode.
  Future<void> addBookCopy() async {
    final bookId = _bookId;
    if (bookId == null) {
      throw StateError('BookDetailViewModel chưa được khởi tạo bookId.');
    }

    final bookRepo = ref.read(supabaseBookRepositoryProvider);

    // Lấy các bản sao hiện có để tạo barcode mới
    final existing = await bookRepo.getBookCopies(bookId);
    final nextBarcode = _generateNextBarcode(bookId, existing);

    await bookRepo.addBookCopy(
      barcode: nextBarcode,
      bookTitleId: bookId,
      status: 0, // Sẵn sàng
      condition: 'Tốt',
    );

    // Refresh screen.
    ref.invalidateSelf();
    await future;
  }

  Future<void> deleteCopy(String copyBarcode) async {
    final bookRepo = ref.read(supabaseBookRepositoryProvider);
    await bookRepo.deleteBookCopy(copyBarcode);

    ref.invalidateSelf();
    await future;
  }

  Future<void> deleteBook() async {
    final bookId = _bookId;
    if (bookId == null) {
      throw StateError('BookDetailViewModel chưa được khởi tạo bookId.');
    }

    final bookRepo = ref.read(supabaseBookRepositoryProvider);
    await bookRepo.deleteBookTitle(bookId);
  }

  /// Create a reservation for this book.
  Future<void> createReservation(String memberId) async {
    final bookId = _bookId;
    if (bookId == null) {
      throw StateError('BookDetailViewModel chưa được khởi tạo bookId.');
    }

    final reservationRepo = ref.read(reservationRepositoryProvider);
    await reservationRepo.createReservation(
      bookId: bookId,
      memberId: memberId,
    );

    // Refresh screen.
    ref.invalidateSelf();
    await future;
  }

  String _generateNextBarcode(String bookId, List<SupabaseBookCopy> existing) {
    var maxNum = 0;
    for (final c in existing) {
      final barcode = c.barcode.trim();
      if (!barcode.startsWith('$bookId-')) continue;
      final suffix = barcode.substring(bookId.length + 1);
      final n = int.tryParse(suffix);
      if (n == null) continue;
      if (n > maxNum) maxNum = n;
    }
    final next = maxNum + 1;
    return '$bookId-${next.toString().padLeft(3, '0')}';
  }
}

final bookDetailViewModelProvider = AutoDisposeAsyncNotifierProviderFamily<
    BookDetailViewModel, BookDetailState, String>(BookDetailViewModel.new);
