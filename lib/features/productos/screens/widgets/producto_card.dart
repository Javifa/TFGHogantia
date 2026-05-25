import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../models/producto.dart';

/// Tarjeta de producto con botones +/- para cantidad.
class ProductoCard extends StatelessWidget {
  final Producto producto;
  final VoidCallback? onIncrementar;
  final VoidCallback? onDecrementar;
  final VoidCallback? onEliminar;
  final VoidCallback? onTap;

  const ProductoCard({
    super.key,
    required this.producto,
    this.onIncrementar,
    this.onDecrementar,
    this.onEliminar,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Indicador de stock
              Container(
                width: 4,
                height: 48,
                decoration: BoxDecoration(
                  color: producto.bajoStock
                      ? AppColors.warning
                      : AppColors.success,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      producto.nombre,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          producto.cantidadTexto,
                          style: TextStyle(
                            fontSize: 13,
                            color: producto.bajoStock
                                ? AppColors.warning
                                : AppColors.textSecondary,
                          ),
                        ),
                        if (producto.categoria != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              producto.categoria!,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Botones cantidad
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _BotonCantidad(icon: Icons.remove, onTap: onDecrementar),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      '${producto.cantidad}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _BotonCantidad(icon: Icons.add, onTap: onIncrementar),
                ],
              ),
              // Eliminar
              if (onEliminar != null)
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: AppColors.error,
                  ),
                  onPressed: onEliminar,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BotonCantidad extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _BotonCantidad({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: AppColors.textPrimary),
      ),
    );
  }
}
