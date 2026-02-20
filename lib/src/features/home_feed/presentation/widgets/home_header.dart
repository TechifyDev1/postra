import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:postra/main.dart';
import 'package:postra/src/features/auth/presentation/providers/auth_provider.dart';
import 'package:postra/src/shared/widgets/postra_image.dart';

class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = CupertinoTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authState = ref.watch(authProvider);
    final user = authState.currentUser;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'Home',
            style: theme.textTheme.navLargeTitleTextStyle.copyWith(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.none,
            ),
          ),
          Row(
            children: [
              _HeaderAction(
                icon: isDark ? CupertinoIcons.sun_max : CupertinoIcons.moon,
                onPressed: () {
                  MyApp.of(context).toggleTheme();
                },
              ),
              const SizedBox(width: 16),
              _UserProfileImage(imageUrl: user?.profilePictureUrl),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _HeaderAction({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark
              ? CupertinoColors.systemGrey6.darkColor
              : CupertinoColors.systemGrey6,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 24,
          color: isDark ? CupertinoColors.white : CupertinoColors.black,
        ),
      ),
    );
  }
}

class _UserProfileImage extends StatelessWidget {
  final String? imageUrl;

  const _UserProfileImage({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: CupertinoColors.systemGrey.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: PostraImage(
        imageUrl: imageUrl ?? 'https://picsum.photos/seed/user_me/100/100',
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
