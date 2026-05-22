import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/responsive.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../facades/auth_facade.dart';
import '../../estancias/facades/estancias_facade.dart';
import '../../productos/facades/productos_facade.dart';
import '../../compras/facades/compras_facade.dart';
import '../../gastos/facades/gastos_facade.dart';

/// Pantalla de inicio de sesión.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _showPass = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final facade = context.read<AuthFacade>();
    final ok = await facade.iniciarSesion(
      email: _emailCtrl.text,
      contrasena: _passCtrl.text,
    );
    if (ok && mounted) context.go('/');
  }

  Future<void> _recuperarContrasena() async {
    if (_emailCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, introduce tu email en el campo superior primero')),
      );
      return;
    }
    final facade = context.read<AuthFacade>();
    final ok = await facade.recuperarContrasena(_emailCtrl.text);
    if (mounted && ok) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => _OtpDialog(email: _emailCtrl.text),
      );
    }
  }

  Future<void> _guest() async {
    await context.read<AuthFacade>().entrarComoInvitado();
    if (!mounted) return;
    context.read<EstanciasFacade>().activarModoDemo();
    context.read<ProductosFacade>().activarModoDemo();
    context.read<ComprasFacade>().activarModoDemo();
    context.read<GastosFacade>().activarModoDemo();
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final isWide = !Responsive.isMobile(context);

    return Scaffold(
      body: isWide ? _buildDesktop() : _buildMobile(),
    );
  }

  // ── Desktop / Tablet: split layout ──
  Widget _buildDesktop() {
    return Row(
      children: [
        // Panel izquierdo — branding
        Expanded(
          flex: 5,
          child: Container(
            decoration: const BoxDecoration(
              gradient: AppColors.heroGradient,
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(48),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                      ),
                      child: const Icon(Icons.home_rounded, size: 36, color: Colors.white),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Hogentia',
                      style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -1),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tu hogar, bajo control.',
                      style: TextStyle(fontSize: 16, color: Colors.white.withValues(alpha: 0.8)),
                    ),
                    const SizedBox(height: 40),
                    // Feature pills
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: ['🏠 Estancias', '📦 Stock', '🛒 Compras', '📊 Gastos'].map((t) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                          ),
                          child: Text(t, style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13, fontWeight: FontWeight.w500)),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Panel derecho — formulario
        Expanded(
          flex: 4,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(48),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: _buildForm(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Móvil: single column ──
  Widget _buildMobile() {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Logo
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.home_rounded, size: 32, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text('Hogentia', style: Theme.of(context).textTheme.displayMedium),
              const SizedBox(height: 4),
              Text('Tu hogar, bajo control.', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 36),
              _buildForm(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Formulario compartido ──
  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Título
          Text('Iniciar sesión', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 4),
          Text('Accede a tu hogar digital', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 28),

          CustomTextField(
            controller: _emailCtrl,
            label: 'Email',
            hint: 'tu@email.com',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: Validators.email,
          ),
          const SizedBox(height: 14),
          CustomTextField(
            controller: _passCtrl,
            label: 'Contraseña',
            hint: '••••••••',
            prefixIcon: Icons.lock_outline,
            obscureText: !_showPass,
            textInputAction: TextInputAction.done,
            validator: Validators.contrasena,
            onSubmitted: (_) => _login(),
            suffixIcon: IconButton(
              icon: Icon(_showPass ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.textHint, size: 20),
              onPressed: () => setState(() => _showPass = !_showPass),
            ),
          ),
          
          // Olvidé mi contraseña
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _recuperarContrasena,
              child: const Text('¿Has olvidado tu contraseña?'),
            ),
          ),
          
          const SizedBox(height: 8),

          // Error
          Consumer<AuthFacade>(
            builder: (_, f, __) {
              if (f.error == null) return const SizedBox.shrink();
              return Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.error, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(f.error!, style: const TextStyle(color: AppColors.error, fontSize: 13))),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 8),

          // Botón login
          Consumer<AuthFacade>(
            builder: (_, f, __) => SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: f.cargando ? null : _login,
                child: f.cargando
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Continuar'),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Registro link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('¿Sin cuenta? ', style: Theme.of(context).textTheme.bodyMedium),
              TextButton(onPressed: () => context.go('/registro'), child: const Text('Crear una')),
            ],
          ),

          const SizedBox(height: 12),

          // Divider
          Row(
            children: [
              Expanded(child: Container(height: 1, color: AppColors.divider)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('o', style: Theme.of(context).textTheme.bodySmall),
              ),
              Expanded(child: Container(height: 1, color: AppColors.divider)),
            ],
          ),

          const SizedBox(height: 12),

          // Invitado
          SizedBox(
            height: 50,
            child: OutlinedButton.icon(
              onPressed: _guest,
              icon: const Icon(Icons.explore_outlined, size: 18),
              label: const Text('Explorar como invitado'),
            ),
          ),
          const SizedBox(height: 6),
          Text('Datos de ejemplo · Sin registro', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _OtpDialog extends StatefulWidget {
  final String email;
  const _OtpDialog({required this.email});

  @override
  State<_OtpDialog> createState() => _OtpDialogState();
}

class _OtpDialogState extends State<_OtpDialog> {
  final _codeCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _codeVerified = false;
  bool _loading = false;

  @override
  void dispose() {
    _codeCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _verificar() async {
    if (_codeCtrl.text.trim().isEmpty) return;
    setState(() => _loading = true);
    final facade = context.read<AuthFacade>();
    final ok = await facade.verificarCodigoRecuperacion(widget.email, _codeCtrl.text.trim());
    if (mounted) {
      setState(() => _loading = false);
      if (ok) {
        setState(() => _codeVerified = true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(facade.error ?? 'Código inválido')));
      }
    }
  }

  Future<void> _cambiarPassword() async {
    if (_passCtrl.text.trim().length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mínimo 6 caracteres')));
      return;
    }
    setState(() => _loading = true);
    final facade = context.read<AuthFacade>();
    final ok = await facade.actualizarContrasena(_passCtrl.text);
    if (mounted) {
      setState(() => _loading = false);
      if (ok) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contraseña cambiada con éxito')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(facade.error ?? 'Error al actualizar')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_codeVerified ? 'Nueva Contraseña' : 'Introduce el código'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_codeVerified 
            ? 'Introduce tu nueva contraseña segura.'
            : 'Revisa tu correo electrónico. Te hemos enviado un código de seguridad de 6 dígitos.'),
          const SizedBox(height: 16),
          if (!_codeVerified)
            CustomTextField(
              controller: _codeCtrl,
              label: 'Código de 6 dígitos',
              hint: '123456',
              keyboardType: TextInputType.number,
            )
          else
            CustomTextField(
              controller: _passCtrl,
              label: 'Nueva contraseña',
              hint: '••••••••',
              obscureText: true,
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _loading ? null : (_codeVerified ? _cambiarPassword : _verificar),
          child: _loading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : Text(_codeVerified ? 'Guardar' : 'Verificar'),
        ),
      ],
    );
  }
}

