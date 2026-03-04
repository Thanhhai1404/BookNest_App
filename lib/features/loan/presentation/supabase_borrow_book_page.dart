import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'supabase_loan_view_model.dart';

/// Trang mượn sách sử dụng Supabase
class SupabaseBorrowBookPage extends ConsumerStatefulWidget {
  const SupabaseBorrowBookPage({super.key});

  @override
  ConsumerState<SupabaseBorrowBookPage> createState() => _SupabaseBorrowBookPageState();
}

class _SupabaseBorrowBookPageState extends ConsumerState<SupabaseBorrowBookPage> {
  final _formKey = GlobalKey<FormState>();

  Map<String, dynamic>? _selectedMember;
  final List<SupabaseAvailableCopyInfo> _selectedBooks = [];
  DateTime _dueDate = DateTime.now().add(const Duration(days: 14));

  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final membersAsync = ref.watch(supabaseMembersForLoanProvider);
    final copiesAsync = ref.watch(supabaseAvailableCopiesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mượn sách'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Header info card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: scheme.primaryContainer.withAlpha(50),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: scheme.primaryContainer),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: scheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Tạo phiếu mượn sách mới cho hội viên. Có thể chọn nhiều sách cùng lúc. Thời hạn mặc định là 14 ngày.',
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Member dropdown
            Text(
              'Chọn hội viên *',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            membersAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, _) =>
                  Text('Lỗi: $e', style: TextStyle(color: scheme.error)),
              data: (members) {
                if (members.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: scheme.errorContainer.withAlpha(50),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('Chưa có hội viên nào trong hệ thống.'),
                  );
                }
                return DropdownButtonFormField<Map<String, dynamic>>(
                  decoration: InputDecoration(
                    hintText: 'Chọn hội viên...',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: scheme.surfaceContainerLow,
                  ),
                  isExpanded: true,
                  items: members.map((m) {
                    final name = formatMemberNameFromJson(m);
                    return DropdownMenuItem(
                      value: m,
                      child: Text('$name (${m['madg']})'),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedMember = value),
                  validator: (value) {
                    if (value == null) return 'Vui lòng chọn hội viên';
                    return null;
                  },
                );
              },
            ),
            const SizedBox(height: 20),

            // Book selection
            Text(
              'Chọn sách mượn *',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            copiesAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, _) =>
                  Text('Lỗi: $e', style: TextStyle(color: scheme.error)),
              data: (copies) {
                if (copies.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: scheme.errorContainer.withAlpha(50),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('Không có sách nào còn trống.'),
                  );
                }

                // Lọc ra những sách chưa được chọn
                final availableCopies = copies
                    .where((c) => !_selectedBooks.any((s) => s.barcode == c.barcode))
                    .toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nút bấm để mở bottom sheet chọn sách
                    InkWell(
                      onTap: availableCopies.isEmpty
                          ? null
                          : () => _showBookPicker(context, availableCopies),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: scheme.outline),
                          borderRadius: BorderRadius.circular(12),
                          color: scheme.surfaceContainerLow,
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.menu_book_outlined, color: scheme.onSurfaceVariant),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                availableCopies.isEmpty
                                    ? 'Đã chọn hết sách có sẵn'
                                    : 'Bấm để chọn sách... (${availableCopies.length} sách có sẵn)',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: availableCopies.isEmpty
                                          ? scheme.onSurfaceVariant
                                          : scheme.onSurface,
                                    ),
                              ),
                            ),
                            Icon(Icons.add_circle_outline, color: scheme.primary),
                          ],
                        ),
                      ),
                    ),

                    // Danh sách sách đã chọn
                    if (_selectedBooks.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: scheme.outline.withAlpha(50)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.library_books, size: 20, color: scheme.primary),
                                const SizedBox(width: 8),
                                Text(
                                  'Sách đã chọn (${_selectedBooks.length})',
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ...(_selectedBooks.map((book) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '• ${book.displayText}',
                                          style: Theme.of(context).textTheme.bodyMedium,
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.close, size: 20, color: scheme.error),
                                        onPressed: () {
                                          setState(() => _selectedBooks.remove(book));
                                        },
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ],
                                  ),
                                ))),
                          ],
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),

            // Validation message cho sách
            if (_selectedBooks.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Vui lòng chọn ít nhất một cuốn sách',
                  style: TextStyle(
                    color: scheme.error,
                    fontSize: 12,
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // Due date picker
            Text(
              'Hạn trả *',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickDueDate,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: scheme.outline),
                  borderRadius: BorderRadius.circular(12),
                  color: scheme.surfaceContainerLow,
                ),
                child: Row(
                  children: [
                    Icon(Icons.event_outlined, color: scheme.onSurfaceVariant),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        DateFormat('EEEE, dd/MM/yyyy', 'vi_VN').format(_dueDate),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    Icon(Icons.edit_calendar, color: scheme.primary),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Còn ${_dueDate.difference(DateTime.now()).inDays} ngày',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 32),

            // Submit button
            FilledButton.icon(
              onPressed: _isSubmitting || _selectedBooks.isEmpty ? null : _submit,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check_rounded),
              label: Text(_isSubmitting 
                ? 'Đang xử lý...' 
                : 'Tạo phiếu mượn (${_selectedBooks.length} sách)'),
            ),
          ],
        ),
      ),
    );
  }
  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      helpText: 'Chọn ngày hạn trả',
      cancelText: 'Hủy',
      confirmText: 'Chọn',
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  /// Hiển thị bottom sheet để chọn sách
  void _showBookPicker(BuildContext context, List<SupabaseAvailableCopyInfo> availableCopies) {
    final scheme = Theme.of(context).colorScheme;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: scheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.menu_book, color: scheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Chọn sách (${availableCopies.length} có sẵn)',
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
              child: ListView.builder(
                controller: scrollController,
                itemCount: availableCopies.length,
                itemBuilder: (context, index) {
                  final book = availableCopies[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: scheme.primaryContainer,
                      child: Icon(Icons.book, color: scheme.primary),
                    ),
                    title: Text(
                      book.bookTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text('Mã vạch: ${book.barcode}'),
                    trailing: Icon(Icons.add_circle_outline, color: scheme.primary),
                    onTap: () {
                      setState(() => _selectedBooks.add(book));
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBooks.isEmpty) return;

    setState(() => _isSubmitting = true);

    try {
      final loanId = await ref.read(supabaseLoanViewModelProvider.notifier).borrowBooks(
            memberId: _selectedMember!['madg'] as String,
            barcodes: _selectedBooks.map((b) => b.barcode).toList(),
            dueDate: _dueDate,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tạo phiếu mượn $loanId thành công với ${_selectedBooks.length} sách!'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red.shade600,
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
