import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/db/app_database.dart';

class PublisherRepository {
  PublisherRepository(this.db);

  final AppDatabase db;

  Future<List<Publisher>> getAllPublishers() {
    return (db.select(db.publishers)
          ..orderBy([(p) => drift.OrderingTerm(expression: p.name)]))
        .get();
  }
}

final publisherRepositoryProvider = Provider<PublisherRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return PublisherRepository(db);
});
