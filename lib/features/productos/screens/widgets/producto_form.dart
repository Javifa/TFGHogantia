import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../facades/productos_facade.dart';

/// Formulario para crear un producto con opción de adjuntar ticket.
class ProductoForm extends StatefulWidget {
  final String estanciaId;
  const ProductoForm({super.key, required this.estanciaId});
  @override
  State<ProductoForm> createState() => _ProductoFormState();
}

class _ProductoFormState extends State<ProductoForm> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _cantidadCtrl = TextEditingController(text: '0');
  final _minCtrl = TextEditingController(text: '0');
  final _precioCtrl = TextEditingController();
  final _notasCtrl = TextEditingController();
  String? _categoria;
  String? _unidad;
  Uint8List? _ticketBytes;
  String? _ticketNombre;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _cantidadCtrl.dispose();
    _minCtrl.dispose();
    _precioCtrl.dispose();
    _notasCtrl.dispose();
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
    final facade = context.read<ProductosFacade>();
    final ok = await facade.crearProducto(
      estanciaId: widget.estanciaId,
      nombre: _nombreCtrl.text.trim(),
      categoria: _categoria,
      cantidad: int.tryParse(_cantidadCtrl.text) ?? 0,
      cantidadMinima: int.tryParse(_minCtrl.text) ?? 0,
      unidad: _unidad,
      notas: _notasCtrl.text.trim().isEmpty ? null : _notasCtrl.text.trim(),
    );
    if (ok && mounted) Navigator.of(context).pop();
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
              Text('Nuevo producto', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 20),

              CustomTextField(controller: _nombreCtrl, label: 'Nombre', hint: 'Ej: Leche', prefixIcon: Icons.inventory_2_outlined, validator: (v) => Validators.requerido(v, 'El nombre')),
              const SizedBox(height: 14),

              DropdownButtonFormField<String>(
                initialValue: _categoria,
                decoration: const InputDecoration(labelText: 'Categoría', prefixIcon: Icon(Icons.category_outlined)),
                items: AppConstants.categoriasProducto.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _categoria = v),
              ),
              const SizedBox(height: 14),

              Row(children: [
                Expanded(child: CustomTextField(controller: _cantidadCtrl, label: 'Cantidad', keyboardType: TextInputType.number, validator: (v) => Validators.numeroPositivo(v, 'Cantidad'))),
                const SizedBox(width: 12),
                Expanded(child: CustomTextField(controller: _minCtrl, label: 'Mínimo', keyboardType: TextInputType.number, validator: (v) => Validators.numeroPositivo(v, 'Mínimo'))),
              ]),
              const SizedBox(height: 14),

              Row(children: [
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    initialValue: _unidad,
                    decoration: const InputDecoration(labelText: 'Unidad', prefixIcon: Icon(Icons.straighten_outlined)),
                    items: AppConstants.unidadesMedida.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                    onChanged: (v) => setState(() => _unidad = v),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: CustomTextField(controller: _precioCtrl, label: 'Precio (€)', hint: '0.00', keyboardType: const TextInputType.numberWithOptions(decimal: true))),
              ]),
              const SizedBox(height: 14),

              CustomTextField(controller: _notasCtrl, label: 'Notas (opcional)', maxLines: 2, prefixIcon: Icons.notes_outlined),
              const SizedBox(height: 14),

              // ── Adjuntar ticket ──
              _TicketAttachment(
                ticketBytes: _ticketBytes,
                ticketNombre: _ticketNombre,
                onSeleccionar: _seleccionarTicket,
                onEliminar: () => setState(() {
                  _ticketBytes = null;
                  _ticketNombre = null;
                }),
              ),
              const SizedBox(height: 20),

              SizedBox(height: 50, child: ElevatedButton(onPressed: _guardar, child: const Text('Crear producto'))),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget reutilizable para adjuntar imagen de ticket.
class TicketAttachment extends StatelessWidget {
  final Uint8List? ticketBytes;
  final String? ticketNombre;
  final VoidCallback onSeleccionar;
  final VoidCallback onEliminar;

  const TicketAttachment({
    super.key,
    this.ticketBytes,
    this.ticketNombre,
    required this.onSeleccionar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    return _TicketAttachment(
      ticketBytes: ticketBytes,
      ticketNombre: ticketNombre,
      onSeleccionar: onSeleccionar,
      onEliminar: onEliminar,
    );
  }
}

class _TicketAttachment extends StatelessWidget {
  final Uint8List? ticketBytes;
  final String? ticketNombre;
  final VoidCallback onSeleccionar;
  final VoidCallback onEliminar;

  const _TicketAttachment({
    this.ticketBytes,
    this.ticketNombre,
    required this.onSeleccionar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    if (ticketBytes != null) {
      // Ticket seleccionado — preview
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(ticketBytes!, width: 48, height: 48, fit: BoxFit.cover),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Ticket adjunto', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.success)),
                  const SizedBox(height: 2),
                  Text(ticketNombre ?? 'imagen.jpg', style: const TextStyle(fontSize: 11, color: AppColors.textHint), overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            IconButton(icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.textHint), onPressed: onEliminar),
          ],
        ),
      );
    }

    // Sin ticket — botón para adjuntar
    return GestureDetector(
      onTap: onSeleccionar,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, style: BorderStyle.solid),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt_outlined, size: 20, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Text('Adjuntar foto de ticket', style: TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
