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
  });

  final String query;

  MemberListState copyWith({String? query}) {
    return MemberListState(query: query ?? this.query);
  }

  static const initial = MemberListState(query: '');
}

/// Controls search query; members list is a stream derived from query.
class MemberListController extends StateNotifier<MemberListState> {
  MemberListController(this.ref) : super(MemberListState.initial);

  final Ref ref;

  void setQuery(String value) {
    state = state.copyWith(query: value);
  }

  Stream<List<Member>> watchMembers() {
    final repo = ref.read(memberRepositoryProvider);
    final q = state.query.trim();
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
}

final memberListControllerProvider =
    StateNotifierProvider<MemberListController, MemberListState>((ref) {
  return MemberListController(ref);
});

/// Convenience stream provider that updates when search query changes.
final memberListStreamProvider =
    StreamProvider.autoDispose<List<Member>>((ref) {
  final controller = ref.watch(memberListControllerProvider.notifier);
  // Rebuild when query changes
  ref.watch(memberListControllerProvider);
  return controller.watchMembers();
});
