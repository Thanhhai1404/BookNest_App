import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'member_view_model.dart';

/// Asynchronously generates an auto ID for new members.
final generateMemberIdProvider =
    FutureProvider.autoDispose<String>((ref) async {
  final repo = ref.watch(memberRepositoryProvider);
  return repo.generateNextMemberId();
});
