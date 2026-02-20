import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PostDetailActionBar extends StatelessWidget {
  final String likes;
  final String comments;
  final bool isLiked;
  final VoidCallback onLikeTap;
  final VoidCallback onCommentTap;

  const PostDetailActionBar({
    super.key,
    required this.likes,
    required this.comments,
    this.isLiked = false,
    required this.onLikeTap,
    required this.onCommentTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark
                ? CupertinoColors.systemGrey.withValues(alpha: 0.1)
                : CupertinoColors.systemGrey.withValues(alpha: 0.1),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _ActionButton(
                icon: isLiked ? Icons.favorite : Icons.favorite_border,
                iconColor: isLiked ? CupertinoColors.destructiveRed : null,
                label: likes,
                onPressed: onLikeTap,
              ),
              const SizedBox(width: 24),
              _ActionButton(
                icon: Icons.chat_bubble_outline,
                label: comments,
                onPressed: onCommentTap,
              ),
            ],
          ),
          Row(
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {},
                child: const Icon(
                  Icons.bookmark_border,
                  color: CupertinoColors.systemGrey,
                ),
              ),
              const SizedBox(width: 16),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {},
                child: const Icon(
                  Icons.ios_share,
                  color: CupertinoColors.activeBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String label;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    this.iconColor,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Row(
        children: [
          Icon(icon, size: 24, color: iconColor ?? CupertinoColors.systemGrey),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.systemGrey,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}
