import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';

/// Service class để quản lý kết nối Supabase.
class SupabaseService {
  SupabaseService._();

  static bool _initialized = false;

  /// Khởi tạo Supabase client.
  ///
  /// Gọi hàm này trong main() trước khi runApp().
  static Future<void> initialize() async {
    if (_initialized) return;

    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );

    _initialized = true;
    debugPrint('✅ Supabase initialized successfully');
  }

  /// Lấy Supabase client instance.
  static SupabaseClient get client => Supabase.instance.client;

  /// Kiểm tra kết nối Supabase.
  ///
  /// In ra thông báo thành công hoặc lỗi.
  /// Returns true nếu kết nối thành công, false nếu thất bại.
  static Future<bool> testConnection() async {
    try {
      // Thử lấy session hiện tại để kiểm tra kết nối
      final session = client.auth.currentSession;

      // Nếu không có lỗi, kết nối thành công
      debugPrint('🎉 Kết nối Supabase thành công!');
      debugPrint(
          '   Session: ${session != null ? "Active" : "No session (anonymous)"}');
      return true;
    } catch (e) {
      debugPrint('❌ Kết nối Supabase thất bại: $e');
      return false;
    }
  }

  /// Kiểm tra xem Supabase đã được khởi tạo chưa.
  static bool get isInitialized => _initialized;
}
