import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:postra/src/features/auth/presentation/providers/auth_provider.dart';
import 'package:postra/src/core/utils/time_formatter.dart';
import '../providers/posts_provider.dart';

class CommentsBottomSheet extends ConsumerStatefulWidget {
  final String slug;
  const CommentsBottomSheet({super.key, required this.slug});

  @override
  ConsumerState<CommentsBottomSheet> createState() =>
      _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends ConsumerState<CommentsBottomSheet> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(postsProvider.notifier).getComments(widget.slug);
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitComment() {
    if (_commentController.text.trim().isEmpty) return;

    final authState = ref.read(authProvider);
    final user = authState.currentUser;

    if (user != null) {
      ref
          .read(postsProvider.notifier)
          .addComment(
            widget.slug,
            _commentController.text.trim(),
            user.username,
            user.profilePictureUrl,
          );
      _commentController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(postsProvider);
    final theme = CupertinoTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return CupertinoPageScaffold(
      backgroundColor: isDark
          ? CupertinoColors.black
          : const Color(0xFFF9FAFB), // bg-slate-50
      navigationBar: CupertinoNavigationBar(
        backgroundColor: isDark
            ? CupertinoColors.black.withValues(alpha: 0.8)
            : CupertinoColors.white.withValues(alpha: 0.8),
        middle: Text(
          'Comments',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
        ),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.chevron_down),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: state.isGettingComments
                  ? const Center(child: CupertinoActivityIndicator())
                  : state.comments.isEmpty
                  ? Center(
                      child: Text(
                        'No comments yet. Be the first!',
                        style: theme.textTheme.textStyle.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                      itemCount: state.comments.length,
                      itemBuilder: (context, index) {
                        final comment = state.comments[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark
                                ? CupertinoColors.systemGrey6.darkColor
                                : CupertinoColors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark
                                  ? CupertinoColors.systemGrey.withValues(
                                      alpha: 0.1,
                                    )
                                  : const Color(0xFFF1F5F9), // border-slate-100
                            ),
                            boxShadow: [
                              if (!isDark)
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: isDark
                                    ? CupertinoColors.systemGrey6
                                    : const Color(0xFFE2E8F0), // bg-slate-200
                                backgroundImage:
                                    (comment.profilePictureUrl != null &&
                                        comment.profilePictureUrl!.isNotEmpty)
                                    ? NetworkImage(comment.profilePictureUrl!)
                                    : null,
                                child:
                                    (comment.profilePictureUrl == null ||
                                        comment.profilePictureUrl!.isEmpty)
                                    ? Icon(
                                        CupertinoIcons.person_fill,
                                        size: 18,
                                        color: isDark
                                            ? CupertinoColors.systemGrey
                                            : const Color(0xFF94A3B8),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          comment.authorUsername,
                                          style: theme.textTheme.textStyle
                                              .copyWith(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        Text(
                                          TimeFormatter.getRelativeTime(
                                              comment.createdAt),
                                          style: theme.textTheme.textStyle
                                              .copyWith(
                                                fontSize: 11,
                                                color:
                                                    CupertinoColors.systemGrey,
                                              ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      comment.content,
                                      style: theme.textTheme.textStyle.copyWith(
                                        fontSize: 14,
                                        height: 1.5,
                                        color: isDark
                                            ? CupertinoColors.systemGrey
                                            : const Color(0xFF475569),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),

            // Comment Input Field
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: BoxDecoration(
                color: isDark ? CupertinoColors.black : CupertinoColors.white,
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? CupertinoColors.systemGrey.withValues(alpha: 0.2)
                        : const Color(0xFFF1F5F9),
                  ),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: CupertinoTextField(
                        controller: _commentController,
                        placeholder: 'Add a comment...',
                        placeholderStyle: const TextStyle(
                          color: CupertinoColors.systemGrey,
                        ),
                        style: const TextStyle(),
                        decoration: BoxDecoration(
                          color: isDark
                              ? CupertinoColors.systemGrey6.darkColor
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        maxLines: null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (state.isAddingComment)
                      const CupertinoActivityIndicator()
                    else
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: _submitComment,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            CupertinoIcons.arrow_up,
                            color: CupertinoColors.white,
                            size: 20,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
