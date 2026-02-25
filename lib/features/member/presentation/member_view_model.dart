import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../members/data/member_repository.dart';

// Re-export providers for backward compatibility
export '../../members/data/member_repository.dart'
    show supabaseMemberRepositoryProvider, SupabaseMember, generateSupabaseMemberIdProvider;
export '../../members/data/package_repository.dart'
    show packageRepositoryProvider, SupabasePackage, packagesProvider;

class MemberListState {
  const MemberListState({
    required this.query,
    required this.debouncedQuery,
    required this.members,
    required this.isLoading,
    this.error,
  });

  /// Giá trị user đang nhập (realtime)
  final String query;

  /// Giá trị sau debounce (dùng để query DB)
  final String debouncedQuery;

  /// Danh sách hội viên
  final List<SupabaseMember> members;

  /// Đang tải dữ liệu
  final bool isLoading;

  /// Lỗi nếu có
  final String? error;

  MemberListState copyWith({
    String? query,
    String? debouncedQuery,
    List<SupabaseMember>? members,
    bool? isLoading,
    String? error,
  }) {
    return MemberListState(
      query: query ?? this.query,
      debouncedQuery: debouncedQuery ?? this.debouncedQuery,
      members: members ?? this.members,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  static const initial = MemberListState(
    query: '',
    debouncedQuery: '',
    members: [],
    isLoading: true,
    error: null,
  );
}

/// Controls search query with 500ms debounce; members list fetched from Supabase.
class MemberListController extends StateNotifier<MemberListState> {
  MemberListController(this.ref) : super(MemberListState.initial) {
    // Load members on init
    _loadMembers();
  }

  final Ref ref;
  Timer? _debounceTimer;

  void setQuery(String value) {
    state = state.copyWith(query: value);

    // Cancel previous timer
    _debounceTimer?.cancel();

    // Debounce 500ms before updating debouncedQuery and fetching
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      state = state.copyWith(debouncedQuery: value);
      _loadMembers();
    });
  }

  void clearQuery() {
    _debounceTimer?.cancel();
    state = state.copyWith(query: '', debouncedQuery: '');
    _loadMembers();
  }

  /// Set query and trigger search immediately (no debounce) - used for scanner results
  void setQueryImmediate(String value) {
    _debounceTimer?.cancel();
    state = state.copyWith(query: value, debouncedQuery: value);
    _loadMembers();
  }

  /// Load hoặc refresh danh sách hội viên từ Supabase
  Future<void> _loadMembers() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final repo = ref.read(supabaseMemberRepositoryProvider);
      final q = state.debouncedQuery.trim();

      final members = q.isEmpty
          ? await repo.getMembers()
          : await repo.searchMembers(q);

      state = state.copyWith(members: members, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Refresh danh sách (public)
  Future<void> refresh() async {
    await _loadMembers();
  }

  /// Xóa hội viên
  Future<void> delete(String id) async {
    final repo = ref.read(supabaseMemberRepositoryProvider);
    await repo.deleteMember(id);
    await _loadMembers();
  }
  /// Thêm hội viên mới
  /// [avatarFile] - File avatar (optional), sẽ được upload lên Storage
  Future<void> addMember({
    required String id,
    String? lastName,
    String? middleName,
    String? firstName,
    String? phone,
    required String nationalId,
    required String email,
    String? address,
    bool isActive = true,
    required String packageId,
    String? avatarUrl,
    File? avatarFile,
  }) async {
    final repo = ref.read(supabaseMemberRepositoryProvider);
    await repo.addMember(
      id: id,
      lastName: lastName,
      middleName: middleName,
      firstName: firstName,
      phone: phone,
      nationalId: nationalId,
      email: email,
      address: address,
      isActive: isActive,
      packageId: packageId,
      avatarUrl: avatarUrl,
      avatarFile: avatarFile,
    );
    await _loadMembers();
  }
  /// Cập nhật hội viên
  /// [avatarFile] - File avatar mới (optional), sẽ được upload lên Storage
  Future<void> updateMember({
    required String id,
    String? lastName,
    String? middleName,
    String? firstName,
    String? phone,
    String? nationalId,
    String? email,
    String? address,
    bool? isActive,
    String? packageId,
    String? avatarUrl,
    File? avatarFile,
  }) async {
    final repo = ref.read(supabaseMemberRepositoryProvider);
    await repo.updateMember(
      id: id,
      lastName: lastName,
      middleName: middleName,
      firstName: firstName,
      phone: phone,
      nationalId: nationalId,
      email: email,
      address: address,
      isActive: isActive,
      packageId: packageId,
      avatarUrl: avatarUrl,
      avatarFile: avatarFile,
    );
    await _loadMembers();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

final memberListControllerProvider =
    StateNotifierProvider<MemberListController, MemberListState>((ref) {
  return MemberListController(ref);
});

/// Provider để tạo mã hội viên mới
final generateMemberIdProvider = FutureProvider<String>((ref) async {
  final repo = ref.watch(supabaseMemberRepositoryProvider);
  return repo.generateNextMemberId();
});
