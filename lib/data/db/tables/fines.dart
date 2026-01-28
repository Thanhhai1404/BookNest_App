import 'package:drift/drift.dart';

// Drift table: Fines

class Fines extends Table {
  IntColumn get id => integer().autoIncrement()();

  DateTimeColumn get createdAt => dateTime().nullable()();

  /// Total fine amount in VND.
  IntColumn get totalAmount => integer().nullable()();

  TextColumn get reason => text().nullable().withLength(min: 0, max: 200)();

  /// SQL TrangThai bit.
  BoolColumn get isPaid => boolean().nullable()();

  TextColumn get memberId => text().withLength(min: 1, max: 10)();
  TextColumn get loanId => text().withLength(min: 1, max: 15)();
}
