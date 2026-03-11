import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'member_view_model.dart';

class MemberFormPage extends ConsumerStatefulWidget {
  const MemberFormPage({super.key, this.existing});

  final SupabaseMember? existing;

  @override
  ConsumerState<MemberFormPage> createState() => _MemberFormPageState();
}

class _MemberFormPageState extends ConsumerState<MemberFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _idCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _middleNameCtrl;
  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _nationalIdCtrl;
  late final TextEditingController _addressCtrl;

  String? _packageId;
  String? _avatarPath;
  bool _isActive = true;
  bool _saving = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final m = widget.existing;
    _idCtrl = TextEditingController(text: m?.id ?? '');
    _lastNameCtrl = TextEditingController(text: m?.lastName ?? '');
    _middleNameCtrl = TextEditingController(text: m?.middleName ?? '');
    _firstNameCtrl = TextEditingController(text: m?.firstName ?? '');
    _phoneCtrl = TextEditingController(text: m?.phone ?? '');
    _emailCtrl = TextEditingController(text: m?.email ?? '');
    _nationalIdCtrl = TextEditingController(text: m?.nationalId ?? '');
    _addressCtrl = TextEditingController(text: m?.address ?? '');
    _packageId = m?.packageId;
    _avatarPath = m?.avatarUrl;
    _isActive = m?.isActive ?? true;

    // Auto-generate next member id in Add mode.
    if (m == null) {
      Future.microtask(() async {
        final nextId = await ref.read(generateMemberIdProvider.future);
        if (!mounted) return;
        if (_idCtrl.text.trim().isEmpty) {
          setState(() => _idCtrl.text = nextId);
        }
      });
    }
  }

  @override
  void dispose() {
    _idCtrl.dispose();
    _lastNameCtrl.dispose();
    _middleNameCtrl.dispose();
    _firstNameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _nationalIdCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    final path = res?.files.single.path;
    if (path == null) return;
    setState(() => _avatarPath = path);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if ((_packageId ?? '').trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn gói cước.')),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final controller = ref.read(memberListControllerProvider.notifier);

      // Phân biệt giữa local file path và URL đã có sẵn
      File? avatarFile;
      String? avatarUrl;

      if (_avatarPath != null && _avatarPath!.isNotEmpty) {
        if (_avatarPath!.startsWith('http://') ||
            _avatarPath!.startsWith('https://')) {
          // Đã là URL từ Supabase, không cần upload lại
          avatarUrl = _avatarPath;
        } else {
          // Local file path, cần upload
          avatarFile = File(_avatarPath!);
        }
      }

      if (_isEdit) {
        await controller.updateMember(
          id: _idCtrl.text.trim(),
          lastName: _lastNameCtrl.text.trim().isEmpty
              ? null
              : _lastNameCtrl.text.trim(),
          middleName: _middleNameCtrl.text.trim().isEmpty
              ? null
              : _middleNameCtrl.text.trim(),
          firstName: _firstNameCtrl.text.trim().isEmpty
              ? null
              : _firstNameCtrl.text.trim(),
          phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
          nationalId: _nationalIdCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          address: _addressCtrl.text.trim().isEmpty
              ? null
              : _addressCtrl.text.trim(),
          packageId: _packageId!,
          isActive: _isActive,
          avatarUrl: avatarUrl,
          avatarFile: avatarFile,
        );
      } else {
        await controller.addMember(
          id: _idCtrl.text.trim(),
          lastName: _lastNameCtrl.text.trim().isEmpty
              ? null
              : _lastNameCtrl.text.trim(),
          middleName: _middleNameCtrl.text.trim().isEmpty
              ? null
              : _middleNameCtrl.text.trim(),
          firstName: _firstNameCtrl.text.trim().isEmpty
              ? null
              : _firstNameCtrl.text.trim(),
          phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
          nationalId: _nationalIdCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          address: _addressCtrl.text.trim().isEmpty
              ? null
              : _addressCtrl.text.trim(),
          packageId: _packageId!,
          isActive: _isActive,
          avatarUrl: avatarUrl,
          avatarFile: avatarFile,
        );
      }

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final packagesAsync = ref.watch(packagesProvider);

    // Ensure generateMemberIdProvider runs in Add mode (so it can cache while page is open)
    if (!_isEdit) {
      ref.watch(generateMemberIdProvider);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Sửa hội viên' : 'Thêm hội viên'),
      ),
      body: packagesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Lỗi tải gói hội viên: $e'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(packagesProvider),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          ),
        ),
        data: (packages) => _buildForm(context, packages),
      ),
    );
  }

  Widget _buildForm(BuildContext context, List<SupabasePackage> packages) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Avatar section
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: _getAvatarImage(),
                  child: _getAvatarImage() == null
                      ? const Icon(Icons.person)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Avatar',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        (_avatarPath ?? '').trim().isEmpty
                            ? 'Chưa chọn ảnh'
                            : 'Đã chọn ảnh',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _pickAvatar,
                  icon: const Icon(Icons.upload),
                  label: const Text('Chọn'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Form fields
        Form(
          key: _formKey,
          child: Column(
            children: [
              // Member ID
              TextFormField(
                controller: _idCtrl,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Mã hội viên (MaDG)',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withAlpha(153),
                ),
                validator: (v) {
                  final value = (v ?? '').trim();
                  if (value.isEmpty) return 'Đang tạo mã...';
                  if (value.length > 10) return 'Tối đa 10 ký tự.';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Name row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _lastNameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Họ',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _middleNameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Tên lót',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // First name
              TextFormField(
                controller: _firstNameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Tên',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              // Phone
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'SĐT',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  final value = (v ?? '').trim();
                  if (value.isEmpty) return 'Bắt buộc.';
                  if (value.length != 10) return 'SĐT phải đủ 10 số.';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Package dropdown
              DropdownButtonFormField<String>(
                value: _packageId,
                items: packages
                    .map(
                      (p) => DropdownMenuItem(
                        value: p.id,
                        child:
                            Text('${p.displayName} - ${p.formattedMonthlyFee}'),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _packageId = v),
                decoration: const InputDecoration(
                  labelText: 'Gói cước',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Vui lòng chọn gói cước';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Active status
              SwitchListTile.adaptive(
                value: _isActive,
                onChanged: (v) => setState(() => _isActive = v),
                title: const Text('Trạng thái hoạt động'),
              ),
              const SizedBox(height: 12),

              // Email
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  final value = (v ?? '').trim();
                  if (value.isEmpty) return 'Bắt buộc.';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // National ID (CCCD)
              TextFormField(
                controller: _nationalIdCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'CCCD',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  final value = (v ?? '').trim();
                  if (value.isEmpty) return 'Bắt buộc.';
                  if (value.length != 12) return 'CCCD phải đủ 12 số.';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Address
              TextFormField(
                controller: _addressCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Địa chỉ',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Save button
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(_saving ? 'Đang lưu...' : 'Lưu'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  ImageProvider? _getAvatarImage() {
    if (_avatarPath == null || _avatarPath!.trim().isEmpty) {
      return null;
    }

    // Check if it's a URL (from Supabase) or local file path
    if (_avatarPath!.startsWith('http://') ||
        _avatarPath!.startsWith('https://')) {
      return NetworkImage(_avatarPath!);
    } else {
      return FileImage(File(_avatarPath!));
    }
  }
}
