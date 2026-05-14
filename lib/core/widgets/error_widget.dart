import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Widget de error reutilizable con botón de reintentar.
class AppErrorWidget extends StatelessWidget {
  final String mensaje;
  final VoidCallback? onReintentar;
  final IconData icono;

  const AppErrorWidget({
    super.key,
    required this.mensaje,
    this.onReintentar,
    this.icono = Icons.error_outline_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icono,
              size: 64,
              color: AppColors.error.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 16),
            Text(
              mensaje,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onReintentar != null) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: onReintentar,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reintentar'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
