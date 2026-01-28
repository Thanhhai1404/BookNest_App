import 'package:drift/drift.dart';

// Drift table: Reservations

class Reservations extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get bookId => text().withLength(min: 1, max: 10)();
  TextColumn get memberId => text().withLength(min: 1, max: 10)();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// int status: 0=Active, 1=Fulfilled, 2=Cancelled (suggested)
  IntColumn get status => integer().withDefault(const Constant(0))();
}
