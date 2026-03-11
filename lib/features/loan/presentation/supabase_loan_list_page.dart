import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_theme.dart';
import '../data/repositories/supabase_loan_repository.dart';
import 'supabase_borrow_book_page.dart';
import 'supabase_loan_view_model.dart';

/// Currency formatter for VND
final _currencyFormat = NumberFormat('#,###', 'vi_VN');

/// Trang danh sách phiếu mượn sử dụng Supabase
class SupabaseLoanListPage extends ConsumerWidget {
  const SupabaseLoanListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(supabaseLoanViewModelProvider);

    return stateAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Phiếu mượn')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, st) => Scaffold(
        appBar: AppBar(title: const Text('Phiếu mượn')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Lỗi: $e'),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () =>
                      ref.invalidate(supabaseLoanViewModelProvider),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (state) => _LoanListContent(state: state),
    );
  }
}

class _LoanListContent extends ConsumerWidget {
  const _LoanListContent({required this.state});

  final SupabaseLoanListState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeCount = state.activeLoans.length;
    final overdueCount = state.overdueLoans.length;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Phiếu mượn'),
          actions: [
            IconButton(
              tooltip: 'Tải lại',
              onPressed: () =>
                  ref.read(supabaseLoanViewModelProvider.notifier).refresh(),
              icon: const Icon(Icons.refresh),
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Đang mượn'),
                    if (activeCount > 0) ...[
                      const SizedBox(width: 8),
                      _Badge(count: activeCount, color: Colors.green),
                    ],
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Quá hạn'),
                    if (overdueCount > 0) ...[
                      const SizedBox(width: 8),
                      _Badge(count: overdueCount, color: Colors.red),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Active loans
            _LoanListView(
              loans: state.activeLoans,
              emptyMessage: 'Không có phiếu mượn đang hoạt động.',
              showCallButton: false,
            ),
            // Tab 2: Overdue loans
            _LoanListView(
              loans: state.overdueLoans,
              emptyMessage: 'Không có phiếu mượn quá hạn.',
              showCallButton: true,
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            final result = await Navigator.of(context).push<bool>(
              MaterialPageRoute(builder: (_) => const SupabaseBorrowBookPage()),
            );
            if (result == true && context.mounted) {
              ref.read(supabaseLoanViewModelProvider.notifier).refresh();
            }
          },
          icon: const Icon(Icons.add),
          label: const Text('Mượn sách'),
        ),
      ),
    );
  }
}

/// Badge widget for tab counts
class _Badge extends StatelessWidget {
  const _Badge({required this.count, required this.color});

  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        count.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Reusable loan list view
class _LoanListView extends ConsumerWidget {
  const _LoanListView({
    required this.loans,
    required this.emptyMessage,
    required this.showCallButton,
  });

  final List<SupabaseLoanWithDetails> loans;
  final String emptyMessage;
  final bool showCallButton;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (loans.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              showCallButton
                  ? Icons.check_circle_outline
                  : Icons.inbox_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(emptyMessage),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(supabaseLoanViewModelProvider.notifier).refresh(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: loans.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = loans[index];
          return _LoanCard(item: item, showCallButton: showCallButton);
        },
      ),
    );
  }
}

class _LoanCard extends ConsumerWidget {
  const _LoanCard({required this.item, required this.showCallButton});

  final SupabaseLoanWithDetails item;
  final bool showCallButton;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final loan = item.loan;
    final details = item.details;

    // Tìm sách quá hạn nhất
    final overdueDetail = details.where((d) => d.isOverdue).toList()
      ..sort((a, b) => b.overdueDays.compareTo(a.overdueDays));
    final maxOverdueDays =
        overdueDetail.isNotEmpty ? overdueDetail.first.overdueDays : 0;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: item.hasOverdueBooks
              ? scheme.error.withAlpha(100)
              : scheme.outline.withAlpha(50),
        ),
      ),
      child: InkWell(
        onTap: () => _showLoanDetails(context, ref),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    backgroundColor: item.hasOverdueBooks
                        ? scheme.errorContainer
                        : scheme.primaryContainer,
                    child: Icon(
                      Icons.person_outline,
                      color:
                          item.hasOverdueBooks ? scheme.error : scheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Member info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loan.memberName ?? loan.memberId,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        Text(
                          'Mã PM: ${loan.id}',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  // Overdue badge
                  if (item.hasOverdueBooks)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: scheme.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Quá hạn $maxOverdueDays ngày',
                        style: TextStyle(
                          color: scheme.error,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Book list
              ...details.take(3).map((detail) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.menu_book_outlined,
                          size: 18,
                          color: detail.isOverdue
                              ? scheme.error
                              : scheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            detail.bookTitle ?? detail.barcode,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: detail.isOverdue ? scheme.error : null,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          detail.dueDate != null
                              ? DateFormat('dd/MM').format(detail.dueDate!)
                              : '---',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: detail.isOverdue
                                        ? scheme.error
                                        : scheme.onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                  )),

              if (details.length > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '+ ${details.length - 3} sách khác',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                ),

              const SizedBox(height: 12),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Call button for overdue
                  if (showCallButton &&
                      loan.memberPhone != null &&
                      loan.memberPhone!.isNotEmpty)
                    IconButton(
                      onPressed: () => _makePhoneCall(loan.memberPhone!),
                      icon: const Icon(Icons.phone_outlined),
                      tooltip: 'Gọi điện nhắc nhở',
                      color: scheme.primary,
                    ),
                  // Return button
                  TextButton.icon(
                    onPressed: () => _showReturnDialog(context, ref),
                    icon: const Icon(Icons.assignment_return_outlined),
                    label: const Text('Trả sách'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLoanDetails(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final loan = item.loan;
    final details = item.details;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            controller: scrollController,
            children: [
              // Header
              Row(
                children: [
                  Icon(Icons.receipt_long, color: scheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Phiếu mượn ${loan.id}',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        Text(
                          'Ngày mượn: ${loan.borrowDate != null ? DateFormat('dd/MM/yyyy').format(loan.borrowDate!) : '---'}',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),

              // Member info
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: scheme.primaryContainer,
                  child: Icon(Icons.person, color: scheme.primary),
                ),
                title: Text(loan.memberName ?? loan.memberId),
                subtitle: Text(loan.memberPhone ?? 'Không có SĐT'),
                contentPadding: EdgeInsets.zero,
              ),

              const SizedBox(height: 16),
              Text(
                'Danh sách sách (${details.length})',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),

              // Book list
              ...details.map((detail) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: detail.isOverdue
                            ? scheme.errorContainer
                            : scheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.menu_book,
                          color: detail.isOverdue
                              ? scheme.error
                              : scheme.onSurfaceVariant,
                        ),
                      ),
                      title: Text(detail.bookTitle ?? detail.barcode),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Mã vạch: ${detail.barcode}'),
                          Text(
                            'Hạn trả: ${detail.dueDate != null ? DateFormat('dd/MM/yyyy').format(detail.dueDate!) : '---'}',
                            style: TextStyle(
                              color: detail.isOverdue ? scheme.error : null,
                            ),
                          ),
                          if (detail.isOverdue)
                            Text(
                              'Quá hạn ${detail.overdueDays} ngày - Phạt: ${_currencyFormat.format(detail.overdueDays * kSupabaseFineRatePerDay)} VND',
                              style: TextStyle(
                                color: scheme.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                      trailing: detail.returnDate != null
                          ? Icon(Icons.check_circle,
                              color: Colors.green.shade600)
                          : null,
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  void _showReturnDialog(BuildContext context, WidgetRef ref) {
    final loan = item.loan;
    final details = item.details.where((d) => d.returnDate == null).toList();

    if (details.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tất cả sách đã được trả.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => _ReturnBookDialog(
        loanId: loan.id,
        details: details,
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

/// Dialog để trả sách
class _ReturnBookDialog extends ConsumerStatefulWidget {
  const _ReturnBookDialog({
    required this.loanId,
    required this.details,
  });

  final String loanId;
  final List<SupabaseLoanDetail> details;

  @override
  ConsumerState<_ReturnBookDialog> createState() => _ReturnBookDialogState();
}

class _ReturnBookDialogState extends ConsumerState<_ReturnBookDialog> {
  final Set<String> _selectedBarcodes = {};
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: const Text('Trả sách'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chọn sách cần trả:',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            ...widget.details.map((detail) => CheckboxListTile(
                  value: _selectedBarcodes.contains(detail.barcode),
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _selectedBarcodes.add(detail.barcode);
                      } else {
                        _selectedBarcodes.remove(detail.barcode);
                      }
                    });
                  },
                  title: Text(detail.bookTitle ?? detail.barcode),
                  subtitle: detail.isOverdue
                      ? Text(
                          'Quá hạn ${detail.overdueDays} ngày - Phạt: ${_currencyFormat.format(detail.overdueDays * kSupabaseFineRatePerDay)} VND',
                          style: TextStyle(color: scheme.error),
                        )
                      : null,
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                )),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed:
              _selectedBarcodes.isEmpty || _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text('Trả ${_selectedBarcodes.length} sách'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);

    try {
      final viewModel = ref.read(supabaseLoanViewModelProvider.notifier);
      final results = <SupabaseReturnBookResult>[];

      for (final barcode in _selectedBarcodes) {
        final result = await viewModel.returnBook(
          loanId: widget.loanId,
          barcode: barcode,
        );
        results.add(result);
      }

      if (mounted) {
        Navigator.pop(context);

        // Show summary
        final overdueBooks = results.where((r) => r.isOverdue).toList();
        final totalFine =
            overdueBooks.fold<int>(0, (sum, r) => sum + r.fineAmount);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              overdueBooks.isEmpty
                  ? 'Trả ${results.length} sách thành công!'
                  : 'Trả ${results.length} sách thành công. Phạt: ${_currencyFormat.format(totalFine)} VND',
            ),
            backgroundColor: overdueBooks.isEmpty
                ? AppTheme.successColor
                : AppTheme.warningColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
