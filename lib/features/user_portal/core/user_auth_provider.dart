import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/auth/unified_auth_provider.dart';

/// Thông tin Member đã đăng nhập
class UserMember {
  final String id;
  final String? lastName;
  final String? middleName;
  final String? firstName;
  final String? phone;
  final String email;
  final int walletBalance;
  final int points;
  final int credibilityScore;
  final String? avatarUrl;
  final String? subscriptionId;
  final DateTime? subscriptionExpiry;
  final bool isActive;

  const UserMember({
    required this.id,
    this.lastName,
    this.middleName,
    this.firstName,
    this.phone,
    required this.email,
    this.walletBalance = 0,
    this.points = 0,
    this.credibilityScore = 100,
    this.avatarUrl,
    this.subscriptionId,
    this.subscriptionExpiry,
    this.isActive = true,
  });

  /// Họ tên đầy đủ
  String get fullName {
    final parts = [lastName, middleName, firstName]
        .where((e) => (e ?? '').trim().isNotEmpty)
        .map((e) => e!.trim())
        .toList();
    return parts.isEmpty ? id : parts.join(' ');
  }

  /// Có gói hội viên active không
  bool get hasActiveSubscription {
    if (subscriptionId == null || subscriptionId!.isEmpty) return false;
    if (subscriptionExpiry == null) return true;
    return subscriptionExpiry!.isAfter(DateTime.now());
  }

  factory UserMember.fromJson(Map<String, dynamic> json) {
    return UserMember(
      id: json['madg'] as String,
      lastName: json['hodg'] as String?,
      middleName: json['tenlotdg'] as String?,
      firstName: json['tendg'] as String?,
      phone: json['sdt'] as String?,
      email: json['email'] as String? ?? '',
      walletBalance: (json['soduvi'] as num?)?.toInt() ?? 0,
      points: (json['diemtichluy'] as num?)?.toInt() ?? 0,
      credibilityScore: (json['diem_tin_nhiem'] as num?)?.toInt() ?? 100,
      avatarUrl: json['avatar_url'] as String?,
      subscriptionId: json['magoi'] as String?,
      subscriptionExpiry: json['ngayhethangoi'] != null
          ? DateTime.tryParse(json['ngayhethangoi'] as String)
          : null,
      isActive: json['trangthai'] == true || json['trangthai'] == 1,
    );
  }
}

/// State cho User Auth
class UserAuthState {
  final UserMember? currentMember;
  final bool isLoading;
  final String? error;

  const UserAuthState({
    this.currentMember,
    this.isLoading = false,
    this.error,
  });

  bool get isLoggedIn => currentMember != null;

  UserAuthState copyWith({
    UserMember? currentMember,
    bool? isLoading,
    String? error,
    bool clearMember = false,
  }) {
    return UserAuthState(
      currentMember:
          clearMember ? null : (currentMember ?? this.currentMember),
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier quản lý đăng nhập Member
class UserAuthNotifier extends Notifier<UserAuthState> {
  @override
  UserAuthState build() {
    return const UserAuthState();
  }
  /// Đăng nhập member bằng mã DG hoặc SĐT + mật khẩu
  Future<bool> login(String identifier, String password) async {
    if (identifier.trim().isEmpty || password.isEmpty) {
      throw Exception('Vui lòng nhập đầy đủ mã hội viên/SĐT và mật khẩu');
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final client = Supabase.instance.client;
      final input = identifier.trim();

      // Xác định: nếu bắt đầu bằng số (0-9) -> đăng nhập bằng SĐT
      // Ngược lại -> đăng nhập bằng mã độc giả (madg)
      final bool isPhone = RegExp(r'^[0-9]').hasMatch(input);

      Map<String, dynamic>? response;

      if (isPhone) {
        // Đăng nhập bằng SĐT
        response = await client
            .from('doc_gia')
            .select()
            .eq('sdt', input)
            .eq('matkhau', password)
            .maybeSingle();
      } else {
        // Đăng nhập bằng mã độc giả (madg)
        response = await client
            .from('doc_gia')
            .select()
            .eq('madg', input.toUpperCase())
            .eq('matkhau', password)
            .maybeSingle();
      }

      if (response == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'Sai mã hội viên/SĐT hoặc mật khẩu',
        );
        throw Exception('Sai mã hội viên/SĐT hoặc mật khẩu');
      }

      final member = UserMember.fromJson(response);

      state = state.copyWith(
        currentMember: member,
        isLoading: false,
        error: null,
      );

      return true;
    } catch (e) {
      if (e.toString().contains('Sai mã hội viên')) rethrow;
      state = state.copyWith(
        isLoading: false,
        error: 'Lỗi đăng nhập: ${e.toString().replaceAll('Exception: ', '')}',
      );
      rethrow;
    }
  }

  /// Đăng ký member mới
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
        'cccd': '', // national ID placeholder
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
  void logout() {
    state = const UserAuthState();
  }
}

/// Providers
final userAuthProvider =
    NotifierProvider<UserAuthNotifier, UserAuthState>(UserAuthNotifier.new);

final currentMemberProvider = Provider<UserMember?>((ref) {
  // Ưu tiên lấy từ unified auth nếu có
  final unifiedUser = ref.watch(unifiedCurrentMemberProvider);
  if (unifiedUser != null) return unifiedUser;
  
  // Fallback: lấy từ user auth provider cũ
  return ref.watch(userAuthProvider).currentMember;
});

final isMemberLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(userAuthProvider).isLoggedIn;
});

// ==================== BRIDGE TO UNIFIED AUTH ====================

/// Bridge provider: convert AppUser -> UserMember cho các UI pages cũ
final unifiedCurrentMemberProvider = Provider<UserMember?>((ref) {
  final appUser = ref.watch(currentUserProvider);
  if (appUser == null || appUser.role != UserRole.member) return null;
  
  return UserMember(
    id: appUser.id,
    lastName: appUser.lastName,
    middleName: appUser.middleName,
    firstName: appUser.firstName,
    phone: appUser.phone,
    email: appUser.email ?? '',
    walletBalance: appUser.walletBalance,
    points: appUser.points,
    credibilityScore: appUser.credibilityScore,
    avatarUrl: appUser.avatarUrl,
    subscriptionId: appUser.subscriptionId,
    subscriptionExpiry: appUser.subscriptionExpiry,
  );
});
