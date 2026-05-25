import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/models/usuario.dart';

/// Header del perfil con avatar diseño premium.
class PerfilHeader extends StatelessWidget {
  final Usuario usuario;
  const PerfilHeader({super.key, required this.usuario});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Avatar con borde gradient
        Container(
          padding: const EdgeInsets.all(3),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.heroGradient,
          ),
          child: CircleAvatar(
            radius: 44,
            backgroundColor: AppColors.surface,
            backgroundImage: usuario.avatarUrl != null
                ? NetworkImage(usuario.avatarUrl!)
                : null,
            child: usuario.avatarUrl == null
                ? Text(
                    usuario.nombreVisible[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  )
                : null,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          usuario.nombreVisible,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          usuario.email,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
      ],
    );
  }
}
