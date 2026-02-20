import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:postra/src/features/posts/data/models/post.dart';
import 'package:postra/src/features/post_detail/presentation/widgets/post_action_bar.dart';
import 'package:postra/src/features/post_detail/presentation/widgets/post_author_info.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:postra/src/features/post_detail/presentation/widgets/post_detail_header.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:postra/src/features/posts/presentation/providers/posts_provider.dart';
import 'package:postra/src/features/posts/presentation/widgets/comments_bottom_sheet.dart';
import 'package:postra/src/core/utils/time_formatter.dart';

class PostDetailPage extends ConsumerWidget {
  final Post post;
  const PostDetailPage({super.key, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = CupertinoTheme.of(context);

    // Watch the provider to get the latest post state
    final currentPost =
        ref.watch(postsProvider).getPostBySlug(post.slug) ?? post;

    return CupertinoPageScaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: Stack(
        children: [
          // Scrollable Content
          Positioned.fill(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                const SliverToBoxAdapter(
                  child: SizedBox(height: 60), // Spacer for header
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PostAuthorInfo(
                          name: currentPost.authorFullName,
                          avatarUrl:
                              currentPost.profilePic ??
                              'https://picsum.photos/seed/alex/200/200',
                          metadata:
                              '${TimeFormatter.formatFullDate(currentPost.createdAt)} • 6 min read',
                        ),
                        Text(
                          currentPost.title,
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            color: theme.brightness == Brightness.dark
                                ? CupertinoColors.white
                                : CupertinoColors.black,
                            height: 1.1,
                            letterSpacing: -1,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        const SizedBox(height: 24),
                        HtmlWidget(
                          currentPost.content,
                          textStyle: TextStyle(
                            fontSize: 18,
                            height: 1.6,
                            color: theme.brightness == Brightness.dark
                                ? CupertinoColors.systemGrey
                                : CupertinoColors.darkBackgroundGray,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Sticky Top Header (Back Button)
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
                    child: PostDetailHeader(handle: currentPost.username),
                  ),
                ),
              ),
            ),
          ),

          // Sticky Bottom Action Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  color: theme.scaffoldBackgroundColor.withValues(alpha: 0.8),
                  child: SafeArea(
                    top: false,
                    child: PostDetailActionBar(
                      likes: currentPost.likeCount.toString(),
                      comments: currentPost.commentCount.toString(),
                      isLiked: currentPost.isLiked,
                      onLikeTap: () => ref
                          .read(postsProvider.notifier)
                          .toggleLike(currentPost),
                      onCommentTap: () =>
                          _showComments(context, currentPost.slug),
                    ),
                  ),
                ),
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
}
