import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/enums.dart';
import '../../../data/db/app_database.dart';
import '../data/repositories/loan_repository.dart';

/// DTO for available book copy display in borrow form.
class AvailableCopyInfo {
  const AvailableCopyInfo({
    required this.copyId,
    required this.bookTitle,
  });

  final String copyId;
  final String bookTitle;

  String get displayText => '$bookTitle - $copyId';
}

/// State for loan list screen.
class LoanListState {
  const LoanListState({
    required this.activeLoans,
  });

  final List<LoanWithDetails> activeLoans;
}

/// ViewModel for loan list and borrow operations.
class LoanViewModel extends AsyncNotifier<LoanListState> {
  @override
  Future<LoanListState> build() async {
    final repo = ref.watch(loanRepositoryProvider);
    final activeLoans = await repo.getActiveLoans();
    return LoanListState(activeLoans: activeLoans);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(loanRepositoryProvider);
      final activeLoans = await repo.getActiveLoans();
      return LoanListState(activeLoans: activeLoans);
    });
  }

  Future<void> borrowBook({
    required String memberId,
    required String copyId,
    required DateTime dueDate,
  }) async {
    final repo = ref.read(loanRepositoryProvider);
    await repo.borrowBook(
      memberId: memberId,
      copyId: copyId,
      dueDate: dueDate,
    );
    await refresh();
  }

  /// Return a borrowed book by loan ID.
  Future<void> returnBook(int loanId) async {
    final repo = ref.read(loanRepositoryProvider);
    await repo.returnBook(loanId);
    ref.invalidateSelf();
  }
}

final loanViewModelProvider =
    AsyncNotifierProvider<LoanViewModel, LoanListState>(LoanViewModel.new);

/// Provider for loading all members (for borrow form dropdown).
final allMembersProvider = FutureProvider<List<Member>>((ref) async {
  final db = ref.watch(databaseProvider);
  return (db.select(db.members)
        ..orderBy([(m) => drift.OrderingTerm(expression: m.id)]))
      .get();
});

/// Provider for loading available book copies (status = available).
final availableCopiesProvider =
    FutureProvider<List<AvailableCopyInfo>>((ref) async {
  final db = ref.watch(databaseProvider);

  final bc = db.bookCopies;
  final b = db.books;

  final query = db.select(bc).join([
    drift.innerJoin(b, b.id.equalsExp(bc.bookId)),
  ]);

  query.where(bc.status.equals(BookStatus.available.code));
  query.orderBy([drift.OrderingTerm(expression: b.title)]);

  final rows = await query.get();

  return rows.map((row) {
    final copy = row.readTable(bc);
    final book = row.readTable(b);
    return AvailableCopyInfo(
      copyId: copy.id,
      bookTitle: book.title ?? book.id,
    );
  }).toList();
});
