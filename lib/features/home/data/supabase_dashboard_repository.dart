import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Model chứa các thống kê của Dashboard
class DashboardStats {
  final int totalBooks;
  final int totalMembers;
  final int borrowedBooks;
  final int overdueLoans;

  const DashboardStats({
    required this.totalBooks,
    required this.totalMembers,
    required this.borrowedBooks,
    required this.overdueLoans,
  });

  const DashboardStats.empty()
      : totalBooks = 0,
        totalMembers = 0,
        borrowedBooks = 0,
        overdueLoans = 0;
}

/// Repository để lấy thống kê Dashboard từ Supabase
class SupabaseDashboardRepository {
  final SupabaseClient _client;

  SupabaseDashboardRepository(this._client);

  /// Lấy toàn bộ thống kê cho Dashboard
  Future<DashboardStats> getDashboardStats() async {
    try {
      // 1. Đếm tổng sách (bảng sach)
      final booksResponse = await _client.from('sach').select('mavach');
      final totalBooks = (booksResponse as List).length;

      // 2. Đếm tổng hội viên (bảng doc_gia)
      final membersResponse = await _client.from('doc_gia').select('madg');
      final totalMembers = (membersResponse as List).length;

      // 3. Đếm sách đang mượn (bảng sach với trangthai = 1)
      final borrowedResponse = await _client
          .from('sach')
          .select('mavach')
          .eq('trangthai', 1);
      final borrowedBooks = (borrowedResponse as List).length;

      // 4. Đếm số sách quá hạn (bảng chi_tiet_muon với trangthai = 0 và ngayhentra < now)
      final now = DateTime.now().toIso8601String().split('T').first;
      final overdueResponse = await _client
          .from('chi_tiet_muon')
          .select('mavach')
          .eq('trangthai', 0) // Chưa trả
          .lt('ngayhentra', now); // Ngày hẹn trả < hôm nay
      final overdueLoans = (overdueResponse as List).length;

      return DashboardStats(
        totalBooks: totalBooks,
        totalMembers: totalMembers,
        borrowedBooks: borrowedBooks,
        overdueLoans: overdueLoans,
      );
    } catch (e) {
      throw Exception('Lỗi khi lấy thống kê dashboard: $e');
    }
  }
}

/// Provider cho SupabaseDashboardRepository
final supabaseDashboardRepositoryProvider =
    Provider<SupabaseDashboardRepository>((ref) {
  return SupabaseDashboardRepository(Supabase.instance.client);
});

/// Provider FutureProvider cho Dashboard Stats
final supabaseDashboardStatsProvider =
    FutureProvider.autoDispose<DashboardStats>((ref) async {
  final repository = ref.watch(supabaseDashboardRepositoryProvider);
  return repository.getDashboardStats();
});
