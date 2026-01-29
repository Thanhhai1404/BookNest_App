import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../data/db/app_database.dart';
import 'member_form_page.dart';
import 'member_view_model.dart';

/// Currency formatter for VND
final _currencyFormat = NumberFormat('#,###', 'vi_VN');

/// Provider for member detail - auto-refreshes when member data changes
final memberDetailProvider =
    FutureProvider.family.autoDispose<Member?, String>((ref, memberId) {
  return ref.watch(memberRepositoryProvider).getMemberById(memberId);
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
          ),
          body: ListView(
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
    );

    if (result != null && result > 0) {
      try {
        await ref.read(memberRepositoryProvider).topUpWallet(member.id, result);
        // Refresh data
        ref.invalidate(memberDetailProvider(memberId));
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
              ),
            ),
          ],
        ),
      ),
    );
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
