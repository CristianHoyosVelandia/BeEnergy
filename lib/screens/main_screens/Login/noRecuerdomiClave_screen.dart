// ignore_for_file: file_names

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

class NoRecuerdomiclaveScreen extends StatefulWidget {
  const NoRecuerdomiclaveScreen({super.key});

  @override
  State<NoRecuerdomiclaveScreen> createState() =>
      _NoRecuerdomiclaveScreenState();
}

class _NoRecuerdomiclaveScreenState extends State<NoRecuerdomiclaveScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _sendRecoveryEmail() async {
    if (!_formKey.currentState!.validate()) {
      Metodos.flushbarNegativo(context, 'Por favor ingresa un email válido');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _authService.forgotPassword(
        email: _email.text.trim(),
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (response['success']) {
        setState(() => _emailSent = true);
        await Metodos.flushbarPositivoLargo(
          context,
          response['message'] ??
              'Correo de recuperación enviado. Revisa tu bandeja de entrada.',
        );
      } else {
        Metodos.flushbarNegativo(
          context,
          response['message'] ?? 'No se pudo enviar el correo',
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      Metodos.flushbarNegativo(
          context, 'Error de conexión. Verifica tu internet.');
    }
  }

  Widget _sentState() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppTokens.space32),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(AppTokens.space16),
            decoration: BoxDecoration(
              color: AppTokens.primaryColor.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.mark_email_read_outlined,
              color: AppTokens.primaryColor,
              size: AppTokens.iconSizeXLarge,
            ),
          ),
          SizedBox(height: AppTokens.space16),
          Text(
            'Revisa tu correo para continuar con la recuperación de contraseña.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTokens.grey700,
                  height: 1.4,
                ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      heroHeight: 300,
      children: [
        const AuthHeader(
          title: 'Recuperar contraseña',
          subtitle: 'Te enviaremos instrucciones al correo registrado.',
        ),
        SizedBox(height: AppTokens.space16),
        if (_emailSent) ...[
          _sentState(),
          AuthPrimaryButton(
            label: 'Volver al login',
            onPressed: () => Navigator.pop(context),
          ),
        ] else ...[
          Form(
            key: _formKey,
            child: AuthTextField(
              label: 'Email',
              hint: 'Ingresa tu correo electrónico',
              controller: _email,
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              validator: Validators.emailValidator(),
            ),
          ),
          AuthPrimaryButton(
            label: 'Enviar',
            isLoading: _isLoading,
            onPressed: _sendRecoveryEmail,
          ),
          AuthFooterLink(
            text: '¿Ya tienes cuenta?',
            actionText: 'Volver a login',
            onTap: () => Navigator.pop(context),
          ),
        ],
      ],
    );
  }
}
