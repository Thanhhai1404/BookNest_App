import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../data/db/app_database.dart';
import '../../../data/repositories/subscription_repository.dart';
import 'subscription_view_model.dart';

final _currencyFormat = NumberFormat('#,###', 'vi_VN');

/// Page for managing subscription plans
class SubscriptionListPage extends ConsumerWidget {
  const SubscriptionListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(subscriptionViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Gói Hội viên'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Thêm gói mới',
            onPressed: () => _showAddDialog(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Tải lại',
            onPressed: () =>
                ref.read(subscriptionViewModelProvider.notifier).refresh(),
          ),
        ],
      ),
      body: stateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Lỗi: $e'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.read(subscriptionViewModelProvider.notifier).refresh(),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
        data: (state) => _buildContent(context, ref, state),
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, WidgetRef ref, SubscriptionListState state) {
    final scheme = Theme.of(context).colorScheme;

    if (state.subscriptions.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.card_membership, size: 64, color: scheme.outlineVariant),
            const SizedBox(height: 16),
            Text(
              'Chưa có gói hội viên nào',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => _showAddDialog(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Thêm gói mới'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.subscriptions.length,
      itemBuilder: (context, index) {
        final item = state.subscriptions[index];
        return _SubscriptionCard(
          item: item,
          isProcessing: state.isProcessing,
        );
      },
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => _AddSubscriptionDialog(
        onSave: (id, name, monthlyFee, deposit, maxBooks, maxDays,
            description) async {
          final success = await ref
              .read(subscriptionViewModelProvider.notifier)
              .createSubscription(
                id: id,
                name: name,
                monthlyFee: monthlyFee,
                deposit: deposit,
                maxBooks: maxBooks,
                maxDays: maxDays,
                description: description,
              );
          if (ctx.mounted) {
            Navigator.of(ctx).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text(success ? 'Đã thêm gói mới' : 'Thêm gói thất bại'),
                backgroundColor: success ? Colors.green : Colors.red,
              ),
            );
          }
        },
      ),
    );
  }
}

class _SubscriptionCard extends ConsumerWidget {
  const _SubscriptionCard({
    required this.item,
    required this.isProcessing,
  });

  final SubscriptionWithMemberCount item;
  final bool isProcessing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final sub = item.subscription;

    // Determine card color based on subscription type
    Color cardColor;
    IconData cardIcon;
    if (sub.id.toLowerCase().contains('vip') ||
        (sub.monthlyFee ?? 0) > 100000) {
      cardColor = Colors.amber.shade700;
      cardIcon = Icons.star;
    } else if (sub.id.toLowerCase().contains('premium')) {
      cardColor = Colors.purple.shade600;
      cardIcon = Icons.workspace_premium;
    } else {
      cardColor = scheme.primary;
      cardIcon = Icons.card_membership;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: cardColor.withAlpha(38),
                  child: Icon(cardIcon, color: cardColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sub.name ?? sub.id,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      Text(
                        'Mã: ${sub.id}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                // Member count badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.people,
                          size: 16, color: scheme.onPrimaryContainer),
                      const SizedBox(width: 4),
                      Text(
                        '${item.memberCount}',
                        style: TextStyle(
                          color: scheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),

            // Info grid
            Row(
              children: [
                Expanded(
                  child: _InfoTile(
                    icon: Icons.book,
                    label: 'Giới hạn sách',
                    value: '${sub.maxBooks ?? "∞"} cuốn',
                    color: Colors.blue,
                  ),
                ),
                Expanded(
                  child: _InfoTile(
                    icon: Icons.calendar_today,
                    label: 'Giới hạn ngày',
                    value: '${sub.maxDays ?? "∞"} ngày',
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _InfoTile(
                    icon: Icons.payments,
                    label: 'Phí hàng tháng',
                    value: sub.monthlyFee != null
                        ? '${_currencyFormat.format(sub.monthlyFee)}đ'
                        : 'Miễn phí',
                    color: Colors.green,
                  ),
                ),
                Expanded(
                  child: _InfoTile(
                    icon: Icons.account_balance_wallet,
                    label: 'Tiền đặt cọc',
                    value: sub.deposit != null
                        ? '${_currencyFormat.format(sub.deposit)}đ'
                        : 'Không có',
                    color: Colors.teal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Features row
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _FeatureChip(
                  label: 'Đặt trước',
                  enabled: sub.allowReservation,
                ),
                _FeatureChip(
                  label: 'Gia hạn',
                  enabled: sub.allowRenewal,
                ),
              ],
            ),

            if (sub.description != null && sub.description!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                sub.description!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ],

            const SizedBox(height: 16),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: isProcessing
                      ? null
                      : () => _showEditDialog(context, ref, sub),
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Sửa'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: isProcessing || item.memberCount > 0
                      ? null
                      : () => _confirmDelete(context, ref, sub),
                  icon: Icon(
                    Icons.delete,
                    size: 18,
                    color: item.memberCount > 0 ? null : Colors.red,
                  ),
                  label: Text(
                    'Xóa',
                    style: TextStyle(
                      color: item.memberCount > 0 ? null : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, Subscription sub) {
    showDialog(
      context: context,
      builder: (ctx) => _EditSubscriptionDialog(
        subscription: sub,
        onSave: (maxBooks, maxDays, name, monthlyFee, deposit, description,
            allowReservation, allowRenewal) async {
          final success = await ref
              .read(subscriptionViewModelProvider.notifier)
              .updateSubscription(
                id: sub.id,
                name: name,
                maxBooks: maxBooks,
                maxDays: maxDays,
                monthlyFee: monthlyFee,
                deposit: deposit,
                description: description,
                allowReservation: allowReservation,
                allowRenewal: allowRenewal,
              );
          if (ctx.mounted) {
            Navigator.of(ctx).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text(success ? 'Đã cập nhật gói' : 'Cập nhật thất bại'),
                backgroundColor: success ? Colors.green : Colors.red,
              ),
            );
          }
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Subscription sub) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa gói "${sub.name ?? sub.id}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final success = await ref
                  .read(subscriptionViewModelProvider.notifier)
                  .deleteSubscription(sub.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success
                        ? 'Đã xóa gói'
                        : 'Không thể xóa (có hội viên đang dùng)'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
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
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({
    required this.label,
    required this.enabled,
  });

  final String label;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: enabled ? Colors.green.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: enabled ? Colors.green.shade200 : Colors.grey.shade300,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            enabled ? Icons.check_circle : Icons.cancel,
            size: 14,
            color: enabled ? Colors.green.shade700 : Colors.grey.shade500,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: enabled ? Colors.green.shade700 : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EditSubscriptionDialog extends StatefulWidget {
  const _EditSubscriptionDialog({
    required this.subscription,
    required this.onSave,
  });

  final Subscription subscription;
  final Future<void> Function(
    int? maxBooks,
    int? maxDays,
    String? name,
    int? monthlyFee,
    int? deposit,
    String? description,
    bool? allowReservation,
    bool? allowRenewal,
  ) onSave;

  @override
  State<_EditSubscriptionDialog> createState() =>
      _EditSubscriptionDialogState();
}

class _EditSubscriptionDialogState extends State<_EditSubscriptionDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _maxBooksController;
  late final TextEditingController _maxDaysController;
  late final TextEditingController _monthlyFeeController;
  late final TextEditingController _depositController;
  late final TextEditingController _descriptionController;
  late bool _allowReservation;
  late bool _allowRenewal;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final sub = widget.subscription;
    _nameController = TextEditingController(text: sub.name ?? '');
    _maxBooksController =
        TextEditingController(text: sub.maxBooks?.toString() ?? '');
    _maxDaysController =
        TextEditingController(text: sub.maxDays?.toString() ?? '');
    _monthlyFeeController =
        TextEditingController(text: sub.monthlyFee?.toString() ?? '');
    _depositController =
        TextEditingController(text: sub.deposit?.toString() ?? '');
    _descriptionController = TextEditingController(text: sub.description ?? '');
    _allowReservation = sub.allowReservation;
    _allowRenewal = sub.allowRenewal;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _maxBooksController.dispose();
    _maxDaysController.dispose();
    _monthlyFeeController.dispose();
    _depositController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
          'Chỉnh sửa: ${widget.subscription.name ?? widget.subscription.id}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Tên gói',
                prefixIcon: Icon(Icons.label),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _maxBooksController,
                    decoration: const InputDecoration(
                      labelText: 'Giới hạn sách',
                      prefixIcon: Icon(Icons.book),
                      hintText: 'VD: 5',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _maxDaysController,
                    decoration: const InputDecoration(
                      labelText: 'Giới hạn ngày',
                      prefixIcon: Icon(Icons.calendar_today),
                      hintText: 'VD: 14',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _monthlyFeeController,
                    decoration: const InputDecoration(
                      labelText: 'Phí hàng tháng (VND)',
                      prefixIcon: Icon(Icons.payments),
                      hintText: 'VD: 50000',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _depositController,
                    decoration: const InputDecoration(
                      labelText: 'Tiền cọc (VND)',
                      prefixIcon: Icon(Icons.account_balance_wallet),
                      hintText: 'VD: 100000',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Mô tả',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Cho phép đặt trước'),
              value: _allowReservation,
              onChanged: (v) => setState(() => _allowReservation = v),
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: const Text('Cho phép gia hạn'),
              value: _allowRenewal,
              onChanged: (v) => setState(() => _allowRenewal = v),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Lưu'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);

    await widget.onSave(
      int.tryParse(_maxBooksController.text),
      int.tryParse(_maxDaysController.text),
      _nameController.text.isEmpty ? null : _nameController.text,
      int.tryParse(_monthlyFeeController.text),
      int.tryParse(_depositController.text),
      _descriptionController.text.isEmpty ? null : _descriptionController.text,
      _allowReservation,
      _allowRenewal,
    );
  }
}

class _AddSubscriptionDialog extends StatefulWidget {
  const _AddSubscriptionDialog({required this.onSave});

  final Future<void> Function(
    String id,
    String name,
    int? monthlyFee,
    int? deposit,
    int? maxBooks,
    int? maxDays,
    String? description,
  ) onSave;

  @override
  State<_AddSubscriptionDialog> createState() => _AddSubscriptionDialogState();
}

class _AddSubscriptionDialogState extends State<_AddSubscriptionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _nameController = TextEditingController();
  final _maxBooksController = TextEditingController(text: '5');
  final _maxDaysController = TextEditingController(text: '14');
  final _monthlyFeeController = TextEditingController();
  final _depositController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _maxBooksController.dispose();
    _maxDaysController.dispose();
    _monthlyFeeController.dispose();
    _depositController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Thêm gói hội viên mới'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _idController,
                decoration: const InputDecoration(
                  labelText: 'Mã gói *',
                  prefixIcon: Icon(Icons.tag),
                  hintText: 'VD: BASIC, VIP',
                ),
                validator: (v) => v == null || v.isEmpty ? 'Bắt buộc' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên gói *',
                  prefixIcon: Icon(Icons.label),
                  hintText: 'VD: Gói Cơ bản, Gói VIP',
                ),
                validator: (v) => v == null || v.isEmpty ? 'Bắt buộc' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _maxBooksController,
                      decoration: const InputDecoration(
                        labelText: 'Giới hạn sách',
                        prefixIcon: Icon(Icons.book),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _maxDaysController,
                      decoration: const InputDecoration(
                        labelText: 'Giới hạn ngày',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _monthlyFeeController,
                      decoration: const InputDecoration(
                        labelText: 'Phí tháng (VND)',
                        prefixIcon: Icon(Icons.payments),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _depositController,
                      decoration: const InputDecoration(
                        labelText: 'Tiền cọc (VND)',
                        prefixIcon: Icon(Icons.account_balance_wallet),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Mô tả',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Thêm'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    await widget.onSave(
      _idController.text.toUpperCase(),
      _nameController.text,
      int.tryParse(_monthlyFeeController.text),
      int.tryParse(_depositController.text),
      int.tryParse(_maxBooksController.text),
      int.tryParse(_maxDaysController.text),
      _descriptionController.text.isEmpty ? null : _descriptionController.text,
    );
  }
}
