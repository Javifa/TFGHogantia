import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/responsive.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../core/widgets/confirm_dialog.dart';
import 'package:go_router/go_router.dart';
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
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

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
          final productosEstancia = facade.productos
              .where((p) => p.estanciaId == widget.estanciaId)
              .toList();
          final productosFiltrados = _searchQuery.isEmpty
              ? productosEstancia
              : productosEstancia
                    .where((p) => p.nombre.toLowerCase().contains(_searchQuery))
                    .toList();

          if (facade.cargando && productosEstancia.isEmpty) {
            return const AppLoadingIndicator(mensaje: 'Cargando productos...');
          }
          if (facade.error != null && productosEstancia.isEmpty) {
            return AppErrorWidget(
              mensaje: facade.error!,
              onReintentar: () => facade.cargarProductos(widget.estanciaId),
            );
          }
          if (productosEstancia.isEmpty) return _buildVacio(isSearch: false);

          return RefreshIndicator(
            onRefresh: () => facade.cargarProductos(widget.estanciaId),
            color: AppColors.primary,
            child: Responsive.constrained(
              context: context,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(hp, 16, hp, 8),
                      child: TextField(
                        controller: _searchCtrl,
                        decoration: InputDecoration(
                          hintText: 'Buscar producto',
                          prefixIcon: const Icon(Icons.search_rounded),
                          filled: true,
                          fillColor: AppColors.card,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val.toLowerCase();
                          });
                        },
                      ),
                    ),
                  ),
                  if (productosFiltrados.isEmpty && _searchQuery.isNotEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _buildVacio(isSearch: true),
                    ),
                  // Alerta bajo stock
                  if (facade.productosBajoStock
                      .where((p) => p.estanciaId == widget.estanciaId)
                      .isNotEmpty)
                    SliverToBoxAdapter(
                      child: Container(
                        margin: EdgeInsets.fromLTRB(hp, 8, hp, 0),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.warning.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.warning_amber_rounded,
                              color: AppColors.warning,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${facade.productosBajoStock.where((p) => p.estanciaId == widget.estanciaId).length} producto(s) con bajo stock',
                              style: const TextStyle(
                                color: AppColors.warning,
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // Lista
                  if (productosFiltrados.isNotEmpty)
                    SliverPadding(
                      padding: EdgeInsets.all(hp),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((_, i) {
                          final p = productosFiltrados[i];
                          return ProductoCard(
                            producto: p,
                            onIncrementar: () =>
                                facade.cambiarCantidad(p.id, 1),
                            onDecrementar: () =>
                                facade.cambiarCantidad(p.id, -1),
                            onEliminar: () => _eliminar(p.id),
                            onTap: () => context.go(
                              '/estancia/${widget.estanciaId}/producto/${p.id}',
                            ),
                          );
                        }, childCount: productosFiltrados.length),
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 80)),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_productos',
        onPressed: _agregar,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildVacio({bool isSearch = false}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                isSearch
                    ? Icons.search_off_rounded
                    : Icons.inventory_2_outlined,
                size: 36,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isSearch ? 'No se encontraron productos' : 'Sin productos aún',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              isSearch
                  ? 'Intenta buscar con otro término.'
                  : 'Añade productos para controlar\nel stock de esta estancia',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (!isSearch) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _agregar,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Añadir producto'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _eliminar(String id) async {
    final ok = await ConfirmDialog.mostrar(
      context,
      titulo: 'Eliminar producto',
      mensaje: '¿Seguro?',
      textoConfirmar: 'Eliminar',
      esPeligroso: true,
    );
    if (ok && mounted) context.read<ProductosFacade>().eliminarProducto(id);
  }
}
