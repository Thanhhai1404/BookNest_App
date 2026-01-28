import 'package:drift/drift.dart';

// Drift table: StaffAccounts

class StaffAccounts extends Table {
  TextColumn get id => text().withLength(min: 1, max: 10)();

  TextColumn get lastName => text().nullable().withLength(min: 0, max: 20)();
  TextColumn get middleName => text().nullable().withLength(min: 0, max: 20)();
  TextColumn get firstName => text().nullable().withLength(min: 0, max: 10)();

  TextColumn get role => text().nullable().withLength(min: 0, max: 100)();

  /// Unique username (SQL: TaiKhoan)
  TextColumn get username => text().withLength(min: 1, max: 100)();

  /// Password hash or plaintext (local-only app; you can switch to hashing later)
  TextColumn get password => text().withLength(min: 1, max: 100)();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => ['UNIQUE(username)'];
}
