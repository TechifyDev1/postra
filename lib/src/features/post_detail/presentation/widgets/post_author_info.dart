import 'package:flutter/cupertino.dart';
import 'package:postra/src/shared/widgets/postra_image.dart';

class PostAuthorInfo extends StatelessWidget {
  final String name;
  final String avatarUrl;
  final String metadata;

  const PostAuthorInfo({
    super.key,
    required this.name,
    required this.avatarUrl,
    required this.metadata,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? CupertinoColors.black.withValues(alpha: 0.2)
                      : CupertinoColors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: PostraImage(
              imageUrl: avatarUrl,
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? CupertinoColors.white : CupertinoColors.black,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                metadata,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? CupertinoColors.systemGrey
                      : CupertinoColors.systemGrey,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
