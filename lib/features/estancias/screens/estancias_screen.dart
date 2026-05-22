import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/responsive.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../facades/estancias_facade.dart';
import '../models/estancia.dart';
import 'widgets/estancia_card.dart';
import 'widgets/estancia_form.dart';
import '../../auth/facades/auth_facade.dart';
import '../../productos/facades/productos_facade.dart';

/// Pantalla principal de estancias del hogar (Dark Neon Theme).
class EstanciasScreen extends StatefulWidget {
  const EstanciasScreen({super.key});
  @override
  State<EstanciasScreen> createState() => _EstanciasScreenState();
}

class _EstanciasScreenState extends State<EstanciasScreen> {
  final _searchCtrl = TextEditingController();

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EstanciasFacade>().cargarEstancias();
      context.read<ProductosFacade>().cargarTodos();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _crear() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const EstanciaForm(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hp = Responsive.horizontalPadding(context);
    final cols = Responsive.gridColumns(context);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_estancias_main',
        onPressed: _crear,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        child: const Icon(Icons.add_rounded, size: 28),
      ),
      body: SafeArea(
        child: Consumer2<EstanciasFacade, ProductosFacade>(
          builder: (context, facade, productosFacade, _) {
            if (facade.cargando && facade.estancias.isEmpty) {
              return const AppLoadingIndicator(mensaje: 'Cargando estancias...');
            }
            if (facade.error != null && facade.estancias.isEmpty) {
              return AppErrorWidget(mensaje: facade.error!, onReintentar: facade.cargarEstancias);
            }

            final estanciasFiltradas = _searchQuery.isEmpty 
                ? facade.estancias 
                : facade.estancias.where((e) => 
                    e.nombre.toLowerCase().contains(_searchQuery)
                  ).toList();

            return RefreshIndicator(
              onRefresh: facade.cargarEstancias,
              color: AppColors.primary,
              child: Responsive.constrained(
                context: context,
                child: CustomScrollView(
                  slivers: [
                    // ── Header Custom ──
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(hp, 24, hp, 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'TU HOGAR',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.2,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Estancias',
                                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Consumer<AuthFacade>(
                              builder: (context, auth, _) {
                                final usuario = auth.usuario;
                                final inicial = usuario?.nombreVisible.isNotEmpty == true
                                    ? usuario!.nombreVisible[0].toUpperCase()
                                    : '?';

                                return GestureDetector(
                                  onTap: () => context.go('/perfil'),
                                  child: CircleAvatar(
                                    radius: 20,
                                    backgroundColor: AppColors.primary.withOpacity(0.1),
                                    backgroundImage: usuario?.avatarUrl != null
                                        ? NetworkImage(usuario!.avatarUrl!)
                                        : null,
                                    child: usuario?.avatarUrl == null
                                        ? Text(
                                            inicial,
                                            style: const TextStyle(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          )
                                        : null,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ── Search Bar ──
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(hp, 8, hp, 24),
                        child: TextField(
                          controller: _searchCtrl,
                          decoration: InputDecoration(
                            hintText: 'Buscar estancias',
                            prefixIcon: const Icon(Icons.search_rounded),
                            filled: true,
                            fillColor: AppColors.card,
                            contentPadding: const EdgeInsets.symmetric(vertical: 14),
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

                    // ── Grid o Vacío ──
                    if (estanciasFiltradas.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _buildVacio(isSearch: _searchQuery.isNotEmpty),
                      )
                    else
                      SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: hp),
                        sliver: SliverGrid(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: cols,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.9, // Ajustado para el nuevo diseño de tarjeta
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, i) {
                              final e = estanciasFiltradas[i];
                              final cantidad = productosFacade.productos.where((p) => p.estanciaId == e.id).length;
                              return EstanciaCard(
                                estancia: e,
                                cantidadProductos: cantidad,
                                onTap: () => context.go('/estancia/${e.id}'),
                                onEditar: () => _editar(e),
                                onEliminar: () => _eliminar(e),
                              );
                            },
                            childCount: estanciasFiltradas.length,
                          ),
                        ),
                      ),

                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildVacio({bool isSearch = false}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                isSearch ? Icons.search_off_rounded : Icons.home_work_outlined, 
                size: 40, 
                color: AppColors.textSecondary
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isSearch ? 'No se encontraron resultados' : 'Aún no hay estancias', 
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isSearch ? 'Intenta buscar con otro término.' : 'Añade estancias para empezar a organizar tu hogar.', 
              style: const TextStyle(color: AppColors.textSecondary), 
              textAlign: TextAlign.center
            ),
          ],
        ),
      ),
    );
  }

  void _editar(Estancia e) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EstanciaForm(estancia: e),
    );
  }

  Future<void> _eliminar(Estancia e) async {
    final ok = await ConfirmDialog.mostrar(context, titulo: 'Eliminar estancia', mensaje: '¿Eliminar "${e.nombre}"?\nSe borrarán sus productos.', textoConfirmar: 'Eliminar', esPeligroso: true);
    if (ok && mounted) context.read<EstanciasFacade>().eliminarEstancia(e.id);
  }
}
