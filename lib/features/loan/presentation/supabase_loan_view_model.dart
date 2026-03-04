import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/supabase_loan_repository.dart';

/// DTO cho sách có sẵn để mượn (Supabase version)
class SupabaseAvailableCopyInfo {
  const SupabaseAvailableCopyInfo({
    required this.barcode,
    required this.bookTitle,
    this.location,
  });

  final String barcode;
  final String bookTitle;
  final String? location;

  String get displayText => '$bookTitle - $barcode';

  factory SupabaseAvailableCopyInfo.fromJson(Map<String, dynamic> json) {
    String? bookTitle;
    if (json['dau_sach'] != null && json['dau_sach'] is Map) {
      bookTitle = json['dau_sach']['tensach'] as String?;
    }
    
    return SupabaseAvailableCopyInfo(
      barcode: json['mavach'] as String,
      bookTitle: bookTitle ?? json['mavach'] as String,
      location: json['vitri'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SupabaseAvailableCopyInfo &&
          runtimeType == other.runtimeType &&
          barcode == other.barcode;

  @override
  int get hashCode => barcode.hashCode;
}

/// State cho loan list screen (Supabase version)
class SupabaseLoanListState {
  const SupabaseLoanListState({
    required this.activeLoans,
    required this.overdueLoans,
  });

  final List<SupabaseLoanWithDetails> activeLoans;
  final List<SupabaseLoanWithDetails> overdueLoans;
}

/// ViewModel cho quản lý mượn/trả sách với Supabase
class SupabaseLoanViewModel extends AsyncNotifier<SupabaseLoanListState> {
  @override
  Future<SupabaseLoanListState> build() async {
    final repo = ref.watch(supabaseLoanRepositoryProvider);
    final activeLoans = await repo.getActiveLoans();
    final overdueLoans = await repo.getOverdueLoans();
    return SupabaseLoanListState(
      activeLoans: activeLoans,
      overdueLoans: overdueLoans,
    );
  }

  /// Làm mới danh sách
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(supabaseLoanRepositoryProvider);
      final activeLoans = await repo.getActiveLoans();
      final overdueLoans = await repo.getOverdueLoans();
      return SupabaseLoanListState(
        activeLoans: activeLoans,
        overdueLoans: overdueLoans,
      );
    });
  }

  /// Tạo phiếu mượn sách
  /// 
  /// [memberId]: Mã độc giả
  /// [barcodes]: Danh sách mã vạch sách cần mượn
  /// [dueDate]: Ngày hẹn trả
  Future<String> borrowBooks({
    required String memberId,
    required List<String> barcodes,
    required DateTime dueDate,
  }) async {
    final repo = ref.read(supabaseLoanRepositoryProvider);
    final loanId = await repo.createLoan(
      maDG: memberId,
      maVachList: barcodes,
      ngayHenTra: dueDate,
    );
    await refresh();
    return loanId;
  }

  /// Mượn một cuốn sách (backward compatible với UI cũ)
  Future<String> borrowBook({
    required String memberId,
    required String copyId,
    required DateTime dueDate,
  }) async {
    return borrowBooks(
      memberId: memberId,
      barcodes: [copyId],
      dueDate: dueDate,
    );
  }

  /// Trả một cuốn sách
  Future<SupabaseReturnBookResult> returnBook({
    required String loanId,
    required String barcode,
    String? bookCondition,
  }) async {
    final repo = ref.read(supabaseLoanRepositoryProvider);
    final result = await repo.returnBook(
      loanId: loanId,
      barcode: barcode,
      bookCondition: bookCondition,
    );
    ref.invalidateSelf();
    return result;
  }

  /// Gia hạn sách
  Future<DateTime> renewBook({
    required String loanId,
    required String barcode,
  }) async {
    final repo = ref.read(supabaseLoanRepositoryProvider);
    final newDueDate = await repo.renewBook(
      loanId: loanId,
      barcode: barcode,
    );
    ref.invalidateSelf();
    return newDueDate;
  }
}

/// Provider cho SupabaseLoanViewModel
final supabaseLoanViewModelProvider =
    AsyncNotifierProvider<SupabaseLoanViewModel, SupabaseLoanListState>(
        SupabaseLoanViewModel.new);

/// Provider cho danh sách sách có sẵn để mượn
final supabaseAvailableCopiesProvider =
    FutureProvider<List<SupabaseAvailableCopyInfo>>((ref) async {
  final repo = ref.watch(supabaseLoanRepositoryProvider);
  final books = await repo.getAvailableBooks();
  return books.map((json) => SupabaseAvailableCopyInfo.fromJson(json)).toList();
});

/// Provider cho danh sách độc giả (để chọn khi mượn sách)
final supabaseMembersForLoanProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final client = ref.watch(supabaseClientProvider);
  final response = await client
      .from('doc_gia')
      .select('madg, hodg, tenlotdg, tendg, sdt, trangthai')
      .eq('trangthai', true) // Chỉ lấy độc giả còn hoạt động
      .order('madg');
  return List<Map<String, dynamic>>.from(response);
});

/// Helper để format tên độc giả từ JSON
String formatMemberNameFromJson(Map<String, dynamic> json) {
  final ho = (json['hodg'] ?? '') as String;
  final tenLot = (json['tenlotdg'] ?? '') as String;
  final ten = (json['tendg'] ?? '') as String;
  final fullName = [ho, tenLot, ten]
      .where((e) => e.trim().isNotEmpty)
      .join(' ');
  return fullName.isEmpty ? json['madg'] as String : fullName;
}
