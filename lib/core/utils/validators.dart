/// Validaciones reutilizables para formularios.
class Validators {
  Validators._();

  /// Valida que el campo no esté vacío.
  static String? requerido(String? valor, [String campo = 'Este campo']) {
    if (valor == null || valor.trim().isEmpty) {
      return '$campo es obligatorio';
    }
    return null;
  }

  /// Valida formato de email.
  static String? email(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'El email es obligatorio';
    }
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(valor.trim())) {
      return 'Introduce un email válido';
    }
    return null;
  }

  /// Valida contraseña (mínimo 6 caracteres).
  static String? contrasena(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'La contraseña es obligatoria';
    }
    if (valor.length < 6) {
      return 'Mínimo 6 caracteres';
    }
    return null;
  }

  /// Valida que dos contraseñas coincidan.
  static String? confirmarContrasena(String? valor, String contrasena) {
    if (valor == null || valor.isEmpty) {
      return 'Confirma la contraseña';
    }
    if (valor != contrasena) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  /// Valida longitud máxima.
  static String? longitudMaxima(
    String? valor,
    int max, [
    String campo = 'Este campo',
  ]) {
    if (valor != null && valor.length > max) {
      return '$campo no puede exceder $max caracteres';
    }
    return null;
  }

  /// Valida que sea un número entero positivo.
  static String? numeroPositivo(String? valor, [String campo = 'Este campo']) {
    if (valor == null || valor.trim().isEmpty) return null; // Permitir vacío
    final numero = int.tryParse(valor);
    if (numero == null || numero < 0) {
      return '$campo debe ser un número positivo';
    }
    return null;
  }

  /// Valida que sea un precio válido.
  static String? precio(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'El precio es obligatorio';
    }
    final precio = double.tryParse(valor.replaceAll(',', '.'));
    if (precio == null || precio < 0) {
      return 'Introduce un precio válido';
    }
    return null;
  }
}
