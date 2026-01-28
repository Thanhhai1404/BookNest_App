import 'package:drift/drift.dart';

// Drift table: Renewals

class Renewals extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get loanId => text().withLength(min: 1, max: 15)();

  DateTimeColumn get renewedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get oldDueDate => dateTime()();
  DateTimeColumn get newDueDate => dateTime()();
}
