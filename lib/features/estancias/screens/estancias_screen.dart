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

/// Pantalla principal de estancias del hogar (Dark Neon Theme).
class EstanciasScreen extends StatefulWidget {
  const EstanciasScreen({super.key});
  @override
  State<EstanciasScreen> createState() => _EstanciasScreenState();
}

class _EstanciasScreenState extends State<EstanciasScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EstanciasFacade>().cargarEstancias();
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
      body: SafeArea(
        child: Consumer<EstanciasFacade>(
          builder: (context, facade, _) {
            if (facade.cargando && facade.estancias.isEmpty) {
              return const AppLoadingIndicator(mensaje: 'Cargando estancias...');
            }
            if (facade.error != null && facade.estancias.isEmpty) {
              return AppErrorWidget(mensaje: facade.error!, onReintentar: facade.cargarEstancias);
            }

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
                            FloatingActionButton(
                              heroTag: 'fab_estancias',
                              mini: true,
                              onPressed: _crear,
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              child: const Icon(Icons.add_rounded),
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
                            hintText: 'Buscar estancias o productos',
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
                            // TODO: Implementar filtrado local
                          },
                        ),
                      ),
                    ),

                    // ── Grid o Vacío ──
                    if (facade.estancias.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _buildVacio(),
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
                              final e = facade.estancias[i];
                              return EstanciaCard(
                                estancia: e,
                                onTap: () => context.go('/estancia/${e.id}'),
                                onEditar: () => _editar(e),
                                onEliminar: () => _eliminar(e),
                              );
                            },
                            childCount: facade.estancias.length,
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

  Widget _buildVacio() {
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
              child: const Icon(Icons.home_work_outlined, size: 40, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            Text('Aún no hay estancias', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text('Añade estancias para empezar a organizar tu hogar.', style: TextStyle(color: AppColors.textSecondary), textAlign: TextAlign.center),
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
