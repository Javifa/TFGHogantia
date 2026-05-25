import 'package:flutter/material.dart';

/// Extension methods útiles para reducir boilerplate.

// ── Context Extensions ──
extension ContextExtensions on BuildContext {
  /// Acceso rápido al tema.
  ThemeData get tema => Theme.of(this);

  /// Acceso rápido al ColorScheme.
  ColorScheme get colores => Theme.of(this).colorScheme;

  /// Acceso rápido al TextTheme.
  TextTheme get textos => Theme.of(this).textTheme;

  /// Tamaño de pantalla.
  Size get tamanoPantalla => MediaQuery.sizeOf(this);

  /// Ancho de pantalla.
  double get anchoPantalla => MediaQuery.sizeOf(this).width;

  /// Alto de pantalla.
  double get altoPantalla => MediaQuery.sizeOf(this).height;

  /// Muestra un SnackBar con mensaje.
  void mostrarSnackBar(String mensaje, {bool esError = false}) {
    ScaffoldMessenger.of(this).clearSnackBars();
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: esError ? Theme.of(this).colorScheme.error : null,
      ),
    );
  }
}

// ── String Extensions ──
extension StringExtensions on String {
  /// Capitaliza la primera letra.
  String get capitalizado {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }

  /// Verifica si es un email válido.
  bool get esEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }
}

// ── DateTime Extensions ──
extension DateTimeExtensions on DateTime {
  /// Verifica si es hoy.
  bool get esHoy {
    final ahora = DateTime.now();
    return year == ahora.year && month == ahora.month && day == ahora.day;
  }

  /// Verifica si es este mes.
  bool get esEsteMes {
    final ahora = DateTime.now();
    return year == ahora.year && month == ahora.month;
  }
}
