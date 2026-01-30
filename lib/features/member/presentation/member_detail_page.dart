import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/constants/enums.dart';
import '../../../data/db/app_database.dart';
import '../../../data/repositories/finance_repository.dart';
import '../../loan/data/repositories/loan_repository.dart';
import '../../loan/presentation/loan_view_model.dart';
import 'member_form_page.dart';
import 'member_view_model.dart';

/// Currency formatter for VND
final _currencyFormat = NumberFormat('#,###', 'vi_VN');

/// Provider for member detail - auto-refreshes when member data changes
final memberDetailProvider =
    FutureProvider.family.autoDispose<Member?, String>((ref, memberId) {
  return ref.watch(memberRepositoryProvider).getMemberById(memberId);
});

/// Provider for member's transaction history
final memberTransactionsProvider =
    FutureProvider.family.autoDispose<List<Transaction>, String>(
        (ref, memberId) {
  return ref.watch(financeRepositoryProvider).getTransactionsByMember(memberId);
});

class MemberDetailPage extends ConsumerWidget {
  const MemberDetailPage({super.key, required this.memberId});

  final String memberId;

  String _fullName(Member m) {
    final parts = <String>[];
    for (final p in [m.lastName, m.middleName, m.firstName]) {
      final v = (p ?? '').trim();
      if (v.isNotEmpty) parts.add(v);
    }
    return parts.isEmpty ? m.id : parts.join(' ');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memberAsync = ref.watch(memberDetailProvider(memberId));

    return memberAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Hội viên')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Hội viên')),
        body: Center(child: Text('Lỗi: $e')),
      ),
      data: (member) {
        if (member == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Hội viên')),
            body: const Center(child: Text('Không tìm thấy hội viên.')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(_fullName(member)),
            actions: [
              IconButton(
                tooltip: 'Sửa',
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => MemberFormPage(existing: member),
                    ),
                  );
                  // Refresh data after edit
                  ref.invalidate(memberDetailProvider(memberId));
                },
                icon: const Icon(Icons.edit),
              ),
              IconButton(
                tooltip: 'Xoá',
                onPressed: () => _showDeleteDialog(context, ref, member),
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // --- Member Info Card ---
              _MemberInfoCard(member: member, fullName: _fullName(member)),
              const SizedBox(height: 16),

              // --- Wallet & Points Card ---
              _WalletPointsCard(
                member: member,
                onTopUp: () => _showTopUpDialog(context, ref, member),
              ),
              const SizedBox(height: 16),

              // --- Loan History Card ---
              _LoanHistoryCard(memberId: memberId),
              const SizedBox(height: 16),

              // --- Transaction History Card ---
              _TransactionHistoryCard(memberId: memberId),
              const SizedBox(height: 16),

              // --- Other Info Card ---
              _OtherInfoCard(member: member),
              const SizedBox(height: 16),

              // --- QR Code Button ---
              FilledButton.icon(
                onPressed: () => _showMemberCardDialog(context, member),
                icon: const Icon(Icons.qr_code_2),
                label: const Text('Xem thẻ thành viên'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showDeleteDialog(
      BuildContext context, WidgetRef ref, Member member) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xoá hội viên?'),
        content: Text('Bạn chắc chắn muốn xoá ${_fullName(member)}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Huỷ'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Xoá'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    await ref.read(memberListControllerProvider.notifier).delete(member.id);
    if (context.mounted) Navigator.of(context).pop();
  }

  Future<void> _showTopUpDialog(
      BuildContext context, WidgetRef ref, Member member) async {
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => _TopUpDialog(member: member),
    );    if (result != null && result > 0) {
      try {
        await ref.read(memberRepositoryProvider).topUpWallet(member.id, result);
        // Refresh data
        ref.invalidate(memberDetailProvider(memberId));
        ref.invalidate(memberTransactionsProvider(memberId));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Đã nạp ${_currencyFormat.format(result)} VND vào ví thành công!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  void _showMemberCardDialog(BuildContext context, Member member) {
    showDialog(
      context: context,
      builder: (ctx) => _MemberCardDialog(
        member: member,
        fullName: _fullName(member),
      ),
    );
  }
}

/// Member Info Card with avatar and basic info
class _MemberInfoCard extends StatelessWidget {
  const _MemberInfoCard({required this.member, required this.fullName});

  final Member member;
  final String fullName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundImage: (member.avatarPath ?? '').trim().isEmpty
                  ? null
                  : FileImage(File(member.avatarPath!)),
              child: (member.avatarPath ?? '').trim().isEmpty
                  ? Text(
                      fullName.isNotEmpty ? fullName[0].toUpperCase() : '?',
                      style: theme.textTheme.headlineMedium,
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fullName,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _InfoRow(icon: Icons.badge_outlined, text: member.id),
                  _InfoRow(
                    icon: Icons.phone_outlined,
                    text: member.phone ?? '-',
                  ),
                  _InfoRow(
                    icon: Icons.email_outlined,
                    text: member.email,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Wallet & Points Card with top-up button
class _WalletPointsCard extends StatelessWidget {
  const _WalletPointsCard({required this.member, required this.onTopUp});

  final Member member;
  final VoidCallback onTopUp;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final walletBalance = member.walletBalance;
    final points = member.points;

    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                // Wallet section
                Expanded(
                  child: Column(
                    children: [
                      Icon(
                        Icons.account_balance_wallet,
                        size: 32,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Số dư ví',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_currencyFormat.format(walletBalance)} VND',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Divider
                Container(
                  width: 1,
                  height: 60,
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                ),
                // Points section
                Expanded(
                  child: Column(
                    children: [
                      Icon(
                        Icons.emoji_events,
                        size: 32,
                        color: Colors.amber[700],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Điểm tích luỹ',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _currencyFormat.format(points),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onTopUp,
                icon: const Icon(Icons.add_card),
                label: const Text('Nạp tiền vào ví'),
              ),            ),
          ],
        ),
      ),
    );
  }
}

/// Transaction History Card
class _TransactionHistoryCard extends ConsumerWidget {
  const _TransactionHistoryCard({required this.memberId});

  final String memberId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final transactionsAsync = ref.watch(memberTransactionsProvider(memberId));
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(Icons.history, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Lịch sử Giao dịch',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Content
          transactionsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Lỗi: $e'),
            ),
            data: (transactions) {
              if (transactions.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 48,
                          color: theme.colorScheme.outline,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Chưa có giao dịch nào',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Show only last 5 transactions
              final displayList = transactions.take(5).toList();

              return Column(
                children: [
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: displayList.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final tx = displayList[index];
                      return _TransactionTile(
                        transaction: tx,
                        dateFormat: dateFormat,
                      );
                    },
                  ),
                  if (transactions.length > 5) ...[
                    const Divider(height: 1),
                    TextButton(
                      onPressed: () => _showAllTransactions(
                        context,
                        transactions,
                        dateFormat,
                      ),
                      child: Text('Xem tất cả (${transactions.length})'),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  void _showAllTransactions(
    BuildContext context,
    List<Transaction> transactions,
    DateFormat dateFormat,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.history),
                  const SizedBox(width: 8),
                  Text(
                    'Tất cả Giao dịch (${transactions.length})',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // List
            Expanded(
              child: ListView.separated(
                controller: scrollController,
                itemCount: transactions.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final tx = transactions[index];
                  return _TransactionTile(
                    transaction: tx,
                    dateFormat: dateFormat,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Single transaction tile
class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    required this.transaction,
    required this.dateFormat,
  });

  final Transaction transaction;
  final DateFormat dateFormat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Determine icon and color based on transaction type
    final txType = TransactionType.fromValue(transaction.type);
    final isCredit =
        txType == TransactionType.topUp || txType == TransactionType.refund;

    final IconData icon;
    final Color iconColor;
    final Color amountColor;

    switch (txType) {
      case TransactionType.topUp:
        icon = Icons.arrow_upward;
        iconColor = Colors.green;
        amountColor = Colors.green;
        break;
      case TransactionType.refund:
        icon = Icons.replay;
        iconColor = Colors.blue;
        amountColor = Colors.blue;
        break;
      case TransactionType.payment:
      case TransactionType.finePayment:
        icon = Icons.arrow_downward;
        iconColor = Colors.red;
        amountColor = Colors.red;
        break;
    }

    final amountText = isCredit
        ? '+${_currencyFormat.format(transaction.amount)}'
        : _currencyFormat.format(transaction.amount);

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withAlpha(25),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        transaction.description ?? _getDefaultDescription(txType),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        dateFormat.format(transaction.createdAt),
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.outline,
        ),
      ),
      trailing: Text(
        '$amountText VND',
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: amountColor,
        ),
      ),
    );
  }

  String _getDefaultDescription(TransactionType type) {
    switch (type) {
      case TransactionType.topUp:
        return 'Nạp tiền';
      case TransactionType.payment:
        return 'Thanh toán';
      case TransactionType.refund:
        return 'Hoàn tiền';
      case TransactionType.finePayment:
        return 'Thanh toán phạt';
    }
  }
}

/// Other info card (subscription, address)
class _OtherInfoCard extends StatelessWidget {
  const _OtherInfoCard({required this.member});

  final Member member;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.card_membership),
            title: const Text('Gói hội viên'),
            subtitle: Text(member.subscriptionId),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.location_on_outlined),
            title: const Text('Địa chỉ'),
            subtitle: Text(member.address ?? '-'),
          ),
        ],
      ),
    );
  }
}

/// Top-up Dialog
class _TopUpDialog extends StatefulWidget {
  const _TopUpDialog({required this.member});

  final Member member;

  @override
  State<_TopUpDialog> createState() => _TopUpDialogState();
}

class _TopUpDialogState extends State<_TopUpDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _quickAmounts = [50000, 100000, 200000, 500000, 1000000];
  int? _selectedQuickAmount;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _selectQuickAmount(int amount) {
    setState(() {
      _selectedQuickAmount = amount;
      _amountController.text = amount.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentBalance = widget.member.walletBalance;

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.add_card, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          const Text('Nạp tiền'),
        ],
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current balance
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.account_balance_wallet, size: 20),
                    const SizedBox(width: 8),
                    Text('Số dư hiện tại: '),
                    Text(
                      '${_currencyFormat.format(currentBalance)} VND',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Quick amount buttons
              Text(
                'Chọn nhanh:',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _quickAmounts.map((amount) {
                  final isSelected = _selectedQuickAmount == amount;
                  return ChoiceChip(
                    label: Text('${_currencyFormat.format(amount)}đ'),
                    selected: isSelected,
                    onSelected: (_) => _selectQuickAmount(amount),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Custom amount input
              Text(
                'Hoặc nhập số tiền:',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  hintText: 'Nhập số tiền (VND)',
                  suffixText: 'VND',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập số tiền';
                  }
                  final amount = int.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Số tiền phải lớn hơn 0';
                  }
                  if (amount < 1000) {
                    return 'Số tiền tối thiểu là 1,000 VND';
                  }
                  if (amount > 10000000) {
                    return 'Số tiền tối đa là 10,000,000 VND';
                  }
                  return null;
                },
                onChanged: (_) {
                  // Clear quick selection when user types
                  if (_selectedQuickAmount != null) {
                    setState(() => _selectedQuickAmount = null);
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Huỷ'),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final amount = int.parse(_amountController.text);
              Navigator.pop(context, amount);
            }
          },
          child: const Text('Nạp tiền'),
        ),
      ],
    );
  }
}

/// Member Card Dialog with QR code
class _MemberCardDialog extends StatelessWidget {
  const _MemberCardDialog({required this.member, required this.fullName});

  final Member member;
  final String fullName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 320),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Text(
              'THẺ HỘI VIÊN',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'BOOKNEST LIBRARY',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),

            // QR Code
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: QrImageView(
                data: member.id,
                version: QrVersions.auto,
                size: 180,
                backgroundColor: Colors.white,
                errorCorrectionLevel: QrErrorCorrectLevel.M,
              ),
            ),
            const SizedBox(height: 16),

            // Member ID
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                member.id,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Member name
            Text(
              fullName,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              member.email,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            // Close button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Đóng'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Loan History Card - Shows member's book borrowing history
class _LoanHistoryCard extends ConsumerWidget {
  const _LoanHistoryCard({required this.memberId});

  final String memberId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final loansAsync = ref.watch(memberLoanHistoryProvider(memberId));
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(Icons.menu_book, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Lịch sử Mượn sách',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Content
          loansAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Lỗi: $e'),
            ),
            data: (loans) {
              if (loans.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.library_books_outlined,
                          size: 48,
                          color: theme.colorScheme.outline,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Chưa có lịch sử mượn sách',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Show only last 5 loans
              final displayList = loans.take(5).toList();

              return Column(
                children: [
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: displayList.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final loan = displayList[index];
                      return _LoanHistoryTile(
                        loan: loan,
                        dateFormat: dateFormat,
                      );
                    },
                  ),
                  if (loans.length > 5) ...[
                    const Divider(height: 1),
                    TextButton(
                      onPressed: () => _showAllLoans(context, loans, dateFormat),
                      child: Text('Xem tất cả (${loans.length})'),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  void _showAllLoans(
    BuildContext context,
    List<LoanWithDetails> loans,
    DateFormat dateFormat,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.menu_book),
                  const SizedBox(width: 8),
                  Text(
                    'Lịch sử Mượn sách (${loans.length})',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Statistics row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _StatChip(
                    label: 'Tổng',
                    value: loans.length.toString(),
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  _StatChip(
                    label: 'Đang mượn',
                    value: loans
                        .where((l) => l.loan.returnDate == null)
                        .length
                        .toString(),
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  _StatChip(
                    label: 'Đã trả',
                    value: loans
                        .where((l) => l.loan.returnDate != null)
                        .length
                        .toString(),
                    color: Colors.green,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // List
            Expanded(
              child: ListView.separated(
                controller: scrollController,
                itemCount: loans.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final loan = loans[index];
                  return _LoanHistoryTile(
                    loan: loan,
                    dateFormat: dateFormat,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Stat chip for loan history modal
class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tile for loan history item
class _LoanHistoryTile extends StatelessWidget {
  const _LoanHistoryTile({
    required this.loan,
    required this.dateFormat,
  });

  final LoanWithDetails loan;
  final DateFormat dateFormat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isReturned = loan.loan.returnDate != null;
    final isOverdue = loan.isOverdue;

    // Determine status
    String statusText;
    Color statusColor;
    IconData statusIcon;

    if (isReturned) {
      statusText = 'Đã trả';
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else if (isOverdue) {
      statusText = 'Quá hạn';
      statusColor = Colors.red;
      statusIcon = Icons.warning;
    } else {
      statusText = 'Đang mượn';
      statusColor = Colors.orange;
      statusIcon = Icons.schedule;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Leading icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(statusIcon, color: statusColor, size: 20),
          ),
          const SizedBox(width: 12),
          // Content - use Expanded to prevent overflow
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Book title
                Text(
                  loan.bookTitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Copy ID and Loan ID
                Text(
                  'Mã: ${loan.copyId} • Phiếu #${loan.loan.id}',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 2),
                // Dates - wrap to prevent overflow
                Wrap(
                  spacing: 4,
                  runSpacing: 2,
                  children: [
                    Text(
                      'Mượn: ${dateFormat.format(loan.loan.borrowDate)}',
                      style: theme.textTheme.bodySmall,
                    ),
                    if (isReturned) ...[
                      Text('→', style: theme.textTheme.bodySmall),
                      Text(
                        'Trả: ${dateFormat.format(loan.loan.returnDate!)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.green,
                        ),
                      ),
                    ] else ...[
                      Text('•', style: theme.textTheme.bodySmall),
                      Text(
                        'Hạn: ${dateFormat.format(loan.loan.dueDate)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isOverdue ? Colors.red : null,
                          fontWeight: isOverdue ? FontWeight.bold : null,
                        ),
                      ),
                    ],
                  ],
                ),
                // Show overdue days if applicable
                if (isOverdue && !isReturned) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Trễ ${loan.overdueDays} ngày',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
