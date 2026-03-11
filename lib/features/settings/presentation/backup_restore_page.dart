import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/backup_repository.dart';

/// Provider for database info
final databaseInfoProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) {
  return ref.watch(backupRepositoryProvider).getDatabaseInfo();
});

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _isBackingUp = false;
  bool _isRestoring = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dbInfoAsync = ref.watch(databaseInfoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- Database Info Section ---
          _SectionHeader(
            icon: Icons.storage,
            title: 'Thông tin Cơ sở dữ liệu',
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: dbInfoAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (e, _) => Text('Lỗi: $e'),
                data: (info) => Column(
                  children: [
                    _InfoRow(
                      label: 'Trạng thái',
                      value: info['exists'] == true
                          ? 'Hoạt động'
                          : 'Không tìm thấy',
                      valueColor:
                          info['exists'] == true ? Colors.green : Colors.red,
                    ),
                    if (info['exists'] == true) ...[
                      const Divider(height: 16),
                      _InfoRow(
                        label: 'Dung lượng',
                        value:
                            BackupRepository.formatFileSize(info['size'] ?? 0),
                      ),
                      const Divider(height: 16),
                      _InfoRow(
                        label: 'Cập nhật lần cuối',
                        value: info['lastModified'] != null
                            ? DateFormat('dd/MM/yyyy HH:mm')
                                .format(info['lastModified'])
                            : '-',
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // --- Backup & Restore Section ---
          _SectionHeader(
            icon: Icons.backup,
            title: 'Sao lưu & Khôi phục',
            color: theme.colorScheme.tertiary,
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                // Backup button
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.cloud_upload,
                      color: Colors.green.shade700,
                    ),
                  ),
                  title: const Text('Sao lưu ngay'),
                  subtitle: const Text('Xuất dữ liệu ra file để lưu trữ'),
                  trailing: _isBackingUp
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          Icons.chevron_right,
                          color: theme.colorScheme.outline,
                        ),
                  onTap: _isBackingUp ? null : _performBackup,
                ),
                const Divider(height: 1), // Restore button
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.warningColor.withAlpha(50),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.cloud_download,
                      color: AppTheme.warningColor,
                    ),
                  ),
                  title: const Text('Khôi phục dữ liệu'),
                  subtitle: const Text('Nhập dữ liệu từ file sao lưu'),
                  trailing: _isRestoring
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          Icons.chevron_right,
                          color: theme.colorScheme.outline,
                        ),
                  onTap: _isRestoring ? null : _confirmRestore,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16), // Warning note
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.warningColor.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.warningColor.withAlpha(100)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline,
                    color: AppTheme.warningColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Khuyến nghị: Sao lưu dữ liệu định kỳ mỗi ngày để tránh mất dữ liệu quan trọng.',
                    style: TextStyle(
                      color: AppTheme.warningColor,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // --- App Info Section ---
          _SectionHeader(
            icon: Icons.info_outline,
            title: 'Thông tin ứng dụng',
            color: theme.colorScheme.secondary,
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.local_library),
                  title: const Text('BookNest'),
                  subtitle: const Text('Phiên bản 0.1.0'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.code),
                  title: const Text('Database Schema'),
                  subtitle: const Text('Version 5'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _performBackup() async {
    setState(() => _isBackingUp = true);

    try {
      final repo = ref.read(backupRepositoryProvider);
      final result = await repo.backupDatabase();

      if (!mounted) return;

      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text(result.message ?? 'Sao lưu thành công!')),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Refresh database info
        ref.invalidate(databaseInfoProvider);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text(result.message ?? 'Sao lưu thất bại!')),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isBackingUp = false);
      }
    }
  }

  Future<void> _confirmRestore() async {
    // Show dangerous warning dialog
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.warning_amber_rounded,
            size: 48,
            color: Colors.red.shade700,
          ),
        ),
        title: const Text(
          '⚠️ CẢNH BÁO QUAN TRỌNG ⚠️',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade300, width: 2),
              ),
              child: Column(
                children: [
                  Text(
                    'TOÀN BỘ DỮ LIỆU HIỆN TẠI SẼ BỊ XOÁ!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '• Tất cả hội viên\n'
                    '• Tất cả sách và bản sao\n'
                    '• Tất cả phiếu mượn\n'
                    '• Tất cả giao dịch & phạt\n'
                    '• Tất cả đặt trước',
                    style: TextStyle(
                      color: Colors.red.shade900,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Dữ liệu sẽ được thay thế bằng file sao lưu bạn chọn.\n\n'
              'Hành động này KHÔNG THỂ HOÀN TÁC!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Huỷ bỏ'),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('TÔI HIỂU, TIẾP TỤC'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Second confirmation
    final doubleConfirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận lần cuối'),
        content: const Text(
          'Bạn có chắc chắn muốn khôi phục dữ liệu?\n\n'
          'Sau khi hoàn tất, ứng dụng cần được khởi động lại.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Huỷ'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );

    if (doubleConfirmed != true || !mounted) return;

    await _performRestore();
  }

  Future<void> _performRestore() async {
    setState(() => _isRestoring = true);

    try {
      final repo = ref.read(backupRepositoryProvider);
      final result = await repo.restoreDatabase();

      if (!mounted) return;

      if (result.success) {
        // Show success dialog with restart instruction
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            icon: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                size: 48,
                color: Colors.green.shade700,
              ),
            ),
            title: const Text(
              'Khôi phục thành công!',
              style: TextStyle(color: Colors.green),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Dữ liệu đã được khôi phục từ file sao lưu.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Vui lòng ĐÓNG và MỞ LẠI ứng dụng để áp dụng thay đổi.',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              FilledButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  // Exit the app
                  SystemNavigator.pop();
                },
                child: const Text('Đóng ứng dụng'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text(result.message ?? 'Khôi phục thất bại!')),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRestoring = false);
      }
    }
  }
}

/// Section header widget
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.color,
  });

  final IconData icon;
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
      ],
    );
  }
}

/// Info row for database info card
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: valueColor,
              ),
        ),
      ],
    );
  }
}
