import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/db/app_database.dart';
import '../data/repositories/author_repository.dart';
import '../data/repositories/book_repository.dart';
import '../data/repositories/category_repository.dart';
import '../data/repositories/publisher_repository.dart';

class BookFormPage extends ConsumerStatefulWidget {
  const BookFormPage({super.key, this.existing});

  final Book? existing;

  @override
  ConsumerState<BookFormPage> createState() => _BookFormPageState();
}

class _BookFormPageState extends ConsumerState<BookFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleCtrl;
  late final TextEditingController _yearCtrl;
  late final TextEditingController _descriptionCtrl;

  int? _categoryId;
  int? _authorId;
  int? _publisherId;

  bool _saving = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final b = widget.existing;
    _titleCtrl = TextEditingController(text: b?.title ?? '');
    _yearCtrl = TextEditingController(
      text: b?.publishedYear == null ? '' : '${b!.publishedYear}',
    );
    _descriptionCtrl = TextEditingController(text: b?.description ?? '');

    _categoryId = b?.categoryId;
    _publisherId = b?.publisherId;

    // Author is N-N via book_authors; current repo only exposes first author on
    // list queries, so for edit mode we keep it empty for now.
    _authorId = null;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _yearCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  String _formatAuthor(Author a) {
    final parts = <String>[];
    for (final p in [a.lastName, a.middleName, a.firstName]) {
      final v = (p ?? '').trim();
      if (v.isNotEmpty) parts.add(v);
    }
    return parts.isEmpty ? 'Tác giả #${a.id}' : parts.join(' ');
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn thể loại.')),
      );
      return;
    }
    if (_authorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn tác giả.')),
      );
      return;
    }
    if (_publisherId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn nhà xuất bản.')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final repo = ref.read(bookRepositoryProvider);

      final title = _titleCtrl.text.trim();
      final yearRaw = _yearCtrl.text.trim();
      final desc = _descriptionCtrl.text.trim();

      final year = yearRaw.isEmpty ? null : int.tryParse(yearRaw);

      // Strict rules: required text fields already validated.
      // Book id strategy: keep manual/SQL ids as-is for now.
      final companion = BooksCompanion(
        // In Add mode, let repository generate a valid auto-increment id.
        id: _isEdit
            ? drift.Value(widget.existing!.id)
            : const drift.Value.absent(),
        title: drift.Value(title),
        publishedYear: drift.Value(year),
        description: drift.Value(desc),
        categoryId: drift.Value(_categoryId!),
        publisherId: drift.Value(_publisherId!),
        // keep other optional fields absent
        coverPrice: const drift.Value.absent(),
        totalQuantity: const drift.Value.absent(),
        coverPath: const drift.Value.absent(),
      );

      if (_isEdit) {
        await repo.updateBook(companion);
      } else {
        await repo.addBook(companion);
      }

      // TODO: Insert/update book_authors row based on _authorId (later).

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lưu thất bại: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Sửa sách' : 'Thêm sách'),
      ),
      body: FutureBuilder<
          (
            List<Category> categories,
            List<Author> authors,
            List<Publisher> publishers
          )>(
        future: () async {
          final cats =
              await ref.read(categoryRepositoryProvider).getAllCategories();
          final authors =
              await ref.read(authorRepositoryProvider).getAllAuthors();
          final pubs =
              await ref.read(publisherRepositoryProvider).getAllPublishers();
          return (cats, authors, pubs);
        }(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Lỗi tải dữ liệu: ${snapshot.error}'),
              ),
            );
          }

          final data = snapshot.data;
          final categories = data?.$1 ?? const <Category>[];
          final authors = data?.$2 ?? const <Author>[];
          final publishers = data?.$3 ?? const <Publisher>[];

          // Ensure dropdown defaults are valid after load.
          _categoryId =
              _categoryId != null && categories.any((c) => c.id == _categoryId)
                  ? _categoryId
                  : null;
          _authorId = _authorId != null && authors.any((a) => a.id == _authorId)
              ? _authorId
              : null;
          _publisherId = _publisherId != null &&
                  publishers.any((p) => p.id == _publisherId)
              ? _publisherId
              : null;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _titleCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Tên sách',
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
                      controller: _yearCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Năm xuất bản',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        final value = (v ?? '').trim();
                        if (value.isEmpty) return 'Bắt buộc.';
                        final year = int.tryParse(value);
                        if (year == null) return 'Năm không hợp lệ.';
                        if (year < 0 || year > 2200) return 'Năm không hợp lệ.';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descriptionCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Mô tả',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        final value = (v ?? '').trim();
                        if (value.isEmpty) return 'Bắt buộc.';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      initialValue: _categoryId,
                      items: categories
                          .map(
                            (c) => DropdownMenuItem(
                              value: c.id,
                              child: Text(c.name ?? 'Thể loại #${c.id}'),
                            ),
                          )
                          .toList(),
                      onChanged: _saving
                          ? null
                          : (v) => setState(() => _categoryId = v),
                      decoration: const InputDecoration(
                        labelText: 'Thể loại',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v == null ? 'Bắt buộc.' : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      initialValue: _authorId,
                      items: authors
                          .map(
                            (a) => DropdownMenuItem(
                              value: a.id,
                              child: Text(_formatAuthor(a)),
                            ),
                          )
                          .toList(),
                      onChanged:
                          _saving ? null : (v) => setState(() => _authorId = v),
                      decoration: const InputDecoration(
                        labelText: 'Tác giả',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v == null ? 'Bắt buộc.' : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      initialValue: _publisherId,
                      items: publishers
                          .map(
                            (p) => DropdownMenuItem(
                              value: p.id,
                              child: Text(p.name ?? 'NXB #${p.id}'),
                            ),
                          )
                          .toList(),
                      onChanged: _saving
                          ? null
                          : (v) => setState(() => _publisherId = v),
                      decoration: const InputDecoration(
                        labelText: 'Nhà xuất bản',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v == null ? 'Bắt buộc.' : null,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _saving ? null : _save,
                        icon: _saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
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
        },
      ),
    );
  }
}
