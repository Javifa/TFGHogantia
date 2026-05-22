/// Excepción personalizada de la aplicación.
/// Envuelve los errores con mensajes legibles para el usuario.
class AppException implements Exception {
  final String mensaje;
  final String? codigo;
  final dynamic error;

  const AppException(
    this.mensaje, {
    this.codigo,
    this.error,
  });

  @override
  String toString() => mensaje;

  /// Crea una excepción a partir de un error de Supabase.
  factory AppException.desdeSupabase(dynamic error) {
    final mensaje = error?.toString() ?? 'Error desconocido';

    if (mensaje.contains('Invalid login credentials')) {
      return const AppException(
        'Credenciales incorrectas',
        codigo: 'AUTH_INVALID',
      );
    }
    if (mensaje.contains('User already registered')) {
      return const AppException(
        'Este correo ya está registrado',
        codigo: 'AUTH_DUPLICATE',
      );
    }
    if (mensaje.contains('Email not confirmed')) {
      return const AppException(
        'Debes confirmar tu correo electrónico',
        codigo: 'AUTH_UNCONFIRMED',
      );
    }
    if (mensaje.contains('network') || mensaje.contains('SocketException')) {
      return const AppException(
        'Sin conexión a internet',
        codigo: 'NETWORK',
      );
    }
    if (mensaje.contains('rate limit') || mensaje.contains('over_email_send_rate_limit')) {
      return const AppException(
        'Demasiados intentos. Por favor, desactiva "Confirm email" en Supabase o espera un rato.',
        codigo: 'AUTH_RATE_LIMIT',
      );
    }

    return AppException(
      'Error: $mensaje',
      codigo: 'UNKNOWN',
      error: error,
    );
  }
}
