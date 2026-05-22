import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/supabase_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../models/usuario.dart';

/// Repositorio de autenticación.
/// Capa de acceso a datos — solo CRUD contra Supabase Auth + perfiles.
class AuthRepository {
  SupabaseClient get _supabase => Supabase.instance.client;

  /// Inicia sesión con email y contraseña.
  Future<AuthResponse> iniciarSesion({
    required String email,
    required String contrasena,
  }) async {
    try {
      return await _supabase.auth.signInWithPassword(
        email: email,
        password: contrasena,
      );
    } catch (e) {
      throw AppException.desdeSupabase(e);
    }
  }

  /// Registra un nuevo usuario.
  Future<AuthResponse> registrar({
    required String email,
    required String contrasena,
    String? nombre,
  }) async {
    try {
      return await _supabase.auth.signUp(
        email: email,
        password: contrasena,
        data: {'nombre': nombre},
      );
    } catch (e) {
      throw AppException.desdeSupabase(e);
    }
  }

  /// Cierra la sesión actual.
  Future<void> cerrarSesion() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw AppException.desdeSupabase(e);
    }
  }

  /// Recupera la contraseña mediante email.
  Future<void> recuperarContrasena(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw AppException.desdeSupabase(e);
    }
  }

  /// Verifica el código OTP enviado al correo para recuperación de contraseña.
  Future<AuthResponse> verificarCodigoRecuperacion(String email, String token) async {
    try {
      return await _supabase.auth.verifyOTP(
        email: email,
        token: token,
        type: OtpType.recovery,
      );
    } catch (e) {
      throw AppException.desdeSupabase(e);
    }
  }

  /// Actualiza la contraseña del usuario actual.
  Future<UserResponse> actualizarContrasena(String nuevaContrasena) async {
    try {
      return await _supabase.auth.updateUser(
        UserAttributes(password: nuevaContrasena),
      );
    } catch (e) {
      throw AppException.desdeSupabase(e);
    }
  }

  /// Borra la cuenta del usuario actual llamando a RPC (requiere que exista la función en Supabase).
  Future<void> borrarCuenta() async {
    try {
      await _supabase.rpc('delete_user');
      await _supabase.auth.signOut();
    } catch (e) {
      throw AppException.desdeSupabase(e);
    }
  }

  /// Obtiene el perfil del usuario actual.
  Future<Usuario?> obtenerPerfil(String userId) async {
    try {
      final response = await _supabase
          .from(SupabaseConstants.tablaPerfiles)
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return null;
      return Usuario.fromJson(response);
    } catch (e) {
      throw AppException.desdeSupabase(e);
    }
  }

  /// Actualiza el perfil del usuario.
  Future<Usuario> actualizarPerfil(Usuario usuario) async {
    try {
      final response = await _supabase
          .from(SupabaseConstants.tablaPerfiles)
          .update(usuario.toJson())
          .eq('id', usuario.id)
          .select()
          .single();

      return Usuario.fromJson(response);
    } catch (e) {
      throw AppException.desdeSupabase(e);
    }
  }

  /// Sube un avatar a Supabase Storage y retorna la URL pública.
  Future<String> subirAvatar(String usuarioId, String nombreArchivo, List<int> bytes) async {
    try {
      final path = '$usuarioId/$nombreArchivo';
      await _supabase.storage
          .from(SupabaseConstants.bucketAvatares)
          .uploadBinary(path, bytes as dynamic);

      return _supabase.storage
          .from(SupabaseConstants.bucketAvatares)
          .getPublicUrl(path);
    } catch (e) {
      throw AppException.desdeSupabase(e);
    }
  }

  /// Stream de cambios de autenticación.
  Stream<AuthState> get onAuthStateChange =>
      _supabase.auth.onAuthStateChange;

  /// Usuario actual de Supabase Auth.
  User? get usuarioActual => _supabase.auth.currentUser;
}
