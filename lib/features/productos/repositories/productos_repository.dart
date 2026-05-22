import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/supabase_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../models/producto.dart';

/// Repositorio de productos.
/// Solo acceso a datos contra Supabase.
class ProductosRepository {
  SupabaseClient get _supabase => Supabase.instance.client;

  /// Obtiene productos de una estancia.
  Future<List<Producto>> obtenerPorEstancia(String estanciaId) async {
    try {
      final response = await _supabase
          .from(SupabaseConstants.tablaProductos)
          .select()
          .eq('estancia_id', estanciaId)
          .eq('activo', true)
          .order('nombre');

      return response.map((json) => Producto.fromJson(json)).toList();
    } catch (e) {
      throw AppException.desdeSupabase(e);
    }
  }

  /// Obtiene todos los productos del usuario.
  Future<List<Producto>> obtenerTodos(String usuarioId) async {
    try {
      final response = await _supabase
          .from(SupabaseConstants.tablaProductos)
          .select()
          .eq('usuario_id', usuarioId)
          .eq('activo', true)
          .order('nombre');

      return response.map((json) => Producto.fromJson(json)).toList();
    } catch (e) {
      throw AppException.desdeSupabase(e);
    }
  }

  /// Obtiene un producto por ID.
  Future<Producto> obtenerPorId(String id) async {
    try {
      final response = await _supabase
          .from(SupabaseConstants.tablaProductos)
          .select()
          .eq('id', id)
          .single();

      return Producto.fromJson(response);
    } catch (e) {
      throw AppException.desdeSupabase(e);
    }
  }

  /// Crea un nuevo producto.
  Future<Producto> crear(Producto producto) async {
    try {
      final response = await _supabase
          .from(SupabaseConstants.tablaProductos)
          .insert(producto.toJson())
          .select()
          .single();

      return Producto.fromJson(response);
    } catch (e) {
      throw AppException.desdeSupabase(e);
    }
  }

  /// Actualiza un producto existente.
  Future<Producto> actualizar(Producto producto) async {
    try {
      final data = producto.toJson();
      data['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .from(SupabaseConstants.tablaProductos)
          .update(data)
          .eq('id', producto.id)
          .select()
          .single();

      return Producto.fromJson(response);
    } catch (e) {
      throw AppException.desdeSupabase(e);
    }
  }

  /// Elimina un producto (soft delete: activo = false).
  Future<void> eliminar(String id) async {
    try {
      await _supabase
          .from(SupabaseConstants.tablaProductos)
          .update({'activo': false, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', id);
    } catch (e) {
      throw AppException.desdeSupabase(e);
    }
  }

  /// Actualiza la cantidad de un producto.
  Future<Producto> actualizarCantidad(String id, int nuevaCantidad) async {
    try {
      final response = await _supabase
          .from(SupabaseConstants.tablaProductos)
          .update({
            'cantidad': nuevaCantidad,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .select()
          .single();

      return Producto.fromJson(response);
    } catch (e) {
      throw AppException.desdeSupabase(e);
    }
  }

  /// Sube un ticket/factura a Supabase Storage y retorna la URL pública.
  Future<String> subirTicket(String usuarioId, String nombreArchivo, List<int> bytes) async {
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
