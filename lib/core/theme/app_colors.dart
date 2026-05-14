import 'package:flutter/material.dart';

/// Paleta de colores de Hogentia.
/// Identidad visual propia con gradientes cálidos y tonos profundos.
class AppColors {
  AppColors._();

  // ── Marca ──
  static const Color primary = Color(0xFF5B4CE0);
  static const Color primaryDark = Color(0xFF3D2DB7);
  static const Color primaryLight = Color(0xFFAEA4F3);

  static const Color accent = Color(0xFFFD6F5A);
  static const Color accentDark = Color(0xFFE04832);

  static const Color mint = Color(0xFF2ED8A3);
  static const Color mintDark = Color(0xFF17A87D);

  static const Color amber = Color(0xFFFFC145);

  // ── Superficies ──
  static const Color background = Color(0xFFF7F6FB);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF0EEF8);
  static const Color card = Colors.white;

  // ── Texto ──
  static const Color textPrimary = Color(0xFF1A1733);
  static const Color textSecondary = Color(0xFF6E6B8A);
  static const Color textHint = Color(0xFFABA8C3);

  // ── UI ──
  static const Color border = Color(0xFFE8E6F0);
  static const Color divider = Color(0xFFF0EEF6);
  static const Color shadow = Color(0x0A1A1733);

  // ── Semánticos ──
  static const Color success = Color(0xFF2ED8A3);
  static const Color warning = Color(0xFFFFC145);
  static const Color error = Color(0xFFFF5B5B);

  // ── Gradientes ──
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF7C6EF5), Color(0xFF5B4CE0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFFF8E71), Color(0xFFFD6F5A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFF50E3B5), Color(0xFF2ED8A3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF5B4CE0), Color(0xFF8E7CF7), Color(0xFFFD6F5A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
