import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../facades/compras_facade.dart';
import '../../../productos/screens/widgets/producto_form.dart';

import '../../models/compra.dart';

/// Formulario para registrar o editar una compra con opción de adjuntar ticket.
class TicketForm extends StatefulWidget {
  final Compra? compra;

  const TicketForm({super.key, this.compra});
  @override
  State<TicketForm> createState() => _TicketFormState();
}

class _TicketFormState extends State<TicketForm> {
  final _formKey = GlobalKey<FormState>();
  final _tiendaCtrl = TextEditingController();
  final _conceptoCtrl = TextEditingController();
  final _totalCtrl = TextEditingController();
  DateTime _fecha = DateTime.now();
  Uint8List? _ticketBytes;
  String? _ticketNombre;

  @override
  void initState() {
    super.initState();
    if (widget.compra != null) {
      final c = widget.compra!;
      _tiendaCtrl.text = c.tienda ?? '';
      _conceptoCtrl.text = c.concepto ?? '';
      _totalCtrl.text = c.total.toStringAsFixed(2);
      _fecha = c.fecha;
      if (c.imagenTicketUrl != null) {
        _ticketNombre = 'Ticket actual guardado';
      }
    }
  }

  @override
  void dispose() {
    _tiendaCtrl.dispose();
    _conceptoCtrl.dispose();
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
    final tienda = _tiendaCtrl.text.trim().isEmpty ? null : _tiendaCtrl.text.trim();
    final concepto = _conceptoCtrl.text.trim().isEmpty ? null : _conceptoCtrl.text.trim();
    final total = double.parse(_totalCtrl.text.replaceAll(',', '.'));

    bool ok;
    if (widget.compra != null) {
      ok = await facade.actualizarCompra(
        widget.compra!,
        tienda: tienda,
        concepto: concepto,
        total: total,
        fecha: _fecha,
        nuevaImagenTicket: _ticketBytes,
      );
    } else {
      ok = await facade.crearCompra(
        tienda: tienda,
        concepto: concepto,
        total: total,
        fecha: _fecha,
        imagenTicket: _ticketBytes,
      );
    }
    
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
              Text(widget.compra == null ? 'Nueva compra' : 'Editar compra', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 20),

              CustomTextField(controller: _tiendaCtrl, label: 'Tienda (opcional)', hint: 'Ej: Mercadona', prefixIcon: Icons.store_outlined),
              const SizedBox(height: 14),
              CustomTextField(controller: _conceptoCtrl, label: 'Concepto (opcional)', hint: 'Ej: Compra semanal, Fiesta...', prefixIcon: Icons.label_outline),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _totalCtrl, 
                label: 'Total (€)', 
                hint: '0.00', 
                prefixIcon: Icons.euro_outlined, 
                keyboardType: const TextInputType.numberWithOptions(decimal: true), 
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))],
                validator: Validators.precio
              ),
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

              SizedBox(height: 50, child: ElevatedButton(onPressed: _guardar, child: Text(widget.compra == null ? 'Registrar compra' : 'Guardar cambios'))),
            ],
          ),
        ),
      ),
    );
  }
}
