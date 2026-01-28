import 'package:drift/drift.dart';

/// SQL: TAC_GIA
class Authors extends Table {
  @override
  String get tableName => 'authors';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get lastName => text().nullable().withLength(min: 0, max: 20)();
  TextColumn get middleName => text().nullable().withLength(min: 0, max: 20)();
  TextColumn get firstName => text().nullable().withLength(min: 0, max: 10)();
  TextColumn get hometown => text().nullable().withLength(min: 0, max: 200)();
}
