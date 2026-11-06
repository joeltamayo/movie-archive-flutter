import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_archive/core/theme/app_colors.dart';
import 'package:movie_archive/core/utils/validators.dart';
import 'package:movie_archive/core/widgets/app_button.dart';
import 'package:movie_archive/core/widgets/app_text_field.dart';


// Pantalla de registro. Por ahora no hace nada, solo valida el formulario y redirige a /catalog.
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _birthDateText = TextEditingController();
  DateTime? _birthDate;
  bool _hidePassword = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _birthDateText.dispose();
    super.dispose();
  }

  String _format(DateTime d) {
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    return '$day/$month/${d.year}';
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 20, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Fecha de nacimiento',
    );
    if (picked == null || !mounted) return;
    setState(() {
      _birthDate = picked;
      _birthDateText.text = _format(picked);
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    // Cuando se agregue la implementación de AuthService, aquí se llamará a AuthService.register(...) y se creará el documento users/{uid}.
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
                      'Regístrate',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Text('¿Ya tienes una cuenta?'),
                        TextButton(
                          onPressed: () => context.go('/login'),
                          child: const Text(
                            'Inicia sesión aquí.',
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
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Nombre',
                      controller: _name,
                      hint: 'Juan Pazcal',
                      textInputAction: TextInputAction.next,
                      validator: (v) =>
                          Validators.notEmpty(v, message: 'Escribe tu nombre'),
                    ),
                    const SizedBox(height: 16),
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
                      textInputAction: TextInputAction.next,
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
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Fecha de nacimiento',
                      controller: _birthDateText,
                      hint: 'dd/mm/aaaa',
                      readOnly: true,
                      onTap: _pickDate,
                      suffixIcon: IconButton(
                        tooltip: 'Elegir fecha',
                        icon: const Icon(Icons.calendar_month_outlined),
                        onPressed: _pickDate,
                      ),
                      validator: (v) => Validators.notEmpty(
                        v,
                        message: 'Selecciona tu fecha de nacimiento',
                      ),
                    ),
                    const SizedBox(height: 28),
                    AppButton.accent(label: 'Regístrate', onPressed: _submit),
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
