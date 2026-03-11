import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../core/user_auth_provider.dart';
import '../../data/user_book_repository.dart';
import '../../data/user_social_repository.dart';

/// Viết / Xem chi tiết Review
class UserReviewPage extends ConsumerStatefulWidget {
  const UserReviewPage({super.key, required this.reviewId});

  final String reviewId;

  @override
  ConsumerState<UserReviewPage> createState() => _UserReviewPageState();
}

class _UserReviewPageState extends ConsumerState<UserReviewPage> {
  final _contentCtrl = TextEditingController();
  int _rating = 0;
  String? _selectedBookId;
  bool _isSubmitting = false;

  bool get _isNew => widget.reviewId == 'new';

  @override
  void dispose() {
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn số sao đánh giá'),
          backgroundColor: AppTheme.warningColor,
        ),
      );
      return;
    }

    if (_selectedBookId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn cuốn sách'),
          backgroundColor: AppTheme.warningColor,
        ),
      );
      return;
    }

    final member = ref.read(currentMemberProvider);
    if (member == null) return;

    setState(() => _isSubmitting = true);

    try {
      await ref.read(userSocialRepositoryProvider).createReview(
            memberId: member.id,
            bookId: _selectedBookId!,
            rating: _rating,
            content: _contentCtrl.text.trim().isEmpty
                ? null
                : _contentCtrl.text.trim(),
          );

      if (!mounted) return;

      // Invalidate feed so it refreshes
      ref.invalidate(reviewFeedProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã đăng review thành công! 🎉'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(_isNew ? 'Viết Review' : 'Chi tiết Review'),
        centerTitle: true,
        actions: _isNew
            ? [
                TextButton(
                  onPressed: _isSubmitting ? null : _handleSubmit,
                  child: const Text('Đăng',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ]
            : null,
      ),
      body: _isNew ? _buildWriteForm(context) : _buildReadView(context),
    );
  }

  Widget _buildWriteForm(BuildContext context) {
    final booksAsync = ref.watch(userBooksProvider(null));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Chọn sách
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.slate200.withAlpha(120)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Chọn sách để review',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                booksAsync.when(
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (e, _) => Text('Lỗi tải sách: $e'),                  data: (books) => DropdownButtonFormField<String>(
                    initialValue: _selectedBookId,
                    decoration: const InputDecoration(
                      hintText: 'Chọn cuốn sách...',
                      prefixIcon: Icon(Icons.menu_book),
                    ),
                    items: books
                        .map((b) => DropdownMenuItem(
                            value: b.id, child: Text(b.title)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedBookId = v),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Đánh giá sao
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.slate200.withAlpha(120)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Đánh giá của bạn',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    return GestureDetector(
                      onTap: () => setState(() => _rating = i + 1),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          i < _rating ? Icons.star : Icons.star_border,
                          size: 40,
                          color: AppTheme.warningColor,
                        ),
                      ),
                    );
                  }),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _rating == 0
                          ? 'Chạm để đánh giá'
                          : ['', 'Tệ', 'Trung bình', 'Khá', 'Hay', 'Xuất sắc'][_rating],
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppTheme.textSecondary),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Nội dung review
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.slate200.withAlpha(120)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nội dung review',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                TextField(
                  controller: _contentCtrl,
                  maxLines: 8,
                  decoration: const InputDecoration(
                    hintText: 'Chia sẻ cảm nhận của bạn về cuốn sách này...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            height: 52,
            child: FilledButton.icon(
              onPressed: _isSubmitting ? null : _handleSubmit,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.send),
              label: const Text('Đăng Review',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildReadView(BuildContext context) {
    // For read view, we just show a placeholder.
    // In a full implementation, you'd fetch the review by ID.
    return const Center(
      child: Text('Chi tiết review sẽ được hiển thị từ feed.'),
    );
  }
}
