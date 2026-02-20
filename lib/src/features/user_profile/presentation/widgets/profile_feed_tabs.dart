import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfileFeedTabs extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabChanged;

  const ProfileFeedTabs({
    super.key,
    required this.selectedIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isDark
                    ? CupertinoColors.systemGrey.withValues(alpha: 0.1)
                    : CupertinoColors.systemGrey.withValues(alpha: 0.1),
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _TabItem(
                icon: Icons.grid_view_outlined,
                isSelected: selectedIndex == 0,
                onTap: () => onTabChanged(0),
              ),
              _TabItem(
                icon: Icons.bookmark_border,
                isSelected: selectedIndex == 1,
                onTap: () => onTabChanged(1),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TabItem extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabItem({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = CupertinoTheme.of(context).primaryColor;

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 24,
            color: isSelected ? primaryColor : CupertinoColors.systemGrey,
          ),
          const SizedBox(height: 8),
          if (isSelected)
            Container(
              width: 16,
              height: 2,
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          if (!isSelected) const SizedBox(height: 2),
        ],
      ),
    );
  }
}
