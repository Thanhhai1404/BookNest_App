import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/auth/unified_auth_provider.dart';
import '../../core/user_auth_provider.dart';
import '../../data/user_order_repository.dart';
import '../../data/user_borrow_repository.dart';

/// Tab Cá nhân - Profile & Settings
class UserProfilePage extends ConsumerWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final member = ref.watch(currentMemberProvider);

    // Real counts for menu subtitles
    final ordersAsync = member != null
        ? ref.watch(memberOrdersProvider(member.id))
        : null;
    final borrowCountAsync = member != null
        ? ref.watch(activeBorrowCountProvider(member.id))
        : null;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: CustomScrollView(
        slivers: [
          // ==================== HEADER ====================
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
              decoration: BoxDecoration(
                color: AppTheme.cardLight,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(8),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Avatar & Name
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: AppTheme.primaryColor.withAlpha(20),
                        child: Text(
                          (member?.fullName ?? 'U')[0].toUpperCase(),
                          style: const TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              member?.fullName ?? 'Người dùng',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              member?.id ?? 'DG0000',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings_outlined,
                            color: AppTheme.textSecondary),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Stats cards row
                  Row(
                    children: [
                      _StatCard(
                        icon: Icons.shield_outlined,
                        value: '${member?.credibilityScore ?? 100}',
                        label: 'Tín nhiệm',
                        color: AppTheme.successColor,
                      ),
                      const SizedBox(width: 10),
                      _StatCard(
                        icon: Icons.account_balance_wallet_outlined,
                        value: _formatPrice(member?.walletBalance ?? 0),
                        label: 'Ví (đ)',
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 10),
                      _StatCard(
                        icon: Icons.star_outline,
                        value: '${member?.points ?? 0}',
                        label: 'Điểm',
                        color: AppTheme.warningColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Subscription badge
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: member?.hasActiveSubscription == true
                          ? LinearGradient(
                              colors: [
                                AppTheme.primaryColor.withAlpha(15),
                                AppTheme.primaryColor.withAlpha(5),
                              ],
                            )
                          : null,
                      border: Border.all(
                        color: member?.hasActiveSubscription == true
                            ? AppTheme.primaryColor.withAlpha(40)
                            : AppTheme.slate200,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.card_membership,
                          size: 20,
                          color: member?.hasActiveSubscription == true
                              ? AppTheme.primaryColor
                              : AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                member?.hasActiveSubscription == true
                                    ? 'Gói Hội Viên Active'
                                    : 'Chưa đăng ký Gói Hội Viên',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color:
                                          member?.hasActiveSubscription == true
                                              ? AppTheme.primaryColor
                                              : AppTheme.textSecondary,
                                    ),
                              ),
                              if (member?.subscriptionExpiry != null)
                                Text(
                                  'HSD: ${member!.subscriptionExpiry!.day}/${member.subscriptionExpiry!.month}/${member.subscriptionExpiry!.year}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                          color: AppTheme.textSecondary),
                                ),
                            ],
                          ),
                        ),
                        if (member?.hasActiveSubscription != true)
                          TextButton(
                            onPressed: () {},
                            child: const Text('Đăng ký',
                                style: TextStyle(fontSize: 12)),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ==================== MENU ====================
          SliverToBoxAdapter(child: const SizedBox(height: 16)),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section: Quản lý
                  _SectionLabel(label: 'Quản lý'),                  _MenuItem(
                    icon: Icons.shopping_bag_outlined,
                    title: 'Lịch sử mua sách',
                    subtitle: ordersAsync?.whenOrNull(
                      data: (orders) => '${orders.length} đơn hàng',
                    ) ?? '...',
                    onTap: () => context.push('/user/profile/purchases'),
                  ),
                  _MenuItem(
                    icon: Icons.book_outlined,
                    title: 'Lịch sử mượn sách',
                    subtitle: borrowCountAsync?.whenOrNull(
                      data: (count) => '$count đang mượn',
                    ) ?? '...',
                    onTap: () => context.push('/user/profile/borrows'),
                  ),
                  _MenuItem(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Quản lý ví',
                    subtitle: '${_formatPrice(member?.walletBalance ?? 0)}đ',
                    onTap: () => context.push('/user/profile/wallet'),
                  ),_MenuItem(
                    icon: Icons.bookmark_outline,
                    title: 'Sách yêu thích',
                    onTap: () {},
                  ),

                  const SizedBox(height: 8),
                  _SectionLabel(label: 'Tài khoản'),
                  _MenuItem(
                    icon: Icons.person_outline,
                    title: 'Chỉnh sửa hồ sơ',
                    onTap: () {},
                  ),
                  _MenuItem(
                    icon: Icons.notifications_outlined,
                    title: 'Thông báo',
                    onTap: () {},
                  ),
                  _MenuItem(
                    icon: Icons.help_outline,
                    title: 'Trợ giúp & Hỗ trợ',
                    onTap: () {},
                  ),

                  const SizedBox(height: 8),                  // Đăng xuất
                  _MenuItem(
                    icon: Icons.logout,
                    title: 'Đăng xuất',
                    iconColor: AppTheme.errorColor,
                    titleColor: AppTheme.errorColor,
                    onTap: () {
                      ref.read(unifiedAuthProvider.notifier).logout();
                      context.go('/login');
                    },
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
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

// ==================== SUB-COMPONENTS ====================

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withAlpha(12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(30)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 6),
            Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold, color: color),
            ),
            Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: AppTheme.textSecondary, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.iconColor,
    this.titleColor,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: AppTheme.cardLight,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: (iconColor ?? AppTheme.primaryColor).withAlpha(12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon,
              size: 20, color: iconColor ?? AppTheme.primaryColor),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: titleColor,
              ),
        ),
        subtitle: subtitle != null
            ? Text(subtitle!,
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: AppTheme.textSecondary))
            : null,
        trailing: Icon(Icons.chevron_right,
            size: 20, color: AppTheme.textSecondary.withAlpha(150)),
      ),
    );
  }
}
