import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_archive/core/theme/app_colors.dart';
import 'package:movie_archive/core/utils/validators.dart';
import 'package:movie_archive/core/widgets/app_button.dart';
import 'package:movie_archive/core/widgets/app_text_field.dart';
import 'package:movie_archive/core/widgets/error_banner.dart';
import 'package:movie_archive/data/services/auth_service.dart';
import 'package:movie_archive/data/services/services.dart';

// Pantalla de inicio de sesión 
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _hidePassword = true;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy) return;
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await authService.signIn(
        email: _email.text.trim(),
        password: _password.text,
      );
      // Al cambiar la sesión, el router redirige solo al catálogo.
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _busy = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'No se pudo iniciar sesión. Inténtalo de nuevo.';
        _busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Bienvenido a',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: AppColors.muted),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Movie Archive',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Tu archivo personal de películas',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: AppColors.muted),
                    ),
                    const SizedBox(height: 24),
                    const Center(
                      child: Image(
                        image: AssetImage('assets/images/logo.png'),
                        width: 120,
                        height: 120,
                        semanticLabel: 'Logo de Movie Archive',
                      ),
                    ),
                    const SizedBox(height: 32),
                    AppTextField(
                      label: 'Correo',
                      controller: _email,
                      hint: 'ejemplo@correo.com',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      enabled: !_busy,
                      validator: Validators.email,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Contraseña',
                      controller: _password,
                      hint: '••••••',
                      obscureText: _hidePassword,
                      textInputAction: TextInputAction.done,
                      enabled: !_busy,
                      onSubmitted: (_) => _submit(),
                      validator: Validators.password,
                      suffixIcon: IconButton(
                        tooltip: _hidePassword
                            ? 'Mostrar contraseña'
                            : 'Ocultar contraseña',
                        icon: Icon(
                          _hidePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () =>
                            setState(() => _hidePassword = !_hidePassword),
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      ErrorBanner(_error!),
                    ],
                    const SizedBox(height: 24),
                    AppButton.primary(
                      label: _busy ? 'Entrando…' : 'Iniciar sesión',
                      onPressed: _busy ? null : _submit,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Text('¿No tienes una cuenta?'),
                        TextButton(
                          onPressed: _busy ? null : () => context.go('/register'),
                          child: const Text(
                            'Regístrate aquí.',
                            style: TextStyle(
                              color: AppColors.link,
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.link,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
