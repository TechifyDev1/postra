import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PostDetailHeader extends StatelessWidget {
  final String handle;

  const PostDetailHeader({super.key, required this.handle});

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => Navigator.of(context).pop(),
            child: Row(
              children: [
                const Icon(
                  Icons.chevron_left,
                  size: 32,
                  color: CupertinoColors.activeBlue,
                ),
                Text(
                  'Feed',
                  style: TextStyle(
                    fontSize: 17,
                    color: CupertinoColors.activeBlue,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
          Text(
            handle,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? CupertinoColors.systemGrey.withValues(alpha: 0.6)
                  : CupertinoColors.systemGrey,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(width: 48), // Spacer for centering handle
        ],
      ),
    );
  }
}
