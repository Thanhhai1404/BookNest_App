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

/// Reservation status for book reservations (stored as text in DB).
enum ReservationStatus {
  active('Active'),
  fulfilled('Fulfilled'),
  cancelled('Cancelled');

  const ReservationStatus(this.value);
  final String value;

  static ReservationStatus fromValue(String value) {
    return ReservationStatus.values.firstWhere(
      (e) => e.value.toLowerCase() == value.toLowerCase(),
      orElse: () => ReservationStatus.active,
    );
  }
}

/// Transaction type for wallet transactions (stored as text in DB).
enum TransactionType {
  topUp('TopUp'), // Nạp tiền vào ví
  payment('Payment'), // Thanh toán (phí mượn, phí trễ, etc.)
  refund('Refund'), // Hoàn tiền
  finePayment('FinePayment'), // Thanh toán phạt
  reward('Reward'); // Điểm thưởng

  const TransactionType(this.value);
  final String value;

  static TransactionType fromValue(String value) {
    return TransactionType.values.firstWhere(
      (e) => e.value.toLowerCase() == value.toLowerCase(),
      orElse: () => TransactionType.payment,
    );
  }
}

/// Fine status for tracking fine payments (stored as text in DB).
enum FineStatus {
  pending('Pending'), // Chưa thanh toán
  paid('Paid'), // Đã thanh toán
  waived('Waived'); // Được miễn

  const FineStatus(this.value);
  final String value;

  static FineStatus fromValue(String value) {
    return FineStatus.values.firstWhere(
      (e) => e.value.toLowerCase() == value.toLowerCase(),
      orElse: () => FineStatus.pending,
    );
  }
}

/// Fine reason for categorizing fines.
enum FineReason {
  overdue('Overdue'), // Trả sách trễ
  damaged('Damaged'), // Sách bị hư hỏng
  lost('Lost'); // Mất sách

  const FineReason(this.value);
  final String value;

  static FineReason fromValue(String value) {
    return FineReason.values.firstWhere(
      (e) => e.value.toLowerCase() == value.toLowerCase(),
      orElse: () => FineReason.overdue,
    );
  }
}
