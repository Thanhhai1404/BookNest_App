import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// User role enum for app authorization.
enum UserRole {
  admin,
  customer,
  unknown;

  static UserRole fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'customer':
        return UserRole.customer;
      default:
        return UserRole.unknown;
    }
  }
}

/// Result of authentication operations.
class AuthResult {
  const AuthResult({
    required this.success,
    this.message,
    this.user,
    this.role,
  });

  final bool success;
  final String? message;
  final User? user;
  final UserRole? role;

  factory AuthResult.success({User? user, UserRole? role, String? message}) {
    return AuthResult(
      success: true,
      user: user,
      role: role,
      message: message,
    );
  }

  factory AuthResult.failure(String message) {
    return AuthResult(success: false, message: message);
  }
}

/// Repository for handling Supabase authentication.
class AuthRepository {
  AuthRepository(this._client);

  final SupabaseClient _client;

  /// Get current authenticated user.
  User? get currentUser => _client.auth.currentUser;

  /// Check if user is logged in.
  bool get isLoggedIn => currentUser != null;

  /// Stream of auth state changes.
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// Sign in with email and password.
  ///
  /// Returns [AuthResult] with success status and user info.
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      if (response.user == null) {
        return AuthResult.failure('Đăng nhập thất bại. Vui lòng thử lại.');
      }

      // Get user role from profiles table
      final role = await getUserRole();

      debugPrint('✅ Login successful: ${response.user!.email}, role: $role');

      return AuthResult.success(
        user: response.user,
        role: role,
        message: 'Đăng nhập thành công!',
      );
    } on AuthException catch (e) {
      debugPrint('❌ Login AuthException: ${e.message}');
      return AuthResult.failure(_mapAuthError(e.message));
    } catch (e) {
      debugPrint('❌ Login error: $e');
      return AuthResult.failure('Đã xảy ra lỗi. Vui lòng thử lại.');
    }
  }

  /// Sign up with email and password.
  ///
  /// Creates a new user account.
  Future<AuthResult> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email.trim(),
        password: password,
        data: fullName != null ? {'full_name': fullName} : null,
      );

      if (response.user == null) {
        return AuthResult.failure('Đăng ký thất bại. Vui lòng thử lại.');
      }

      debugPrint('✅ SignUp successful: ${response.user!.email}');

      return AuthResult.success(
        user: response.user,
        role: UserRole.customer, // New users are customers by default
        message: 'Đăng ký thành công! Vui lòng kiểm tra email để xác nhận.',
      );
    } on AuthException catch (e) {
      debugPrint('❌ SignUp AuthException: ${e.message}');
      return AuthResult.failure(_mapAuthError(e.message));
    } catch (e) {
      debugPrint('❌ SignUp error: $e');
      return AuthResult.failure('Đã xảy ra lỗi. Vui lòng thử lại.');
    }
  }

  /// Sign out current user.
  Future<AuthResult> logout() async {
    try {
      await _client.auth.signOut();
      debugPrint('✅ Logout successful');
      return AuthResult.success(message: 'Đã đăng xuất.');
    } catch (e) {
      debugPrint('❌ Logout error: $e');
      return AuthResult.failure('Đăng xuất thất bại. Vui lòng thử lại.');
    }
  }

  /// Get current user's role from profiles table.
  ///
  /// Returns [UserRole.unknown] if not found.
  Future<UserRole> getUserRole() async {
    try {
      final user = currentUser;
      if (user == null) {
        debugPrint('⚠️ getUserRole: No current user');
        return UserRole.unknown;
      }

      final response = await _client
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .maybeSingle();

      if (response == null) {
        debugPrint('⚠️ getUserRole: No profile found for user ${user.id}');
        return UserRole.customer; // Default to customer if no profile
      }

      final role = UserRole.fromString(response['role'] as String?);
      debugPrint('✅ getUserRole: ${user.email} -> $role');
      return role;
    } catch (e) {
      debugPrint('❌ getUserRole error: $e');
      return UserRole.unknown;
    }
  }

  /// Map Supabase auth error messages to Vietnamese.
  String _mapAuthError(String message) {
    final lowerMessage = message.toLowerCase();

    if (lowerMessage.contains('invalid login credentials') ||
        lowerMessage.contains('invalid_credentials')) {
      return 'Email hoặc mật khẩu không đúng.';
    }
    if (lowerMessage.contains('email not confirmed')) {
      return 'Email chưa được xác nhận. Vui lòng kiểm tra hộp thư.';
    }
    if (lowerMessage.contains('user already registered') ||
        lowerMessage.contains('already been registered')) {
      return 'Email này đã được đăng ký.';
    }
    if (lowerMessage.contains('password')) {
      return 'Mật khẩu phải có ít nhất 6 ký tự.';
    }
    if (lowerMessage.contains('email')) {
      return 'Email không hợp lệ.';
    }
    if (lowerMessage.contains('network') || lowerMessage.contains('socket')) {
      return 'Lỗi kết nối mạng. Vui lòng kiểm tra internet.';
    }

    return message;
  }
}

/// Provider for AuthRepository.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(Supabase.instance.client);
});

/// Provider for current user role.
final userRoleProvider = FutureProvider<UserRole>((ref) async {
  final authRepo = ref.watch(authRepositoryProvider);
  return authRepo.getUserRole();
});

/// Provider for auth state stream.
final authStateProvider = StreamProvider<AuthState>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return authRepo.authStateChanges;
});
