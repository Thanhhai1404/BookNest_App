// Central enums used across the app.
//
// IMPORTANT: Numeric values are mapped to the original SQL (QLTV - V2.sql)
// so we can keep backward-compatible meaning for stored integers.

enum BookStatus {
  available(0),
  borrowed(1),
  damaged(2),
  lost(3);

  const BookStatus(this.code);
  final int code;

  static BookStatus fromCode(int code) {
    return BookStatus.values.firstWhere(
      (e) => e.code == code,
      orElse: () => BookStatus.available,
    );
  }
}

enum MemberStatus {
  /// SQL Bit (DOC_GIA.TrangThai): 1 = active
  active(1),

  /// SQL Bit: 0 = locked
  locked(0);

  const MemberStatus(this.code);
  final int code;

  static MemberStatus fromCode(int code) {
    return code == 1 ? MemberStatus.active : MemberStatus.locked;
  }
}

/// Loan status is not stored in the original PHIEU_MUON header as a field.
/// In BookNest, we keep a derived status for UI/reporting.
/// Suggested integer mapping for persistence if needed.
enum LoanStatus {
  active(0),
  overdue(1),
  returned(2);

  const LoanStatus(this.code);
  final int code;

  static LoanStatus fromCode(int code) {
    return LoanStatus.values.firstWhere(
      (e) => e.code == code,
      orElse: () => LoanStatus.active,
    );
  }
}

enum Role {
  admin,
  staff;

  static Role fromUsernameOrTitle({required String username, String? title}) {
    if (username.toLowerCase() == 'admin') return Role.admin;
    if (title != null && title.toLowerCase().contains('admin')) {
      return Role.admin;
    }
    return Role.staff;
  }
}

/// Reservation status for book reservations.
enum ReservationStatus {
  active(0),
  fulfilled(1),
  cancelled(2);

  const ReservationStatus(this.code);
  final int code;

  static ReservationStatus fromCode(int code) {
    return ReservationStatus.values.firstWhere(
      (e) => e.code == code,
      orElse: () => ReservationStatus.active,
    );
  }
}
