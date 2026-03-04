import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/supabase_employee_repository.dart';

/// Trang Form thêm/sửa nhân viên
class SupabaseEmployeeFormPage extends ConsumerStatefulWidget {
  const SupabaseEmployeeFormPage({
    super.key,
    this.employee,
  });

  /// Nếu có employee thì là chế độ Sửa, nếu null thì là Thêm mới
  final SupabaseEmployee? employee;

  bool get isEditing => employee != null;

  @override
  ConsumerState<SupabaseEmployeeFormPage> createState() =>
      _SupabaseEmployeeFormPageState();
}

class _SupabaseEmployeeFormPageState
    extends ConsumerState<SupabaseEmployeeFormPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _idController;
  late TextEditingController _lastNameController;
  late TextEditingController _firstNameController;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;

  String _selectedPosition = 'Thủ thư';
  bool _isSubmitting = false;
  bool _obscurePassword = true;

  static const List<String> _positions = ['Thủ thư', 'Quản lý'];

  @override
  void initState() {
    super.initState();
    final emp = widget.employee;
    _idController = TextEditingController(text: emp?.id ?? '');
    _lastNameController = TextEditingController(text: emp?.lastName ?? '');
    _firstNameController = TextEditingController(text: emp?.firstName ?? '');
    _usernameController = TextEditingController(text: emp?.username ?? '');
    _passwordController = TextEditingController();

    if (emp?.position != null && _positions.contains(emp!.position)) {
      _selectedPosition = emp.position!;
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _lastNameController.dispose();
    _firstNameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isEditing = widget.isEditing;

    // Nếu là chế độ Thêm mới và chưa có ID, fetch ID tự động
    if (!isEditing && _idController.text.isEmpty) {
      final generatedIdAsync = ref.watch(generateEmployeeIdProvider);
      generatedIdAsync.whenData((id) {
        if (_idController.text.isEmpty) {
          _idController.text = id;
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Sửa nhân viên' : 'Thêm nhân viên'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Header info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: scheme.primaryContainer.withAlpha(50),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: scheme.primaryContainer),
              ),
              child: Row(
                children: [
                  Icon(
                    isEditing ? Icons.edit_note : Icons.person_add,
                    color: scheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isEditing
                          ? 'Cập nhật thông tin nhân viên. Để trống mật khẩu nếu không muốn thay đổi.'
                          : 'Điền thông tin để tạo nhân viên mới. Mã NV sẽ được sinh tự động.',
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Mã NV
            _buildSectionTitle(context, 'Mã nhân viên *'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _idController,
              decoration: InputDecoration(
                hintText: 'VD: NV001',
                prefixIcon: const Icon(Icons.badge_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: scheme.surfaceContainerLow,
              ),
              readOnly: isEditing, // Không cho sửa mã khi đang edit
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập mã nhân viên';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Họ NV
            _buildSectionTitle(context, 'Họ nhân viên'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _lastNameController,
              decoration: InputDecoration(
                hintText: 'VD: Nguyễn Văn',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: scheme.surfaceContainerLow,
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 20),

            // Tên NV
            _buildSectionTitle(context, 'Tên nhân viên *'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _firstNameController,
              decoration: InputDecoration(
                hintText: 'VD: An',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: scheme.surfaceContainerLow,
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập tên nhân viên';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Chức vụ
            _buildSectionTitle(context, 'Chức vụ *'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedPosition,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.work_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: scheme.surfaceContainerLow,
              ),
              items: _positions.map((pos) {
                return DropdownMenuItem(
                  value: pos,
                  child: Row(
                    children: [
                      Icon(
                        pos == 'Quản lý'
                            ? Icons.admin_panel_settings
                            : Icons.local_library,
                        size: 20,
                        color: pos == 'Quản lý' ? Colors.purple : Colors.teal,
                      ),
                      const SizedBox(width: 8),
                      Text(pos),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedPosition = value);
                }
              },
            ),
            const SizedBox(height: 20),

            // Tài khoản
            _buildSectionTitle(context, 'Tên đăng nhập *'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(
                hintText: 'VD: nguyenvanan',
                prefixIcon: const Icon(Icons.account_circle_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: scheme.surfaceContainerLow,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập tên đăng nhập';
                }
                if (value.contains(' ')) {
                  return 'Tên đăng nhập không được chứa khoảng trắng';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Mật khẩu
            _buildSectionTitle(
              context,
              isEditing ? 'Mật khẩu mới (để trống nếu không đổi)' : 'Mật khẩu *',
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                hintText: isEditing ? 'Nhập mật khẩu mới...' : 'Nhập mật khẩu',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: scheme.surfaceContainerLow,
              ),
              obscureText: _obscurePassword,
              validator: (value) {
                // Bắt buộc khi thêm mới
                if (!isEditing && (value == null || value.isEmpty)) {
                  return 'Vui lòng nhập mật khẩu';
                }
                // Kiểm tra độ dài nếu có nhập
                if (value != null && value.isNotEmpty && value.length < 4) {
                  return 'Mật khẩu phải có ít nhất 4 ký tự';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),

            // Submit button
            FilledButton.icon(
              onPressed: _isSubmitting ? null : _submit,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(isEditing ? Icons.save : Icons.add),
              label: Text(
                _isSubmitting
                    ? 'Đang xử lý...'
                    : (isEditing ? 'Lưu thay đổi' : 'Thêm nhân viên'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final repository = ref.read(supabaseEmployeeRepositoryProvider);

      final employee = SupabaseEmployee(
        id: _idController.text.trim(),
        lastName: _lastNameController.text.trim().isEmpty
            ? null
            : _lastNameController.text.trim(),
        firstName: _firstNameController.text.trim(),
        position: _selectedPosition,
        username: _usernameController.text.trim(),
      );

      if (widget.isEditing) {
        // Cập nhật
        await repository.updateEmployeeFromModel(
          employee,
          newPassword: _passwordController.text.isEmpty
              ? null
              : _passwordController.text,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã cập nhật nhân viên ${employee.fullName}'),
              backgroundColor: Colors.green.shade600,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.of(context).pop(true);
        }
      } else {
        // Thêm mới
        await repository.createEmployeeFromModel(
          employee,
          password: _passwordController.text,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã thêm nhân viên ${employee.fullName}'),
              backgroundColor: Colors.green.shade600,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = e.toString().replaceAll('Exception: ', '');
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade600, size: 28),
                const SizedBox(width: 8),
                Text(
                  widget.isEditing ? 'Lỗi cập nhật' : 'Lỗi thêm mới',
                  style: TextStyle(
                    color: Colors.red.shade600,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Text(errorMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Đóng'),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
