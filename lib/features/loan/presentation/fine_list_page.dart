import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../data/repositories/finance_repository.dart';
import 'fine_view_model.dart';

final _currencyFormat = NumberFormat('#,###', 'vi_VN');
final _dateFormat = DateFormat('dd/MM/yyyy');

class FineListPage extends ConsumerWidget {
  const FineListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(fineViewModelProvider);
    return stateAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Quan ly Thu phat')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, st) => Scaffold(
        appBar: AppBar(title: const Text('Quan ly Thu phat')),
        body: Center(child: Text('Loi: $e')),
      ),
      data: (state) => _FineListContent(state: state),
    );
  }
}

class _FineListContent extends ConsumerWidget {
  const _FineListContent({required this.state});
  final FineListState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quan ly Thu phat'),
          actions: [
            IconButton(
              tooltip: 'Tai lai',
              onPressed: state.isProcessing ? null : () => ref.read(fineViewModelProvider.notifier).refresh(),
              icon: const Icon(Icons.refresh),
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.pending_actions, size: 18),
                const SizedBox(width: 6),
                const Text('Chua TT'),
                if (state.pendingFines.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: scheme.error, borderRadius: BorderRadius.circular(10)),
                    child: Text('${state.pendingFines.length}', style: TextStyle(color: scheme.onError, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ])),
              Tab(child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.history, size: 18),
                const SizedBox(width: 6),
                const Text('Lich su'),
                if (state.paidFines.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: scheme.primaryContainer, borderRadius: BorderRadius.circular(10)),
                    child: Text('${state.paidFines.length}', style: TextStyle(color: scheme.onPrimaryContainer, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ])),
            ],
          ),
        ),
        body: TabBarView(children: [_PendingFinesTab(state: state), _PaidFinesTab(state: state)]),
      ),
    );
  }
}

class _PendingFinesTab extends ConsumerWidget {
  const _PendingFinesTab({required this.state});
  final FineListState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final pendingFines = state.pendingFines;
    return Column(children: [
      if (pendingFines.isNotEmpty)
        Container(
          width: double.infinity, padding: const EdgeInsets.all(16), color: scheme.errorContainer,
          child: Row(children: [
            Icon(Icons.receipt_long, color: scheme.onErrorContainer),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${pendingFines.length} khoan phat chua thanh toan', style: TextStyle(color: scheme.onErrorContainer, fontWeight: FontWeight.w600)),
              Text('Tong: ${_currencyFormat.format(state.totalPendingAmount)}d', style: TextStyle(color: scheme.onErrorContainer, fontSize: 18, fontWeight: FontWeight.bold)),
            ])),
          ]),
        ),
      Expanded(
        child: pendingFines.isEmpty
          ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.check_circle_outline, size: 64, color: Colors.green.shade300),
              const SizedBox(height: 16),
              Text('Khong co khoan phat nao', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: scheme.onSurfaceVariant)),
            ]))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: pendingFines.length,
              itemBuilder: (context, index) => _PendingFineCard(fineDetails: pendingFines[index], isProcessing: state.isProcessing),
            ),
      ),
    ]);
  }
}

class _PaidFinesTab extends ConsumerWidget {
  const _PaidFinesTab({required this.state});
  final FineListState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final paidFines = state.paidFines;
    return Column(children: [
      if (paidFines.isNotEmpty)
        Container(
          width: double.infinity, padding: const EdgeInsets.all(16), color: scheme.primaryContainer,
          child: Row(children: [
            Icon(Icons.account_balance_wallet, color: scheme.onPrimaryContainer),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${paidFines.length} khoan da xu ly', style: TextStyle(color: scheme.onPrimaryContainer, fontWeight: FontWeight.w600)),
              Text('Da thu: ${_currencyFormat.format(state.totalPaidAmount)}d', style: TextStyle(color: scheme.onPrimaryContainer, fontSize: 18, fontWeight: FontWeight.bold)),
            ])),
          ]),
        ),
      Expanded(
        child: paidFines.isEmpty
          ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.history, size: 64, color: scheme.outlineVariant),
              const SizedBox(height: 16),
              Text('Chua co lich su', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: scheme.onSurfaceVariant)),
            ]))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: paidFines.length,
              itemBuilder: (context, index) => _PaidFineCard(fineDetails: paidFines[index]),
            ),
      ),
    ]);
  }
}

class _PendingFineCard extends ConsumerWidget {
  const _PendingFineCard({required this.fineDetails, required this.isProcessing});
  final FineWithDetails fineDetails;
  final bool isProcessing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final fine = fineDetails.fine;
    return Card(
      margin: const EdgeInsets.only(bottom: 12), elevation: 2, color: scheme.surfaceContainerLowest,
      child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(backgroundColor: Colors.red.shade100, child: Icon(Icons.person, color: Colors.red.shade700)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(fineDetails.memberName, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            Text('Ma HV: ${fineDetails.memberId}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.red.shade200)),
            child: Text('${_currencyFormat.format(fine.amount)}d', style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ]),
        const SizedBox(height: 12), const Divider(height: 1), const SizedBox(height: 12),
        Row(children: [
          Icon(Icons.warning_amber, size: 18, color: Colors.orange.shade700),
          const SizedBox(width: 8),
          Expanded(child: Text(_buildReasonText(fine.reason, fine.overdueDays), style: TextStyle(color: Colors.orange.shade700, fontWeight: FontWeight.w500))),
        ]),
        const SizedBox(height: 8),
        if (fineDetails.bookTitle != null) ...[
          Row(children: [
            Icon(Icons.menu_book, size: 18, color: scheme.primary),
            const SizedBox(width: 8),
            Expanded(child: Text('Sach: ${fineDetails.bookTitle}', style: Theme.of(context).textTheme.bodyMedium, maxLines: 1, overflow: TextOverflow.ellipsis)),
          ]),
          const SizedBox(height: 8),
        ],
        Row(children: [
          Icon(Icons.calendar_today, size: 18, color: scheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Text('Ngay tao: ${_dateFormat.format(fine.createdAt)}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
        ]),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: fineDetails.canPayFromWallet ? Colors.green.shade50 : Colors.orange.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: fineDetails.canPayFromWallet ? Colors.green.shade200 : Colors.orange.shade200),
          ),
          child: Row(children: [
            Icon(Icons.account_balance_wallet, size: 18, color: fineDetails.canPayFromWallet ? Colors.green.shade700 : Colors.orange.shade700),
            const SizedBox(width: 8),
            Expanded(child: Text('So du vi: ${_currencyFormat.format(fineDetails.memberBalance)}d', style: TextStyle(color: fineDetails.canPayFromWallet ? Colors.green.shade700 : Colors.orange.shade700, fontWeight: FontWeight.w500))),
            if (!fineDetails.canPayFromWallet)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: Colors.orange.shade700, borderRadius: BorderRadius.circular(4)),
                child: const Text('Khong du', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
          ]),
        ),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: FilledButton.icon(
            onPressed: isProcessing || !fineDetails.canPayFromWallet ? null : () => _confirmPay(context, ref),
            style: FilledButton.styleFrom(backgroundColor: Colors.green.shade600, disabledBackgroundColor: Colors.grey.shade300),
            icon: const Icon(Icons.payment, size: 18), label: const Text('Thu tien'),
          )),
          const SizedBox(width: 12),
          Expanded(child: OutlinedButton.icon(
            onPressed: isProcessing ? null : () => _confirmWaive(context, ref),
            style: OutlinedButton.styleFrom(foregroundColor: Colors.blue.shade700),
            icon: const Icon(Icons.volunteer_activism, size: 18), label: const Text('Mien phat'),
          )),
        ]),
      ])),
    );
  }

  String _buildReasonText(String reason, int overdueDays) {
    switch (reason.toLowerCase()) {
      case 'overdue': return 'Tra sach tre $overdueDays ngay';
      case 'damaged': return 'Sach bi hu hong';
      case 'lost': return 'Mat sach';
      default: return reason;
    }
  }

  Future<void> _confirmPay(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(children: [Icon(Icons.payment, color: Colors.green.shade700), const SizedBox(width: 8), const Text('Xac nhan thanh toan')]),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Hoi vien: ${fineDetails.memberName}'),
          const SizedBox(height: 4),
          Text('Ly do: ${_buildReasonText(fineDetails.fine.reason, fineDetails.fine.overdueDays)}'),
          const SizedBox(height: 12),
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)), child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('So tien phat:'), Text('${_currencyFormat.format(fineDetails.fine.amount)}d', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red))]),
            const SizedBox(height: 4),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('So du hien tai:'), Text('${_currencyFormat.format(fineDetails.memberBalance)}d')]),
            const Divider(),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('So du sau TT:'), Text('${_currencyFormat.format(fineDetails.memberBalance - fineDetails.fine.amount)}d', style: const TextStyle(fontWeight: FontWeight.bold))]),
          ])),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Huy')),
          FilledButton(onPressed: () => Navigator.of(ctx).pop(true), style: FilledButton.styleFrom(backgroundColor: Colors.green.shade600), child: const Text('Thanh toan')),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      final result = await ref.read(fineViewModelProvider.notifier).payFine(fineDetails);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.message), backgroundColor: result.success ? Colors.green : Colors.red));
      }
    }
  }

  Future<void> _confirmWaive(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(children: [Icon(Icons.volunteer_activism, color: Colors.blue.shade700), const SizedBox(width: 8), const Text('Xac nhan mien phat')]),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Hoi vien: ${fineDetails.memberName}'),
          const SizedBox(height: 4),
          Text('Ly do phat: ${_buildReasonText(fineDetails.fine.reason, fineDetails.fine.overdueDays)}'),
          const SizedBox(height: 4),
          Text('So tien: ${_currencyFormat.format(fineDetails.fine.amount)}d', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
          const SizedBox(height: 12),
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.blue.shade200)), child: Row(children: [
            Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
            const SizedBox(width: 8),
            const Expanded(child: Text('Mien phat se khong tru tien tu vi hoi vien', style: TextStyle(fontSize: 13))),
          ])),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Huy')),
          FilledButton(onPressed: () => Navigator.of(ctx).pop(true), style: FilledButton.styleFrom(backgroundColor: Colors.blue.shade600), child: const Text('Mien phat')),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      final success = await ref.read(fineViewModelProvider.notifier).waiveFine(fineDetails.fine.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(success ? 'Da mien phat thanh cong!' : 'Mien phat that bai'), backgroundColor: success ? Colors.green : Colors.red));
      }
    }
  }
}

class _PaidFineCard extends StatelessWidget {
  const _PaidFineCard({required this.fineDetails});
  final FineWithDetails fineDetails;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fine = fineDetails.fine;
    final isPaid = fine.status.toLowerCase() == 'paid';
    final statusColor = isPaid ? Colors.green : Colors.blue;
    final statusIcon = isPaid ? Icons.check_circle : Icons.volunteer_activism;
    final statusText = isPaid ? 'Da thu' : 'Da mien';

    return Card(
      margin: const EdgeInsets.only(bottom: 12), elevation: 1, color: scheme.surfaceContainerLowest,
      child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(backgroundColor: statusColor.shade100, child: Icon(Icons.person, color: statusColor.shade700)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(fineDetails.memberName, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            Text('Ma HV: ${fineDetails.memberId}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: statusColor.shade50, borderRadius: BorderRadius.circular(20), border: Border.all(color: statusColor.shade200)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(statusIcon, size: 16, color: statusColor.shade700),
              const SizedBox(width: 4),
              Text(statusText, style: TextStyle(color: statusColor.shade700, fontWeight: FontWeight.w600, fontSize: 12)),
            ]),
          ),
        ]),
        const SizedBox(height: 12), const Divider(height: 1), const SizedBox(height: 12),
        Row(children: [
          Icon(Icons.monetization_on, size: 18, color: scheme.primary),
          const SizedBox(width: 8),
          Text('So tien: ${_currencyFormat.format(fine.amount)}d', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Icon(Icons.info_outline, size: 18, color: scheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(child: Text('Ly do: ${_buildReasonText(fine.reason, fine.overdueDays)}', style: Theme.of(context).textTheme.bodyMedium)),
        ]),
        const SizedBox(height: 8),
        if (fineDetails.bookTitle != null) ...[
          Row(children: [
            Icon(Icons.menu_book, size: 18, color: scheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Expanded(child: Text('Sach: ${fineDetails.bookTitle}', style: Theme.of(context).textTheme.bodyMedium, maxLines: 1, overflow: TextOverflow.ellipsis)),
          ]),
          const SizedBox(height: 8),
        ],
        Wrap(spacing: 16, runSpacing: 8, children: [
          Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.calendar_today, size: 16, color: scheme.onSurfaceVariant),
            const SizedBox(width: 6),
            Text('Tao: ${_dateFormat.format(fine.createdAt)}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
          ]),
          if (fine.paidAt != null)
            Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(isPaid ? Icons.check : Icons.remove_circle, size: 16, color: statusColor.shade700),
              const SizedBox(width: 6),
              Text(isPaid ? 'Thu: ${_dateFormat.format(fine.paidAt!)}' : 'Mien: ${_dateFormat.format(fine.paidAt!)}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: statusColor.shade700, fontWeight: FontWeight.w500)),
            ]),
        ]),
      ])),
    );
  }

  String _buildReasonText(String reason, int overdueDays) {
    switch (reason.toLowerCase()) {
      case 'overdue': return 'Tra sach tre $overdueDays ngay';
      case 'damaged': return 'Sach bi hu hong';
      case 'lost': return 'Mat sach';
      default: return reason;
    }
  }
}
