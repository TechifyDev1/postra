import 'package:flutter/cupertino.dart';
import 'package:postra/src/shared/widgets/postra_image.dart';

class PostContentView extends StatelessWidget {
  final String title;
  final List<PostContentItem> contentItems;

  const PostContentView({
    super.key,
    required this.title,
    required this.contentItems,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w800,
            color: isDark ? CupertinoColors.white : CupertinoColors.black,
            height: 1.1,
            letterSpacing: -1,
            decoration: TextDecoration.none,
          ),
        ),
        const SizedBox(height: 24),
        ...contentItems.map((item) => _buildContentItem(context, item)),
      ],
    );
  }

  Widget _buildContentItem(BuildContext context, PostContentItem item) {
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;

    switch (item.type) {
      case PostContentType.text:
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Text(
            item.content,
            style: TextStyle(
              fontSize: 18,
              height: 1.6,
              color: isDark
                  ? CupertinoColors.systemGrey
                  : CupertinoColors.darkBackgroundGray,
              decoration: TextDecoration.none,
            ),
          ),
        );
      case PostContentType.image:
        return Padding(
          padding: const EdgeInsets.only(bottom: 32, top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PostraImage(
                imageUrl: item.content,
                borderRadius: BorderRadius.circular(16),
                width: double.infinity,
              ),
              if (item.caption != null) ...[
                const SizedBox(height: 12),
                Text(
                  item.caption!,
                  style: TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.systemGrey,
                    fontStyle: FontStyle.italic,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ],
          ),
        );
      case PostContentType.header:
        return Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 12),
          child: Text(
            item.content,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? CupertinoColors.white : CupertinoColors.black,
              decoration: TextDecoration.none,
            ),
          ),
        );
      case PostContentType.blockquote:
        return Container(
          margin: const EdgeInsets.only(bottom: 24, top: 8),
          padding: const EdgeInsets.only(left: 20, top: 8, bottom: 8),
          decoration: const BoxDecoration(
            border: Border(
              left: BorderSide(color: CupertinoColors.activeBlue, width: 4),
            ),
          ),
          child: Text(
            item.content,
            style: TextStyle(
              fontSize: 20,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w300,
              color: isDark ? CupertinoColors.white : CupertinoColors.black,
              height: 1.4,
              decoration: TextDecoration.none,
            ),
          ),
        );
      case PostContentType.tagBar:
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: item.tags!.map((tag) => _buildTag(context, tag)).toList(),
        );
    }
  }

  Widget _buildTag(BuildContext context, String tag) {
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? CupertinoColors.systemGrey6.darkColor
            : CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        '#$tag',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isDark
              ? CupertinoColors.systemGrey
              : CupertinoColors.systemGrey,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }
}

enum PostContentType { text, image, header, blockquote, tagBar }

class PostContentItem {
  final PostContentType type;
  final String content;
  final String? caption;
  final List<String>? tags;

  PostContentItem({
    required this.type,
    required this.content,
    this.caption,
    this.tags,
  });
}
