import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/enums.dart';
import '../../../../data/db/app_database.dart';

/// DTO for displaying loan info with related member & book details.
class LoanWithDetails {
  const LoanWithDetails({
    required this.loan,
    required this.memberName,
    required this.bookTitle,
    required this.copyId,
  });

  final Loan loan;
  final String memberName;
  final String bookTitle;
  final String copyId;
}

class LoanRepository {
  LoanRepository(this.db);

  final AppDatabase db;

  /// Borrow a book copy: creates a Loan record and updates BookCopy status.
  ///
  /// Uses a Drift transaction to ensure atomicity:
  /// 1. Insert new Loan row.
  /// 2. Update BookCopy status to borrowed.
  Future<int> borrowBook({
    required String memberId,
    required String copyId,
    required DateTime dueDate,
  }) async {
    return db.transaction(() async {
      // Step A: Insert loan record.
      final loanId = await db.into(db.loans).insert(
            LoansCompanion.insert(
              memberId: memberId,
              copyId: copyId,
              borrowDate: DateTime.now(),
              dueDate: dueDate,
              status: drift.Value(LoanStatus.active.code),
            ),
          );

      // Step B: Update BookCopy status to borrowed.
      await (db.update(db.bookCopies)..where((c) => c.id.equals(copyId)))
          .write(BookCopiesCompanion(
        status: drift.Value(BookStatus.borrowed.code),
      ));

      return loanId;
    });
  }

  /// Get all active loans (not yet returned) with member/book info.
  ///
  /// Joins Loans -> Members, Loans -> BookCopies -> Books to display
  /// human-readable names.
  Future<List<LoanWithDetails>> getActiveLoans() async {
    final l = db.loans;
    final m = db.members;
    final bc = db.bookCopies;
    final b = db.books;

    final query = db.select(l).join([
      drift.innerJoin(m, m.id.equalsExp(l.memberId)),
      drift.innerJoin(bc, bc.id.equalsExp(l.copyId)),
      drift.innerJoin(b, b.id.equalsExp(bc.bookId)),
    ]);

    // Filter only active loans (status = 0 or 1, i.e., not returned).
    query.where(
        l.status.isIn([LoanStatus.active.code, LoanStatus.overdue.code]));
    query.orderBy([drift.OrderingTerm.desc(l.borrowDate)]);

    final rows = await query.get();

    return rows.map((row) {
      final loan = row.readTable(l);
      final member = row.readTable(m);
      final book = row.readTable(b);
      final copy = row.readTable(bc);

      final memberName = _formatMemberName(member);
      final bookTitle = book.title ?? book.id;

      return LoanWithDetails(
        loan: loan,
        memberName: memberName,
        bookTitle: bookTitle,
        copyId: copy.id,
      );
    }).toList();
  }

  /// Get all loans (including returned) for history.
  Future<List<LoanWithDetails>> getAllLoans() async {
    final l = db.loans;
    final m = db.members;
    final bc = db.bookCopies;
    final b = db.books;

    final query = db.select(l).join([
      drift.innerJoin(m, m.id.equalsExp(l.memberId)),
      drift.innerJoin(bc, bc.id.equalsExp(l.copyId)),
      drift.innerJoin(b, b.id.equalsExp(bc.bookId)),
    ]);

    query.orderBy([drift.OrderingTerm.desc(l.borrowDate)]);

    final rows = await query.get();

    return rows.map((row) {
      final loan = row.readTable(l);
      final member = row.readTable(m);
      final book = row.readTable(b);
      final copy = row.readTable(bc);

      final memberName = _formatMemberName(member);
      final bookTitle = book.title ?? book.id;

      return LoanWithDetails(
        loan: loan,
        memberName: memberName,
        bookTitle: bookTitle,
        copyId: copy.id,
      );
    }).toList();
  }

  /// Return a borrowed book: updates loan status and book copy status.
  Future<void> returnBook(int loanId) async {
    return db.transaction(() async {
      // Get the loan to find the copyId.
      final loan = await (db.select(db.loans)
            ..where((l) => l.id.equals(loanId)))
          .getSingleOrNull();
      if (loan == null) {
        throw StateError('Không tìm thấy phiếu mượn #$loanId');
      }

      // Step A: Update loan status to returned.
      await (db.update(db.loans)..where((l) => l.id.equals(loanId))).write(
        LoansCompanion(
          returnDate: drift.Value(DateTime.now()),
          status: drift.Value(LoanStatus.returned.code),
        ),
      );      // Step B: Update BookCopy status back to available.
      await (db.update(db.bookCopies)..where((c) => c.id.equals(loan.copyId)))
          .write(BookCopiesCompanion(
        status: drift.Value(BookStatus.available.code),
      ));
    });
  }

  /// Maximum number of renewals allowed per loan.
  static const int maxRenewals = 2;

  /// Renewal period in days.
  static const int renewalDays = 7;

  /// Renew a loan: extends the due date by [renewalDays] days.
  ///
  /// Returns the new due date.
  /// Throws if:
  /// - Loan not found
  /// - Loan already returned
  /// - Max renewals reached
  Future<DateTime> renewBook(int loanId) async {
    // Get the loan.
    final loan = await (db.select(db.loans)
          ..where((l) => l.id.equals(loanId)))
        .getSingleOrNull();

    if (loan == null) {
      throw StateError('Không tìm thấy phiếu mượn #$loanId');
    }

    // Check if loan is already returned.
    if (loan.returnDate != null) {
      throw StateError('Phiếu mượn #$loanId đã được trả sách');
    }

    // Check if max renewals reached.
    if (loan.renewalCount >= maxRenewals) {
      throw StateError(
        'Đã đạt giới hạn gia hạn ($maxRenewals lần). Không thể gia hạn thêm.',
      );
    }

    // Calculate new due date: extend from current due date.
    final newDueDate = loan.dueDate.add(Duration(days: renewalDays));
    final newRenewalCount = loan.renewalCount + 1;

    // Update the loan.
    await (db.update(db.loans)..where((l) => l.id.equals(loanId))).write(
      LoansCompanion(
        dueDate: drift.Value(newDueDate),
        renewalCount: drift.Value(newRenewalCount),
        // If loan was overdue, reset status to active if new due date is in the future.
        status: newDueDate.isAfter(DateTime.now())
            ? drift.Value(LoanStatus.active.code)
            : const drift.Value.absent(),
      ),
    );

    return newDueDate;
  }

  /// Check if a loan can be renewed.
  bool canRenew(Loan loan) {
    return loan.returnDate == null && loan.renewalCount < maxRenewals;
  }

  String _formatMemberName(Member member) {
    final parts = <String>[];
    for (final p in [member.lastName, member.middleName, member.firstName]) {
      final v = (p ?? '').trim();
      if (v.isNotEmpty) parts.add(v);
    }
    return parts.isEmpty ? member.id : parts.join(' ');
  }
}

final loanRepositoryProvider = Provider<LoanRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return LoanRepository(db);
});
