import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:mi_refugio_app/shared/constants/app_colors.dart";
import "package:mi_refugio_app/shared/constants/app_shadows.dart";

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
      _NavItem(icon: Icons.home_rounded, label: "Inicio"),
      _NavItem(icon: Icons.menu_book_rounded, label: "Diario"),
      _NavItem(icon: Icons.chat_bubble_rounded, label: "ChatBot"),
      _NavItem(icon: Icons.person_rounded, label: "Perfil"),
    ];
    final theme = Theme.of(context);

    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(26),
            boxShadow: AppShadows.soft,
          ),
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              backgroundColor: Colors.transparent,
              height: 68,
              indicatorColor: AppColors.primary.withValues(alpha: 0.14),
              indicatorShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>(
                (states) => theme.textTheme.labelMedium?.copyWith(
                  fontWeight: states.contains(WidgetState.selected)
                      ? FontWeight.w600
                      : FontWeight.w500,
                  color: states.contains(WidgetState.selected)
                      ? AppColors.primary
                      : AppColors.textSecondary.withValues(alpha: 0.7),
                ),
              ),
              iconTheme: WidgetStateProperty.resolveWith<IconThemeData?>(
                (states) => IconThemeData(
                  size: 26,
                  color: states.contains(WidgetState.selected)
                      ? AppColors.primary
                      : AppColors.textSecondary.withValues(alpha: 0.7),
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
                    label: item.label,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}
