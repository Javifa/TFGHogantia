import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Configuración e inicialización de Supabase.
class SupabaseConfig {
  SupabaseConfig._();

  static bool _inicializado = false;

  static bool modoInvitado = false;

  // Inicializa la conexión con Supabase.
  static Future<void> inicializar({
    required String url,
    required String anonKey,
  }) async {
    await Supabase.initialize(url: url, anonKey: anonKey);
    _inicializado = true;
  }

  // Si Supabase se inicializa correctamente.
  static bool get inicializado => _inicializado;

  static SupabaseClient get cliente => Supabase.instance.client;

  // Pilla el usuario actual.
  static User? get usuarioActual {
    if (!_inicializado) return null;
    try {
      return cliente.auth.currentUser;
    } catch (_) {
      return null;
    }
  }

  /// ID del usuario actual.
  static String? get usuarioId => usuarioActual?.id;

  /// Verifica si hay un usuario autenticado (o en modo invitado).
  static bool get estaAutenticado => modoInvitado || usuarioActual != null;
}
