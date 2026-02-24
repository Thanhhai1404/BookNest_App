import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../books/data/repositories/supabase_author_repository.dart';
import '../../books/data/repositories/supabase_book_repository.dart';
import '../../books/data/repositories/supabase_category_repository.dart';
import '../../books/data/repositories/supabase_publisher_repository.dart';

class BookFormPage extends ConsumerStatefulWidget {
  const BookFormPage({super.key, this.existing});

  final SupabaseBookTitle? existing;

  @override
  ConsumerState<BookFormPage> createState() => _BookFormPageState();
}

class _BookFormPageState extends ConsumerState<BookFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _idCtrl;
  late final TextEditingController _titleCtrl;
  late final TextEditingController _yearCtrl;
  late final TextEditingController _descriptionCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _copiesCtrl;

  int? _categoryId;
  int? _authorId;
  int? _publisherId;

  bool _saving = false;

  // Ảnh bìa
  File? _selectedImageFile;
  final ImagePicker _imagePicker = ImagePicker();

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final b = widget.existing;
    _idCtrl = TextEditingController(text: b?.id ?? '');
    _titleCtrl = TextEditingController(text: b?.title ?? '');
    _yearCtrl = TextEditingController(
      text: b?.publishYear == null ? '' : '${b!.publishYear}',
    );
    _descriptionCtrl = TextEditingController(text: b?.description ?? '');
    _priceCtrl = TextEditingController(
      text: b?.price == null ? '' : '${b!.price}',
    );
    _copiesCtrl = TextEditingController(text: _isEdit ? '' : '1');

    _categoryId = b?.categoryId;
    _publisherId = b?.publisherId;
    _authorId = null;
  }

  @override
  void dispose() {
    _idCtrl.dispose();
    _titleCtrl.dispose();
    _yearCtrl.dispose();
    _descriptionCtrl.dispose();
    _priceCtrl.dispose();
    _copiesCtrl.dispose();
    super.dispose();
  }
  String _formatAuthor(SupabaseAuthor a) {
    return a.fullName.isNotEmpty ? a.fullName : 'Tác giả #${a.id}';
  }
  /// Chọn ảnh từ thư viện
  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          _selectedImageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi chọn ảnh: $e')),
        );
      }
    }
  }

  /// Widget hiển thị ảnh bìa
  Widget _buildCoverImageWidget() {
    // Nếu đã chọn ảnh mới
    if (_selectedImageFile != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.file(
            _selectedImageFile!,
            fit: BoxFit.cover,
          ),
          Positioned(
            top: 8,
            right: 8,
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.black54,
              child: IconButton(
                icon: const Icon(Icons.close, size: 16, color: Colors.white),
                onPressed: () => setState(() => _selectedImageFile = null),
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      );
    }

    // Nếu đang sửa và có ảnh bìa cũ
    if (_isEdit && widget.existing?.imageUrl != null && widget.existing!.imageUrl!.isNotEmpty) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            widget.existing!.imageUrl!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildPlaceholder();
            },
          ),
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Nhấn để thay đổi',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ],
      );
    }

    // Placeholder mặc định
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.camera_alt, size: 48, color: Colors.grey[500]),
        const SizedBox(height: 8),
        Text(
          'Nhấn để chọn ảnh bìa',
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
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
      final repo = ref.read(supabaseBookRepositoryProvider);

      final id = _idCtrl.text.trim();
      final title = _titleCtrl.text.trim();
      final yearRaw = _yearCtrl.text.trim();
      final desc = _descriptionCtrl.text.trim();
      final priceRaw = _priceCtrl.text.trim();
      final copiesRaw = _copiesCtrl.text.trim();

      final year = yearRaw.isEmpty ? null : int.tryParse(yearRaw);
      final price = priceRaw.isEmpty ? null : int.tryParse(priceRaw);
      final copies = copiesRaw.isEmpty ? 1 : int.tryParse(copiesRaw) ?? 1;      if (_isEdit) {
        await repo.updateBookTitle(
          id: widget.existing!.id,
          title: title,
          publishYear: year,
          price: price,
          categoryId: _categoryId,
          publisherId: _publisherId,
          description: desc.isNotEmpty ? desc : null,
          coverImage: _selectedImageFile,
        );
      } else {
        await repo.addBookTitle(
          id: id,
          title: title,
          publishYear: year,
          price: price,
                    categoryId: _categoryId,
          publisherId: _publisherId,
          description: desc.isNotEmpty ? desc : null,
          numberOfCopies: copies,
          coverImage: _selectedImageFile,
        );

        // Thêm tác giả vào sách
        final authorRepo = ref.read(supabaseAuthorRepositoryProvider);
        await authorRepo.addAuthorToBook(id, _authorId!, null);
      }

      // Invalidate provider để refresh danh sách sách
      ref.invalidate(supabaseBookTitlesProvider);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEdit ? 'Cập nhật sách thành công!' : 'Thêm sách thành công!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lưu thất bại: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch các providers từ Supabase
    final categoriesAsync = ref.watch(supabaseCategoriesProvider);
    final authorsAsync = ref.watch(supabaseAuthorsProvider);
    final publishersAsync = ref.watch(supabasePublishersProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Sửa sách' : 'Thêm sách'),
        actions: [
          // Nút refresh để tải lại dữ liệu từ Supabase
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Tải lại danh sách',
            onPressed: () {
              ref.invalidate(supabaseCategoriesProvider);
              ref.invalidate(supabaseAuthorsProvider);
              ref.invalidate(supabasePublishersProvider);
            },
          ),
        ],
      ),
      body: _buildBody(categoriesAsync, authorsAsync, publishersAsync),
    );
  }

  Widget _buildBody(
    AsyncValue<List<SupabaseCategory>> categoriesAsync,
    AsyncValue<List<SupabaseAuthor>> authorsAsync,
    AsyncValue<List<SupabasePublisher>> publishersAsync,
  ) {
    // Kiểm tra loading
    if (categoriesAsync.isLoading ||
        authorsAsync.isLoading ||
        publishersAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Kiểm tra lỗi
    if (categoriesAsync.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Lỗi tải thể loại: ${categoriesAsync.error}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(supabaseCategoriesProvider),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    if (authorsAsync.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Lỗi tải tác giả: ${authorsAsync.error}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(supabaseAuthorsProvider),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    if (publishersAsync.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Lỗi tải NXB: ${publishersAsync.error}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(supabasePublishersProvider),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    final categories = categoriesAsync.value ?? [];
    final authors = authorsAsync.value ?? [];
    final publishers = publishersAsync.value ?? [];

    // Ensure dropdown defaults are valid after load.
    _categoryId =
        _categoryId != null && categories.any((c) => c.id == _categoryId)
            ? _categoryId
            : null;
    _authorId = _authorId != null && authors.any((a) => a.id == _authorId)
        ? _authorId
        : null;
    _publisherId =
        _publisherId != null && publishers.any((p) => p.id == _publisherId)
            ? _publisherId
            : null;    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              // Widget chọn ảnh bìa
              GestureDetector(
                onTap: _saving ? null : _pickImage,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[400]!),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _buildCoverImageWidget(),
                  ),
                ),
              ),
              // Mã sách (chỉ hiện khi thêm mới)
              if (!_isEdit) ...[
                TextFormField(
                  controller: _idCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Mã sách (MaDS)',
                    hintText: 'VD: SACH001',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    final value = (v ?? '').trim();
                    if (value.isEmpty) return 'Bắt buộc.';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
              ],
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
                  if (value.isEmpty) return null; // Không bắt buộc
                  final year = int.tryParse(value);
                  if (year == null) return 'Năm không hợp lệ.';
                  if (year < 0 || year > 2200) return 'Năm không hợp lệ.';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Giá bìa (VNĐ)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Mô tả',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: _categoryId,
                items: categories
                    .map(
                      (c) => DropdownMenuItem(
                        value: c.id,
                        child: Text(c.name.isNotEmpty ? c.name : 'Thể loại #${c.id}'),
                      ),
                    )
                    .toList(),
                onChanged:
                    _saving ? null : (v) => setState(() => _categoryId = v),
                decoration: const InputDecoration(
                  labelText: 'Thể loại',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null ? 'Bắt buộc.' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: _authorId,
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
                value: _publisherId,
                items: publishers
                    .map(
                      (p) => DropdownMenuItem(
                        value: p.id,
                        child: Text(p.name.isNotEmpty ? p.name : 'NXB #${p.id}'),
                      ),
                    )
                    .toList(),
                onChanged:
                    _saving ? null : (v) => setState(() => _publisherId = v),
                decoration: const InputDecoration(
                  labelText: 'Nhà xuất bản',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null ? 'Bắt buộc.' : null,
              ),
              // Số lượng bản sao (chỉ khi thêm mới)
              if (!_isEdit) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _copiesCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Số lượng bản sao',
                    hintText: 'Mặc định: 1',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    final value = (v ?? '').trim();
                    if (value.isEmpty) return null;
                    final copies = int.tryParse(value);
                    if (copies == null || copies < 1) {
                      return 'Số lượng phải >= 1';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
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
}
