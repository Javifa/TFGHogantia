import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/supabase_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../models/estancia.dart';

/// Repositorio de estancias.
/// Solo acceso a datos contra Supabase.
class EstanciasRepository {
  SupabaseClient get _supabase => Supabase.instance.client;

  /// Obtiene todas las estancias del usuario.
  Future<List<Estancia>> obtenerTodas(String usuarioId) async {
    try {
      final response = await _supabase
          .from(SupabaseConstants.tablaEstancias)
          .select()
          .eq('usuario_id', usuarioId)
          .order('orden');

      return response.map((json) => Estancia.fromJson(json)).toList();
    } catch (e) {
      throw AppException.desdeSupabase(e);
    }
  }

  /// Obtiene una estancia por ID.
  Future<Estancia> obtenerPorId(String id) async {
    try {
      final response = await _supabase
          .from(SupabaseConstants.tablaEstancias)
          .select()
          .eq('id', id)
          .single();

      return Estancia.fromJson(response);
    } catch (e) {
      throw AppException.desdeSupabase(e);
    }
  }

  /// Crea una nueva estancia.
  Future<Estancia> crear(Estancia estancia) async {
    try {
      final response = await _supabase
          .from(SupabaseConstants.tablaEstancias)
          .insert(estancia.toJson())
          .select()
          .single();

      return Estancia.fromJson(response);
    } catch (e) {
      throw AppException.desdeSupabase(e);
    }
  }

  /// Actualiza una estancia existente.
  Future<Estancia> actualizar(Estancia estancia) async {
    try {
      final response = await _supabase
          .from(SupabaseConstants.tablaEstancias)
          .update(estancia.toJson())
          .eq('id', estancia.id)
          .select()
          .single();

      return Estancia.fromJson(response);
    } catch (e) {
      throw AppException.desdeSupabase(e);
    }
  }

  /// Elimina una estancia.
  Future<void> eliminar(String id) async {
    try {
      await _supabase
          .from(SupabaseConstants.tablaEstancias)
          .delete()
          .eq('id', id);
    } catch (e) {
      throw AppException.desdeSupabase(e);
    }
  }
}
