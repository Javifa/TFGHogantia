import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/responsive.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/error_widget.dart';
import '../facades/gastos_facade.dart';
import 'widgets/resumen_mensual_card.dart';
import 'widgets/gasto_chart.dart';

/// Pantalla de resumen de gastos.
class GastosScreen extends StatefulWidget {
  const GastosScreen({super.key});
  @override
  State<GastosScreen> createState() => _GastosScreenState();
}

class _GastosScreenState extends State<GastosScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final f = context.read<GastosFacade>();
      f.cargarResumenMesActual();
      f.cargarHistorico();
    });
  }

  @override
  Widget build(BuildContext context) {
    final hp = Responsive.horizontalPadding(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Gastos')),
      body: Consumer<GastosFacade>(
        builder: (_, facade, __) {
          if (facade.cargando && facade.resumenActual == null) return const AppLoadingIndicator(mensaje: 'Cargando gastos...');
          if (facade.error != null && facade.resumenActual == null) return AppErrorWidget(mensaje: facade.error!, onReintentar: facade.cargarResumenMesActual);

          return SingleChildScrollView(
            child: Responsive.constrained(
              context: context,
              child: Padding(
                padding: EdgeInsets.all(hp),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nav mes
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(icon: const Icon(Icons.chevron_left_rounded), onPressed: facade.mesAnterior),
                        Text(facade.resumenActual?.mesTexto ?? '', style: Theme.of(context).textTheme.titleLarge),
                        IconButton(icon: const Icon(Icons.chevron_right_rounded), onPressed: facade.mesSiguiente),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (facade.resumenActual != null)
                      ResumenMensualCard(resumen: facade.resumenActual!),
                    const SizedBox(height: 28),
                    if (facade.historico.isNotEmpty) ...[
                      Text('Evolución mensual', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 16),
                      SizedBox(height: 240, child: GastoChart(datos: facade.historico)),
                    ],
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
