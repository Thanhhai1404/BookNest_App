import 'package:drift/drift.dart';

// Drift table: Subscriptions

class Subscriptions extends Table {
  TextColumn get id => text().withLength(min: 1, max: 20)();
  TextColumn get name => text().nullable().withLength(min: 0, max: 50)();

  /// Monthly fee in VND.
  IntColumn get monthlyFee => integer().nullable()();

  /// Deposit in VND.
  IntColumn get deposit => integer().nullable()();

  IntColumn get maxBooks => integer().nullable()();
  IntColumn get maxDays => integer().nullable()();
  TextColumn get description => text().nullable().withLength(min: 0, max: 200)();

  BoolColumn get allowReservation => boolean().withDefault(const Constant(true))();
  BoolColumn get allowRenewal => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}
