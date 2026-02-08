import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/db/app_database.dart';
import '../../../data/repositories/member_repository.dart';
import '../../books/data/repositories/supabase_book_repository.dart';

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
    final memberRepo = MemberRepository(db);
    final bookRepo = ref.watch(supabaseBookRepositoryProvider);

    // Lấy thống kê sách từ Supabase
    int bookCopyCount = 0;
    try {
      final stats = await bookRepo.getBookStatistics();
      bookCopyCount = stats['totalCopies'] ?? 0;
    } catch (_) {
      // Nếu lỗi thì giữ 0
    }

    // Lấy số hội viên từ local DB
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
