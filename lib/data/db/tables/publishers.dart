import 'package:drift/drift.dart';

/// SQL: NHA_XUAT_BAN
class Publishers extends Table {
  @override
  String get tableName => 'publishers';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().nullable().withLength(min: 0, max: 100)();
  TextColumn get address => text().nullable().withLength(min: 0, max: 200)();
}
