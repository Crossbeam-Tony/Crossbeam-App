import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'crossbeam_header.dart';
import 'expandable_bottom_nav.dart';

class BaseLayout extends StatelessWidget {
  final Widget child;

  const BaseLayout({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final int selectedIndex =
        _calculateSelectedIndex(GoRouterState.of(context));

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            const CrossbeamHeader(),
            Expanded(child: child),
          ],
        ),
      ),
      bottomNavigationBar: ExpandableBottomNav(
        currentIndex: selectedIndex,
        onTap: (index) => _onItemTapped(context, index),
        primaryItems: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.feed_outlined), label: 'Feed'),
          BottomNavigationBarItem(
              icon: Icon(Icons.work_outline), label: 'Projects'),
          BottomNavigationBarItem(
              icon: Icon(Icons.group_outlined), label: 'Crews'),
          BottomNavigationBarItem(
              icon: Icon(Icons.event_outlined), label: 'Events'),
          BottomNavigationBarItem(
              icon: Icon(Icons.storefront_outlined), label: 'Marketplace'),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(GoRouterState state) {
    final location = state.uri.path;
    if (location.startsWith('/feed') || location == '/') return 0;
    if (location.startsWith('/projects')) return 1;
    if (location.startsWith('/crews')) return 2;
    if (location.startsWith('/events')) return 3;
    if (location.startsWith('/marketplace')) return 4;
    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/projects');
        break;
      case 2:
        context.go('/crews');
        break;
      case 3:
        context.go('/events');
        break;
      case 4:
        context.go('/marketplace');
        break;
    }
  }
}
