import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import '../../../config/supabase_config.dart';
import '../../../core/data/datos_demo.dart';
import '../models/compra.dart';
import '../models/linea_compra.dart';
import '../services/compras_service.dart';

/// Facade de compras.
/// Punto de entrada único para la UI.
class ComprasFacade extends ChangeNotifier {
  final ComprasService _service;

  // ── Estado ──
  List<Compra> _compras = [];
  Compra? _compraActual;
  bool _cargando = false;
  String? _error;
  bool _modoDemo = false;

  // ── Getters ──
  List<Compra> get compras => _compras;
  Compra? get compraActual => _compraActual;
  bool get cargando => _cargando;
  String? get error => _error;
  int get total => _compras.length;

  /// Total de todas las compras cargadas.
  double get totalGastado =>
      _compras.fold(0.0, (sum, c) => sum + c.total);

  ComprasFacade({ComprasService? service})
      : _service = service ?? ComprasService();

  /// Activa el modo demo.
  void activarModoDemo() {
    _modoDemo = true;
    _compras = List.from(DatosDemo.compras);
    notifyListeners();
  }

  /// Carga todas las compras del usuario.
  Future<void> cargarCompras() async {
    if (_modoDemo) {
      _compras = List.from(DatosDemo.compras);
      notifyListeners();
      return;
    }

    final userId = SupabaseConfig.usuarioId;
    if (userId == null) return;

    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      _compras = await _service.obtenerTodas(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  /// Carga compras de un mes específico.
  Future<void> cargarComprasMes(int anio, int mes) async {
    if (_modoDemo) {
      _compras = DatosDemo.compras
          .where((Compra c) => c.fecha.year == anio && c.fecha.month == mes)
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
      _compras = await _service.obtenerPorMes(userId, anio, mes);
    } catch (e) {
      _error = e.toString();
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  /// Carga detalle de una compra.
  Future<void> cargarCompra(String id) async {
    if (_modoDemo) {
      _compraActual = _compras.firstWhere(
        (c) => c.id == id,
        orElse: () => _compras.first,
      );
      notifyListeners();
      return;
    }

    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      _compraActual = await _service.obtenerPorId(id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  /// Crea una nueva compra con sus líneas.
  Future<bool> crearCompra({
    String? tienda,
    required double total,
    required DateTime fecha,
    List<LineaCompra> lineas = const [],
    Uint8List? imagenTicket,
  }) async {
    if (_modoDemo) {
      final nueva = Compra(
        id: DatosDemo.generarId(),
        usuarioId: 'invitado',
        tienda: tienda,
        total: total,
        fecha: fecha,
        createdAt: DateTime.now(),
        lineas: lineas,
      );
      _compras.insert(0, nueva);
      notifyListeners();
      return true;
    }

    final userId = SupabaseConfig.usuarioId;
    if (userId == null) return false;

    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      String? imagenUrl;
      if (imagenTicket != null) {
        final nombre = 'ticket_${DateTime.now().millisecondsSinceEpoch}.jpg';
        imagenUrl = await _service.subirTicket(userId, nombre, imagenTicket);
      }

      final compra = Compra(
        id: '',
        usuarioId: userId,
        tienda: tienda,
        total: total,
        imagenTicketUrl: imagenUrl,
        fecha: fecha,
        createdAt: DateTime.now(),
      );

      final nueva = await _service.crear(compra, lineas);
      _compras.insert(0, nueva);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  /// Elimina una compra.
  Future<bool> eliminarCompra(String id) async {
    if (_modoDemo) {
      _compras.removeWhere((c) => c.id == id);
      if (_compraActual?.id == id) _compraActual = null;
      notifyListeners();
      return true;
    }

    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      await _service.eliminar(id);
      _compras.removeWhere((c) => c.id == id);
      if (_compraActual?.id == id) _compraActual = null;
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
