import 'package:drift/drift.dart';

import 'books.dart';
import 'members.dart';

/// Drift table: Reservations (Đặt trước sách)
///
/// Tracks book reservation requests when no copies are available.
class Reservations extends Table {
  @override
  String get tableName => 'reservations';

  /// Auto-increment primary key.
  IntColumn get id => integer().autoIncrement()();

  /// Book being reserved (FK -> Books.id).
  TextColumn get bookId =>
      text().withLength(min: 1, max: 10).references(Books, #id)();

  /// Member who is reserving (FK -> Members.id).
  TextColumn get memberId =>
      text().withLength(min: 1, max: 10).references(Members, #id)();

  /// When the reservation was created.
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// Reservation status: 'Active', 'Fulfilled', 'Cancelled'.
  TextColumn get status =>
      text().withLength(min: 1, max: 20).withDefault(const Constant('Active'))();
}
