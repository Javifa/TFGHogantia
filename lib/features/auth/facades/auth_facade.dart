import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../config/supabase_config.dart';
import '../models/usuario.dart';
import '../services/auth_service.dart';

/// Facade de autenticación.
/// Punto de entrada único para la UI — gestiona estado + orquesta servicios.
class AuthFacade extends ChangeNotifier {
  final AuthService _authService;

  // ── Estado ──
  Usuario? _usuario;
  bool _cargando = false;
  String? _error;
  bool _inicializado = false;
  bool _modoInvitado = false;

  // ── Getters ──
  Usuario? get usuario => _usuario;
  bool get cargando => _cargando;
  String? get error => _error;
  bool get estaAutenticado => _usuario != null;
  bool get inicializado => _inicializado;
  bool get modoInvitado => _modoInvitado;
  String? get usuarioId =>
      _modoInvitado ? 'invitado' : _authService.usuarioActual?.id;

  AuthFacade({AuthService? authService})
      : _authService = authService ?? AuthService() {
    _inicializarAuth();
  }

  void _inicializarAuth() {
    if (!SupabaseConfig.inicializado) {
      // Supabase no configurado — modo invitado disponible
      _inicializado = true;
      return;
    }
    try {
      _escucharCambiosAuth();
    } catch (_) {
      _inicializado = true;
    }
  }

  /// Escucha cambios de estado de autenticación.
  void _escucharCambiosAuth() {
    _authService.onAuthStateChange.listen((AuthState state) async {
      if (state.event == AuthChangeEvent.signedIn ||
          state.event == AuthChangeEvent.tokenRefreshed) {
        await _cargarPerfil();
      } else if (state.event == AuthChangeEvent.signedOut) {
        _usuario = null;
        notifyListeners();
      }
      _inicializado = true;
      notifyListeners();
    });
  }

  /// Carga el perfil del usuario actual.
  Future<void> _cargarPerfil() async {
    final user = _authService.usuarioActual;
    if (user == null) return;

    try {
      _usuario = await _authService.obtenerPerfil(user.id);
    } catch (e) {
      // Si no hay perfil en la tabla, crear uno temporal
      _usuario = Usuario(
        id: user.id,
        email: user.email ?? '',
        nombre: user.userMetadata?['nombre'],
        createdAt: DateTime.now(),
      );
    }
  }

  /// Entra como invitado con datos de demo.
  void entrarComoInvitado() {
    _modoInvitado = true;
    SupabaseConfig.modoInvitado = true; // Flag estático para GoRouter
    _usuario = Usuario(
      id: 'invitado',
      email: 'invitado@hogentia.app',
      nombre: 'Invitado',
      createdAt: DateTime.now(),
    );
    _inicializado = true;
    notifyListeners();
  }

  /// Inicia sesión.
  Future<bool> iniciarSesion({
    required String email,
    required String contrasena,
  }) async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.iniciarSesion(
        email: email,
        contrasena: contrasena,
      );
      await _cargarPerfil();
      _modoInvitado = false;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  /// Registra un nuevo usuario.
  Future<bool> registrar({
    required String email,
    required String contrasena,
    String? nombre,
  }) async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.registrar(
        email: email,
        contrasena: contrasena,
        nombre: nombre,
      );
      await _cargarPerfil();
      _modoInvitado = false;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  /// Cierra la sesión.
  Future<void> cerrarSesion() async {
    _cargando = true;
    notifyListeners();

    try {
      if (!_modoInvitado) {
        await _authService.cerrarSesion();
      }
      _usuario = null;
      _modoInvitado = false;
      SupabaseConfig.modoInvitado = false;
    } catch (e) {
      _error = e.toString();
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  /// Actualiza el perfil del usuario.
  Future<bool> actualizarPerfil({
    String? nombre,
    String? avatarUrl,
  }) async {
    if (_usuario == null) return false;

    // En modo invitado, actualizar solo localmente
    if (_modoInvitado) {
      _usuario = _usuario!.copyWith(nombre: nombre, avatarUrl: avatarUrl);
      notifyListeners();
      return true;
    }

    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      _usuario = await _authService.actualizarPerfil(
        _usuario!.copyWith(nombre: nombre, avatarUrl: avatarUrl),
      );
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  /// Limpia el error actual.
  void limpiarError() {
    _error = null;
    notifyListeners();
  }
}
