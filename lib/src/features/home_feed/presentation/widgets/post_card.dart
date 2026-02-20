import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:postra/src/shared/widgets/postra_image.dart';

class PostCard extends StatelessWidget {
  final String authorName;
  final String? authorAvatar;
  final String timestamp;
  final String title;
  final String content;
  final String? imageUrl;
  final String likes;
  final String comments;
  final bool isLiked;
  final VoidCallback onLikeTap;
  final VoidCallback onCommentTap;
  final VoidCallback onShareTap;
  final VoidCallback? onEditTap;
  final VoidCallback? onDeleteTap;
  final VoidCallback? onAuthorTap;
  final bool isOwner;

  const PostCard({
    super.key,
    required this.authorName,
    this.authorAvatar,
    required this.timestamp,
    required this.title,
    required this.content,
    this.imageUrl,
    required this.likes,
    required this.comments,
    this.isLiked = false,
    required this.onLikeTap,
    required this.onCommentTap,
    required this.onShareTap,
    this.onEditTap,
    this.onDeleteTap,
    this.onAuthorTap,
    this.isOwner = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? CupertinoColors.systemGrey6.darkColor
            : CupertinoColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? CupertinoColors.systemGrey.withValues(alpha: 0.1)
              : CupertinoColors.systemGrey.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author Header
          GestureDetector(
            onTap: onAuthorTap,
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                _Avatar(imageUrl: authorAvatar),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$authorName • $timestamp',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? CupertinoColors.systemGrey
                              : CupertinoColors.systemGrey,
                          letterSpacing: 0.5,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isOwner)
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => _showActionSheet(context),
                    child: Icon(
                      CupertinoIcons.ellipsis,
                      size: 20,
                      color: isDark
                          ? CupertinoColors.systemGrey
                          : CupertinoColors.systemGrey,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Optional Post Image
          if (imageUrl != null) ...[
            PostraImage(
              imageUrl: imageUrl!.startsWith('http')
                  ? imageUrl!
                  : 'https://picsum.photos/seed/${imageUrl.hashCode}/800/450',
              borderRadius: BorderRadius.circular(16),
              width: double.infinity,
              height: 200,
            ),
            const SizedBox(height: 16),
          ],

          // Post Title
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? CupertinoColors.white : CupertinoColors.black,
              height: 1.2,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 8),

          // Post Content
          Text(
            content,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? CupertinoColors.systemGrey
                  : CupertinoColors.systemGrey,
              height: 1.5,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 20),

          // Footer Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _StatItem(
                    icon: isLiked ? Icons.favorite : Icons.favorite_border,
                    iconColor: isLiked ? CupertinoColors.destructiveRed : null,
                    label: likes,
                    onTap: onLikeTap,
                  ),
                  const SizedBox(width: 20),
                  _StatItem(
                    icon: Icons.chat_bubble_outline,
                    label: comments,
                    onTap: onCommentTap,
                  ),
                ],
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: onShareTap,
                child: Icon(
                  Icons.ios_share,
                  size: 18,
                  color: isDark
                      ? CupertinoColors.systemGrey
                      : CupertinoColors.systemGrey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showActionSheet(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('Post Options'),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              if (onEditTap != null) onEditTap!();
            },
            child: const Text('Edit'),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              _showDeleteConfirmation(context);
            },
            child: const Text('Delete'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              if (onDeleteTap != null) onDeleteTap!();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? imageUrl;

  const _Avatar({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      child: PostraImage(
        imageUrl: (imageUrl != null && imageUrl!.startsWith('http'))
            ? imageUrl!
            : 'https://picsum.photos/seed/${imageUrl.hashCode}/100/100',
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String label;
  final VoidCallback onTap;

  const _StatItem({
    required this.icon,
    this.iconColor,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color:
                iconColor ??
                (isDark
                    ? CupertinoColors.systemGrey
                    : CupertinoColors.systemGrey),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? CupertinoColors.systemGrey
                  : CupertinoColors.systemGrey,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}
