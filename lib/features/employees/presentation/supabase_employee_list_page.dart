import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/supabase_employee_repository.dart';

/// Trang danh sách nhân viên sử dụng Supabase
class SupabaseEmployeeListPage extends ConsumerWidget {
  const SupabaseEmployeeListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employeesAsync = ref.watch(employeesSupabaseProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Nhân viên'),
        actions: [
          IconButton(
            tooltip: 'Tải lại',
            onPressed: () => ref.invalidate(employeesSupabaseProvider),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: employeesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: scheme.error),
              const SizedBox(height: 16),
              Text(
                'Đã xảy ra lỗi',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  e.toString().replaceAll('Exception: ', ''),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => ref.invalidate(employeesSupabaseProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
              ),
            ],
          ),
        ),
        data: (employees) {
          if (employees.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 80,
                    color: scheme.outlineVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có nhân viên nào',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Thêm nhân viên để bắt đầu quản lý',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: scheme.outline,
                        ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: employees.length,
            itemBuilder: (context, index) {
              final employee = employees[index];
              return _EmployeeTile(employee: employee);
            },
          );
        },
      ),
    );
  }
}

class _EmployeeTile extends StatelessWidget {
  const _EmployeeTile({required this.employee});

  final SupabaseEmployee employee;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // Màu avatar dựa trên chức vụ
    Color avatarColor;
    IconData avatarIcon;
    switch (employee.position?.toLowerCase()) {
      case 'quản lý':
      case 'quan ly':
      case 'manager':
        avatarColor = Colors.purple;
        avatarIcon = Icons.admin_panel_settings;
        break;
      case 'thủ thư':
      case 'thu thu':
      case 'librarian':
        avatarColor = Colors.teal;
        avatarIcon = Icons.local_library;
        break;
      default:
        avatarColor = Colors.blueGrey;
        avatarIcon = Icons.person;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: scheme.outlineVariant.withAlpha(50)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: avatarColor.withAlpha(30),
          child: Icon(avatarIcon, color: avatarColor),
        ),
        title: Text(
          employee.fullName,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.badge_outlined, size: 14, color: scheme.outline),
                const SizedBox(width: 4),
                Text(
                  employee.position ?? 'Chưa xác định',
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
            if (employee.username != null && employee.username!.isNotEmpty) ...[
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(Icons.account_circle_outlined, size: 14, color: scheme.outline),
                  const SizedBox(width: 4),
                  Text(
                    '@${employee.username}',
                    style: TextStyle(
                      color: scheme.outline,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            employee.id,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontFamily: 'monospace',
                ),
          ),
        ),
        onTap: () {
          // TODO: Navigate to employee detail page
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Chi tiết: ${employee.fullName}'),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 1),
            ),
          );
        },
      ),
    );
  }
}
