import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../facades/estancias_facade.dart';
import '../../models/estancia.dart';

/// Formulario para crear/editar una estancia (BottomSheet).
class EstanciaForm extends StatefulWidget {
  final Estancia? estancia;
  const EstanciaForm({super.key, this.estancia});
  @override
  State<EstanciaForm> createState() => _EstanciaFormState();
}

class _EstanciaFormState extends State<EstanciaForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _descCtrl;
  late String _icono;
  bool get _esEdicion => widget.estancia != null;

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController(text: widget.estancia?.nombre ?? '');
    _descCtrl = TextEditingController(text: widget.estancia?.descripcion ?? '');
    _icono = widget.estancia?.icono ?? '🏠';
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    final facade = context.read<EstanciasFacade>();
    bool ok;
    if (_esEdicion) {
      ok = await facade.actualizarEstancia(widget.estancia!.copyWith(
        nombre: _nombreCtrl.text.trim(),
        icono: _icono,
        descripcion: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      ));
    } else {
      ok = await facade.crearEstancia(
        nombre: _nombreCtrl.text.trim(),
        icono: _icono,
        descripcion: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      );
    }
    if (ok && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Text(_esEdicion ? 'Editar estancia' : 'Nueva estancia', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            const Text('Icono', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: AppConstants.iconosEstancia.map((i) {
                final sel = i == _icono;
                return GestureDetector(
                  onTap: () => setState(() => _icono = i),
                  child: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: sel ? AppColors.primary.withValues(alpha: 0.1) : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                      border: sel ? Border.all(color: AppColors.primary, width: 2) : null,
                    ),
                    child: Center(child: Text(i, style: const TextStyle(fontSize: 22))),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            CustomTextField(controller: _nombreCtrl, label: 'Nombre', hint: 'Ej: Cocina', prefixIcon: Icons.home_outlined, validator: (v) => Validators.requerido(v, 'El nombre')),
            const SizedBox(height: 16),
            CustomTextField(controller: _descCtrl, label: 'Descripción (opcional)', hint: 'Ej: Cocina principal', prefixIcon: Icons.notes_outlined, maxLines: 2),
            const SizedBox(height: 24),
            SizedBox(height: 52, child: ElevatedButton(onPressed: _guardar, child: Text(_esEdicion ? 'Guardar' : 'Crear estancia'))),
          ],
        ),
      ),
    );
  }
}
