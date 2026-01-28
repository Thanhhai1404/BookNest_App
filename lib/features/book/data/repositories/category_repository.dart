import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/db/app_database.dart';

class CategoryRepository {
  CategoryRepository(this.db);

  final AppDatabase db;

  Future<List<Category>> getAllCategories() {
    return (db.select(db.categories)
          ..orderBy([(c) => drift.OrderingTerm(expression: c.name)]))
        .get();
  }
}

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return CategoryRepository(db);
});
