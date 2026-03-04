import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Các module phân loại hành động
class ActivityModule {
  static const String muonTra = 'MUON_TRA';
  static const String viTien = 'VI_TIEN';
  static const String hoiVien = 'HOI_VIEN';
  static const String sach = 'SACH';
  static const String nhanVien = 'NHAN_VIEN';
  static const String heThong = 'HE_THONG';
}

/// Model cho Nhật ký hoạt động từ Supabase
/// Mapping với bảng: nhat_ky_hoat_dong
/// Cột: id, manv, module, hanhdong, noidung, madg, thamchieu_id, thoigian
class ActivityLog {
  final int id;
  final String? employeeId; // manv
  final String module; // module (phân loại)
  final String actionType; // hanhdong
  final String content; // noidung
  final String? memberId; // madg (độc giả liên quan)
  final String? referenceId; // thamchieu_id (mã tham chiếu)
  final DateTime createdAt; // thoigian
  
  // Join data
  final String? employeeName; // Từ join nhan_vien
  final String? memberName; // Từ join doc_gia

  ActivityLog({
    required this.id,
    this.employeeId,
    required this.module,
    required this.actionType,
    required this.content,
    this.memberId,
    this.referenceId,
    required this.createdAt,
    this.employeeName,
    this.memberName,
  });

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    // Parse employee name từ join
    String? empName;
    final nhanVien = json['nhan_vien'];
    if (nhanVien != null && nhanVien is Map<String, dynamic>) {
      final ho = (nhanVien['honv'] as String?)?.trim() ?? '';
      final ten = (nhanVien['tennv'] as String?)?.trim() ?? '';
      empName = '$ho $ten'.trim();
      if (empName.isEmpty) empName = null;
    }

    // Parse member name từ join
    String? memName;
    final docGia = json['doc_gia'];
    if (docGia != null && docGia is Map<String, dynamic>) {
      final ho = (docGia['hodg'] as String?)?.trim() ?? '';
      final tenLot = (docGia['tenlotdg'] as String?)?.trim() ?? '';
      final ten = (docGia['tendg'] as String?)?.trim() ?? '';
      memName = '$ho $tenLot $ten'.trim();
      if (memName.isEmpty) memName = null;
    }

    return ActivityLog(
      id: (json['id'] as num?)?.toInt() ?? 0,
      employeeId: (json['manv'] as String?)?.trim(),
      module: (json['module'] as String?) ?? ActivityModule.heThong,
      actionType: (json['hanhdong'] as String?) ?? 'Khác',
      content: (json['noidung'] as String?) ?? '',
      memberId: (json['madg'] as String?)?.trim(),
      referenceId: (json['thamchieu_id'] as String?)?.trim(),
      createdAt: DateTime.tryParse(json['thoigian']?.toString() ?? '') ?? DateTime.now(),
      employeeName: empName,
      memberName: memName,
    );
  }

  /// Lấy icon dựa trên module
  String get moduleIcon {
    switch (module) {
      case ActivityModule.muonTra:
        return '📚';
      case ActivityModule.viTien:
        return '💰';
      case ActivityModule.hoiVien:
        return '👤';
      case ActivityModule.sach:
        return '📖';
      case ActivityModule.nhanVien:
        return '👔';
      case ActivityModule.heThong:
        return '⚙️';
      default:
        return '📝';
    }
  }

  /// Lấy tên module hiển thị
  String get moduleDisplayName {
    switch (module) {
      case ActivityModule.muonTra:
        return 'Mượn trả';
      case ActivityModule.viTien:
        return 'Ví tiền';
      case ActivityModule.hoiVien:
        return 'Hội viên';
      case ActivityModule.sach:
        return 'Sách';
      case ActivityModule.nhanVien:
        return 'Nhân viên';
      case ActivityModule.heThong:
        return 'Hệ thống';
      default:
        return module;
    }
  }

  /// Lấy màu dựa trên module
  int get moduleColorValue {
    switch (module) {
      case ActivityModule.muonTra:
        return 0xFF4CAF50; // Green
      case ActivityModule.viTien:
        return 0xFFFF9800; // Orange
      case ActivityModule.hoiVien:
        return 0xFF2196F3; // Blue
      case ActivityModule.sach:
        return 0xFF9C27B0; // Purple
      case ActivityModule.nhanVien:
        return 0xFF009688; // Teal
      case ActivityModule.heThong:
        return 0xFF607D8B; // Blue Grey
      default:
        return 0xFF9E9E9E; // Grey
    }
  }
}

/// Repository cho Activity Log
class SupabaseActivityLogRepository {
  final SupabaseClient _client;

  SupabaseActivityLogRepository(this._client);

  /// Lấy danh sách activity logs với optional filter theo ngày và module
  Future<List<ActivityLog>> getActivityLogs({
    DateTime? filterDate,
    String? filterModule,
    int limit = 100,
  }) async {
    try {
      var query = _client
          .from('nhat_ky_hoat_dong')
          .select('''
            id,
            manv,
            module,
            hanhdong,
            noidung,
            madg,
            thamchieu_id,
            thoigian,
            nhan_vien(honv, tennv),
            doc_gia(hodg, tenlotdg, tendg)
          ''');

      // Filter theo ngày nếu có
      if (filterDate != null) {
        final startOfDay = DateTime(filterDate.year, filterDate.month, filterDate.day);
        final endOfDay = startOfDay.add(const Duration(days: 1));
        
        query = query
            .gte('thoigian', startOfDay.toIso8601String())
            .lt('thoigian', endOfDay.toIso8601String());
      }

      // Filter theo module nếu có
      if (filterModule != null && filterModule.isNotEmpty) {
        query = query.eq('module', filterModule);
      }

      final response = await query
          .order('thoigian', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => ActivityLog.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stack) {
      debugPrint('Error fetching activity logs: $e');
      debugPrint('Stack: $stack');
      rethrow;
    }
  }

  /// Thêm một activity log mới
  Future<void> addLog({
    required String module,
    required String actionType,
    required String content,
    String? employeeId,
    String? memberId,
    String? referenceId,
  }) async {
    try {
      await _client.from('nhat_ky_hoat_dong').insert({
        'manv': employeeId,
        'module': module,
        'hanhdong': actionType,
        'noidung': content,
        'madg': memberId,
        'thamchieu_id': referenceId,
      });
    } catch (e, stack) {
      debugPrint('Error adding activity log: $e');
      debugPrint('Stack: $stack');
      // Không throw lỗi để không ảnh hưởng đến flow chính
    }
  }
}

// ============================================================
// PROVIDERS
// ============================================================

/// Provider cho SupabaseClient
final _supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Provider cho ActivityLogRepository
final activityLogRepositoryProvider = Provider<SupabaseActivityLogRepository>((ref) {
  final client = ref.watch(_supabaseClientProvider);
  return SupabaseActivityLogRepository(client);
});

/// State cho filter ngày
final activityLogDateFilterProvider = StateProvider<DateTime?>((ref) => null);

/// State cho filter module
final activityLogModuleFilterProvider = StateProvider<String?>((ref) => null);

/// Provider cho danh sách activity logs (auto-refresh khi filter thay đổi)
final activityLogsProvider = FutureProvider<List<ActivityLog>>((ref) async {
  final repository = ref.watch(activityLogRepositoryProvider);
  final filterDate = ref.watch(activityLogDateFilterProvider);
  final filterModule = ref.watch(activityLogModuleFilterProvider);
  
  return repository.getActivityLogs(
    filterDate: filterDate,
    filterModule: filterModule,
  );
});

/// Provider để nhóm logs theo ngày (dd/MM/yyyy)
final groupedActivityLogsProvider = Provider<Map<String, List<ActivityLog>>>((ref) {
  final logsAsync = ref.watch(activityLogsProvider);
  
  return logsAsync.when(
    data: (logs) {
      final Map<String, List<ActivityLog>> grouped = {};
      
      for (final log in logs) {
        final dateKey = _formatDateKey(log.createdAt);
        grouped.putIfAbsent(dateKey, () => []).add(log);
      }
      
      return grouped;
    },
    loading: () => {},
    error: (_, __) => {},
  );
});

/// Helper để format date key
String _formatDateKey(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final year = date.year.toString();
  return '$day/$month/$year';
}
