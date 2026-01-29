import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/barcode_scanner_view.dart';
import 'book_form_page.dart';
import 'book_detail_page.dart';
import '../data/repositories/book_repository.dart';
import '../domain/models/book_with_details.dart';
import 'book_list_view_model.dart';

class BookListPage extends ConsumerStatefulWidget {
  const BookListPage({super.key});

  @override
  ConsumerState<BookListPage> createState() => _BookListPageState();
}

class _BookListPageState extends ConsumerState<BookListPage> {
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
      ref.read(bookListViewModelProvider.notifier).setQueryImmediate(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bookListViewModelProvider);
    final scheme = Theme.of(context).colorScheme;

    // Sync controller with state when cleared externally
    if (state.query.isEmpty && _searchController.text.isNotEmpty) {
      _searchController.clear();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sách'),
        actions: [
          IconButton(
            tooltip: 'Tải lại',
            onPressed: () =>
                ref.read(bookListViewModelProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: Column(
        children: [
          // Search bar with scanner
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Tìm theo tên sách, tác giả hoặc mã sách',
              leading: const Icon(Icons.search),
              padding: const WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (value) =>
                  ref.read(bookListViewModelProvider.notifier).setQuery(value),
              trailing: [
                // Scanner button
                IconButton(
                  tooltip: 'Quét mã vạch',
                  onPressed: _openScanner,
                  icon: const Icon(Icons.qr_code_scanner),
                ),
                // Clear button
                if (state.query.trim().isNotEmpty)
                  IconButton(
                    tooltip: 'Xoá tìm kiếm',
                    onPressed: () {
                      _searchController.clear();
                      ref.read(bookListViewModelProvider.notifier).clearQuery();
                    },
                    icon: const Icon(Icons.clear),
                  ),
              ],
            ),
          ),

          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _FilterChip(
                  label: 'Tất cả',
                  selected: state.filter == BookAvailabilityFilter.all,
                  onSelected: () => ref
                      .read(bookListViewModelProvider.notifier)
                      .setFilter(BookAvailabilityFilter.all),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Sẵn sàng',
                  selected: state.filter == BookAvailabilityFilter.available,
                  onSelected: () => ref
                      .read(bookListViewModelProvider.notifier)
                      .setFilter(BookAvailabilityFilter.available),
                  color: Colors.green,
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Hết hàng',
                  selected: state.filter == BookAvailabilityFilter.outOfStock,
                  onSelected: () => ref
                      .read(bookListViewModelProvider.notifier)
                      .setFilter(BookAvailabilityFilter.outOfStock),
                  color: Colors.red,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Book list
          Expanded(
            child: _buildBookList(context, state, scheme),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final saved = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => const BookFormPage()),
          );
          if (saved == true && context.mounted) {
            ref.read(bookListViewModelProvider.notifier).refresh();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Thêm'),
      ),
    );
  }

  Widget _buildBookList(
    BuildContext context,
    BookListState state,
    ColorScheme scheme,
  ) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.books.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 64, color: scheme.outline),
            const SizedBox(height: 16),
            Text(
              state.query.isNotEmpty ||
                      state.filter != BookAvailabilityFilter.all
                  ? 'Không tìm thấy sách phù hợp'
                  : 'Chưa có sách nào.',
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(bookListViewModelProvider.notifier).refresh(),
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.6,
        ),
        itemCount: state.books.length,
        itemBuilder: (context, index) {
          final item = state.books[index];
          return _BookCard(item: item);
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
    this.color,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final chipColor = color ?? scheme.primary;

    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor: chipColor.withAlpha(40),
      checkmarkColor: chipColor,
      side: selected ? BorderSide(color: chipColor) : null,
    );
  }
}

class _BookCard extends StatelessWidget {
  const _BookCard({required this.item});

  final BookWithDetails item;

  @override
  Widget build(BuildContext context) {
    final book = item.book;
    final scheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BookDetailPage(bookId: book.id),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cover placeholder
            Container(
              height: 140,
              color: scheme.surfaceContainerHighest,
              child: const Icon(Icons.menu_book, size: 48),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title ?? book.id,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.authorName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.publisherName} • ${item.categoryName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
