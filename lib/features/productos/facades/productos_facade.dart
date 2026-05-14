import 'package:flutter/foundation.dart';

import '../../../config/supabase_config.dart';
import '../../../core/data/datos_demo.dart';
import '../models/producto.dart';
import '../services/productos_service.dart';

/// Facade de productos.
/// Punto de entrada único para la UI.
class ProductosFacade extends ChangeNotifier {
  final ProductosService _service;

  // ── Estado ──
  List<Producto> _productos = [];
  Producto? _productoActual;
  bool _cargando = false;
  String? _error;
  String? _estanciaIdActual;
  bool _modoDemo = false;

  // ── Getters ──
  List<Producto> get productos => _productos;
  Producto? get productoActual => _productoActual;
  bool get cargando => _cargando;
  String? get error => _error;
  int get total => _productos.length;
  String? get estanciaIdActual => _estanciaIdActual;

  /// Productos con bajo stock.
  List<Producto> get productosBajoStock =>
      _productos.where((p) => p.bajoStock).toList();

  /// Productos filtrados por categoría.
  List<Producto> productosPorCategoria(String categoria) =>
      _productos.where((p) => p.categoria == categoria).toList();

  ProductosFacade({ProductosService? service})
      : _service = service ?? ProductosService();

  /// Activa el modo demo.
  void activarModoDemo() {
    _modoDemo = true;
  }

  /// Carga productos de una estancia.
  Future<void> cargarProductos(String estanciaId) async {
    _estanciaIdActual = estanciaId;

    if (_modoDemo) {
      _productos = List.from(
        DatosDemo.productosPorEstancia[estanciaId] ?? [],
      );
      notifyListeners();
      return;
    }

    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      _productos = await _service.obtenerPorEstancia(estanciaId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  /// Carga todos los productos del usuario.
  Future<void> cargarTodos() async {
    if (_modoDemo) {
      _productos = DatosDemo.productosPorEstancia.values
          .expand((lista) => lista)
          .toList();
      notifyListeners();
      return;
    }

    final userId = SupabaseConfig.usuarioId;
    if (userId == null) return;

    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      _productos = await _service.obtenerTodos(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  /// Carga detalle de un producto.
  Future<void> cargarProducto(String id) async {
    if (_modoDemo) {
      for (final lista in DatosDemo.productosPorEstancia.values) {
        final encontrado = lista.where((Producto p) => p.id == id);
        if (encontrado.isNotEmpty) {
          _productoActual = encontrado.first;
          break;
        }
      }
      notifyListeners();
      return;
    }

    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      _productoActual = await _service.obtenerPorId(id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  /// Crea un nuevo producto.
  Future<bool> crearProducto({
    required String estanciaId,
    required String nombre,
    String? categoria,
    int cantidad = 0,
    int cantidadMinima = 0,
    String? unidad,
    String? notas,
  }) async {
    if (_modoDemo) {
      final nuevo = Producto(
        id: DatosDemo.generarId(),
        estanciaId: estanciaId,
        usuarioId: 'invitado',
        nombre: nombre,
        categoria: categoria,
        cantidad: cantidad,
        cantidadMinima: cantidadMinima,
        unidad: unidad,
        notas: notas,
        createdAt: DateTime.now(),
      );
      _productos.add(nuevo);
      notifyListeners();
      return true;
    }

    final userId = SupabaseConfig.usuarioId;
    if (userId == null) return false;

    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      final producto = Producto(
        id: '',
        estanciaId: estanciaId,
        usuarioId: userId,
        nombre: nombre,
        categoria: categoria,
        cantidad: cantidad,
        cantidadMinima: cantidadMinima,
        unidad: unidad,
        notas: notas,
        createdAt: DateTime.now(),
      );
      final nuevo = await _service.crear(producto);
      _productos.add(nuevo);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  /// Actualiza un producto.
  Future<bool> actualizarProducto(Producto producto) async {
    if (_modoDemo) {
      final index = _productos.indexWhere((p) => p.id == producto.id);
      if (index >= 0) _productos[index] = producto;
      if (_productoActual?.id == producto.id) _productoActual = producto;
      notifyListeners();
      return true;
    }

    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      final actualizado = await _service.actualizar(producto);
      final index = _productos.indexWhere((p) => p.id == producto.id);
      if (index >= 0) _productos[index] = actualizado;
      if (_productoActual?.id == producto.id) _productoActual = actualizado;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  /// Incrementa o decrementa la cantidad de un producto.
  Future<bool> cambiarCantidad(String id, int incremento) async {
    if (_modoDemo) {
      final index = _productos.indexWhere((p) => p.id == id);
      if (index >= 0) {
        final p = _productos[index];
        final nuevaCantidad = p.cantidad + incremento;
        if (nuevaCantidad < 0) return false;
        _productos[index] = p.copyWith(cantidad: nuevaCantidad);
        if (_productoActual?.id == id) {
          _productoActual = _productos[index];
        }
        notifyListeners();
      }
      return true;
    }

    try {
      final actualizado = await _service.incrementarCantidad(id, incremento);
      final index = _productos.indexWhere((p) => p.id == id);
      if (index >= 0) _productos[index] = actualizado;
      if (_productoActual?.id == id) _productoActual = actualizado;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Elimina un producto.
  Future<bool> eliminarProducto(String id) async {
    if (_modoDemo) {
      _productos.removeWhere((p) => p.id == id);
      if (_productoActual?.id == id) _productoActual = null;
      notifyListeners();
      return true;
    }

    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      await _service.eliminar(id);
      _productos.removeWhere((p) => p.id == id);
      if (_productoActual?.id == id) _productoActual = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  /// Limpia error.
  void limpiarError() {
    _error = null;
    notifyListeners();
  }
}
