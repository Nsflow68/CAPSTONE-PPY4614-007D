import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mi_refugio_app/shared/constants/app_colors.dart';
import 'package:mi_refugio_app/shared/constants/app_shadows.dart';

class MainShell extends StatelessWidget {
  const MainShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      const _NavItem(
        icon: Icons.home_outlined,
        selectedIcon: Icons.home_rounded,
        label: 'Inicio',
      ),
      const _NavItem(
        icon: Icons.book_outlined,
        selectedIcon: Icons.book_rounded,
        label: 'Diario',
      ),
      const _NavItem(
        icon: Icons.spa_outlined,
        selectedIcon: Icons.spa_rounded,
        label: 'Bienestar',
      ),
      const _NavItem(
        icon: Icons.emoji_events_outlined,
        selectedIcon: Icons.emoji_events_rounded,
        label: 'Progreso',
      ),
      const _NavItem(
        icon: Icons.person_outlined,
        selectedIcon: Icons.person_rounded,
        label: 'Perfil',
      ),
    ];
    final theme = Theme.of(context);

    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.86),
                    Colors.white.withOpacity(0.72),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(26),
                boxShadow: AppShadows.soft,
              ),
              child: NavigationBarTheme(
                data: NavigationBarThemeData(
                  backgroundColor: Colors.transparent,
                  height: 68,
                  indicatorColor: AppColors.primary.withOpacity(0.18),
                  indicatorShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>(
                    (states) => theme.textTheme.labelMedium?.copyWith(
                      fontWeight: states.contains(WidgetState.selected)
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: states.contains(WidgetState.selected)
                          ? AppColors.primary
                          : AppColors.textSecondary.withOpacity(0.65),
                    ),
                  ),
                  iconTheme: WidgetStateProperty.resolveWith<IconThemeData?>(
                    (states) => IconThemeData(
                      size: states.contains(WidgetState.selected) ? 26 : 24,
                      color: states.contains(WidgetState.selected)
                          ? AppColors.primary
                          : AppColors.textSecondary.withOpacity(0.65),
                    ),
                  ),
                ),
                child: NavigationBar(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  selectedIndex: navigationShell.currentIndex,
                  onDestinationSelected: _onTap,
                  labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                  destinations: [
                    for (final item in items)
                      NavigationDestination(
                        icon: Icon(item.icon),
                        selectedIcon: Icon(item.selectedIcon),
                        label: item.label,
                        tooltip: item.label, // Accessibility
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}
