import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:postra/src/core/providers/navigation_provider.dart';
import 'package:postra/src/features/auth/presentation/providers/auth_provider.dart';
import 'package:postra/src/features/home_feed/presentation/widgets/category_bar.dart';
import 'package:postra/src/features/home_feed/presentation/widgets/home_header.dart';
import 'package:postra/src/features/home_feed/presentation/widgets/post_card.dart';
import 'package:postra/src/features/user_profile/presentation/pages/user_profile_page.dart';
import 'package:postra/src/features/post_detail/presentation/pages/post_detail_page.dart';
import 'package:postra/src/features/create_post/presentation/pages/create_post_page.dart';
import 'package:postra/src/features/posts/presentation/providers/posts_provider.dart';
import 'package:postra/src/features/posts/presentation/widgets/comments_bottom_sheet.dart';
import 'package:flutter/services.dart';
import 'package:postra/src/core/utils/time_formatter.dart';

class HomeFeedPage extends ConsumerStatefulWidget {
  const HomeFeedPage({super.key});

  @override
  ConsumerState<HomeFeedPage> createState() => _HomeFeedPageState();
}

class _HomeFeedPageState extends ConsumerState<HomeFeedPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(postsProvider.notifier).getPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    final postsProv = ref.watch(postsProvider);
    return CupertinoPageScaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: Stack(
        children: [
          // Main Scrollable Content
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Spacer for Sticky Header
              const SliverToBoxAdapter(
                child: SizedBox(height: 140), // Height of Header + SafeArea
              ),

              // Refresh Control
              CupertinoSliverRefreshControl(
                onRefresh: () async {
                  await ref.read(postsProvider.notifier).getPosts();
                },
              ),

              // Category Bar
              const SliverToBoxAdapter(child: CategoryBar()),

              // Post Feed
              if (postsProv.isGettingPosts)
                const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CupertinoActivityIndicator(),
                    ),
                  ),
                )
              else if (postsProv.gettingPostsError != null)
                SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            CupertinoIcons.exclamationmark_triangle,
                            size: 48,
                            color: CupertinoColors.systemRed,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Failed to load posts',
                            style: theme.textTheme.navTitleTextStyle,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            postsProv.gettingPostsError!,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.textStyle.copyWith(
                              color: CupertinoColors.systemGrey,
                            ),
                          ),
                          const SizedBox(height: 16),
                          CupertinoButton.filled(
                            onPressed: () {
                              ref.read(postsProvider.notifier).getPosts();
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else if (postsProv.posts.isEmpty)
                const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text('No posts available'),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.only(bottom: 120),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final post = postsProv.posts[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context, rootNavigator: true).push(
                            CupertinoPageRoute(
                              builder: (context) => PostDetailPage(post: post),
                            ),
                          );
                        },
                        child: PostCard(
                          authorName: post.authorFullName,
                          authorAvatar: post.profilePic,
                          timestamp: TimeFormatter.getRelativeTime(
                            post.createdAt,
                          ),
                          title: post.title,
                          content: post.subTitle,
                          likes: post.likeCount.toString(),
                          comments: post.commentCount.toString(),
                          isLiked: post.isLiked,
                          imageUrl: post.postBanner,
                          onLikeTap: () =>
                              ref.read(postsProvider.notifier).toggleLike(post),
                          onCommentTap: () => _showComments(context, post.slug),
                          onShareTap: () =>
                              _handleShare(post.username, post.slug),
                          onEditTap: () => _handleEdit(post),
                          onDeleteTap: () => _handleDelete(post.slug),
                          isOwner:
                              ref.watch(authProvider).currentUser?.username ==
                              post.username,
                          onAuthorTap: () {
                            final currentUser = ref
                                .read(authProvider)
                                .currentUser;
                            if (currentUser != null &&
                                currentUser.username == post.username) {
                              // Switch to Profile tab
                              ref.read(navigationProvider.notifier).state = 2;
                            } else {
                              // Push separate profile page
                              Navigator.of(context, rootNavigator: true).push(
                                CupertinoPageRoute(
                                  builder: (context) =>
                                      UserProfilePage(username: post.username),
                                ),
                              );
                            }
                          },
                        ),
                      );
                    }, childCount: postsProv.posts.length),
                  ),
                ),
            ],
          ),

          // Sticky Header with Blur
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: theme.scaffoldBackgroundColor.withValues(alpha: 0.8),
                  child: const SafeArea(bottom: false, child: HomeHeader()),
                ),
              ),
            ),
          ),

          // Floating Action Button
          Positioned(
            bottom: 112,
            right: 24,
            child: _FAB(
              onPressed: () {
                Navigator.of(context, rootNavigator: true).push(
                  CupertinoPageRoute(
                    fullscreenDialog: true,
                    builder: (context) => const CreatePostPage(),
                  ),
                );
              },
            ),
          ),

          // Deletion Loading Overlay
          if (postsProv.isDeletingPost)
            Positioned.fill(
              child: Container(
                color:
                    (CupertinoTheme.of(context).brightness == Brightness.dark
                            ? CupertinoColors.black
                            : CupertinoColors.white)
                        .withValues(alpha: 0.6),
                child: const Center(
                  child: CupertinoActivityIndicator(radius: 16),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showComments(BuildContext context, String slug) {
    Navigator.of(context, rootNavigator: true).push(
      CupertinoPageRoute(
        fullscreenDialog: true,
        builder: (context) => CommentsBottomSheet(slug: slug),
      ),
    );
  }

  void _handleShare(String username, String slug) {
    final link = 'https://postra-fronted.vercel.app/$username/$slug';
    Clipboard.setData(ClipboardData(text: link));
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Link Copied'),
        content: const Text('Post link has been copied to clipboard.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _handleEdit(dynamic post) {
    Navigator.of(context, rootNavigator: true).push(
      CupertinoPageRoute(
        fullscreenDialog: true,
        builder: (context) => CreatePostPage(postToEdit: post),
      ),
    );
  }

  void _handleDelete(String slug) async {
    final success = await ref.read(postsProvider.notifier).deletePost(slug);
    if (mounted) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text(success ? 'Deleted' : 'Error'),
          content: Text(
            success ? 'Post deleted successfully.' : 'Failed to delete post.',
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }
}

class _FAB extends StatelessWidget {
  final VoidCallback onPressed;

  const _FAB({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final primaryColor = CupertinoTheme.of(context).primaryColor;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: primaryColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Icon(
          CupertinoIcons.add,
          color: CupertinoColors.white,
          size: 30,
        ),
      ),
    );
  }
}
