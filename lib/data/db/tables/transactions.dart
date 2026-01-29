// Drift table: Transactions
import 'package:drift/drift.dart';

import 'members.dart';

/// Wallet transaction records for members.
/// Tracks all money movements: top-ups, payments, refunds, fine payments.
class Transactions extends Table {
  @override
  String get tableName => 'transactions';

  IntColumn get id => integer().autoIncrement()();

  /// Member who owns this transaction (FK -> Members.id).
  TextColumn get memberId =>
      text().withLength(min: 1, max: 10).references(Members, #id)();

  /// Transaction type: 'TopUp', 'Payment', 'Refund', 'FinePayment'.
  TextColumn get type => text().withLength(min: 1, max: 20)();

  /// Amount in VND (positive for credits, negative for debits).
  IntColumn get amount => integer()();

  /// Balance after this transaction.
  IntColumn get balanceAfter => integer().withDefault(const Constant(0))();

  /// Optional reference to the fine being paid (FK -> Fines.id).
  IntColumn get fineId => integer().nullable()();

  /// Optional reference to loan (for payment context).
  IntColumn get loanId => integer().nullable()();

  /// Description of the transaction.
  TextColumn get description => text().nullable().withLength(min: 0, max: 200)();

  /// Timestamp when transaction was created.
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
