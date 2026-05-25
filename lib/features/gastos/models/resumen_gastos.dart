/// Modelo de resumen de gastos mensuales.
class ResumenGastos {
  final int anio;
  final int mes;
  final double totalMes;
  final int numCompras;
  final Map<String, double> gastosPorTienda;

  const ResumenGastos({
    required this.anio,
    required this.mes,
    this.totalMes = 0,
    this.numCompras = 0,
    this.gastosPorTienda = const {},
  });

  /// Media de gasto por compra.
  double get mediaPorCompra => numCompras > 0 ? totalMes / numCompras : 0;

  /// Nombre del mes legible. Ej: "Mayo 2026"
  String get mesTexto {
    const meses = [
      '',
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    return '${meses[mes]} $anio';
  }

  /// Tienda con mayor gasto.
  String? get tiendaPrincipal {
    if (gastosPorTienda.isEmpty) return null;
    return gastosPorTienda.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }
}
