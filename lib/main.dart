import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:intl/date_symbol_data_local.dart';

import 'app/app.dart';
import 'data/db/app_database.dart';
import 'data/db/seed_data.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  // 1. Khởi tạo Database
  final db = AppDatabase();

  // 2. Chạy Seed Data (Nạp dữ liệu thật nếu chưa có)
  await SeedData.seedIfNeeded(db);

  // 3. Chạy App với ProviderScope
  runApp(
    ProviderScope(
      overrides: [
        // Bơm con 'db' vừa tạo vào 'databaseProvider' để cả app dùng chung
        databaseProvider.overrideWithValue(db),
      ],
      child: const BookNestApp(),
    ),
  );
}
