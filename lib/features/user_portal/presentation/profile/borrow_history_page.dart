import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/theme/app_theme.dart';
import '../../core/user_auth_provider.dart';
import '../../data/user_borrow_repository.dart';

/// Lịch sử mượn sách - Phiếu mượn & trạng thái
class BorrowHistoryPage extends ConsumerWidget {
  const BorrowHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final member = ref.watch(currentMemberProvider);

    if (member == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Lịch sử mượn sách')),
        body: const Center(child: Text('Vui lòng đăng nhập')),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundLight,
        appBar: AppBar(
          title: const Text('Lịch sử mượn sách'),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Đang xử lý'),
              Tab(text: 'Đã trả / Đã hủy'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ActiveBorrowsTab(memberId: member.id),
            _ReturnedBorrowsTab(memberId: member.id),
          ],
        ),
      ),
    );
  }
}

// ==================== TAB: ĐANG XỬ LÝ ====================

class _ActiveBorrowsTab extends ConsumerWidget {
  const _ActiveBorrowsTab({required this.memberId});
  final String memberId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final borrowsAsync = ref.watch(activeBorrowsProvider(memberId));

    return borrowsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Lỗi: $e')),
      data: (borrows) {
        if (borrows.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.inbox_outlined,
                    size: 48,
                    color: AppTheme.textSecondary.withAlpha(100)),
                const SizedBox(height: 12),
                Text('Không có phiếu mượn nào',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppTheme.textSecondary)),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async =>
              ref.invalidate(activeBorrowsProvider(memberId)),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: borrows.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _BorrowCard(
                record: borrows[index],
                memberId: memberId,
              );
            },
          ),
        );
      },
    );
  }
}

// ==================== TAB: ĐÃ TRẢ / ĐÃ HỦY ====================

class _ReturnedBorrowsTab extends ConsumerWidget {
  const _ReturnedBorrowsTab({required this.memberId});
  final String memberId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final borrowsAsync = ref.watch(returnedBorrowsProvider(memberId));

    return borrowsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Lỗi: $e')),
      data: (borrows) {
        if (borrows.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.inbox_outlined,
                    size: 48,
                    color: AppTheme.textSecondary.withAlpha(100)),
                const SizedBox(height: 12),
                Text('Chưa có phiếu trả / hủy nào',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppTheme.textSecondary)),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async =>
              ref.invalidate(returnedBorrowsProvider(memberId)),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: borrows.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _BorrowCard(
                record: borrows[index],
                memberId: memberId,
              );
            },
          ),
        );
      },
    );
  }
}

// ==================== BORROW CARD (Interactive) ====================

class _BorrowCard extends ConsumerWidget {
  const _BorrowCard({required this.record, required this.memberId});

  final UserBorrowRecord record;
  final String memberId;

  Color get _statusColor {
    if (record.isCancelled) return AppTheme.errorColor;
    if (record.isPending) return AppTheme.warningColor;
    if (record.isReturned) return AppTheme.textSecondary;
    if (record.isOverdue) return AppTheme.errorColor;
    return AppTheme.successColor;
  }

  IconData get _statusIcon {
    if (record.isCancelled) return Icons.cancel_outlined;
    if (record.isPending) return Icons.hourglass_top;
    if (record.isReturned) return Icons.check_circle_outline;
    if (record.isOverdue) return Icons.warning_amber;
    return Icons.book;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final borrowStr =
        '${record.borrowDate.day}/${record.borrowDate.month}/${record.borrowDate.year}';
    final dueStr = record.dueDate != null
        ? '${record.dueDate!.day}/${record.dueDate!.month}/${record.dueDate!.year}'
        : '---';

    return Material(
      color: AppTheme.cardLight,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showBorrowDetailDialog(context, ref),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.slate200.withAlpha(120)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Loan ID & Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text('#${record.loanId}',
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: AppTheme.textSecondary)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _statusColor.withAlpha(20),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_statusIcon, size: 12, color: _statusColor),
                        const SizedBox(width: 4),
                        Text(record.statusLabel,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _statusColor,
                            )),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Book info
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryColor.withAlpha(40),
                          AppTheme.primaryColor.withAlpha(70),
                        ],
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: record.bookImageUrl != null
                          ? Image.network(record.bookImageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                  Icons.menu_book,
                                  color: Colors.white70,
                                  size: 20))
                          : const Icon(Icons.menu_book,
                              color: Colors.white70, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(record.bookTitle ?? record.bookBarcode,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined,
                                size: 12, color: AppTheme.textSecondary),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text('$borrowStr → $dueStr',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                          color: AppTheme.textSecondary)),
                            ),
                          ],
                        ),
                        if (record.fineAmount != null &&
                            record.fineAmount! > 0) ...[
                          const SizedBox(height: 4),
                          Text('Tiền phạt: ${record.fineAmount}đ',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: AppTheme.errorColor,
                                    fontWeight: FontWeight.w600,
                                  )),
                        ],
                      ],
                    ),
                  ),
                  // Chevron hint
                  const Icon(Icons.chevron_right,
                      size: 20, color: AppTheme.textSecondary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== DIALOG: CHI TIẾT PHIẾU MƯỢN (QR) ====================

  void _showBorrowDetailDialog(BuildContext context, WidgetRef ref) {
    final qrData = 'booknest://borrow/${record.loanId}';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(
                'Chi tiết phiếu mượn',
                style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                '#${record.loanId}',
                style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 4),

              // Status badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_statusIcon, size: 14, color: _statusColor),
                    const SizedBox(width: 4),
                    Text(record.statusLabel,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _statusColor,
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Book info
              Text(
                record.bookTitle ?? record.bookBarcode,
                style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'Mã vạch: ${record.bookBarcode}',
                style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
              const SizedBox(height: 20),

              // QR Code
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.slate200),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Đưa mã QR cho Thủ thư',
                      style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: 160,
                      height: 160,
                      child: QrImageView(
                        data: qrData,
                        version: QrVersions.auto,
                        size: 160,
                        eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: AppTheme.textPrimaryLight,
                        ),
                        dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: AppTheme.textPrimaryLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Date info
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.warningColor.withAlpha(15),
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: AppTheme.warningColor.withAlpha(50)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.access_time,
                        size: 14, color: AppTheme.warningColor),
                    const SizedBox(width: 6),
                    Text(
                      'Mượn: ${record.borrowDate.day}/${record.borrowDate.month}/${record.borrowDate.year}'
                      '${record.dueDate != null ? '  →  Hẹn trả: ${record.dueDate!.day}/${record.dueDate!.month}/${record.dueDate!.year}' : ''}',
                      style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                            color: AppTheme.warningColor,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Action buttons
              Row(
                children: [
                  // Nút Đóng
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Đóng'),
                    ),
                  ),
                  // Nút Hủy đơn - chỉ hiện khi đang Chờ duyệt
                  if (record.isPending) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(ctx); // Đóng detail dialog
                          _showCancelDialog(context, ref);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.errorColor,
                          padding:
                              const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cancel_outlined, size: 18),
                            SizedBox(width: 6),
                            Text('Hủy đơn',
                                style:
                                    TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== DIALOG: XÁC NHẬN HỦY ĐƠN ====================

  void _showCancelDialog(BuildContext context, WidgetRef ref) {
    final reasonController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          icon: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.errorColor.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.cancel_outlined,
              color: AppTheme.errorColor,
              size: 32,
            ),
          ),
          title: const Text('Xác nhận hủy đơn'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bạn có chắc muốn hủy phiếu mượn #${record.loanId}?\n'
                'Sách sẽ được trả lại kệ để người khác mượn.',
                style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                      height: 1.5,
                    ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                enabled: !isLoading,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Lý do hủy (không bắt buộc)',
                  hintText: 'VD: Đổi ý, bận không đến lấy được...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(ctx),
              child: const Text('Quay lại'),
            ),
            FilledButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      setDialogState(() => isLoading = true);

                      try {
                        final repo =
                            ref.read(userBorrowRepositoryProvider);
                        await repo.cancelBorrowRequest(
                          record.loanId,
                          reasonController.text,
                        );

                        // Invalidate cả 2 tab + count
                        ref.invalidate(activeBorrowsProvider(memberId));
                        ref.invalidate(returnedBorrowsProvider(memberId));
                        ref.invalidate(borrowHistoryProvider(memberId));
                        ref.invalidate(
                            activeBorrowCountProvider(memberId));

                        if (ctx.mounted) Navigator.pop(ctx);

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Row(
                                children: [
                                  Icon(Icons.check_circle,
                                      color: Colors.white, size: 20),
                                  SizedBox(width: 10),
                                  Expanded(
                                      child: Text(
                                          'Đã hủy đơn mượn thành công')),
                                ],
                              ),
                              backgroundColor: AppTheme.successColor,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(10)),
                              margin: const EdgeInsets.all(16),
                            ),
                          );
                        }
                      } catch (e) {
                        setDialogState(() => isLoading = false);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.error_outline,
                                      color: Colors.white, size: 20),
                                  const SizedBox(width: 10),
                                  Expanded(
                                      child: Text('Lỗi hủy đơn: $e')),
                                ],
                              ),
                              backgroundColor: AppTheme.errorColor,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(10)),
                              margin: const EdgeInsets.all(16),
                            ),
                          );
                        }
                      }
                    },
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.errorColor,
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Xác nhận hủy',
                      style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}
