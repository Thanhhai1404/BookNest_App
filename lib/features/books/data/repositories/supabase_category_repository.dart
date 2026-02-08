import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Model cho Thể loại từ Supabase
/// Mapping với bảng: the_loai (MaTL bigint PK, TenTL text)
class SupabaseCategory {
  final int id; // bigint trong DB
  final String name;

  SupabaseCategory({
    required this.id,
    required this.name,
  });
  factory SupabaseCategory.fromJson(Map<String, dynamic> json) {
    // bigint có thể trả về num
    int parseId(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString()) ?? 0;
    }
    
    return SupabaseCategory(
      id: parseId(json['matl']),
      name: json['tentl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'tentl': name,
    };
  }
}

/// Repository cho thể loại
class SupabaseCategoryRepository {
  SupabaseCategoryRepository(this._client);

  final SupabaseClient _client;
  static const String _tableName = 'the_loai';
  /// Lấy tất cả thể loại
  Future<List<SupabaseCategory>> getCategories() async {
    try {
      final response = await _client
          .from(_tableName)
          .select('matl, tentl')
          .order('tentl', ascending: true);

      return (response as List)
          .map((json) => SupabaseCategory.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Lỗi khi lấy danh sách thể loại: $e');
    }
  }

  /// Lấy thể loại theo ID
  Future<SupabaseCategory?> getCategoryById(int id) async {
    try {
      final response = await _client
          .from(_tableName)
          .select('matl, tentl')
          .eq('matl', id)
          .maybeSingle();

      if (response == null) return null;
      return SupabaseCategory.fromJson(response);
    } catch (e) {
      throw Exception('Lỗi khi lấy thể loại: $e');
    }
  }

  /// Thêm thể loại mới
  Future<SupabaseCategory> addCategory(String name) async {
    try {
      final response = await _client
          .from(_tableName)
          .insert({'tentl': name})
          .select('matl, tentl')
          .single();

      return SupabaseCategory.fromJson(response);
    } catch (e) {
      throw Exception('Lỗi khi thêm thể loại: $e');
    }
  }

  /// Cập nhật thể loại
  Future<SupabaseCategory> updateCategory(int id, String name) async {
    try {
      final response = await _client
          .from(_tableName)
          .update({'tentl': name})
          .eq('matl', id)
          .select('matl, tentl')
          .single();

      return SupabaseCategory.fromJson(response);
    } catch (e) {
      throw Exception('Lỗi khi cập nhật thể loại: $e');
    }
  }
  /// Xóa thể loại
  Future<void> deleteCategory(int id) async {
    try {
      await _client.from(_tableName).delete().eq('matl', id);
    } catch (e) {
      throw Exception('Lỗi khi xóa thể loại: $e');
    }
  }
}

/// Providers
final supabaseCategoryRepositoryProvider =
    Provider<SupabaseCategoryRepository>((ref) {
  return SupabaseCategoryRepository(Supabase.instance.client);
});

/// Provider để lấy danh sách thể loại - QUAN TRỌNG: autoDispose để luôn fetch mới
final supabaseCategoriesProvider =
    FutureProvider.autoDispose<List<SupabaseCategory>>((ref) async {
  final repository = ref.watch(supabaseCategoryRepositoryProvider);
  return repository.getCategories();
});