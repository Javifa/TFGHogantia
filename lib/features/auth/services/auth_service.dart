import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/app_exception.dart';
import '../models/usuario.dart';
import '../repositories/auth_repository.dart';

/// Servicio de autenticación.
/// Lógica de negocio — validaciones y orquestación.
class AuthService {
  final AuthRepository _repository;

  AuthService({AuthRepository? repository})
      : _repository = repository ?? AuthRepository();

  /// Inicia sesión validando los campos.
  Future<AuthResponse> iniciarSesion({
    required String email,
    required String contrasena,
  }) async {
    // Validaciones de negocio
    if (email.trim().isEmpty) {
      throw const AppException('El email es obligatorio');
    }
    if (contrasena.isEmpty) {
      throw const AppException('La contraseña es obligatoria');
    }

    return await _repository.iniciarSesion(
      email: email.trim().toLowerCase(),
      contrasena: contrasena,
    );
  }

  /// Registra un nuevo usuario validando los campos.
  Future<AuthResponse> registrar({
    required String email,
    required String contrasena,
    String? nombre,
  }) async {
    if (email.trim().isEmpty) {
      throw const AppException('El email es obligatorio');
    }
    if (contrasena.length < 6) {
      throw const AppException('La contraseña debe tener al menos 6 caracteres');
    }

    return await _repository.registrar(
      email: email.trim().toLowerCase(),
      contrasena: contrasena,
      nombre: nombre?.trim(),
    );
  }

  /// Cierra la sesión.
  Future<void> cerrarSesion() async {
    await _repository.cerrarSesion();
  }

  /// Recupera la contraseña.
  Future<void> recuperarContrasena(String email) async {
    if (email.trim().isEmpty) {
      throw const AppException('El email es obligatorio');
    }
    await _repository.recuperarContrasena(email.trim().toLowerCase());
  }

  /// Verifica el código OTP de recuperación.
  Future<void> verificarCodigoRecuperacion(String email, String token) async {
    if (token.trim().isEmpty || token.length < 5) {
      throw const AppException('El código debe tener al menos 5 dígitos');
    }
    await _repository.verificarCodigoRecuperacion(email.trim().toLowerCase(), token.trim());
  }

  /// Actualiza la contraseña.
  Future<void> actualizarContrasena(String nuevaContrasena) async {
    if (nuevaContrasena.length < 6) {
      throw const AppException('La contraseña debe tener al menos 6 caracteres');
    }
    await _repository.actualizarContrasena(nuevaContrasena);
  }

  /// Borra la cuenta actual.
  Future<void> borrarCuenta() async {
    await _repository.borrarCuenta();
  }

  /// Obtiene el perfil del usuario.
  Future<Usuario?> obtenerPerfil(String userId) async {
    return await _repository.obtenerPerfil(userId);
  }

  /// Actualiza el perfil del usuario.
  Future<Usuario> actualizarPerfil(Usuario usuario) async {
    if (usuario.nombre?.trim().isEmpty ?? true) {
      throw const AppException('El nombre es obligatorio');
    }
    return await _repository.actualizarPerfil(usuario);
  }

  /// Sube una imagen de avatar a Storage.
  Future<String> subirAvatar(String usuarioId, String nombreArchivo, List<int> bytes) async {
    return await _repository.subirAvatar(usuarioId, nombreArchivo, bytes);
  }

  /// Stream de cambios de auth.
  Stream<AuthState> get onAuthStateChange =>
      _repository.onAuthStateChange;

  /// Usuario de Supabase Auth actual.
  User? get usuarioActual => _repository.usuarioActual;
}
