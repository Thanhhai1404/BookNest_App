import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../core/user_auth_provider.dart';
import '../../data/user_social_repository.dart';

/// Profile công khai của người dùng khác
class UserPublicProfilePage extends ConsumerWidget {
  const UserPublicProfilePage({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final member = ref.watch(currentMemberProvider);
    final profileAsync = ref.watch(publicProfileProvider(userId));
    final reviewsAsync = ref.watch(_memberReviewsProvider(userId));

    return profileAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Lỗi: $e')),
      ),
      data: (profile) {
        if (profile == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Không tìm thấy người dùng')),
          );
        }

        return Scaffold(
          backgroundColor: AppTheme.backgroundLight,
          body: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryColor.withAlpha(50),
                          AppTheme.backgroundLight,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: AppTheme.primaryColor.withAlpha(30),
                          backgroundImage: profile.avatarUrl != null
                              ? NetworkImage(profile.avatarUrl!)
                              : null,
                          child: profile.avatarUrl == null
                              ? Text(
                                  profile.name.isNotEmpty
                                      ? profile.name[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          profile.name,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          'Điểm tín nhiệm: ${profile.credibilityScore}',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Stats & Follow
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _StatItem(
                              value: '${profile.booksRead}', label: 'Đã đọc'),
                          _StatItem(
                              value: '${profile.followerCount}',
                              label: 'Follower'),
                          _StatItem(
                              value: '${profile.followingCount}',
                              label: 'Following'),
                          _StatItem(
                              value: '${profile.reviewCount}',
                              label: 'Review'),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Follow button (hide if it's yourself)
                      if (member != null && member.id != userId)
                        SizedBox(
                          width: double.infinity,
                          child: profile.isFollowedByMe
                              ? OutlinedButton.icon(
                                  onPressed: () async {
                                    await ref
                                        .read(userSocialRepositoryProvider)
                                        .toggleFollow(member.id, userId);
                                    ref.invalidate(publicProfileProvider);
                                  },
                                  icon: const Icon(Icons.person_remove_outlined,
                                      size: 18),
                                  label: const Text('Bỏ Follow'),
                                )
                              : FilledButton.icon(
                                  onPressed: () async {
                                    await ref
                                        .read(userSocialRepositoryProvider)
                                        .toggleFollow(member.id, userId);
                                    ref.invalidate(publicProfileProvider);
                                  },
                                  icon: const Icon(Icons.person_add_outlined,
                                      size: 18),
                                  label: const Text('Follow'),
                                ),
                        ),
                    ],
                  ),
                ),
              ),

              // Reviews section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Text(
                    'Reviews gần đây',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: reviewsAsync.when(
                  loading: () => const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (e, _) => SliverToBoxAdapter(
                    child: Center(child: Text('Lỗi: $e')),
                  ),
                  data: (reviews) {
                    if (reviews.isEmpty) {
                      return SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Center(
                            child: Text(
                              'Chưa có review nào',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: AppTheme.textSecondary),
                            ),
                          ),
                        ),
                      );
                    }

                    return SliverList.separated(
                      itemCount: reviews.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final review = reviews[index];
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.cardLight,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: AppTheme.slate200.withAlpha(120)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      review.bookTitle ?? review.bookId,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.primaryColor,
                                          ),
                                    ),
                                  ),
                                  Row(
                                    children: List.generate(5, (i) {
                                      return Icon(
                                        i < review.rating
                                            ? Icons.star
                                            : Icons.star_border,
                                        size: 14,
                                        color: AppTheme.warningColor,
                                      );
                                    }),
                                  ),
                                ],
                              ),
                              if (review.content != null &&
                                  review.content!.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  review.content!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: AppTheme.textSecondary),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        );
      },
    );
  }
}

// Private provider for member reviews on this page
final _memberReviewsProvider =
    FutureProvider.family<List<UserReview>, String>((ref, memberId) {
  return ref.read(userSocialRepositoryProvider).getMemberReviews(memberId);
});

class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}
