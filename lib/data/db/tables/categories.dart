import 'package:drift/drift.dart';

/// SQL: THE_LOAI
class Categories extends Table {
  @override
  String get tableName => 'categories';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().nullable().withLength(min: 0, max: 100)();
}
