import 'package:flutter/material.dart';
import 'package:mi_refugio_app/shared/constants/app_colors.dart';

/// Widget reutilizable para indicadores de carga consistentes.
///
/// Muestra un indicador circular con mensaje opcional.
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({
    this.message,
    this.size = 40.0,
    super.key,
  });

  /// Mensaje opcional a mostrar debajo del indicador
  final String? message;

  /// Tamaño del indicador circular
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: const CircularProgressIndicator(
                strokeWidth: 3,
                color: AppColors.primary,
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
