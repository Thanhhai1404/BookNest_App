import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;

import '../../../data/db/app_database.dart';
import 'member_form_view_model.dart';
import 'member_view_model.dart';

class MemberFormPage extends ConsumerStatefulWidget {
  const MemberFormPage({super.key, this.existing});

  final Member? existing;

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

  String? _subscriptionId;
  String? _avatarPath;
  bool _isActive = true;

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
    _subscriptionId = m?.subscriptionId;
    _avatarPath = m?.avatarPath;
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
    if ((_subscriptionId ?? '').trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn gói cước.')),
      );
      return;
    }

    final companion = MembersCompanion(
      id: drift.Value(_idCtrl.text.trim()),
      lastName: drift.Value(
        _lastNameCtrl.text.trim().isEmpty ? null : _lastNameCtrl.text.trim(),
      ),
      middleName: drift.Value(
        _middleNameCtrl.text.trim().isEmpty
            ? null
            : _middleNameCtrl.text.trim(),
      ),
      firstName: drift.Value(
        _firstNameCtrl.text.trim().isEmpty ? null : _firstNameCtrl.text.trim(),
      ),
      phone: drift.Value(
          _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim()),
      nationalId: drift.Value(_nationalIdCtrl.text.trim()),
      email: drift.Value(_emailCtrl.text.trim()),
      address: drift.Value(
          _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim()),
      subscriptionId: drift.Value(_subscriptionId!),
      isActive: drift.Value(_isActive),
      avatarPath:
          drift.Value((_avatarPath ?? '').trim().isEmpty ? null : _avatarPath),
      // Keep other optional fields as absent (no changes)
      dateOfBirth: const drift.Value.absent(),
      subscriptionExpiryDate: const drift.Value.absent(),
      walletBalance: const drift.Value.absent(),
      points: const drift.Value.absent(),
      password: const drift.Value.absent(),
    );

    final controller = ref.read(memberListControllerProvider.notifier);
    await controller.upsert(companion, isUpdate: _isEdit);

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(databaseProvider);

    // Ensure generateMemberIdProvider runs in Add mode (so it can cache while page is open)
    if (!_isEdit) {
      ref.watch(generateMemberIdProvider);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Sửa hội viên' : 'Thêm hội viên'),
      ),
      body: FutureBuilder<List<Subscription>>(
        future: (db.select(db.subscriptions)
              ..orderBy([(s) => drift.OrderingTerm(expression: s.id)]))
            .get(),
        builder: (context, snapshot) {
          final subs = snapshot.data ?? const <Subscription>[];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundImage: (_avatarPath ?? '').trim().isEmpty
                            ? null
                            : FileImage(File(_avatarPath!)),
                        child: (_avatarPath ?? '').trim().isEmpty
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
                                  : _avatarPath!,
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
              Form(
                key: _formKey,
                child: Column(
                  children: [
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
                    TextFormField(
                      controller: _firstNameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Tên',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
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
                    DropdownButtonFormField<String>(
                      initialValue: _subscriptionId,
                      items: subs
                          .map(
                            (s) => DropdownMenuItem(
                              value: s.id,
                              child: Text('${s.id} - ${s.name ?? ''}'),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _subscriptionId = v),
                      decoration: const InputDecoration(
                        labelText: 'Gói cước',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile.adaptive(
                      value: _isActive,
                      onChanged: (v) => setState(() => _isActive = v),
                      title: const Text('Trạng thái hoạt động'),
                    ),
                    const SizedBox(height: 12),
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
                    TextFormField(
                      controller: _addressCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Địa chỉ',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed:
                            snapshot.connectionState == ConnectionState.waiting
                                ? null
                                : _save,
                        icon: const Icon(Icons.save),
                        label: const Text('Lưu'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
