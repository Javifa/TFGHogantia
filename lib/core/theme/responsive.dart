import 'package:flutter/material.dart';

/// Utilidades de layout responsivo.
class Responsive {
  Responsive._();

  /// Breakpoints
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;

  /// Comprueba el tipo de dispositivo.
  static bool isMobile(BuildContext c) => MediaQuery.sizeOf(c).width < mobile;
  static bool isTablet(BuildContext c) {
    final w = MediaQuery.sizeOf(c).width;
    return w >= mobile && w < desktop;
  }

  static bool isDesktop(BuildContext c) =>
      MediaQuery.sizeOf(c).width >= desktop;

  /// Ancho máximo del contenido según el dispositivo.
  static double contentMaxWidth(BuildContext c) {
    if (isDesktop(c)) return 1100;
    if (isTablet(c)) return 720;
    return double.infinity;
  }

  /// Número de columnas para grids.
  static int gridColumns(BuildContext c) {
    if (isDesktop(c)) return 4;
    if (isTablet(c)) return 3;
    return 2;
  }

  /// Padding horizontal del contenido.
  static double horizontalPadding(BuildContext c) {
    if (isDesktop(c)) return 32;
    if (isTablet(c)) return 24;
    return 16;
  }

  /// Widget wrapper para centrar contenido con ancho máximo.
  static Widget constrained({
    required BuildContext context,
    required Widget child,
    double? maxWidth,
  }) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? contentMaxWidth(context),
        ),
        child: child,
      ),
    );
  }
}
