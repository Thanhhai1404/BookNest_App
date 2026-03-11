import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/providers/supabase_auth_provider.dart';
import '../../../data/db/app_database.dart';
import '../../loan/presentation/loan_view_model.dart';
import 'book_detail_view_model.dart';

/// Status enum cho sách
enum BookCopyStatus {
  available(0, 'Sẵn sàng', AppTheme.successColor),
  borrowed(1, 'Đang mượn', AppTheme.errorColor),
  reserved(2, 'Đã đặt trước', AppTheme.warningColor),
  damaged(3, 'Hỏng/Mất', AppTheme.textSecondary);

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
        title: const Text('Book Details'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              // TODO: Share functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Chia sẻ đang phát triển')),
              );
            },
          ),
          // Chỉ hiển thị nút Xóa nếu là Admin
          if (isAdmin)
            IconButton(
              tooltip: 'Xóa sách',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _showDeleteBookDialog(context, ref),
            ),
        ],
      ),
      body: stateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => _buildErrorState(context, ref, e),
        data: (state) => _buildBookDetailContent(context, ref, state, isAdmin),
      ),
      // FAB chỉ hiển thị cho Admin
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => _addBookCopy(context, ref),
              icon: const Icon(Icons.library_add),
              label: const Text('Thêm bản sao'),
            )
          : null,
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object e) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppTheme.errorColor),
            const SizedBox(height: 16),
            Text('Lỗi: $e'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  ref.invalidate(bookDetailViewModelProvider(bookId)),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookDetailContent(
    BuildContext context,
    WidgetRef ref,
    BookDetailState state,
    bool isAdmin,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final title = state.bookTitle.title.isNotEmpty
        ? state.bookTitle.title
        : state.bookTitle.id;
    final author = state.authorName;
    final description = state.bookTitle.description ?? '';
    final imageUrl = state.bookTitle.imageUrl;
    final categoryName = state.categoryName;
    final availableCopies = state.availableCopiesCount;
    final totalCopies = state.copies.length;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Book Cover Image
                _buildCoverSection(context, imageUrl, scheme),

                // 2. Title & Rating
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimaryLight,
                              ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Rating badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withAlpha(20),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star,
                                size: 16, color: AppTheme.primaryColor),
                            const SizedBox(width: 4),
                            Text(
                              '4.8', // Placeholder rating
                              style: TextStyle(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 3. Author
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                  child: Text(
                    'by $author',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),

                // 4. Info Row (Genre, Pages, Language)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                            color: scheme.outlineVariant.withAlpha(100)),
                        bottom: BorderSide(
                            color: scheme.outlineVariant.withAlpha(100)),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _InfoColumn(
                            label: 'GENRE',
                            value:
                                categoryName.isNotEmpty ? categoryName : 'N/A',
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: scheme.outlineVariant.withAlpha(100),
                        ),
                        Expanded(
                          child: _InfoColumn(
                            label: 'PAGES',
                            value: '${totalCopies > 0 ? totalCopies : "—"}',
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: scheme.outlineVariant.withAlpha(100),
                        ),
                        Expanded(
                          child: _InfoColumn(
                            label: 'LANGUAGE',
                            value: 'Tiếng Việt',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 5. Synopsis
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Synopsis',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        description.isNotEmpty
                            ? description
                            : 'Chưa có mô tả cho sách này.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondary,
                              height: 1.6,
                            ),
                      ),
                    ],
                  ),
                ),

                // 6. Action Buttons (Borrow Now, Add to Wishlist)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                  child: Column(
                    children: [
                      // Borrow Now button
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: availableCopies > 0
                              ? () => _showBorrowDialog(context, ref, state)
                              : null,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                AppTheme.primaryColor.withAlpha(100),
                            disabledForegroundColor: Colors.white70,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            availableCopies > 0 ? 'Borrow Now' : 'Out of Stock',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Add to Wishlist button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _handleWishlist(context, ref, state),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.primaryColor,
                            side: BorderSide(
                                color: AppTheme.primaryColor.withAlpha(100)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: Icon(
                            state.hasActiveReservation
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            color: AppTheme.primaryColor,
                          ),
                          label: Text(
                            state.hasActiveReservation
                                ? 'Already Reserved'
                                : 'Add to Wishlist',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 7. Admin Section: Book Copies Management
                if (isAdmin) ...[
                  const Divider(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Icon(Icons.inventory_2_outlined, color: scheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Quản lý bản sao ($availableCopies/$totalCopies sẵn)',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (state.copies.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.inventory_2_outlined,
                                size: 48, color: scheme.outline),
                            const SizedBox(height: 8),
                            Text(
                              'Chưa có bản sao nào',
                              style: TextStyle(color: scheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...state.copies.map((c) => Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 4),
                          child: _CopyTile(
                            copyId: c.barcode,
                            status: c.status,
                            onDelete: () =>
                                _deleteCopy(context, ref, c.barcode),
                          ),
                        )),
                  const SizedBox(height: 80), // Space for FAB
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCoverSection(
      BuildContext context, String? imageUrl, ColorScheme scheme) {
    return Container(
      height: 300,
      width: double.infinity,
      color: AppTheme.backgroundLight,
      child: Center(
        child: Container(
          height: 220,
          width: 150,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(40),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: imageUrl != null && imageUrl.isNotEmpty
              ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildPlaceholderCover(scheme);
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
                )
              : _buildPlaceholderCover(scheme),
        ),
      ),
    );
  }

  Widget _buildPlaceholderCover(ColorScheme scheme) {
    return Container(
      color: scheme.surfaceContainerHighest,
      child: Icon(Icons.menu_book, size: 48, color: scheme.outline),
    );
  }

  void _showBorrowDialog(
      BuildContext context, WidgetRef ref, BookDetailState state) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chức năng mượn sách đang phát triển')),
    );
  }

  void _handleWishlist(
      BuildContext context, WidgetRef ref, BookDetailState state) {
    if (state.hasActiveReservation) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sách đã được đặt trước')),
      );
      return;
    } // Show member selection dialog for reservation
    showDialog(
      context: context,
      builder: (ctx) => _MemberSelectionDialog(
        members: ref.read(allMembersProvider).maybeWhen(
              data: (members) => members,
              orElse: () => [],
            ),
        onSelect: (memberId) async {
          Navigator.pop(ctx);
          try {
            await ref
                .read(bookDetailViewModelProvider(bookId).notifier)
                .createReservation(memberId);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Đặt trước thành công!'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Lỗi: $e'),
                  backgroundColor: AppTheme.errorColor,
                ),
              );
            }
          }
        },
      ),
    );
  }

  Future<void> _showDeleteBookDialog(
      BuildContext context, WidgetRef ref) async {
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
              backgroundColor: AppTheme.errorColor,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    try {
      await ref.read(bookDetailViewModelProvider(bookId).notifier).deleteBook();
      if (!context.mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xóa sách thất bại: $e')),
      );
    }
  }

  Future<void> _addBookCopy(BuildContext context, WidgetRef ref) async {
    try {
      await ref
          .read(bookDetailViewModelProvider(bookId).notifier)
          .addBookCopy();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nhập kho thất bại: $e')),
      );
    }
  }

  Future<void> _deleteCopy(
      BuildContext context, WidgetRef ref, String barcode) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa bản sao?'),
        content: Text('Xóa bản sao $barcode này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          FilledButton.tonal(
            style: FilledButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: AppTheme.errorColor,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    try {
      await ref
          .read(bookDetailViewModelProvider(bookId).notifier)
          .deleteCopy(barcode);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xóa bản sao thất bại: $e')),
      );
    }
  }
}

/// Info column widget for Genre/Pages/Language
class _InfoColumn extends StatelessWidget {
  const _InfoColumn({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
                letterSpacing: 1,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

/// Copy Tile for admin management
class _CopyTile extends StatelessWidget {
  const _CopyTile({required this.copyId, required this.status, this.onDelete});

  final String copyId;
  final int status;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final copyStatus = BookCopyStatus.fromCode(status);
    final scheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: copyStatus.color.withAlpha(25),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.qr_code_2, color: copyStatus.color),
        ),
        title: Text(
          copyId,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        subtitle: Text(
          copyStatus.label,
          style: TextStyle(color: copyStatus.color, fontSize: 12),
        ),
        trailing: onDelete != null
            ? IconButton(
                icon: Icon(Icons.delete_outline, color: scheme.error),
                onPressed: onDelete,
              )
            : null,
      ),
    );
  }
}

/// Member Selection Dialog for reservations
class _MemberSelectionDialog extends StatefulWidget {
  const _MemberSelectionDialog({required this.members, required this.onSelect});

  final List<Member> members;
  final void Function(String memberId) onSelect;

  @override
  State<_MemberSelectionDialog> createState() => _MemberSelectionDialogState();
}

class _MemberSelectionDialogState extends State<_MemberSelectionDialog> {
  String _query = '';
  String? _selectedMemberId;

  /// Get full name from Member (drift class doesn't have fullName getter)
  String _getMemberFullName(Member m) {
    final parts = [m.lastName, m.middleName, m.firstName]
        .where((e) => (e ?? '').trim().isNotEmpty)
        .map((e) => e!.trim())
        .toList();
    return parts.isEmpty ? m.id : parts.join(' ');
  }

  List<Member> get _filteredMembers {
    if (_query.isEmpty) return widget.members;
    final q = _query.toLowerCase();
    return widget.members.where((m) {
      final name = _getMemberFullName(m).toLowerCase();
      final phone = (m.phone ?? '').toLowerCase();
      return name.contains(q) ||
          phone.contains(q) ||
          m.id.toLowerCase().contains(q);
    }).toList();
  }

  String _formatMemberName(Member m) {
    final name = _getMemberFullName(m);
    return name.isNotEmpty ? name : m.id;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.person_search, color: AppTheme.primaryColor),
          const SizedBox(width: 8),
          const Text('Chọn hội viên'),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Tìm theo tên, SĐT...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 300,
              child: _filteredMembers.isEmpty
                  ? const Center(child: Text('Không tìm thấy'))
                  : ListView.builder(
                      itemCount: _filteredMembers.length,
                      itemBuilder: (context, index) {
                        final member = _filteredMembers[index];
                        final isSelected = _selectedMemberId == member.id;
                        return ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          selected: isSelected,
                          selectedTileColor:
                              AppTheme.primaryColor.withAlpha(20),
                          leading: CircleAvatar(
                            backgroundColor: isSelected
                                ? AppTheme.primaryColor
                                : Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
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
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          subtitle: Text(
                            '${member.id} • ${member.phone ?? 'N/A'}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          trailing: isSelected
                              ? Icon(Icons.check_circle,
                                  color: AppTheme.primaryColor)
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
              : () => widget.onSelect(_selectedMemberId!),
          child: const Text('Đặt trước'),
        ),
      ],
    );
  }
}
