import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/enums.dart';
import '../../../../data/db/app_database.dart';

/// DTO for displaying reservation info with related member & book details.
class ReservationWithDetails {
  const ReservationWithDetails({
    required this.reservation,
    required this.memberName,
    required this.memberId,
    required this.bookTitle,
  });

  final Reservation reservation;
  final String memberName;
  final String memberId;
  final String bookTitle;
}

class ReservationRepository {
  ReservationRepository(this.db);

  final AppDatabase db;

  /// Create a new reservation for a book.
  ///
  /// [bookId]: The book ID to reserve.
  /// [memberId]: The member ID who is reserving.
  /// Returns the reservation ID.
  Future<int> createReservation({
    required String bookId,
    required String memberId,
  }) async {
    // Check if member already has an active reservation for this book.
    final existing = await getActiveReservationByMemberAndBook(
      memberId: memberId,
      bookId: bookId,
    );
    if (existing != null) {
      throw StateError('Hội viên đã đặt trước sách này rồi.');
    }

    return db.into(db.reservations).insert(
          ReservationsCompanion.insert(
            bookId: bookId,
            memberId: memberId,
            status: drift.Value(ReservationStatus.active.code),
          ),
        );
  }

  /// Check if a book has any active reservations.
  ///
  /// Returns the first active reservation with member details, or null if none.
  Future<ReservationWithDetails?> getActiveReservationForBook(
      String bookId) async {
    final r = db.reservations;
    final m = db.members;
    final b = db.books;

    final query = db.select(r).join([
      drift.innerJoin(m, m.id.equalsExp(r.memberId)),
      drift.innerJoin(b, b.id.equalsExp(r.bookId)),
    ]);

    query.where(r.bookId.equals(bookId) &
        r.status.equals(ReservationStatus.active.code));
    query.orderBy([drift.OrderingTerm.asc(r.createdAt)]);
    query.limit(1);

    final row = await query.getSingleOrNull();
    if (row == null) return null;

    final reservation = row.readTable(r);
    final member = row.readTable(m);
    final book = row.readTable(b);

    return ReservationWithDetails(
      reservation: reservation,
      memberName: _formatMemberName(member),
      memberId: member.id,
      bookTitle: book.title ?? book.id,
    );
  }

  /// Get active reservation by member and book (to prevent duplicates).
  Future<Reservation?> getActiveReservationByMemberAndBook({
    required String memberId,
    required String bookId,
  }) async {
    return (db.select(db.reservations)
          ..where((r) =>
              r.memberId.equals(memberId) &
              r.bookId.equals(bookId) &
              r.status.equals(ReservationStatus.active.code)))
        .getSingleOrNull();
  }

  /// Get all active reservations.
  Future<List<ReservationWithDetails>> getActiveReservations() async {
    final r = db.reservations;
    final m = db.members;
    final b = db.books;

    final query = db.select(r).join([
      drift.innerJoin(m, m.id.equalsExp(r.memberId)),
      drift.innerJoin(b, b.id.equalsExp(r.bookId)),
    ]);

    query.where(r.status.equals(ReservationStatus.active.code));
    query.orderBy([drift.OrderingTerm.asc(r.createdAt)]);

    final rows = await query.get();

    return rows.map((row) {
      final reservation = row.readTable(r);
      final member = row.readTable(m);
      final book = row.readTable(b);

      return ReservationWithDetails(
        reservation: reservation,
        memberName: _formatMemberName(member),
        memberId: member.id,
        bookTitle: book.title ?? book.id,
      );
    }).toList();
  }

  /// Mark a reservation as fulfilled (when book is returned and held for them).
  Future<void> fulfillReservation(int reservationId) async {
    await (db.update(db.reservations)
          ..where((r) => r.id.equals(reservationId)))
        .write(ReservationsCompanion(
      status: drift.Value(ReservationStatus.fulfilled.code),
    ));
  }

  /// Cancel a reservation.
  Future<void> cancelReservation(int reservationId) async {
    await (db.update(db.reservations)
          ..where((r) => r.id.equals(reservationId)))
        .write(ReservationsCompanion(
      status: drift.Value(ReservationStatus.cancelled.code),
    ));
  }

  /// Count active reservations for a specific book.
  Future<int> countActiveReservationsForBook(String bookId) async {
    final countExp = db.reservations.id.count();
    final query = db.selectOnly(db.reservations)
      ..addColumns([countExp])
      ..where(db.reservations.bookId.equals(bookId) &
          db.reservations.status.equals(ReservationStatus.active.code));

    final row = await query.getSingle();
    return row.read(countExp) ?? 0;
  }

  String _formatMemberName(Member member) {
    final parts = <String>[];
    for (final p in [member.lastName, member.middleName, member.firstName]) {
      final v = (p ?? '').trim();
      if (v.isNotEmpty) parts.add(v);
    }
    return parts.isEmpty ? member.id : parts.join(' ');
  }
}

final reservationRepositoryProvider = Provider<ReservationRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return ReservationRepository(db);
});
