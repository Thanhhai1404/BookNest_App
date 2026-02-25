import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/barcode_scanner_view.dart';
import 'member_detail_page.dart';
import 'member_form_page.dart';
import 'member_view_model.dart';

class MemberListPage extends ConsumerStatefulWidget {
  const MemberListPage({super.key});

  @override
  ConsumerState<MemberListPage> createState() => _MemberListPageState();
}

class _MemberListPageState extends ConsumerState<MemberListPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openScanner() async {
    final code = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const BarcodeScannerView()),
    );
    if (code != null && code.isNotEmpty && mounted) {
      _searchController.text = code;
      ref.read(memberListControllerProvider.notifier).setQueryImmediate(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(memberListControllerProvider);
    final scheme = Theme.of(context).colorScheme;

    // Sync controller with state when cleared externally
    if (state.query.isEmpty && _searchController.text.isNotEmpty) {
      _searchController.clear();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hội viên'),
        actions: [
          IconButton(
            tooltip: 'Tải lại',
            onPressed: () =>
                ref.read(memberListControllerProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Tìm theo tên, SĐT hoặc mã hội viên',
              leading: const Icon(Icons.search),
              padding: const WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (value) => ref
                  .read(memberListControllerProvider.notifier)
                  .setQuery(value),
              trailing: [
                // Scanner button
                IconButton(
                  tooltip: 'Quét mã thẻ',
                  onPressed: _openScanner,
                  icon: const Icon(Icons.qr_code_scanner),
                ),
                // Clear button
                if (state.query.trim().isNotEmpty)
                  IconButton(
                    tooltip: 'Xoá tìm kiếm',
                    onPressed: () {
                      _searchController.clear();
                      ref
                          .read(memberListControllerProvider.notifier)
                          .clearQuery();
                    },
                    icon: const Icon(Icons.clear),
                  ),
              ],
            ),
          ),
          Expanded(
            child: _buildMemberList(context, state, scheme),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final saved = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => const MemberFormPage(),
            ),
          );
          if (saved == true && context.mounted) {
            ref.read(memberListControllerProvider.notifier).refresh();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Thêm'),
      ),
    );
  }

  Widget _buildMemberList(
    BuildContext context,
    MemberListState state,
    ColorScheme scheme,
  ) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 64, color: scheme.error),
              const SizedBox(height: 16),
              Text(
                'Lỗi tải dữ liệu',
                style: TextStyle(
                  color: scheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                state.error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () =>
                    ref.read(memberListControllerProvider.notifier).refresh(),
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.members.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline, size: 64, color: scheme.outline),
            const SizedBox(height: 16),
            Text(
              state.query.isNotEmpty
                  ? 'Không tìm thấy hội viên phù hợp'
                  : 'Chưa có hội viên nào.',
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(memberListControllerProvider.notifier).refresh(),
      child: ListView.separated(
        itemCount: state.members.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final m = state.members[index];

          // Avatar - nếu có avatarUrl thì dùng NetworkImage, nếu không thì hiển thị chữ cái đầu
          ImageProvider? avatarProvider;
          if (m.avatarUrl != null && m.avatarUrl!.isNotEmpty) {
            avatarProvider = NetworkImage(m.avatarUrl!);
          }

          return ListTile(
            leading: CircleAvatar(
              backgroundImage: avatarProvider,
              child: avatarProvider == null
                  ? Text(m.fullName.isNotEmpty ? m.fullName[0].toUpperCase() : '?')
                  : null,
            ),
            title: Text(m.fullName),
            subtitle: Text(
                'Gói: ${m.packageName} • SĐT: ${m.phone ?? '-'}'),
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
      ),
    );
  }
}
