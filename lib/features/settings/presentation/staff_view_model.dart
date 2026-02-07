import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/db/app_database.dart';
import '../../../data/repositories/staff_repository.dart';

/// State for staff list
class StaffListState {
  const StaffListState({
    required this.staffList,
    this.isProcessing = false,
  });

  final List<StaffAccount> staffList;
  final bool isProcessing;

  StaffListState copyWith({
    List<StaffAccount>? staffList,
    bool? isProcessing,
  }) {
    return StaffListState(
      staffList: staffList ?? this.staffList,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }
}

/// ViewModel for managing staff accounts
class StaffViewModel extends AsyncNotifier<StaffListState> {
  late StaffRepository _repo;

  @override
  Future<StaffListState> build() async {
    _repo = ref.watch(staffRepositoryProvider);
    return _loadStaff();
  }

  Future<StaffListState> _loadStaff() async {
    final staffList = await _repo.getAllStaff();
    return StaffListState(staffList: staffList);
  }

  /// Refresh the staff list
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _loadStaff());
  }

  /// Create new staff account
  /// Returns error message if failed, null if success
  Future<String?> createStaff({
    required String username,
    required String password,
    String? lastName,
    String? middleName,
    String? firstName,
    String? role,
  }) async {
    final currentState = state.valueOrNull;
    if (currentState == null || currentState.isProcessing) {
      return 'Đang xử lý, vui lòng đợi...';
    }

    state = AsyncData(currentState.copyWith(isProcessing: true));

    try {
      // Generate next ID
      final nextId = await _repo.generateNextId();

      final result = await _repo.createStaff(
        id: nextId,
        username: username,
        password: password,
        lastName: lastName,
        middleName: middleName,
        firstName: firstName,
        role: role,
      );

      if (result != null) {
        await refresh();
        return null; // Success
      } else {
        state = AsyncData(currentState.copyWith(isProcessing: false));
        return 'Tên đăng nhập đã tồn tại';
      }
    } catch (e) {
      state = AsyncData(currentState.copyWith(isProcessing: false));
      return 'Lỗi: $e';
    }
  }

  /// Update staff account
  Future<String?> updateStaff({
    required String id,
    String? lastName,
    String? middleName,
    String? firstName,
    String? role,
    String? username,
    String? password,
  }) async {
    final currentState = state.valueOrNull;
    if (currentState == null || currentState.isProcessing) {
      return 'Đang xử lý, vui lòng đợi...';
    }

    state = AsyncData(currentState.copyWith(isProcessing: true));

    try {
      final success = await _repo.updateStaff(
        id: id,
        lastName: lastName,
        middleName: middleName,
        firstName: firstName,
        role: role,
        username: username,
        password: password,
      );

      if (success) {
        await refresh();
        return null; // Success
      } else {
        state = AsyncData(currentState.copyWith(isProcessing: false));
        return 'Cập nhật thất bại (tên đăng nhập có thể đã tồn tại)';
      }
    } catch (e) {
      state = AsyncData(currentState.copyWith(isProcessing: false));
      return 'Lỗi: $e';
    }
  }

  /// Delete staff account
  Future<bool> deleteStaff(String id) async {
    final currentState = state.valueOrNull;
    if (currentState == null || currentState.isProcessing) return false;

    state = AsyncData(currentState.copyWith(isProcessing: true));

    try {
      final success = await _repo.deleteStaff(id);
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

/// Provider for StaffViewModel
final staffViewModelProvider =
    AsyncNotifierProvider<StaffViewModel, StaffListState>(
  StaffViewModel.new,
);
