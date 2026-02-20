import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:postra/src/core/providers/navigation_provider.dart';
import 'package:postra/src/features/auth/presentation/pages/sign_up_page.dart';
import 'package:postra/src/features/auth/presentation/providers/auth_provider.dart';
import 'package:postra/src/features/home_feed/presentation/pages/home_feed_page.dart';
import 'package:postra/src/features/search/presentation/pages/search_page.dart';
import 'package:postra/src/features/user_profile/presentation/pages/user_profile_page.dart';

class MainTabs extends ConsumerStatefulWidget {
  const MainTabs({super.key});

  @override
  ConsumerState<MainTabs> createState() => _MainTabsState();
}

class _MainTabsState extends ConsumerState<MainTabs> {
  final CupertinoTabController _tabController = CupertinoTabController();

  @override
  void initState() {
    super.initState();
    // Synchronize controller with provider on start
    _tabController.index = ref.read(navigationProvider);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen for global navigation changes
    ref.listen<int>(navigationProvider, (previous, next) {
      if (next != _tabController.index) {
        _tabController.index = next;
      }
    });

    final authProv = ref.watch(authProvider);

    // If user is not logged in, but tries to access profile tab (index 2),
    // we let them stay there to see the login/signup page.
    // However, if they just logged in, we might want to keep them on the profile tab?
    // The issue description says "after the profile tab keeps going to homepage".
    // This implies that when they log in, the tab resets to 0.
    // This is because `CupertinoTabScaffold` maintains its own state if we don't control it.
    // By lifting the state to `_currentIndex`, we can control it.

    return CupertinoTabScaffold(
      controller: _tabController,
      // we likely DON'T want to use `currentIndex` property if we use `CupertinoTabScaffold` standard behavior
      // because `CupertinoTabScaffold` manages the index internally unless we use a `CupertinoTabController`.
      // BUT, providing `currentIndex` to `CupertinoTabBar` without a controller on Scaffold causes conflict/no-op?
      // Actually, `CupertinoTabScaffold` takes a `controller`.
      // Let's use a `CupertinoTabController`.
      tabBar: CupertinoTabBar(
        height: 64, // Increased height for better spacing
        border: Border(
          top: BorderSide(
            color: CupertinoTheme.brightnessOf(context) == Brightness.dark
                ? CupertinoColors.systemGrey.withValues(alpha: 0.1)
                : CupertinoColors.systemGrey.withValues(alpha: 0.1),
            width: 0.5,
          ),
        ),
        backgroundColor: CupertinoTheme.of(
          context,
        ).scaffoldBackgroundColor.withValues(alpha: 0.95),
        activeColor: CupertinoTheme.of(context).primaryColor,
        inactiveColor: CupertinoColors.systemGrey,
        onTap: (index) {
          ref.read(navigationProvider.notifier).state = index;
        },
        items: [
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(top: 8),
              child: Icon(CupertinoIcons.home),
            ),
            activeIcon: Padding(
              padding: EdgeInsets.only(top: 8),
              child: Icon(CupertinoIcons.home),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(top: 8),
              child: Icon(CupertinoIcons.search_circle),
            ),
            activeIcon: Padding(
              padding: EdgeInsets.only(top: 8),
              child: Icon(CupertinoIcons.search_circle_fill),
            ),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(top: 8),
              child: authProv.isLoading
                  ? const CupertinoActivityIndicator()
                  : Icon(CupertinoIcons.person_fill),
            ),
            activeIcon: Padding(
              padding: EdgeInsets.only(top: 8),
              child: authProv.isLoading
                  ? const CupertinoActivityIndicator()
                  : Icon(CupertinoIcons.person_fill),
            ),
            label: 'Profile',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return CupertinoTabView(builder: (context) => const HomeFeedPage());
          case 1:
            return CupertinoTabView(builder: (context) => const SearchPage());
          case 2:
            // If explicit user, show profile
            if (authProv.currentUser != null) {
              return CupertinoTabView(
                key: ValueKey('authenticated_${authProv.currentUser!.id}'),
                builder: (context) => const UserProfilePage(),
              );
            }
            // If loading AND no user, show loading?
            // Or if we want to default to SignUpPage immediately?
            // The user request says "instead of just a loading indicator that is currently showing".
            // So we should prioritize showing SignUpPage if currentUser is null, even if it's "loading" (unless it's initial load?).
            // Let's standardise:
            if (authProv.isLoading) {
              // Keep loading indicator only if we really want to block UI,
              // but user wants to see signup page.
              // However, if we show signup page while loading, and then user appears, it might flash.
              // But let's try to show SignUpPage if currentUser is null.
            }

            return CupertinoTabView(
              key: const ValueKey('guest'),
              builder: (context) => const SignUpPage(),
            );
          default:
            return CupertinoTabView(builder: (context) => const HomeFeedPage());
        }
      },
    );
  }
}
