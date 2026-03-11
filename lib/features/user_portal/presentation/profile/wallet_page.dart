import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../core/user_auth_provider.dart';
import '../../data/user_wallet_repository.dart';

/// Quản lý ví - Nạp tiền, lịch sử giao dịch
class WalletPage extends ConsumerWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final member = ref.watch(currentMemberProvider);
    if (member == null) {
      return const Scaffold(
        body: Center(child: Text('Vui lòng đăng nhập')),
      );
    }

    final balanceAsync = ref.watch(walletBalanceProvider(member.id));
    final txAsync = ref.watch(walletTransactionsProvider(member.id));

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Ví BookNest'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(walletBalanceProvider(member.id));
          ref.invalidate(walletTransactionsProvider(member.id));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ==================== BALANCE CARD ====================
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryColor, Color(0xFFCC0B0B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withAlpha(60),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.account_balance_wallet,
                            color: Colors.white.withAlpha(200), size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Số dư hiện tại',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white.withAlpha(200),
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    balanceAsync.when(
                      data: (balance) => Text(
                        '${_formatPrice(balance)}đ',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      loading: () => const SizedBox(
                        height: 36,
                        width: 100,
                        child: LinearProgressIndicator(color: Colors.white54),
                      ),
                      error: (e, _) => Text(
                        'Lỗi tải số dư',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.white70,
                            ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: _WalletAction(
                            icon: Icons.add_circle_outline,
                            label: 'Nạp tiền',
                            onTap: () => _showTopUpDialog(context, ref, member.id),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _WalletAction(
                            icon: Icons.history,
                            label: 'Lịch sử',
                            onTap: () {},
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ==================== NẠP NHANH ====================
              Text('Nạp nhanh',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                children: [
                  _QuickAmount(
                    amount: '50.000',
                    onTap: () => _doTopUp(context, ref, member.id, 50000),
                  ),
                  const SizedBox(width: 8),
                  _QuickAmount(
                    amount: '100.000',
                    onTap: () => _doTopUp(context, ref, member.id, 100000),
                  ),
                  const SizedBox(width: 8),
                  _QuickAmount(
                    amount: '200.000',
                    onTap: () => _doTopUp(context, ref, member.id, 200000),
                  ),
                  const SizedBox(width: 8),
                  _QuickAmount(
                    amount: '500.000',
                    onTap: () => _doTopUp(context, ref, member.id, 500000),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ==================== LỊCH SỬ GIAO DỊCH ====================
              Text('Giao dịch gần đây',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              txAsync.when(
                data: (transactions) {
                  if (transactions.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.receipt_long_outlined,
                                size: 48, color: AppTheme.textSecondary.withAlpha(100)),
                            const SizedBox(height: 12),
                            Text('Chưa có giao dịch',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: AppTheme.textSecondary)),
                          ],
                        ),
                      ),
                    );
                  }
                  return Column(
                    children: transactions.map((tx) {
                      final isDebit = tx.isDebit;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.cardLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.slate200.withAlpha(120)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: (isDebit
                                        ? AppTheme.errorColor
                                        : AppTheme.successColor)
                                    .withAlpha(15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                isDebit ? Icons.arrow_upward : Icons.arrow_downward,
                                size: 18,
                                color: isDebit
                                    ? AppTheme.errorColor
                                    : AppTheme.successColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tx.description ?? tx.typeLabel,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    '${tx.transactionDate.day}/${tx.transactionDate.month}/${tx.transactionDate.year}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(color: AppTheme.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${isDebit ? '' : '+'}${_formatPrice(tx.amount)}đ',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isDebit
                                        ? AppTheme.errorColor
                                        : AppTheme.successColor,
                                  ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Text('Lỗi tải giao dịch: $e',
                        style: const TextStyle(color: AppTheme.errorColor)),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _doTopUp(
      BuildContext context, WidgetRef ref, String memberId, int amount) async {
    try {
      await ref.read(userWalletRepositoryProvider).topUp(memberId, amount);
      ref.invalidate(walletBalanceProvider(memberId));
      ref.invalidate(walletTransactionsProvider(memberId));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Nạp ${_formatPrice(amount)}đ thành công!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi nạp tiền: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _showTopUpDialog(BuildContext context, WidgetRef ref, String memberId) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nạp tiền vào ví'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(
            labelText: 'Số tiền (đ)',
            hintText: '100000',
            prefixIcon: Icon(Icons.payments_outlined),
          ),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () {
              final amount = int.tryParse(ctrl.text.replaceAll('.', ''));
              if (amount == null || amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Vui lòng nhập số tiền hợp lệ'),
                    backgroundColor: AppTheme.warningColor,
                  ),
                );
                return;
              }
              Navigator.pop(ctx);
              _doTopUp(context, ref, memberId, amount);
            },
            child: const Text('Nạp'),
          ),
        ],
      ),
    );
  }

  static String _formatPrice(int price) {
    final abs = price.abs();
    final str = abs.toString();
    final buffer = StringBuffer();
    if (price < 0) buffer.write('-');
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
    }
    return buffer.toString();
  }
}

class _WalletAction extends StatelessWidget {
  const _WalletAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(30),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: Colors.white),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                )),
          ],
        ),
      ),
    );
  }
}

class _QuickAmount extends StatelessWidget {
  const _QuickAmount({required this.amount, required this.onTap});
  final String amount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.primaryColor.withAlpha(50)),
            borderRadius: BorderRadius.circular(10),
            color: AppTheme.primaryColor.withAlpha(8),
          ),
          child: Center(
            child: Text(
              '$amountđ',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
