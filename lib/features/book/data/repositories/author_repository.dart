import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/db/app_database.dart';

class AuthorRepository {
  AuthorRepository(this.db);

  final AppDatabase db;

  Future<List<Author>> getAllAuthors() {
    // Order by name parts for a stable dropdown display.
    return (db.select(db.authors)
          ..orderBy([
            (a) => drift.OrderingTerm(expression: a.lastName),
            (a) => drift.OrderingTerm(expression: a.middleName),
            (a) => drift.OrderingTerm(expression: a.firstName),
          ]))
        .get();
  }
}

final authorRepositoryProvider = Provider<AuthorRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return AuthorRepository(db);
});
