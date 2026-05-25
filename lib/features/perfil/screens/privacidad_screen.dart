import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/responsive.dart';

class PrivacidadScreen extends StatelessWidget {
  const PrivacidadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final hp = Responsive.horizontalPadding(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Privacidad y Seguridad')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(hp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Icon(
              Icons.shield_rounded,
              size: 64,
              color: AppColors.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Tu privacidad es lo primero',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'En Hogentia nos tomamos muy en serio la seguridad de los datos de tu hogar. '
              'Por ello, hemos implementado las medidas más estrictas de la industria para asegurar que '
              'solo tú y las personas que autorices puedan acceder a la información de tus estancias, compras y productos.',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            _Seccion(
              icono: Icons.lock_outline,
              titulo: 'Cifrado en reposo',
              texto:
                  'Todos los datos almacenados en nuestros servidores están cifrados mediante AES-256. Tus fotografías (tickets y avatares) se almacenan de forma segura.',
            ),
            const SizedBox(height: 24),
            _Seccion(
              icono: Icons.policy_outlined,
              titulo: 'Row Level Security (RLS)',
              texto:
                  'Utilizamos políticas a nivel de fila en la base de datos PostgreSQL, garantizando criptográficamente que es imposible que otros usuarios accedan a tus registros.',
            ),
            const SizedBox(height: 24),
            _Seccion(
              icono: Icons.delete_sweep_outlined,
              titulo: 'Derecho al olvido',
              texto:
                  'Al borrar tu cuenta, todos tus datos, compras y estancias se eliminan de forma permanente e irrecuperable de nuestros sistemas en un plazo máximo de 24 horas.',
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _Seccion extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String texto;

  const _Seccion({
    required this.icono,
    required this.titulo,
    required this.texto,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icono, color: AppColors.primary, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                texto,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
