import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;

/// Model cho Đầu sách (Book Title) từ Supabase
/// Mapping với bảng: dau_sach
/// Cột: MaDS (text PK), TenSach, NamXB, GiaBia, TongSoLuong, MoTa, MaTL (bigint), MaNXB (bigint)
class SupabaseBookTitle {
  final String id; // MaDS là text
  final String title;
  final int? publishYear;
  final int? price;
  final int totalCopies;
  final String? description;
  final int? categoryId; // bigint trong DB
  final String? categoryName;
  final int? publisherId; // bigint trong DB
  final String? publisherName;

  SupabaseBookTitle({
    required this.id,
    required this.title,
    this.publishYear,
    this.price,
    this.totalCopies = 0,
    this.description,
    this.categoryId,
    this.categoryName,
    this.publisherId,
    this.publisherName,
  });
  factory SupabaseBookTitle.fromJson(Map<String, dynamic> json) {
    // Xử lý join với bảng the_loai (lowercase column names)
    String? categoryName;
    if (json['the_loai'] != null && json['the_loai'] is Map) {
      categoryName = json['the_loai']['tentl'] as String?;
    }

    // Xử lý join với bảng nha_xuat_ban (lowercase column names)
    String? publisherName;
    if (json['nha_xuat_ban'] != null && json['nha_xuat_ban'] is Map) {
      publisherName = json['nha_xuat_ban']['tennxb'] as String?;
    }

    // Helper để parse số (bigint có thể trả về num)
    int? parseIntOrNull(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString());
    }

    return SupabaseBookTitle(
      id: json['mads'] as String,
      title: json['tensach'] as String? ?? '',
      publishYear: parseIntOrNull(json['namxb']),
      price: parseIntOrNull(json['giabia']),
      totalCopies: parseIntOrNull(json['tongsoluong']) ?? 0,
      description: json['mota'] as String?,
      categoryId: parseIntOrNull(json['matl']),
      categoryName: categoryName,
      publisherId: parseIntOrNull(json['manxb']),
      publisherName: publisherName,
    );
  }
  Map<String, dynamic> toInsertJson() {
    return {
      'mads': id,
      'tensach': title,
      'namxb': publishYear,
      'giabia': price,
      'tongsoluong': totalCopies,
      'mota': description,
      'matl': categoryId,
      'manxb': publisherId,
    };
  }
}

/// Model cho Sách (Book Copy) từ Supabase
/// Mapping với bảng: sach
/// Cột: MaVach (text PK), ViTri, TinhTrang, TrangThai (int), MaDS
class SupabaseBookCopy {
  final String barcode; // MaVach là PK
  final String bookTitleId; // MaDS
  final String? location;
  final String? condition;
  final int status; // 0: Sẵn sàng, 1: Đang mượn, 2: Đã đặt, 3: Hỏng/Mất

  // Thông tin đầu sách (nếu join)
  final SupabaseBookTitle? bookTitle;

  SupabaseBookCopy({
    required this.barcode,
    required this.bookTitleId,
    this.location,
    this.condition,
    this.status = 0,
    this.bookTitle,
  });
  factory SupabaseBookCopy.fromJson(Map<String, dynamic> json) {
    SupabaseBookTitle? bookTitle;
    if (json['dau_sach'] != null && json['dau_sach'] is Map) {
      bookTitle = SupabaseBookTitle.fromJson(json['dau_sach'] as Map<String, dynamic>);
    }

    // Helper để parse số
    int parseIntOrDefault(dynamic value, int defaultValue) {
      if (value == null) return defaultValue;
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString()) ?? defaultValue;
    }

    return SupabaseBookCopy(
      barcode: json['mavach'] as String,
      bookTitleId: json['mads'] as String,
      location: json['vitri'] as String?,
      condition: json['tinhtrang'] as String?,
      status: parseIntOrDefault(json['trangthai'], 0),
      bookTitle: bookTitle,
    );
  }
  Map<String, dynamic> toInsertJson() {
    return {
      'mavach': barcode,
      'mads': bookTitleId,
      'vitri': location,
      'tinhtrang': condition,
      'trangthai': status,
    };
  }

  /// Kiểm tra sách có sẵn để mượn không
  bool get isAvailable => status == 0;

  /// Lấy tên trạng thái
  String get statusName {
    switch (status) {
      case 0:
        return 'Sẵn sàng';
      case 1:
        return 'Đang mượn';
      case 2:
        return 'Đã đặt trước';
      case 3:
        return 'Hỏng/Mất';
      default:
        return 'Không xác định';
    }
  }
}

/// Repository để quản lý sách trên Supabase
class SupabaseBookRepository {
  SupabaseBookRepository(this._client);

  final SupabaseClient _client;

  /// Tên các bảng (đúng với SQL của bạn)
  static const String _bookTitleTable = 'dau_sach';
  static const String _bookCopyTable = 'sach';
  static const String _storageBucket = 'book_covers';

  // ==================== UPLOAD ẢNH BÌA ====================

  /// Upload ảnh bìa lên Supabase Storage
  /// Trả về URL công khai của ảnh
  Future<String> uploadCoverImage(File imageFile) async {
    try {
      // Tạo tên file unique
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${path.basename(imageFile.path)}';
      final filePath = 'covers/$fileName';

      // Upload file
      await _client.storage.from(_storageBucket).upload(
            filePath,
            imageFile,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: false,
            ),
          );

      // Lấy URL công khai
      final publicUrl =
          _client.storage.from(_storageBucket).getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      throw Exception('Lỗi khi upload ảnh bìa: $e');
    }
  }

  /// Upload ảnh bìa từ bytes (cho web hoặc memory image)
  Future<String> uploadCoverImageBytes(Uint8List bytes, String fileName) async {
    try {
      final uniqueFileName =
          '${DateTime.now().millisecondsSinceEpoch}_$fileName';
      final filePath = 'covers/$uniqueFileName';

      await _client.storage.from(_storageBucket).uploadBinary(
            filePath,
            bytes,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: false,
            ),
          );

      final publicUrl =
          _client.storage.from(_storageBucket).getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      throw Exception('Lỗi khi upload ảnh bìa: $e');
    }
  }

  /// Xóa ảnh bìa khỏi Storage
  Future<void> deleteCoverImage(String imageUrl) async {
    try {
      // Extract path from URL
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;

      // Tìm vị trí 'covers' trong path
      final coversIndex = pathSegments.indexOf('covers');
      if (coversIndex == -1) return;

      final filePath = pathSegments.sublist(coversIndex).join('/');

      await _client.storage.from(_storageBucket).remove([filePath]);
    } catch (e) {
      // Không throw lỗi nếu xóa ảnh thất bại
      debugPrint('Warning: Không thể xóa ảnh bìa: $e');
    }
  }
  // ==================== ĐẦU SÁCH (BOOK TITLES) ====================
  /// Lấy danh sách tất cả đầu sách (kèm thông tin thể loại và NXB)
  Future<List<SupabaseBookTitle>> getBookTitles() async {
    try {
      // Thử query đơn giản trước, không join
      final response = await _client
          .from(_bookTitleTable)
          .select()
          .order('tensach', ascending: true);

      return (response as List)
          .map((json) => SupabaseBookTitle.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Lỗi khi lấy danh sách đầu sách: $e');
    }
  }  /// Lấy đầu sách theo ID (MaDS)
  Future<SupabaseBookTitle?> getBookTitleById(String id) async {
    try {
      final response = await _client
          .from(_bookTitleTable)
          .select()
          .eq('mads', id)
          .maybeSingle();

      if (response == null) return null;
      return SupabaseBookTitle.fromJson(response);
    } catch (e) {
      throw Exception('Lỗi khi lấy đầu sách: $e');
    }
  }
  /// Tìm kiếm đầu sách theo từ khóa
  Future<List<SupabaseBookTitle>> searchBookTitles(String keyword) async {
    try {
      final response = await _client
          .from(_bookTitleTable)
          .select()
          .or('tensach.ilike.%$keyword%,mads.ilike.%$keyword%')
          .order('tensach', ascending: true);

      return (response as List)
          .map((json) => SupabaseBookTitle.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Lỗi khi tìm kiếm đầu sách: $e');
    }
  }
  /// Lấy đầu sách theo thể loại
  Future<List<SupabaseBookTitle>> getBookTitlesByCategory(int categoryId) async {
    try {
      final response = await _client
          .from(_bookTitleTable)
          .select()
          .eq('matl', categoryId)
          .order('tensach', ascending: true);

      return (response as List)
          .map((json) => SupabaseBookTitle.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Lỗi khi lấy sách theo thể loại: $e');
    }
  }
  /// Thêm đầu sách mới
  /// [numberOfCopies] - Số lượng bản sao cần tạo
  Future<SupabaseBookTitle> addBookTitle({
    required String id, // MaDS - bạn cần tự tạo mã
    required String title,
    int? publishYear,
    int? price,
    int? categoryId,
    int? publisherId,
    String? description,
    int numberOfCopies = 1,
  }) async {
    try {
      // Insert đầu sách
      final bookTitleResponse = await _client
          .from(_bookTitleTable)
          .insert({
            'mads': id,
            'tensach': title,
            'namxb': publishYear,
            'giabia': price,
            'tongsoluong': numberOfCopies,
            'mota': description,
            'matl': categoryId,
            'manxb': publisherId,
          })
          .select()
          .single();

      final bookTitle = SupabaseBookTitle.fromJson(bookTitleResponse);

      // Tạo các bản sao sách
      if (numberOfCopies > 0) {
        final copies = List.generate(numberOfCopies, (index) {
          return {
            'mavach': '$id-${(index + 1).toString().padLeft(3, '0')}',
            'mads': id,
            'trangthai': 0, // Sẵn sàng
            'tinhtrang': 'Tốt',
          };
        });

        await _client.from(_bookCopyTable).insert(copies);
      }

      return bookTitle;
    } catch (e) {
      throw Exception('Lỗi khi thêm đầu sách: $e');
    }
  }
  /// Cập nhật đầu sách
  Future<SupabaseBookTitle> updateBookTitle({
    required String id,
    String? title,
    int? publishYear,
    int? price,
    int? categoryId,
    int? publisherId,
    String? description,
    int? totalCopies,
  }) async {
    try {
      // Build update data - chỉ update những field được truyền vào
      final updateData = <String, dynamic>{};
      if (title != null) updateData['tensach'] = title;
      if (publishYear != null) updateData['namxb'] = publishYear;
      if (price != null) updateData['giabia'] = price;
      if (categoryId != null) updateData['matl'] = categoryId;
      if (publisherId != null) updateData['manxb'] = publisherId;
      if (description != null) updateData['mota'] = description;
      if (totalCopies != null) updateData['tongsoluong'] = totalCopies;

      if (updateData.isEmpty) {
        // Không có gì để update, trả về book hiện tại
        final current = await getBookTitleById(id);
        if (current == null) throw Exception('Không tìm thấy đầu sách');
        return current;
      }

      final response = await _client
          .from(_bookTitleTable)
          .update(updateData)
          .eq('mads', id)
          .select()
          .single();

      return SupabaseBookTitle.fromJson(response);
    } catch (e) {
      throw Exception('Lỗi khi cập nhật đầu sách: $e');
    }
  }
  /// Xóa đầu sách (và tất cả bản sao)
  Future<void> deleteBookTitle(String id) async {
    try {
      // Xóa các bản sao trước (do foreign key)
      await _client.from(_bookCopyTable).delete().eq('mads', id);

      // Xóa đầu sách
      await _client.from(_bookTitleTable).delete().eq('mads', id);
    } catch (e) {
      throw Exception('Lỗi khi xóa đầu sách: $e');
    }
  }

  // ==================== BẢN SAO SÁCH (BOOK COPIES) ====================
  /// Lấy danh sách bản sao của một đầu sách
  Future<List<SupabaseBookCopy>> getBookCopies(String bookTitleId) async {
    try {
      final response = await _client
          .from(_bookCopyTable)
          .select('*, dau_sach:mads(*)')
          .eq('mads', bookTitleId)
          .order('mavach', ascending: true);

      return (response as List)
          .map((json) => SupabaseBookCopy.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Lỗi khi lấy danh sách bản sao: $e');
    }
  }

  /// Lấy tất cả bản sao
  Future<List<SupabaseBookCopy>> getAllBookCopies() async {
    try {
      final response = await _client
          .from(_bookCopyTable)
          .select('*, dau_sach:mads(*)')
          .order('mavach', ascending: true);

      return (response as List)
          .map((json) => SupabaseBookCopy.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Lỗi khi lấy danh sách bản sao: $e');
    }
  }

  /// Lấy bản sao theo barcode (MaVach)
  Future<SupabaseBookCopy?> getBookCopyByBarcode(String barcode) async {
    try {
      final response = await _client
          .from(_bookCopyTable)
          .select('*, dau_sach:mads(*)')
          .eq('mavach', barcode)
          .maybeSingle();

      if (response == null) return null;
      return SupabaseBookCopy.fromJson(response);
    } catch (e) {
      throw Exception('Lỗi khi lấy bản sao theo barcode: $e');
    }
  }

  /// Lấy bản sao sẵn sàng của một đầu sách
  Future<List<SupabaseBookCopy>> getAvailableCopies(String bookTitleId) async {
    try {
      final response = await _client
          .from(_bookCopyTable)
          .select('*, dau_sach:mads(*)')
          .eq('mads', bookTitleId)
          .eq('trangthai', 0) // Sẵn sàng
          .order('mavach', ascending: true);

      return (response as List)
          .map((json) => SupabaseBookCopy.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Lỗi khi lấy bản sao sẵn sàng: $e');
    }
  }
  /// Thêm bản sao mới
  Future<SupabaseBookCopy> addBookCopy({
    required String barcode,
    required String bookTitleId,
    String? location,
    String? condition,
    int status = 0,
  }) async {
    try {
      final response = await _client
          .from(_bookCopyTable)
          .insert({
            'mavach': barcode,
            'mads': bookTitleId,
            'vitri': location,
            'tinhtrang': condition ?? 'Tốt',
            'trangthai': status,
          })
          .select('*, dau_sach:mads(*)')
          .single();

      // Cập nhật số lượng trong đầu sách
      await _updateBookTitleCounts(bookTitleId);

      return SupabaseBookCopy.fromJson(response);
    } catch (e) {
      throw Exception('Lỗi khi thêm bản sao: $e');
    }
  }

  /// Cập nhật trạng thái bản sao
  /// status: 0 = Sẵn sàng, 1 = Đang mượn, 2 = Đã đặt, 3 = Hỏng/Mất
  Future<SupabaseBookCopy> updateBookCopyStatus(
      String barcode, int status) async {
    try {
      final response = await _client
          .from(_bookCopyTable)
          .update({'trangthai': status})
          .eq('mavach', barcode)
          .select('*, dau_sach:mads(*)')
          .single();

      final copy = SupabaseBookCopy.fromJson(response);

      // Cập nhật số lượng trong đầu sách
      await _updateBookTitleCounts(copy.bookTitleId);

      return copy;
    } catch (e) {
      throw Exception('Lỗi khi cập nhật trạng thái bản sao: $e');
    }
  }

  /// Cập nhật thông tin bản sao
  Future<SupabaseBookCopy> updateBookCopy({
    required String barcode,
    String? location,
    String? condition,
    int? status,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (location != null) updateData['vitri'] = location;
      if (condition != null) updateData['tinhtrang'] = condition;
      if (status != null) updateData['trangthai'] = status;

      final response = await _client
          .from(_bookCopyTable)
          .update(updateData)
          .eq('mavach', barcode)
          .select('*, dau_sach:mads(*)')
          .single();

      final copy = SupabaseBookCopy.fromJson(response);

      // Cập nhật số lượng trong đầu sách nếu status thay đổi
      if (status != null) {
        await _updateBookTitleCounts(copy.bookTitleId);
      }

      return SupabaseBookCopy.fromJson(response);
    } catch (e) {
      throw Exception('Lỗi khi cập nhật bản sao: $e');
    }
  }

  /// Xóa bản sao
  Future<void> deleteBookCopy(String barcode) async {
    try {
      // Lấy thông tin để update counts
      final copy = await getBookCopyByBarcode(barcode);
      if (copy == null) return;

      await _client.from(_bookCopyTable).delete().eq('mavach', barcode);

      // Cập nhật số lượng trong đầu sách
      await _updateBookTitleCounts(copy.bookTitleId);
    } catch (e) {
      throw Exception('Lỗi khi xóa bản sao: $e');
    }
  }
  /// Cập nhật số lượng sách trong đầu sách
  Future<void> _updateBookTitleCounts(String bookTitleId) async {
    try {
      // Đếm tổng số bản sao
      final totalResponse = await _client
          .from(_bookCopyTable)
          .select('mavach')
          .eq('mads', bookTitleId);
      final totalCount = (totalResponse as List).length;

      // Cập nhật đầu sách
      await _client.from(_bookTitleTable).update({
        'tongsoluong': totalCount,
      }).eq('mads', bookTitleId);
    } catch (e) {
      debugPrint('Warning: Không thể cập nhật số lượng sách: $e');
    }
  }

  // ==================== THỐNG KÊ ====================
  /// Lấy thống kê sách
  Future<Map<String, int>> getBookStatistics() async {
    try {
      // Đếm tổng đầu sách
      final titlesResponse =
          await _client.from(_bookTitleTable).select('mads');
      final totalTitles = (titlesResponse as List).length;

      // Đếm tổng bản sao
      final copiesResponse =
          await _client.from(_bookCopyTable).select('mavach');
      final totalCopies = (copiesResponse as List).length;

      // Đếm sách sẵn sàng (trangthai = 0)
      final availableResponse = await _client
          .from(_bookCopyTable)
          .select('mavach')
          .eq('trangthai', 0);
      final availableCopies = (availableResponse as List).length;

      // Đếm sách đang mượn (trangthai = 1)
      final borrowedResponse = await _client
          .from(_bookCopyTable)
          .select('mavach')
          .eq('trangthai', 1);
      final borrowedCopies = (borrowedResponse as List).length;

      // Đếm sách đã đặt (trangthai = 2)
      final reservedResponse = await _client
          .from(_bookCopyTable)
          .select('mavach')
          .eq('trangthai', 2);
      final reservedCopies = (reservedResponse as List).length;

      return {
        'totalTitles': totalTitles,
        'totalCopies': totalCopies,
        'availableCopies': availableCopies,
        'borrowedCopies': borrowedCopies,
        'reservedCopies': reservedCopies,
      };
    } catch (e) {
      throw Exception('Lỗi khi lấy thống kê sách: $e');
    }
  }

  /// Đếm số bản sao sẵn sàng của một đầu sách
  Future<int> countAvailableCopies(String bookTitleId) async {
    try {
      final response = await _client
          .from(_bookCopyTable)
          .select('mavach')
          .eq('mads', bookTitleId)
          .eq('trangthai', 0);
      return (response as List).length;
    } catch (e) {
      throw Exception('Lỗi khi đếm bản sao sẵn sàng: $e');
    }
  }
}

/// Provider cho SupabaseBookRepository
final supabaseBookRepositoryProvider = Provider<SupabaseBookRepository>((ref) {
  return SupabaseBookRepository(Supabase.instance.client);
});

/// Provider để lấy danh sách đầu sách
final supabaseBookTitlesProvider =
    FutureProvider<List<SupabaseBookTitle>>((ref) async {
  final repository = ref.watch(supabaseBookRepositoryProvider);
  return repository.getBookTitles();
});

/// Provider để tìm kiếm sách
final supabaseBookSearchProvider =
    FutureProvider.family<List<SupabaseBookTitle>, String>(
        (ref, keyword) async {
  final repository = ref.watch(supabaseBookRepositoryProvider);
  if (keyword.isEmpty) {
    return repository.getBookTitles();
  }
  return repository.searchBookTitles(keyword);
});

/// Provider để lấy sách theo thể loại
final supabaseBooksByCategoryProvider =
    FutureProvider.family<List<SupabaseBookTitle>, int>(
        (ref, categoryId) async {
  final repository = ref.watch(supabaseBookRepositoryProvider);
  return repository.getBookTitlesByCategory(categoryId);
});

/// Provider để lấy thống kê sách
final supabaseBookStatisticsProvider =
    FutureProvider<Map<String, int>>((ref) async {
  final repository = ref.watch(supabaseBookRepositoryProvider);
  return repository.getBookStatistics();
});

/// Provider để lấy bản sao của một đầu sách
final supabaseBookCopiesProvider =
    FutureProvider.family<List<SupabaseBookCopy>, String>(
        (ref, bookTitleId) async {
  final repository = ref.watch(supabaseBookRepositoryProvider);
  return repository.getBookCopies(bookTitleId);
});