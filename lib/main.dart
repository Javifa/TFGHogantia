import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'app.dart';
import 'config/supabase_config.dart';

/// Punto de entrada de la aplicación Hogentia.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  // Cargar variables de entorno
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('No se encontró archivo .env, usando variables compiladas.');
  }

  // Inicializar formatos de fecha en español
  await initializeDateFormatting('es_ES', null);

  // Inicializar Supabase (si las credenciales son válidas)
  try {
    final urlEnv = const String.fromEnvironment('SUPABASE_URL');
    final url = urlEnv.isNotEmpty ? urlEnv : (dotenv.env['SUPABASE_URL'] ?? '');
    
    final anonKeyEnv = const String.fromEnvironment('SUPABASE_ANON_KEY');
    final anonKey = anonKeyEnv.isNotEmpty ? anonKeyEnv : (dotenv.env['SUPABASE_ANON_KEY'] ?? '');

    if (url.isNotEmpty && anonKey.isNotEmpty) {
      await SupabaseConfig.inicializar(url: url, anonKey: anonKey);
    }
  } catch (e) {
    debugPrint('⚠️ Supabase no configurado: $e');
    debugPrint('   Usa el modo invitado para explorar la app.');
  }

  runApp(const HogentiaApp());
}
