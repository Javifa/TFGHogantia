import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/responsive.dart';

class AyudaScreen extends StatelessWidget {
  const AyudaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final hp = Responsive.horizontalPadding(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Centro de Ayuda'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(hp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Icon(Icons.help_outline_rounded, size: 64, color: AppColors.primary),
            const SizedBox(height: 24),
            Text(
              '¿En qué podemos ayudarte?',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Encuentra respuestas a las preguntas más frecuentes sobre el uso de Hogentia.',
              style: TextStyle(fontSize: 16, color: AppColors.textPrimary, height: 1.5),
            ),
            const SizedBox(height: 32),
            _PreguntaFrecuente(
              pregunta: '¿Cómo añado un producto a una estancia?',
              respuesta: 'Dirígete a la pestaña "Inicio", selecciona la estancia deseada y pulsa el botón flotante (+) en la esquina inferior derecha. Podrás introducir el nombre, la cantidad y adjuntar el ticket de compra.',
            ),
            _PreguntaFrecuente(
              pregunta: '¿Puedo compartir mis estancias con familiares?',
              respuesta: 'Actualmente, el sistema está diseñado para un único gestor por cuenta para garantizar la privacidad y consistencia de los datos. Estamos trabajando en la funcionalidad multiusuario para futuras versiones.',
            ),
            _PreguntaFrecuente(
              pregunta: '¿Qué pasa si olvido mi contraseña?',
              respuesta: 'En la pantalla de inicio de sesión, pulsa en "¿Has olvidado tu contraseña?" e introduce tu correo. Te enviaremos un enlace seguro para restablecerla al instante.',
            ),
            _PreguntaFrecuente(
              pregunta: '¿Cómo funcionan los gráficos de gastos?',
              respuesta: 'La pestaña "Gastos" recopila automáticamente todos los tickets que subes en la sección "Compras". Calcula el total mensual y te muestra una media para que sepas en qué gastas más.',
            ),
            const SizedBox(height: 48),
            Center(
              child: Column(
                children: [
                  const Text('¿No encuentras lo que buscas?', style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Contactando con soporte... (Simulación)')),
                      );
                    },
                    icon: const Icon(Icons.support_agent_rounded),
                    label: const Text('Contactar con Soporte'),
                  )
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _PreguntaFrecuente extends StatefulWidget {
  final String pregunta;
  final String respuesta;

  const _PreguntaFrecuente({required this.pregunta, required this.respuesta});

  @override
  State<_PreguntaFrecuente> createState() => _PreguntaFrecuenteState();
}

class _PreguntaFrecuenteState extends State<_PreguntaFrecuente> {
  bool _expandido = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.border),
      ),
      color: AppColors.surfaceVariant,
      child: ExpansionTile(
        title: Text(
          widget.pregunta,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.textPrimary),
        ),
        onExpansionChanged: (v) => setState(() => _expandido = v),
        iconColor: AppColors.primary,
        collapsedIconColor: AppColors.textHint,
        childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        children: [
          Text(
            widget.respuesta,
            style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
          ),
        ],
      ),
    );
  }
}
