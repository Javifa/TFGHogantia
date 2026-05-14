import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Configuración e inicialización de Supabase.
class SupabaseConfig {
  SupabaseConfig._();

  static bool _inicializado = false;
  
  /// Flag estático de modo invitado (accesible sin Provider).
  static bool modoInvitado = false;

  /// Inicializa la conexión con Supabase.
  /// Debe llamarse en main() antes de runApp().
  static Future<void> inicializar() async {
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    );
    _inicializado = true;
  }

  /// Si Supabase se inicializó correctamente.
  static bool get inicializado => _inicializado;

  /// Cliente Supabase singleton.
  static SupabaseClient get cliente => Supabase.instance.client;

  /// Usuario autenticado actual (puede ser null).
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
  static bool get estaAutenticado =>
      modoInvitado || usuarioActual != null;
}
