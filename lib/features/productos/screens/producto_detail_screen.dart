import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/responsive.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../facades/productos_facade.dart';
import 'widgets/producto_form.dart';

/// Pantalla de detalle de un producto con soporte de ticket.
class ProductoDetailScreen extends StatefulWidget {
  final String productoId;
  const ProductoDetailScreen({super.key, required this.productoId});
  @override
  State<ProductoDetailScreen> createState() => _ProductoDetailScreenState();
}

class _ProductoDetailScreenState extends State<ProductoDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductosFacade>().cargarProducto(widget.productoId);
    });
  }

  Future<void> _adjuntarTicket() async {
    final picker = ImagePicker();
    final imagen = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1200, imageQuality: 80);
    if (imagen == null) return;
    
    final bytes = await imagen.readAsBytes();
    
    if (mounted) {
      final facade = context.read<ProductosFacade>();
      final p = facade.productoActual;
      if (p != null) {
        final ok = await facade.actualizarProducto(p, nuevaImagenTicket: bytes);
        if (ok && mounted) {
          ScaffoldMessenger.of(context)..clearSnackBars()..showSnackBar(
            const SnackBar(content: Text('Ticket adjuntado correctamente'), behavior: SnackBarBehavior.floating),
          );
        } else if (!ok && mounted) {
          ScaffoldMessenger.of(context)..clearSnackBars()..showSnackBar(
            SnackBar(content: Text(facade.error ?? 'Error al adjuntar ticket. Revisa Supabase.'), backgroundColor: AppColors.error),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hp = Responsive.horizontalPadding(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de producto'),
        actions: [
          Consumer<ProductosFacade>(
            builder: (_, facade, __) {
              final p = facade.productoActual;
              if (p == null) return const SizedBox();
              return IconButton(
                icon: const Icon(Icons.edit_rounded),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => ProductoForm(
                      estanciaId: p.estanciaId,
                      producto: p,
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<ProductosFacade>(
        builder: (_, facade, __) {
          if (facade.cargando) return const AppLoadingIndicator();
          final p = facade.productoActual;
          if (p == null) return const Center(child: Text('Producto no encontrado'));

          return SingleChildScrollView(
            child: Responsive.constrained(
              context: context,
              child: Padding(
                padding: EdgeInsets.all(hp),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Nombre y estado ──
                    Row(
                      children: [
                        Expanded(child: Text(p.nombre, style: Theme.of(context).textTheme.headlineMedium)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: (p.bajoStock ? AppColors.warning : AppColors.success).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(p.bajoStock ? 'Bajo stock' : 'OK', style: TextStyle(color: p.bajoStock ? AppColors.warning : AppColors.success, fontWeight: FontWeight.w600, fontSize: 13)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ── Info ──
                    _InfoTile(label: 'Cantidad', valor: p.cantidadTexto, icono: Icons.inventory_2_outlined),
                    _InfoTile(label: 'Stock mínimo', valor: '${p.cantidadMinima}', icono: Icons.warning_amber_outlined),
                    if (p.categoria != null)
                      _InfoTile(label: 'Categoría', valor: p.categoria!, icono: Icons.category_outlined),
                    if (p.precioUnitario != null)
                      _InfoTile(label: 'Precio', valor: Formatters.moneda(p.precioUnitario!), icono: Icons.euro_outlined),
                    if (p.notas != null)
                      _InfoTile(label: 'Notas', valor: p.notas!, icono: Icons.notes_outlined),
                    const SizedBox(height: 16),

                    // ── Ticket ──
                    if (p.ticketUrl != null) ...[
                      Text('Ticket adjunto', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(p.ticketUrl!, width: double.infinity, fit: BoxFit.cover),
                      ),
                    ] else ...[
                      // Opción de adjuntar ticket después
                      GestureDetector(
                        onTap: _adjuntarTicket,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 40, height: 40,
                                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
                                child: const Icon(Icons.camera_alt_outlined, color: AppColors.primary, size: 20),
                              ),
                              const SizedBox(width: 12),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Adjuntar ticket', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary)),
                                  Text('Sube la foto del recibo', style: TextStyle(fontSize: 12, color: AppColors.textHint)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ]
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String valor;
  final IconData icono;
  const _InfoTile({required this.label, required this.valor, required this.icono});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(10)),
          child: Icon(icono, color: AppColors.primary, size: 20),
        ),
        title: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        subtitle: Text(valor, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      ),
    );
  }
}
