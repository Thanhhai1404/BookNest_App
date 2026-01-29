import 'package:drift/drift.dart';

import 'book_copies.dart';
import 'members.dart';

/// Drift table: Loans (Phiếu mượn)
///
/// Tracks book borrowing transactions.
class Loans extends Table {
  @override
  String get tableName => 'loans';

  /// Auto-increment primary key.
  IntColumn get id => integer().autoIncrement()();

  /// Member who borrows the book (FK -> Members.id).
  TextColumn get memberId =>
      text().withLength(min: 1, max: 10).references(Members, #id)();

  /// The specific book copy being borrowed (FK -> BookCopies.id).
  TextColumn get copyId =>
      text().withLength(min: 1, max: 20).references(BookCopies, #id)();

  /// Date when the book was borrowed.
  DateTimeColumn get borrowDate => dateTime()();

  /// Due date for returning the book.
  DateTimeColumn get dueDate => dateTime()();

  /// Actual return date (null if not yet returned).
  DateTimeColumn get returnDate => dateTime().nullable()();

  /// Loan status: 0 = Active, 1 = Overdue, 2 = Returned.
  IntColumn get status => integer().withDefault(const Constant(0))();
}
