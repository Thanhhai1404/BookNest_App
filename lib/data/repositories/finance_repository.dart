import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/enums.dart';
import '../db/app_database.dart';

/// Provider for FinanceRepository
final financeRepositoryProvider = Provider<FinanceRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return FinanceRepository(db);
});

/// Fine rate: VND per overdue day.
const int kFineRatePerDay = 5000;

/// DTO for displaying fine info with member details.
class FineWithDetails {
  const FineWithDetails({
    required this.fine,
    required this.memberId,
    required this.memberName,
    required this.memberPhone,
    required this.memberBalance,
    this.bookTitle,
    this.loanId,
  });

  final Fine fine;
  final String memberId;
  final String memberName;
  final String? memberPhone;
  final int memberBalance;
  final String? bookTitle;
  final int? loanId;

  /// Check if member has enough balance to pay this fine.
  bool get canPayFromWallet => memberBalance >= fine.amount;
}

/// Repository for managing transactions and fines.
class FinanceRepository {
  FinanceRepository(this._db);
  final AppDatabase _db;

  // ============================================================
  // TRANSACTIONS
  // ============================================================

  /// Get all transactions for a member, ordered by createdAt desc.
  Future<List<Transaction>> getTransactionsByMember(String memberId) async {
    return (_db.select(_db.transactions)
          ..where((t) => t.memberId.equals(memberId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  /// Get recent transactions for a member (limit N).
  Future<List<Transaction>> getRecentTransactions(
    String memberId, {
    int limit = 10,
  }) async {
    return (_db.select(_db.transactions)
          ..where((t) => t.memberId.equals(memberId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(limit))
        .get();
  }

  /// Create a transaction record.
  Future<int> createTransaction({
    required String memberId,
    required TransactionType type,
    required int amount,
    required int balanceAfter,
    int? fineId,
    int? loanId,
    String? description,
  }) async {
    return _db.into(_db.transactions).insert(
          TransactionsCompanion.insert(
            memberId: memberId,
            type: type.value,
            amount: amount,
            balanceAfter: Value(balanceAfter),
            fineId: Value(fineId),
            loanId: Value(loanId),
            description: Value(description),
          ),
        );
  }

  /// Get transaction by ID.
  Future<Transaction?> getTransactionById(int id) async {
    return (_db.select(_db.transactions)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  // ============================================================
  // FINES
  // ============================================================

  /// Get all fines for a member.
  Future<List<Fine>> getFinesByMember(String memberId) async {
    return (_db.select(_db.fines)
          ..where((f) => f.memberId.equals(memberId))
          ..orderBy([(f) => OrderingTerm.desc(f.createdAt)]))
        .get();
  }

  /// Get pending (unpaid) fines for a member.
  Future<List<Fine>> getPendingFinesByMember(String memberId) async {
    return (_db.select(_db.fines)
          ..where((f) =>
              f.memberId.equals(memberId) &
              f.status.equals(FineStatus.pending.value))
          ..orderBy([(f) => OrderingTerm.desc(f.createdAt)]))
        .get();
  }

  /// Get total pending fine amount for a member.
  Future<int> getTotalPendingFines(String memberId) async {
    final fines = await getPendingFinesByMember(memberId);
    return fines.fold<int>(0, (sum, fine) => sum + fine.amount);
  }

  /// Get fine by ID.
  Future<Fine?> getFineById(int id) async {
    return (_db.select(_db.fines)..where((f) => f.id.equals(id)))
        .getSingleOrNull();
  }

  /// Get fine by loan ID.
  Future<Fine?> getFineByLoanId(int loanId) async {
    return (_db.select(_db.fines)..where((f) => f.loanId.equals(loanId)))
        .getSingleOrNull();
  }
  /// Get all pending fines with member and book details.
  /// 
  /// Returns a list of [FineWithDetails] containing fine info,
  /// member name, phone, balance, and book title.
  Future<List<FineWithDetails>> getAllPendingFinesWithDetails() async {
    return getFinesWithDetails(status: FineStatus.pending);
  }

  /// Get fines with member and book details, filtered by status.
  /// 
  /// [status] - Filter by fine status. If null, returns all fines.
  /// Returns a list of [FineWithDetails] containing fine info,
  /// member name, phone, balance, and book title.
  Future<List<FineWithDetails>> getFinesWithDetails({FineStatus? status}) async {
    final f = _db.fines;
    final m = _db.members;
    final l = _db.loans;
    final bc = _db.bookCopies;
    final b = _db.books;

    // Join fines -> members, fines -> loans -> bookCopies -> books
    final query = _db.select(f).join([
      innerJoin(m, m.id.equalsExp(f.memberId)),
      innerJoin(l, l.id.equalsExp(f.loanId)),
      innerJoin(bc, bc.id.equalsExp(l.copyId)),
      innerJoin(b, b.id.equalsExp(bc.bookId)),
    ]);

    // Filter by status if provided
    if (status != null) {
      query.where(f.status.equals(status.value));
    }
    query.orderBy([OrderingTerm.desc(f.createdAt)]);

    final rows = await query.get();

    return rows.map((row) {
      final fine = row.readTable(f);
      final member = row.readTable(m);
      final book = row.readTable(b);
      final loan = row.readTable(l);

      // Format member name
      String memberName = member.id;
      if (member.lastName != null || member.firstName != null) {
        memberName = '${member.lastName ?? ''} ${member.firstName ?? ''}'.trim();
        if (memberName.isEmpty) memberName = member.id;
      }

      return FineWithDetails(
        fine: fine,
        memberId: member.id,
        memberName: memberName,
        memberPhone: member.phone,
        memberBalance: member.walletBalance,
        bookTitle: book.title ?? book.id,
        loanId: loan.id,
      );
    }).toList();
  }

  /// Get all paid fines with member and book details.
  Future<List<FineWithDetails>> getAllPaidFinesWithDetails() async {
    return getFinesWithDetails(status: FineStatus.paid);
  }

  /// Get all fines (all statuses) with member and book details.
  Future<List<FineWithDetails>> getAllFinesWithDetails() async {
    return getFinesWithDetails(status: null);
  }

  /// Create a new fine record.
  Future<int> createFine({
    required String memberId,
    required int loanId,
    required int amount,
    required FineReason reason,
    int overdueDays = 0,
  }) async {
    return _db.into(_db.fines).insert(
          FinesCompanion.insert(
            memberId: memberId,
            loanId: loanId,
            amount: amount,
            reason: reason.value,
            overdueDays: Value(overdueDays),
          ),
        );
  }

  /// Create auto-fine for overdue loan.
  /// Calculates fine based on overdue days.
  Future<int?> createOverdueFine({
    required String memberId,
    required int loanId,
    required DateTime dueDate,
    DateTime? returnDate,
  }) async {
    final effectiveDate = returnDate ?? DateTime.now();
    final overdueDays = effectiveDate.difference(dueDate).inDays;

    if (overdueDays <= 0) return null; // Not overdue

    final amount = overdueDays * kFineRatePerDay;

    return createFine(
      memberId: memberId,
      loanId: loanId,
      amount: amount,
      reason: FineReason.overdue,
      overdueDays: overdueDays,
    );
  }

  /// Pay a fine using member's wallet.
  /// Returns true if successful, false if insufficient balance.
  Future<bool> payFine({
    required int fineId,
    required String memberId,
  }) async {
    return _db.transaction(() async {
      // Get the fine
      final fine = await getFineById(fineId);
      if (fine == null || fine.status != FineStatus.pending.value) {
        return false;
      }

      // Get member's current balance
      final member = await (_db.select(_db.members)
            ..where((m) => m.id.equals(memberId)))
          .getSingleOrNull();
      if (member == null) return false;

      final currentBalance = member.walletBalance;
      if (currentBalance < fine.amount) {
        return false; // Insufficient balance
      }

      // Deduct from wallet
      final newBalance = currentBalance - fine.amount;
      await (_db.update(_db.members)..where((m) => m.id.equals(memberId)))
          .write(MembersCompanion(walletBalance: Value(newBalance)));

      // Update fine status
      await (_db.update(_db.fines)..where((f) => f.id.equals(fineId))).write(
        FinesCompanion(
          status: Value(FineStatus.paid.value),
          paidAt: Value(DateTime.now()),
        ),
      );

      // Create transaction record
      await createTransaction(
        memberId: memberId,
        type: TransactionType.finePayment,
        amount: -fine.amount, // Negative for debit
        balanceAfter: newBalance,
        fineId: fineId,
        loanId: fine.loanId,
        description:
            'Thanh toán phạt #$fineId - ${fine.reason} (${fine.overdueDays} ngày)',
      );

      return true;
    });
  }

  /// Pay a fine using cash (manual payment by admin).
  /// 
  /// This method:
  /// 1. Updates fine status to Paid
  /// 2. Creates a transaction record for audit trail
  /// 3. Does NOT deduct from member's wallet (cash payment)
  /// 
  /// Returns true if successful.
  Future<bool> payFineByCash({
    required int fineId,
  }) async {
    return _db.transaction(() async {
      // 1. Get the fine info
      final fine = await getFineById(fineId);
      if (fine == null || fine.status != FineStatus.pending.value) {
        return false;
      }

      // 2. Get member's current balance (for transaction record only)
      final member = await (_db.select(_db.members)
            ..where((m) => m.id.equals(fine.memberId)))
          .getSingleOrNull();
      if (member == null) return false;

      // 3. Update fine status to Paid
      await (_db.update(_db.fines)..where((f) => f.id.equals(fineId))).write(
        FinesCompanion(
          status: Value(FineStatus.paid.value),
          paidAt: Value(DateTime.now()),
        ),
      );

      // 4. Create transaction record for audit trail
      // Amount is negative (money going out from member's perspective)
      // balanceAfter remains unchanged since we don't deduct from wallet
      await createTransaction(
        memberId: fine.memberId,
        type: TransactionType.finePayment,
        amount: -fine.amount, // Negative for debit/payment
        balanceAfter: member.walletBalance, // Balance unchanged (cash payment)
        fineId: fineId,
        loanId: fine.loanId,
        description: 'Thanh toán phạt (Tiền mặt) - ${_formatFineReason(fine.reason, fine.overdueDays)}',
      );

      return true;
    });
  }

  /// Helper to format fine reason for description.
  String _formatFineReason(String reason, int overdueDays) {
    switch (reason.toLowerCase()) {
      case 'overdue':
        return 'Trả trễ $overdueDays ngày';
      case 'damaged':
        return 'Sách hư hỏng';
      case 'lost':
        return 'Mất sách';
      default:
        return reason;
    }
  }

  /// Waive a fine (forgive without payment).
  Future<bool> waiveFine(int fineId) async {
    final updated = await (_db.update(_db.fines)
          ..where((f) => f.id.equals(fineId)))
        .write(
      FinesCompanion(
        status: Value(FineStatus.waived.value),
        paidAt: Value(DateTime.now()),
      ),
    );
    return updated > 0;
  }

  // ============================================================
  // WALLET OPERATIONS (with transaction logging)
  // ============================================================

  /// Top up wallet with transaction record.
  Future<bool> topUpWalletWithTransaction({
    required String memberId,
    required int amount,
    String? description,
  }) async {
    if (amount <= 0) return false;

    return _db.transaction(() async {
      // Get current balance
      final member = await (_db.select(_db.members)
            ..where((m) => m.id.equals(memberId)))
          .getSingleOrNull();
      if (member == null) return false;

      final newBalance = member.walletBalance + amount;

      // Update wallet
      await (_db.update(_db.members)..where((m) => m.id.equals(memberId)))
          .write(MembersCompanion(walletBalance: Value(newBalance)));

      // Create transaction record
      await createTransaction(
        memberId: memberId,
        type: TransactionType.topUp,
        amount: amount,
        balanceAfter: newBalance,
        description: description ?? 'Nạp tiền vào ví',
      );

      return true;
    });
  }

  /// Deduct from wallet with transaction record (for payments).
  Future<bool> deductWalletWithTransaction({
    required String memberId,
    required int amount,
    int? loanId,
    String? description,
  }) async {
    if (amount <= 0) return false;

    return _db.transaction(() async {
      // Get current balance
      final member = await (_db.select(_db.members)
            ..where((m) => m.id.equals(memberId)))
          .getSingleOrNull();
      if (member == null) return false;

      if (member.walletBalance < amount) return false; // Insufficient

      final newBalance = member.walletBalance - amount;

      // Update wallet
      await (_db.update(_db.members)..where((m) => m.id.equals(memberId)))
          .write(MembersCompanion(walletBalance: Value(newBalance)));

      // Create transaction record
      await createTransaction(
        memberId: memberId,
        type: TransactionType.payment,
        amount: -amount, // Negative for debit
        balanceAfter: newBalance,
        loanId: loanId,
        description: description ?? 'Thanh toán',
      );

      return true;
    });
  }

  /// Refund to wallet with transaction record.
  Future<bool> refundWalletWithTransaction({
    required String memberId,
    required int amount,
    int? loanId,
    String? description,
  }) async {
    if (amount <= 0) return false;

    return _db.transaction(() async {
      // Get current balance
      final member = await (_db.select(_db.members)
            ..where((m) => m.id.equals(memberId)))
          .getSingleOrNull();
      if (member == null) return false;

      final newBalance = member.walletBalance + amount;

      // Update wallet
      await (_db.update(_db.members)..where((m) => m.id.equals(memberId)))
          .write(MembersCompanion(walletBalance: Value(newBalance)));

      // Create transaction record
      await createTransaction(
        memberId: memberId,
        type: TransactionType.refund,
        amount: amount,
        balanceAfter: newBalance,
        loanId: loanId,
        description: description ?? 'Hoàn tiền',
      );

      return true;
    });
  }

  // ============================================================
  // STATISTICS
  // ============================================================

  /// Get total fines collected (paid) in a date range.
  Future<int> getTotalFinesCollected({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    var query = _db.select(_db.fines)
      ..where((f) => f.status.equals(FineStatus.paid.value));

    if (startDate != null) {
      query = query..where((f) => f.paidAt.isBiggerOrEqualValue(startDate));
    }
    if (endDate != null) {
      query = query..where((f) => f.paidAt.isSmallerOrEqualValue(endDate));
    }

    final fines = await query.get();
    return fines.fold<int>(0, (sum, fine) => sum + fine.amount);
  }

  /// Get total wallet top-ups in a date range.
  Future<int> getTotalTopUps({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    var query = _db.select(_db.transactions)
      ..where((t) => t.type.equals(TransactionType.topUp.value));

    if (startDate != null) {
      query = query..where((t) => t.createdAt.isBiggerOrEqualValue(startDate));
    }
    if (endDate != null) {
      query = query..where((t) => t.createdAt.isSmallerOrEqualValue(endDate));
    }

    final transactions = await query.get();
    return transactions.fold<int>(0, (sum, t) => sum + t.amount);
  }

  /// Count pending fines across all members.
  Future<int> countPendingFines() async {
    final fines = await (_db.select(_db.fines)
          ..where((f) => f.status.equals(FineStatus.pending.value)))
        .get();
    return fines.length;
  }
}
