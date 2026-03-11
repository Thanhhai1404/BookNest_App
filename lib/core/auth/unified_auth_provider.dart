import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ============================================================================
// Unified Auth Provider - Hợp nhất xác thực cho cả Admin, Thủ thư và Hội viên
// ============================================================================

/// Các vai trò trong hệ thống
enum UserRole {
  admin,     // Quản lý - chỉ xem Dashboard
  librarian, // Thủ thư - toàn bộ nghiệp vụ
  member,    // Hội viên - User Portal
}

/// Thông tin user sau khi đăng nhập (dùng chung cho cả 3 role)
class AppUser {
  final String id;
  final String? lastName;
  final String? middleName;
  final String? firstName;
  final String? phone;
  final String? email;
  final UserRole role;
  
  // Chỉ dành cho Member
  final int walletBalance;
  final int points;
  final int credibilityScore;
  final String? avatarUrl;
  final String? subscriptionId;
  final DateTime? subscriptionExpiry;

  // Chỉ dành cho Employee
  final String? position;
  final String? username;

  const AppUser({
    required this.id,
    this.lastName,
    this.middleName,
    this.firstName,
    this.phone,
    this.email,
    required this.role,
    this.walletBalance = 0,
    this.points = 0,
    this.credibilityScore = 100,
    this.avatarUrl,
    this.subscriptionId,
    this.subscriptionExpiry,
    this.position,
    this.username,
  });

  /// Họ tên đầy đủ
  String get fullName {
    final parts = [lastName, middleName, firstName]
        .where((e) => (e ?? '').trim().isNotEmpty)
        .map((e) => e!.trim())
        .toList();
    return parts.isEmpty ? id : parts.join(' ');
  }

  /// Tên hiển thị ngắn
  String get displayName => firstName ?? lastName ?? id;

  /// Nhãn role tiếng Việt
  String get roleLabel {
    switch (role) {
      case UserRole.admin:
        return 'Quản lý';
      case UserRole.librarian:
        return 'Thủ thư';
      case UserRole.member:
        return 'Hội viên';
    }
  }

  /// Có gói hội viên active không (chỉ Member)
  bool get hasActiveSubscription {
    if (role != UserRole.member) return false;
    if (subscriptionId == null || subscriptionId!.isEmpty) return false;
    if (subscriptionExpiry == null) return true;
    return subscriptionExpiry!.isAfter(DateTime.now());
  }

  /// Parse từ bảng nhan_vien
  factory AppUser.fromEmployee(Map<String, dynamic> json) {
    final positionStr = (json['chucvu'] as String?)?.toLowerCase() ?? '';
    final isAdmin = positionStr.contains('quản lý') ||
        positionStr.contains('quan ly') ||
        positionStr.contains('manager') ||
        positionStr.contains('admin');

    return AppUser(
      id: json['manv'] as String,
      lastName: json['honv'] as String?,
      firstName: json['tennv'] as String?,
      position: json['chucvu'] as String?,
      username: json['taikhoan'] as String?,
      role: isAdmin ? UserRole.admin : UserRole.librarian,
    );
  }

  /// Parse từ bảng doc_gia
  factory AppUser.fromMember(Map<String, dynamic> json) {
    return AppUser(
      id: json['madg'] as String,
      lastName: json['hodg'] as String?,
      middleName: json['tenlotdg'] as String?,
      firstName: json['tendg'] as String?,
      phone: json['sdt'] as String?,
      email: json['email'] as String?,
      role: UserRole.member,
      walletBalance: (json['soduvi'] as num?)?.toInt() ?? 0,
      points: (json['diemtichluy'] as num?)?.toInt() ?? 0,
      credibilityScore: (json['diem_tin_nhiem'] as num?)?.toInt() ?? 100,
      avatarUrl: json['avatar_url'] as String?,
      subscriptionId: json['magoi'] as String?,
      subscriptionExpiry: json['ngayhethangoi'] != null
          ? DateTime.tryParse(json['ngayhethangoi'] as String)
          : null,
    );
  }
}

/// Auth State
class UnifiedAuthState {
  final AppUser? currentUser;
  final bool isLoading;
  final String? error;

  const UnifiedAuthState({
    this.currentUser,
    this.isLoading = false,
    this.error,
  });

  bool get isLoggedIn => currentUser != null;

  UnifiedAuthState copyWith({
    AppUser? currentUser,
    bool? isLoading,
    String? error,
    bool clearUser = false,
  }) {
    return UnifiedAuthState(
      currentUser: clearUser ? null : (currentUser ?? this.currentUser),
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Unified Auth Notifier
class UnifiedAuthNotifier extends Notifier<UnifiedAuthState> {
  @override
  UnifiedAuthState build() {
    return const UnifiedAuthState();
  }

  /// Đăng nhập hợp nhất
  /// - Nếu tìm thấy trong nhan_vien -> Admin/Librarian
  /// - Nếu không, tìm trong doc_gia -> Member
  Future<bool> login(String identifier, String password) async {
    if (identifier.trim().isEmpty || password.isEmpty) {
      throw Exception('Vui lòng nhập đầy đủ tài khoản và mật khẩu');
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final client = Supabase.instance.client;
      final input = identifier.trim();

      // ============ BƯỚC 1: Kiểm tra bảng nhan_vien ============
      Map<String, dynamic>? empResponse;
      
      // Thử tìm theo taikhoan
      empResponse = await client
          .from('nhan_vien')
          .select()
          .eq('taikhoan', input)
          .eq('matkhau', password)
          .maybeSingle();

      // Nếu không tìm thấy theo taikhoan, thử theo manv
      if (empResponse == null) {
        empResponse = await client
            .from('nhan_vien')
            .select()
            .eq('manv', input.toUpperCase())
            .eq('matkhau', password)
            .maybeSingle();
      }

      if (empResponse != null) {
        // Đăng nhập thành công với tư cách nhân viên
        final user = AppUser.fromEmployee(empResponse);
        state = state.copyWith(
          currentUser: user,
          isLoading: false,
          error: null,
        );
        return true;
      }

      // ============ BƯỚC 2: Kiểm tra bảng doc_gia ============
      Map<String, dynamic>? memberResponse;

      // Xác định input là SĐT hay mã độc giả
      final bool isPhone = RegExp(r'^[0-9]').hasMatch(input);

      if (isPhone) {
        // Đăng nhập bằng SĐT
        memberResponse = await client
            .from('doc_gia')
            .select()
            .eq('sdt', input)
            .eq('matkhau', password)
            .maybeSingle();
      } else {
        // Đăng nhập bằng mã độc giả (madg)
        memberResponse = await client
            .from('doc_gia')
            .select()
            .eq('madg', input.toUpperCase())
            .eq('matkhau', password)
            .maybeSingle();
      }

      if (memberResponse != null) {
        // Đăng nhập thành công với tư cách hội viên
        final user = AppUser.fromMember(memberResponse);
        state = state.copyWith(
          currentUser: user,
          isLoading: false,
          error: null,
        );
        return true;
      }

      // ============ KHÔNG TÌM THẤY ============
      state = state.copyWith(
        isLoading: false,
        error: 'Sai tài khoản hoặc mật khẩu',
      );
      throw Exception('Sai tài khoản hoặc mật khẩu');
    } catch (e) {
      if (e.toString().contains('Sai tài khoản')) rethrow;
      state = state.copyWith(
        isLoading: false,
        error: 'Lỗi đăng nhập: ${e.toString().replaceAll('Exception: ', '')}',
      );
      rethrow;
    }
  }

  /// Đăng ký Member mới
  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    String? lastName,
    String? phone,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final client = Supabase.instance.client;

      // Tạo mã DG mới
      final countResp = await client.from('doc_gia').select('madg');
      final newId = 'DG${(countResp.length + 1).toString().padLeft(4, '0')}';

      await client.from('doc_gia').insert({
        'madg': newId,
        'tendg': firstName.trim(),
        'hodg': (lastName ?? '').trim(),
        'email': email.trim(),
        'sdt': phone?.trim(),
        'matkhau': password,
        'soduvi': 0,
        'diemtichluy': 0,
        'diem_tin_nhiem': 100,
        'trangthai': true,
        'cccd': '',
      });

      // Auto-login
      return login(newId, password);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Lỗi đăng ký: ${e.toString().replaceAll('Exception: ', '')}',
      );
      rethrow;
    }
  }

  /// Đăng xuất
  void logout() {
    state = const UnifiedAuthState();
  }
}

// ======================== Providers ========================

final unifiedAuthProvider =
    NotifierProvider<UnifiedAuthNotifier, UnifiedAuthState>(
        UnifiedAuthNotifier.new);

/// Provider tiện ích để lấy user hiện tại
final currentUserProvider = Provider<AppUser?>((ref) {
  return ref.watch(unifiedAuthProvider).currentUser;
});

/// Provider kiểm tra trạng thái đăng nhập
final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(unifiedAuthProvider).isLoggedIn;
});

/// Provider lấy role hiện tại
final currentRoleProvider = Provider<UserRole?>((ref) {
  return ref.watch(unifiedAuthProvider).currentUser?.role;
});
