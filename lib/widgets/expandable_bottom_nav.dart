import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ExpandableBottomNav extends StatelessWidget {
  final List<BottomNavigationBarItem> primaryItems;
  final int currentIndex;
  final Function(int) onTap;

  const ExpandableBottomNav({
    super.key,
    required this.primaryItems,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: primaryItems,
      type: BottomNavigationBarType.fixed,
    );
  }
}
