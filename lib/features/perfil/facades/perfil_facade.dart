import 'package:flutter/foundation.dart';

import '../../auth/facades/auth_facade.dart';
import '../../auth/models/usuario.dart';

/// Facade de perfil de usuario.
/// Reutiliza AuthFacade para operaciones de perfil.
class PerfilFacade extends ChangeNotifier {
  final AuthFacade _authFacade;

  PerfilFacade({required AuthFacade authFacade}) : _authFacade = authFacade;

  // ── Getters delegados ──
  Usuario? get usuario => _authFacade.usuario;
  bool get cargando => _authFacade.cargando;
  String? get error => _authFacade.error;

  /// Actualiza el nombre del usuario.
  Future<bool> actualizarNombre(String nombre) async {
    return await _authFacade.actualizarPerfil(nombre: nombre);
  }

  /// Actualiza el avatar del usuario.
  Future<bool> actualizarAvatar(String avatarUrl) async {
    return await _authFacade.actualizarPerfil(avatarUrl: avatarUrl);
  }

  /// Cierra la sesión.
  Future<void> cerrarSesion() async {
    await _authFacade.cerrarSesion();
  }
}
