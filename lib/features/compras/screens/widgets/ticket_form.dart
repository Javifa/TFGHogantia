import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../facades/compras_facade.dart';
import '../../../productos/screens/widgets/producto_form.dart';

/// Formulario para registrar una compra con opción de adjuntar ticket.
class TicketForm extends StatefulWidget {
  const TicketForm({super.key});
  @override
  State<TicketForm> createState() => _TicketFormState();
}

class _TicketFormState extends State<TicketForm> {
  final _formKey = GlobalKey<FormState>();
  final _tiendaCtrl = TextEditingController();
  final _totalCtrl = TextEditingController();
  DateTime _fecha = DateTime.now();
  Uint8List? _ticketBytes;
  String? _ticketNombre;

  @override
  void dispose() {
    _tiendaCtrl.dispose();
    _totalCtrl.dispose();
    super.dispose();
  }

  Future<void> _seleccionarTicket() async {
    final picker = ImagePicker();
    final imagen = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1200, imageQuality: 80);
    if (imagen == null) return;
    final bytes = await imagen.readAsBytes();
    setState(() {
      _ticketBytes = bytes;
      _ticketNombre = imagen.name;
    });
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    final facade = context.read<ComprasFacade>();
    final ok = await facade.crearCompra(
      tienda: _tiendaCtrl.text.trim().isEmpty ? null : _tiendaCtrl.text.trim(),
      total: double.parse(_totalCtrl.text.replaceAll(',', '.')),
      fecha: _fecha,
      imagenTicket: _ticketBytes,
    );
    if (ok && mounted) Navigator.of(context).pop();
  }

  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (fecha != null) setState(() => _fecha = fecha);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(left: 24, right: 24, top: 16, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              Text('Nueva compra', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 20),

              CustomTextField(controller: _tiendaCtrl, label: 'Tienda (opcional)', hint: 'Ej: Mercadona', prefixIcon: Icons.store_outlined),
              const SizedBox(height: 14),
              CustomTextField(controller: _totalCtrl, label: 'Total (€)', hint: '0.00', prefixIcon: Icons.euro_outlined, keyboardType: const TextInputType.numberWithOptions(decimal: true), validator: Validators.precio),
              const SizedBox(height: 14),

              // Fecha
              GestureDetector(
                onTap: _seleccionarFecha,
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Fecha', prefixIcon: Icon(Icons.calendar_today_outlined)),
                  child: Text('${_fecha.day}/${_fecha.month}/${_fecha.year}'),
                ),
              ),
              const SizedBox(height: 14),

              // ── Adjuntar ticket ──
              TicketAttachment(
                ticketBytes: _ticketBytes,
                ticketNombre: _ticketNombre,
                onSeleccionar: _seleccionarTicket,
                onEliminar: () => setState(() {
                  _ticketBytes = null;
                  _ticketNombre = null;
                }),
              ),
              const SizedBox(height: 20),

              SizedBox(height: 50, child: ElevatedButton(onPressed: _guardar, child: const Text('Registrar compra'))),
            ],
          ),
        ),
      ),
    );
  }
}
