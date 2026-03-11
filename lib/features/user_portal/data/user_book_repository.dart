import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ============================================================================
// User Portal Book Repository
// Fetches book data for the member-facing portal (browse, detail, search)
// ============================================================================

/// Book model for user portal (read-only view)
class UserBook {
  final String id;
  final String title;
  final int? publishYear;
  final int? coverPrice;     // giá bìa
  final int? salePrice;      // giá bán lẻ (null = không bán)
  final int totalCopies;
  final int saleCopies;      // số lượng bán
  final String? description;
  final String? categoryName;
  final String? publisherName;
  final String? imageUrl;
  final List<String> authors;
  final double avgRating;
  final int reviewCount;

  const UserBook({
    required this.id,
    required this.title,
    this.publishYear,
    this.coverPrice,
    this.salePrice,
    this.totalCopies = 0,
    this.saleCopies = 0,
    this.description,
    this.categoryName,
    this.publisherName,
    this.imageUrl,
    this.authors = const [],
    this.avgRating = 0,
    this.reviewCount = 0,
  });

  bool get canBuy => salePrice != null && saleCopies > 0;
  bool get canBorrow => availableCopies > 0;

  /// Sách còn cho mượn = tổng - đang mượn (tính tương đối)
  int get availableCopies => totalCopies;

  String get authorString => authors.isEmpty ? 'Không rõ' : authors.join(', ');
  factory UserBook.fromJson(Map<String, dynamic> json) {
    int? parseIntOrNull(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString());
    }

    String? categoryName;
    if (json['the_loai'] is Map) {
      categoryName = json['the_loai']['tentl'] as String?;
    }

    String? publisherName;
    if (json['nha_xuat_ban'] is Map) {
      publisherName = json['nha_xuat_ban']['tennxb'] as String?;
    }

    List<String> authors = [];
    if (json['chi_tiet_tac_gia'] is List) {
      for (final ct in json['chi_tiet_tac_gia'] as List) {
        if (ct is Map && ct['tac_gia'] is Map) {
          final tg = ct['tac_gia'] as Map;
          final parts = [tg['hotg'], tg['tenlottg'], tg['tentg']]
              .where((e) => (e ?? '').toString().trim().isNotEmpty)
              .map((e) => e.toString().trim());
          if (parts.isNotEmpty) authors.add(parts.join(' '));
        }
      }
    }    return UserBook(
      id: json['mads'] as String? ?? '',
      title: json['tensach'] as String? ?? '',
      publishYear: parseIntOrNull(json['namxb']),
      coverPrice: parseIntOrNull(json['giabia']),
      salePrice: parseIntOrNull(json['gia_ban']),
      totalCopies: parseIntOrNull(json['tongsoluong']) ?? 0,
      saleCopies: parseIntOrNull(json['so_luong_ban']) ?? 0,
      description: json['mota'] as String?,
      categoryName: categoryName,
      publisherName: publisherName,
      imageUrl: json['anhbia'] as String?,
      authors: authors,
    );
  }
}

/// Repository
class UserBookRepository {
  final SupabaseClient _client;

  UserBookRepository(this._client);

  /// Lấy tất cả sách (phân trang)
  Future<List<UserBook>> getBooks({
    int page = 0,
    int limit = 20,
    String? category,
    String? search,
  }) async {
    var query = _client
        .from('dau_sach')
        .select('''
          *,
          the_loai(tentl),
          nha_xuat_ban(tennxb),
          chi_tiet_tac_gia(tac_gia(hotg, tenlottg, tentg))
        ''');

    if (category != null && category.isNotEmpty) {
      query = query.eq('the_loai.tentl', category);
    }

    if (search != null && search.isNotEmpty) {
      query = query.ilike('tensach', '%$search%');
    }

    final data = await query
        .range(page * limit, (page + 1) * limit - 1)
        .order('tensach');

    return data.map((e) => UserBook.fromJson(e)).toList();
  }

  /// Lấy chi tiết sách theo ID
  Future<UserBook?> getBookById(String bookId) async {
    final data = await _client
        .from('dau_sach')
        .select('''
          *,
          the_loai(tentl),
          nha_xuat_ban(tennxb),
          chi_tiet_tac_gia(tac_gia(hotg, tenlottg, tentg))
        ''')
        .eq('mads', bookId)
        .maybeSingle();

    if (data == null) return null;
    return UserBook.fromJson(data);
  }

  /// Sách phổ biến (có nhiều review nhất)
  Future<List<UserBook>> getPopularBooks({int limit = 10}) async {
    // Simple: fetch all and sort client-side by review count
    // In production, use a Supabase function or view
    final data = await _client
        .from('dau_sach')
        .select('''
          *,
          the_loai(tentl),
          nha_xuat_ban(tennxb),
          chi_tiet_tac_gia(tac_gia(hotg, tenlottg, tentg))
        ''')
        .limit(limit)
        .order('tongsoluong', ascending: false);

    return data.map((e) => UserBook.fromJson(e)).toList();
  }

  /// Sách mới nhất
  Future<List<UserBook>> getNewBooks({int limit = 10}) async {
    final data = await _client
        .from('dau_sach')
        .select('''
          *,
          the_loai(tentl),
          nha_xuat_ban(tennxb),
          chi_tiet_tac_gia(tac_gia(hotg, tenlottg, tentg))
        ''')
        .limit(limit)
        .order('namxb', ascending: false);

    return data.map((e) => UserBook.fromJson(e)).toList();
  }

  /// Lấy danh sách thể loại
  Future<List<String>> getCategories() async {
    final data = await _client
        .from('the_loai')
        .select('tentl')
        .order('tentl');

    return data.map((e) => e['tentl'] as String).toList();
  }
}

// ======================== Providers ========================

final userBookRepositoryProvider = Provider<UserBookRepository>((ref) {
  return UserBookRepository(Supabase.instance.client);
});

final userBooksProvider = FutureProvider.family<List<UserBook>, String?>(
  (ref, search) {
    return ref.read(userBookRepositoryProvider).getBooks(search: search);
  },
);

final userBookDetailProvider = FutureProvider.family<UserBook?, String>(
  (ref, bookId) {
    return ref.read(userBookRepositoryProvider).getBookById(bookId);
  },
);

final popularBooksProvider = FutureProvider<List<UserBook>>((ref) {
  return ref.read(userBookRepositoryProvider).getPopularBooks();
});

final newBooksProvider = FutureProvider<List<UserBook>>((ref) {
  return ref.read(userBookRepositoryProvider).getNewBooks();
});

final categoriesProvider = FutureProvider<List<String>>((ref) {
  return ref.read(userBookRepositoryProvider).getCategories();
});
