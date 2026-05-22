import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../models/compra.dart';

/// Tarjeta de compra para el listado.
class CompraCard extends StatelessWidget {
  final Compra compra;
  final VoidCallback? onTap;
  const CompraCard({super.key, required this.compra, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            gradient: AppColors.secondaryGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.receipt_long_rounded, color: Colors.white),
        ),
        title: Row(
          children: [
            Expanded(child: Text(compra.tienda ?? 'Sin tienda', style: const TextStyle(fontWeight: FontWeight.w600))),
            if (compra.concepto != null && compra.concepto!.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                child: Text(compra.concepto!, style: const TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
        subtitle: Text(Formatters.fechaCorta(compra.fecha), style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        trailing: Text(Formatters.moneda(compra.total), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
      ),
    );
  }
}
