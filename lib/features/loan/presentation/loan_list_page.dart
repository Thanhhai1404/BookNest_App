import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../reservation/data/repositories/reservation_repository.dart';
import '../data/repositories/loan_repository.dart';
import 'borrow_book_page.dart';
import 'loan_view_model.dart';

class LoanListPage extends ConsumerWidget {
  const LoanListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(loanViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Phiếu mượn đang hoạt động'),
        actions: [
          IconButton(
            tooltip: 'Tải lại',
            onPressed: () => ref.read(loanViewModelProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: stateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Lỗi: $e'),
          ),
        ),
        data: (state) {
          if (state.activeLoans.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Chưa có phiếu mượn nào.'),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(loanViewModelProvider.notifier).refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.activeLoans.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = state.activeLoans[index];
                return _LoanCard(item: item);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => const BorrowBookPage()),
          );
          if (result == true && context.mounted) {
            ref.read(loanViewModelProvider.notifier).refresh();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Mượn sách'),
      ),
    );
  }
}

class _LoanCard extends ConsumerWidget {
  const _LoanCard({required this.item});

  final LoanWithDetails item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final dateFormat = DateFormat('dd/MM/yyyy');

    final isOverdue = item.loan.dueDate.isBefore(DateTime.now());
    final statusColor = isOverdue ? Colors.red : Colors.green;
    final statusLabel = isOverdue ? 'Quá hạn' : 'Đang mượn';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outlineVariant.withAlpha(80)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Member name + status badge
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: scheme.primaryContainer,
                  child: Icon(Icons.person, color: scheme.onPrimaryContainer),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.memberName,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      Text(
                        'Mã phiếu: #${item.loan.id}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withAlpha(100)),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Book info
            Row(
              children: [
                Icon(Icons.menu_book, size: 20, color: scheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${item.bookTitle} (${item.copyId})',
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Dates
            Row(
              children: [
                Expanded(
                  child: _InfoChip(
                    icon: Icons.calendar_today_outlined,
                    label: 'Ngày mượn',
                    value: dateFormat.format(item.loan.borrowDate),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InfoChip(
                    icon: Icons.event_outlined,
                    label: 'Hạn trả',
                    value: dateFormat.format(item.loan.dueDate),
                    isHighlighted: isOverdue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),            // Return book button
            Row(
              children: [
                // Renew button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _canRenew(item)
                        ? () => _confirmRenew(context, ref)
                        : null,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue.shade700,
                      side: BorderSide(
                        color: _canRenew(item)
                            ? Colors.blue.shade300
                            : Colors.grey.shade300,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.update),
                    label: Text(
                      'Gia hạn (${item.loan.renewalCount}/2)',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Return button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmReturn(context, ref),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green.shade700,
                      side: BorderSide(color: Colors.green.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.assignment_return),
                    label: const Text('Trả sách'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );  }

  /// Check if this loan can be renewed (max 2 times).
  bool _canRenew(LoanWithDetails item) {
    return item.loan.renewalCount < 2;
  }

  Future<void> _confirmRenew(BuildContext context, WidgetRef ref) async {
    final isOverdue = item.loan.dueDate.isBefore(DateTime.now());
    final dateFormat = DateFormat('dd/MM/yyyy');
    final newDueDate = item.loan.dueDate.add(const Duration(days: 7));

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.update, color: Colors.blue.shade700),
            const SizedBox(width: 8),
            const Text('Gia hạn sách'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isOverdue) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.orange.shade700),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Lưu ý: Sách này đã quá hạn!',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text('Sách: ${item.bookTitle}'),
            const SizedBox(height: 4),
            Text('Mã bản: ${item.copyId}'),
            const SizedBox(height: 4),
            Text('Người mượn: ${item.memberName}'),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Hạn trả hiện tại: '),
                Text(
                  dateFormat.format(item.loan.dueDate),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isOverdue ? Colors.red : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Text('Hạn trả mới: '),
                Text(
                  dateFormat.format(newDueDate),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const Text(' (+7 ngày)'),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Số lần gia hạn: ${item.loan.renewalCount}/2',
              style: Theme.of(ctx).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Xác nhận gia hạn'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final resultDate =
            await ref.read(loanViewModelProvider.notifier).renewBook(item.loan.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Gia hạn thành công! Hạn trả mới: ${dateFormat.format(resultDate)}',
              ),
              backgroundColor: Colors.blue.shade600,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: $e'),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }
  Future<void> _confirmReturn(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận trả sách'),
        content: Text(
          'Xác nhận trả cuốn "${item.bookTitle}" (${item.copyId})?\n\n'
          'Người mượn: ${item.memberName}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        // Return the book and get the bookId
        final bookId = await ref
            .read(loanViewModelProvider.notifier)
            .returnBook(item.loan.id);

        // Check if there's an active reservation for this book
        final reservationRepo = ref.read(reservationRepositoryProvider);
        final reservation =
            await reservationRepo.getActiveReservationForBook(bookId);

        if (reservation != null && context.mounted) {
          // Show important reservation alert
          await showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              icon: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.notification_important,
                  size: 48,
                  color: Colors.orange.shade700,
                ),
              ),
              title: const Text(
                '🔔 Sách được đặt trước!',
                textAlign: TextAlign.center,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.person,
                                color: Colors.orange.shade700, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                reservation.memberName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.badge,
                                color: Colors.orange.shade700, size: 20),
                            const SizedBox(width: 8),
                            Text('Mã: ${reservation.memberId}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Vui lòng giữ sách "${item.bookTitle}" tại quầy và liên hệ hội viên!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ],
              ),
              actions: [
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () async {
                      // Mark reservation as fulfilled
                      await reservationRepo
                          .fulfillReservation(reservation.reservation.id);
                      if (ctx.mounted) {
                        Navigator.of(ctx).pop();
                      }
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Đã hiểu - Giữ sách tại quầy'),
                  ),
                ),
              ],
            ),
          );

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Trả sách thành công! Đã thông báo đặt trước cho ${reservation.memberName}.',
                ),
                backgroundColor: Colors.orange.shade600,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } else if (context.mounted) {
          // Normal return, no reservation
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Trả sách thành công!'),
              backgroundColor: Colors.green.shade600,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: $e'),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
    this.isHighlighted = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = isHighlighted ? Colors.red : scheme.onSurfaceVariant;

    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}
