import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/providers/supabase_auth_provider.dart';
import '../../activity_log/data/supabase_activity_log_repository.dart';
import '../../activity_log/presentation/supabase_activity_log_page.dart';
import '../../book/presentation/book_list_page.dart';
import '../../employees/presentation/supabase_employee_list_page.dart';
import '../../loan/presentation/supabase_loan_list_page.dart';
import '../../member/presentation/member_list_page.dart';
import '../../settings/presentation/backup_restore_page.dart';
import '../data/supabase_dashboard_repository.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final stateAsync = ref.watch(supabaseDashboardStatsProvider);
    final currentEmployee = ref.watch(currentEmployeeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('BookNest'),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'Cài đặt',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
            },
            icon: const Icon(Icons.settings_outlined),
          ),
          IconButton(
            tooltip: 'Đăng xuất',
            onPressed: () => _showLogoutDialog(context, ref),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header greeting
                    Text(
                      'Xin chào${currentEmployee != null ? ', ${currentEmployee.displayName}' : ''}! 👋',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentEmployee != null
                          ? '${currentEmployee.position ?? 'Nhân viên'} • ${currentEmployee.id}'
                          : 'Chào mừng đến với BookNest',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 24), // Stats cards row
                    stateAsync.when(
                      loading: () => _buildStatsGrid(
                        context: context,
                        totalBooks: '...',
                        totalMembers: '...',
                        borrowedBooks: '...',
                        overdueLoans: '...',
                        isLoading: true,
                      ),
                      error: (e, _) => _buildStatsGrid(
                        context: context,
                        totalBooks: '!',
                        totalMembers: '!',
                        borrowedBooks: '!',
                        overdueLoans: '!',
                        isError: true,
                      ),
                      data: (stats) => _buildStatsGrid(
                        context: context,
                        totalBooks: stats.totalBooks.toString(),
                        totalMembers: stats.totalMembers.toString(),
                        borrowedBooks: stats.borrowedBooks.toString(),
                        overdueLoans: stats.overdueLoans.toString(),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Menu title
                    Text(
                      'Chức năng',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Menu grid
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.1,
                ),
                delegate: SliverChildListDelegate([
                  _MenuCard(
                    icon: Icons.people_alt_rounded,
                    title: 'Quản lý\nHội viên',
                    color: Colors.blue,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const MemberListPage(),
                        ),
                      );
                    },
                  ),
                  _MenuCard(
                    icon: Icons.library_books_rounded,
                    title: 'Quản lý\nSách',
                    color: AppTheme.warningColor,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const BookListPage(),
                        ),
                      );
                    },
                  ),
                  _MenuCard(
                    icon: Icons.output_rounded,
                    title: 'Mượn\nSách',
                    color: Colors.green,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SupabaseLoanListPage(),
                        ),
                      );
                    },
                  ),
                  _MenuCard(
                    icon: Icons.input_rounded,
                    title: 'Trả\nSách',
                    color: Colors.deepPurple,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SupabaseLoanListPage(),
                        ),
                      );
                    },
                  ), // Chỉ hiển thị nút Quản lý Nhân viên nếu là Admin
                  if (currentEmployee?.isAdmin ?? false)
                    _MenuCard(
                      icon: Icons.badge_rounded,
                      title: 'Quản lý\nNhân viên',
                      color: Colors.teal,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SupabaseEmployeeListPage(),
                          ),
                        );
                      },
                    ),
                  // Nhật ký hoạt động - chỉ hiển thị cho Quản lý
                  if (currentEmployee?.position == 'Quản lý')
                    _MenuCard(
                      icon: Icons.history_rounded,
                      title: 'Nhật ký\nhoạt động',
                      color: Colors.indigo,
                      onTap: () {
                        ref.invalidate(activityLogsProvider);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SupabaseActivityLogPage(),
                          ),
                        );
                      },
                    ),
                ]),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}

/// Build a 2x2 grid of stats cards
Widget _buildStatsGrid({
  required BuildContext context,
  required String totalBooks,
  required String totalMembers,
  required String borrowedBooks,
  required String overdueLoans,
  bool isLoading = false,
  bool isError = false,
}) {
  final scheme = Theme.of(context).colorScheme;
  // Colors for each card
  final Color booksColor = isError ? scheme.error : AppTheme.warningColor;
  final Color membersColor = isError ? scheme.error : AppTheme.primaryColor;
  final Color borrowedColor = isError ? scheme.error : AppTheme.successColor;
  final Color overdueColor = isError ? scheme.error : AppTheme.errorColor;

  return Column(
    children: [
      // Row 1: Total Books + Members
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
              icon: Icons.people_rounded,
              label: 'Hội viên',
              value: totalMembers,
              color: membersColor,
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      // Row 2: Borrowed Books + Overdue Loans
      Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.bookmark_added_rounded,
              label: 'Đang mượn',
              value: borrowedBooks,
              color: borrowedColor,
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

class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant.withAlpha(80),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Show logout confirmation dialog.
void _showLogoutDialog(BuildContext context, WidgetRef ref) {
  final currentEmployee = ref.read(currentEmployeeProvider);

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Đăng xuất'),
      content: Text(
        currentEmployee != null
            ? 'Bạn đang đăng nhập với tài khoản "${currentEmployee.fullName}".\n\nBạn có chắc chắn muốn đăng xuất?'
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
            ref.read(authProvider.notifier).logout();
          },
          child: const Text('Đăng xuất'),
        ),
      ],
    ),
  );
}
