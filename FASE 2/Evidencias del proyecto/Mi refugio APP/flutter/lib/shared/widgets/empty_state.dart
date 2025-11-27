import 'package:flutter/material.dart';
import 'package:mi_refugio_app/shared/constants/app_colors.dart';

/// Widget reutilizable para mostrar estados vacíos de forma consistente.
///
/// Muestra un ícono, título y mensaje opcional de forma elegante y minimalista.
class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.icon,
    required this.title,
    this.message,
    this.action,
    super.key,
  });

  /// Ícono que representa el estado vacío
  final IconData icon;

  /// Título principal del estado vacío
  final String title;

  /// Mensaje descriptivo opcional
  final String? message;

  /// Acción opcional (botón)
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ícono con círculo de fondo
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 36,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // Título
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),

            if (message != null) ...[
              const SizedBox(height: 12),
              // Mensaje
              Text(
                message!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            if (action != null) ...[
              const SizedBox(height: 32),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
