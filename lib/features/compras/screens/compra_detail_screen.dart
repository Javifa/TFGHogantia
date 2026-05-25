import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/responsive.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../facades/compras_facade.dart';
import 'widgets/ticket_form.dart';

/// Pantalla de detalle de una compra con soporte de ticket.
class CompraDetailScreen extends StatefulWidget {
  final String compraId;
  const CompraDetailScreen({super.key, required this.compraId});
  @override
  State<CompraDetailScreen> createState() => _CompraDetailScreenState();
}

class _CompraDetailScreenState extends State<CompraDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ComprasFacade>().cargarCompra(widget.compraId);
    });
  }

  Future<void> _adjuntarTicket() async {
    final picker = ImagePicker();
    final imagen = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1200, imageQuality: 80);
    if (imagen == null) return;
    // En modo demo simplemente mostramos feedback
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ticket adjuntado correctamente'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  void _confirmarEliminar(BuildContext context, ComprasFacade facade, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar compra'),
        content: const Text('¿Estás seguro de que deseas eliminar esta compra? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx); // Cerrar dialog
              final ok = await facade.eliminarCompra(id);
              if (ok && mounted) {
                Navigator.of(context).pop(); // Volver a lista
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Compra eliminada')));
              } else if (!ok && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(facade.error ?? 'Error al eliminar')));
              }
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hp = Responsive.horizontalPadding(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de compra'),
        actions: [
          Consumer<ComprasFacade>(
            builder: (_, facade, __) {
              final c = facade.compraActual;
              if (c == null) return const SizedBox();
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_rounded),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => TicketForm(compra: c),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                    onPressed: () => _confirmarEliminar(context, facade, c.id),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<ComprasFacade>(
        builder: (_, facade, __) {
          if (facade.cargando) return const AppLoadingIndicator();
          final c = facade.compraActual;
          if (c == null) return const Center(child: Text('Compra no encontrada'));

          return SingleChildScrollView(
            child: Responsive.constrained(
              context: context,
              child: Padding(
                padding: EdgeInsets.all(hp),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c.tienda ?? 'Sin tienda', style: Theme.of(context).textTheme.headlineMedium),
                              const SizedBox(height: 4),
                              if (c.concepto != null && c.concepto!.isNotEmpty) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                                  child: Text(c.concepto!, style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(height: 6),
                              ],
                              Text(Formatters.fechaLarga(c.fecha), style: const TextStyle(color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(16)),
                          child: Text(Formatters.moneda(c.total), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ── Ticket adjunto ──
                    if (c.imagenTicketUrl != null) ...[
                      Text('Ticket', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(c.imagenTicketUrl!, width: double.infinity, fit: BoxFit.cover),
                      ),
                      const SizedBox(height: 24),
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
                              Column(
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
                    ],

                    // ── Líneas ──
                    if (c.lineas.isNotEmpty) ...[
                      Text('Artículos', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 12),
                      ...c.lineas.map((l) => Card(
                        child: ListTile(
                          title: Text(l.nombreItem),
                          subtitle: Text('${l.cantidad} x ${Formatters.moneda(l.precioUnitario)}'),
                          trailing: Text(Formatters.moneda(l.subtotal), style: const TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      )),
                    ] else
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(12)),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline, size: 18, color: AppColors.textHint),
                            SizedBox(width: 8),
                            Text('Sin artículos detallados', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                          ],
                        ),
                      ),
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
