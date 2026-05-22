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
  bool get _modoDemo => SupabaseConfig.modoInvitado;

  // ── Getters ──
  List<Compra> get compras => _compras;
  Compra? get compraActual => _compraActual;
  bool get cargando => _cargando;
  String? get error => _error;
  int get total => _compras.length;

  /// Total de todas las compras cargadas.
  double get totalGastado =>
      _compras.fold(0.0, (sum, c) => sum + c.total);

  double _totalGastadoEsteMes = 0.0;
  double get totalGastadoEsteMes => _totalGastadoEsteMes;

  double _limiteGastos = 500.0;
  double get limiteGastos => _limiteGastos;
  
  void establecerLimite(double limite) {
    _limiteGastos = limite;
    notifyListeners();
  }

  ComprasFacade({ComprasService? service})
      : _service = service ?? ComprasService();

  /// Activa el modo demo.
  void activarModoDemo() {
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

  /// Carga y calcula el total gastado en el mes actual.
  Future<void> cargarTotalMesActual() async {
    final now = DateTime.now();
    if (_modoDemo) {
      _totalGastadoEsteMes = DatosDemo.compras
          .where((c) => c.fecha.year == now.year && c.fecha.month == now.month)
          .fold(0.0, (sum, c) => sum + c.total);
      notifyListeners();
      return;
    }

    final userId = SupabaseConfig.usuarioId;
    if (userId == null) return;

    try {
      final comprasMes = await _service.obtenerPorMes(userId, now.year, now.month);
      _totalGastadoEsteMes = comprasMes.fold(0.0, (sum, c) => sum + c.total);
    } catch (e) {
      _error = e.toString();
    } finally {
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
    String? concepto,
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
        concepto: concepto,
        total: total,
        fecha: fecha,
        createdAt: DateTime.now(),
        lineas: lineas,
      );
      _compras.insert(0, nueva);
      final now = DateTime.now();
      if (nueva.fecha.year == now.year && nueva.fecha.month == now.month) {
        _totalGastadoEsteMes += nueva.total;
      }
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
        concepto: concepto,
        total: total,
        imagenTicketUrl: imagenUrl,
        fecha: fecha,
        createdAt: DateTime.now(),
      );

      final nueva = await _service.crear(compra, lineas);
      _compras.insert(0, nueva);
      final now = DateTime.now();
      if (nueva.fecha.year == now.year && nueva.fecha.month == now.month) {
        _totalGastadoEsteMes += nueva.total;
      }
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  /// Actualiza una compra existente.
  Future<bool> actualizarCompra(
    Compra compraOriginal, {
    String? tienda,
    String? concepto,
    required double total,
    required DateTime fecha,
    Uint8List? nuevaImagenTicket,
  }) async {
    if (_modoDemo) {
      final index = _compras.indexWhere((c) => c.id == compraOriginal.id);
      if (index >= 0) {
        _compras[index] = compraOriginal.copyWith(
          tienda: tienda,
          concepto: concepto,
          total: total,
          fecha: fecha,
        );
        if (_compraActual?.id == compraOriginal.id) {
          _compraActual = _compras[index];
        }
      }
      notifyListeners();
      return true;
    }

    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      final actualizada = await _service.actualizar(
        compraOriginal.copyWith(tienda: tienda, concepto: concepto, total: total, fecha: fecha),
        nuevaImagenTicket: nuevaImagenTicket,
      );

      final index = _compras.indexWhere((c) => c.id == compraOriginal.id);
      if (index >= 0) {
        _compras[index] = actualizada;
      }
      if (_compraActual?.id == compraOriginal.id) {
        _compraActual = actualizada;
      }
      // Actualizar el total del mes actual re-calculando
      cargarTotalMesActual();
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
      // Actualizar el total del mes actual re-calculando
      cargarTotalMesActual();
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
