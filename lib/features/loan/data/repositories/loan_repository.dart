import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/enums.dart';
import '../../../../data/db/app_database.dart';

/// Fine rate: VND per overdue day.
const int kFineRatePerDay = 2000;

/// Result of returning a book, includes fine information if overdue.
class ReturnBookResult {
  const ReturnBookResult({
    required this.bookId,
    required this.isOverdue,
    required this.lateDays,
    required this.fineAmount,
    this.fineId,
    this.newBalance,
    this.finePaidFromWallet = false,
  });

  final String bookId;
  final bool isOverdue;
  final int lateDays;
  final int fineAmount;
  final int? fineId;
  final int? newBalance;
  
  /// Whether the fine was auto-paid from wallet.
  /// If false and isOverdue, fine is pending (needs cash payment).
  final bool finePaidFromWallet;
  
  /// Whether fine is pending (not paid, needs cash collection).
  bool get finePending => isOverdue && fineAmount > 0 && !finePaidFromWallet;
}

/// DTO for displaying loan info with related member & book details.
class LoanWithDetails {
  const LoanWithDetails({
    required this.loan,
    required this.memberName,
    required this.memberId,
    required this.memberPhone,
    required this.bookTitle,
    required this.copyId,
    required this.bookId,
  });

  final Loan loan;
  final String memberName;
  final String memberId;
  final String? memberPhone;
  final String bookTitle;
  final String copyId;
  final String bookId;

  /// Calculate overdue days (0 if not overdue)
  int get overdueDays {
    if (loan.returnDate != null) return 0; // Already returned
    final days = DateTime.now().difference(loan.dueDate).inDays;
    return days > 0 ? days : 0;
  }

  /// Check if loan is overdue
  bool get isOverdue => overdueDays > 0;
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
    query.orderBy([drift.OrderingTerm.desc(l.borrowDate)]);    final rows = await query.get();    return rows.map((row) {
      final loan = row.readTable(l);
      final member = row.readTable(m);
      final book = row.readTable(b);
      final copy = row.readTable(bc);

      final memberName = _formatMemberName(member);
      final bookTitle = book.title ?? book.id;

      return LoanWithDetails(
        loan: loan,
        memberName: memberName,
        memberId: member.id,
        memberPhone: member.phone,
        bookTitle: bookTitle,
        copyId: copy.id,
        bookId: book.id,
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

    query.orderBy([drift.OrderingTerm.desc(l.borrowDate)]);    final rows = await query.get();

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
        memberId: member.id,
        memberPhone: member.phone,
        bookTitle: bookTitle,
        copyId: copy.id,
        bookId: book.id,
      );
    }).toList();
  }
  /// Get the bookId for a loan (used to check reservations before return).
  Future<String?> getBookIdForLoan(int loanId) async {
    final loan = await (db.select(db.loans)
          ..where((l) => l.id.equals(loanId)))
        .getSingleOrNull();
    if (loan == null) return null;

    final copy = await (db.select(db.bookCopies)
          ..where((c) => c.id.equals(loan.copyId)))
        .getSingleOrNull();
    return copy?.bookId;
  }

  /// Get all overdue loans (active loans with dueDate < now).
  ///
  /// Ordered by overdue days descending (most overdue first).
  Future<List<LoanWithDetails>> getOverdueLoans() async {
    final l = db.loans;
    final m = db.members;
    final bc = db.bookCopies;
    final b = db.books;

    final query = db.select(l).join([
      drift.innerJoin(m, m.id.equalsExp(l.memberId)),
      drift.innerJoin(bc, bc.id.equalsExp(l.copyId)),
      drift.innerJoin(b, b.id.equalsExp(bc.bookId)),
    ]);

    final now = DateTime.now();

    // Filter: active status AND dueDate < now AND not returned
    query.where(
      l.status.isIn([LoanStatus.active.code, LoanStatus.overdue.code]) &
          l.dueDate.isSmallerThanValue(now) &
          l.returnDate.isNull(),
    );

    // Order by due date ascending (most overdue first)
    query.orderBy([drift.OrderingTerm.asc(l.dueDate)]);

    final rows = await query.get();

    return rows.map((row) {
      final loan = row.readTable(l);
      final member = row.readTable(m);
      final book = row.readTable(b);
      final copy = row.readTable(bc);

      return LoanWithDetails(
        loan: loan,
        memberName: _formatMemberName(member),
        memberId: member.id,
        memberPhone: member.phone,
        bookTitle: book.title ?? book.id,
        copyId: copy.id,
        bookId: book.id,
      );
    }).toList();
  }

  /// Get all loans for a specific member (full history).
  ///
  /// Includes both active and returned loans, ordered by borrow date desc.
  Future<List<LoanWithDetails>> getLoansByMember(String memberId) async {
    final l = db.loans;
    final m = db.members;
    final bc = db.bookCopies;
    final b = db.books;

    final query = db.select(l).join([
      drift.innerJoin(m, m.id.equalsExp(l.memberId)),
      drift.innerJoin(bc, bc.id.equalsExp(l.copyId)),
      drift.innerJoin(b, b.id.equalsExp(bc.bookId)),
    ]);

    query.where(l.memberId.equals(memberId));
    query.orderBy([drift.OrderingTerm.desc(l.borrowDate)]);

    final rows = await query.get();

    return rows.map((row) {
      final loan = row.readTable(l);
      final member = row.readTable(m);
      final book = row.readTable(b);
      final copy = row.readTable(bc);

      return LoanWithDetails(
        loan: loan,
        memberName: _formatMemberName(member),
        memberId: member.id,
        memberPhone: member.phone,
        bookTitle: book.title ?? book.id,
        copyId: copy.id,
        bookId: book.id,
      );
    }).toList();
  }

  /// Return a borrowed book: updates loan status and book copy status.
  ///
  /// Returns a [ReturnBookResult] containing the bookId and any fine info.
  /// Automatically calculates and applies fine for overdue returns.
  Future<ReturnBookResult> returnBook(int loanId) async {
    // Get the loan to find the copyId first (outside transaction for bookId).
    final loan = await (db.select(db.loans)
          ..where((l) => l.id.equals(loanId)))
        .getSingleOrNull();
    if (loan == null) {
      throw StateError('Không tìm thấy phiếu mượn #$loanId');
    }

    // Get the bookId from copy.
    final copy = await (db.select(db.bookCopies)
          ..where((c) => c.id.equals(loan.copyId)))
        .getSingleOrNull();
    if (copy == null) {
      throw StateError('Không tìm thấy bản sao ${loan.copyId}');
    }

    // Calculate late days
    final now = DateTime.now();
    final lateDays = now.difference(loan.dueDate).inDays;
    final isOverdue = lateDays > 0;
    final fineAmount = isOverdue ? lateDays * kFineRatePerDay : 0;

    int? fineId;
    int? newBalance;

    await db.transaction(() async {
      // Step A: Update loan status to returned.
      await (db.update(db.loans)..where((l) => l.id.equals(loanId))).write(
        LoansCompanion(
          returnDate: drift.Value(now),
          status: drift.Value(LoanStatus.returned.code),
        ),
      );

      // Step B: Update BookCopy status back to available.
      await (db.update(db.bookCopies)..where((c) => c.id.equals(loan.copyId)))
          .write(BookCopiesCompanion(
        status: drift.Value(BookStatus.available.code),
      ));

      // Step C: If overdue, create fine record
      if (isOverdue && fineAmount > 0) {
        // Get member's current balance first
        final member = await (db.select(db.members)
              ..where((m) => m.id.equals(loan.memberId)))
            .getSingleOrNull();

        if (member != null) {
          final currentBalance = member.walletBalance;
          final canPayFromWallet = currentBalance >= fineAmount;

          // Create fine record (status depends on wallet balance)
          fineId = await db.into(db.fines).insert(
                FinesCompanion.insert(
                  memberId: loan.memberId,
                  loanId: loanId,
                  amount: fineAmount,
                  reason: FineReason.overdue.value,
                  overdueDays: drift.Value(lateDays),
                  // If wallet has enough, mark as Paid; otherwise Pending
                  status: drift.Value(canPayFromWallet 
                      ? FineStatus.paid.value 
                      : FineStatus.pending.value),
                  paidAt: drift.Value(canPayFromWallet ? now : null),
                ),
              );

          if (canPayFromWallet) {
            // Wallet has enough balance - auto deduct
            newBalance = currentBalance - fineAmount;

            // Update wallet balance
            await (db.update(db.members)
                  ..where((m) => m.id.equals(loan.memberId)))
                .write(MembersCompanion(walletBalance: drift.Value(newBalance!)));

            // Create transaction record for auto fine payment
            await db.into(db.transactions).insert(
                  TransactionsCompanion.insert(
                    memberId: loan.memberId,
                    type: TransactionType.finePayment.value,
                    amount: -fineAmount, // Negative for debit
                    balanceAfter: drift.Value(newBalance!),
                    fineId: drift.Value(fineId),
                    loanId: drift.Value(loanId),
                    description: drift.Value(
                      'Tự động trừ phạt trả sách trễ $lateDays ngày - Phiếu mượn #$loanId',
                    ),
                  ),
                );
          }
          // If wallet doesn't have enough, fine stays Pending
          // Admin will collect cash later via FineListPage
        }
      }
    });

    // Check if fine was paid from wallet (newBalance != null means it was deducted)
    final finePaidFromWallet = isOverdue && fineAmount > 0 && newBalance != null;

    return ReturnBookResult(
      bookId: copy.bookId,
      isOverdue: isOverdue,
      lateDays: lateDays,
      fineAmount: fineAmount,
      fineId: fineId,
      newBalance: newBalance,
      finePaidFromWallet: finePaidFromWallet,
    );
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
