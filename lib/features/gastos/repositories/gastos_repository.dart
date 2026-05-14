import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/supabase_constants.dart';
import '../../../core/errors/app_exception.dart';

/// Repositorio de gastos.
/// Consultas analíticas sobre compras para generar resúmenes.
class GastosRepository {
  SupabaseClient get _supabase => Supabase.instance.client;

  /// Obtiene el total de gastos de un mes.
  Future<double> obtenerTotalMes(String usuarioId, int anio, int mes) async {
    try {
      final inicio = DateTime(anio, mes, 1);
      final fin = DateTime(anio, mes + 1, 0);

      final response = await _supabase
          .from(SupabaseConstants.tablaCompras)
          .select('total')
          .eq('usuario_id', usuarioId)
          .gte('fecha', inicio.toIso8601String().split('T').first)
          .lte('fecha', fin.toIso8601String().split('T').first);

      double total = 0;
      for (final row in response) {
        total += (row['total'] as num?)?.toDouble() ?? 0;
      }
      return total;
    } catch (e) {
      throw AppException.desdeSupabase(e);
    }
  }

  /// Obtiene los totales mensuales de los últimos N meses.
  Future<Map<String, double>> obtenerTotalesMensuales(
    String usuarioId, {
    int meses = 6,
  }) async {
    try {
      final ahora = DateTime.now();
      final resultados = <String, double>{};

      for (int i = 0; i < meses; i++) {
        final fecha = DateTime(ahora.year, ahora.month - i, 1);
        final clave = '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}';
        resultados[clave] = await obtenerTotalMes(
          usuarioId,
          fecha.year,
          fecha.month,
        );
      }

      return resultados;
    } catch (e) {
      throw AppException.desdeSupabase(e);
    }
  }

  /// Obtiene compras agrupadas por tienda en un mes.
  Future<Map<String, double>> obtenerGastosPorTienda(
    String usuarioId,
    int anio,
    int mes,
  ) async {
    try {
      final inicio = DateTime(anio, mes, 1);
      final fin = DateTime(anio, mes + 1, 0);

      final response = await _supabase
          .from(SupabaseConstants.tablaCompras)
          .select('tienda, total')
          .eq('usuario_id', usuarioId)
          .gte('fecha', inicio.toIso8601String().split('T').first)
          .lte('fecha', fin.toIso8601String().split('T').first);

      final gastos = <String, double>{};
      for (final row in response) {
        final tienda = (row['tienda'] as String?) ?? 'Sin tienda';
        final total = (row['total'] as num?)?.toDouble() ?? 0;
        gastos[tienda] = (gastos[tienda] ?? 0) + total;
      }
      return gastos;
    } catch (e) {
      throw AppException.desdeSupabase(e);
    }
  }
}
