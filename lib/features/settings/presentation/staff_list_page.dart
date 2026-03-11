import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/db/app_database.dart';
import 'staff_view_model.dart';

/// Page for managing staff accounts
class StaffListPage extends ConsumerWidget {
  const StaffListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(staffViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Nhân viên'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: 'Thêm nhân viên',
            onPressed: () => _showAddDialog(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Tải lại',
            onPressed: () =>
                ref.read(staffViewModelProvider.notifier).refresh(),
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
                    ref.read(staffViewModelProvider.notifier).refresh(),
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
      BuildContext context, WidgetRef ref, StaffListState state) {
    final scheme = Theme.of(context).colorScheme;

    if (state.staffList.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline, size: 64, color: scheme.outlineVariant),
            const SizedBox(height: 16),
            Text(
              'Chưa có nhân viên nào',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => _showAddDialog(context, ref),
              icon: const Icon(Icons.person_add),
              label: const Text('Thêm nhân viên'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.staffList.length,
      itemBuilder: (context, index) {
        final staff = state.staffList[index];
        return _StaffCard(
          staff: staff,
          isProcessing: state.isProcessing,
        );
      },
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => _AddStaffDialog(
        onSave:
            (username, password, lastName, middleName, firstName, role) async {
          final error =
              await ref.read(staffViewModelProvider.notifier).createStaff(
                    username: username,
                    password: password,
                    lastName: lastName,
                    middleName: middleName,
                    firstName: firstName,
                    role: role,
                  );
          if (ctx.mounted) {
            Navigator.of(ctx).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error ?? 'Đã thêm nhân viên mới'),
                backgroundColor: error == null ? Colors.green : Colors.red,
              ),
            );
          }
        },
      ),
    );
  }
}

class _StaffCard extends ConsumerWidget {
  const _StaffCard({
    required this.staff,
    required this.isProcessing,
  });

  final StaffAccount staff;
  final bool isProcessing;

  String get _fullName {
    final parts = [staff.lastName, staff.middleName, staff.firstName]
        .where((p) => p != null && p.isNotEmpty)
        .toList();
    return parts.isEmpty ? staff.id : parts.join(' ');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme; // Role color
    Color roleColor;
    IconData roleIcon;
    switch (staff.role?.toLowerCase()) {
      case 'admin':
        roleColor = AppTheme.errorColor;
        roleIcon = Icons.admin_panel_settings;
        break;
      case 'manager':
        roleColor = AppTheme.warningColor;
        roleIcon = Icons.manage_accounts;
        break;
      default:
        roleColor = AppTheme.primaryColor;
        roleIcon = Icons.person;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: roleColor.withAlpha(38),
                  child: Icon(roleIcon, color: roleColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _fullName,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      Text(
                        'Mã NV: ${staff.id}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                // Role badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: roleColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: roleColor.withAlpha(77)),
                  ),
                  child: Text(
                    staff.role ?? 'Nhân viên',
                    style: TextStyle(
                      color: roleColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Username row
            Row(
              children: [
                Icon(Icons.account_circle, size: 18, color: scheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Tài khoản: ${staff.username}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed:
                      isProcessing ? null : () => _showEditDialog(context, ref),
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Sửa'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed:
                      isProcessing ? null : () => _confirmDelete(context, ref),
                  icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                  label: const Text('Xóa', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => _EditStaffDialog(
        staff: staff,
        onSave:
            (lastName, middleName, firstName, role, username, password) async {
          final error =
              await ref.read(staffViewModelProvider.notifier).updateStaff(
                    id: staff.id,
                    lastName: lastName,
                    middleName: middleName,
                    firstName: firstName,
                    role: role,
                    username: username,
                    password: password,
                  );
          if (ctx.mounted) {
            Navigator.of(ctx).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error ?? 'Đã cập nhật thông tin'),
                backgroundColor: error == null ? Colors.green : Colors.red,
              ),
            );
          }
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa nhân viên "$_fullName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final success = await ref
                  .read(staffViewModelProvider.notifier)
                  .deleteStaff(staff.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text(success ? 'Đã xóa nhân viên' : 'Xóa thất bại'),
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

class _AddStaffDialog extends StatefulWidget {
  const _AddStaffDialog({required this.onSave});

  final Future<void> Function(
    String username,
    String password,
    String? lastName,
    String? middleName,
    String? firstName,
    String? role,
  ) onSave;

  @override
  State<_AddStaffDialog> createState() => _AddStaffDialogState();
}

class _AddStaffDialogState extends State<_AddStaffDialog> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _firstNameController = TextEditingController();
  String _selectedRole = 'Nhân viên';
  bool _isSaving = false;
  bool _obscurePassword = true;

  final _roles = ['Admin', 'Manager', 'Nhân viên'];

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _lastNameController.dispose();
    _middleNameController.dispose();
    _firstNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Thêm nhân viên mới'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Name fields
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(
                        labelText: 'Họ',
                        hintText: 'Nguyễn',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _middleNameController,
                      decoration: const InputDecoration(
                        labelText: 'Tên đệm',
                        hintText: 'Văn',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(
                        labelText: 'Tên',
                        hintText: 'An',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Role dropdown
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Vai trò',
                  prefixIcon: Icon(Icons.badge),
                ),
                items: _roles.map((role) {
                  return DropdownMenuItem(value: role, child: Text(role));
                }).toList(),
                onChanged: (v) => setState(() => _selectedRole = v!),
              ),
              const SizedBox(height: 16),

              // Username
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Tên đăng nhập *',
                  prefixIcon: Icon(Icons.account_circle),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Bắt buộc' : null,
              ),
              const SizedBox(height: 16),

              // Password
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Mật khẩu *',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                obscureText: _obscurePassword,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Bắt buộc';
                  if (v.length < 4) return 'Tối thiểu 4 ký tự';
                  return null;
                },
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
      _usernameController.text,
      _passwordController.text,
      _lastNameController.text.isEmpty ? null : _lastNameController.text,
      _middleNameController.text.isEmpty ? null : _middleNameController.text,
      _firstNameController.text.isEmpty ? null : _firstNameController.text,
      _selectedRole,
    );
  }
}

class _EditStaffDialog extends StatefulWidget {
  const _EditStaffDialog({
    required this.staff,
    required this.onSave,
  });

  final StaffAccount staff;
  final Future<void> Function(
    String? lastName,
    String? middleName,
    String? firstName,
    String? role,
    String? username,
    String? password,
  ) onSave;

  @override
  State<_EditStaffDialog> createState() => _EditStaffDialogState();
}

class _EditStaffDialogState extends State<_EditStaffDialog> {
  late final TextEditingController _usernameController;
  final _passwordController = TextEditingController();
  late final TextEditingController _lastNameController;
  late final TextEditingController _middleNameController;
  late final TextEditingController _firstNameController;
  late String _selectedRole;
  bool _isSaving = false;
  bool _obscurePassword = true;
  bool _changePassword = false;

  final _roles = ['Admin', 'Manager', 'Nhân viên'];

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.staff.username);
    _lastNameController =
        TextEditingController(text: widget.staff.lastName ?? '');
    _middleNameController =
        TextEditingController(text: widget.staff.middleName ?? '');
    _firstNameController =
        TextEditingController(text: widget.staff.firstName ?? '');
    _selectedRole = widget.staff.role ?? 'Nhân viên';
    if (!_roles.contains(_selectedRole)) {
      _selectedRole = 'Nhân viên';
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _lastNameController.dispose();
    _middleNameController.dispose();
    _firstNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Sửa: ${widget.staff.id}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Name fields
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(labelText: 'Họ'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _middleNameController,
                    decoration: const InputDecoration(labelText: 'Tên đệm'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(labelText: 'Tên'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Role dropdown
            DropdownButtonFormField<String>(
              value: _selectedRole,
              decoration: const InputDecoration(
                labelText: 'Vai trò',
                prefixIcon: Icon(Icons.badge),
              ),
              items: _roles.map((role) {
                return DropdownMenuItem(value: role, child: Text(role));
              }).toList(),
              onChanged: (v) => setState(() => _selectedRole = v!),
            ),
            const SizedBox(height: 16),

            // Username
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Tên đăng nhập',
                prefixIcon: Icon(Icons.account_circle),
              ),
            ),
            const SizedBox(height: 16),

            // Change password checkbox
            CheckboxListTile(
              title: const Text('Đổi mật khẩu'),
              value: _changePassword,
              onChanged: (v) => setState(() => _changePassword = v!),
              contentPadding: EdgeInsets.zero,
            ),

            if (_changePassword)
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Mật khẩu mới',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                obscureText: _obscurePassword,
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
      _lastNameController.text.isEmpty ? null : _lastNameController.text,
      _middleNameController.text.isEmpty ? null : _middleNameController.text,
      _firstNameController.text.isEmpty ? null : _firstNameController.text,
      _selectedRole,
      _usernameController.text != widget.staff.username
          ? _usernameController.text
          : null,
      _changePassword && _passwordController.text.isNotEmpty
          ? _passwordController.text
          : null,
    );
  }
}
