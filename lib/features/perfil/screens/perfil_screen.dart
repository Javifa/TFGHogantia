import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/responsive.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../auth/facades/auth_facade.dart';
import '../../estancias/facades/estancias_facade.dart';
import '../../compras/facades/compras_facade.dart';

/// Pantalla de perfil del usuario (Dark Neon Theme).
class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final hp = Responsive.horizontalPadding(context);

    return Scaffold(
      body: SafeArea(
        child: Consumer<AuthFacade>(
          builder: (_, auth, __) {
            final u = auth.usuario;
            if (u == null) return const Center(child: Text('No autenticado'));

            return SingleChildScrollView(
              child: Responsive.constrained(
                context: context,
                child: Padding(
                  padding: EdgeInsets.all(hp),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      // ── Títulos ──
                      const Text(
                        'CUENTA',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Perfil',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Profile Card ──
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 56, height: 56,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                u.nombreVisible.isNotEmpty ? u.nombreVisible[0].toUpperCase() : 'U',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    u.nombreVisible,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    u.email,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'PRO',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Stats Row ──
                      Consumer2<EstanciasFacade, ComprasFacade>(
                        builder: (_, estancias, compras, __) {
                          return Row(
                            children: [
                              Expanded(
                                child: _StatBox(
                                  valor: '${estancias.total}',
                                  label: 'Estancias',
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: _StatBox(
                                  valor: '73', // Placeholder for total items
                                  label: 'Productos',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _StatBox(
                                  valor: Formatters.monedaCorto(compras.totalGastado),
                                  label: 'Este mes',
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      // ── Settings List ──
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          children: [
                            _SettingsTile(
                              icon: Icons.settings_outlined,
                              title: 'Configuración de cuenta',
                              subtitle: 'Nombre, email, contraseña',
                              onTap: () {},
                            ),
                            const Divider(indent: 64, endIndent: 16),
                            _SettingsTile(
                              icon: Icons.notifications_none_outlined,
                              title: 'Notificaciones',
                              subtitle: 'Alertas de stock, presupuestos',
                              onTap: () {},
                            ),
                            const Divider(indent: 64, endIndent: 16),
                            _SettingsTile(
                              icon: Icons.credit_card_outlined,
                              title: 'Facturación',
                              subtitle: 'Plan y método de pago',
                              onTap: () {},
                            ),
                            const Divider(indent: 64, endIndent: 16),
                            _SettingsTile(
                              icon: Icons.shield_outlined,
                              title: 'Privacidad',
                              subtitle: 'Datos y seguridad',
                              onTap: () {},
                            ),
                            const Divider(indent: 64, endIndent: 16),
                            _SettingsTile(
                              icon: Icons.help_outline_rounded,
                              title: 'Centro de ayuda',
                              subtitle: 'Preguntas frecuentes y soporte',
                              onTap: () {},
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // ── Sign Out Button ──
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final ok = await ConfirmDialog.mostrar(
                              context,
                              titulo: 'Cerrar sesión',
                              mensaje: '¿Seguro que quieres salir?',
                              textoConfirmar: 'Salir',
                            );
                            if (ok && context.mounted) {
                              await auth.cerrarSesion();
                              if (context.mounted) context.go('/login');
                            }
                          },
                          icon: const Icon(Icons.logout_rounded, size: 20, color: AppColors.error),
                          label: const Text('Cerrar sesión', style: TextStyle(color: AppColors.error, fontSize: 15, fontWeight: FontWeight.w600)),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: AppColors.error.withValues(alpha: 0.05),
                            side: BorderSide(color: AppColors.error.withValues(alpha: 0.2)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String valor;
  final String label;

  const _StatBox({required this.valor, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            valor,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: Icon(icon, color: AppColors.textSecondary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textHint, size: 24),
          ],
        ),
      ),
    );
  }
}
