import '../../../core/errors/app_exception.dart';
import '../models/producto.dart';
import '../repositories/productos_repository.dart';

/// Servicio de productos.
/// Lógica de negocio — validaciones, filtros y reglas.
class ProductosService {
  final ProductosRepository _repository;

  ProductosService({ProductosRepository? repository})
      : _repository = repository ?? ProductosRepository();

  /// Obtiene productos de una estancia.
  Future<List<Producto>> obtenerPorEstancia(String estanciaId) async {
    return await _repository.obtenerPorEstancia(estanciaId);
  }

  /// Obtiene todos los productos del usuario.
  Future<List<Producto>> obtenerTodos(String usuarioId) async {
    return await _repository.obtenerTodos(usuarioId);
  }

  /// Obtiene un producto por ID.
  Future<Producto> obtenerPorId(String id) async {
    return await _repository.obtenerPorId(id);
  }

  /// Crea un producto con validación.
  Future<Producto> crear(Producto producto) async {
    _validar(producto);
    return await _repository.crear(producto);
  }

  /// Actualiza un producto con validación.
  Future<Producto> actualizar(Producto producto) async {
    _validar(producto);
    return await _repository.actualizar(producto);
  }

  /// Elimina un producto (soft delete).
  Future<void> eliminar(String id) async {
    await _repository.eliminar(id);
  }

  /// Incrementa la cantidad de un producto.
  Future<Producto> incrementarCantidad(String id, int incremento) async {
    final producto = await _repository.obtenerPorId(id);
    final nuevaCantidad = producto.cantidad + incremento;
    if (nuevaCantidad < 0) {
      throw const AppException('La cantidad no puede ser negativa');
    }
    return await _repository.actualizarCantidad(id, nuevaCantidad);
  }

  /// Obtiene productos con bajo stock de una estancia.
  Future<List<Producto>> obtenerBajoStock(String estanciaId) async {
    final productos = await _repository.obtenerPorEstancia(estanciaId);
    return productos.where((p) => p.bajoStock).toList();
  }

  /// Validaciones de negocio.
  void _validar(Producto producto) {
    if (producto.nombre.trim().isEmpty) {
      throw const AppException('El nombre del producto es obligatorio');
    }
    if (producto.nombre.length > 100) {
      throw const AppException('El nombre no puede exceder 100 caracteres');
    }
    if (producto.cantidad < 0) {
      throw const AppException('La cantidad no puede ser negativa');
    }
    if (producto.cantidadMinima < 0) {
      throw const AppException('La cantidad mínima no puede ser negativa');
    }
  }
}
