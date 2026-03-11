import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/employees/data/supabase_employee_repository.dart';

/// State class cho Auth
class AuthState {
  final SupabaseEmployee? currentEmployee;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.currentEmployee,
    this.isLoading = false,
    this.error,
  });

  bool get isLoggedIn => currentEmployee != null;

  AuthState copyWith({
    SupabaseEmployee? currentEmployee,
    bool? isLoading,
    String? error,
    bool clearEmployee = false,
  }) {
    return AuthState(
      currentEmployee:
          clearEmployee ? null : (currentEmployee ?? this.currentEmployee),
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier quản lý trạng thái đăng nhập
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    return const AuthState();
  }

  /// Đăng nhập với tài khoản và mật khẩu
  Future<bool> login(String username, String password) async {
    if (username.trim().isEmpty || password.isEmpty) {
      throw Exception('Vui lòng nhập đầy đủ tài khoản và mật khẩu');
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final client = Supabase.instance.client;

      // Query bảng nhan_vien với taikhoan và matkhau
      final response = await client
          .from('nhan_vien')
          .select('manv, honv, tennv, chucvu, taikhoan')
          .eq('taikhoan', username.trim())
          .eq('matkhau', password)
          .maybeSingle();

      if (response == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'Sai tài khoản hoặc mật khẩu',
        );
        throw Exception('Sai tài khoản hoặc mật khẩu');
      }

      // Parse kết quả thành SupabaseEmployee
      final employee = SupabaseEmployee.fromJson(response);

      state = state.copyWith(
        currentEmployee: employee,
        isLoading: false,
        error: null,
      );

      return true;
    } catch (e) {
      if (e.toString().contains('Sai tài khoản')) {
        rethrow;
      }
      state = state.copyWith(
        isLoading: false,
        error: 'Lỗi đăng nhập: ${e.toString().replaceAll('Exception: ', '')}',
      );
      throw Exception(
          'Lỗi đăng nhập: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  /// Đăng xuất
  void logout() {
    state = const AuthState();
  }

  /// Kiểm tra đã đăng nhập chưa
  bool get isLoggedIn => state.isLoggedIn;

  /// Lấy nhân viên hiện tại
  SupabaseEmployee? get currentEmployee => state.currentEmployee;
}

/// Provider cho AuthNotifier
final authProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

/// Provider tiện ích để lấy nhân viên hiện tại
final currentEmployeeProvider = Provider<SupabaseEmployee?>((ref) {
  return ref.watch(authProvider).currentEmployee;
});

/// Provider kiểm tra trạng thái đăng nhập
final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoggedIn;
});
