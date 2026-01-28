import 'package:drift/drift.dart';

// Drift table: Loans

class Loans extends Table {
  /// SQL: MaPhieuMuon (Char(15))
  TextColumn get id => text().withLength(min: 1, max: 15)();

  DateTimeColumn get borrowedAt => dateTime().nullable()();
  TextColumn get note => text().nullable().withLength(min: 0, max: 200)();

  /// Member who borrows.
  TextColumn get memberId => text().withLength(min: 1, max: 10)();

  /// Staff who creates the loan (from SQL NHAN_VIEN.MaNV). Stored as text.
  TextColumn get staffId => text().withLength(min: 1, max: 10)();

  /// Card number used (SQL THE_THANH_VIEN.MaSoThe)
  TextColumn get memberCardNumber => text().withLength(min: 1, max: 20)();

  @override
  Set<Column> get primaryKey => {id};
}
