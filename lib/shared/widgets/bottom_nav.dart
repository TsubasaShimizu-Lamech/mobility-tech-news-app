import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/news/news_screen.dart';
import '../../features/bookmark/bookmark_screen.dart';
import '../../features/settings/settings_screen.dart';

final _currentTabProvider = StateProvider<int>((ref) => 0);

class MainScaffold extends ConsumerWidget {
  const MainScaffold({super.key});

  static const _screens = [
    NewsScreen(),
    BookmarkScreen(),
    SettingsScreen(),
  ];

  static const _destinations = [
    (
      icon: Icons.newspaper_outlined,
      activeIcon: Icons.newspaper,
      label: 'ニュース',
    ),
    (
      icon: Icons.bookmark_border,
      activeIcon: Icons.bookmark,
      label: '保存済み',
    ),
    (
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
      label: '設定',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(_currentTabProvider);
    final isWide = MediaQuery.of(context).size.width >= 600;

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: currentTab,
              onDestinationSelected: (index) =>
                  ref.read(_currentTabProvider.notifier).state = index,
              labelType: NavigationRailLabelType.all,
              destinations: [
                for (final d in _destinations)
                  NavigationRailDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.activeIcon),
                    label: Text(d.label),
                  ),
              ],
            ),
            const VerticalDivider(width: 1, thickness: 1),
            Expanded(
              child: IndexedStack(
                index: currentTab,
                children: _screens,
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: currentTab,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentTab,
        onTap: (index) => ref.read(_currentTabProvider.notifier).state = index,
        items: [
          for (final d in _destinations)
            BottomNavigationBarItem(
              icon: Icon(d.icon),
              activeIcon: Icon(d.activeIcon),
              label: d.label,
            ),
        ],
      ),
    );
  }
}
