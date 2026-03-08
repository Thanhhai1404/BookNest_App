import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../activity_log/data/supabase_activity_log_repository.dart';

/// Fine rate: VND per overdue day.
const int kSupabaseFineRatePerDay = 2000;

/// Points awarded per book returned on time.
const int kSupabasePointsPerBook = 10;

/// Maximum number of renewals allowed per loan.
const int kSupabaseMaxRenewals = 2;

/// Renewal period in days.
const int kSupabaseRenewalDays = 7;

// ==================== MODELS ====================

/// Model cho Phiếu mượn (Loan slip) từ Supabase
/// Mapping với bảng: phieu_muon
/// Cột: mapm (PK), ngaymuon, ghichu, madg, manv, mast
class SupabaseLoan {
  final String id; // MaPhieuMuon
  final DateTime? borrowDate; // NgayMuon
  final String? note; // GhiChu
  final String memberId; // MaDG
  final String staffId; // MaNV
  final String cardId; // MaST (Mã số thẻ)

  // Thông tin từ join
  final String? memberName;
  final String? memberPhone;

  SupabaseLoan({
    required this.id,
    this.borrowDate,
    this.note,
    required this.memberId,
    required this.staffId,
    required this.cardId,
    this.memberName,
    this.memberPhone,
  });

  factory SupabaseLoan.fromJson(Map<String, dynamic> json) {
    // Parse DateTime
    DateTime? parseDateTime(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      return DateTime.tryParse(value.toString());
    }

    // Parse thông tin độc giả từ join
    String? memberName;
    String? memberPhone;
    if (json['doc_gia'] != null && json['doc_gia'] is Map) {
      final docGia = json['doc_gia'] as Map<String, dynamic>;
      final ho = (docGia['hodg'] ?? '') as String;
      final tenLot = (docGia['tenlotdg'] ?? '') as String;
      final ten = (docGia['tendg'] ?? '') as String;
      memberName = [ho, tenLot, ten]
          .where((e) => e.trim().isNotEmpty)
          .join(' ');
      if (memberName.isEmpty) memberName = docGia['madg'] as String?;
      memberPhone = docGia['sdt'] as String?;
    }    return SupabaseLoan(
      id: json['mapm'] as String,
      borrowDate: parseDateTime(json['ngaymuon']),
      note: json['ghichu'] as String?,
      memberId: (json['madg'] as String?)?.trim() ?? '',
      staffId: (json['manv'] as String?)?.trim() ?? '',
      cardId: (json['mast'] as String?) ?? '',
      memberName: memberName,
      memberPhone: memberPhone,
    );
  }  Map<String, dynamic> toInsertJson() {
    return {
      'mapm': id,
      'ngaymuon': borrowDate?.toIso8601String(),
      'ghichu': note,
      'madg': memberId,
      'manv': staffId,
      'mast': cardId,
    };
  }
}

/// Model cho Chi tiết mượn (Loan detail) từ Supabase
/// Mapping với bảng: chi_tiet_muon
/// Cột: mapm + mavach (composite PK), ngayhentra, ngaytrathucte, 
///      tinhtrangsachkhitra, tienphatphatsinh, trangthai
class SupabaseLoanDetail {
  final String loanId; // MaPhieuMuon
  final String barcode; // MaVach
  final DateTime? dueDate; // NgayHenTra
  final DateTime? returnDate; // NgayTraThucTe
  final String? bookConditionOnReturn; // TinhTrangSachKhiTra
  final int fineAmount; // TienPhatPhatSinh
  final int status; // TrangThai (0: Đang mượn, 1: Đã trả, 2: Quá hạn)
  final int renewalCount; // Số lần gia hạn (client-side tracking)

  // Thông tin từ join với bảng sách
  final String? bookTitle;
  final String? bookTitleId;
  final String? location;

  SupabaseLoanDetail({
    required this.loanId,
    required this.barcode,
    this.dueDate,
    this.returnDate,
    this.bookConditionOnReturn,
    this.fineAmount = 0,
    this.status = 0,
    this.renewalCount = 0,
    this.bookTitle,
    this.bookTitleId,
    this.location,
  });

  factory SupabaseLoanDetail.fromJson(Map<String, dynamic> json) {
    // Parse DateTime
    DateTime? parseDateTime(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      return DateTime.tryParse(value.toString());
    }

    // Helper để parse số
    int parseIntOrDefault(dynamic value, int defaultValue) {
      if (value == null) return defaultValue;
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString()) ?? defaultValue;
    }

    // Parse thông tin sách từ join
    String? bookTitle;
    String? bookTitleId;
    String? location;
    if (json['sach'] != null && json['sach'] is Map) {
      final sach = json['sach'] as Map<String, dynamic>;
      bookTitleId = sach['mads'] as String?;
      location = sach['vitri'] as String?;
      
      // Nếu có join thêm với dau_sach
      if (sach['dau_sach'] != null && sach['dau_sach'] is Map) {
        final dauSach = sach['dau_sach'] as Map<String, dynamic>;
        bookTitle = dauSach['tensach'] as String?;
      }
    }    return SupabaseLoanDetail(
      loanId: json['mapm'] as String,
      barcode: json['mavach'] as String,
      dueDate: parseDateTime(json['ngayhentra']),
      returnDate: parseDateTime(json['ngaytrathucte']),
      bookConditionOnReturn: json['tinhtrangsachkhitra'] as String?,      fineAmount: parseIntOrDefault(json['tienphatphatsinh'], 0),
      status: parseIntOrDefault(json['trangthai'], 0),
      // Cột solangiahan có thể chưa tồn tại trong DB - mặc định 0
      renewalCount: parseIntOrDefault(json['solangiahan'] ?? json['so_lan_gia_han'], 0),
      bookTitle: bookTitle,
      bookTitleId: bookTitleId,
      location: location,
    );
  }
  Map<String, dynamic> toInsertJson() {
    return {
      'mapm': loanId,
      'mavach': barcode,
      'ngayhentra': dueDate?.toIso8601String(),
      'ngaytrathucte': returnDate?.toIso8601String(),
      'tinhtrangsachkhitra': bookConditionOnReturn,
      'tienphatphatsinh': fineAmount,
      'trangthai': status,
    };
  }

  /// Tính số ngày quá hạn (0 nếu chưa quá hạn)
  int get overdueDays {
    if (returnDate != null || dueDate == null) return 0;
    final days = DateTime.now().difference(dueDate!).inDays;
    return days > 0 ? days : 0;
  }

  /// Kiểm tra có quá hạn không
  bool get isOverdue => overdueDays > 0;

  /// Có thể gia hạn không
  bool get canRenew => returnDate == null && renewalCount < kSupabaseMaxRenewals;
}

/// DTO kết hợp Phiếu mượn với Chi tiết
class SupabaseLoanWithDetails {
  final SupabaseLoan loan;
  final List<SupabaseLoanDetail> details;

  SupabaseLoanWithDetails({
    required this.loan,
    required this.details,
  });

  /// Tổng số sách đang mượn (chưa trả)
  int get activeBooksCount => details.where((d) => d.returnDate == null).length;

  /// Tổng số sách đã trả
  int get returnedBooksCount => details.where((d) => d.returnDate != null).length;

  /// Có sách quá hạn không
  bool get hasOverdueBooks => details.any((d) => d.isOverdue);
}

/// Result khi trả sách
class SupabaseReturnBookResult {
  const SupabaseReturnBookResult({
    required this.barcode,
    required this.isOverdue,
    required this.lateDays,
    required this.fineAmount,
    this.pointsEarned = 0,
    this.depositRefunded = 0,
  });

  final String barcode;
  final bool isOverdue;
  final int lateDays;
  final int fineAmount;
  final int pointsEarned;
  final int depositRefunded; // Tiền cọc đã hoàn

  /// Có phạt cần thu không
  bool get hasFine => isOverdue && fineAmount > 0;

  /// Số tiền thực nhận sau khi trừ phạt
  int get netRefund => depositRefunded - fineAmount;
}

// ==================== REPOSITORY ====================

/// Repository để quản lý Mượn/Trả sách trên Supabase
class SupabaseLoanRepository {
  SupabaseLoanRepository(this._client);

  final SupabaseClient _client;

  static const String _loanTable = 'phieu_muon';
  static const String _loanDetailTable = 'chi_tiet_muon';
  static const String _bookTable = 'sach';
  static const String _memberTable = 'doc_gia';

  // ==================== TẠO PHIẾU MƯỢN ====================

  /// Tạo mã phiếu mượn mới theo format PM + timestamp
  String _generateLoanId() {
    final now = DateTime.now();
    return 'PM${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
  }

  /// Tạo phiếu mượn mới
  /// 
  /// [maDG]: Mã độc giả (member ID)
  /// [maVachList]: Danh sách mã vạch sách cần mượn
  /// [ngayHenTra]: Ngày hẹn trả
  /// [maNV]: Mã nhân viên (staff ID), mặc định 'NV001'
  /// 
  /// Logic:
  /// 1. Lấy mã thẻ thành viên từ bảng the_thanh_vien
  /// 2. Insert vào phieu_muon
  /// 3. Loop insert vào chi_tiet_muon cho từng sách
  /// 4. Update trạng thái sách sang 1 (Đang mượn)
  /// 5. Trừ tiền cọc từ ví hội viên
  /// 6. Ghi log giao dịch trừ cọc
  Future<String> createLoan({
    required String maDG,
    required List<String> maVachList,
    required DateTime ngayHenTra,
    String maNV = 'NV001',
  }) async {
    try {
      if (maVachList.isEmpty) {
        throw Exception('Danh sách sách mượn không được rỗng');
      }

      // ========== BƯỚC 1: Kiểm tra số dư ví, tiền cọc và giới hạn sách ==========
      final memberResponse = await _client
          .from(_memberTable)
          .select('soduvi, magoi, goi_hoi_vien(tiencoc, sosachtoida)')
          .eq('madg', maDG.trim())
          .maybeSingle();

      if (memberResponse == null) {
        throw Exception('Không tìm thấy độc giả $maDG');
      }

      final soduvi = (memberResponse['soduvi'] as num?)?.toInt() ?? 0;
      final goiHoiVien = memberResponse['goi_hoi_vien'] as Map<String, dynamic>?;
      final tiencoc = (goiHoiVien?['tiencoc'] as num?)?.toInt() ?? 0;
      final sosachtoida = (goiHoiVien?['sosachtoida'] as num?)?.toInt() ?? 5;

      // ========== BƯỚC 2: Đếm số sách đang mượn (chưa trả) ==========
      final borrowingCountResponse = await _client
          .from(_loanDetailTable)
          .select('mavach, phieu_muon!inner(madg)')
          .eq('phieu_muon.madg', maDG.trim())
          .eq('trangthai', 0); // 0: Đang mượn (chưa trả)

      final soSachDangMuon = (borrowingCountResponse as List).length;

      // ========== BƯỚC 3: Kiểm tra giới hạn sách ==========
      final tongSachSauKhiMuon = soSachDangMuon + maVachList.length;
      if (tongSachSauKhiMuon > sosachtoida) {
        throw Exception(
          'Vượt quá giới hạn! Gói của bạn chỉ được mượn tối đa $sosachtoida cuốn. '
          'Bạn đang mượn $soSachDangMuon cuốn, không thể mượn thêm ${maVachList.length} cuốn nữa.'
        );
      }

      // ========== BƯỚC 4: Tính tổng tiền cọc (theo số đầu sách) ==========
      final int tongTienCoc = tiencoc * maVachList.length;

      // ========== BƯỚC 5: Kiểm tra số dư ví ==========
      if (soduvi < tongTienCoc) {
        throw Exception(
          'Số dư ví không đủ để mượn ${maVachList.length} cuốn sách. '
          'Cần tối thiểu ${_formatCurrency(tongTienCoc)} VNĐ (${_formatCurrency(tiencoc)}/cuốn). '
          'Số dư hiện tại: ${_formatCurrency(soduvi)} VNĐ. '
          'Vui lòng nạp thêm ${_formatCurrency(tongTienCoc - soduvi)} VNĐ.'
        );
      }

      // ========== BƯỚC 6: Lấy mã thẻ thành viên ==========
      final cardResponse = await _client
          .from('the_thanh_vien')
          .select('mast')
          .eq('madg', maDG.trim())
          .eq('trangthai', 1) // Thẻ còn hoạt động
          .maybeSingle();

      if (cardResponse == null) {
        throw Exception('Không tìm thấy thẻ thành viên hợp lệ cho độc giả $maDG');
      }

      final mast = cardResponse['mast'] as String;
      final mapm = _generateLoanId();
      final ngaymuon = DateTime.now();

      // ========== BƯỚC 7: Insert phiếu mượn ==========
      await _client.from(_loanTable).insert({
        'mapm': mapm,
        'ngaymuon': ngaymuon.toIso8601String(),
        'ghichu': null,
        'madg': maDG.trim(),
        'manv': maNV.trim(),
        'mast': mast,
      });

      // ========== BƯỚC 8: Insert chi tiết mượn cho từng sách ==========
      for (final mavach in maVachList) {
        await _client.from(_loanDetailTable).insert({
          'mapm': mapm,
          'mavach': mavach,
          'ngayhentra': ngayHenTra.toIso8601String(),
          'ngaytrathucte': null,
          'tinhtrangsachkhitra': null,
          'tienphatphatsinh': 0,
          'trangthai': 0, // 0: Đang mượn
        });

        // Update trạng thái sách sang 1 (Đang mượn)
        await _client
            .from(_bookTable)
            .update({'trangthai': 1})
            .eq('mavach', mavach);
      }

      // ========== BƯỚC 9: Trừ tiền cọc từ ví ==========
      if (tongTienCoc > 0) {
        final newBalance = soduvi - tongTienCoc;
        await _client
            .from(_memberTable)
            .update({'soduvi': newBalance})
            .eq('madg', maDG.trim());

        // ========== BƯỚC 10: Ghi log giao dịch trừ cọc ==========
        await _client.from('giao_dich_vi').insert({
          'madg': maDG.trim(),
          'loaigiaodich': 'Trừ tiền cọc',
          'sotien': tongTienCoc,
          'ngaygiaodich': DateTime.now().toIso8601String(),
          'noidung': 'Cọc mượn ${maVachList.length} sách phiếu $mapm',
        });        debugPrint('💰 Đã trừ tiền cọc: ${_formatCurrency(tongTienCoc)} VNĐ (${maVachList.length} cuốn x ${_formatCurrency(tiencoc)})');
      }

      // ========== BƯỚC 11: Ghi log nhật ký hoạt động ==========
      final activityLogRepo = SupabaseActivityLogRepository(_client);
      await activityLogRepo.addLog(
        module: ActivityModule.muonTra,
        actionType: 'Tạo phiếu mượn',
        content: 'Tạo phiếu mượn $mapm cho độc giả $maDG, mượn ${maVachList.length} cuốn sách.',
        employeeId: maNV.trim(),
        memberId: maDG.trim(),
        referenceId: mapm,
      );

      debugPrint('✅ Tạo phiếu mượn thành công: $mapm với ${maVachList.length} sách');
      return mapm;
    } catch (e) {
      debugPrint('❌ Lỗi khi tạo phiếu mượn: $e');
      rethrow;
    }
  }

  /// Format tiền tệ
  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  // ==================== LẤY DANH SÁCH PHIẾU MƯỢN ====================

  /// Lấy tất cả phiếu mượn đang hoạt động (có sách chưa trả)
  Future<List<SupabaseLoanWithDetails>> getActiveLoans() async {
    try {
      // Query phiếu mượn với join độc giả
      final loansResponse = await _client
          .from(_loanTable)
          .select('''
            *,
            doc_gia(madg, hodg, tenlotdg, tendg, sdt)
          ''')
          .order('ngaymuon', ascending: false);

      final List<SupabaseLoanWithDetails> result = [];

      for (final loanJson in loansResponse) {
        final loan = SupabaseLoan.fromJson(loanJson);

        // Query chi tiết mượn cho phiếu này với join sách và đầu sách
        final detailsResponse = await _client
            .from(_loanDetailTable)            .select('''
              *,
              sach(mavach, mads, vitri, dau_sach(mads, tensach))
            ''')
            .eq('mapm', loan.id)
            .isFilter('ngaytrathucte', null); // Chỉ lấy sách chưa trả

        if (detailsResponse.isEmpty) {
          continue; // Bỏ qua phiếu không còn sách chưa trả
        }

        final details = (detailsResponse as List)
            .map((json) => SupabaseLoanDetail.fromJson(json))
            .toList();

        result.add(SupabaseLoanWithDetails(loan: loan, details: details));
      }

      debugPrint('📚 Lấy ${result.length} phiếu mượn đang hoạt động');
      return result;
    } catch (e) {
      debugPrint('❌ Lỗi khi lấy danh sách phiếu mượn: $e');
      throw Exception('Lỗi khi lấy danh sách phiếu mượn: $e');
    }
  }

  /// Lấy tất cả phiếu mượn quá hạn
  Future<List<SupabaseLoanWithDetails>> getOverdueLoans() async {
    try {
      final now = DateTime.now().toIso8601String();

      // Query chi tiết mượn quá hạn
      final detailsResponse = await _client
          .from(_loanDetailTable)
          .select('''
            *,
            sach(mavach, mads, vitri, dau_sach(mads, tensach)),
            phieu_muon(*, doc_gia(madg, hodg, tenlotdg, tendg, sdt))
          ''')
          .isFilter('ngaytrathucte', null) // Chưa trả
          .lt('ngayhentra', now); // Quá hạn

      // Group theo phiếu mượn
      final Map<String, SupabaseLoanWithDetails> groupedLoans = {};

      for (final json in detailsResponse) {
        final detail = SupabaseLoanDetail.fromJson(json);
        
        if (!groupedLoans.containsKey(detail.loanId)) {
          // Parse loan từ nested data
          final loanJson = json['phieu_muon'] as Map<String, dynamic>?;
          if (loanJson == null) continue;
          
          final loan = SupabaseLoan.fromJson(loanJson);
          groupedLoans[detail.loanId] = SupabaseLoanWithDetails(
            loan: loan,
            details: [],
          );
        }

        // Thêm detail vào list (cần tạo list mới vì immutable)
        final existing = groupedLoans[detail.loanId]!;
        groupedLoans[detail.loanId] = SupabaseLoanWithDetails(
          loan: existing.loan,
          details: [...existing.details, detail],
        );
      }

      final result = groupedLoans.values.toList();
      debugPrint('⚠️ Lấy ${result.length} phiếu mượn quá hạn');
      return result;
    } catch (e) {
      debugPrint('❌ Lỗi khi lấy danh sách quá hạn: $e');
      throw Exception('Lỗi khi lấy danh sách quá hạn: $e');
    }
  }

  /// Lấy lịch sử mượn của một độc giả
  Future<List<SupabaseLoanWithDetails>> getLoansByMember(String memberId) async {
    try {
      final loansResponse = await _client
          .from(_loanTable)
          .select('''
            *,
            doc_gia(madg, hodg, tenlotdg, tendg, sdt)
          ''')
          .eq('madg', memberId.trim())
          .order('ngaymuon', ascending: false);

      final List<SupabaseLoanWithDetails> result = [];

      for (final loanJson in loansResponse) {
        final loan = SupabaseLoan.fromJson(loanJson);

        final detailsResponse = await _client
            .from(_loanDetailTable)            .select('''
              *,
              sach(mavach, mads, vitri, dau_sach(mads, tensach))
            ''')
            .eq('mapm', loan.id);

        final details = (detailsResponse as List)
            .map((json) => SupabaseLoanDetail.fromJson(json))
            .toList();

        result.add(SupabaseLoanWithDetails(loan: loan, details: details));
      }

      return result;
    } catch (e) {
      debugPrint('❌ Lỗi khi lấy lịch sử mượn: $e');
      throw Exception('Lỗi khi lấy lịch sử mượn: $e');
    }
  }

  /// Lấy chi tiết một phiếu mượn
  Future<SupabaseLoanWithDetails?> getLoanById(String loanId) async {
    try {
      final loanResponse = await _client
          .from(_loanTable)
          .select('''
            *,
            doc_gia(madg, hodg, tenlotdg, tendg, sdt)
          ''')          .eq('mapm', loanId)
          .maybeSingle();

      if (loanResponse == null) return null;

      final loan = SupabaseLoan.fromJson(loanResponse);

      final detailsResponse = await _client
          .from(_loanDetailTable)
          .select('''            *,
            sach(mavach, mads, vitri, dau_sach(mads, tensach))
          ''')
          .eq('mapm', loanId);

      final details = (detailsResponse as List)
          .map((json) => SupabaseLoanDetail.fromJson(json))
          .toList();

      return SupabaseLoanWithDetails(loan: loan, details: details);
    } catch (e) {
      debugPrint('❌ Lỗi khi lấy chi tiết phiếu mượn: $e');
      throw Exception('Lỗi khi lấy chi tiết phiếu mượn: $e');
    }
  }

  // ==================== TRẢ SÁCH ====================

  /// Trả một cuốn sách
  /// 
  /// [loanId]: Mã phiếu mượn
  /// [barcode]: Mã vạch sách cần trả
  /// [bookCondition]: Tình trạng sách khi trả (tùy chọn)
  /// 
  /// Logic:
  /// 1. Tính số ngày quá hạn và tiền phạt
  /// 2. Update chi_tiet_muon: ngaytrathucte, tinhtrangsachkhitra, tienphatphatsinh, trangthai
  /// 3. Update sach.trangthai về 0 (Sẵn sàng)
  /// 4. Hoàn tiền cọc (1 cuốn) và trừ tiền phạt (nếu có)
  /// 5. Ghi log giao dịch hoàn cọc và phạt
  /// 6. Nếu đúng hạn: cộng điểm cho độc giả
  Future<SupabaseReturnBookResult> returnBook({
    required String loanId,
    required String barcode,
    String? bookCondition,
  }) async {
    // Gọi hàm returnBooks với 1 sách
    final results = await returnBooks(
      loanId: loanId,
      barcodes: [barcode],
      bookCondition: bookCondition,
    );
    return results.first;
  }

  /// Trả nhiều cuốn sách cùng lúc
  /// 
  /// [loanId]: Mã phiếu mượn
  /// [barcodes]: Danh sách mã vạch sách cần trả
  /// [bookCondition]: Tình trạng sách khi trả (tùy chọn)
  /// 
  /// Logic:
  /// 1. Lấy thông tin chi tiết từng sách mượn
  /// 2. Tính tổng tiền phạt cho tất cả sách
  /// 3. Update chi_tiet_muon cho từng sách
  /// 4. Update sach.trangthai về 0 cho từng sách
  /// 5. Hoàn tiền cọc = tiencoc * số sách trả - tổng tiền phạt
  /// 6. Ghi log giao dịch hoàn cọc và phạt
  /// 7. Cộng điểm nếu có sách đúng hạn
  Future<List<SupabaseReturnBookResult>> returnBooks({
    required String loanId,
    required List<String> barcodes,
    String? bookCondition,
  }) async {
    try {
      if (barcodes.isEmpty) {
        throw Exception('Danh sách sách trả không được rỗng');
      }

      final soLuongTra = barcodes.length;
      String? memberId;
      int tongTienPhat = 0;
      int tongDiemCong = 0;
      final List<SupabaseReturnBookResult> results = [];

      // ========== BƯỚC 1: Xử lý từng sách ==========
      for (final barcode in barcodes) {
        // Lấy thông tin chi tiết mượn
        final detailResponse = await _client
            .from(_loanDetailTable)
            .select('*, phieu_muon(madg)')
            .eq('mapm', loanId)
            .eq('mavach', barcode)
            .maybeSingle();

        if (detailResponse == null) {
          throw Exception('Không tìm thấy thông tin mượn sách $barcode trong phiếu $loanId');
        }

        // Lấy memberId từ phiếu đầu tiên
        if (memberId == null) {
          memberId = (detailResponse['phieu_muon'] as Map?)?['madg'] as String?;
          if (memberId == null) {
            throw Exception('Không tìm thấy thông tin độc giả');
          }
        }

        final dueDate = DateTime.tryParse(detailResponse['ngayhentra'] ?? '');
        if (dueDate == null) {
          throw Exception('Ngày hẹn trả không hợp lệ cho sách $barcode');
        }

        // Tính tiền phạt cho sách này
        final now = DateTime.now();
        final lateDays = now.difference(dueDate).inDays;
        final isOverdue = lateDays > 0;
        final fineAmount = isOverdue ? lateDays * kSupabaseFineRatePerDay : 0;
        tongTienPhat += fineAmount;

        // Cộng điểm nếu đúng hạn
        int pointsEarned = 0;
        if (!isOverdue) {
          pointsEarned = kSupabasePointsPerBook;
          tongDiemCong += pointsEarned;
        }

        // Update chi tiết mượn
        await _client
            .from(_loanDetailTable)
            .update({
              'ngaytrathucte': now.toIso8601String(),
              'tinhtrangsachkhitra': bookCondition,
              'tienphatphatsinh': fineAmount,
              'trangthai': 1, // 1: Đã trả
            })
            .eq('mapm', loanId)
            .eq('mavach', barcode);

        // Update trạng thái sách về 0 (Sẵn sàng)
        await _client
            .from(_bookTable)
            .update({'trangthai': 0})
            .eq('mavach', barcode);

        results.add(SupabaseReturnBookResult(
          barcode: barcode,
          isOverdue: isOverdue,
          lateDays: lateDays > 0 ? lateDays : 0,
          fineAmount: fineAmount,
          pointsEarned: pointsEarned,
          depositRefunded: 0, // Sẽ cập nhật sau
        ));
      }

      // ========== BƯỚC 2: Lấy thông tin ví và tiền cọc ==========
      final memberResponse = await _client
          .from(_memberTable)
          .select('soduvi, diemtichluy, magoi, goi_hoi_vien(tiencoc)')
          .eq('madg', memberId!.trim())
          .maybeSingle();

      if (memberResponse == null) {
        throw Exception('Không tìm thấy thông tin độc giả $memberId');
      }

      final soduvi = (memberResponse['soduvi'] as num?)?.toInt() ?? 0;
      final currentPoints = (memberResponse['diemtichluy'] as num?)?.toInt() ?? 0;
      final goiHoiVien = memberResponse['goi_hoi_vien'] as Map<String, dynamic>?;
      final tiencoc = (goiHoiVien?['tiencoc'] as num?)?.toInt() ?? 0;

      // ========== BƯỚC 3: Tính tổng tiền hoàn cọc ==========
      final int tongTienHoan = tiencoc * soLuongTra;

      // ========== BƯỚC 4: Cập nhật số dư ví ==========
      // Công thức: soduvi_moi = soduvi_cu + tongTienHoan - tongTienPhat
      final newBalance = soduvi + tongTienHoan - tongTienPhat;
      await _client
          .from(_memberTable)
          .update({'soduvi': newBalance})
          .eq('madg', memberId.trim());

      // ========== BƯỚC 5: Ghi log giao dịch hoàn cọc ==========
      if (tongTienHoan > 0) {
        await _client.from('giao_dich_vi').insert({
          'madg': memberId.trim(),
          'loaigiaodich': 'Hoàn tiền cọc',
          'sotien': tongTienHoan,
          'ngaygiaodich': DateTime.now().toIso8601String(),
          'noidung': 'Hoàn cọc trả $soLuongTra sách (phiếu $loanId)',
        });
        debugPrint('💰 Đã hoàn tiền cọc: ${_formatCurrency(tongTienHoan)} VNĐ ($soLuongTra cuốn x ${_formatCurrency(tiencoc)})');
      }

      // ========== BƯỚC 6: Ghi log giao dịch phạt (nếu có) ==========
      if (tongTienPhat > 0) {
        await _client.from('giao_dich_vi').insert({
          'madg': memberId.trim(),
          'loaigiaodich': 'Phạt trễ hạn',
          'sotien': tongTienPhat,
          'ngaygiaodich': DateTime.now().toIso8601String(),
          'noidung': 'Phạt trễ hạn trả $soLuongTra sách (phiếu $loanId)',
        });
        debugPrint('⚠️ Đã trừ tiền phạt: ${_formatCurrency(tongTienPhat)} VNĐ');
      }

      // ========== BƯỚC 7: Cộng điểm tích lũy ==========
      if (tongDiemCong > 0) {
        await _client
            .from(_memberTable)
            .update({'diemtichluy': currentPoints + tongDiemCong})
            .eq('madg', memberId.trim());
        debugPrint('⭐ Đã cộng $tongDiemCong điểm tích lũy');
      }      // Cập nhật depositRefunded cho kết quả đầu tiên (hoặc chia đều)
      final updatedResults = results.map((r) => SupabaseReturnBookResult(
        barcode: r.barcode,
        isOverdue: r.isOverdue,
        lateDays: r.lateDays,
        fineAmount: r.fineAmount,
        pointsEarned: r.pointsEarned,
        depositRefunded: tiencoc, // Mỗi sách hoàn 1 phần cọc
      )).toList();

      // ========== BƯỚC 8: Ghi log nhật ký hoạt động ==========
      final activityLogRepo = SupabaseActivityLogRepository(_client);
      final barcodeListStr = barcodes.join(', ');
      await activityLogRepo.addLog(
        module: ActivityModule.muonTra,
        actionType: 'Nhận trả sách',
        content: 'Nhận trả $soLuongTra sách ($barcodeListStr) từ phiếu $loanId. Hoàn cọc ${_formatCurrency(tongTienHoan)} VNĐ${tongTienPhat > 0 ? ', phạt ${_formatCurrency(tongTienPhat)} VNĐ' : ''}.',
        memberId: memberId.trim(),
        referenceId: loanId,
      );

      debugPrint('✅ Trả $soLuongTra sách thành công. Hoàn: ${_formatCurrency(tongTienHoan)}, Phạt: ${_formatCurrency(tongTienPhat)}');

      return updatedResults;
    } catch (e) {
      debugPrint('❌ Lỗi khi trả sách: $e');
      rethrow;
    }
  }

  // ==================== GIA HẠN ====================

  /// Gia hạn thời gian mượn sách
  /// 
  /// [loanId]: Mã phiếu mượn
  /// [barcode]: Mã vạch sách cần gia hạn
  /// 
  /// Returns: Ngày hẹn trả mới
  Future<DateTime> renewBook({
    required String loanId,
    required String barcode,
  }) async {
    try {
      // Lấy thông tin chi tiết mượn
      final detailResponse = await _client
          .from(_loanDetailTable)          .select('ngayhentra, solangiahan, ngaytrathucte')
          .eq('mapm', loanId)
          .eq('mavach', barcode)
          .maybeSingle();

      if (detailResponse == null) {
        throw Exception('Không tìm thấy thông tin mượn sách');
      }

      // Kiểm tra đã trả chưa
      if (detailResponse['ngaytrathucte'] != null) {
        throw Exception('Sách đã được trả, không thể gia hạn');
      }

      // Kiểm tra số lần gia hạn
      final currentRenewals = (detailResponse['solangiahan'] as num?)?.toInt() ?? 0;
      if (currentRenewals >= kSupabaseMaxRenewals) {
        throw Exception('Đã đạt giới hạn gia hạn ($kSupabaseMaxRenewals lần)');
      }

      // Tính ngày hẹn trả mới
      final currentDueDate = DateTime.parse(detailResponse['ngayhentra']);
      final newDueDate = currentDueDate.add(Duration(days: kSupabaseRenewalDays));

      // Update
      await _client
          .from(_loanDetailTable)
          .update({            'ngayhentra': newDueDate.toIso8601String(),
            'solangiahan': currentRenewals + 1,
            'trangthai': 0, // Reset về đang mượn nếu trước đó là quá hạn
          })
          .eq('mapm', loanId)
          .eq('mavach', barcode);

      debugPrint('✅ Gia hạn sách $barcode thành công. Hạn mới: $newDueDate');
      return newDueDate;
    } catch (e) {
      debugPrint('❌ Lỗi khi gia hạn: $e');
      throw Exception('Lỗi khi gia hạn: $e');
    }
  }

  // ==================== LẤY SÁCH CÓ SẴN ====================

  /// Lấy danh sách sách có sẵn để mượn
  Future<List<Map<String, dynamic>>> getAvailableBooks() async {
    try {
      final response = await _client
          .from(_bookTable)
          .select('''
            mavach, vitri, trangthai,
            dau_sach(mads, tensach)
          ''')
          .eq('trangthai', 0) // 0: Sẵn sàng
          .order('mavach');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('❌ Lỗi khi lấy danh sách sách có sẵn: $e');
      throw Exception('Lỗi khi lấy danh sách sách có sẵn: $e');
    }
  }

  /// Lấy bookTitleId (MaDauSach) từ barcode
  Future<String?> getBookTitleIdByBarcode(String barcode) async {
    try {
      final response = await _client
          .from(_bookTable)
          .select('mads')
          .eq('mavach', barcode)
          .maybeSingle();

      return response?['mads'] as String?;
    } catch (e) {
      return null;
    }
  }
}

// ==================== PROVIDERS ====================

/// Provider cho SupabaseClient
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Provider cho SupabaseLoanRepository
final supabaseLoanRepositoryProvider = Provider<SupabaseLoanRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseLoanRepository(client);
});

/// Provider cho danh sách phiếu mượn đang hoạt động
final activeLoansProvider = FutureProvider<List<SupabaseLoanWithDetails>>((ref) async {
  final repo = ref.watch(supabaseLoanRepositoryProvider);
  return repo.getActiveLoans();
});

/// Provider cho danh sách phiếu mượn quá hạn
final overdueLoansProvider = FutureProvider<List<SupabaseLoanWithDetails>>((ref) async {
  final repo = ref.watch(supabaseLoanRepositoryProvider);
  return repo.getOverdueLoans();
});

/// Provider cho lịch sử mượn của một độc giả
final memberLoanHistorySupabaseProvider = FutureProvider.family
    .autoDispose<List<SupabaseLoanWithDetails>, String>((ref, memberId) async {
  final repo = ref.watch(supabaseLoanRepositoryProvider);
  return repo.getLoansByMember(memberId);
});

/// Provider cho danh sách sách có sẵn
final availableBooksProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.watch(supabaseLoanRepositoryProvider);
  return repo.getAvailableBooks();
});
