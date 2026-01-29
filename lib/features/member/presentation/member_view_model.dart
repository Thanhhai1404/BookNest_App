import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/db/app_database.dart';
import '../../../data/repositories/member_repository.dart';

/// Provider for repository
final memberRepositoryProvider = Provider<MemberRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return MemberRepository(db);
});

class MemberListState {
  const MemberListState({
    required this.query,
    required this.debouncedQuery,
  });

  /// Giá trị user đang nhập (realtime)
  final String query;

  /// Giá trị sau debounce (dùng để query DB)
  final String debouncedQuery;

  MemberListState copyWith({String? query, String? debouncedQuery}) {
    return MemberListState(
      query: query ?? this.query,
      debouncedQuery: debouncedQuery ?? this.debouncedQuery,
    );
  }

  static const initial = MemberListState(query: '', debouncedQuery: '');
}

/// Controls search query with 500ms debounce; members list is a stream derived from query.
class MemberListController extends StateNotifier<MemberListState> {
  MemberListController(this.ref) : super(MemberListState.initial);

  final Ref ref;
  Timer? _debounceTimer;

  void setQuery(String value) {
    state = state.copyWith(query: value);

    // Cancel previous timer
    _debounceTimer?.cancel();

    // Debounce 500ms before updating debouncedQuery
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      state = state.copyWith(debouncedQuery: value);
    });
  }
  void clearQuery() {
    _debounceTimer?.cancel();
    state = MemberListState.initial;
  }

  /// Set query and trigger search immediately (no debounce) - used for scanner results
  void setQueryImmediate(String value) {
    _debounceTimer?.cancel();
    state = state.copyWith(query: value, debouncedQuery: value);
  }

  Stream<List<Member>> watchMembers() {
    final repo = ref.read(memberRepositoryProvider);
    final q = state.debouncedQuery.trim();
    return repo.watchMembers(query: q.isEmpty ? null : q);
  }

  Future<void> delete(String id) async {
    final repo = ref.read(memberRepositoryProvider);
    await repo.deleteMember(id);
  }

  Future<void> upsert(MembersCompanion data, {required bool isUpdate}) async {
    final repo = ref.read(memberRepositoryProvider);
    if (isUpdate) {
      await repo.updateMember(data);
    } else {
      await repo.addMember(data);
    }
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

/// Convenience stream provider that updates when debounced query changes.
final memberListStreamProvider =
    StreamProvider.autoDispose<List<Member>>((ref) {
  final controller = ref.watch(memberListControllerProvider.notifier);
  // Only rebuild when debouncedQuery changes
  ref.watch(memberListControllerProvider.select((s) => s.debouncedQuery));
  return controller.watchMembers();
});
