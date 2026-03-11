import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ============================================================================
// User Portal Wallet Repository
// Handles wallet balance, top-up, and transaction history
// ============================================================================

/// Giao dịch ví
class WalletTransaction {
  final int id;
  final String type; // NAP_TIEN, TRU_PHI_GOI, TRU_TIEN_PHAT, MUA_SACH, HOAN_TIEN
  final int amount;
  final DateTime transactionDate;
  final String? description;

  const WalletTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.transactionDate,
    this.description,
  });

  bool get isDebit => amount < 0;

  String get typeLabel {
    switch (type) {
      case 'NAP_TIEN':
        return 'Nạp tiền';
      case 'TRU_PHI_GOI':
        return 'Phí gói';
      case 'TRU_TIEN_PHAT':
        return 'Tiền phạt';
      case 'MUA_SACH':
        return 'Mua sách';
      case 'HOAN_TIEN':
        return 'Hoàn tiền';
      default:
        return type;
    }
  }
  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    int parseNum(dynamic v) => (v is num) ? v.toInt() : int.tryParse(v.toString()) ?? 0;

    return WalletTransaction(
      id: parseNum(json['magd']),
      type: json['loaigiaodich'] as String? ?? '',
      amount: parseNum(json['sotien']),
      transactionDate:
          DateTime.tryParse(json['ngaygiaodich']?.toString() ?? '') ?? DateTime.now(),
      description: json['noidung'] as String?,
    );
  }
}

/// Repository
class UserWalletRepository {
  final SupabaseClient _client;

  UserWalletRepository(this._client);

  /// Lấy số dư ví
  Future<int> getBalance(String memberId) async {
    final data = await _client
        .from('doc_gia')
        .select('soduvi')
        .eq('madg', memberId)
        .single();
    return (data['soduvi'] as num?)?.toInt() ?? 0;
  }

  /// Lấy lịch sử giao dịch
  Future<List<WalletTransaction>> getTransactions(String memberId) async {
    final data = await _client
        .from('giao_dich_vi')
        .select()
        .eq('madg', memberId)
        .order('ngaygiaodich', ascending: false);

    return data.map((e) => WalletTransaction.fromJson(e)).toList();
  }

  /// Nạp tiền vào ví
  Future<void> topUp(String memberId, int amount) async {
    // 1. Insert giao dịch
    await _client.from('giao_dich_vi').insert({
      'madg': memberId,
      'loaigiaodich': 'NAP_TIEN',
      'sotien': amount,
      'ngaygiaodich': DateTime.now().toIso8601String(),
      'noidung': 'Nạp tiền vào ví',
    });

    // 2. Cập nhật số dư
    final current = await getBalance(memberId);
    await _client
        .from('doc_gia')
        .update({'soduvi': current + amount})
        .eq('madg', memberId);
  }

  /// Trừ tiền ví (mua sách, phạt, phí gói...)
  Future<bool> deduct(String memberId, int amount, String type, String description) async {
    final balance = await getBalance(memberId);
    if (balance < amount) return false;

    await _client.from('giao_dich_vi').insert({
      'madg': memberId,
      'loaigiaodich': type,
      'sotien': -amount,
      'ngaygiaodich': DateTime.now().toIso8601String(),
      'noidung': description,
    });

    await _client
        .from('doc_gia')
        .update({'soduvi': balance - amount})
        .eq('madg', memberId);

    return true;
  }
}

// ======================== Providers ========================

final userWalletRepositoryProvider = Provider<UserWalletRepository>((ref) {
  return UserWalletRepository(Supabase.instance.client);
});

final walletBalanceProvider = FutureProvider.family<int, String>(
  (ref, memberId) {
    return ref.read(userWalletRepositoryProvider).getBalance(memberId);
  },
);

final walletTransactionsProvider =
    FutureProvider.family<List<WalletTransaction>, String>(
  (ref, memberId) {
    return ref.read(userWalletRepositoryProvider).getTransactions(memberId);
  },
);
