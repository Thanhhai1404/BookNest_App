import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/subscription_repository.dart';

/// State for subscription list
class SubscriptionListState {
  const SubscriptionListState({
    required this.subscriptions,
    this.isProcessing = false,
  });

  final List<SubscriptionWithMemberCount> subscriptions;
  final bool isProcessing;

  SubscriptionListState copyWith({
    List<SubscriptionWithMemberCount>? subscriptions,
    bool? isProcessing,
  }) {
    return SubscriptionListState(
      subscriptions: subscriptions ?? this.subscriptions,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }
}

/// ViewModel for managing subscriptions
class SubscriptionViewModel extends AsyncNotifier<SubscriptionListState> {
  late SubscriptionRepository _repo;

  @override
  Future<SubscriptionListState> build() async {
    _repo = ref.watch(subscriptionRepositoryProvider);
    return _loadSubscriptions();
  }

  Future<SubscriptionListState> _loadSubscriptions() async {
    final subscriptions = await _repo.getAllWithMemberCount();
    return SubscriptionListState(subscriptions: subscriptions);
  }

  /// Refresh the subscription list
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _loadSubscriptions());
  }

  /// Update subscription plan
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
    final currentState = state.valueOrNull;
    if (currentState == null || currentState.isProcessing) return false;

    state = AsyncData(currentState.copyWith(isProcessing: true));

    try {
      final success = await _repo.updateSubscription(
        id: id,
        name: name,
        monthlyFee: monthlyFee,
        deposit: deposit,
        maxBooks: maxBooks,
        maxDays: maxDays,
        description: description,
        allowReservation: allowReservation,
        allowRenewal: allowRenewal,
      );

      if (success) {
        await refresh();
      } else {
        state = AsyncData(currentState.copyWith(isProcessing: false));
      }
      return success;
    } catch (e) {
      state = AsyncData(currentState.copyWith(isProcessing: false));
      return false;
    }
  }

  /// Create new subscription plan
  Future<bool> createSubscription({
    required String id,
    required String name,
    int? monthlyFee,
    int? deposit,
    int? maxBooks,
    int? maxDays,
    String? description,
  }) async {
    final currentState = state.valueOrNull;
    if (currentState == null || currentState.isProcessing) return false;

    state = AsyncData(currentState.copyWith(isProcessing: true));

    try {
      await _repo.createSubscription(
        id: id,
        name: name,
        monthlyFee: monthlyFee,
        deposit: deposit,
        maxBooks: maxBooks,
        maxDays: maxDays,
        description: description,
      );
      await refresh();
      return true;
    } catch (e) {
      state = AsyncData(currentState.copyWith(isProcessing: false));
      return false;
    }
  }

  /// Delete subscription plan
  Future<bool> deleteSubscription(String id) async {
    final currentState = state.valueOrNull;
    if (currentState == null || currentState.isProcessing) return false;

    state = AsyncData(currentState.copyWith(isProcessing: true));

    try {
      final success = await _repo.deleteSubscription(id);
      if (success) {
        await refresh();
      } else {
        state = AsyncData(currentState.copyWith(isProcessing: false));
      }
      return success;
    } catch (e) {
      state = AsyncData(currentState.copyWith(isProcessing: false));
      return false;
    }
  }
}

/// Provider for SubscriptionViewModel
final subscriptionViewModelProvider =
    AsyncNotifierProvider<SubscriptionViewModel, SubscriptionListState>(
  SubscriptionViewModel.new,
);
