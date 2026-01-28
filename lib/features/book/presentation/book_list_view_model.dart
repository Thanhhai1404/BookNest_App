import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/book_repository.dart';
import '../domain/models/book_with_details.dart';

/// Loads list of books for the Book Management feature.
class BookListViewModel extends AsyncNotifier<List<BookWithDetails>> {
  @override
  Future<List<BookWithDetails>> build() async {
    final repo = ref.watch(bookRepositoryProvider);
    return repo.getBooks();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(bookRepositoryProvider);
      return repo.getBooks();
    });
  }
}

final bookListViewModelProvider =
    AsyncNotifierProvider<BookListViewModel, List<BookWithDetails>>(
  BookListViewModel.new,
);
