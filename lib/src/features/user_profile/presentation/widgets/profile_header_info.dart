import 'package:flutter/cupertino.dart';
import 'package:postra/src/shared/widgets/postra_image.dart';

class ProfileHeaderInfo extends StatelessWidget {
  final String avatarUrl;
  final String name;
  final String bio;
  final String website;
  final String postsCount;
  final String followersCount;
  final String followingCount;

  const ProfileHeaderInfo({
    super.key,
    required this.avatarUrl,
    required this.name,
    required this.bio,
    required this.website,
    required this.postsCount,
    required this.followersCount,
    required this.followingCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textStyle = theme.textTheme.textStyle;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? CupertinoColors.black.withValues(alpha: 0.2)
                          : CupertinoColors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: PostraImage(
                  imageUrl: avatarUrl,
                  borderRadius: BorderRadius.circular(48),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StatItem(label: 'Posts', value: postsCount),
                    _StatItem(label: 'Followers', value: followersCount),
                    _StatItem(label: 'Following', value: followingCount),
                  ],
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            name,
            style: textStyle.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            bio,
            style: textStyle.copyWith(
              fontSize: 15,
              height: 1.5,
              color: isDark
                  ? CupertinoColors.systemGrey
                  : CupertinoColors.darkBackgroundGray,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {},
            child: Text(
              website,
              style: textStyle.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: CupertinoColors.activeBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textStyle = theme.textTheme.textStyle;
    return Column(
      children: [
        Text(
          value,
          style: textStyle.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label.toUpperCase(),
          style: textStyle.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
            color: isDark
                ? CupertinoColors.systemGrey
                : CupertinoColors.systemGrey,
          ),
        ),
      ],
    );
  }
}
