// ignore_for_file: file_names

import 'package:be_energy/core/extensions/context_extensions.dart';
import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/repositories/auth_repository.dart';
import 'package:be_energy/utils/metodos.dart';
import 'package:flutter/material.dart';

import '../../../models/my_user.dart';
import '../Login/reset_password_screen.dart';

class CambiarClavePerfilScreen extends StatefulWidget {
  final MyUser myUser;

  const CambiarClavePerfilScreen({super.key, required this.myUser});

  @override
  State<CambiarClavePerfilScreen> createState() => _CambiarClavePerfilScreenState();
}

class _CambiarClavePerfilScreenState extends State<CambiarClavePerfilScreen> {
  final AuthRepository _authRepository = AuthRepository();
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    final correo = widget.myUser.correo;
    if (correo != null && correo.isNotEmpty) {
      _emailController.text = correo;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _enviarCodigo() async {
    if (!_formKey.currentState!.validate()) return;
    final email = _emailController.text.trim();
    setState(() => _sending = true);
    try {
      final resp = await _authRepository.forgotPassword(email: email);
      if (!mounted) return;
      if (resp.success) {
        Metodos.flushbarPositivo(
          context,
          'Si existe una cuenta con este correo, recibirás un código por email.',
        );
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) context.push(ResetPasswordScreen(email: email));
        });
      } else {
        Metodos.flushbarNegativo(
          context,
          resp.message ?? 'No se pudo enviar el código. Intenta de nuevo.',
        );
      }
    } catch (_) {
      if (mounted) {
        Metodos.flushbarNegativo(
          context,
          'Error de conexión. Revisa tu internet e intenta de nuevo.',
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        backgroundColor: context.colors.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: context.colors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Cambiar contraseña',
          style: context.textStyles.titleLarge?.copyWith(
            color: context.colors.onSurface,
            fontWeight: AppTokens.fontWeightBold,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTokens.space24,
            vertical: AppTokens.space16,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Se enviará un código de verificación a tu correo. Luego podrás ingresar el código y tu nueva contraseña de forma segura.',
                  style: context.textStyles.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: AppTokens.space24),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: 'Correo electrónico',
                    hintText: 'correo@ejemplo.com',
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: context.colors.primary,
                    ),
                    filled: true,
                    fillColor: context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
                    border: OutlineInputBorder(
                      borderRadius: AppTokens.borderRadiusMedium,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: AppTokens.borderRadiusMedium,
                      borderSide: BorderSide(
                        color: context.colors.outline.withValues(alpha: 0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: AppTokens.borderRadiusMedium,
                      borderSide: BorderSide(
                        color: context.colors.primary,
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: AppTokens.borderRadiusMedium,
                      borderSide: BorderSide(color: context.colors.error),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Ingresa tu correo electrónico';
                    }
                    if (!Metodos.validateEmail(v.trim())) {
                      return 'Ingresa un correo válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppTokens.space32),
                SizedBox(
                  height: AppTokens.buttonHeightLarge,
                  child: ElevatedButton(
                    onPressed: _sending ? null : _enviarCodigo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.colors.primary,
                      foregroundColor: context.colors.onPrimary,
                      disabledBackgroundColor: context.colors.primary.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppTokens.borderRadiusCircular,
                      ),
                      elevation: 0,
                    ),
                    child: _sending
                        ? SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(context.colors.onPrimary),
                            ),
                          )
                        : Text(
                            'Enviar código',
                            style: context.textStyles.titleMedium?.copyWith(
                              color: context.colors.onPrimary,
                              fontWeight: AppTokens.fontWeightBold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
