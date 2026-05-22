import 'package:flutter/material.dart';

/// Paleta de colores de Hogentia.
/// Estilo minimalista monocromático (Black & White).
class AppColors {
  AppColors._();

  // ── Marca ──
  static const Color primary = Color(0xFF000000);
  static const Color primaryDark = Color(0xFF000000);
  static const Color primaryLight = Color(0xFF333333);

  static const Color accent = Color(0xFF000000);
  static const Color accentDark = Color(0xFF000000);

  static const Color mint = Color(0xFF000000);
  static const Color mintDark = Color(0xFF000000);

  static const Color amber = Color(0xFF000000);

  // ── Superficies ──
  static const Color background = Color(0xFFF9F9F9);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF0F0F0);
  static const Color card = Colors.white;

  // ── Texto ──
  static const Color textPrimary = Color(0xFF111111);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textHint = Color(0xFFAAAAAA);

  // ── UI ──
  static const Color border = Color(0xFFE5E5E5);
  static const Color divider = Color(0xFFEEEEEE);
  static const Color shadow = Color(0x0A000000);

  // ── Semánticos (Los mantenemos para que los errores sigan siendo rojos) ──
  static const Color success = Color(0xFF000000);
  static const Color warning = Color(0xFF666666);
  static const Color error = Color(0xFFD32F2F);

  // ── Gradientes (Convertidos a monocromático elegante) ──
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF333333), Color(0xFF000000)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF333333), Color(0xFF000000)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFF333333), Color(0xFF000000)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF222222), Color(0xFF000000)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
