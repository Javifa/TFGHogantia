import 'package:flutter/foundation.dart';

import '../../../core/data/datos_demo.dart';
import '../../../config/supabase_config.dart';
import '../models/resumen_gastos.dart';
import '../services/gastos_service.dart';

/// Facade de gastos.
/// Punto de entrada único para la UI — resúmenes y analítica.
class GastosFacade extends ChangeNotifier {
  final GastosService _service;

  // ── Estado ──
  ResumenGastos? _resumenActual;
  Map<String, double> _historico = {};
  bool _cargando = false;
  String? _error;
  int _anioSeleccionado = DateTime.now().year;
  int _mesSeleccionado = DateTime.now().month;
  bool _modoDemo = false;

  // ── Getters ──
  ResumenGastos? get resumenActual => _resumenActual;
  Map<String, double> get historico => _historico;
  bool get cargando => _cargando;
  String? get error => _error;
  int get anioSeleccionado => _anioSeleccionado;
  int get mesSeleccionado => _mesSeleccionado;

  GastosFacade({GastosService? service})
      : _service = service ?? GastosService();

  /// Activa el modo demo.
  void activarModoDemo() {
    _modoDemo = true;
    _resumenActual = DatosDemo.resumenMesActual;
    _historico = DatosDemo.historico;
    notifyListeners();
  }

  /// Carga el resumen del mes actual.
  Future<void> cargarResumenMesActual() async {
    await cargarResumenMes(_anioSeleccionado, _mesSeleccionado);
  }

  /// Carga el resumen de un mes específico.
  Future<void> cargarResumenMes(int anio, int mes) async {
    _anioSeleccionado = anio;
    _mesSeleccionado = mes;

    if (_modoDemo) {
      _resumenActual = DatosDemo.resumenMesActual;
      notifyListeners();
      return;
    }

    final userId = SupabaseConfig.usuarioId;
    if (userId == null) return;

    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      _resumenActual = await _service.obtenerResumenMes(userId, anio, mes);
    } catch (e) {
      _error = e.toString();
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  /// Carga el histórico de gastos (últimos 6 meses).
  Future<void> cargarHistorico({int meses = 6}) async {
    if (_modoDemo) {
      _historico = DatosDemo.historico;
      notifyListeners();
      return;
    }

    final userId = SupabaseConfig.usuarioId;
    if (userId == null) return;

    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      _historico = await _service.obtenerHistorico(userId, meses: meses);
    } catch (e) {
      _error = e.toString();
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  /// Navega al mes anterior.
  Future<void> mesAnterior() async {
    if (_mesSeleccionado == 1) {
      _mesSeleccionado = 12;
      _anioSeleccionado--;
    } else {
      _mesSeleccionado--;
    }
    await cargarResumenMesActual();
  }

  /// Navega al mes siguiente.
  Future<void> mesSiguiente() async {
    final ahora = DateTime.now();
    if (_anioSeleccionado >= ahora.year && _mesSeleccionado >= ahora.month) {
      return;
    }
    if (_mesSeleccionado == 12) {
      _mesSeleccionado = 1;
      _anioSeleccionado++;
    } else {
      _mesSeleccionado++;
    }
    await cargarResumenMesActual();
  }

  /// Limpia error.
  void limpiarError() {
    _error = null;
    notifyListeners();
  }
}
