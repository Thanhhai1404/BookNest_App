import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ============================================================================
// User Portal Borrow Repository
// Handles borrow history from member's perspective
// ============================================================================

/// Lịch sử mượn sách
class UserBorrowRecord {
  final String loanId;
  final String bookBarcode;
  final String? bookTitle;
  final String? bookImageUrl;
  final DateTime borrowDate;
  final DateTime? dueDate;
  final DateTime? returnDate;  final int status; // 0: đang mượn, 1: đã trả, 2: chờ duyệt, 3: đã hủy
  final int? fineAmount;
  final String? condition;

  const UserBorrowRecord({
    required this.loanId,
    required this.bookBarcode,
    this.bookTitle,
    this.bookImageUrl,
    required this.borrowDate,
    this.dueDate,
    this.returnDate,
    this.status = 0,
    this.fineAmount,
    this.condition,
  });  bool get isPending => status == 2;

  bool get isCancelled => status == 3;

  bool get isOverdue =>
      status == 0 && dueDate != null && DateTime.now().isAfter(dueDate!);

  bool get isReturned => status == 1;

  String get statusLabel {
    if (isCancelled) return 'Đã hủy';
    if (isPending) return 'Chờ duyệt';
    if (isReturned) return 'Đã trả';
    if (isOverdue) return 'Quá hạn';
    return 'Đang mượn';
  }
  factory UserBorrowRecord.fromJson(Map<String, dynamic> json) {
    int parseNum(dynamic v) => (v is num) ? v.toInt() : int.tryParse(v.toString()) ?? 0;

    // Parse book info through: chi_tiet_muon -> sach -> dau_sach
    String? bookTitle;
    String? bookImageUrl;
    if (json['sach'] is Map) {
      final sach = json['sach'] as Map;
      if (sach['dau_sach'] is Map) {
        bookTitle = sach['dau_sach']['tensach'] as String?;
        bookImageUrl = sach['dau_sach']['anhbia'] as String?;
      }
    }    return UserBorrowRecord(
      loanId: json['mapm'] as String? ?? '',
      bookBarcode: json['mavach'] as String? ?? '',
      bookTitle: bookTitle,
      bookImageUrl: bookImageUrl,
      borrowDate: DateTime.tryParse(
              json['phieu_muon']?['ngaymuon']?.toString() ?? '') ??
          DateTime.now(),
      dueDate: json['ngayhentra'] != null
          ? DateTime.tryParse(json['ngayhentra'].toString())
          : null,
      returnDate: json['ngaytrathucte'] != null
          ? DateTime.tryParse(json['ngaytrathucte'].toString())
          : null,      status: parseNum(json['trangthai']),
      fineAmount: parseNum(json['tienphatphatsinh']),
      condition: json['tinhtrangsachkhitra'] as String?,
    );
  }
}

/// Repository
class UserBorrowRepository {
  final SupabaseClient _client;

  UserBorrowRepository(this._client);

  /// Lấy tất cả lịch sử mượn trả của member
  Future<List<UserBorrowRecord>> getBorrowHistory(String memberId) async {
    // Get all phieu_muon for this member, then get chi_tiet_muon
    final data = await _client
        .from('chi_tiet_muon')
        .select('''
          *,
          phieu_muon!inner(mapm, ngaymuon, madg),
          sach(mavach, dau_sach(tensach, anhbia))
        ''')
        .eq('phieu_muon.madg', memberId)
        .order('phieu_muon(ngaymuon)', ascending: false);

    return data.map((e) => UserBorrowRecord.fromJson(e)).toList();
  }  /// Lấy sách đang mượn (chưa trả) - bao gồm cả "Chờ duyệt" và "Đang mượn"
  Future<List<UserBorrowRecord>> getActiveBorrows(String memberId) async {
    final data = await _client
        .from('chi_tiet_muon')
        .select('''
          *,
          phieu_muon!inner(mapm, ngaymuon, madg),
          sach(mavach, dau_sach(tensach, anhbia))
        ''')
        .eq('phieu_muon.madg', memberId)
        .inFilter('trangthai', [0, 2]) // 0 = đang mượn, 2 = chờ duyệt
        .order('phieu_muon(ngaymuon)', ascending: false);

    return data.map((e) => UserBorrowRecord.fromJson(e)).toList();
  }
  /// Lấy sách đã trả + đã hủy
  Future<List<UserBorrowRecord>> getReturnedBorrows(String memberId) async {
    final data = await _client
        .from('chi_tiet_muon')
        .select('''
          *,
          phieu_muon!inner(mapm, ngaymuon, madg),
          sach(mavach, dau_sach(tensach, anhbia))
        ''')
        .eq('phieu_muon.madg', memberId)
        .inFilter('trangthai', [1, 3]) // 1 = đã trả, 3 = đã hủy
        .order('phieu_muon(ngaymuon)', ascending: false);

    return data.map((e) => UserBorrowRecord.fromJson(e)).toList();
  }
  /// Đếm sách đang mượn (bao gồm chờ duyệt)
  Future<int> getActiveBorrowCount(String memberId) async {
    final data = await _client
        .from('chi_tiet_muon')
        .select('mapm, phieu_muon!inner(madg)')
        .eq('phieu_muon.madg', memberId)
        .inFilter('trangthai', [0, 2]);
    return data.length;
  }
  /// Tạo yêu cầu mượn sách mới
  /// Returns mã phiếu mượn nếu thành công
  Future<String> createBorrowRequest({
    required String memberId,
    required String bookId,
    required DateTime pickupDate,
    required String pickupTime,
  }) async {
    // 1. Tìm sách có thể mượn (sach có trạng thái sẵn sàng)
    // Cột khóa ngoại trong bảng 'sach' là 'mads' (mã đầu sách)
    final availableBooks = await _client
        .from('sach')
        .select('mavach')
        .eq('mads', bookId)
        .eq('trangthai', 0) // 0 = sẵn sàng cho mượn
        .limit(1);

    if (availableBooks.isEmpty) {
      throw Exception('Không còn sách để mượn');
    }    final bookBarcode = availableBooks[0]['mavach'] as String;

    // 2. Tạo mã phiếu mượn unique
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final borrowId = 'PM${timestamp.toString().substring(5)}';

    // 3. Tính ngày hẹn trả (14 ngày từ ngày mượn)
    final dueDate = pickupDate.add(const Duration(days: 14));

    // 4. Lấy mã thẻ thành viên (bắt buộc cho phiếu mượn)
    final cardResponse = await _client
        .from('the_thanh_vien')
        .select('mast')
        .eq('madg', memberId)
        .eq('trangthai', 1) // Thẻ còn hoạt động
        .maybeSingle();

    if (cardResponse == null) {
      throw Exception('Không tìm thấy thẻ thành viên hợp lệ. Vui lòng liên hệ thư viện.');
    }

    final mast = cardResponse['mast'] as String;

    // 5. Insert phiếu mượn (dùng tên cột như admin: mapm, mast)
    await _client.from('phieu_muon').insert({
      'mapm': borrowId,
      'madg': memberId,
      'manv': null, // Chưa có nhân viên duyệt - sẽ được duyệt sau
      'mast': mast,
      'ngaymuon': pickupDate.toIso8601String(),
      'ghichu': 'Đặt online - Giờ hẹn lấy: $pickupTime',
    });

    // 6. Insert chi tiết mượn (dùng tên cột như admin: mapm)
    await _client.from('chi_tiet_muon').insert({
      'mapm': borrowId,
      'mavach': bookBarcode,
      'ngayhentra': dueDate.toIso8601String(),
      'ngaytrathucte': null,
      'trangthai': 2, // 2 = Chờ duyệt (pending)
      'tienphatphatsinh': 0,
      'tinhtrangsachkhitra': null,
    });

    // 7. Cập nhật trạng thái sách thành "đang được giữ"
    await _client
        .from('sach')
        .update({'trangthai': 2}) // 2 = đang giữ/chờ lấy
        .eq('mavach', bookBarcode);    return borrowId;
  }

  /// Hủy đơn mượn sách
  /// - Cập nhật trạng thái chi_tiet_muon → 3 (Đã hủy)
  /// - Trả lại trạng thái sách về 0 (Có sẵn)
  /// - Không trừ điểm tín nhiệm
  Future<void> cancelBorrowRequest(String mapm, String? reason) async {
    // 1. Lấy danh sách mã vạch sách thuộc phiếu mượn này
    final details = await _client
        .from('chi_tiet_muon')
        .select('mavach')
        .eq('mapm', mapm);

    // 2. Cập nhật trạng thái chi tiết mượn → 3 (Đã hủy)
    await _client
        .from('chi_tiet_muon')
        .update({'trangthai': 3})
        .eq('mapm', mapm);

    // 3. Cập nhật ghi chú phiếu mượn (thêm lý do hủy)
    final ghiChuUpdate = reason != null && reason.trim().isNotEmpty
        ? 'Đã hủy bởi độc giả - Lý do: ${reason.trim()}'
        : 'Đã hủy bởi độc giả';
    await _client
        .from('phieu_muon')
        .update({'ghichu': ghiChuUpdate})
        .eq('mapm', mapm);

    // 4. Trả lại trạng thái từng cuốn sách về 0 (Có sẵn)
    for (final row in details) {
      final mavach = row['mavach'] as String;
      await _client
          .from('sach')
          .update({'trangthai': 0})
          .eq('mavach', mavach);
    }
  }
}

// ======================== Providers ========================

final userBorrowRepositoryProvider = Provider<UserBorrowRepository>((ref) {
  return UserBorrowRepository(Supabase.instance.client);
});

final borrowHistoryProvider =
    FutureProvider.family<List<UserBorrowRecord>, String>(
  (ref, memberId) {
    return ref.read(userBorrowRepositoryProvider).getBorrowHistory(memberId);
  },
);

final activeBorrowsProvider =
    FutureProvider.family<List<UserBorrowRecord>, String>(
  (ref, memberId) {
    return ref.read(userBorrowRepositoryProvider).getActiveBorrows(memberId);
  },
);

final returnedBorrowsProvider =
    FutureProvider.family<List<UserBorrowRecord>, String>(
  (ref, memberId) {
    return ref.read(userBorrowRepositoryProvider).getReturnedBorrows(memberId);
  },
);

final activeBorrowCountProvider = FutureProvider.family<int, String>(
  (ref, memberId) {
    return ref.read(userBorrowRepositoryProvider).getActiveBorrowCount(memberId);
  },
);
