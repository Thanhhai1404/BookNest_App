import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Model cho Giao dịch ví từ Supabase
/// Mapping với bảng: giao_dich_vi
/// Cột: magd (PK auto-increment), loaigiaodich, sotien, ngaygiaodich, noidung, madg
class SupabaseTransaction {
  final int id; // MaGD - auto-increment
  final String type; // LoaiGiaoDich: 'Nạp tiền', 'Thanh toán', 'Hoàn tiền', etc.
  final int amount; // SoTien (Decimal trong DB nhưng parse thành int)
  final DateTime? transactionDate; // NgayGiaoDich
  final String? description; // NoiDung
  final String memberId; // MaDG

  SupabaseTransaction({
    required this.id,
    required this.type,
    required this.amount,
    this.transactionDate,
    this.description,
    required this.memberId,
  });

  factory SupabaseTransaction.fromJson(Map<String, dynamic> json) {
    // Helper để parse số
    int parseIntOrDefault(dynamic value, int defaultValue) {
      if (value == null) return defaultValue;
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString()) ?? defaultValue;
    }

    // Parse DateTime
    DateTime? parseDateTime(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      return DateTime.tryParse(value.toString());
    }

    return SupabaseTransaction(
      id: parseIntOrDefault(json['magd'], 0),
      type: (json['loaigiaodich'] as String?) ?? 'Khác',
      amount: parseIntOrDefault(json['sotien'], 0),
      transactionDate: parseDateTime(json['ngaygiaodich']),
      description: json['noidung'] as String?,
      memberId: (json['madg'] as String?)?.trim() ?? '',
    );
  }

  Map<String, dynamic> toInsertJson() {
    // Không include 'magd' vì là auto-increment
    return {
      'loaigiaodich': type,
      'sotien': amount,
      'ngaygiaodich': transactionDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'noidung': description,
      'madg': memberId,
    };
  }

  /// Kiểm tra đây có phải giao dịch nạp tiền không
  bool get isCredit => type == 'Nạp tiền' || type == 'Hoàn tiền' || type == 'Thưởng';

  /// Lấy icon color dựa trên loại giao dịch
  String get displayType {
    switch (type) {
      case 'Nạp tiền':
        return 'Nạp tiền';
      case 'Thanh toán':
        return 'Thanh toán';
      case 'Thanh toán phạt':
        return 'Thanh toán phạt';
      case 'Hoàn tiền':
        return 'Hoàn tiền';
      case 'Thưởng':
        return 'Điểm thưởng';
      default:
        return type;
    }
  }
}

/// Enum cho loại giao dịch
enum SupabaseTransactionType {
  topUp('Nạp tiền'),
  payment('Thanh toán'),
  finePayment('Thanh toán phạt'),
  refund('Hoàn tiền'),
  reward('Thưởng');

  const SupabaseTransactionType(this.value);
  final String value;
}

/// Repository để quản lý giao dịch ví trên Supabase
class SupabaseTransactionRepository {
  SupabaseTransactionRepository(this._client);

  final SupabaseClient _client;

  /// Tên bảng
  static const String _transactionTable = 'giao_dich_vi';

  // ==================== QUERY GIAO DỊCH ====================

  /// Lấy danh sách giao dịch của một hội viên
  /// Sắp xếp theo ngaygiaodich giảm dần (mới nhất lên đầu)
  Future<List<SupabaseTransaction>> getTransactionsByMember(String maDG) async {
    try {
      final response = await _client
          .from(_transactionTable)
          .select('*')
          .eq('madg', maDG.trim())
          .order('ngaygiaodich', ascending: false);

      return (response as List)
          .map((json) => SupabaseTransaction.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('❌ Lỗi khi lấy danh sách giao dịch: $e');
      throw Exception('Lỗi khi lấy danh sách giao dịch: $e');
    }
  }

  /// Lấy N giao dịch gần nhất của một hội viên
  Future<List<SupabaseTransaction>> getRecentTransactions(
    String maDG, {
    int limit = 10,
  }) async {
    try {
      final response = await _client
          .from(_transactionTable)
          .select('*')
          .eq('madg', maDG.trim())
          .order('ngaygiaodich', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => SupabaseTransaction.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('❌ Lỗi khi lấy giao dịch gần nhất: $e');
      throw Exception('Lỗi khi lấy giao dịch gần nhất: $e');
    }
  }

  /// Lấy tất cả giao dịch (cho admin)
  Future<List<SupabaseTransaction>> getAllTransactions() async {
    try {
      final response = await _client
          .from(_transactionTable)
          .select('*')
          .order('ngaygiaodich', ascending: false);

      return (response as List)
          .map((json) => SupabaseTransaction.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('❌ Lỗi khi lấy tất cả giao dịch: $e');
      throw Exception('Lỗi khi lấy tất cả giao dịch: $e');
    }
  }

  // ==================== TẠO GIAO DỊCH ====================

  /// Tạo giao dịch mới
  Future<SupabaseTransaction> createTransaction({
    required String maDG,
    required SupabaseTransactionType type,
    required int amount,
    String? description,
  }) async {
    try {
      final insertData = {
        'madg': maDG.trim(),
        'loaigiaodich': type.value,
        'sotien': amount,
        'ngaygiaodich': DateTime.now().toIso8601String(),
        'noidung': description,
      };

      final response = await _client
          .from(_transactionTable)
          .insert(insertData)
          .select()
          .single();

      debugPrint('✅ Tạo giao dịch thành công: ${type.value} - $amount VND');
      return SupabaseTransaction.fromJson(response);
    } catch (e) {
      debugPrint('❌ Lỗi khi tạo giao dịch: $e');
      throw Exception('Lỗi khi tạo giao dịch: $e');
    }
  }

  /// Tạo giao dịch nạp tiền
  Future<SupabaseTransaction> createTopUpTransaction({
    required String maDG,
    required int amount,
    String? description,
  }) async {
    return createTransaction(
      maDG: maDG,
      type: SupabaseTransactionType.topUp,
      amount: amount,
      description: description ?? 'Nạp tiền vào ví',
    );
  }

  /// Tạo giao dịch thanh toán
  Future<SupabaseTransaction> createPaymentTransaction({
    required String maDG,
    required int amount,
    String? description,
  }) async {
    return createTransaction(
      maDG: maDG,
      type: SupabaseTransactionType.payment,
      amount: amount,
      description: description ?? 'Thanh toán',
    );
  }

  /// Tạo giao dịch thanh toán phạt
  Future<SupabaseTransaction> createFinePaymentTransaction({
    required String maDG,
    required int amount,
    String? description,
  }) async {
    return createTransaction(
      maDG: maDG,
      type: SupabaseTransactionType.finePayment,
      amount: amount,
      description: description ?? 'Thanh toán tiền phạt quá hạn',
    );
  }

  /// Tạo giao dịch hoàn tiền
  Future<SupabaseTransaction> createRefundTransaction({
    required String maDG,
    required int amount,
    String? description,
  }) async {
    return createTransaction(
      maDG: maDG,
      type: SupabaseTransactionType.refund,
      amount: amount,
      description: description ?? 'Hoàn tiền',
    );
  }

  // ==================== THỐNG KÊ ====================

  /// Tính tổng số tiền nạp của một hội viên
  Future<int> getTotalTopUp(String maDG) async {
    try {
      final response = await _client
          .from(_transactionTable)
          .select('sotien')
          .eq('madg', maDG.trim())
          .eq('loaigiaodich', 'Nạp tiền');

      int total = 0;
      for (final row in response as List) {
        final amount = row['sotien'];
        if (amount is num) total += amount.toInt();
      }
      return total;
    } catch (e) {
      debugPrint('❌ Lỗi khi tính tổng nạp: $e');
      return 0;
    }
  }

  /// Tính tổng số tiền đã chi tiêu của một hội viên
  Future<int> getTotalSpent(String maDG) async {
    try {
      final response = await _client
          .from(_transactionTable)
          .select('sotien')
          .eq('madg', maDG.trim())
          .inFilter('loaigiaodich', ['Thanh toán', 'Thanh toán phạt']);

      int total = 0;
      for (final row in response as List) {
        final amount = row['sotien'];
        if (amount is num) total += amount.toInt();
      }
      return total;
    } catch (e) {
      debugPrint('❌ Lỗi khi tính tổng chi tiêu: $e');
      return 0;
    }
  }
}

// ==================== PROVIDERS ====================

/// Provider cho SupabaseTransactionRepository
final supabaseTransactionRepositoryProvider =
    Provider<SupabaseTransactionRepository>((ref) {
  return SupabaseTransactionRepository(Supabase.instance.client);
});

/// Provider lấy danh sách giao dịch của một hội viên
final memberTransactionsSupabaseProvider = FutureProvider.family
    .autoDispose<List<SupabaseTransaction>, String>((ref, memberId) async {
  final repository = ref.watch(supabaseTransactionRepositoryProvider);
  return repository.getTransactionsByMember(memberId);
});

/// Provider lấy giao dịch gần nhất của một hội viên
final recentTransactionsSupabaseProvider = FutureProvider.family
    .autoDispose<List<SupabaseTransaction>, String>((ref, memberId) async {
  final repository = ref.watch(supabaseTransactionRepositoryProvider);
  return repository.getRecentTransactions(memberId, limit: 5);
});
