import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/supabase_activity_log_repository.dart';

class SupabaseActivityLogPage extends ConsumerWidget {
  const SupabaseActivityLogPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final logsAsync = ref.watch(activityLogsProvider);
    final filterDate = ref.watch(activityLogDateFilterProvider);
    final filterModule = ref.watch(activityLogModuleFilterProvider);
    final groupedLogs = ref.watch(groupedActivityLogsProvider);
    
    final hasFilter = filterDate != null || filterModule != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nhật ký hoạt động'),
        actions: [
          // Module filter button
          IconButton(
            tooltip: 'Lọc theo loại',
            onPressed: () => _showModuleFilterSheet(context, ref, filterModule),
            icon: Badge(
              isLabelVisible: filterModule != null,
              child: const Icon(Icons.category_rounded),
            ),
          ),
          // Date filter button
          IconButton(
            tooltip: 'Lọc theo ngày',
            onPressed: () => _showDatePicker(context, ref, filterDate),
            icon: Badge(
              isLabelVisible: filterDate != null,
              child: const Icon(Icons.calendar_month_rounded),
            ),
          ),
          // Clear filter button (chỉ hiện khi có filter)
          if (hasFilter)
            IconButton(
              tooltip: 'Xóa bộ lọc',
              onPressed: () {
                ref.read(activityLogDateFilterProvider.notifier).state = null;
                ref.read(activityLogModuleFilterProvider.notifier).state = null;
              },
              icon: const Icon(Icons.filter_alt_off_rounded),
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter info bar
          if (hasFilter)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: scheme.primaryContainer,
              child: Row(
                children: [
                  Icon(
                    Icons.filter_list_rounded,
                    size: 20,
                    color: scheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _buildFilterText(filterDate, filterModule),
                      style: TextStyle(
                        color: scheme.onPrimaryContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      ref.read(activityLogDateFilterProvider.notifier).state = null;
                      ref.read(activityLogModuleFilterProvider.notifier).state = null;
                    },
                    child: Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          
          // Content
          Expanded(
            child: logsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 64,
                      color: scheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Đã có lỗi xảy ra',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString().replaceAll('Exception: ', ''),
                      style: TextStyle(color: scheme.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => ref.invalidate(activityLogsProvider),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
              data: (logs) {
                if (logs.isEmpty) {
                  return _buildEmptyState(context, filterDate, ref);
                }

                // Build grouped list
                final dateKeys = groupedLogs.keys.toList();
                
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(activityLogsProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: dateKeys.length,
                    itemBuilder: (context, index) {
                      final dateKey = dateKeys[index];
                      final logsForDate = groupedLogs[dateKey] ?? [];
                      
                      return _buildDateSection(
                        context,
                        dateKey,
                        logsForDate,
                        isFirst: index == 0,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }  Widget _buildEmptyState(BuildContext context, DateTime? filterDate, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final filterModule = ref.watch(activityLogModuleFilterProvider);
    final hasFilter = filterDate != null || filterModule != null;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_rounded,
            size: 80,
            color: scheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            hasFilter
                ? 'Không có hoạt động nào\nphù hợp với bộ lọc'
                : 'Chưa có hoạt động nào',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
          if (hasFilter) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                ref.read(activityLogDateFilterProvider.notifier).state = null;
                ref.read(activityLogModuleFilterProvider.notifier).state = null;
              },
              icon: const Icon(Icons.filter_alt_off_rounded),
              label: const Text('Xóa bộ lọc'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDateSection(
    BuildContext context,
    String dateKey,
    List<ActivityLog> logs,
    {bool isFirst = false}
  ) {
    final scheme = Theme.of(context).colorScheme;
    
    // Kiểm tra xem có phải hôm nay không
    final today = DateTime.now();
    final todayKey = '${today.day.toString().padLeft(2, '0')}/${today.month.toString().padLeft(2, '0')}/${today.year}';
    final yesterday = today.subtract(const Duration(days: 1));
    final yesterdayKey = '${yesterday.day.toString().padLeft(2, '0')}/${yesterday.month.toString().padLeft(2, '0')}/${yesterday.year}';
    
    String displayDate;
    if (dateKey == todayKey) {
      displayDate = 'Hôm nay';
    } else if (dateKey == yesterdayKey) {
      displayDate = 'Hôm qua';
    } else {
      displayDate = dateKey;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date header
        Container(
          width: double.infinity,
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: isFirst ? 16 : 24,
            bottom: 8,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: scheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  displayDate,
                  style: TextStyle(
                    color: scheme.onSecondaryContainer,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '(${logs.length} hoạt động)',
                style: TextStyle(
                  color: scheme.outline,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        
        // Log items
        ...logs.map((log) => _ActivityLogTile(log: log)),
      ],
    );
  }
  Future<void> _showDatePicker(
    BuildContext context,
    WidgetRef ref,
    DateTime? currentFilter,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: currentFilter ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'Chọn ngày để lọc',
      cancelText: 'Hủy',
      confirmText: 'Chọn',
    );

    if (picked != null) {
      ref.read(activityLogDateFilterProvider.notifier).state = picked;
    }
  }

  void _showModuleFilterSheet(
    BuildContext context,
    WidgetRef ref,
    String? currentModule,
  ) {
    final modules = [
      (ActivityModule.muonTra, 'Mượn trả', '📚'),
      (ActivityModule.viTien, 'Ví tiền', '💰'),
      (ActivityModule.hoiVien, 'Hội viên', '👤'),
      (ActivityModule.sach, 'Sách', '📖'),
      (ActivityModule.nhanVien, 'Nhân viên', '👔'),
      (ActivityModule.heThong, 'Hệ thống', '⚙️'),
    ];

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Text(
                      'Lọc theo loại',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    if (currentModule != null)
                      TextButton(
                        onPressed: () {
                          ref.read(activityLogModuleFilterProvider.notifier).state = null;
                          Navigator.pop(context);
                        },
                        child: const Text('Xóa lọc'),
                      ),
                  ],
                ),
              ),
              const Divider(height: 1),
              ...modules.map((module) => ListTile(
                leading: Text(module.$3, style: const TextStyle(fontSize: 24)),
                title: Text(module.$2),
                trailing: currentModule == module.$1
                    ? const Icon(Icons.check_rounded, color: Colors.green)
                    : null,
                onTap: () {
                  ref.read(activityLogModuleFilterProvider.notifier).state = module.$1;
                  Navigator.pop(context);
                },
              )),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  String _buildFilterText(DateTime? filterDate, String? filterModule) {
    final parts = <String>[];
    
    if (filterDate != null) {
      parts.add(DateFormat('dd/MM/yyyy').format(filterDate));
    }
    
    if (filterModule != null) {
      String moduleName;
      switch (filterModule) {
        case ActivityModule.muonTra:
          moduleName = 'Mượn trả';
          break;
        case ActivityModule.viTien:
          moduleName = 'Ví tiền';
          break;
        case ActivityModule.hoiVien:
          moduleName = 'Hội viên';
          break;
        case ActivityModule.sach:
          moduleName = 'Sách';
          break;
        case ActivityModule.nhanVien:
          moduleName = 'Nhân viên';
          break;
        case ActivityModule.heThong:
          moduleName = 'Hệ thống';
          break;
        default:
          moduleName = filterModule;
      }
      parts.add(moduleName);
    }
    
    return 'Đang lọc: ${parts.join(' • ')}';
  }
}

class _ActivityLogTile extends StatelessWidget {
  final ActivityLog log;

  const _ActivityLogTile({required this.log});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final moduleColor = Color(log.moduleColorValue);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showDetailDialog(context),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: moduleColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      log.moduleIcon,
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Module badge + Action type + time
                      Row(
                        children: [
                          // Module badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: moduleColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              log.moduleDisplayName,
                              style: TextStyle(
                                color: moduleColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          // Action type
                          Expanded(
                            child: Text(
                              log.actionType,
                              style: TextStyle(
                                color: scheme.onSurface,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            DateFormat('HH:mm').format(log.createdAt),
                            style: TextStyle(
                              color: scheme.outline,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),                      const SizedBox(height: 6),
                      
                      // Content (nội dung)
                      if (log.content.isNotEmpty)
                        Text(
                          log.content,
                          style: TextStyle(
                            color: scheme.onSurface,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      
                      const SizedBox(height: 4),
                      
                      // Employee + Member info
                      Row(
                        children: [
                          if (log.employeeName != null || log.employeeId != null) ...[
                            Icon(
                              Icons.badge_outlined,
                              size: 14,
                              color: scheme.outline,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                log.employeeName ?? log.employeeId ?? '',
                                style: TextStyle(
                                  color: scheme.outline,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                          if ((log.memberName != null || log.memberId != null) && 
                              (log.employeeId != null)) ...[
                            const SizedBox(width: 8),
                            Text('•', style: TextStyle(color: scheme.outline)),
                            const SizedBox(width: 8),
                          ],
                          if (log.memberName != null || log.memberId != null) ...[
                            Icon(
                              Icons.person_outline_rounded,
                              size: 14,
                              color: scheme.outline,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                log.memberName ?? log.memberId ?? '',
                                style: TextStyle(
                                  color: scheme.outline,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  void _showDetailDialog(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final moduleColor = Color(log.moduleColorValue);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(log.moduleIcon, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    log.actionType,
                    style: TextStyle(color: moduleColor, fontSize: 18),
                  ),
                  Text(
                    log.moduleDisplayName,
                    style: TextStyle(
                      color: scheme.outline,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Thời gian
              _buildDetailRow(
                context,
                'Thời gian',
                DateFormat('HH:mm - dd/MM/yyyy').format(log.createdAt),
                Icons.access_time_rounded,
              ),
              const SizedBox(height: 12),
              
              // Nhân viên
              if (log.employeeId != null)
                _buildDetailRow(
                  context,
                  'Nhân viên',
                  log.employeeName ?? log.employeeId!,
                  Icons.badge_rounded,
                ),
              if (log.employeeId != null) const SizedBox(height: 12),
              
              // Độc giả liên quan
              if (log.memberId != null)
                _buildDetailRow(
                  context,
                  'Độc giả',
                  log.memberName ?? log.memberId!,
                  Icons.person_rounded,
                ),
              if (log.memberId != null) const SizedBox(height: 12),
              
              // Mã tham chiếu
              if (log.referenceId != null && log.referenceId!.isNotEmpty)
                _buildDetailRow(
                  context,
                  'Mã tham chiếu',
                  log.referenceId!,
                  Icons.tag_rounded,
                ),
              if (log.referenceId != null && log.referenceId!.isNotEmpty) 
                const SizedBox(height: 12),
              
              // Nội dung
              if (log.content.isNotEmpty) ...[
                Text(
                  'Nội dung',
                  style: TextStyle(
                    color: scheme.outline,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    log.content,
                    style: TextStyle(
                      color: scheme.onSurface,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final scheme = Theme.of(context).colorScheme;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: scheme.outline),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: scheme.outline,
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
