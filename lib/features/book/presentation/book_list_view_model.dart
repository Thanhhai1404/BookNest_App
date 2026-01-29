import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/book_repository.dart';
import '../domain/models/book_with_details.dart';

/// State for book list with search and filter
class BookListState {
  const BookListState({
    required this.books,
    required this.query,
    required this.debouncedQuery,
    required this.filter,
    required this.isLoading,
  });

  final List<BookWithDetails> books;
  final String query;
  final String debouncedQuery;
  final BookAvailabilityFilter filter;
  final bool isLoading;

  BookListState copyWith({
    List<BookWithDetails>? books,
    String? query,
    String? debouncedQuery,
    BookAvailabilityFilter? filter,
    bool? isLoading,
  }) {
    return BookListState(
      books: books ?? this.books,
      query: query ?? this.query,
      debouncedQuery: debouncedQuery ?? this.debouncedQuery,
      filter: filter ?? this.filter,
      isLoading: isLoading ?? this.isLoading,
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
    state = state.copyWith(isLoading: true);

    try {
      final repo = ref.read(bookRepositoryProvider);
      final books = await repo.searchBooks(
        query: state.debouncedQuery.isEmpty ? null : state.debouncedQuery,
        filter: state.filter,
      );
      state = state.copyWith(books: books, isLoading: false);
    } catch (e) {
      state = state.copyWith(books: [], isLoading: false);
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
