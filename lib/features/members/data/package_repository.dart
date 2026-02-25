import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Model cho Gói hội viên từ Supabase
/// Mapping với bảng: goi_hoi_vien
/// Cột: MaGoi (varchar PK), TenGoi, PhiThang, TienCoc, SoSachToiDa, SoNgayMuon, MoTa
class SupabasePackage {
  final String id; // MaGoi
  final String? name; // TenGoi
  final int? monthlyFee; // PhiThang
  final int? deposit; // TienCoc
  final int? maxBooks; // SoSachToiDa
  final int? maxDays; // SoNgayMuon
  final String? description; // MoTa

  SupabasePackage({
    required this.id,
    this.name,
    this.monthlyFee,
    this.deposit,
    this.maxBooks,
    this.maxDays,
    this.description,
  });

  factory SupabasePackage.fromJson(Map<String, dynamic> json) {
    // Helper để parse số (có thể là num hoặc int)
    int? parseIntOrNull(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString());
    }    return SupabasePackage(
      id: json['magoi'] as String,
      name: json['tengoi'] as String?,
      monthlyFee: parseIntOrNull(json['phithang']),
      deposit: parseIntOrNull(json['tiencoc']),
      maxBooks: parseIntOrNull(json['sosachtoida']),
      maxDays: parseIntOrNull(json['songaymuon']),
      description: json['mota'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'magoi': id,
      'tengoi': name,
      'phithang': monthlyFee,
      'tiencoc': deposit,
      'sosachtoida': maxBooks,
      'songaymuon': maxDays,
      'mota': description,
    };
  }

  /// Hiển thị tên gói (dùng cho Dropdown)
  String get displayName => name ?? id;

  /// Format phí tháng
  String get formattedMonthlyFee {
    if (monthlyFee == null) return 'Miễn phí';
    return '${_formatNumber(monthlyFee!)} VNĐ/tháng';
  }

  /// Format tiền cọc
  String get formattedDeposit {
    if (deposit == null || deposit == 0) return 'Không cọc';
    return '${_formatNumber(deposit!)} VNĐ';
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  @override
  String toString() => 'SupabasePackage($id, $name)';
}

/// Repository để quản lý Gói hội viên trên Supabase
class PackageRepository {
  PackageRepository(this._client);

  final SupabaseClient _client;

  static const String _tableName = 'goi_hoi_vien';
  /// Lấy danh sách tất cả gói hội viên
  Future<List<SupabasePackage>> getPackages() async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .order('magoi', ascending: true);

      return (response as List)
          .map((json) => SupabasePackage.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Lỗi khi lấy danh sách gói hội viên: $e');
    }
  }
  /// Lấy gói theo ID
  Future<SupabasePackage?> getPackageById(String id) async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('magoi', id)
          .maybeSingle();

      if (response == null) return null;
      return SupabasePackage.fromJson(response);
    } catch (e) {
      throw Exception('Lỗi khi lấy gói hội viên: $e');
    }
  }

  /// Thêm gói mới
  Future<SupabasePackage> addPackage({
    required String id,
    String? name,
    int? monthlyFee,
    int? deposit,
    int? maxBooks,
    int? maxDays,
    String? description,
  }) async {
    try {      final response = await _client
          .from(_tableName)
          .insert({
            'magoi': id,
            'tengoi': name,
            'phithang': monthlyFee,
            'tiencoc': deposit,
            'sosachtoida': maxBooks,
            'songaymuon': maxDays,
            'mota': description,
          })
          .select()
          .single();

      return SupabasePackage.fromJson(response);
    } catch (e) {
      throw Exception('Lỗi khi thêm gói hội viên: $e');
    }
  }

  /// Cập nhật gói
  Future<SupabasePackage> updatePackage({
    required String id,
    String? name,
    int? monthlyFee,
    int? deposit,
    int? maxBooks,
    int? maxDays,
    String? description,
  }) async {    try {
      final updateData = <String, dynamic>{};
      if (name != null) updateData['tengoi'] = name;
      if (monthlyFee != null) updateData['phithang'] = monthlyFee;
      if (deposit != null) updateData['tiencoc'] = deposit;
      if (maxBooks != null) updateData['sosachtoida'] = maxBooks;
      if (maxDays != null) updateData['songaymuon'] = maxDays;
      if (description != null) updateData['mota'] = description;

      if (updateData.isEmpty) {
        final current = await getPackageById(id);
        if (current == null) throw Exception('Không tìm thấy gói hội viên');
        return current;
      }      final response = await _client
          .from(_tableName)
          .update(updateData)
          .eq('magoi', id)
          .select()
          .single();

      return SupabasePackage.fromJson(response);
    } catch (e) {
      throw Exception('Lỗi khi cập nhật gói hội viên: $e');
    }
  }

  /// Xóa gói
  Future<void> deletePackage(String id) async {
    try {
      await _client.from(_tableName).delete().eq('magoi', id);
    } catch (e) {
      throw Exception('Lỗi khi xóa gói hội viên: $e');
    }
  }
}

/// Provider cho PackageRepository
final packageRepositoryProvider = Provider<PackageRepository>((ref) {
  return PackageRepository(Supabase.instance.client);
});

/// Provider để lấy danh sách gói hội viên
final packagesProvider = FutureProvider<List<SupabasePackage>>((ref) async {
  final repository = ref.watch(packageRepositoryProvider);
  return repository.getPackages();
});
