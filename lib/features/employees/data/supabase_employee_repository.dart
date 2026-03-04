import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Model cho Nhân viên từ Supabase
/// Mapping với bảng: nhan_vien
/// Cột: manv, honv, tennv, chucvu, taikhoan, matkhau
class SupabaseEmployee {
  final String id; // manv
  final String? lastName; // honv
  final String? firstName; // tennv
  final String? position; // chucvu
  final String? username; // taikhoan
  // Không lưu matkhau vì lý do bảo mật

  SupabaseEmployee({
    required this.id,
    this.lastName,
    this.firstName,
    this.position,
    this.username,
  });

  factory SupabaseEmployee.fromJson(Map<String, dynamic> json) {
    return SupabaseEmployee(
      id: json['manv'] as String,
      lastName: json['honv'] as String?,
      firstName: json['tennv'] as String?,
      position: json['chucvu'] as String?,
      username: json['taikhoan'] as String?,
    );
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'manv': id,
      'honv': lastName,
      'tennv': firstName,
      'chucvu': position,
      'taikhoan': username,
    };
  }

  /// Tên đầy đủ của nhân viên
  String get fullName {
    final parts = <String>[];
    if (lastName != null && lastName!.isNotEmpty) parts.add(lastName!);
    if (firstName != null && firstName!.isNotEmpty) parts.add(firstName!);
    return parts.isEmpty ? 'Chưa có tên' : parts.join(' ');
  }

  /// Tên hiển thị ngắn (tên + họ)
  String get displayName => firstName ?? lastName ?? id;
}

/// Repository để quản lý nhân viên từ Supabase
class SupabaseEmployeeRepository {
  final SupabaseClient _client;
  static const _tableName = 'nhan_vien';

  SupabaseEmployeeRepository(this._client);

  /// Lấy tất cả nhân viên
  Future<List<SupabaseEmployee>> getAllEmployees() async {
    try {
      final response = await _client
          .from(_tableName)
          .select('manv, honv, tennv, chucvu, taikhoan')
          .order('tennv', ascending: true);

      return (response as List)
          .map((json) => SupabaseEmployee.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Lỗi khi lấy danh sách nhân viên: $e');
    }
  }

  /// Lấy nhân viên theo ID
  Future<SupabaseEmployee?> getEmployeeById(String id) async {
    try {
      final response = await _client
          .from(_tableName)
          .select('manv, honv, tennv, chucvu, taikhoan')
          .eq('manv', id)
          .maybeSingle();

      if (response == null) return null;
      return SupabaseEmployee.fromJson(response);
    } catch (e) {
      throw Exception('Lỗi khi lấy thông tin nhân viên: $e');
    }
  }

  /// Tạo nhân viên mới
  Future<SupabaseEmployee> createEmployee({
    required String id,
    String? lastName,
    String? firstName,
    String? position,
    String? username,
    String? password,
  }) async {
    try {
      final data = {
        'manv': id,
        'honv': lastName,
        'tennv': firstName,
        'chucvu': position,
        'taikhoan': username,
        if (password != null) 'matkhau': password,
      };

      final response = await _client
          .from(_tableName)
          .insert(data)
          .select('manv, honv, tennv, chucvu, taikhoan')
          .single();

      return SupabaseEmployee.fromJson(response);
    } catch (e) {
      throw Exception('Lỗi khi tạo nhân viên: $e');
    }
  }

  /// Cập nhật thông tin nhân viên
  Future<SupabaseEmployee> updateEmployee({
    required String id,
    String? lastName,
    String? firstName,
    String? position,
    String? username,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (lastName != null) data['honv'] = lastName;
      if (firstName != null) data['tennv'] = firstName;
      if (position != null) data['chucvu'] = position;
      if (username != null) data['taikhoan'] = username;

      final response = await _client
          .from(_tableName)
          .update(data)
          .eq('manv', id)
          .select('manv, honv, tennv, chucvu, taikhoan')
          .single();

      return SupabaseEmployee.fromJson(response);
    } catch (e) {
      throw Exception('Lỗi khi cập nhật nhân viên: $e');
    }
  }

  /// Xóa nhân viên
  Future<void> deleteEmployee(String id) async {
    try {
      await _client.from(_tableName).delete().eq('manv', id);
    } catch (e) {
      throw Exception('Lỗi khi xóa nhân viên: $e');
    }
  }

  /// Đếm tổng số nhân viên
  Future<int> countEmployees() async {
    try {
      final response = await _client.from(_tableName).select('manv');
      return (response as List).length;
    } catch (e) {
      throw Exception('Lỗi khi đếm nhân viên: $e');
    }
  }
}

/// Provider cho SupabaseEmployeeRepository
final supabaseEmployeeRepositoryProvider =
    Provider<SupabaseEmployeeRepository>((ref) {
  return SupabaseEmployeeRepository(Supabase.instance.client);
});

/// Provider để lấy danh sách tất cả nhân viên
final employeesSupabaseProvider =
    FutureProvider.autoDispose<List<SupabaseEmployee>>((ref) async {
  final repository = ref.watch(supabaseEmployeeRepositoryProvider);
  return repository.getAllEmployees();
});
