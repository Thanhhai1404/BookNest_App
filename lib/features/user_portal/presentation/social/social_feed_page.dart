import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../core/user_auth_provider.dart';
import '../../data/user_social_repository.dart';

/// Tab Cộng đồng - Social Feed (Goodreads Style)
/// Review, Rating, Reading Status, Follow
class SocialFeedPage extends ConsumerStatefulWidget {
  const SocialFeedPage({super.key});

  @override
  ConsumerState<SocialFeedPage> createState() => _SocialFeedPageState();
}

class _SocialFeedPageState extends ConsumerState<SocialFeedPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Cộng đồng'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note_rounded),
            tooltip: 'Viết review',
            onPressed: () => context.push('/user/social/review/new'),
          ),
          const SizedBox(width: 4),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          tabs: const [
            Tab(text: 'Feed'),
            Tab(text: 'Review mới'),
            Tab(text: 'Đang đọc'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _FeedTab(),
          _FeedTab(), // Same feed, review-only filter can be added later
          _ReadingTab(),
        ],
      ),
    );
  }
}

// ==================== FEED TAB ====================
class _FeedTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final member = ref.watch(currentMemberProvider);
    final feedAsync = ref.watch(reviewFeedProvider(member?.id));

    return feedAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Lỗi tải feed: $e', textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => ref.invalidate(reviewFeedProvider),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
      data: (reviews) {
        if (reviews.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.forum_outlined, size: 48,
                    color: AppTheme.textSecondary.withAlpha(100)),
                const SizedBox(height: 12),
                Text('Chưa có review nào',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary)),
                const SizedBox(height: 8),                FilledButton.icon(
                  onPressed: () => context.push('/user/social/review/new'),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Viết review đầu tiên'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(reviewFeedProvider),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: reviews.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final review = reviews[index];
              return _FeedCard(
                userName: review.memberName.isNotEmpty
                    ? review.memberName
                    : review.memberId,
                action: 'đã review',
                bookTitle: review.bookTitle ?? review.bookId,
                content: review.content,
                rating: review.rating.toDouble(),
                timeAgo: _timeAgo(review.createdAt),
                likeCount: review.likeCount,
                isLiked: review.isLikedByMe,                onUserTap: () =>
                    context.push('/user/social/user/${review.memberId}'),
                onLikeTap: member != null
                    ? () async {
                        await ref
                            .read(userSocialRepositoryProvider)
                            .toggleLikeReview(review.id, member.id);
                        ref.invalidate(reviewFeedProvider);
                      }
                    : null,
              );
            },
          ),
        );
      },
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays} ngày';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

class _FeedCard extends StatelessWidget {
  const _FeedCard({
    required this.userName,
    required this.action,
    required this.bookTitle,
    this.content,
    this.rating,
    required this.timeAgo,
    this.likeCount = 0,
    this.isLiked = false,
    this.onUserTap,
    this.onLikeTap,
  });

  final String userName;
  final String action;
  final String bookTitle;
  final String? content;
  final double? rating;
  final String timeAgo;
  final int likeCount;
  final bool isLiked;
  final VoidCallback? onUserTap;
  final VoidCallback? onLikeTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.slate200.withAlpha(120)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User row
          Row(
            children: [
              GestureDetector(
                onTap: onUserTap,
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: AppTheme.primaryColor.withAlpha(20),
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: onUserTap,
                      child: Text(
                        userName,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Text(
                      '$action • $timeAgo',
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_horiz, size: 20),
                color: AppTheme.textSecondary,
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Book name
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withAlpha(10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.menu_book, size: 14, color: AppTheme.primaryColor),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    bookTitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
          ),

          // Rating
          if (rating != null && rating! > 0) ...[
            const SizedBox(height: 10),
            Row(
              children: List.generate(5, (i) {
                return Icon(
                  i < rating!.floor() ? Icons.star : Icons.star_border,
                  size: 18,
                  color: AppTheme.warningColor,
                );
              }),
            ),
          ],

          // Content
          if (content != null && content!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              content!,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(height: 1.5),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          // Action bar
          const SizedBox(height: 12),
          Row(
            children: [
              GestureDetector(
                onTap: onLikeTap,
                child: Row(
                  children: [
                    Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      size: 18,
                      color: isLiked ? AppTheme.primaryColor : AppTheme.textSecondary,
                    ),
                    if (likeCount > 0) ...[
                      const SizedBox(width: 4),
                      Text('$likeCount',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(color: AppTheme.textSecondary)),
                    ],
                  ],
                ),
              ),
              const Spacer(),
              Icon(Icons.bookmark_border, size: 18, color: AppTheme.textSecondary),
            ],
          ),
        ],
      ),
    );
  }
}

// ==================== READING TAB ====================
class _ReadingTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final member = ref.watch(currentMemberProvider);
    if (member == null) {
      return const Center(child: Text('Vui lòng đăng nhập'));
    }

    final statusAsync = ref.watch(memberReadingStatusProvider(member.id));

    return statusAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Lỗi: $e')),
      data: (statuses) {
        if (statuses.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_stories_outlined, size: 48,
                    color: AppTheme.textSecondary.withAlpha(100)),
                const SizedBox(height: 12),
                Text('Chưa có sách nào đang đọc',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary)),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: statuses.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = statuses[index];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.slate200.withAlpha(120)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppTheme.primaryColor.withAlpha(20),
                    child: Text(
                      (member.firstName ?? 'U')[0].toUpperCase(),
                      style: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: Theme.of(context).textTheme.bodyMedium,
                            children: [
                              TextSpan(
                                text: member.fullName,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              TextSpan(text: ' ${item.statusLabel.toLowerCase()} '),
                              TextSpan(
                                text: item.bookTitle ?? item.bookId,
                                style: const TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: item.progress / 100,
                                  minHeight: 6,
                                  backgroundColor: AppTheme.slate200,
                                  valueColor: const AlwaysStoppedAnimation(
                                      AppTheme.primaryColor),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${item.progress}%',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
