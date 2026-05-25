import 'package:flutter/foundation.dart';

import '../../../config/supabase_config.dart';
import '../../../core/data/datos_demo.dart';
import '../models/estancia.dart';
import '../services/estancias_service.dart';

/// Facade de estancias.
/// Punto de entrada único para la UI.
class EstanciasFacade extends ChangeNotifier {
  final EstanciasService _service;

  // ── Estado ──
  List<Estancia> _estancias = [];
  Estancia? _estanciaActual;
  bool _cargando = false;
  String? _error;
  bool get _modoDemo => SupabaseConfig.modoInvitado;

  // ── Getters ──
  List<Estancia> get estancias => _estancias;
  Estancia? get estanciaActual => _estanciaActual;
  bool get cargando => _cargando;
  String? get error => _error;
  int get total => _estancias.length;

  EstanciasFacade({EstanciasService? service})
    : _service = service ?? EstanciasService();

  /// Activa el modo demo con datos de ejemplo.
  void activarModoDemo() {
    _estancias = List.from(DatosDemo.estancias);
    notifyListeners();
  }

  /// Carga todas las estancias del usuario actual.
  Future<void> cargarEstancias() async {
    if (_modoDemo) {
      _estancias = List.from(DatosDemo.estancias);
      notifyListeners();
      return;
    }

    final userId = SupabaseConfig.usuarioId;
    if (userId == null) return;

    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      _estancias = await _service.obtenerTodas(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  /// Carga el detalle de una estancia.
  Future<void> cargarEstancia(String id) async {
    if (_modoDemo) {
      _estanciaActual = _estancias.firstWhere(
        (e) => e.id == id,
        orElse: () => _estancias.first,
      );
      notifyListeners();
      return;
    }

    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      _estanciaActual = await _service.obtenerPorId(id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  /// Crea una nueva estancia.
  Future<bool> crearEstancia({
    required String nombre,
    String icono = '🏠',
    String? descripcion,
  }) async {
    if (_modoDemo) {
      final nueva = Estancia(
        id: DatosDemo.generarId(),
        usuarioId: 'invitado',
        nombre: nombre,
        icono: icono,
        descripcion: descripcion,
        orden: _estancias.length,
        createdAt: DateTime.now(),
      );
      _estancias.add(nueva);
      notifyListeners();
      return true;
    }

    final userId = SupabaseConfig.usuarioId;
    if (userId == null) return false;

    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      final estancia = Estancia(
        id: '',
        usuarioId: userId,
        nombre: nombre,
        icono: icono,
        descripcion: descripcion,
        orden: _estancias.length,
        createdAt: DateTime.now(),
      );
      final nueva = await _service.crear(estancia);
      _estancias.add(nueva);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  /// Actualiza una estancia existente.
  Future<bool> actualizarEstancia(Estancia estancia) async {
    if (_modoDemo) {
      final index = _estancias.indexWhere((e) => e.id == estancia.id);
      if (index >= 0) _estancias[index] = estancia;
      if (_estanciaActual?.id == estancia.id) _estanciaActual = estancia;
      notifyListeners();
      return true;
    }

    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      final actualizada = await _service.actualizar(estancia);
      final index = _estancias.indexWhere((e) => e.id == estancia.id);
      if (index >= 0) _estancias[index] = actualizada;
      if (_estanciaActual?.id == estancia.id) _estanciaActual = actualizada;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  /// Elimina una estancia.
  Future<bool> eliminarEstancia(String id) async {
    if (_modoDemo) {
      _estancias.removeWhere((e) => e.id == id);
      if (_estanciaActual?.id == id) _estanciaActual = null;
      notifyListeners();
      return true;
    }

    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      await _service.eliminar(id);
      _estancias.removeWhere((e) => e.id == id);
      if (_estanciaActual?.id == id) _estanciaActual = null;
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
