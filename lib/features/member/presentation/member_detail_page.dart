import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/db/app_database.dart';
import 'member_form_page.dart';
import 'member_view_model.dart';

class MemberDetailPage extends ConsumerWidget {
  const MemberDetailPage({super.key, required this.memberId});

  final String memberId;

  String _fullName(Member m) {
    final parts = <String>[];
    for (final p in [m.lastName, m.middleName, m.firstName]) {
      final v = (p ?? '').trim();
      if (v.isNotEmpty) parts.add(v);
    }
    return parts.isEmpty ? m.id : parts.join(' ');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<Member?>(
      future: ref.read(memberRepositoryProvider).getMemberById(memberId),
      builder: (context, snapshot) {
        final member = snapshot.data;

        return Scaffold(
          appBar: AppBar(
            title: Text(member == null ? 'Hội viên' : _fullName(member)),
            actions: [
              IconButton(
                tooltip: 'Sửa',
                onPressed: member == null
                    ? null
                    : () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => MemberFormPage(existing: member),
                          ),
                        );
                      },
                icon: const Icon(Icons.edit),
              ),
              IconButton(
                tooltip: 'Xoá',
                onPressed: member == null
                    ? null
                    : () async {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Xoá hội viên?'),
                            content: Text(
                                'Bạn chắc chắn muốn xoá ${_fullName(member)}?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Huỷ'),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('Xoá'),
                              ),
                            ],
                          ),
                        );
                        if (ok != true) return;

                        await ref
                            .read(memberListControllerProvider.notifier)
                            .delete(member.id);
                        if (context.mounted) Navigator.of(context).pop();
                      },
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          body: snapshot.connectionState == ConnectionState.waiting
              ? const Center(child: CircularProgressIndicator())
              : member == null
                  ? const Center(child: Text('Không tìm thấy hội viên.'))
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 32,
                                  backgroundImage:
                                      (member.avatarPath ?? '').trim().isEmpty
                                          ? null
                                          : FileImage(File(member.avatarPath!)),
                                  child:
                                      (member.avatarPath ?? '').trim().isEmpty
                                          ? Text(_fullName(member)[0])
                                          : null,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _fullName(member),
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge,
                                      ),
                                      const SizedBox(height: 4),
                                      Text('Mã: ${member.id}'),
                                      Text('SĐT: ${member.phone ?? '-'}'),
                                      Text('Email: ${member.email}'),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Card(
                          child: Column(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.card_membership),
                                title: const Text('Gói hội viên'),
                                subtitle: Text(member.subscriptionId),
                              ),
                              const Divider(height: 1),
                              ListTile(
                                leading: const Icon(Icons.location_on_outlined),
                                title: const Text('Địa chỉ'),
                                subtitle: Text(member.address ?? '-'),
                              ),
                              const Divider(height: 1),
                              ListTile(
                                leading: const Icon(
                                    Icons.account_balance_wallet_outlined),
                                title: const Text('Số dư ví'),
                                subtitle:
                                    Text('${member.walletBalance ?? 0} VND'),
                              ),
                              const Divider(height: 1),
                              ListTile(
                                leading:
                                    const Icon(Icons.emoji_events_outlined),
                                title: const Text('Điểm tích luỹ'),
                                subtitle: Text('${member.points ?? 0}'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Chức năng thẻ thành viên sẽ làm sau.'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.qr_code_2),
                          label: const Text('Xem thẻ thành viên'),
                        ),
                      ],
                    ),
        );
      },
    );
  }
}
