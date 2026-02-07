import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/app_database.dart';

/// Provider for StaffRepository
final staffRepositoryProvider = Provider<StaffRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return StaffRepository(db);
});

/// Repository for managing staff accounts.
class StaffRepository {
  StaffRepository(this._db);
  final AppDatabase _db;

  // ============================================================
  // READ OPERATIONS
  // ============================================================

  /// Get all staff accounts.
  Future<List<StaffAccount>> getAllStaff() async {
    return (_db.select(_db.staffAccounts)
          ..orderBy([(s) => OrderingTerm.asc(s.lastName)]))
        .get();
  }

  /// Get staff by ID.
  Future<StaffAccount?> getStaffById(String id) async {
    return (_db.select(_db.staffAccounts)..where((s) => s.id.equals(id)))
        .getSingleOrNull();
  }

  /// Get staff by username.
  Future<StaffAccount?> getStaffByUsername(String username) async {
    return (_db.select(_db.staffAccounts)
          ..where((s) => s.username.equals(username)))
        .getSingleOrNull();
  }

  /// Check if username exists.
  Future<bool> isUsernameExists(String username, [String? excludeId]) async {
    final query = _db.select(_db.staffAccounts)
      ..where((s) => s.username.equals(username));

    if (excludeId != null) {
      query.where((s) => s.id.equals(excludeId).not());
    }

    final result = await query.getSingleOrNull();
    return result != null;
  }

  /// Authenticate staff login.
  Future<StaffAccount?> authenticate(String username, String password) async {
    return (_db.select(_db.staffAccounts)
          ..where(
              (s) => s.username.equals(username) & s.password.equals(password)))
        .getSingleOrNull();
  }

  // ============================================================
  // WRITE OPERATIONS
  // ============================================================

  /// Create a new staff account.
  /// Returns the staff ID if successful.
  Future<String?> createStaff({
    required String id,
    required String username,
    required String password,
    String? lastName,
    String? middleName,
    String? firstName,
    String? role,
  }) async {
    // Check username uniqueness
    if (await isUsernameExists(username)) {
      return null; // Username already exists
    }

    await _db.into(_db.staffAccounts).insert(
          StaffAccountsCompanion.insert(
            id: id,
            username: username,
            password: password,
            lastName: Value(lastName),
            middleName: Value(middleName),
            firstName: Value(firstName),
            role: Value(role),
          ),
        );
    return id;
  }

  /// Update staff account.
  Future<bool> updateStaff({
    required String id,
    String? lastName,
    String? middleName,
    String? firstName,
    String? role,
    String? username,
    String? password,
  }) async {
    // Check username uniqueness if changing
    if (username != null && await isUsernameExists(username, id)) {
      return false; // Username already taken
    }

    final updated = await (_db.update(_db.staffAccounts)
          ..where((s) => s.id.equals(id)))
        .write(
      StaffAccountsCompanion(
        lastName: lastName != null ? Value(lastName) : const Value.absent(),
        middleName:
            middleName != null ? Value(middleName) : const Value.absent(),
        firstName: firstName != null ? Value(firstName) : const Value.absent(),
        role: role != null ? Value(role) : const Value.absent(),
        username: username != null ? Value(username) : const Value.absent(),
        password: password != null ? Value(password) : const Value.absent(),
      ),
    );
    return updated > 0;
  }

  /// Change staff password.
  Future<bool> changePassword({
    required String id,
    required String oldPassword,
    required String newPassword,
  }) async {
    // Verify old password
    final staff = await getStaffById(id);
    if (staff == null || staff.password != oldPassword) {
      return false;
    }

    final updated = await (_db.update(_db.staffAccounts)
          ..where((s) => s.id.equals(id)))
        .write(StaffAccountsCompanion(password: Value(newPassword)));
    return updated > 0;
  }

  /// Delete staff account.
  Future<bool> deleteStaff(String id) async {
    final deleted = await (_db.delete(_db.staffAccounts)
          ..where((s) => s.id.equals(id)))
        .go();
    return deleted > 0;
  }

  /// Get total staff count.
  Future<int> getStaffCount() async {
    final query = _db.selectOnly(_db.staffAccounts)
      ..addColumns([_db.staffAccounts.id.count()]);
    final result = await query.getSingle();
    return result.read(_db.staffAccounts.id.count()) ?? 0;
  }

  /// Generate next staff ID.
  Future<String> generateNextId() async {
    final allStaff = await getAllStaff();
    if (allStaff.isEmpty) return 'NV001';

    // Find max numeric suffix
    int maxNum = 0;
    for (final staff in allStaff) {
      final match = RegExp(r'NV(\d+)').firstMatch(staff.id);
      if (match != null) {
        final num = int.tryParse(match.group(1)!) ?? 0;
        if (num > maxNum) maxNum = num;
      }
    }
    return 'NV${(maxNum + 1).toString().padLeft(3, '0')}';
  }
}
