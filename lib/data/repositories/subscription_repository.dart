import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/app_database.dart';

/// Provider for SubscriptionRepository
final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return SubscriptionRepository(db);
});

/// Repository for managing subscription plans.
class SubscriptionRepository {
  SubscriptionRepository(this._db);
  final AppDatabase _db;

  // ============================================================
  // READ OPERATIONS
  // ============================================================

  /// Get all subscription plans.
  Future<List<Subscription>> getAllSubscriptions() async {
    return (_db.select(_db.subscriptions)
          ..orderBy([(s) => OrderingTerm.asc(s.monthlyFee)]))
        .get();
  }

  /// Get subscription by ID.
  Future<Subscription?> getSubscriptionById(String id) async {
    return (_db.select(_db.subscriptions)..where((s) => s.id.equals(id)))
        .getSingleOrNull();
  }

  /// Get subscription with member count.
  Future<List<SubscriptionWithMemberCount>> getAllWithMemberCount() async {
    final subscriptions = await getAllSubscriptions();
    final result = <SubscriptionWithMemberCount>[];

    for (final sub in subscriptions) {
      final count = await _getMemberCount(sub.id);
      result.add(SubscriptionWithMemberCount(
        subscription: sub,
        memberCount: count,
      ));
    }

    return result;
  }

  /// Get member count for a subscription.
  Future<int> _getMemberCount(String subscriptionId) async {
    final query = _db.selectOnly(_db.members)
      ..addColumns([_db.members.id.count()])
      ..where(_db.members.subscriptionId.equals(subscriptionId));

    final result = await query.getSingle();
    return result.read(_db.members.id.count()) ?? 0;
  }

  // ============================================================
  // WRITE OPERATIONS
  // ============================================================

  /// Create a new subscription plan.
  Future<void> createSubscription({
    required String id,
    required String name,
    int? monthlyFee,
    int? deposit,
    int? maxBooks,
    int? maxDays,
    String? description,
    bool allowReservation = true,
    bool allowRenewal = true,
  }) async {
    await _db.into(_db.subscriptions).insert(
          SubscriptionsCompanion.insert(
            id: id,
            name: Value(name),
            monthlyFee: Value(monthlyFee),
            deposit: Value(deposit),
            maxBooks: Value(maxBooks),
            maxDays: Value(maxDays),
            description: Value(description),
            allowReservation: Value(allowReservation),
            allowRenewal: Value(allowRenewal),
          ),
        );
  }

  /// Update subscription plan.
  Future<bool> updateSubscription({
    required String id,
    String? name,
    int? monthlyFee,
    int? deposit,
    int? maxBooks,
    int? maxDays,
    String? description,
    bool? allowReservation,
    bool? allowRenewal,
  }) async {
    final updated = await (_db.update(_db.subscriptions)
          ..where((s) => s.id.equals(id)))
        .write(
      SubscriptionsCompanion(
        name: name != null ? Value(name) : const Value.absent(),
        monthlyFee:
            monthlyFee != null ? Value(monthlyFee) : const Value.absent(),
        deposit: deposit != null ? Value(deposit) : const Value.absent(),
        maxBooks: maxBooks != null ? Value(maxBooks) : const Value.absent(),
        maxDays: maxDays != null ? Value(maxDays) : const Value.absent(),
        description:
            description != null ? Value(description) : const Value.absent(),
        allowReservation: allowReservation != null
            ? Value(allowReservation)
            : const Value.absent(),
        allowRenewal:
            allowRenewal != null ? Value(allowRenewal) : const Value.absent(),
      ),
    );
    return updated > 0;
  }

  /// Delete subscription plan (only if no members are using it).
  Future<bool> deleteSubscription(String id) async {
    // Check if any members are using this subscription
    final memberCount = await _getMemberCount(id);
    if (memberCount > 0) {
      return false; // Cannot delete - members are using it
    }

    final deleted = await (_db.delete(_db.subscriptions)
          ..where((s) => s.id.equals(id)))
        .go();
    return deleted > 0;
  }
}

/// DTO for subscription with member count.
class SubscriptionWithMemberCount {
  const SubscriptionWithMemberCount({
    required this.subscription,
    required this.memberCount,
  });

  final Subscription subscription;
  final int memberCount;
}
