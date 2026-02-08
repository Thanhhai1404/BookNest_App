import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../books/data/repositories/supabase_book_repository.dart';

/// Filter options for book availability
enum BookAvailabilityFilter {
  all, // Tất cả
  available, // Sẵn sàng (có ít nhất 1 bản sao Available)
  outOfStock, // Hết hàng (không có bản sao Available nào)
}

/// State for book list with search and filter
class BookListState {
  const BookListState({
    required this.books,
    required this.query,
    required this.debouncedQuery,
    required this.filter,
    required this.isLoading,
    this.error,
  });

  final List<SupabaseBookTitle> books;
  final String query;
  final String debouncedQuery;
  final BookAvailabilityFilter filter;
  final bool isLoading;
  final String? error;

  BookListState copyWith({
    List<SupabaseBookTitle>? books,
    String? query,
    String? debouncedQuery,
    BookAvailabilityFilter? filter,
    bool? isLoading,
    String? error,
  }) {
    return BookListState(
      books: books ?? this.books,
      query: query ?? this.query,
      debouncedQuery: debouncedQuery ?? this.debouncedQuery,
      filter: filter ?? this.filter,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  static const initial = BookListState(
    books: [],
    query: '',
    debouncedQuery: '',
    filter: BookAvailabilityFilter.all,
    isLoading: true,
  );
}

/// Loads list of books for the Book Management feature with search & filter.
class BookListViewModel extends Notifier<BookListState> {
  Timer? _debounceTimer;

  @override
  BookListState build() {
    // Initial load
    _loadBooks();
    return BookListState.initial;
  }

  Future<void> _loadBooks() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final repo = ref.read(supabaseBookRepositoryProvider);
      List<SupabaseBookTitle> books;

      // Tìm kiếm hoặc lấy tất cả
      if (state.debouncedQuery.isNotEmpty) {
        books = await repo.searchBookTitles(state.debouncedQuery);
      } else {
        books = await repo.getBookTitles();
      }

      // Áp dụng filter theo availability
      if (state.filter != BookAvailabilityFilter.all) {
        books = books.where((book) {
          if (state.filter == BookAvailabilityFilter.available) {
            return book.totalCopies > 0;
          } else {
            // outOfStock
            return book.totalCopies == 0;
          }
        }).toList();
      }

      state = state.copyWith(books: books, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        books: [],
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void setQuery(String value) {
    state = state.copyWith(query: value);

    // Cancel previous timer
    _debounceTimer?.cancel();

    // Debounce 500ms before updating debouncedQuery and loading
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      state = state.copyWith(debouncedQuery: value);
      _loadBooks();
    });
  }

  void clearQuery() {
    _debounceTimer?.cancel();
    state = state.copyWith(query: '', debouncedQuery: '');
    _loadBooks();
  }

  /// Set query and search immediately (no debounce) - used for scanner results
  void setQueryImmediate(String value) {
    _debounceTimer?.cancel();
    state = state.copyWith(query: value, debouncedQuery: value);
    _loadBooks();
  }

  void setFilter(BookAvailabilityFilter filter) {
    state = state.copyWith(filter: filter);
    _loadBooks();
  }

  Future<void> refresh() async {
    await _loadBooks();
  }
}

final bookListViewModelProvider =
    NotifierProvider<BookListViewModel, BookListState>(
  BookListViewModel.new,
);
