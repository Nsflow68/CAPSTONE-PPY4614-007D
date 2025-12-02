// Temporarily stubbing reward_tile to unblock compilation
import 'package:flutter/material.dart';
import 'package:mi_refugio_app/shared/constants/app_colors.dart';

class RewardTile extends StatelessWidget {
  const RewardTile({
    required this.title,
    required this.description,
    required this.points,
    this.balance,
    this.highlight = false,
    this.onTap,
    super.key,
  });

  final String title;
  final String description;
  final int points;
  final int? balance;
  final bool highlight;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final available = balance != null ? 'Tienes $balance pts' : null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: highlight
              ? const LinearGradient(
                  colors: [Color(0xFF7F79F9), Color(0xFF8BE1D0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: highlight ? null : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(
                      alpha: highlight ? 0.2 : 0.1,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    color: highlight ? Colors.white : AppColors.primary,
                  ),
                ),
                const Spacer(),
                Text(
                  '$points pts',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: highlight ? Colors.white : AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: highlight ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: highlight
                    ? Colors.white.withValues(alpha: 0.9)
                    : AppColors.textSecondary.withValues(alpha: 0.85),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Necesitas $points pts',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: highlight ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (available != null) ...[
                  const SizedBox(width: 12),
                  Text(
                    available,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: highlight ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
