import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/enums.dart';
import '../db/app_database.dart';

/// Provider for MemberRepository
final memberRepositoryProvider = Provider<MemberRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return MemberRepository(db);
});

class MemberRepository {
  MemberRepository(this.db);

  final AppDatabase db;

  /// Stream list members. Supports searching by name parts or phone.
  ///
  /// - If [query] is null/empty: returns all members ordered by id.
  /// - Otherwise: matches `lastName`, `middleName`, `firstName`, or `phone`.
  Stream<List<Member>> watchMembers({String? query}) {
    final q = db.select(db.members);

    final normalized = (query ?? '').trim().toLowerCase();
    if (normalized.isNotEmpty) {
      final like = '%$normalized%';
      q.where((m) {
        // Use lower() to make search case-insensitive.
        return m.lastName.lower().like(like) |
            m.middleName.lower().like(like) |
            m.firstName.lower().like(like) |
            m.phone.lower().like(like);
      });
    }

    q.orderBy([(m) => OrderingTerm(expression: m.id)]);
    return q.watch();
  }

  Future<Member?> getMemberById(String id) {
    return (db.select(db.members)..where((m) => m.id.equals(id)))
        .getSingleOrNull();
  }

  Future<int> addMember(MembersCompanion data) {
    return db.into(db.members).insert(data);
  }

  Future<bool> updateMember(MembersCompanion data) {
    // Requires `id` to be present.
    return db.update(db.members).replace(data);
  }

  Future<int> deleteMember(String id) {
    return (db.delete(db.members)..where((m) => m.id.equals(id))).go();
  }

  Future<String> generateNextMemberId() async {
    // Robust approach: read all ids, parse numeric suffix, and compute max.
    // This avoids lexicographical issues (e.g. DG99 > DG100 when ordered as strings).

    // Read only the `id` column for performance.
    final rows =
        await (db.selectOnly(db.members)..addColumns([db.members.id])).get();

    if (rows.isEmpty) return 'DG001';

    final regex = RegExp(r'^DG(\d+)$', caseSensitive: false);

    var maxValue = 0;
    for (final row in rows) {
      final id = row.read(db.members.id);
      if (id == null) continue;

      final match = regex.firstMatch(id.trim());
      if (match == null) continue;

      final value = int.tryParse(match.group(1) ?? '');
      if (value == null) continue;
      if (value > maxValue) maxValue = value;
    }
    final next = maxValue + 1;
    final padded = next.toString().padLeft(3, '0');
    return 'DG$padded';
  }

  /// Count total members using SQL COUNT(*).
  Future<int> countMembers() async {
    final countExp = db.members.id.count();
    final query = db.selectOnly(db.members)..addColumns([countExp]);
    final row = await query.getSingle();
    return row.read(countExp) ?? 0;
  }
  /// Top up wallet balance for a member.
  ///
  /// [memberId]: The member's ID.
  /// [amount]: Amount to add (must be positive).
  /// Returns the new wallet balance, or throws if member not found.
  ///
  /// Also logs the transaction to the Transactions table.
  Future<int> topUpWallet(String memberId, int amount) async {
    if (amount <= 0) {
      throw ArgumentError('Amount must be positive');
    }

    return db.transaction(() async {
      final member = await getMemberById(memberId);
      if (member == null) {
        throw StateError('Không tìm thấy hội viên: $memberId');
      }

      final currentBalance = member.walletBalance;
      final newBalance = currentBalance + amount;

      // Update wallet balance
      await (db.update(db.members)..where((m) => m.id.equals(memberId))).write(
        MembersCompanion(walletBalance: Value(newBalance)),
      );

      // Log transaction
      await db.into(db.transactions).insert(
            TransactionsCompanion.insert(
              memberId: memberId,
              type: TransactionType.topUp.value,
              amount: amount,
              balanceAfter: Value(newBalance),
              description: const Value('Nạp tiền tài khoản'),
            ),
          );

      return newBalance;
    });
  }
  /// Deduct from wallet balance for a member.
  ///
  /// [memberId]: The member's ID.
  /// [amount]: Amount to deduct (must be positive).
  /// [allowNegative]: If true, allows wallet to go negative (for debt).
  /// Returns the new wallet balance.
  Future<int> deductWallet(String memberId, int amount,
      {bool allowNegative = false}) async {
    if (amount <= 0) {
      throw ArgumentError('Amount must be positive');
    }

    final member = await getMemberById(memberId);
    if (member == null) {
      throw StateError('Không tìm thấy hội viên: $memberId');
    }

    final currentBalance = member.walletBalance;
    if (!allowNegative && currentBalance < amount) {
      throw StateError('Số dư không đủ. Hiện có: $currentBalance VND');
    }

    final newBalance = currentBalance - amount;

    await (db.update(db.members)..where((m) => m.id.equals(memberId))).write(
      MembersCompanion(walletBalance: Value(newBalance)),
    );

    return newBalance;
  }

  /// Update points for a member (add or subtract).
  ///
  /// [memberId]: The member's ID.
  /// [pointsToAdd]: Points to add (positive) or subtract (negative).
  /// Returns the new points total.
  Future<int> updatePoints(String memberId, int pointsToAdd) async {
    final member = await getMemberById(memberId);
    if (member == null) {
      throw StateError('Không tìm thấy hội viên: $memberId');
    }    final currentPoints = member.points;
    final newPoints = currentPoints + pointsToAdd;

    // Ensure points don't go negative
    final finalPoints = newPoints < 0 ? 0 : newPoints;

    await (db.update(db.members)..where((m) => m.id.equals(memberId))).write(
      MembersCompanion(points: Value(finalPoints)),
    );

    return finalPoints;
  }

  /// Get wallet balance for a member.
  Future<int> getWalletBalance(String memberId) async {
    final member = await getMemberById(memberId);
    if (member == null) {
      throw StateError('Không tìm thấy hội viên: $memberId');
    }
    return member.walletBalance;
  }

  /// Get points for a member.
  Future<int> getPoints(String memberId) async {
    final member = await getMemberById(memberId);
    if (member == null) {
      throw StateError('Không tìm thấy hội viên: $memberId');
    }
    return member.points;
  }
}
