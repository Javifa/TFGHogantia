import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/responsive.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/error_widget.dart';
import '../facades/compras_facade.dart';
import 'widgets/compra_card.dart';
import 'widgets/ticket_form.dart';

/// Pantalla principal de compras.
class ComprasScreen extends StatefulWidget {
  const ComprasScreen({super.key});
  @override
  State<ComprasScreen> createState() => _ComprasScreenState();
}

class _ComprasScreenState extends State<ComprasScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ComprasFacade>().cargarCompras();
    });
  }

  void _nueva() {
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => const TicketForm());
  }

  @override
  Widget build(BuildContext context) {
    final hp = Responsive.horizontalPadding(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Compras')),
      body: Consumer<ComprasFacade>(
        builder: (_, facade, __) {
          if (facade.cargando && facade.compras.isEmpty) return const AppLoadingIndicator(mensaje: 'Cargando compras...');
          if (facade.error != null && facade.compras.isEmpty) return AppErrorWidget(mensaje: facade.error!, onReintentar: facade.cargarCompras);
          if (facade.compras.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72, height: 72,
                    decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(18)),
                    child: const Icon(Icons.receipt_long_outlined, size: 36, color: AppColors.accent),
                  ),
                  const SizedBox(height: 20),
                  Text('Sin compras registradas', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(onPressed: _nueva, icon: const Icon(Icons.add, size: 18), label: const Text('Registrar compra')),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: facade.cargarCompras,
            child: Responsive.constrained(
              context: context,
              child: ListView.builder(
                padding: EdgeInsets.all(hp),
                itemCount: facade.compras.length,
                itemBuilder: (_, i) {
                  final c = facade.compras[i];
                  return CompraCard(compra: c, onTap: () => context.go('/compras/${c.id}'));
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(heroTag: 'fab_compras', onPressed: _nueva, child: const Icon(Icons.add_rounded)),
    );
  }
}
