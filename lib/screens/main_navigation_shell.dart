import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/constants.dart';
import '../app/localizations.dart';
import '../providers/language_provider.dart';
import 'home_screen.dart';
import 'market_price_screen.dart';
import 'procurement_screen.dart';
import 'profile_screen.dart';
import 'queue_tracking_screen.dart';

class MainNavigationShell extends StatefulWidget {
  final int initialTab;

  const MainNavigationShell({super.key, this.initialTab = 0});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
  }

  void _onTabTapped(int index) {
    if (_currentIndex == index) return;
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    context.select<LanguageProvider, String>((p) => p.currentLanguage.code);
    final s = S.of(context);
    final List<Widget> pages = [
      HomeScreen(onNavigateTab: _onTabTapped),
      ProcurementScreen(),
      QueueTrackingScreen(),
      MarketPriceScreen(),
      ProfileScreen(),
    ];

    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _currentIndex != 0) {
          _onTabTapped(0);
        }
      },
      child: Scaffold(
        body: IndexedStack(index: _currentIndex, children: pages),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: const Border(
              top: BorderSide(color: AppColors.borderSubtle, width: 1.0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavBarItem(
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home_rounded,
                    label: s.home,
                    isSelected: _currentIndex == 0,
                    onTap: () => _onTabTapped(0),
                  ),
                  _NavBarItem(
                    icon: Icons.receipt_long_outlined,
                    activeIcon: Icons.receipt_long_rounded,
                    label: s.myBookings,
                    isSelected: _currentIndex == 1,
                    onTap: () => _onTabTapped(1),
                  ),
                  _NavBarItem(
                    icon: Icons.access_time_outlined,
                    activeIcon: Icons.access_time_filled_rounded,
                    label: s.liveQueue,
                    isSelected: _currentIndex == 2,
                    onTap: () => _onTabTapped(2),
                  ),
                  _NavBarItem(
                    icon: Icons.trending_up_rounded,
                    activeIcon: Icons.trending_up_rounded,
                    label: s.price,
                    isSelected: _currentIndex == 3,
                    onTap: () => _onTabTapped(3),
                  ),
                  _NavBarItem(
                    icon: Icons.person_outline_rounded,
                    activeIcon: Icons.person_rounded,
                    label: s.profileTab,
                    isSelected: _currentIndex == 4,
                    onTap: () => _onTabTapped(4),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surfacePaleGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 22,
              color: isSelected
                  ? AppColors.primaryGreen
                  : const Color(0xFF555555),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? AppColors.primaryGreen
                    : const Color(0xFF555555),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
