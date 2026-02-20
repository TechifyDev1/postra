import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:postra/main.dart' show MyApp;
import 'package:postra/src/features/auth/presentation/providers/auth_provider.dart';
import 'package:postra/src/features/create_post/presentation/pages/create_post_page.dart';
import 'package:postra/src/features/home_feed/presentation/widgets/post_card.dart';
import 'package:postra/src/features/post_detail/presentation/pages/post_detail_page.dart';
import 'package:postra/src/features/posts/presentation/providers/posts_provider.dart';
import 'package:postra/src/features/user_profile/presentation/widgets/profile_actions.dart';
import 'package:postra/src/features/user_profile/presentation/widgets/profile_feed_tabs.dart';
import 'package:postra/src/features/user_profile/presentation/widgets/profile_header_info.dart';
import 'package:postra/src/features/posts/presentation/widgets/comments_bottom_sheet.dart';
import 'package:flutter/services.dart';
import 'package:postra/src/core/utils/time_formatter.dart';
import 'package:postra/src/features/user_profile/presentation/providers/user_profile_provider.dart';
import 'package:postra/src/features/auth/presentation/pages/sign_up_page.dart';

class UserProfilePage extends ConsumerStatefulWidget {
  final String? username;
  const UserProfilePage({super.key, this.username});

  @override
  ConsumerState<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends ConsumerState<UserProfilePage> {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (widget.username != null) {
        ref
            .read(userProfileProvider(widget.username!).notifier)
            .fetchProfile(widget.username!);
      } else {
        ref.read(postsProvider.notifier).getPosts();
      }
    });
  }

  void _showErrorDialog(String message, {bool isAuthError = false}) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(isAuthError ? 'Action Required' : 'Error'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
          if (isAuthError)
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('Sign Up'),
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  CupertinoPageRoute(builder: (context) => const SignUpPage()),
                );
              },
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final postsProv = ref.watch(postsProvider);
    final theme = CupertinoTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authState = ref.watch(authProvider);

    final isSelf =
        widget.username == null ||
        (authState.currentUser != null &&
            widget.username == authState.currentUser!.username);

    // Listen for profile errors and successes
    if (widget.username != null) {
      ref.listen(userProfileProvider(widget.username!), (previous, next) {
        // 1. Handle Social Errors
        if (next.socialError != null &&
            next.socialError != previous?.socialError) {
          final isGuestError = next.socialError!.contains('logged in');
          _showErrorDialog(next.socialError!, isAuthError: isGuestError);
        }

        // 2. Handle Social Success Feedback
        if (previous != null &&
            previous.isTogglingFollow &&
            !next.isTogglingFollow &&
            next.socialError == null) {
          final message = next.isFollowing
              ? 'Followed @${widget.username}'
              : 'Unfollowed @${widget.username}';

          // Refresh current user data to update their following count
          if (authState.currentUser != null) {
            ref.read(authProvider.notifier).getCurrentUser();
          }

          debugPrint('Success: $message');
        }

        // 3. Handle Profile Load Errors
        if (!isSelf && next.error != null && next.error != previous?.error) {
          _showErrorDialog(next.error!);
        }
      });
    }

    final profileState = widget.username != null
        ? ref.watch(userProfileProvider(widget.username!))
        : null;

    final profile = isSelf ? null : profileState?.profile;
    final isLoading = isSelf
        ? authState.isLoading
        : (profileState?.isLoading ?? false);
    final error = isSelf ? authState.currentUserError : profileState?.error;

    // Convert current user to UserProfile for header
    final UserProfile? displayProfile;
    if (isSelf) {
      final user = authState.currentUser;
      displayProfile = user != null
          ? UserProfile(
              username: user.username,
              fullName: user.fullName,
              profilePictureUrl: user.profilePictureUrl,
              bio: user.bio,
              postCount: user.postCount,
              numOfFollowers: user.numOfFollowers,
              numOfFollowing: user.numOfFollowing,
            )
          : null;
    } else {
      displayProfile = profile;
    }

    final userPosts = postsProv.posts
        .where((post) => post.username == displayProfile?.username)
        .toList();

    return CupertinoPageScaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Sticky Navigation Bar Space
              const SliverToBoxAdapter(child: SizedBox(height: 100)),

              // Refresh Control
              CupertinoSliverRefreshControl(
                onRefresh: () async {
                  if (widget.username != null) {
                    await ref
                        .read(userProfileProvider(widget.username!).notifier)
                        .fetchProfile(widget.username!);
                  } else {
                    await ref.read(postsProvider.notifier).getPosts();
                  }
                },
              ),

              // Profile Info
              SliverToBoxAdapter(
                child: isLoading
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(child: CupertinoActivityIndicator()),
                      )
                    : error != null
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Center(child: Text('Error: $error')),
                      )
                    : ProfileHeaderInfo(
                        avatarUrl:
                            displayProfile?.profilePictureUrl ??
                            'https://picsum.photos/seed/${displayProfile?.username.hashCode}/200/200',
                        name: displayProfile?.fullName ?? 'No Name',
                        bio: displayProfile?.bio ?? '',
                        website: "https://postra.app",
                        postsCount: displayProfile?.postCount.toString() ?? '0',
                        followersCount:
                            displayProfile?.numOfFollowers.toString() ?? '0',
                        followingCount:
                            displayProfile?.numOfFollowing.toString() ?? '0',
                      ),
              ),

              // Actions
              if (isSelf)
                const SliverToBoxAdapter(child: ProfileActions())
              else if (displayProfile != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Expanded(
                          child: Consumer(
                            builder: (context, ref, child) {
                              final profileState = ref.watch(
                                userProfileProvider(widget.username!),
                              );
                              return CupertinoButton(
                                color: profileState.isFollowing
                                    ? CupertinoColors.systemGrey5
                                    : theme.primaryColor,
                                padding: EdgeInsets.zero,
                                borderRadius: BorderRadius.circular(12),
                                onPressed: profileState.isTogglingFollow
                                    ? null
                                    : () {
                                        if (authState.currentUser == null) {
                                          _showErrorDialog(
                                            'You must be logged in to follow users.',
                                            isAuthError: true,
                                          );
                                        } else {
                                          ref
                                              .read(
                                                userProfileProvider(
                                                  widget.username!,
                                                ).notifier,
                                              )
                                              .toggleFollow();
                                        }
                                      },
                                child: profileState.isTogglingFollow
                                    ? const CupertinoActivityIndicator()
                                    : Text(
                                        profileState.isFollowing
                                            ? 'Unfollow'
                                            : 'Follow',
                                        style: TextStyle(
                                          color: profileState.isFollowing
                                              ? (isDark
                                                    ? CupertinoColors.white
                                                    : CupertinoColors.black)
                                              : CupertinoColors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemGrey5.withValues(
                              alpha: 0.3,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: CupertinoButton(
                            padding: const EdgeInsets.all(12),
                            onPressed: () {},
                            child: Icon(
                              CupertinoIcons.mail,
                              color: isDark
                                  ? CupertinoColors.white
                                  : CupertinoColors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // Feed Tabs
              SliverToBoxAdapter(
                child: ProfileFeedTabs(
                  selectedIndex: _selectedTab,
                  onTabChanged: (index) {
                    setState(() {
                      _selectedTab = index;
                    });
                  },
                ),
              ),

              // Personal Post Feed
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
                    child: Text('Error: ${postsProv.gettingPostsError}'),
                  ),
                )
              else if (userPosts.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 80,
                      horizontal: 32,
                    ),
                    child: Column(
                      children: [
                        Icon(
                          CupertinoIcons.doc_text,
                          size: 64,
                          color: isDark
                              ? CupertinoColors.systemGrey
                              : CupertinoColors.systemGrey2,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No posts yet',
                          style: theme.textTheme.textStyle.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Share your thoughts with the world',
                          style: theme.textTheme.textStyle.copyWith(
                            fontSize: 14,
                            color: isDark
                                ? CupertinoColors.systemGrey
                                : CupertinoColors.systemGrey2,
                          ),
                        ),
                        const SizedBox(height: 24),
                        CupertinoButton(
                          color: isDark
                              ? CupertinoColors.white
                              : CupertinoColors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          borderRadius: BorderRadius.circular(100),
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true).push(
                              CupertinoPageRoute(
                                builder: (context) => const CreatePostPage(),
                              ),
                            );
                          },
                          child: Text(
                            'Create New Post',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? CupertinoColors.black
                                  : CupertinoColors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.only(bottom: 120, top: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final post = userPosts[index];
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
                          authorAvatar:
                              post.profilePic ??
                              'https://picsum.photos/seed/alex/100/100',
                          timestamp: TimeFormatter.getRelativeTime(
                            post.createdAt,
                          ),
                          title: post.title,
                          imageUrl: post.postBanner,
                          content: post.subTitle,
                          likes: post.likeCount.toString(),
                          comments: post.commentCount.toString(),
                          isLiked: post.isLiked,
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
                        ),
                      );
                    }, childCount: userPosts.length),
                  ),
                ),
            ],
          ),

          // Sticky Top Navigation
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: theme.scaffoldBackgroundColor.withValues(alpha: 0.8),
                  child: SafeArea(
                    bottom: false,
                    child: Container(
                      height: 56,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (!isSelf)
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Icon(CupertinoIcons.back),
                            ),
                          Text(
                            "@${displayProfile?.username ?? ""}",
                            style: theme.textTheme.textStyle.copyWith(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Row(
                            children: [
                              if (isSelf)
                                CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () async {
                                    await ref
                                        .read(authProvider.notifier)
                                        .logout();
                                  },
                                  child: const Icon(
                                    CupertinoIcons.power,
                                    color: CupertinoColors.systemRed,
                                  ),
                                ),
                              const SizedBox(width: 8),
                              CupertinoButton(
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  MyApp.of(context).toggleTheme();
                                },
                                child: Icon(
                                  isDark
                                      ? CupertinoIcons.sun_max
                                      : CupertinoIcons.moon,
                                  color: isDark
                                      ? CupertinoColors.white
                                      : CupertinoColors.black,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
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
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CommentsBottomSheet(slug: slug),
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
