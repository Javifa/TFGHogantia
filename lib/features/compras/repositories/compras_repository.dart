import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/supabase_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../models/compra.dart';
import '../models/linea_compra.dart';

/// Repositorio de compras y tickets.
/// Solo acceso a datos contra Supabase.
class ComprasRepository {
  SupabaseClient get _supabase => Supabase.instance.client;

  /// Obtiene todas las compras del usuario con sus líneas.
  Future<List<Compra>> obtenerTodas(String usuarioId) async {
    try {
      final response = await _supabase
          .from(SupabaseConstants.tablaCompras)
          .select('*, lineas_compra(*)')
          .eq('usuario_id', usuarioId)
          .order('fecha', ascending: false);

      return response.map((json) => Compra.fromJson(json)).toList();
    } catch (e) {
      throw AppException.desdeSupabase(e);
    }
  }

  /// Obtiene compras de un mes específico.
  Future<List<Compra>> obtenerPorMes(
    String usuarioId,
    int anio,
    int mes,
  ) async {
    try {
      final inicio = DateTime(anio, mes, 1);
      final fin = DateTime(anio, mes + 1, 0); // Último día del mes

      final response = await _supabase
          .from(SupabaseConstants.tablaCompras)
          .select('*, lineas_compra(*)')
          .eq('usuario_id', usuarioId)
          .gte('fecha', inicio.toIso8601String().split('T').first)
          .lte('fecha', fin.toIso8601String().split('T').first)
          .order('fecha', ascending: false);

      return response.map((json) => Compra.fromJson(json)).toList();
    } catch (e) {
      throw AppException.desdeSupabase(e);
    }
  }

  /// Obtiene una compra por ID con sus líneas.
  Future<Compra> obtenerPorId(String id) async {
    try {
      final response = await _supabase
          .from(SupabaseConstants.tablaCompras)
          .select('*, lineas_compra(*)')
          .eq('id', id)
          .single();

      return Compra.fromJson(response);
    } catch (e) {
      throw AppException.desdeSupabase(e);
    }
  }

  /// Crea una nueva compra.
  Future<Compra> crear(Compra compra) async {
    try {
      final response = await _supabase
          .from(SupabaseConstants.tablaCompras)
          .insert(compra.toJson())
          .select()
          .single();

      return Compra.fromJson(response);
    } catch (e) {
      throw AppException.desdeSupabase(e);
    }
  }

  /// Añade líneas a una compra.
  Future<List<LineaCompra>> agregarLineas(List<LineaCompra> lineas) async {
    try {
      final data = lineas.map((l) => l.toJson()).toList();
      final response = await _supabase
          .from(SupabaseConstants.tablaLineasCompra)
          .insert(data)
          .select();

      return response.map((json) => LineaCompra.fromJson(json)).toList();
    } catch (e) {
      throw AppException.desdeSupabase(e);
    }
  }

  /// Actualiza una compra.
  Future<Compra> actualizar(Compra compra) async {
    try {
      final response = await _supabase
          .from(SupabaseConstants.tablaCompras)
          .update(compra.toJson())
          .eq('id', compra.id)
          .select()
          .single();

      return Compra.fromJson(response);
    } catch (e) {
      throw AppException.desdeSupabase(e);
    }
  }

  /// Elimina una compra y sus líneas (cascade en DB).
  Future<void> eliminar(String id) async {
    try {
      await _supabase
          .from(SupabaseConstants.tablaCompras)
          .delete()
          .eq('id', id);
    } catch (e) {
      throw AppException.desdeSupabase(e);
    }
  }

  /// Sube imagen de ticket a Supabase Storage.
  Future<String> subirImagenTicket(
    String usuarioId,
    String nombreArchivo,
    List<int> bytes,
  ) async {
    try {
      final path = '$usuarioId/$nombreArchivo';
      await _supabase.storage
          .from(SupabaseConstants.bucketTickets)
          .uploadBinary(path, bytes as dynamic);

      return _supabase.storage
          .from(SupabaseConstants.bucketTickets)
          .getPublicUrl(path);
    } catch (e) {
      throw AppException.desdeSupabase(e);
    }
  }
}
