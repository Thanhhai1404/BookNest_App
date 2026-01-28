// Drift table: Transactions
import 'package:drift/drift.dart';

class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// SQL: LoaiGiaoDich
  TextColumn get type => text().nullable().withLength(min: 0, max: 20)();

  /// Amount in VND (can be negative in SQL seed data).
  IntColumn get amount => integer().nullable()();

  DateTimeColumn get createdAt => dateTime().nullable()();

  TextColumn get description => text().nullable().withLength(min: 0, max: 200)();

  TextColumn get memberId => text().withLength(min: 1, max: 10)();
}
