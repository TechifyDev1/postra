import 'package:flutter/cupertino.dart';

class TrendingTopics extends StatelessWidget {
  const TrendingTopics({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final List<String> topics = [
      'Architecture',
      'Minimalism',
      'Photography',
      'UI Design',
      'Branding',
      'Art',
    ];

    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: topics.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              color: isDark
                  ? CupertinoColors.systemGrey.withValues(alpha: 0.1)
                  : CupertinoColors.systemGrey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(100),
              minimumSize: Size.zero,
              onPressed: () {},
              child: Text(
                topics[index],
                style: theme.textTheme.textStyle.merge(
                  TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? CupertinoColors.white
                        : CupertinoColors.black,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
