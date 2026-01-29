import 'package:drift/drift.dart';

import '../db/app_database.dart';

class MemberRepository {
  MemberRepository(this.db);

  final AppDatabase db;

  /// Stream list members. Supports searching by name parts or phone.
  ///
  /// - If [query] is null/empty: returns all members ordered by id.
  /// - Otherwise: matches `lastName`, `middleName`, `firstName`, or `phone`.
  Stream<List<Member>> watchMembers({String? query}) {
    final q = db.select(db.members);

    final normalized = (query ?? '').trim().toLowerCase();
    if (normalized.isNotEmpty) {
      final like = '%$normalized%';
      q.where((m) {
        // Use lower() to make search case-insensitive.
        return m.lastName.lower().like(like) |
            m.middleName.lower().like(like) |
            m.firstName.lower().like(like) |
            m.phone.lower().like(like);
      });
    }

    q.orderBy([(m) => OrderingTerm(expression: m.id)]);
    return q.watch();
  }

  Future<Member?> getMemberById(String id) {
    return (db.select(db.members)..where((m) => m.id.equals(id)))
        .getSingleOrNull();
  }

  Future<int> addMember(MembersCompanion data) {
    return db.into(db.members).insert(data);
  }

  Future<bool> updateMember(MembersCompanion data) {
    // Requires `id` to be present.
    return db.update(db.members).replace(data);
  }

  Future<int> deleteMember(String id) {
    return (db.delete(db.members)..where((m) => m.id.equals(id))).go();
  }

  Future<String> generateNextMemberId() async {
    // Robust approach: read all ids, parse numeric suffix, and compute max.
    // This avoids lexicographical issues (e.g. DG99 > DG100 when ordered as strings).

    // Read only the `id` column for performance.
    final rows =
        await (db.selectOnly(db.members)..addColumns([db.members.id])).get();

    if (rows.isEmpty) return 'DG001';

    final regex = RegExp(r'^DG(\d+)$', caseSensitive: false);

    var maxValue = 0;
    for (final row in rows) {
      final id = row.read(db.members.id);
      if (id == null) continue;

      final match = regex.firstMatch(id.trim());
      if (match == null) continue;

      final value = int.tryParse(match.group(1) ?? '');
      if (value == null) continue;
      if (value > maxValue) maxValue = value;
    }    final next = maxValue + 1;
    final padded = next.toString().padLeft(3, '0');
    return 'DG$padded';
  }

  /// Count total members using SQL COUNT(*).
  Future<int> countMembers() async {
    final countExp = db.members.id.count();
    final query = db.selectOnly(db.members)..addColumns([countExp]);
    final row = await query.getSingle();
    return row.read(countExp) ?? 0;
  }
}
