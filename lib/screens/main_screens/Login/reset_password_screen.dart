// ignore_for_file: file_names

import 'package:be_energy/core/api/api_exceptions.dart';
import 'package:be_energy/core/extensions/context_extensions.dart';
import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/repositories/auth_repository.dart';
import 'package:be_energy/utils/metodos.dart';
import 'package:flutter/material.dart';

import 'login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String? email;

  const ResetPasswordScreen({super.key, this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final AuthRepository _authRepository = AuthRepository();
  bool _loading = false;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  bool get _emailPreFilled => widget.email != null && widget.email!.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    if (_emailPreFilled) _emailController.text = widget.email!.trim();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final resp = await _authRepository.resetPassword(
        otp: _otpController.text.trim(),
        newPassword: _newPasswordController.text,
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      );
      if (resp.success && mounted) {
        Metodos.flushbarPositivo(context, 'Contraseña actualizada. Ya puedes iniciar sesión.');
        await Future.delayed(const Duration(milliseconds: 1500));
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        }
      } else if (mounted) {
        final m = (resp.message ?? '').toLowerCase();
        String show = resp.message ?? 'Error al restablecer';
        if (m.contains('expirado') || m.contains('expired')) {
          show = 'El código ha expirado. Solicita uno nuevo.';
        } else if (m.contains('utilizado') || m.contains('used') || m.contains('inválido') || m.contains('otp')) {
          show = 'Código inválido o ya utilizado. Solicita uno nuevo.';
        }
        Metodos.flushbarNegativo(context, show);
      }
    } on ApiException catch (e) {
      if (mounted) {
        final m = e.message.toLowerCase();
        String show = e.message;
        if (m.contains('expirado') || m.contains('expired')) {
          show = 'El código ha expirado. Solicita uno nuevo.';
        } else if (m.contains('utilizado') || m.contains('used') || m.contains('inválido') || m.contains('otp')) {
          show = 'Código inválido o ya utilizado. Solicita uno nuevo.';
        }
        Metodos.flushbarNegativo(context, show);
      }
    } catch (_) {
      if (mounted) {
        Metodos.flushbarNegativo(context, 'Error al restablecer. Verifica tu conexión e intenta de nuevo.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(prefixIcon, color: context.colors.primary),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
      border: OutlineInputBorder(borderRadius: AppTokens.borderRadiusMedium),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppTokens.borderRadiusMedium,
        borderSide: BorderSide(color: context.colors.outline.withValues(alpha: 0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppTokens.borderRadiusMedium,
        borderSide: BorderSide(color: context.colors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppTokens.borderRadiusMedium,
        borderSide: BorderSide(color: context.colors.error),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        title: Text(
          'Nueva contraseña',
          style: context.textStyles.titleLarge?.copyWith(
            color: context.colors.onSurface,
            fontWeight: AppTokens.fontWeightBold,
          ),
        ),
        backgroundColor: context.colors.surface,
        foregroundColor: context.colors.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTokens.space24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Ingresa el código que recibiste por correo y define tu nueva contraseña.',
                  style: context.textStyles.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: AppTokens.space24),
                TextFormField(
                  controller: _emailController,
                  readOnly: _emailPreFilled,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDecoration(
                    label: 'Correo',
                    hint: 'correo@ejemplo.com',
                    prefixIcon: Icons.email_outlined,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Ingresa tu correo';
                    if (!Metodos.validateEmail(v.trim())) return 'Correo no válido';
                    return null;
                  },
                ),
                const SizedBox(height: AppTokens.space16),
                TextFormField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 8,
                  decoration: _inputDecoration(
                    label: 'Código OTP',
                    hint: 'Ej: 123456',
                    prefixIcon: Icons.pin_outlined,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().length < 4) {
                      return 'Ingresa el código de 4 a 8 dígitos';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppTokens.space16),
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: _obscureNewPassword,
                  decoration: _inputDecoration(
                    label: 'Nueva contraseña',
                    hint: 'Mínimo 6 caracteres',
                    prefixIcon: Icons.lock_outline,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureNewPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: context.colors.onSurfaceVariant,
                      ),
                      onPressed: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.length < 6) return 'Mínimo 6 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: AppTokens.space16),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: _inputDecoration(
                    label: 'Repetir contraseña',
                    hint: 'Vuelve a escribir la contraseña',
                    prefixIcon: Icons.lock_outline,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: context.colors.onSurfaceVariant,
                      ),
                      onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v != _newPasswordController.text) {
                      return 'Las contraseñas no coinciden';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppTokens.space32),
                SizedBox(
                  height: AppTokens.buttonHeightLarge,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.colors.primary,
                      foregroundColor: context.colors.onPrimary,
                      disabledBackgroundColor: context.colors.primary.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppTokens.borderRadiusCircular,
                      ),
                      elevation: 0,
                    ),
                    child: _loading
                        ? SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(context.colors.onPrimary),
                            ),
                          )
                        : Text(
                            'Restablecer contraseña',
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
