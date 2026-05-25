import '../models/resumen_gastos.dart';
import '../repositories/gastos_repository.dart';

/// Servicio de gastos.
/// Lógica de negocio — cálculos y transformaciones de datos analíticos.
class GastosService {
  final GastosRepository _repository;

  GastosService({GastosRepository? repository})
    : _repository = repository ?? GastosRepository();

  /// Genera el resumen de gastos de un mes.
  Future<ResumenGastos> obtenerResumenMes(
    String usuarioId,
    int anio,
    int mes,
  ) async {
    final total = await _repository.obtenerTotalMes(usuarioId, anio, mes);
    final gastosPorTienda = await _repository.obtenerGastosPorTienda(
      usuarioId,
      anio,
      mes,
    );

    return ResumenGastos(
      anio: anio,
      mes: mes,
      totalMes: total,
      numCompras: gastosPorTienda.length,
      gastosPorTienda: gastosPorTienda,
    );
  }

  /// Obtiene el histórico de totales mensuales.
  Future<Map<String, double>> obtenerHistorico(
    String usuarioId, {
    int meses = 6,
  }) async {
    return await _repository.obtenerTotalesMensuales(usuarioId, meses: meses);
  }
}
