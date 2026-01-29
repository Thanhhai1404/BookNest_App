import 'package:drift/drift.dart';

import 'loans.dart';
import 'members.dart';

/// Fines table for tracking penalties.
/// Records fines for overdue books, damages, or lost items.
class Fines extends Table {
  @override
  String get tableName => 'fines';

  IntColumn get id => integer().autoIncrement()();

  /// Member who owes this fine (FK -> Members.id).
  TextColumn get memberId =>
      text().withLength(min: 1, max: 10).references(Members, #id)();

  /// Related loan (FK -> Loans.id).
  IntColumn get loanId => integer().references(Loans, #id)();

  /// Fine amount in VND.
  IntColumn get amount => integer()();

  /// Reason: 'Overdue', 'Damaged', 'Lost'.
  TextColumn get reason => text().withLength(min: 1, max: 50)();

  /// Status: 'Pending', 'Paid', 'Waived'.
  TextColumn get status =>
      text().withLength(min: 1, max: 20).withDefault(const Constant('Pending'))();

  /// Number of overdue days (for overdue fines).
  IntColumn get overdueDays => integer().withDefault(const Constant(0))();

  /// Date when fine was paid (null if not paid).
  DateTimeColumn get paidAt => dateTime().nullable()();

  /// Timestamp when fine was created.
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
