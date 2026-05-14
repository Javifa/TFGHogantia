/// Constantes globales de la aplicación Hogentia.
class AppConstants {
  AppConstants._();

  // App info
  static const String appName = 'Hogentia';
  static const String appVersion = '1.0.0';

  // Paginación
  static const int itemsPorPagina = 20;

  // Límites
  static const int maxNombreLength = 100;
  static const int maxDescripcionLength = 500;
  static const int maxNotasLength = 1000;

  // Duración de animaciones (ms)
  static const int animacionCorta = 200;
  static const int animacionMedia = 350;
  static const int animacionLarga = 500;

  // Categorías de productos predeterminadas
  static const List<String> categoriasProducto = [
    'Alimentación',
    'Limpieza',
    'Higiene',
    'Electrónica',
    'Decoración',
    'Herramientas',
    'Ropa',
    'Otros',
  ];

  // Unidades de medida
  static const List<String> unidadesMedida = [
    'unidades',
    'kg',
    'g',
    'litros',
    'ml',
    'paquetes',
    'cajas',
    'bolsas',
  ];

  // Iconos de estancias predeterminados
  static const List<String> iconosEstancia = [
    '🏠', // General
    '🍳', // Cocina
    '🛁', // Baño
    '🛏️', // Dormitorio
    '🛋️', // Salón
    '👕', // Lavandería
    '🏗️', // Garaje
    '🌿', // Jardín / Terraza
    '📚', // Despacho
    '🧒', // Habitación niños
  ];
}
