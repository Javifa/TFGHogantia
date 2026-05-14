import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../models/estancia.dart';

/// Tarjeta de estancia con diseño único para el tema dark neon.
class EstanciaCard extends StatefulWidget {
  final Estancia estancia;
  final VoidCallback? onTap;
  final VoidCallback? onEditar;
  final VoidCallback? onEliminar;

  const EstanciaCard({
    super.key,
    required this.estancia,
    this.onTap,
    this.onEditar,
    this.onEliminar,
  });

  @override
  State<EstanciaCard> createState() => _EstanciaCardState();
}

class _EstanciaCardState extends State<EstanciaCard> {
  bool _hovering = false;

  // Helper para asignar un color de icono basado en el nombre o tipo
  Color _getIconColor() {
    final name = widget.estancia.nombre.toLowerCase();
    if (name.contains('cocina') || name.contains('kitchen')) return const Color(0xFFF97316); // Orange
    if (name.contains('baño') || name.contains('bath')) return const Color(0xFF14B8A6); // Teal
    if (name.contains('dormitorio') || name.contains('bed')) return const Color(0xFFA855F7); // Purple
    if (name.contains('salon') || name.contains('living')) return const Color(0xFF3B82F6); // Blue
    if (name.contains('garaje') || name.contains('garage')) return const Color(0xFFEAB308); // Yellow
    if (name.contains('jardin') || name.contains('garden')) return const Color(0xFF22C55E); // Green
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = _getIconColor();

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          transform: _hovering
              ? (Matrix4.identity()..setTranslationRaw(0, -3, 0))
              : Matrix4.identity(),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _hovering ? AppColors.border.withValues(alpha: 0.8) : AppColors.border.withValues(alpha: 0.3),
            ),
            boxShadow: [
              if (_hovering)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
            ],
          ),
          child: Stack(
            children: [
              // Contenido
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Icono con fondo coloreado ligeramente
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(widget.estancia.icono, style: TextStyle(fontSize: 22, color: iconColor)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.estancia.nombre,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '0 productos', // Muestra items (placeholder)
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Menú
              Positioned(
                top: 8,
                right: 8,
                child: PopupMenuButton<String>(
                  icon: Icon(Icons.more_horiz, size: 20, color: _hovering ? AppColors.textSecondary : Colors.transparent),
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  color: AppColors.surfaceVariant,
                  onSelected: (v) {
                    if (v == 'editar') widget.onEditar?.call();
                    if (v == 'eliminar') widget.onEliminar?.call();
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'editar', child: Row(children: [Icon(Icons.edit_outlined, size: 16, color: AppColors.textPrimary), SizedBox(width: 8), Text('Editar', style: TextStyle(color: AppColors.textPrimary))])),
                    const PopupMenuItem(value: 'eliminar', child: Row(children: [Icon(Icons.delete_outline, size: 16, color: AppColors.error), SizedBox(width: 8), Text('Eliminar', style: TextStyle(color: AppColors.error))])),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
