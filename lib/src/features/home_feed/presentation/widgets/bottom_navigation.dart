import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const BottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 88,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor.withValues(alpha: 0.95),
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
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _TabItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: 'Home',
            isSelected: selectedIndex == 0,
            onTap: () => onItemSelected(0),
          ),
          _TabItem(
            icon: Icons.search_outlined,
            activeIcon: Icons.search,
            label: 'Search',
            isSelected: selectedIndex == 1,
            onTap: () => onItemSelected(1),
          ),
          _TabItem(
            icon: Icons.explore_outlined,
            activeIcon: Icons.explore,
            label: 'Discover',
            isSelected: selectedIndex == 2,
            onTap: () => onItemSelected(2),
          ),
          _TabItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: 'Profile',
            isSelected: selectedIndex == 3,
            onTap: () => onItemSelected(3),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = CupertinoTheme.of(context).primaryColor;

    return CupertinoButton(
      padding: const EdgeInsets.only(top: 12),
      onPressed: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSelected ? activeIcon : icon,
            size: 26,
            color: isSelected ? primaryColor : CupertinoColors.systemGrey,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? primaryColor : CupertinoColors.systemGrey,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}
