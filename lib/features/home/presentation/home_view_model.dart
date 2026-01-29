import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/db/app_database.dart';
import '../../../data/repositories/member_repository.dart';
import '../../book/data/repositories/book_repository.dart';

/// State for Home dashboard statistics.
class HomeState {
  const HomeState({
    required this.bookCopyCount,
    required this.memberCount,
  });

  final int bookCopyCount;
  final int memberCount;
}

/// ViewModel for Home dashboard.
class HomeViewModel extends AsyncNotifier<HomeState> {
  @override
  Future<HomeState> build() async {
    final db = ref.watch(databaseProvider);
    final bookRepo = BookRepository(db);
    final memberRepo = MemberRepository(db);

    final bookCopyCount = await bookRepo.countBookCopies();
    final memberCount = await memberRepo.countMembers();

    return HomeState(
      bookCopyCount: bookCopyCount,
      memberCount: memberCount,
    );
  }

  /// Refresh statistics.
  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

final homeViewModelProvider =
    AsyncNotifierProvider<HomeViewModel, HomeState>(HomeViewModel.new);
