import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/enums.dart';
import 'book_detail_view_model.dart';

class BookDetailPage extends ConsumerWidget {
  const BookDetailPage({super.key, required this.bookId});

  final String bookId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(bookDetailViewModelProvider(bookId));

    return Scaffold(
      appBar: AppBar(title: Text('Chi tiết $bookId')),
      body: stateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Lỗi: $e'),
          ),
        ),
        data: (state) {
          return Column(
            children: [
              _HeaderCard(
                title: state.book.title ?? state.book.id,
                author: state.authorName,
                subtitle: '${state.publisherName} • ${state.categoryName}',
                description: state.book.description ?? '',
              ),
              const Divider(height: 1),
              Expanded(
                child: state.copies.isEmpty
                    ? const Center(child: Text('Chưa có bản sao nào.'))
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.copies.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final c = state.copies[index];
                          return _CopyTile(copyId: c.id, status: c.status);
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final notifier = ref.read(bookDetailViewModelProvider(bookId).notifier);
          try {
            await notifier.addBookCopy();
          } catch (e) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Nhập kho thất bại: $e')),
            );
          }
        },
        icon: const Icon(Icons.library_add),
        label: const Text('Thêm bản sao'),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.title,
    required this.author,
    required this.subtitle,
    required this.description,
  });

  final String title;
  final String author;
  final String subtitle;
  final String description;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 180,
              color: scheme.surfaceContainerHighest,
              child: const Icon(Icons.menu_book, size: 64),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                  if (description.trim().isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CopyTile extends StatelessWidget {
  const _CopyTile({required this.copyId, required this.status});

  final String copyId;
  final int? status;

  @override
  Widget build(BuildContext context) {
    final s = BookStatus.fromCode(status ?? BookStatus.available.code);

    final (label, color) = switch (s) {
      BookStatus.available => ('Sẵn sàng', Colors.green),
      BookStatus.borrowed => ('Đang mượn', Colors.red),
      BookStatus.lost => ('Mất', Colors.grey),
      BookStatus.damaged => ('Hỏng', Colors.orange),
    };

    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      title: Text(copyId, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withAlpha(28),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withAlpha(120)),
        ),
        child: Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
