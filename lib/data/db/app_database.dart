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
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Migration from v1 to v2:
        // - wallet_balance and points now have default 0 instead of nullable
        // For existing data, we just update NULL values to 0
        if (from < 2) {
          await customStatement(
            'UPDATE members SET wallet_balance = 0 WHERE wallet_balance IS NULL',
          );
          await customStatement(
            'UPDATE members SET points = 0 WHERE points IS NULL',
          );
        }

        // Migration from v2 to v3:
        // - Add renewal_count column to loans table (default 0)
        if (from < 3) {
          await customStatement(
            'ALTER TABLE loans ADD COLUMN renewal_count INTEGER NOT NULL DEFAULT 0',
          );
        }

        // Migration from v3 to v4:
        // - Recreate reservations table with TEXT status column
        // (Previous version used INT, new version uses TEXT: 'Active', 'Fulfilled', 'Cancelled')
        if (from < 4) {
          // Drop old table if exists and recreate
          await customStatement('DROP TABLE IF EXISTS reservations');
          await customStatement('''
            CREATE TABLE reservations (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              book_id TEXT NOT NULL REFERENCES books(id),
              member_id TEXT NOT NULL REFERENCES members(id),
              created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now') * 1000),
              status TEXT NOT NULL DEFAULT 'Active'
            )
          ''');
        }

        // Migration from v4 to v5:
        // - Recreate transactions table with new schema
        // - Recreate fines table with new schema
        if (from < 5) {
          // Backup old transactions data if needed
          await customStatement('DROP TABLE IF EXISTS transactions');
          await customStatement('''
            CREATE TABLE transactions (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              member_id TEXT NOT NULL REFERENCES members(id),
              type TEXT NOT NULL,
              amount INTEGER NOT NULL,
              balance_after INTEGER NOT NULL DEFAULT 0,
              fine_id INTEGER NULL,
              loan_id INTEGER NULL,
              description TEXT NULL,
              created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now') * 1000)
            )
          ''');

          // Recreate fines table with new schema
          await customStatement('DROP TABLE IF EXISTS fines');
          await customStatement('''
            CREATE TABLE fines (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              member_id TEXT NOT NULL REFERENCES members(id),
              loan_id INTEGER NOT NULL REFERENCES loans(id),
              amount INTEGER NOT NULL,
              reason TEXT NOT NULL,
              status TEXT NOT NULL DEFAULT 'Pending',
              overdue_days INTEGER NOT NULL DEFAULT 0,
              paid_at INTEGER NULL,
              created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now') * 1000)
            )
          ''');
        }
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'booknest_v2.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
