import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'config/supabase_config.dart';

/// Punto de entrada de la aplicación Hogentia.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar variables de entorno
  await dotenv.load(fileName: '.env');

  // Inicializar formatos de fecha en español
  await initializeDateFormatting('es_ES', null);

  // Inicializar Supabase (si las credenciales son válidas)
  try {
    final url = dotenv.env['SUPABASE_URL'] ?? '';
    if (url.isNotEmpty && !url.contains('tu-proyecto')) {
      await SupabaseConfig.inicializar();
    }
  } catch (e) {
    debugPrint('⚠️ Supabase no configurado: $e');
    debugPrint('   Usa el modo invitado para explorar la app.');
  }

  runApp(const HogentiaApp());
}
