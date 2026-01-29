import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../data/db/app_database.dart';
import 'loan_view_model.dart';

class BorrowBookPage extends ConsumerStatefulWidget {
  const BorrowBookPage({super.key});

  @override
  ConsumerState<BorrowBookPage> createState() => _BorrowBookPageState();
}

class _BorrowBookPageState extends ConsumerState<BorrowBookPage> {
  final _formKey = GlobalKey<FormState>();

  Member? _selectedMember;
  AvailableCopyInfo? _selectedCopy;
  DateTime _dueDate = DateTime.now().add(const Duration(days: 14));

  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final membersAsync = ref.watch(allMembersProvider);
    final copiesAsync = ref.watch(availableCopiesProvider);

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
                      'Tạo phiếu mượn sách mới cho hội viên. Thời hạn mặc định là 14 ngày.',
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
                return DropdownButtonFormField<Member>(
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
                    final name = _formatMemberName(m);
                    return DropdownMenuItem(
                      value: m,
                      child: Text('$name (${m.id})'),
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

            // Book copy dropdown
            Text(
              'Chọn bản sách *',
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
                    child: const Text('Không có bản sách nào còn trống.'),
                  );
                }
                return DropdownButtonFormField<AvailableCopyInfo>(
                  decoration: InputDecoration(
                    hintText: 'Chọn bản sách...',
                    prefixIcon: const Icon(Icons.menu_book_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: scheme.surfaceContainerLow,
                  ),
                  isExpanded: true,
                  items: copies.map((c) {
                    return DropdownMenuItem(
                      value: c,
                      child: Text(
                        c.displayText,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedCopy = value),
                  validator: (value) {
                    if (value == null) return 'Vui lòng chọn bản sách';
                    return null;
                  },
                );
              },
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                        DateFormat('EEEE, dd/MM/yyyy', 'vi_VN')
                            .format(_dueDate),
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
              onPressed: _isSubmitting ? null : _submit,
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
              label: Text(_isSubmitting ? 'Đang xử lý...' : 'Tạo phiếu mượn'),
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await ref.read(loanViewModelProvider.notifier).borrowBook(
            memberId: _selectedMember!.id,
            copyId: _selectedCopy!.copyId,
            dueDate: _dueDate,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Tạo phiếu mượn thành công!'),
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

  String _formatMemberName(Member member) {
    final parts = <String>[];
    if (member.lastName != null && member.lastName!.isNotEmpty) {
      parts.add(member.lastName!);
    }
    if (member.middleName != null && member.middleName!.isNotEmpty) {
      parts.add(member.middleName!);
    }
    if (member.firstName != null && member.firstName!.isNotEmpty) {
      parts.add(member.firstName!);
    }
    return parts.isEmpty ? member.id : parts.join(' ');
  }
}
