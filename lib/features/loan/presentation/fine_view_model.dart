import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/finance_repository.dart';

/// State for fine list with both pending and paid fines
class FineListState {
  const FineListState({
    required this.pendingFines,
    required this.paidFines,
    this.isProcessing = false,
  });

  final List<FineWithDetails> pendingFines;
  final List<FineWithDetails> paidFines;
  final bool isProcessing;

  /// Total pending fine amount
  int get totalPendingAmount =>
      pendingFines.fold(0, (sum, f) => sum + f.fine.amount);

  /// Total paid fine amount
  int get totalPaidAmount =>
      paidFines.fold(0, (sum, f) => sum + f.fine.amount);

  FineListState copyWith({
    List<FineWithDetails>? pendingFines,
    List<FineWithDetails>? paidFines,
    bool? isProcessing,
  }) {
    return FineListState(
      pendingFines: pendingFines ?? this.pendingFines,
      paidFines: paidFines ?? this.paidFines,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }
}

/// ViewModel for managing fines
class FineViewModel extends AsyncNotifier<FineListState> {
  late FinanceRepository _financeRepo;

  @override
  Future<FineListState> build() async {
    _financeRepo = ref.watch(financeRepositoryProvider);
    return _loadFines();
  }

  Future<FineListState> _loadFines() async {
    final pendingFines = await _financeRepo.getAllPendingFinesWithDetails();
    final paidFines = await _financeRepo.getAllPaidFinesWithDetails();
    return FineListState(
      pendingFines: pendingFines,
      paidFines: paidFines,
    );
  }

  /// Refresh the fine list
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _loadFines());
  }

  /// Pay a fine using cash (manual payment by admin).
  /// 
  /// This is for when member pays cash directly to admin.
  /// Does NOT deduct from member's wallet, only records the transaction.
  /// 
  /// Returns a [PayFineResult] with success status and message.
  Future<PayFineResult> payFineByCash(FineWithDetails fineDetails) async {
    // Check if already processing
    final currentState = state.valueOrNull;
    if (currentState == null || currentState.isProcessing) {
      return PayFineResult(
        success: false,
        message: 'Đang xử lý, vui lòng đợi...',
      );
    }

    // Set processing state
    state = AsyncData(currentState.copyWith(isProcessing: true));

    try {
      // Pay the fine by cash (no wallet deduction)
      final success = await _financeRepo.payFineByCash(
        fineId: fineDetails.fine.id,
      );

      if (success) {
        // Reload fines
        await refresh();
        return PayFineResult(
          success: true,
          message: 'Đã thu tiền phạt thành công!\nSố tiền: ${fineDetails.fine.amount}đ (Tiền mặt)',
        );
      } else {
        state = AsyncData(currentState.copyWith(isProcessing: false));
        return PayFineResult(
          success: false,
          message: 'Thu phạt thất bại. Vui lòng thử lại.',
        );
      }
    } catch (e) {
      state = AsyncData(currentState.copyWith(isProcessing: false));
      return PayFineResult(
        success: false,
        message: 'Lỗi: $e',
      );
    }
  }

  /// Pay a fine using member's wallet.
  /// 
  /// Returns a [PayFineResult] with success status and message.
  Future<PayFineResult> payFineFromWallet(FineWithDetails fineDetails) async {
    // Check if already processing
    final currentState = state.valueOrNull;
    if (currentState == null || currentState.isProcessing) {
      return PayFineResult(
        success: false,
        message: 'Đang xử lý, vui lòng đợi...',
      );
    }

    // Set processing state
    state = AsyncData(currentState.copyWith(isProcessing: true));

    try {
      // Check balance
      if (!fineDetails.canPayFromWallet) {
        state = AsyncData(currentState.copyWith(isProcessing: false));
        return PayFineResult(
          success: false,
          message: 'Số dư ví không đủ!\n'
              'Số dư hiện tại: ${fineDetails.memberBalance}đ\n'
              'Số tiền phạt: ${fineDetails.fine.amount}đ',
        );
      }

      // Pay the fine
      final success = await _financeRepo.payFine(
        fineId: fineDetails.fine.id,
        memberId: fineDetails.memberId,
      );

      if (success) {
        // Reload fines
        await refresh();
        return PayFineResult(
          success: true,
          message: 'Đã thanh toán thành công!',
          newBalance: fineDetails.memberBalance - fineDetails.fine.amount,
        );
      } else {
        state = AsyncData(currentState.copyWith(isProcessing: false));
        return PayFineResult(
          success: false,
          message: 'Thanh toán thất bại. Vui lòng thử lại.',
        );
      }
    } catch (e) {
      state = AsyncData(currentState.copyWith(isProcessing: false));
      return PayFineResult(
        success: false,
        message: 'Lỗi: $e',
      );
    }
  }

  /// Waive a fine (forgive without payment).
  Future<bool> waiveFine(int fineId) async {
    final currentState = state.valueOrNull;
    if (currentState == null || currentState.isProcessing) return false;

    state = AsyncData(currentState.copyWith(isProcessing: true));

    try {
      final success = await _financeRepo.waiveFine(fineId);
      if (success) {
        await refresh();
      } else {
        state = AsyncData(currentState.copyWith(isProcessing: false));
      }
      return success;
    } catch (e) {
      state = AsyncData(currentState.copyWith(isProcessing: false));
      return false;
    }
  }
}

/// Result of paying a fine
class PayFineResult {
  const PayFineResult({
    required this.success,
    required this.message,
    this.newBalance,
  });

  final bool success;
  final String message;
  final int? newBalance;
}

/// Provider for FineViewModel
final fineViewModelProvider =
    AsyncNotifierProvider<FineViewModel, FineListState>(() {
  return FineViewModel();
});
