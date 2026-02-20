import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:postra/src/features/user_profile/presentation/pages/edit_profile_page.dart';

class ProfileActions extends StatelessWidget {
  const ProfileActions({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(vertical: 12),
              color: isDark ? CupertinoColors.white : CupertinoColors.black,
              borderRadius: BorderRadius.circular(100),
              onPressed: () {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (context) => const EditProfilePage(),
                  ),
                );
              },
              child: Text(
                'Edit Profile',
                style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? CupertinoColors.black : CupertinoColors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: isDark
                ? CupertinoColors.systemGrey6.darkColor
                : CupertinoColors.systemGrey6,
            borderRadius: BorderRadius.circular(100),
            onPressed: () {},
            child: Icon(
              Icons.share_outlined,
              size: 20,
              color: isDark ? CupertinoColors.white : CupertinoColors.black,
            ),
          ),
        ],
      ),
    );
  }
}
