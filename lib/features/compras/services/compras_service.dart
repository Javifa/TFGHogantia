import 'dart:typed_data';

import '../../../core/errors/app_exception.dart';
import '../models/compra.dart';
import '../models/linea_compra.dart';
import '../repositories/compras_repository.dart';

/// Servicio de compras.
/// Lógica de negocio — validaciones y orquestación.
class ComprasService {
  final ComprasRepository _repository;

  ComprasService({ComprasRepository? repository})
      : _repository = repository ?? ComprasRepository();

  /// Obtiene todas las compras del usuario.
  Future<List<Compra>> obtenerTodas(String usuarioId) async {
    return await _repository.obtenerTodas(usuarioId);
  }

  /// Obtiene compras de un mes.
  Future<List<Compra>> obtenerPorMes(String usuarioId, int anio, int mes) async {
    return await _repository.obtenerPorMes(usuarioId, anio, mes);
  }

  /// Obtiene una compra por ID.
  Future<Compra> obtenerPorId(String id) async {
    return await _repository.obtenerPorId(id);
  }

  /// Crea una compra completa con sus líneas.
  Future<Compra> crear(Compra compra, List<LineaCompra> lineas) async {
    _validar(compra, lineas);

    // 1. Crear la compra
    final compraCreada = await _repository.crear(compra);

    // 2. Crear las líneas con el ID de la compra
    if (lineas.isNotEmpty) {
      final lineasConId = lineas
          .map((l) => LineaCompra(
                id: l.id,
                compraId: compraCreada.id,
                productoId: l.productoId,
                nombreItem: l.nombreItem,
                cantidad: l.cantidad,
                precioUnitario: l.precioUnitario,
                subtotal: l.subtotal,
              ))
          .toList();
      await _repository.agregarLineas(lineasConId);
    }

    // 3. Retornar compra completa
    return await _repository.obtenerPorId(compraCreada.id);
  }

  /// Actualiza una compra y opcionalmente su ticket.
  Future<Compra> actualizar(Compra compra, {Uint8List? nuevaImagenTicket}) async {
    String? nuevaUrl = compra.imagenTicketUrl;
    
    if (nuevaImagenTicket != null) {
      final nombre = 'ticket_${DateTime.now().millisecondsSinceEpoch}.jpg';
      nuevaUrl = await subirTicket(compra.usuarioId, nombre, nuevaImagenTicket);
    }

    final compraAActualizar = compra.copyWith(imagenTicketUrl: nuevaUrl);
    return await _repository.actualizar(compraAActualizar);
  }

  /// Elimina una compra.
  Future<void> eliminar(String id) async {
    await _repository.eliminar(id);
  }

  /// Sube una imagen de ticket.
  Future<String> subirTicket(String usuarioId, String nombre, Uint8List bytes) async {
    return await _repository.subirImagenTicket(usuarioId, nombre, bytes);
  }

  /// Validaciones de negocio.
  void _validar(Compra compra, List<LineaCompra> lineas) {
    if (lineas.isEmpty && compra.total <= 0) {
      throw const AppException(
        'Debe haber al menos un artículo o un total mayor a 0',
      );
    }
    for (final linea in lineas) {
      if (linea.nombreItem.trim().isEmpty) {
        throw const AppException('Cada artículo debe tener un nombre');
      }
      if (linea.precioUnitario < 0) {
        throw const AppException('El precio no puede ser negativo');
      }
    }
  }
}
