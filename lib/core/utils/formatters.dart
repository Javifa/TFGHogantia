import 'package:intl/intl.dart';

/// Formateadores de datos para la UI.
class Formatters {
  Formatters._();

  // ── Moneda ──

  static final _currencyFormat = NumberFormat.currency(
    locale: 'es_ES',
    symbol: '€',
    decimalDigits: 2,
  );

  /// Formatea un double como moneda. Ej: 12.5 → "12,50 €"
  static String moneda(double valor) => _currencyFormat.format(valor);

  /// Formatea un double como moneda corta. Ej: 1200 → "$1.2k"
  static String monedaCorto(double valor) {
    if (valor >= 1000) {
      return '\$${(valor / 1000).toStringAsFixed(1)}k';
    }
    return '\$${valor.toStringAsFixed(0)}';
  }

  // ── Fechas ──

  static final _fechaCorta = DateFormat('dd/MM/yyyy', 'es_ES');
  static final _fechaLarga = DateFormat("d 'de' MMMM 'de' yyyy", 'es_ES');
  static final _fechaHora = DateFormat('dd/MM/yyyy HH:mm', 'es_ES');
  static final _mesAnio = DateFormat('MMMM yyyy', 'es_ES');

  /// Fecha corta. Ej: "14/05/2026"
  static String fechaCorta(DateTime fecha) => _fechaCorta.format(fecha);

  /// Fecha larga. Ej: "14 de mayo de 2026"
  static String fechaLarga(DateTime fecha) => _fechaLarga.format(fecha);

  /// Fecha con hora. Ej: "14/05/2026 12:30"
  static String fechaHora(DateTime fecha) => _fechaHora.format(fecha);

  /// Mes y año. Ej: "mayo 2026"
  static String mesAnio(DateTime fecha) => _mesAnio.format(fecha);

  // ── Texto ──

  /// Capitaliza la primera letra. Ej: "cocina" → "Cocina"
  static String capitalizar(String texto) {
    if (texto.isEmpty) return texto;
    return texto[0].toUpperCase() + texto.substring(1).toLowerCase();
  }

  /// Trunca texto con elipsis. Ej: "Texto muy largo..." 
  static String truncar(String texto, int maxLength) {
    if (texto.length <= maxLength) return texto;
    return '${texto.substring(0, maxLength)}...';
  }
}
