import 'package:drift/drift.dart';

// Drift table: Members

class Members extends Table {
  TextColumn get id => text().withLength(min: 1, max: 10)();

  /// SQL splits name parts (HoDG, TenLotDG, TenDG). Keep parts for fidelity.
  TextColumn get lastName => text().nullable().withLength(min: 0, max: 20)();
  TextColumn get middleName => text().nullable().withLength(min: 0, max: 20)();
  TextColumn get firstName => text().nullable().withLength(min: 0, max: 10)();

  DateTimeColumn get dateOfBirth => dateTime().nullable()();

  TextColumn get phone => text().nullable().withLength(min: 0, max: 10)();
  TextColumn get nationalId => text().withLength(min: 1, max: 12)();
  TextColumn get email => text().withLength(min: 1, max: 100)();
  TextColumn get address => text().nullable().withLength(min: 0, max: 200)();

  DateTimeColumn get subscriptionExpiryDate => dateTime().nullable()();

  /// Wallet balance in VND.
  IntColumn get walletBalance => integer().nullable()();

  IntColumn get points => integer().nullable()();

  /// SQL TrangThai bit (0/1).
  BoolColumn get isActive => boolean().nullable()();

  TextColumn get subscriptionId => text().withLength(min: 1, max: 20)();

  /// Added in roadmap: path to avatar image on device.
  TextColumn get avatarPath => text().nullable()();

  /// Added in roadmap: local password for member login (nullable).
  TextColumn get password => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
        'UNIQUE(email)',
        'UNIQUE(national_id)',
        'UNIQUE(phone)'
      ];
}
