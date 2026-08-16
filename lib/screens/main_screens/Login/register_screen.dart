// ignore_for_file: use_build_context_synchronously

import 'package:be_energy/core/services/auth_service.dart';
import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/core/utils/validators.dart';
import 'package:be_energy/utils/metodos.dart';
import 'package:be_energy/widgets/auth/auth_footer_link.dart';
import 'package:be_energy/widgets/auth/auth_header.dart';
import 'package:be_energy/widgets/auth/auth_primary_button.dart';
import 'package:be_energy/widgets/auth/auth_scaffold.dart';
import 'package:be_energy/widgets/auth/auth_text_field.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _communityCode = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _communityCode.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  String? _confirmPasswordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirma tu contraseña';
    }
    if (value != _password.text) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) {
      Metodos.flushbarNegativo(
        context,
        'Por favor, completa todos los campos correctamente',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // TODO: Consumir el WS definitivo de registro asociado a comunidad y enviar
      // communityCode/communityId cuando el backend exponga ese contrato.
      final response = await _authService.signUp(
        email: _email.text.trim(),
        password: _password.text,
        name: _name.text.trim(),
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (response['success']) {
        await Metodos.flushbarPositivoLargo(
          context,
          response['message'] ?? 'Usuario creado exitosamente',
        );
        if (!mounted) return;
        Navigator.pop(context);
      } else {
        Metodos.flushbarNegativo(
          context,
          response['message'] ?? 'Error al crear la cuenta',
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      Metodos.flushbarNegativo(
          context, 'Error de conexión. Verifica tu internet.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      children: [
        const AuthHeader(
          title: 'Registro Usuario',
          showLogo: false,
          subtitle:
              'Tu cuenta debe estar vinculada a una comunidad energética.',
        ),
        SizedBox(height: AppTokens.space16),
        Form(
          key: _formKey,
          child: Column(
            children: [
              AuthTextField(
                label: 'Nombre',
                hint: 'Ingresa tu nombre completo',
                controller: _name,
                icon: Icons.person_outline,
                textInputAction: TextInputAction.next,
                validator: Validators.minLengthValidator(
                  3,
                  errorMessage: 'Ingrese un nombre mayor a 3 caracteres',
                ),
              ),
              AuthTextField(
                label: 'Email',
                hint: 'Ingresa tu correo electrónico',
                controller: _email,
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: Validators.emailValidator(),
              ),
              AuthTextField(
                label: 'Comunidad',
                hint: 'Código o invitación de comunidad',
                controller: _communityCode,
                icon: Icons.apartment_rounded,
                textInputAction: TextInputAction.next,
                validator: Validators.requiredValidator(
                  errorMessage: 'La comunidad es requerida',
                ),
              ),
              AuthTextField(
                label: 'Contraseña',
                hint: 'Crea una contraseña segura',
                controller: _password,
                icon: Icons.lock_outline,
                obscureText: true,
                textInputAction: TextInputAction.next,
                validator: Validators.passwordValidator(),
              ),
              AuthTextField(
                label: 'Confirmar contraseña',
                hint: 'Repite tu contraseña',
                controller: _confirmPassword,
                icon: Icons.lock_reset_rounded,
                obscureText: true,
                textInputAction: TextInputAction.done,
                validator: _confirmPasswordValidator,
              ),
            ],
          ),
        ),
        AuthPrimaryButton(
          label: 'Crear Cuenta',
          isLoading: _isLoading,
          onPressed: _createAccount,
        ),
        AuthFooterLink(
          text: '¿Ya tienes cuenta?',
          actionText: 'Volver a login',
          onTap: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
