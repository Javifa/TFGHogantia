import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/responsive.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../productos/facades/productos_facade.dart';
import '../../productos/screens/widgets/producto_card.dart';
import '../../productos/screens/widgets/producto_form.dart';
import '../facades/estancias_facade.dart';

/// Pantalla de detalle de una estancia con sus productos.
class EstanciaDetailScreen extends StatefulWidget {
  final String estanciaId;
  const EstanciaDetailScreen({super.key, required this.estanciaId});
  @override
  State<EstanciaDetailScreen> createState() => _EstanciaDetailScreenState();
}

class _EstanciaDetailScreenState extends State<EstanciaDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EstanciasFacade>().cargarEstancia(widget.estanciaId);
      context.read<ProductosFacade>().cargarProductos(widget.estanciaId);
    });
  }

  void _agregar() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProductoForm(estanciaId: widget.estanciaId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hp = Responsive.horizontalPadding(context);

    return Scaffold(
      appBar: AppBar(
        title: Consumer<EstanciasFacade>(
          builder: (_, f, __) {
            final e = f.estanciaActual;
            if (e == null) return const Text('Estancia');
            return Text('${e.icono} ${e.nombre}');
          },
        ),
      ),
      body: Consumer<ProductosFacade>(
        builder: (context, facade, _) {
          if (facade.cargando && facade.productos.isEmpty) {
            return const AppLoadingIndicator(mensaje: 'Cargando productos...');
          }
          if (facade.error != null && facade.productos.isEmpty) {
            return AppErrorWidget(mensaje: facade.error!, onReintentar: () => facade.cargarProductos(widget.estanciaId));
          }
          if (facade.productos.isEmpty) return _buildVacio();

          return RefreshIndicator(
            onRefresh: () => facade.cargarProductos(widget.estanciaId),
            color: AppColors.primary,
            child: Responsive.constrained(
              context: context,
              child: CustomScrollView(
                slivers: [
                  // Alerta bajo stock
                  if (facade.productosBajoStock.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Container(
                        margin: EdgeInsets.fromLTRB(hp, 8, hp, 0),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.warning.withValues(alpha: 0.25)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 18),
                            const SizedBox(width: 8),
                            Text('${facade.productosBajoStock.length} producto(s) con bajo stock',
                                style: const TextStyle(color: AppColors.warning, fontWeight: FontWeight.w500, fontSize: 13)),
                          ],
                        ),
                      ),
                    ),
                  // Lista
                  SliverPadding(
                    padding: EdgeInsets.all(hp),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) {
                          final p = facade.productos[i];
                          return ProductoCard(
                            producto: p,
                            onIncrementar: () => facade.cambiarCantidad(p.id, 1),
                            onDecrementar: () => facade.cambiarCantidad(p.id, -1),
                            onEliminar: () => _eliminar(p.id),
                          );
                        },
                        childCount: facade.productos.length,
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 80)),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(heroTag: 'fab_productos', onPressed: _agregar, child: const Icon(Icons.add_rounded)),
    );
  }

  Widget _buildVacio() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(18)),
              child: const Icon(Icons.inventory_2_outlined, size: 36, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            Text('Sin productos aún', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text('Añade productos para controlar\nel stock de esta estancia', style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(onPressed: _agregar, icon: const Icon(Icons.add_rounded, size: 18), label: const Text('Añadir producto')),
          ],
        ),
      ),
    );
  }

  Future<void> _eliminar(String id) async {
    final ok = await ConfirmDialog.mostrar(context, titulo: 'Eliminar producto', mensaje: '¿Seguro?', textoConfirmar: 'Eliminar', esPeligroso: true);
    if (ok && mounted) context.read<ProductosFacade>().eliminarProducto(id);
  }
}
