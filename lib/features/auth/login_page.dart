import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_archive/core/theme/app_colors.dart';
import 'package:movie_archive/core/utils/validators.dart';
import 'package:movie_archive/core/widgets/app_button.dart';
import 'package:movie_archive/core/widgets/app_text_field.dart';

// Pantalla de inicio de sesión. Por ahora no hace nada, solo valida el formulario y redirige a /catalog.
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

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    // cUANDO SE agreugue la implementación de AuthService, aquí se llamará a AuthService.signIn(email, password).
    context.go('/catalog');
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
                    const Image(
                      image: AssetImage('assets/images/logo.png'),
                      width: 120,
                      height: 120,
                    ),
                    const SizedBox(height: 32),
                    AppTextField(
                      label: 'Correo',
                      controller: _email,
                      hint: 'ejemplo@correo.com',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: Validators.email,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Contraseña',
                      controller: _password,
                      hint: '••••••',
                      obscureText: _hidePassword,
                      textInputAction: TextInputAction.done,
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
                    const SizedBox(height: 24),
                    AppButton.primary(
                      label: 'Iniciar sesión',
                      onPressed: _submit,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Text('¿No tienes una cuenta?'),
                        TextButton(
                          onPressed: () => context.go('/register'),
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
