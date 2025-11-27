import 'package:flutter/material.dart';
import 'package:mi_refugio_app/core/theme/app_theme.dart';
import 'package:mi_refugio_app/shared/constants/app_colors.dart';

/// Widget reutilizable para mostrar errores de forma consistente.
///
/// Banner elegante para mostrar mensajes de error sin ser intrusivo.
class ErrorBanner extends StatelessWidget {
  const ErrorBanner({
    required this.message,
    this.onRetry,
    super.key,
  });

  /// Mensaje de error a mostrar
  final String message;

  /// Callback opcional para reintentar la acción
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 12,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: AppColors.danger.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Ícono
          Icon(
            Icons.error_outline_rounded,
            color: AppColors.danger,
            size: 24,
          ),
          const SizedBox(width: 12),

          // Mensaje
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.danger,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Botón de reintentar (opcional)
          if (onRetry != null) ...[
            const SizedBox(width: 12),
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.danger,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Reintentar'),
            ),
          ],
        ],
      ),
    );
  }
}
