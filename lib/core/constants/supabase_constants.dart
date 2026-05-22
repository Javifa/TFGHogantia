/// Nombres de tablas y buckets de Supabase.
/// Centralizado para evitar strings mágicos en el código.
class SupabaseConstants {
  SupabaseConstants._();

  // Tablas
  static const String tablaPerfiles = 'usuarios';
  static const String tablaEstancias = 'estancias';
  static const String tablaProductos = 'productos';
  static const String tablaCompras = 'compras';
  static const String tablaLineasCompra = 'lineas_compra';

  // Storage buckets
  static const String bucketAvatares = 'avatares';
  static const String bucketTickets = 'tickets';
}
