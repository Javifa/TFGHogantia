import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../config/supabase_config.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/responsive.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/registro_screen.dart';
import '../features/estancias/screens/estancias_screen.dart';
import '../features/estancias/screens/estancia_detail_screen.dart';
import '../features/productos/screens/producto_detail_screen.dart';
import '../features/compras/screens/compras_screen.dart';
import '../features/compras/screens/compra_detail_screen.dart';
import '../features/gastos/screens/gastos_screen.dart';
import '../features/perfil/screens/perfil_screen.dart';
import '../features/perfil/screens/privacidad_screen.dart';
import '../features/perfil/screens/ayuda_screen.dart';

/// Configuración de rutas de la aplicación con GoRouter.
class AppRouter {
  AppRouter._();

  static const String login = '/login';
  static const String registro = '/registro';
  static const String inicio = '/';
  static const String compras = '/compras';
  static const String gastos = '/gastos';
  static const String perfil = '/perfil';

  static final GoRouter router = GoRouter(
    initialLocation: inicio,
    debugLogDiagnostics: false,

    redirect: (BuildContext context, GoRouterState state) {
      final autenticado = SupabaseConfig.estaAutenticado;
      final enAuth = state.matchedLocation == login ||
          state.matchedLocation == registro;
      if (!autenticado && !enAuth) return login;
      if (autenticado && enAuth) return inicio;
      return null;
    },

    routes: [
      GoRoute(
        path: login,
        name: 'login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: registro,
        name: 'registro',
        builder: (_, __) => const RegistroScreen(),
      ),

      // ── Shell adaptativo: BottomNav (móvil) / NavigationRail (desktop) ──
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => _AdaptiveShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: inicio,
              name: 'estancias',
              builder: (_, __) => const EstanciasScreen(),
              routes: [
                GoRoute(
                  path: 'estancia/:id',
                  name: 'estancia-detalle',
                  builder: (_, state) => EstanciaDetailScreen(
                    estanciaId: state.pathParameters['id']!,
                  ),
                  routes: [
                    GoRoute(
                      path: 'producto/:productoId',
                      name: 'producto-detalle',
                      builder: (_, state) => ProductoDetailScreen(
                        productoId: state.pathParameters['productoId']!,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: compras,
              name: 'compras',
              builder: (_, __) => const ComprasScreen(),
              routes: [
                GoRoute(
                  path: ':id',
                  name: 'compra-detalle',
                  builder: (_, state) => CompraDetailScreen(
                    compraId: state.pathParameters['id']!,
                  ),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: gastos,
              name: 'gastos',
              builder: (_, __) => const GastosScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: perfil,
              name: 'perfil',
              builder: (_, __) => const PerfilScreen(),
              routes: [
                GoRoute(
                  path: 'privacidad',
                  name: 'privacidad',
                  builder: (_, __) => const PrivacidadScreen(),
                ),
                GoRoute(
                  path: 'ayuda',
                  name: 'ayuda',
                  builder: (_, __) => const AyudaScreen(),
                ),
              ],
            ),
          ]),
        ],
      ),
    ],
  );
}

/// Shell adaptativo: NavigationRail en desktop/tablet, BottomNav en móvil.
class _AdaptiveShell extends StatelessWidget {
  final StatefulNavigationShell shell;
  const _AdaptiveShell({required this.shell});

  static const _destinations = [
    _NavItem(Icons.home_outlined, Icons.home_rounded, 'Inicio'),
    _NavItem(Icons.receipt_long_outlined, Icons.receipt_long_rounded, 'Compras'),
    _NavItem(Icons.insights_outlined, Icons.insights_rounded, 'Gastos'),
    _NavItem(Icons.person_outline, Icons.person_rounded, 'Perfil'),
  ];

  void _onTap(int index) {
    shell.goBranch(index, initialLocation: index == shell.currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    final useRail = !Responsive.isMobile(context);

    if (useRail) {
      return Scaffold(
        body: Row(
          children: [
            // ── Rail lateral ──
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(right: BorderSide(color: AppColors.border.withValues(alpha: 0.5))),
              ),
              child: NavigationRail(
                selectedIndex: shell.currentIndex,
                onDestinationSelected: _onTap,
                extended: Responsive.isDesktop(context),
                minWidth: 72,
                minExtendedWidth: 200,
                leading: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: _LogoMini(extended: Responsive.isDesktop(context)),
                ),
                destinations: _destinations
                    .map((d) => NavigationRailDestination(
                          icon: Icon(d.icon),
                          selectedIcon: Icon(d.selectedIcon),
                          label: Text(d.label),
                        ))
                    .toList(),
              ),
            ),
            // ── Contenido ──
            Expanded(child: shell),
          ],
        ),
      );
    }

    // ── Móvil: Bottom Nav ──
    return Scaffold(
      body: shell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border.withValues(alpha: 0.5))),
        ),
        child: NavigationBar(
          selectedIndex: shell.currentIndex,
          onDestinationSelected: _onTap,
          destinations: _destinations
              .map((d) => NavigationDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.selectedIcon),
                    label: d.label,
                  ))
              .toList(),
        ),
      ),
    );
  }
}

/// Mini logo para el NavigationRail.
class _LogoMini extends StatelessWidget {
  final bool extended;
  const _LogoMini({this.extended = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: AppColors.heroGradient,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.home_rounded, color: Colors.white, size: 20),
        ),
        if (extended) ...[
          const SizedBox(width: 12),
          const Text(
            'Hogentia',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ],
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  const _NavItem(this.icon, this.selectedIcon, this.label);
}
