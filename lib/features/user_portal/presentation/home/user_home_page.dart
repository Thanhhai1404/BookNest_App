import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../core/user_auth_provider.dart';
import '../../data/user_book_repository.dart';

/// Trang chủ User Portal - Khám phá sách
/// 
/// Soft UI Evolution - Elegant shadows, improved spacing, 
/// enhanced typography hierarchy with red brand colors.
class UserHomePage extends ConsumerStatefulWidget {
  const UserHomePage({super.key});

  @override
  ConsumerState<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends ConsumerState<UserHomePage> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final member = ref.watch(currentMemberProvider);
    final newBooksAsync = ref.watch(newBooksProvider);
    final popularBooksAsync = ref.watch(popularBooksProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final filteredBooksAsync = ref.watch(userBooksProvider(_selectedCategory));

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: CustomScrollView(
        slivers: [
          // ==================== APP BAR ====================
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: AppTheme.cardLight,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            shadowColor: Colors.transparent,
            title: Row(
              children: [
                // Soft Logo Container
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withAlpha(15),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withAlpha(20),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.menu_book_rounded,
                    size: 22,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'BookNest',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryColor,
                        letterSpacing: -0.5,
                      ),
                ),
              ],
            ),
            actions: [
              // Soft Icon Buttons
              _SoftIconButton(
                icon: Icons.search_rounded,
                onPressed: () => _showSearchDialog(context),
              ),
              _SoftIconButton(
                icon: Icons.notifications_none_rounded,
                onPressed: () {},
                showBadge: true,
              ),
              const SizedBox(width: 12),
            ],
          ),

          // ==================== GREETING BANNER ====================
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    AppTheme.primaryColor,
                    Color(0xFFE60A0A),
                    Color(0xFFD00808),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [0.0, 0.5, 1.0],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  // Primary soft shadow
                  BoxShadow(
                    color: AppTheme.primaryColor.withAlpha(50),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                    spreadRadius: 0,
                  ),
                  // Secondary glow
                  BoxShadow(
                    color: AppTheme.primaryColor.withAlpha(30),
                    blurRadius: 40,
                    offset: const Offset(0, 4),
                    spreadRadius: -4,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting with enhanced typography
                  Text(
                    'Xin chào${member != null ? ', ${member.firstName ?? member.fullName}' : ''}! 👋',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Khám phá hàng ngàn cuốn sách hay đang chờ bạn',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withAlpha(210),
                          fontWeight: FontWeight.w400,
                          height: 1.4,
                        ),
                  ),
                  const SizedBox(height: 20),
                  // Soft Search bar
                  GestureDetector(
                    onTap: () => _showSearchDialog(context),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(30),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withAlpha(20),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          Icon(
                            Icons.search_rounded,
                            color: Colors.white.withAlpha(200),
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Tìm kiếm sách, tác giả...',
                            style: TextStyle(
                              color: Colors.white.withAlpha(170),
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ==================== CATEGORY CHIPS ====================
          SliverToBoxAdapter(
            child: SizedBox(
              height: 52,
              child: categoriesAsync.when(
                data: (categories) {
                  final all = ['Tất cả', ...categories];
                  return ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: all.map((cat) {
                      final isAll = cat == 'Tất cả';
                      final isSelected = isAll
                          ? _selectedCategory == null
                          : _selectedCategory == cat;
                      return _SoftCategoryChip(
                        label: cat,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() {
                            _selectedCategory = isAll ? null : cat;
                          });
                        },
                      );
                    }).toList(),
                  );
                },
                loading: () => const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 8)),          // ==================== SÁCH MỚI ====================
          SliverToBoxAdapter(
            child: _SectionHeader(title: 'Sách mới nhất', icon: Icons.auto_awesome, onViewAll: () {}),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 300,
              child: newBooksAsync.when(
                data: (books) {
                  if (books.isEmpty) {
                    return const Center(child: Text('Chưa có sách nào'));
                  }
                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: books.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      final book = books[index];
                      return _SoftBookCard(
                        title: book.title,
                        author: book.authorString,
                        imageUrl: book.imageUrl,
                        imageHue: (index * 40.0) + 10,
                        onTap: () => context.push('/user/book/${book.id}'),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Lỗi: $e')),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 8)),

          // ==================== SÁCH HOT ====================
          SliverToBoxAdapter(
            child: _SectionHeader(title: 'Đang Hot', icon: Icons.local_fire_department_rounded, isHot: true, onViewAll: () {}),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 300,
              child: popularBooksAsync.when(
                data: (books) {
                  if (books.isEmpty) {
                    return const Center(child: Text('Chưa có sách nào'));
                  }
                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: books.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      final book = books[index];
                      return _SoftBookCard(
                        title: book.title,
                        author: book.authorString,
                        imageUrl: book.imageUrl,
                        imageHue: (index * 50.0) + 100,
                        onTap: () => context.push('/user/book/${book.id}'),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Lỗi: $e')),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 8)),

          // ==================== FOR YOU (filtered/all books) ====================
          SliverToBoxAdapter(
            child: _SectionHeader(
              title: _selectedCategory != null
                  ? 'Thể loại: $_selectedCategory'
                  : 'Dành cho bạn',
              icon: Icons.favorite_rounded,
              onViewAll: () {},
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: filteredBooksAsync.when(
              data: (books) {
                if (books.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 48,
                              color: AppTheme.textSecondary,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Không tìm thấy sách nào',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                return SliverList.separated(
                  itemCount: books.length > 10 ? 10 : books.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final book = books[index];
                    return _SoftBookListTile(
                      title: book.title,
                      author: book.authorString,
                      rating: book.avgRating,
                      imageUrl: book.imageUrl,
                      imageHue: (index * 60.0) + 200,
                      onTap: () => context.push('/user/book/${book.id}'),
                    );
                  },
                );
              },
              loading: () => const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
              error: (e, _) => SliverToBoxAdapter(
                child: Center(child: Text('Lỗi: $e')),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withAlpha(15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.search_rounded,
                color: AppTheme.primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Tìm kiếm sách'),
          ],
        ),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Nhập tên sách hoặc tác giả...',
            hintStyle: TextStyle(color: AppTheme.textSecondary.withAlpha(150)),
            prefixIcon: const Icon(Icons.book_outlined, color: AppTheme.textSecondary),
            filled: true,
            fillColor: AppTheme.backgroundLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Hủy',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ref.invalidate(userBooksProvider);
            },
            child: const Text('Tìm kiếm'),
          ),
        ],
      ),
    );
  }
}

// ==================== SOFT UI COMPONENTS ====================

/// Soft Icon Button with subtle background
class _SoftIconButton extends StatelessWidget {
  const _SoftIconButton({
    required this.icon,
    required this.onPressed,
    this.showBadge = false,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Stack(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.slate200.withAlpha(80),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(icon, size: 22),
              color: AppTheme.textPrimaryLight,
              onPressed: onPressed,
              padding: EdgeInsets.zero,
            ),
          ),
          if (showBadge)
            Positioned(
              right: 6,
              top: 6,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.cardLight, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Soft Category Chip with elegant shadows
class _SoftCategoryChip extends StatelessWidget {
  const _SoftCategoryChip({
    required this.label,
    this.isSelected = false,
    this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor : AppTheme.cardLight,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected
                  ? AppTheme.primaryColor
                  : AppTheme.slate200.withAlpha(150),
              width: 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.primaryColor.withAlpha(35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withAlpha(8),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppTheme.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 14,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ),
    );
  }
}

/// Section Header with icon
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.icon,
    this.isHot = false,
    this.onViewAll,
  });

  final String title;
  final IconData? icon;
  final bool isHot;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isHot
                        ? AppTheme.warningColor.withAlpha(20)
                        : AppTheme.primaryColor.withAlpha(15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: isHot ? AppTheme.warningColor : AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
              ),
            ],
          ),
          if (onViewAll != null)
            GestureDetector(
              onTap: onViewAll,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withAlpha(10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Xem tất cả',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 12,
                      color: AppTheme.primaryColor,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Soft Book Card with elegant shadow
class _SoftBookCard extends StatelessWidget {
  const _SoftBookCard({
    required this.title,
    required this.author,
    required this.imageHue,
    this.imageUrl,
    this.onTap,
  });

  final String title;
  final String author;
  final double imageHue;
  final String? imageUrl;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 150,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Image with soft shadow
            Container(
              height: 200,
              width: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    HSLColor.fromAHSL(1, imageHue % 360, 0.45, 0.55).toColor(),
                    HSLColor.fromAHSL(1, (imageHue + 30) % 360, 0.5, 0.4).toColor(),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: HSLColor.fromAHSL(0.25, imageHue % 360, 0.4, 0.5).toColor(),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withAlpha(15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: imageUrl != null && imageUrl!.isNotEmpty
                    ? Image.network(
                        imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Center(
                          child: Icon(
                            Icons.menu_book_rounded,
                            size: 44,
                            color: Colors.white.withAlpha(200),
                          ),
                        ),
                      )
                    : Center(
                        child: Icon(
                          Icons.menu_book_rounded,
                          size: 44,
                          color: Colors.white.withAlpha(200),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 10),
            // Title with improved typography - use Flexible to prevent overflow
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimaryLight,
                          height: 1.2,
                          letterSpacing: -0.2,
                        ),
                  ),
                  const SizedBox(height: 4),
                  // Author
                  Text(
                    author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Soft Book List Tile with elegant card styling
class _SoftBookListTile extends StatelessWidget {
  const _SoftBookListTile({
    required this.title,
    required this.author,
    required this.rating,
    required this.imageHue,
    this.imageUrl,
    this.onTap,
  });

  final String title;
  final String author;
  final double rating;
  final double imageHue;
  final String? imageUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.cardLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.slate200.withAlpha(100),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withAlpha(4),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            // Mini cover with soft shadow
            Container(
              width: 60,
              height: 85,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                  colors: [
                    HSLColor.fromAHSL(1, imageHue % 360, 0.45, 0.55).toColor(),
                    HSLColor.fromAHSL(1, (imageHue + 30) % 360, 0.5, 0.4).toColor(),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: HSLColor.fromAHSL(0.2, imageHue % 360, 0.4, 0.5).toColor(),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: imageUrl != null && imageUrl!.isNotEmpty
                    ? Image.network(
                        imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.menu_book_rounded,
                          color: Colors.white70,
                          size: 26,
                        ),
                      )
                    : const Icon(
                        Icons.menu_book_rounded,
                        color: Colors.white70,
                        size: 26,
                      ),
              ),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                          height: 1.3,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 8),
                  // Rating badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.warningColor.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: AppTheme.warningColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          rating > 0 ? rating.toStringAsFixed(1) : 'Chưa có',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.warningColor,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Bookmark button
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.slate200.withAlpha(60),
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.bookmark_border_rounded,
                  color: AppTheme.textSecondary,
                  size: 20,
                ),
                onPressed: () {},
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
