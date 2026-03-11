// ignore_for_file: dead_code
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/user_book_repository.dart';
import '../../data/user_social_repository.dart';

/// Chi tiết sách - User Portal
class UserBookDetailPage extends ConsumerWidget {
  const UserBookDetailPage({super.key, required this.bookId});

  final String bookId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookAsync = ref.watch(userBookDetailProvider(bookId));
    final ratingAsync = ref.watch(bookRatingStatsProvider(bookId));

    return bookAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Lỗi: $e')),
      ),
      data: (book) {
        if (book == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Không tìm thấy sách')),
          );
        }

        final avgRating = ratingAsync.valueOrNull?['avg'] as double? ?? 0.0;
        final reviewCount = ratingAsync.valueOrNull?['count'] as int? ?? 0;
        final saleAvailable = book.canBuy;
        final rentAvailable = book.canBorrow;

        return Scaffold(
          backgroundColor: AppTheme.backgroundLight,
          body: Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    // ==================== SLIVER APP BAR ====================
                    SliverAppBar(
                      expandedHeight: 320,
                      pinned: true,
                      backgroundColor: AppTheme.cardLight,
                      leading: _CircleBackButton(onTap: () => context.pop()),
                      actions: [
                        _CircleIconButton(icon: Icons.share_outlined, onTap: () {}),
                        const SizedBox(width: 8),
                        _CircleIconButton(icon: Icons.bookmark_border, onTap: () {}),
                        const SizedBox(width: 12),
                      ],
                      flexibleSpace: FlexibleSpaceBar(
                        background: _CoverSection(bookId: bookId, imageUrl: book.imageUrl),
                      ),
                    ),

                    // ==================== CONTENT ====================
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title & Rating
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    book.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                _RatingBadge(rating: avgRating),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Author
                            Text(
                              'by ${book.authorString}',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                            const SizedBox(height: 20),

                            // Info Row
                            _InfoRow(
                              category: book.categoryName ?? 'Chưa phân loại',
                              publisher: book.publisherName ?? 'Không rõ',
                              year: book.publishYear?.toString() ?? '---',
                            ),
                            const SizedBox(height: 24),

                            // Price Tag
                            if (book.salePrice != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withAlpha(15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.sell_outlined,
                                        size: 20, color: AppTheme.primaryColor),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Giá bán: ${_formatPrice(book.salePrice!)}đ',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            color: AppTheme.primaryColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: (rentAvailable
                                                ? AppTheme.successColor
                                                : AppTheme.errorColor)
                                            .withAlpha(25),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        rentAvailable ? 'Có thể mượn' : 'Hết sách mượn',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: rentAvailable
                                              ? AppTheme.successColor
                                              : AppTheme.errorColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],

                            // Synopsis
                            if (book.description != null && book.description!.isNotEmpty) ...[
                              Text(
                                'Giới thiệu',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                book.description!,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppTheme.textSecondary,
                                      height: 1.7,
                                    ),
                              ),
                              const SizedBox(height: 24),
                            ],

                            // Community Rating Preview
                            _RatingPreview(
                              avgRating: avgRating,
                              reviewCount: reviewCount,
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),              // ==================== BOTTOM ACTION BUTTONS ====================
              _BottomActionBar(
                canBuy: saleAvailable,
                canBorrow: rentAvailable,
                onBuy: saleAvailable
                    ? () => context.push('/user/book/$bookId/buy')
                    : null,
                onBorrow: rentAvailable
                    ? () => context.push('/user/book/$bookId/borrow')
                    : null,
              ),
            ],
          ),
        );
      },
    );
  }

  static String _formatPrice(int price) {
    final str = price.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
    }
    return buffer.toString();
  }
}

// ==================== COMPONENTS ====================

class _CircleBackButton extends StatelessWidget {
  const _CircleBackButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(30),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(30),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

class _CoverSection extends StatelessWidget {
  const _CoverSection({required this.bookId, this.imageUrl});
  final String bookId;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withAlpha(30),
            AppTheme.backgroundLight,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Container(
          height: 220,
          width: 150,
          margin: const EdgeInsets.only(top: 40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(40),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: imageUrl != null && imageUrl!.isNotEmpty
                ? Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Center(
                        child: Icon(Icons.menu_book, size: 48,
                            color: Colors.white.withAlpha(200)),
                      ),
                    ),
                  )
                : Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Icon(Icons.menu_book, size: 48,
                          color: Colors.white.withAlpha(200)),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _RatingBadge extends StatelessWidget {
  const _RatingBadge({required this.rating});
  final double rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 16, color: AppTheme.primaryColor),
          const SizedBox(width: 4),
          Text(
            rating > 0 ? rating.toStringAsFixed(1) : '—',
            style: const TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.category,
    required this.publisher,
    required this.year,
  });

  final String category;
  final String publisher;
  final String year;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(
            color: AppTheme.slate200.withAlpha(120),
          ),
        ),
      ),
      child: Row(
        children: [
          _InfoCol(label: 'THỂ LOẠI', value: category),
          _Divider(),
          _InfoCol(label: 'NXB', value: publisher),
          _Divider(),
          _InfoCol(label: 'NĂM XB', value: year),
        ],
      ),
    );
  }
}

class _InfoCol extends StatelessWidget {
  const _InfoCol({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.8,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      color: AppTheme.slate200.withAlpha(120),
    );
  }
}

class _RatingPreview extends StatelessWidget {
  const _RatingPreview({
    this.avgRating = 0.0,
    this.reviewCount = 0,
  });

  final double avgRating;
  final int reviewCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.slate200.withAlpha(120)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Đánh giá từ cộng đồng',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                child: const Text('Xem tất cả'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (reviewCount == 0)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'Chưa có đánh giá nào. Hãy là người đầu tiên!',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
              ),
            )
          else ...[
            Row(
              children: [
                Text(
                  avgRating.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.warningColor,
                      ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: List.generate(5, (i) => Icon(
                        i < avgRating.round() ? Icons.star : Icons.star_border,
                        size: 16,
                        color: AppTheme.warningColor,
                      )),
                    ),
                    Text(
                      '$reviewCount đánh giá',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({
    this.onBuy,
    this.onBorrow,
    this.canBorrow = true,
    this.canBuy = true,
  });

  final VoidCallback? onBuy;
  final VoidCallback? onBorrow;
  final bool canBorrow;
  final bool canBuy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      decoration: BoxDecoration(
        color: AppTheme.cardLight,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Mượn sách
          Expanded(
            child: OutlinedButton.icon(
              onPressed: canBorrow ? onBorrow : null,
              style: OutlinedButton.styleFrom(
                foregroundColor: canBorrow ? AppTheme.primaryColor : AppTheme.textSecondary,
                side: BorderSide(
                  color: canBorrow ? AppTheme.primaryColor : AppTheme.slate200,
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                disabledForegroundColor: AppTheme.textSecondary.withAlpha(150),
              ),
              icon: Icon(
                canBorrow ? Icons.book_outlined : Icons.block,
                size: 18,
              ),
              label: Text(
                canBorrow ? 'Mượn sách' : 'Tạm hết sách',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Mua sách
          Expanded(
            child: FilledButton.icon(
              onPressed: canBuy ? onBuy : null,
              style: FilledButton.styleFrom(
                backgroundColor: canBuy ? AppTheme.primaryColor : AppTheme.slate200,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                disabledBackgroundColor: AppTheme.slate200,
                disabledForegroundColor: AppTheme.textSecondary,
              ),
              icon: Icon(
                canBuy ? Icons.shopping_cart_outlined : Icons.block,
                size: 18,
              ),
              label: Text(
                canBuy ? 'Mua sách' : 'Tạm hết sách',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
