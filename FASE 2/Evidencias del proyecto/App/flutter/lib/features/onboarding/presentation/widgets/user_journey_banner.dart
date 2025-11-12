import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mi_refugio_app/shared/constants/app_colors.dart';

class UserJourneyStep {
  const UserJourneyStep({
    required this.title,
    required this.description,
    required this.route,
    required this.icon,
  });

  final String title;
  final String description;
  final String route;
  final IconData icon;
}

class UserJourneyTimeline extends StatelessWidget {
  const UserJourneyTimeline({super.key, required this.steps});

  final List<UserJourneyStep> steps;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final step in steps)
          _JourneyTile(
            data: step,
            isLast: step == steps.last,
          ),
      ],
    );
  }
}

class _JourneyTile extends StatelessWidget {
  const _JourneyTile({required this.data, required this.isLast});

  final UserJourneyStep data;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => context.go(data.route),
      borderRadius: BorderRadius.circular(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                child: Icon(data.icon, color: AppColors.primary, size: 20),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 48,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  color: AppColors.primary.withValues(alpha: 0.15),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    data.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodySmall?.color,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class UserJourneyBanner extends StatelessWidget {
  const UserJourneyBanner({
    super.key,
    required this.onOpenGuide,
    required this.highlight,
  });

  final VoidCallback onOpenGuide;
  final String highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onOpenGuide,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            colors: [Color(0xFF7F79F9), Color(0xFF8BE1D0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recorrido guiado',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    highlight,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.auto_stories_rounded, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
