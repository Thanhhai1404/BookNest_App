import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/db/app_database.dart';
import 'member_detail_page.dart';
import 'member_form_page.dart';
import 'member_view_model.dart';

class MemberListPage extends ConsumerWidget {
  const MemberListPage({super.key});

  String _fullName(Member m) {
    final parts = [m.lastName, m.middleName, m.firstName]
        .where((e) => (e ?? '').trim().isNotEmpty)
        .map((e) => e!.trim())
        .toList();
    return parts.isEmpty ? m.id : parts.join(' ');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(memberListStreamProvider);
    final state = ref.watch(memberListControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hội viên'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: SearchBar(
              hintText: 'Tìm theo tên hoặc SĐT',
              leading: const Icon(Icons.search),
              padding: const WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (value) => ref
                  .read(memberListControllerProvider.notifier)
                  .setQuery(value),
              trailing: [
                if (state.query.trim().isNotEmpty)
                  IconButton(
                    tooltip: 'Xoá tìm kiếm',
                    onPressed: () => ref
                        .read(memberListControllerProvider.notifier)
                        .setQuery(''),
                    icon: const Icon(Icons.clear),
                  )
              ],
            ),
          ),
          Expanded(
            child: membersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Lỗi: $e'),
                ),
              ),
              data: (members) {
                if (members.isEmpty) {
                  return const Center(
                    child: Text('Chưa có hội viên nào.'),
                  );
                }

                return ListView.separated(
                  itemCount: members.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final m = members[index];
                    final name = _fullName(m);

                    final avatarProvider = (m.avatarPath ?? '').trim().isEmpty
                        ? null
                        : FileImage(File(m.avatarPath!));

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: avatarProvider,
                        child: avatarProvider == null
                            ? Text(name.isNotEmpty ? name[0] : '?')
                            : null,
                      ),
                      title: Text(name),
                      subtitle: Text(
                          'Gói: ${m.subscriptionId} • SĐT: ${m.phone ?? '-'}'),
                      trailing: Icon(
                        m.isActive == false ? Icons.lock : Icons.chevron_right,
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => MemberDetailPage(memberId: m.id),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const MemberFormPage(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Thêm'),
      ),
    );
  }
}
