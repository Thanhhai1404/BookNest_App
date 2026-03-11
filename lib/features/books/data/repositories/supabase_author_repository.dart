import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Model cho Tác giả từ Supabase
/// Mapping với bảng: tac_gia (MaTG bigint PK, HoTG, TenLotTG, TenTG, QueQuan)
class SupabaseAuthor {
  final int id; // bigint trong DB
  final String? lastName;
  final String? middleName;
  final String? firstName;
  final String? hometown;

  SupabaseAuthor({
    required this.id,
    this.lastName,
    this.middleName,
    this.firstName,
    this.hometown,
  });
  factory SupabaseAuthor.fromJson(Map<String, dynamic> json) {
    // bigint có thể trả về num
    int parseId(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString()) ?? 0;
    }

    return SupabaseAuthor(
      id: parseId(json['matg']),
      lastName: json['hotg'] as String?,
      middleName: json['tenlottg'] as String?,
      firstName: json['tentg'] as String?,
      hometown: json['quequan'] as String?,
    );
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'hotg': lastName,
      'tenlottg': middleName,
      'tentg': firstName,
      'quequan': hometown,
    };
  }

  /// Lấy tên đầy đủ
  String get fullName {
    final parts = <String>[];
    if (lastName != null && lastName!.isNotEmpty) parts.add(lastName!);
    if (middleName != null && middleName!.isNotEmpty) parts.add(middleName!);
    if (firstName != null && firstName!.isNotEmpty) parts.add(firstName!);
    return parts.isEmpty ? 'Không có tên' : parts.join(' ');
  }
}

/// Repository cho tác giả
class SupabaseAuthorRepository {
  SupabaseAuthorRepository(this._client);

  final SupabaseClient _client;
  static const String _tableName = 'tac_gia';

  /// Lấy tất cả tác giả
  Future<List<SupabaseAuthor>> getAuthors() async {
    try {
      final response = await _client
          .from(_tableName)
          .select('matg, hotg, tenlottg, tentg, quequan')
          .order('tentg', ascending: true);

      return (response as List)
          .map((json) => SupabaseAuthor.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Lỗi khi lấy danh sách tác giả: $e');
    }
  }

  /// Lấy tác giả theo ID
  Future<SupabaseAuthor?> getAuthorById(int id) async {
    try {
      final response = await _client
          .from(_tableName)
          .select('matg, hotg, tenlottg, tentg, quequan')
          .eq('matg', id)
          .maybeSingle();

      if (response == null) return null;
      return SupabaseAuthor.fromJson(response);
    } catch (e) {
      throw Exception('Lỗi khi lấy tác giả: $e');
    }
  }

  /// Thêm tác giả mới
  Future<SupabaseAuthor> addAuthor({
    String? lastName,
    String? middleName,
    String? firstName,
    String? hometown,
  }) async {
    try {
      final response = await _client
          .from(_tableName)
          .insert({
            'hotg': lastName,
            'tenlottg': middleName,
            'tentg': firstName,
            'quequan': hometown,
          })
          .select('matg, hotg, tenlottg, tentg, quequan')
          .single();

      return SupabaseAuthor.fromJson(response);
    } catch (e) {
      throw Exception('Lỗi khi thêm tác giả: $e');
    }
  }

  /// Cập nhật tác giả
  Future<SupabaseAuthor> updateAuthor(
    int id, {
    String? lastName,
    String? middleName,
    String? firstName,
    String? hometown,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (lastName != null) updateData['hotg'] = lastName;
      if (middleName != null) updateData['tenlottg'] = middleName;
      if (firstName != null) updateData['tentg'] = firstName;
      if (hometown != null) updateData['quequan'] = hometown;

      final response = await _client
          .from(_tableName)
          .update(updateData)
          .eq('matg', id)
          .select('matg, hotg, tenlottg, tentg, quequan')
          .single();

      return SupabaseAuthor.fromJson(response);
    } catch (e) {
      throw Exception('Lỗi khi cập nhật tác giả: $e');
    }
  }

  /// Xóa tác giả
  Future<void> deleteAuthor(int id) async {
    try {
      await _client.from(_tableName).delete().eq('matg', id);
    } catch (e) {
      throw Exception('Lỗi khi xóa tác giả: $e');
    }
  }

  /// Lấy tác giả của một đầu sách (qua bảng chi_tiet_tac_gia)
  Future<List<SupabaseAuthor>> getAuthorsOfBook(String bookId) async {
    try {
      final response = await _client
          .from('chi_tiet_tac_gia')
          .select('tac_gia:matg(matg, hotg, tenlottg, tentg, quequan)')
          .eq('mads', bookId);

      return (response as List).map((json) {
        final authorJson = json['tac_gia'] as Map<String, dynamic>;
        return SupabaseAuthor.fromJson(authorJson);
      }).toList();
    } catch (e) {
      throw Exception('Lỗi khi lấy tác giả của sách: $e');
    }
  }

  /// Thêm tác giả vào sách
  Future<void> addAuthorToBook(
      String bookId, int authorId, String? role) async {
    try {
      await _client.from('chi_tiet_tac_gia').insert({
        'mads': bookId,
        'matg': authorId,
        'vaitro': role,
      });
    } catch (e) {
      throw Exception('Lỗi khi thêm tác giả vào sách: $e');
    }
  }

  /// Xóa tác giả khỏi sách
  Future<void> removeAuthorFromBook(String bookId, int authorId) async {
    try {
      await _client
          .from('chi_tiet_tac_gia')
          .delete()
          .eq('mads', bookId)
          .eq('matg', authorId);
    } catch (e) {
      throw Exception('Lỗi khi xóa tác giả khỏi sách: $e');
    }
  }
}

/// Providers
final supabaseAuthorRepositoryProvider =
    Provider<SupabaseAuthorRepository>((ref) {
  return SupabaseAuthorRepository(Supabase.instance.client);
});

final supabaseAuthorsProvider =
    FutureProvider<List<SupabaseAuthor>>((ref) async {
  final repository = ref.watch(supabaseAuthorRepositoryProvider);
  return repository.getAuthors();
});

/// Lấy tác giả của một sách
final supabaseBookAuthorsProvider =
    FutureProvider.family<List<SupabaseAuthor>, String>((ref, bookId) async {
  final repository = ref.watch(supabaseAuthorRepositoryProvider);
  return repository.getAuthorsOfBook(bookId);
});
