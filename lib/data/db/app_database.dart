import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables/book_copies.dart';
import 'tables/books.dart';
import 'tables/fines.dart';
import 'tables/loans.dart';
import 'tables/members.dart';
import 'tables/receipts.dart';
import 'tables/reservations.dart';
import 'tables/renewals.dart';
import 'tables/staff_accounts.dart';
import 'tables/subscriptions.dart';
import 'tables/transactions.dart';
import 'tables/authors.dart';
import 'tables/book_authors.dart';
import 'tables/categories.dart';
import 'tables/publishers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'app_database.g.dart';

/// Riverpod provider for the app-wide database.
///
/// In `main.dart`, we override this provider with the singleton `AppDatabase()`
/// instance after seeding.
final databaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('databaseProvider must be overridden in main.dart');
});

@DriftDatabase(
  tables: [
    Subscriptions,
    Members,
    StaffAccounts,
    Categories,
    Publishers,
    Authors,
    Books,
    BookAuthors,
    BookCopies,
    Loans,
    Fines,
    Transactions,
    Reservations,
    Renewals,
    Receipts,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'booknest_v2.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
