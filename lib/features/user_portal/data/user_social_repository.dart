import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ============================================================================
// User Portal Social Repository
// Handles reviews, ratings, reading status, follows
// ============================================================================

/// Đánh giá / Review sách
class UserReview {
  final int id;
  final String memberId;
  final String memberName;
  final String? memberAvatar;
  final String bookId;
  final String? bookTitle;
  final String? bookImageUrl;
  final int rating; // 1-5
  final String? title;
  final String? content;
  final int likeCount;
  final bool isLikedByMe;
  final DateTime createdAt;

  const UserReview({
    required this.id,
    required this.memberId,
    this.memberName = '',
    this.memberAvatar,
    required this.bookId,
    this.bookTitle,
    this.bookImageUrl,
    required this.rating,
    this.title,
    this.content,
    this.likeCount = 0,
    this.isLikedByMe = false,
    required this.createdAt,
  });

  factory UserReview.fromJson(Map<String, dynamic> json, {String? currentMemberId}) {
    int parseNum(dynamic v) => (v is num) ? v.toInt() : int.tryParse(v.toString()) ?? 0;

    // Parse member info from join
    String memberName = '';
    String? memberAvatar;
    if (json['doc_gia'] is Map) {
      final dg = json['doc_gia'] as Map;
      final parts = [dg['hodg'], dg['tenlotdg'], dg['tendg']]
          .where((e) => (e ?? '').toString().trim().isNotEmpty)
          .map((e) => e.toString().trim());
      memberName = parts.join(' ');
      memberAvatar = dg['avatar_url'] as String?;
    }

    // Parse book info from join
    String? bookTitle;
    String? bookImageUrl;
    if (json['dau_sach'] is Map) {
      bookTitle = json['dau_sach']['tensach'] as String?;
      bookImageUrl = json['dau_sach']['anhbia'] as String?;
    }

    // Check if current user liked this review
    bool isLiked = false;
    if (json['luot_thich_danh_gia'] is List && currentMemberId != null) {
      isLiked = (json['luot_thich_danh_gia'] as List).any(
        (l) => l is Map && l['madg'] == currentMemberId,
      );
    }

    return UserReview(
      id: parseNum(json['ma_danh_gia']),
      memberId: json['madg'] as String? ?? '',
      memberName: memberName,
      memberAvatar: memberAvatar,
      bookId: json['mads'] as String? ?? '',
      bookTitle: bookTitle,
      bookImageUrl: bookImageUrl,
      rating: parseNum(json['diem_so']),
      title: json['tieu_de'] as String?,
      content: json['noi_dung'] as String?,
      likeCount: parseNum(json['so_thich']),
      isLikedByMe: isLiked,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

/// Trạng thái đọc sách
class ReadingStatus {
  final int id;
  final String memberId;
  final String bookId;
  final String? bookTitle;
  final String? bookImageUrl;
  final String status; // muon_doc, dang_doc, da_doc
  final int progress; // 0-100
  final DateTime? startedAt;
  final DateTime? finishedAt;

  const ReadingStatus({
    required this.id,
    required this.memberId,
    required this.bookId,
    this.bookTitle,
    this.bookImageUrl,
    this.status = 'muon_doc',
    this.progress = 0,
    this.startedAt,
    this.finishedAt,
  });

  String get statusLabel {
    switch (status) {
      case 'muon_doc':
        return 'Muốn đọc';
      case 'dang_doc':
        return 'Đang đọc';
      case 'da_doc':
        return 'Đã đọc';
      default:
        return status;
    }
  }

  factory ReadingStatus.fromJson(Map<String, dynamic> json) {
    int parseNum(dynamic v) => (v is num) ? v.toInt() : int.tryParse(v.toString()) ?? 0;

    String? bookTitle;
    String? bookImageUrl;
    if (json['dau_sach'] is Map) {
      bookTitle = json['dau_sach']['tensach'] as String?;
      bookImageUrl = json['dau_sach']['anhbia'] as String?;
    }

    return ReadingStatus(
      id: parseNum(json['id']),
      memberId: json['madg'] as String? ?? '',
      bookId: json['mads'] as String? ?? '',
      bookTitle: bookTitle,
      bookImageUrl: bookImageUrl,
      status: json['trang_thai'] as String? ?? 'muon_doc',
      progress: parseNum(json['tien_do']),
      startedAt: json['bat_dau_doc'] != null
          ? DateTime.tryParse(json['bat_dau_doc'].toString())
          : null,
      finishedAt: json['doc_xong'] != null
          ? DateTime.tryParse(json['doc_xong'].toString())
          : null,
    );
  }
}

/// Thông tin public profile member
class PublicMemberProfile {
  final String id;
  final String name;
  final String? avatarUrl;
  final int credibilityScore;
  final int reviewCount;
  final int followerCount;
  final int followingCount;
  final int booksRead;
  final bool isFollowedByMe;

  const PublicMemberProfile({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.credibilityScore = 100,
    this.reviewCount = 0,
    this.followerCount = 0,
    this.followingCount = 0,
    this.booksRead = 0,
    this.isFollowedByMe = false,
  });
}

/// Repository
class UserSocialRepository {
  final SupabaseClient _client;

  UserSocialRepository(this._client);

  // ==================== REVIEWS ====================

  /// Lấy feed review mới nhất
  Future<List<UserReview>> getReviewFeed({
    int page = 0,
    int limit = 20,
    String? currentMemberId,
  }) async {
    final data = await _client
        .from('danh_gia')
        .select('''
          *,
          doc_gia(hodg, tenlotdg, tendg, avatar_url),
          dau_sach(tensach, anhbia),
          luot_thich_danh_gia(madg)
        ''')
        .eq('trang_thai', 'active')
        .range(page * limit, (page + 1) * limit - 1)
        .order('created_at', ascending: false);

    return data
        .map((e) => UserReview.fromJson(e, currentMemberId: currentMemberId))
        .toList();
  }

  /// Lấy reviews cho 1 cuốn sách
  Future<List<UserReview>> getBookReviews(String bookId, {String? currentMemberId}) async {
    final data = await _client
        .from('danh_gia')
        .select('''
          *,
          doc_gia(hodg, tenlotdg, tendg, avatar_url),
          dau_sach(tensach, anhbia),
          luot_thich_danh_gia(madg)
        ''')
        .eq('mads', bookId)
        .eq('trang_thai', 'active')
        .order('created_at', ascending: false);

    return data
        .map((e) => UserReview.fromJson(e, currentMemberId: currentMemberId))
        .toList();
  }

  /// Lấy reviews của 1 member
  Future<List<UserReview>> getMemberReviews(String memberId) async {
    final data = await _client
        .from('danh_gia')
        .select('''
          *,
          doc_gia(hodg, tenlotdg, tendg, avatar_url),
          dau_sach(tensach, anhbia)
        ''')
        .eq('madg', memberId)
        .eq('trang_thai', 'active')
        .order('created_at', ascending: false);

    return data.map((e) => UserReview.fromJson(e)).toList();
  }

  /// Tạo review mới
  Future<void> createReview({
    required String memberId,
    required String bookId,
    required int rating,
    String? title,
    String? content,
  }) async {
    await _client.from('danh_gia').upsert({
      'madg': memberId,
      'mads': bookId,
      'diem_so': rating,
      'tieu_de': title,
      'noi_dung': content,
      'trang_thai': 'active',
    }, onConflict: 'madg,mads');
  }

  /// Like / Unlike review
  Future<void> toggleLikeReview(int reviewId, String memberId) async {
    final existing = await _client
        .from('luot_thich_danh_gia')
        .select('id')
        .eq('ma_danh_gia', reviewId)
        .eq('madg', memberId)
        .maybeSingle();

    if (existing != null) {
      // Unlike
      await _client
          .from('luot_thich_danh_gia')
          .delete()
          .eq('ma_danh_gia', reviewId)
          .eq('madg', memberId);
      await _client
          .from('danh_gia')
          .update({'so_thich': _client.rpc('decrement', params: {'x': 1})})
          .eq('ma_danh_gia', reviewId);
    } else {
      // Like
      await _client.from('luot_thich_danh_gia').insert({
        'ma_danh_gia': reviewId,
        'madg': memberId,
      });
      await _client
          .from('danh_gia')
          .update({'so_thich': _client.rpc('increment', params: {'x': 1})})
          .eq('ma_danh_gia', reviewId);
    }
  }

  // ==================== READING STATUS ====================

  /// Lấy reading status của member
  Future<List<ReadingStatus>> getMemberReadingStatus(String memberId, {String? statusFilter}) async {
    var query = _client
        .from('trang_thai_doc')
        .select('''
          *,
          dau_sach(tensach, anhbia)
        ''')
        .eq('madg', memberId);

    if (statusFilter != null) {
      query = query.eq('trang_thai', statusFilter);
    }

    final data = await query.order('updated_at', ascending: false);
    return data.map((e) => ReadingStatus.fromJson(e)).toList();
  }

  /// Cập nhật trạng thái đọc sách
  Future<void> updateReadingStatus({
    required String memberId,
    required String bookId,
    required String status,
    int progress = 0,
  }) async {
    final now = DateTime.now().toIso8601String();
    await _client.from('trang_thai_doc').upsert({
      'madg': memberId,
      'mads': bookId,
      'trang_thai': status,
      'tien_do': progress,
      'bat_dau_doc': status == 'dang_doc' ? now : null,
      'doc_xong': status == 'da_doc' ? now : null,
      'updated_at': now,
    }, onConflict: 'madg,mads');
  }

  // ==================== FOLLOWS ====================

  /// Follow / Unfollow member
  Future<void> toggleFollow(String followerId, String followingId) async {
    final existing = await _client
        .from('theo_doi')
        .select('id')
        .eq('nguoi_theo_doi', followerId)
        .eq('nguoi_duoc_theo_doi', followingId)
        .maybeSingle();

    if (existing != null) {
      await _client
          .from('theo_doi')
          .delete()
          .eq('nguoi_theo_doi', followerId)
          .eq('nguoi_duoc_theo_doi', followingId);
    } else {
      await _client.from('theo_doi').insert({
        'nguoi_theo_doi': followerId,
        'nguoi_duoc_theo_doi': followingId,
      });
    }
  }

  /// Kiểm tra đang follow không
  Future<bool> isFollowing(String followerId, String followingId) async {
    final data = await _client
        .from('theo_doi')
        .select('id')
        .eq('nguoi_theo_doi', followerId)
        .eq('nguoi_duoc_theo_doi', followingId)
        .maybeSingle();
    return data != null;
  }

  /// Đếm follower / following
  Future<int> getFollowerCount(String memberId) async {
    final data = await _client
        .from('theo_doi')
        .select('id')
        .eq('nguoi_duoc_theo_doi', memberId);
    return data.length;
  }

  Future<int> getFollowingCount(String memberId) async {
    final data = await _client
        .from('theo_doi')
        .select('id')
        .eq('nguoi_theo_doi', memberId);
    return data.length;
  }

  // ==================== PUBLIC PROFILE ====================

  /// Lấy public profile member
  Future<PublicMemberProfile?> getPublicProfile(
    String memberId, {
    String? currentMemberId,
  }) async {
    final memberData = await _client
        .from('doc_gia')
        .select('madg, hodg, tenlotdg, tendg, avatar_url, diem_tin_nhiem')
        .eq('madg', memberId)
        .maybeSingle();

    if (memberData == null) return null;

    final parts = [
      memberData['hodg'],
      memberData['tenlotdg'],
      memberData['tendg'],
    ].where((e) => (e ?? '').toString().trim().isNotEmpty).map((e) => e.toString().trim());

    final reviewCount = (await _client
            .from('danh_gia')
            .select('ma_danh_gia')
            .eq('madg', memberId))
        .length;

    final followerCount = await getFollowerCount(memberId);
    final followingCount = await getFollowingCount(memberId);

    final booksRead = (await _client
            .from('trang_thai_doc')
            .select('id')
            .eq('madg', memberId)
            .eq('trang_thai', 'da_doc'))
        .length;

    bool isFollowed = false;
    if (currentMemberId != null && currentMemberId != memberId) {
      isFollowed = await isFollowing(currentMemberId, memberId);
    }

    return PublicMemberProfile(
      id: memberId,
      name: parts.join(' '),
      avatarUrl: memberData['avatar_url'] as String?,
      credibilityScore:
          (memberData['diem_tin_nhiem'] as num?)?.toInt() ?? 100,
      reviewCount: reviewCount,
      followerCount: followerCount,
      followingCount: followingCount,
      booksRead: booksRead,
      isFollowedByMe: isFollowed,
    );
  }

  /// Lấy rating trung bình của sách
  Future<Map<String, dynamic>> getBookRatingStats(String bookId) async {
    final data = await _client
        .from('danh_gia')
        .select('diem_so')
        .eq('mads', bookId)
        .eq('trang_thai', 'active');

    if (data.isEmpty) {
      return {'avg': 0.0, 'count': 0};
    }

    final ratings = data.map((e) => (e['diem_so'] as num).toDouble()).toList();
    final avg = ratings.reduce((a, b) => a + b) / ratings.length;

    return {'avg': avg, 'count': ratings.length};
  }
}

// ======================== Providers ========================

final userSocialRepositoryProvider = Provider<UserSocialRepository>((ref) {
  return UserSocialRepository(Supabase.instance.client);
});

final reviewFeedProvider = FutureProvider.family<List<UserReview>, String?>(
  (ref, currentMemberId) {
    return ref
        .read(userSocialRepositoryProvider)
        .getReviewFeed(currentMemberId: currentMemberId);
  },
);

final bookReviewsProvider = FutureProvider.family<List<UserReview>, String>(
  (ref, bookId) {
    return ref.read(userSocialRepositoryProvider).getBookReviews(bookId);
  },
);

final memberReadingStatusProvider =
    FutureProvider.family<List<ReadingStatus>, String>(
  (ref, memberId) {
    return ref
        .read(userSocialRepositoryProvider)
        .getMemberReadingStatus(memberId);
  },
);

final publicProfileProvider =
    FutureProvider.family<PublicMemberProfile?, String>(
  (ref, memberId) {
    return ref
        .read(userSocialRepositoryProvider)
        .getPublicProfile(memberId);
  },
);

final bookRatingStatsProvider =
    FutureProvider.family<Map<String, dynamic>, String>(
  (ref, bookId) {
    return ref.read(userSocialRepositoryProvider).getBookRatingStats(bookId);
  },
);
