import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/supabase_auth_provider.dart';
import '../../../data/db/app_database.dart';
import '../../loan/presentation/loan_view_model.dart';
import 'book_detail_view_model.dart';

/// Status enum cho sách
enum BookCopyStatus {
  available(0, 'Sẵn sàng', Colors.green),
  borrowed(1, 'Đang mượn', Colors.red),
  reserved(2, 'Đã đặt trước', Colors.orange),
  damaged(3, 'Hỏng/Mất', Colors.grey);

  final int code;
  final String label;
  final Color color;

  const BookCopyStatus(this.code, this.label, this.color);

  static BookCopyStatus fromCode(int code) {
    return BookCopyStatus.values.firstWhere(
      (s) => s.code == code,
      orElse: () => BookCopyStatus.available,
    );
  }
}

class BookDetailPage extends ConsumerWidget {
  const BookDetailPage({super.key, required this.bookId});

  final String bookId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(bookDetailViewModelProvider(bookId));
    final currentEmployee = ref.watch(currentEmployeeProvider);
    final isAdmin = currentEmployee?.isAdmin ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết $bookId'),
        actions: [
          // Chỉ hiển thị nút Xóa nếu là Admin
          if (isAdmin)
            IconButton(
              tooltip: 'Xóa sách',
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Xóa sách?'),
                    content: const Text(
                      'Bạn có chắc chắn muốn xóa sách này và toàn bộ bản sao không? Hành động này không thể hoàn tác.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Hủy'),
                      ),
                      FilledButton.tonal(
                        style: FilledButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Xóa'),
                      ),
                    ],
                  ),
                );
                if (ok != true) return;

                final notifier =
                    ref.read(bookDetailViewModelProvider(bookId).notifier);
                try {
                  await notifier.deleteBook();
                  if (!context.mounted) return;
                  Navigator.of(context).pop(true);
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Xóa sách thất bại: $e')),
                  );
                }
              },
            ),
        ],
      ),
      body: stateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Lỗi: $e'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(bookDetailViewModelProvider(bookId)),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          ),
        ),        data: (state) {
          return Column(
            children: [
              // Header and reservation button wrapped in SingleChildScrollView if no copies
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _HeaderCard(
                      title: state.bookTitle.title.isNotEmpty 
                          ? state.bookTitle.title 
                          : state.bookTitle.id,
                      author: state.authorName,
                      subtitle: '${state.publisherName} • ${state.categoryName}',
                      description: state.bookTitle.description ?? '',
                      availableCopies: state.availableCopiesCount,
                      totalCopies: state.copies.length,
                      hasReservation: state.hasActiveReservation,
                      imageUrl: state.bookTitle.imageUrl,
                    ),
                    // Reservation button when out of stock
                    if (state.availableCopiesCount == 0 && state.copies.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _ReservationButton(
                          bookId: bookId,
                          hasActiveReservation: state.hasActiveReservation,
                          onReserve: (memberId) async {
                            try {
                              await ref
                                  .read(bookDetailViewModelProvider(bookId).notifier)
                                  .createReservation(memberId);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Đặt trước thành công!'),
                                    backgroundColor: Colors.green.shade600,
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Lỗi: $e'),
                                    backgroundColor: Colors.red.shade600,
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      ),
                    const Divider(height: 1),
                    // Book copies section
                    if (state.copies.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(child: Text('Chưa có bản sao nào.')),
                      )
                    else
                      ...state.copies.asMap().entries.map((entry) {
                        final index = entry.key;
                        final c = entry.value;
                        return Padding(
                          padding: EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: index == 0 ? 16 : 4,
                            bottom: index == state.copies.length - 1 ? 80 : 4,
                          ),
                          child: _CopyTile(
                            copyId: c.barcode,
                            status: c.status,
                            onDelete: () async {
                              final ok = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Xóa bản sao?'),
                                  content: Text('Xóa bản sao ${c.barcode} này?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                      child: const Text('Hủy'),
                                    ),
                                    FilledButton.tonal(
                                      style: FilledButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: Colors.red,
                                      ),
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: const Text('Xóa'),
                                    ),
                                  ],
                                ),
                              );
                              if (ok != true) return;

                              final notifier = ref.read(
                                  bookDetailViewModelProvider(bookId).notifier);
                              try {
                                await notifier.deleteCopy(c.barcode);
                              } catch (e) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('Xóa bản sao thất bại: $e')),
                                );
                              }
                            },
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final notifier =
              ref.read(bookDetailViewModelProvider(bookId).notifier);
          try {
            await notifier.addBookCopy();
          } catch (e) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Nhập kho thất bại: $e')),
            );
          }
        },
        icon: const Icon(Icons.library_add),
        label: const Text('Thêm bản sao'),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.title,
    required this.author,
    required this.subtitle,
    required this.description,
    required this.availableCopies,
    required this.totalCopies,
    required this.hasReservation,
    this.imageUrl,
  });

  final String title;
  final String author;
  final String subtitle;
  final String description;
  final int availableCopies;
  final int totalCopies;
  final bool hasReservation;  final String? imageUrl;

  Widget _buildCoverImage(ColorScheme scheme) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ClipRRect(
        child: Image.network(
          imageUrl!,
          fit: BoxFit.contain,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.menu_book, size: 64, color: scheme.outline);
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
              ),
            );
          },
        ),
      );
    }
    return Icon(Icons.menu_book, size: 64, color: scheme.outline);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // Availability status
    final (statusLabel, statusColor) = availableCopies > 0
        ? ('$availableCopies/$totalCopies sẵn sàng', Colors.green)
        : ('Hết sách', Colors.red);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 180,
              color: scheme.surfaceContainerHighest,
              child: _buildCoverImage(scheme),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and availability badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    height: 1.2,
                                  ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
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
                  const SizedBox(height: 8),
                  Text(
                    author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                  if (hasReservation) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.orange.withAlpha(25),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.withAlpha(100)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.schedule,
                              size: 16, color: Colors.orange.shade700),
                          const SizedBox(width: 6),
                          Text(
                            'Có người đặt trước',
                            style: TextStyle(
                              color: Colors.orange.shade700,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (description.trim().isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Button for making reservations when book is out of stock.
class _ReservationButton extends ConsumerWidget {
  const _ReservationButton({
    required this.bookId,
    required this.hasActiveReservation,
    required this.onReserve,
  });

  final String bookId;
  final bool hasActiveReservation;
  final Future<void> Function(String memberId) onReserve;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: () => _showReservationDialog(context, ref),
        style: FilledButton.styleFrom(
          backgroundColor: Colors.orange,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.bookmark_add),
        label: const Text('Đặt trước sách này'),
      ),
    );
  }

  Future<void> _showReservationDialog(
      BuildContext context, WidgetRef ref) async {
    final membersAsync = ref.read(allMembersProvider);

    final members = membersAsync.maybeWhen(
      data: (list) => list,
      orElse: () => <Member>[],
    );

    if (members.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không có hội viên nào trong hệ thống.')),
      );
      return;
    }

    final selectedMemberId = await showDialog<String>(
      context: context,
      builder: (ctx) => _MemberSelectionDialog(members: members),
    );

    if (selectedMemberId != null && context.mounted) {
      await onReserve(selectedMemberId);
    }
  }
}

/// Dialog to select a member for reservation.
class _MemberSelectionDialog extends StatefulWidget {
  const _MemberSelectionDialog({required this.members});

  final List<Member> members;

  @override
  State<_MemberSelectionDialog> createState() => _MemberSelectionDialogState();
}

class _MemberSelectionDialogState extends State<_MemberSelectionDialog> {
  String? _selectedMemberId;
  String _searchQuery = '';

  String _formatMemberName(Member m) {
    final parts = <String>[];
    for (final p in [m.lastName, m.middleName, m.firstName]) {
      final v = (p ?? '').trim();
      if (v.isNotEmpty) parts.add(v);
    }
    return parts.isEmpty ? m.id : parts.join(' ');
  }

  List<Member> get _filteredMembers {
    if (_searchQuery.isEmpty) return widget.members;
    final query = _searchQuery.toLowerCase();
    return widget.members.where((m) {
      final name = _formatMemberName(m).toLowerCase();
      final phone = (m.phone ?? '').toLowerCase();
      return name.contains(query) || phone.contains(query) || m.id.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.person_search, color: Colors.orange.shade700),
          const SizedBox(width: 8),
          const Text('Chọn hội viên'),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Search field
            TextField(
              decoration: InputDecoration(
                hintText: 'Tìm theo tên, SĐT hoặc mã...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
            const SizedBox(height: 16),
            // Member list
            Flexible(
              child: _filteredMembers.isEmpty
                  ? const Center(child: Text('Không tìm thấy hội viên.'))
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: _filteredMembers.length,
                      itemBuilder: (context, index) {
                        final member = _filteredMembers[index];
                        final isSelected = _selectedMemberId == member.id;
                        return ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          selected: isSelected,
                          selectedTileColor: Colors.orange.withAlpha(30),
                          leading: CircleAvatar(
                            backgroundColor: isSelected
                                ? Colors.orange
                                : Theme.of(context).colorScheme.primaryContainer,
                            child: Text(
                              _formatMemberName(member)[0].toUpperCase(),
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                              ),
                            ),
                          ),
                          title: Text(
                            _formatMemberName(member),
                            style: TextStyle(
                              fontWeight:
                                  isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          subtitle: Text(
                            '${member.id} • ${member.phone ?? 'N/A'}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          trailing: isSelected
                              ? const Icon(Icons.check_circle, color: Colors.orange)
                              : null,
                          onTap: () =>
                              setState(() => _selectedMemberId = member.id),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: _selectedMemberId == null
              ? null
              : () => Navigator.pop(context, _selectedMemberId),
          style: FilledButton.styleFrom(backgroundColor: Colors.orange),
          child: const Text('Đặt trước'),
        ),
      ],
    );
  }
}

class _CopyTile extends StatelessWidget {
  const _CopyTile({required this.copyId, required this.status, this.onDelete});

  final String copyId;
  final int status;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final s = BookCopyStatus.fromCode(status);

    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      title: Text(copyId, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: s.color.withAlpha(28),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: s.color.withAlpha(120)),
            ),
            child: Text(
              s.label,
              style: TextStyle(color: s.color, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Xóa bản sao',
            icon: const Icon(Icons.close, size: 18),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
