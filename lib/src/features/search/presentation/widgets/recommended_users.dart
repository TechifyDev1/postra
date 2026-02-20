import 'package:flutter/cupertino.dart';

class RecommendedUsers extends StatelessWidget {
  const RecommendedUsers({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final List<Map<String, String>> users = [
      {
        'name': 'Jordan Lee',
        'handle': '@jordan',
        'avatar': 'https://picsum.photos/seed/jordan/100/100',
      },
      {
        'name': 'Elena S.',
        'handle': '@elena_design',
        'avatar': 'https://picsum.photos/seed/elena/100/100',
      },
      {
        'name': 'Marcus K.',
        'handle': '@marcus_k',
        'avatar': 'https://picsum.photos/seed/marcus/100/100',
      },
      {
        'name': 'Sophie T.',
        'handle': '@sophie_zen',
        'avatar': 'https://picsum.photos/seed/sophie/100/100',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Who to follow',
                style: theme.textTheme.textStyle.merge(
                  const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {},
                child: Text(
                  'See all',
                  style: TextStyle(fontSize: 14, color: theme.primaryColor),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Container(
                width: 140,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? CupertinoColors.systemGrey.withValues(alpha: 0.1)
                      : CupertinoColors.systemGrey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: NetworkImage(user['avatar']!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user['name']!,
                      style: theme.textTheme.textStyle.merge(
                        const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      user['handle']!,
                      style: theme.textTheme.textStyle.merge(
                        const TextStyle(
                          fontSize: 12,
                          color: CupertinoColors.systemGrey,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                    const Spacer(),
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      color: theme.primaryColor,
                      borderRadius: BorderRadius.circular(100),
                      minimumSize: Size.zero,
                      onPressed: () {},
                      child: const Text(
                        'Follow',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
