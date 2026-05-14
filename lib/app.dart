import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/routes.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/facades/auth_facade.dart';
import 'features/estancias/facades/estancias_facade.dart';
import 'features/productos/facades/productos_facade.dart';
import 'features/compras/facades/compras_facade.dart';
import 'features/gastos/facades/gastos_facade.dart';

/// Widget raíz de la aplicación.
/// Configura los providers (facades), el tema y el router.
class HogentiaApp extends StatelessWidget {
  const HogentiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthFacade()),
        ChangeNotifierProvider(create: (_) => EstanciasFacade()),
        ChangeNotifierProvider(create: (_) => ProductosFacade()),
        ChangeNotifierProvider(create: (_) => ComprasFacade()),
        ChangeNotifierProvider(create: (_) => GastosFacade()),
      ],
      child: MaterialApp.router(
        title: 'Hogentia',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
