import 'package:flutter/material.dart';

/// Diálogo de confirmación reutilizable.
/// Devuelve `true` si el usuario confirma, `false` si cancela.
class ConfirmDialog extends StatelessWidget {
  final String titulo;
  final String mensaje;
  final String textoConfirmar;
  final String textoCancelar;
  final bool esPeligroso;

  const ConfirmDialog({
    super.key,
    required this.titulo,
    required this.mensaje,
    this.textoConfirmar = 'Confirmar',
    this.textoCancelar = 'Cancelar',
    this.esPeligroso = false,
  });

  /// Muestra el diálogo y devuelve el resultado.
  static Future<bool> mostrar(
    BuildContext context, {
    required String titulo,
    required String mensaje,
    String textoConfirmar = 'Confirmar',
    String textoCancelar = 'Cancelar',
    bool esPeligroso = false,
  }) async {
    final resultado = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog(
        titulo: titulo,
        mensaje: mensaje,
        textoConfirmar: textoConfirmar,
        textoCancelar: textoCancelar,
        esPeligroso: esPeligroso,
      ),
    );
    return resultado ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.w600)),
      content: Text(
        mensaje,
        style: TextStyle(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(textoCancelar),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: esPeligroso
              ? ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                )
              : null,
          child: Text(textoConfirmar),
        ),
      ],
    );
  }
}
