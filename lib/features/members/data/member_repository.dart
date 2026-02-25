import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;

import 'package_repository.dart';

/// Model cho Hội viên (Độc giả) từ Supabase
/// Mapping với bảng: doc_gia
/// Cột: MaDG, HoDG, TenLotDG, TenDG, NgaySinh, SDT, cccd, Email, DiaChi, NgayHetHanGoi, SoDuVi, DiemTichLuy, TrangThai, MaGoi, avatar_url
class SupabaseMember {
  final String id; // MaDG
  final String? lastName; // HoDG
  final String? middleName; // TenLotDG
  final String? firstName; // TenDG
  final DateTime? dateOfBirth; // NgaySinh
  final String? phone; // SDT
  final String nationalId; // cccd
  final String email; // Email
  final String? address; // DiaChi
  final DateTime? subscriptionExpiryDate; // NgayHetHanGoi
  final int walletBalance; // SoDuVi
  final int points; // DiemTichLuy
  final bool isActive; // TrangThai (bit)
  final String packageId; // MaGoi
  final String? avatarUrl; // avatar_url

  // Thông tin gói hội viên (từ join)
  final SupabasePackage? package;

  SupabaseMember({
    required this.id,
    this.lastName,
    this.middleName,
    this.firstName,
    this.dateOfBirth,
    this.phone,
    required this.nationalId,
    required this.email,
    this.address,
    this.subscriptionExpiryDate,
    this.walletBalance = 0,
    this.points = 0,
    this.isActive = true,
    required this.packageId,
    this.avatarUrl,
    this.package,
  });

  factory SupabaseMember.fromJson(Map<String, dynamic> json) {
    // Helper để parse số
    int parseIntOrDefault(dynamic value, int defaultValue) {
      if (value == null) return defaultValue;
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString()) ?? defaultValue;
    }

    // Parse bool từ bit (có thể là int 0/1 hoặc bool)
    bool parseBool(dynamic value) {
      if (value == null) return true;
      if (value is bool) return value;
      if (value is int) return value != 0;
      if (value is String) return value.toLowerCase() == 'true' || value == '1';
      return true;
    }

    // Parse DateTime
    DateTime? parseDateTime(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      return DateTime.tryParse(value.toString());
    }

    // Parse thông tin gói hội viên từ join
    SupabasePackage? package;
    if (json['goi_hoi_vien'] != null && json['goi_hoi_vien'] is Map) {
      package = SupabasePackage.fromJson(json['goi_hoi_vien'] as Map<String, dynamic>);
    }    return SupabaseMember(
      id: json['madg'] as String,
      lastName: json['hodg'] as String?,
      middleName: json['tenlotdg'] as String?,
      firstName: json['tendg'] as String?,
      dateOfBirth: parseDateTime(json['ngaysinh']),
      phone: json['sdt'] as String?,
      nationalId: json['cccd'] as String,
      email: json['email'] as String,
      address: json['diachi'] as String?,
      subscriptionExpiryDate: parseDateTime(json['ngayhethangoi']),
      walletBalance: parseIntOrDefault(json['soduvi'], 0),
      points: parseIntOrDefault(json['diemtichluy'], 0),
      isActive: parseBool(json['trangthai']),
      packageId: json['magoi'] as String,
      avatarUrl: json['avatar_url'] as String?,
      package: package,
    );
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'madg': id,
      'hodg': lastName,
      'tenlotdg': middleName,
      'tendg': firstName,
      'ngaysinh': dateOfBirth?.toIso8601String(),
      'sdt': phone,
      'cccd': nationalId,
      'email': email,
      'diachi': address,
      'ngayhethangoi': subscriptionExpiryDate?.toIso8601String(),
      'soduvi': walletBalance,
      'diemtichluy': points,
      'trangthai': isActive,
      'magoi': packageId,
      'avatar_url': avatarUrl,
    };
  }

  /// Lấy họ tên đầy đủ
  String get fullName {
    final parts = [lastName, middleName, firstName]
        .where((e) => (e ?? '').trim().isNotEmpty)
        .map((e) => e!.trim())
        .toList();
    return parts.isEmpty ? id : parts.join(' ');
  }

  /// Lấy tên gói hội viên
  String get packageName => package?.name ?? packageId;

  /// Kiểm tra gói còn hiệu lực
  bool get isSubscriptionActive {
    if (subscriptionExpiryDate == null) return true;
    return subscriptionExpiryDate!.isAfter(DateTime.now());
  }

  @override
  String toString() => 'SupabaseMember($id, $fullName)';
}

/// Repository để quản lý Hội viên trên Supabase
class SupabaseMemberRepository {
  SupabaseMemberRepository(this._client);

  final SupabaseClient _client;

  static const String _tableName = 'doc_gia';
  static const String _storageBucket = 'avatars';

  // ==================== UPLOAD AVATAR ====================

  /// Upload avatar lên Supabase Storage
  /// Trả về URL công khai của ảnh
  Future<String> uploadAvatar(File imageFile) async {
    try {
      // Tạo tên file unique
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${path.basename(imageFile.path)}';
      final filePath = 'members/$fileName';

      // Upload file
      await _client.storage.from(_storageBucket).upload(
            filePath,
            imageFile,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: false,
            ),
          );

      // Lấy URL công khai
      final publicUrl =
          _client.storage.from(_storageBucket).getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      throw Exception('Lỗi khi upload avatar: $e');
    }
  }

  /// Xóa avatar khỏi Storage
  Future<void> deleteAvatar(String imageUrl) async {
    try {
      // Extract path from URL
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;

      // Tìm vị trí 'members' trong path
      final membersIndex = pathSegments.indexOf('members');
      if (membersIndex == -1) return;

      final filePath = pathSegments.sublist(membersIndex).join('/');

      await _client.storage.from(_storageBucket).remove([filePath]);
    } catch (e) {
      // Không throw lỗi nếu xóa ảnh thất bại
      debugPrint('Warning: Không thể xóa avatar: $e');
    }
  }

  // ==================== QUERY MEMBERS ====================

  /// Select statement với join để lấy thông tin gói hội viên
  static const String _selectWithJoins = '''
    *,
    goi_hoi_vien(*)
  ''';
  /// Lấy danh sách tất cả hội viên (kèm thông tin gói)
  Future<List<SupabaseMember>> getMembers() async {
    try {
      final response = await _client
          .from(_tableName)
          .select(_selectWithJoins)
          .order('madg', ascending: true);

      return (response as List)
          .map((json) => SupabaseMember.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Lỗi khi lấy danh sách hội viên: $e');
    }
  }
  /// Tìm kiếm hội viên theo từ khóa (tên, SĐT, mã)
  Future<List<SupabaseMember>> searchMembers(String keyword) async {
    try {
      final response = await _client
          .from(_tableName)
          .select(_selectWithJoins)
          .or('hodg.ilike.%$keyword%,tenlotdg.ilike.%$keyword%,tendg.ilike.%$keyword%,sdt.ilike.%$keyword%,madg.ilike.%$keyword%')
          .order('madg', ascending: true);

      return (response as List)
          .map((json) => SupabaseMember.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Lỗi khi tìm kiếm hội viên: $e');
    }
  }
  /// Lấy hội viên theo ID
  Future<SupabaseMember?> getMemberById(String id) async {
    try {
      final response = await _client
          .from(_tableName)
          .select(_selectWithJoins)
          .eq('madg', id)
          .maybeSingle();

      if (response == null) return null;
      return SupabaseMember.fromJson(response);
    } catch (e) {
      throw Exception('Lỗi khi lấy hội viên: $e');
    }
  }
  /// Thêm hội viên mới
  /// [avatarFile] - File avatar (optional), sẽ được upload lên Storage
  Future<SupabaseMember> addMember({
    required String id,
    String? lastName,
    String? middleName,
    String? firstName,
    DateTime? dateOfBirth,
    String? phone,
    required String nationalId,
    required String email,
    String? address,
    DateTime? subscriptionExpiryDate,
    int walletBalance = 0,
    int points = 0,
    bool isActive = true,
    required String packageId,
    String? avatarUrl,
    File? avatarFile,
  }) async {
    try {
      // Upload avatar nếu có file
      String? finalAvatarUrl = avatarUrl;
      if (avatarFile != null) {
        finalAvatarUrl = await uploadAvatar(avatarFile);
      }      final response = await _client
          .from(_tableName)
          .insert({
            'madg': id,
            'hodg': lastName,
            'tenlotdg': middleName,
            'tendg': firstName,
            'ngaysinh': dateOfBirth?.toIso8601String(),
            'sdt': phone,
            'cccd': nationalId,
            'email': email,
            'diachi': address,
            'ngayhethangoi': subscriptionExpiryDate?.toIso8601String(),
            'soduvi': walletBalance,
            'diemtichluy': points,
            'trangthai': isActive,
            'magoi': packageId,
            'avatar_url': finalAvatarUrl,
          })
          .select(_selectWithJoins)
          .single();

      return SupabaseMember.fromJson(response);
    } catch (e) {
      throw Exception('Lỗi khi thêm hội viên: $e');
    }
  }
  /// Cập nhật hội viên
  /// [avatarFile] - File avatar mới (optional), sẽ được upload lên Storage
  Future<SupabaseMember> updateMember({
    required String id,
    String? lastName,
    String? middleName,
    String? firstName,
    DateTime? dateOfBirth,
    String? phone,
    String? nationalId,
    String? email,
    String? address,
    DateTime? subscriptionExpiryDate,
    int? walletBalance,
    int? points,
    bool? isActive,
    String? packageId,
    String? avatarUrl,
    File? avatarFile,
  }) async {
    try {
      // Upload avatar mới nếu có file
      String? finalAvatarUrl = avatarUrl;
      if (avatarFile != null) {
        finalAvatarUrl = await uploadAvatar(avatarFile);
      }

      final updateData = <String, dynamic>{};
      if (lastName != null) updateData['hodg'] = lastName;
      if (middleName != null) updateData['tenlotdg'] = middleName;
      if (firstName != null) updateData['tendg'] = firstName;
      if (dateOfBirth != null) updateData['ngaysinh'] = dateOfBirth.toIso8601String();
      if (phone != null) updateData['sdt'] = phone;
      if (nationalId != null) updateData['cccd'] = nationalId;
      if (email != null) updateData['email'] = email;
      if (address != null) updateData['diachi'] = address;
      if (subscriptionExpiryDate != null) {
        updateData['ngayhethangoi'] = subscriptionExpiryDate.toIso8601String();
      }
      if (walletBalance != null) updateData['soduvi'] = walletBalance;
      if (points != null) updateData['diemtichluy'] = points;
      if (isActive != null) updateData['trangthai'] = isActive;
      if (packageId != null) updateData['magoi'] = packageId;
      if (finalAvatarUrl != null) updateData['avatar_url'] = finalAvatarUrl;

      if (updateData.isEmpty) {
        final current = await getMemberById(id);
        if (current == null) throw Exception('Không tìm thấy hội viên');
        return current;
      }

      final response = await _client
          .from(_tableName)
          .update(updateData)
          .eq('madg', id)
          .select(_selectWithJoins)
          .single();

      return SupabaseMember.fromJson(response);
    } catch (e) {
      throw Exception('Lỗi khi cập nhật hội viên: $e');
    }
  }

  /// Xóa hội viên
  Future<void> deleteMember(String id) async {
    try {
      await _client.from(_tableName).delete().eq('madg', id);
    } catch (e) {
      throw Exception('Lỗi khi xóa hội viên: $e');
    }
  }

  /// Nạp tiền vào ví
  Future<SupabaseMember> topUpWallet(String memberId, int amount) async {
    if (amount <= 0) {
      throw ArgumentError('Số tiền phải là số dương');
    }

    try {
      final member = await getMemberById(memberId);
      if (member == null) {
        throw StateError('Không tìm thấy hội viên: $memberId');
      }

      final newBalance = member.walletBalance + amount;

      return updateMember(id: memberId, walletBalance: newBalance);
    } catch (e) {
      throw Exception('Lỗi khi nạp tiền: $e');
    }
  }

  /// Trừ tiền từ ví
  Future<SupabaseMember> deductWallet(String memberId, int amount, {bool allowNegative = false}) async {
    if (amount <= 0) {
      throw ArgumentError('Số tiền phải là số dương');
    }

    try {
      final member = await getMemberById(memberId);
      if (member == null) {
        throw StateError('Không tìm thấy hội viên: $memberId');
      }

      if (!allowNegative && member.walletBalance < amount) {
        throw StateError('Số dư không đủ. Hiện có: ${member.walletBalance} VNĐ');
      }

      final newBalance = member.walletBalance - amount;

      return updateMember(id: memberId, walletBalance: newBalance);
    } catch (e) {
      throw Exception('Lỗi khi trừ tiền: $e');
    }
  }

  /// Cập nhật điểm tích lũy
  Future<SupabaseMember> updatePoints(String memberId, int pointsToAdd) async {
    try {
      final member = await getMemberById(memberId);
      if (member == null) {
        throw StateError('Không tìm thấy hội viên: $memberId');
      }

      final newPoints = member.points + pointsToAdd;
      final finalPoints = newPoints < 0 ? 0 : newPoints;

      return updateMember(id: memberId, points: finalPoints);
    } catch (e) {
      throw Exception('Lỗi khi cập nhật điểm: $e');
    }
  }
  /// Tạo mã hội viên mới
  Future<String> generateNextMemberId() async {
    try {
      final response = await _client
          .from(_tableName)
          .select('madg')
          .order('madg', ascending: false)
          .limit(10);

      final rows = response as List;
      if (rows.isEmpty) return 'DG001';

      final regex = RegExp(r'^DG(\d+)$', caseSensitive: false);

      var maxValue = 0;
      for (final row in rows) {
        final id = row['madg'] as String?;
        if (id == null) continue;

        final match = regex.firstMatch(id.trim());
        if (match == null) continue;

        final value = int.tryParse(match.group(1) ?? '');
        if (value == null) continue;
        if (value > maxValue) maxValue = value;
      }

      final next = maxValue + 1;
      final padded = next.toString().padLeft(3, '0');
      return 'DG$padded';
    } catch (e) {
      debugPrint('Warning: Không thể tạo mã hội viên: $e');
      return 'DG${DateTime.now().millisecondsSinceEpoch % 10000}';
    }
  }
  /// Đếm tổng số hội viên
  Future<int> countMembers() async {
    try {
      final response = await _client
          .from(_tableName)
          .select('madg');
      return (response as List).length;
    } catch (e) {
      throw Exception('Lỗi khi đếm hội viên: $e');
    }
  }

  /// Lấy thống kê hội viên
  Future<Map<String, int>> getMemberStatistics() async {
    try {
      final allMembers = await getMembers();
      
      final activeCount = allMembers.where((m) => m.isActive).length;
      final inactiveCount = allMembers.where((m) => !m.isActive).length;
      final expiredCount = allMembers.where((m) => !m.isSubscriptionActive).length;

      return {
        'total': allMembers.length,
        'active': activeCount,
        'inactive': inactiveCount,
        'expired': expiredCount,
      };
    } catch (e) {
      throw Exception('Lỗi khi lấy thống kê hội viên: $e');
    }
  }
}

/// Provider cho SupabaseMemberRepository
final supabaseMemberRepositoryProvider = Provider<SupabaseMemberRepository>((ref) {
  return SupabaseMemberRepository(Supabase.instance.client);
});

/// Provider để lấy danh sách hội viên
final supabaseMembersProvider = FutureProvider<List<SupabaseMember>>((ref) async {
  final repository = ref.watch(supabaseMemberRepositoryProvider);
  return repository.getMembers();
});

/// Provider để tìm kiếm hội viên
final supabaseMemberSearchProvider = FutureProvider.family<List<SupabaseMember>, String>((ref, keyword) async {
  final repository = ref.watch(supabaseMemberRepositoryProvider);
  if (keyword.isEmpty) {
    return repository.getMembers();
  }
  return repository.searchMembers(keyword);
});

/// Provider để lấy hội viên theo ID
final supabaseMemberByIdProvider = FutureProvider.family<SupabaseMember?, String>((ref, id) async {
  final repository = ref.watch(supabaseMemberRepositoryProvider);
  return repository.getMemberById(id);
});

/// Provider để tạo mã hội viên mới
final generateSupabaseMemberIdProvider = FutureProvider<String>((ref) async {
  final repository = ref.watch(supabaseMemberRepositoryProvider);
  return repository.generateNextMemberId();
});
