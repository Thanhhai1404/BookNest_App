import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/user_app.dart';
import 'core/services/supabase_service.dart';
import 'data/db/app_database.dart';

/// Entry point cho User Portal (Cổng Thành Viên)
///
/// Chạy riêng: flutter run -t lib/main_user.dart
/// Hoặc build riêng: flutter build apk -t lib/main_user.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();

  // 1. Khởi tạo Supabase
  await SupabaseService.initialize();
  await SupabaseService.testConnection();

  // 2. Khởi tạo Database
  final db = AppDatabase();

  // 3. Chạy App
  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
      ],
      child: const UserApp(),
    ),
  );
}
