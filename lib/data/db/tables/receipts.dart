// Drift table: Receipts (digital receipts)
import 'package:drift/drift.dart';

class Receipts extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Optional linkage
  TextColumn get memberId => text().nullable().withLength(min: 0, max: 10)();
  TextColumn get loanId => text().nullable().withLength(min: 0, max: 15)();
  IntColumn get transactionId => integer().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// Receipt type: e.g. 'checkout', 'checkin', 'subscription_fee', 'fine'
  TextColumn get type => text().withLength(min: 1, max: 50)();

  /// Human-friendly summary string (for quick lists)
  TextColumn get title => text().withLength(min: 1, max: 200)();

  /// JSON blob for full details (line items, totals, etc.).
  TextColumn get payloadJson => text()();
}
