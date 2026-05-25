import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/facades/auth_facade.dart';
import '../../../auth/models/usuario.dart';

/// Formulario para editar el perfil del usuario.
class PerfilForm extends StatefulWidget {
  final Usuario usuario;
  const PerfilForm({super.key, required this.usuario});

  @override
  State<PerfilForm> createState() => _PerfilFormState();
}

class _PerfilFormState extends State<PerfilForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreCtrl;
  Uint8List? _avatarBytes;
  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController(text: widget.usuario.nombreVisible);
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    super.dispose();
  }

  Future<void> _seleccionarAvatar() async {
    final picker = ImagePicker();
    final imagen = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 500,
      imageQuality: 80,
    );
    if (imagen == null) return;

    final bytes = await imagen.readAsBytes();
    setState(() {
      _avatarBytes = bytes;
    });
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _cargando = true);

    final facade = context.read<AuthFacade>();
    final ok = await facade.actualizarPerfil(
      nombre: _nombreCtrl.text.trim(),
      avatarBytes: _avatarBytes,
    );

    if (mounted) {
      setState(() => _cargando = false);
      if (ok) {
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
              content: Text(facade.error ?? 'Error al guardar el perfil'),
            ),
          );
      }
    }
  }

  Future<void> _borrarCuenta() async {
    final ok = await ConfirmDialog.mostrar(
      context,
      titulo: 'Eliminar cuenta',
      mensaje:
          '¿Estás completamente seguro? Esta acción borrará todos tus datos y no se puede deshacer.',
      textoConfirmar: 'Eliminar',
    );
    if (ok && mounted) {
      setState(() => _cargando = true);
      final facade = context.read<AuthFacade>();
      final success = await facade.borrarCuenta();
      if (mounted) {
        setState(() => _cargando = false);
        if (success) {
          context.go('/login');
        } else {
          ScaffoldMessenger.of(context)
            ..clearSnackBars()
            ..showSnackBar(
              SnackBar(
                content: Text(facade.error ?? 'Error al borrar la cuenta'),
              ),
            );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final inicial = widget.usuario.nombreVisible.isNotEmpty
        ? widget.usuario.nombreVisible[0].toUpperCase()
        : 'U';

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Editar Perfil',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),

              // Selector de foto de perfil
              Center(
                child: GestureDetector(
                  onTap: _seleccionarAvatar,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.primary.withValues(
                          alpha: 0.1,
                        ),
                        backgroundImage: _avatarBytes != null
                            ? MemoryImage(_avatarBytes!)
                            : (widget.usuario.avatarUrl != null
                                      ? NetworkImage(widget.usuario.avatarUrl!)
                                      : null)
                                  as ImageProvider?,
                        child:
                            (_avatarBytes == null &&
                                widget.usuario.avatarUrl == null)
                            ? Text(
                                inicial,
                                style: const TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              CustomTextField(
                controller: _nombreCtrl,
                label: 'Nombre completo',
                hint: 'Ej: Juan Pérez',
                prefixIcon: Icons.person_outline,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 32),

              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _cargando ? null : _guardar,
                  child: _cargando
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Guardar cambios'),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: _cargando ? null : _borrarCuenta,
                  icon: const Icon(
                    Icons.delete_forever_rounded,
                    color: AppColors.error,
                  ),
                  label: const Text(
                    'Eliminar cuenta permanentemente',
                    style: TextStyle(color: AppColors.error),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: AppColors.error.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
