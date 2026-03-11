import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/auth/unified_auth_provider.dart';
import '../../activity_log/data/supabase_activity_log_repository.dart';
import '../../activity_log/presentation/supabase_activity_log_page.dart';
import '../../book/presentation/book_list_page.dart';
import '../../employees/presentation/supabase_employee_list_page.dart';
import '../../loan/presentation/supabase_borrow_book_page.dart';
import '../../loan/presentation/supabase_loan_list_page.dart';
import '../../member/presentation/member_list_page.dart';
import '../../settings/presentation/backup_restore_page.dart';
import '../data/supabase_dashboard_repository.dart';

/// Provider cho index tab hiện tại
final currentTabIndexProvider = StateProvider<int>((ref) => 0);

/// Main Admin page với Bottom Navigation Bar
class AdminMainPage extends ConsumerWidget {
  const AdminMainPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(currentTabIndexProvider);
    final currentUser = ref.watch(currentUserProvider);
    final isAdmin = currentUser?.role == UserRole.admin;

    // Xây dựng danh sách tabs dựa trên quyền
    final tabs = <Widget>[
      const AdminDashboardView(),
      const BookListPage(),
      const MemberListPage(),
      if (isAdmin)
        const _SettingsPlaceholder()
      else
        const _NoAccessPlaceholder(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: tabs,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          ref.read(currentTabIndexProvider.notifier).state = index;
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          const NavigationDestination(
            icon: Icon(Icons.book_outlined),
            selectedIcon: Icon(Icons.book),
            label: 'Sách',
          ),
          const NavigationDestination(
            icon: Icon(Icons.people_outlined),
            selectedIcon: Icon(Icons.people),
            label: 'Hội viên',
          ),
          NavigationDestination(
            icon: Icon(isAdmin ? Icons.settings_outlined : Icons.lock_outline),
            selectedIcon: Icon(isAdmin ? Icons.settings : Icons.lock),
            label: 'Cài đặt',
          ),
        ],
      ),
    );
  }
}

/// Placeholder khi không có quyền truy cập
class _NoAccessPlaceholder extends StatelessWidget {
  const _NoAccessPlaceholder();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_rounded,
              size: 80,
              color: scheme.error.withAlpha(150),
            ),
            const SizedBox(height: 16),
            Text(
              'Không có quyền truy cập',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: scheme.error,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tính năng này chỉ dành cho Quản lý',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Placeholder cho tab Cài đặt (đang phát triển)
class _SettingsPlaceholder extends StatelessWidget {
  const _SettingsPlaceholder();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction_rounded,
              size: 80,
              color: scheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Cài đặt đang phát triển',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tính năng này sẽ sớm được cập nhật',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.outline,
                  ),
            ),
            const SizedBox(height: 24),
            // Tạm thời hiển thị nút truy cập Settings cũ
            OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsPage()),
                );
              },
              icon: const Icon(Icons.settings_applications),
              label: const Text('Mở cài đặt cũ'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dashboard View cho Tab Trang chủ
class AdminDashboardView extends ConsumerWidget {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final statsAsync = ref.watch(supabaseDashboardStatsProvider);
    final isAdmin = currentUser?.role == UserRole.admin;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(supabaseDashboardStatsProvider);
            if (isAdmin) ref.invalidate(activityLogsProvider);
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header
                _buildHeader(context, ref, currentUser),
                const SizedBox(height: 24),

                // 2. Thống kê quan trọng
                _buildStatsSection(context, statsAsync),
                const SizedBox(height: 24),

                // 3. Thao tác nhanh
                _buildQuickActionsSection(context, ref, currentUser),

                // 4. Phân tích & Biểu đồ (Mockup) - Chỉ Admin
                if (isAdmin) ...[
                  const SizedBox(height: 24),
                  _buildAnalyticsSection(context),
                ],

                // 5. Hoạt động gần đây - Chỉ Admin
                if (isAdmin) ...[
                  const SizedBox(height: 24),
                  _buildRecentActivitiesSection(context, ref, currentUser),
                ],

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
  /// 1. Header với Avatar, Greeting và Notification
  Widget _buildHeader(
      BuildContext context, WidgetRef ref, AppUser? currentUser) {
    final scheme = Theme.of(context).colorScheme;
    final greeting = _getGreeting();
    final isAdmin = currentUser?.role == UserRole.admin;

    return Row(
      children: [
        // Avatar
        CircleAvatar(
          radius: 24,
          backgroundColor: scheme.primaryContainer,
          child: Text(
            currentUser != null
                ? currentUser.displayName.isNotEmpty
                    ? currentUser.displayName[0].toUpperCase()
                    : 'A'
                : 'A',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: scheme.onPrimaryContainer,
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Greeting & Title
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isAdmin ? 'Bảng điều khiển Admin' : 'Bảng điều khiển Thủ thư',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),              Text(
                '$greeting${currentUser != null ? ", ${currentUser.displayName}" : ""}! 👋',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
        // Notification & Logout buttons
        IconButton(
          onPressed: () {
            // TODO: Hiển thị thông báo
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Thông báo đang phát triển')),
            );
          },
          icon: Badge(
            smallSize: 8,
            child: Icon(Icons.notifications_outlined, color: scheme.onSurface),
          ),
        ),
        IconButton(
          tooltip: 'Đăng xuất',
          onPressed: () => _showLogoutDialog(context, ref),
          icon: Icon(Icons.logout, color: scheme.onSurface),
        ),
      ],
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Chào buổi sáng';
    if (hour < 18) return 'Chào buổi chiều';
    return 'Chào buổi tối';
  }

  /// 2. Thống kê quan trọng
  Widget _buildStatsSection(
      BuildContext context, AsyncValue<DashboardStats> statsAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Thống kê quan trọng'),
        const SizedBox(height: 12),
        statsAsync.when(
          loading: () => _buildStatsGrid(
            context: context,
            totalBooks: '...',
            borrowedBooks: '...',
            totalMembers: '...',
            overdueLoans: '...',
            isLoading: true,
          ),
          error: (e, _) => _buildStatsGrid(
            context: context,
            totalBooks: '!',
            borrowedBooks: '!',
            totalMembers: '!',
            overdueLoans: '!',
            isError: true,
          ),
          data: (stats) => _buildStatsGrid(
            context: context,
            totalBooks: stats.totalBooks.toString(),
            borrowedBooks: stats.borrowedBooks.toString(),
            totalMembers: stats.totalMembers.toString(),
            overdueLoans: stats.overdueLoans.toString(),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid({
    required BuildContext context,
    required String totalBooks,
    required String borrowedBooks,
    required String totalMembers,
    required String overdueLoans,
    bool isLoading = false,
    bool isError = false,
  }) {
    final scheme = Theme.of(context).colorScheme;

    final Color booksColor = isError ? scheme.error : AppTheme.warningColor;
    final Color borrowedColor = isError ? scheme.error : AppTheme.successColor;
    final Color membersColor = isError ? scheme.error : scheme.primary;
    final Color overdueColor = isError ? scheme.error : AppTheme.errorColor;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.menu_book_rounded,
                label: 'Tổng sách',
                value: totalBooks,
                color: booksColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.bookmark_added_rounded,
                label: 'Đang mượn',
                value: borrowedBooks,
                color: borrowedColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.people_rounded,
                label: 'Hội viên',
                value: totalMembers,
                color: membersColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.warning_amber_rounded,
                label: 'Quá hạn',
                value: overdueLoans,
                color: overdueColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
  /// 3. Thao tác nhanh
  Widget _buildQuickActionsSection(
      BuildContext context, WidgetRef ref, AppUser? currentUser) {
    final isAdmin = currentUser?.role == UserRole.admin;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Thao tác nhanh'),
        const SizedBox(height: 12),
        // Nút full-width: Tạo phiếu mượn
        _QuickActionCard(
          icon: Icons.add_circle_outline,
          title: 'Tạo phiếu mượn',
          subtitle: 'Mượn sách cho hội viên',
          color: AppTheme.successColor,
          isFullWidth: true,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SupabaseBorrowBookPage()),
            );
          },
        ),
        const SizedBox(height: 12),
        // Row 2 nút
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.assignment_return,
                title: 'Nhận trả sách',
                subtitle: 'Xử lý trả sách',
                color: AppTheme.primaryColor,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const SupabaseLoanListPage()),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            // Chỉ hiển thị nếu là Quản lý
            if (isAdmin)
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.badge_rounded,
                  title: 'Nhân viên',
                  subtitle: 'Quản lý nhân sự',
                  color: AppTheme.successColor,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const SupabaseEmployeeListPage()),
                    );
                  },
                ),
              ),
            if (!isAdmin)
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.library_books,
                  title: 'Phiếu mượn',
                  subtitle: 'Xem danh sách',
                  color: AppTheme.primaryColor,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const SupabaseLoanListPage()),
                    );
                  },
                ),
              ),
          ],
        ),
      ],
    );
  }

  /// 4. Phân tích & Biểu đồ (Mockup)
  Widget _buildAnalyticsSection(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Phân tích thư viện
        _buildSectionTitle(context, 'Phân tích thư viện'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _PlaceholderCard(
                icon: Icons.attach_money,
                title: 'Doanh thu tháng',
                value: '2.450.000đ',
                subtitle: '+12% so với tháng trước',
                color: AppTheme.successColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _PlaceholderCard(
                icon: Icons.local_fire_department,
                title: 'Thể loại hot',
                value: 'Văn học',
                subtitle: '234 lượt mượn',
                color: AppTheme.warningColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Xu hướng mượn sách
        _buildSectionTitle(context, 'Xu hướng mượn sách'),
        const SizedBox(height: 12),
        Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: scheme.outlineVariant.withAlpha(100)),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.show_chart, size: 48, color: scheme.outline),
                const SizedBox(height: 8),
                Text(
                  'Biểu đồ xu hướng',
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
                Text(
                  '(Đang phát triển)',
                  style: TextStyle(
                    color: scheme.outline,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Mục tiêu tháng
        _buildSectionTitle(context, 'Mục tiêu tháng'),
        const SizedBox(height: 12),
        _buildGoalProgress(
          context,
          title: 'Phiếu mượn mới',
          current: 85,
          target: 100,
          color: AppTheme.primaryColor,
        ),
        const SizedBox(height: 12),
        _buildGoalProgress(
          context,
          title: 'Hội viên mới',
          current: 12,
          target: 20,
          color: AppTheme.successColor,
        ),
      ],
    );
  }

  Widget _buildGoalProgress(
    BuildContext context, {
    required String title,
    required int current,
    required int target,
    required Color color,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final progress = current / target;

    return Card(
      elevation: 0,
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  '$current/$target',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: color.withAlpha(50),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              borderRadius: BorderRadius.circular(4),
              minHeight: 8,
            ),
          ],
        ),
      ),
    );
  }
  /// 5. Hoạt động gần đây - Chỉ dành cho Admin
  Widget _buildRecentActivitiesSection(
      BuildContext context, WidgetRef ref, AppUser? currentUser) {
    final scheme = Theme.of(context).colorScheme;
    final logsAsync = ref.watch(activityLogsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle(context, 'Hoạt động gần đây'),
            TextButton(
              onPressed: () {
                ref.invalidate(activityLogsProvider);
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const SupabaseActivityLogPage()),
                );
              },
              child: const Text('Xem tất cả'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        logsAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (e, _) => Card(
            elevation: 0,
            color: scheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: scheme.onErrorContainer),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Lỗi tải hoạt động',
                      style: TextStyle(color: scheme.onErrorContainer),
                    ),
                  ),
                ],
              ),
            ),
          ),
          data: (logs) {
            if (logs.isEmpty) {
              return Card(
                elevation: 0,
                color: scheme.surfaceContainerLow,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.history, size: 40, color: scheme.outline),
                        const SizedBox(height: 8),
                        Text(
                          'Chưa có hoạt động nào',
                          style: TextStyle(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            // Lấy 3 item mới nhất
            final recentLogs = logs.take(3).toList();

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentLogs.length,
              itemBuilder: (context, index) {
                final log = recentLogs[index];
                return _RecentActivityTile(log: log);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }
  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    final currentUser = ref.read(currentUserProvider);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: Text(
          currentUser != null
              ? 'Bạn đang đăng nhập với tài khoản "${currentUser.fullName}".\n\nBạn có chắc chắn muốn đăng xuất?'
              : 'Bạn có chắc chắn muốn đăng xuất?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Huỷ'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(unifiedAuthProvider.notifier).logout();
              context.go('/login');
            },
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }
}

/// Card thống kê
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: color.withAlpha(25),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withAlpha(40),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: color,
                              ),
                    ),
                  ),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                    overflow: TextOverflow.ellipsis,
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

/// Card thao tác nhanh
class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.isFullWidth = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final bool isFullWidth;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: scheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outlineVariant.withAlpha(100)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(isFullWidth ? 20 : 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: isFullWidth ? 28 : 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: scheme.outline),
            ],
          ),
        ),
      ),
    );
  }
}

/// Card placeholder cho phần Analytics
class _PlaceholderCard extends StatelessWidget {
  const _PlaceholderCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.outline,
                    fontSize: 11,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tile hiển thị hoạt động gần đây
class _RecentActivityTile extends StatelessWidget {
  const _RecentActivityTile({required this.log});

  final ActivityLog log;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final timeFormat = DateFormat('HH:mm');
    final dateFormat = DateFormat('dd/MM'); // Chọn icon và màu theo module
    IconData moduleIcon;
    Color moduleColor;
    switch (log.module) {
      case ActivityModule.muonTra:
        moduleIcon = Icons.library_books;
        moduleColor = AppTheme.primaryColor;
        break;
      case ActivityModule.viTien:
        moduleIcon = Icons.account_balance_wallet;
        moduleColor = AppTheme.successColor;
        break;
      case ActivityModule.hoiVien:
        moduleIcon = Icons.person;
        moduleColor = AppTheme.primaryColor;
        break;
      case ActivityModule.sach:
        moduleIcon = Icons.book;
        moduleColor = AppTheme.warningColor;
        break;
      case ActivityModule.nhanVien:
        moduleIcon = Icons.badge;
        moduleColor = AppTheme.successColor;
        break;
      default:
        moduleIcon = Icons.settings;
        moduleColor = AppTheme.textSecondary;
    }

    return Card(
      elevation: 0,
      color: scheme.surfaceContainerLowest,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: scheme.outlineVariant.withAlpha(80)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Icon module
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: moduleColor.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(moduleIcon, color: moduleColor, size: 20),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    log.actionType,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    log.content,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Time
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  timeFormat.format(log.createdAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.outline,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                Text(
                  dateFormat.format(log.createdAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.outline,
                        fontSize: 11,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
