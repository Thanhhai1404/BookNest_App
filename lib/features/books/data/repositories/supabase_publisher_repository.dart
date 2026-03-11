import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Model cho Nhà xuất bản từ Supabase
/// Mapping với bảng: nha_xuat_ban (MaNXB bigint PK, TenNXB text, DiaChi text)
class SupabasePublisher {
  final int id; // bigint trong DB
  final String name;
  final String? address;

  SupabasePublisher({
    required this.id,
    required this.name,
    this.address,
  });
  factory SupabasePublisher.fromJson(Map<String, dynamic> json) {
    // bigint có thể trả về num
    int parseId(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString()) ?? 0;
    }

    return SupabasePublisher(
      id: parseId(json['manxb']),
      name: json['tennxb'] as String? ?? '',
      address: json['diachi'] as String?,
    );
  }
}

/// Repository cho nhà xuất bản
class SupabasePublisherRepository {
  SupabasePublisherRepository(this._client);

  final SupabaseClient _client;
  static const String _tableName = 'nha_xuat_ban';

  /// Lấy tất cả nhà xuất bản
  Future<List<SupabasePublisher>> getPublishers() async {
    try {
      final response = await _client
          .from(_tableName)
          .select('manxb, tennxb, diachi')
          .order('tennxb', ascending: true);

      return (response as List)
          .map((json) => SupabasePublisher.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Lỗi khi lấy danh sách nhà xuất bản: $e');
    }
  }

  /// Lấy NXB theo ID
  Future<SupabasePublisher?> getPublisherById(int id) async {
    try {
      final response = await _client
          .from(_tableName)
          .select('manxb, tennxb, diachi')
          .eq('manxb', id)
          .maybeSingle();

      if (response == null) return null;
      return SupabasePublisher.fromJson(response);
    } catch (e) {
      throw Exception('Lỗi khi lấy NXB: $e');
    }
  }

  /// Thêm nhà xuất bản mới
  Future<SupabasePublisher> addPublisher(String name, String? address) async {
    try {
      final response = await _client
          .from(_tableName)
          .insert({
            'tennxb': name,
            'diachi': address,
          })
          .select('manxb, tennxb, diachi')
          .single();

      return SupabasePublisher.fromJson(response);
    } catch (e) {
      throw Exception('Lỗi khi thêm nhà xuất bản: $e');
    }
  }

  /// Cập nhật NXB
  Future<SupabasePublisher> updatePublisher(int id,
      {String? name, String? address}) async {
    try {
      final updateData = <String, dynamic>{};
      if (name != null) updateData['tennxb'] = name;
      if (address != null) updateData['diachi'] = address;

      final response = await _client
          .from(_tableName)
          .update(updateData)
          .eq('manxb', id)
          .select('manxb, tennxb, diachi')
          .single();

      return SupabasePublisher.fromJson(response);
    } catch (e) {
      throw Exception('Lỗi khi cập nhật NXB: $e');
    }
  }

  /// Xóa NXB
  Future<void> deletePublisher(int id) async {
    try {
      await _client.from(_tableName).delete().eq('manxb', id);
    } catch (e) {
      throw Exception('Lỗi khi xóa NXB: $e');
    }
  }
}

/// Providers
final supabasePublisherRepositoryProvider =
    Provider<SupabasePublisherRepository>((ref) {
  return SupabasePublisherRepository(Supabase.instance.client);
});

/// Provider để lấy danh sách nhà xuất bản - autoDispose để luôn fetch mới
final supabasePublishersProvider =
    FutureProvider.autoDispose<List<SupabasePublisher>>((ref) async {
  final repository = ref.watch(supabasePublisherRepositoryProvider);
  return repository.getPublishers();
});
