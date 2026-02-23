// ignore_for_file: file_names
import 'package:be_energy/core/api/api_exceptions.dart';
import 'package:be_energy/core/extensions/context_extensions.dart';
import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/data/database_Helper.dart';
import 'package:be_energy/models/my_user.dart';
import 'package:be_energy/repositories/auth_repository.dart';
import 'package:be_energy/repositories/user_repository.dart';
import 'package:be_energy/utils/metodos.dart';
import 'package:flutter/material.dart';

import '../../../views/navigation.dart';
import 'login_screen.dart';

class Verify2FAScreen extends StatefulWidget {
  final String tempSession;
  final String email;
  final int userId;

  const Verify2FAScreen({
    super.key,
    required this.tempSession,
    required this.email,
    required this.userId,
  });

  @override
  State<Verify2FAScreen> createState() => _Verify2FAScreenState();
}

class _Verify2FAScreenState extends State<Verify2FAScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _otpController = TextEditingController();
  final AuthRepository _authRepository = AuthRepository();
  final UserRepository _userRepository = UserRepository();
  bool _loading = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final resp = await _authRepository.verify2fa(
        tempSession: widget.tempSession,
        otp: _otpController.text.trim(),
      );
      if (resp.success && resp.data != null && mounted) {
        final data = resp.data!;
        final userId = data['user_id'] as int? ?? widget.userId;
        final email = data['email'] as String? ?? widget.email;

        MyUser usuariolocal = MyUser(
          idUser: userId,
          nombre: '',
          telefono: '',
          correo: email,
          clave: '',
          energia: '0',
          dinero: '0',
          idCiudad: 0,
        );

        try {
          final userResp = await _userRepository.getUser(userId);
                if (userResp.success && userResp.data != null) {
                  final u = userResp.data!;
                  final roleVal = u['role'];
                  final roleInt = roleVal is int ? roleVal : (roleVal != null ? int.tryParse(roleVal.toString()) : null);
                  usuariolocal = MyUser(
                    idUser: u['id'] ?? userId,
                    nombre: u['name'] ?? u['nombre'] ?? '',
                    telefono: u['phone'] ?? u['telefono'] ?? '',
                    correo: u['email'] ?? u['correo'] ?? email,
                    clave: '',
                    energia: '0',
                    dinero: '0',
                    idCiudad: u['idCiudad'] ?? 0,
                    role: roleInt,
                  );
                }
        } catch (_) {}

        final dbHelper = DatabaseHelper();
        dbHelper.addUser(usuariolocal);

        Metodos.flushbarPositivo(context, 'Ingresando a App');
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => NavPages(myUser: usuariolocal),
                ),
                (Route<dynamic> route) => false,
              );
            }
          });
        }
      } else if (mounted) {
        final m = (resp.message ?? '').toLowerCase();
        String show = resp.message ?? 'Código inválido';
        if (m.contains('expirad') || m.contains('expired')) {
          show = 'La sesión expiró. Inicia sesión de nuevo.';
        } else if (m.contains('inválido') || m.contains('invalid') || m.contains('intentos')) {
          show = 'Código OTP inválido o demasiados intentos. Inicia sesión de nuevo.';
        }
        Metodos.flushbarNegativo(context, show);
      }
    } on ApiException catch (e) {
      if (mounted) {
        final m = e.message.toLowerCase();
        String show = e.message;
        if (m.contains('expirad') || m.contains('expired')) {
          show = 'La sesión expiró. Inicia sesión de nuevo.';
        } else if (m.contains('inválido') || m.contains('invalid') || m.contains('intentos')) {
          show = 'Código OTP inválido o demasiados intentos. Inicia sesión de nuevo.';
        }
        Metodos.flushbarNegativo(context, show);
      }
    } catch (_) {
      if (mounted) {
        Metodos.flushbarNegativo(context, 'Error de conexión. Intenta de nuevo.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(prefixIcon, color: context.colors.primary),
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
          'Verificación en dos pasos',
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
                  'Te enviamos un código de 6 dígitos al correo ${widget.email}. Ingrésalo a continuación.',
                  style: context.textStyles.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: AppTokens.space24),
                TextFormField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: context.textStyles.headlineMedium?.copyWith(
                    letterSpacing: 8,
                    fontWeight: AppTokens.fontWeightBold,
                  ),
                  decoration: _inputDecoration(
                    label: 'Código OTP',
                    hint: '123456',
                    prefixIcon: Icons.pin_outlined,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().length < 6) {
                      return 'Ingresa el código de 6 dígitos';
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
                            'Verificar',
                            style: context.textStyles.titleMedium?.copyWith(
                              color: context.colors.onPrimary,
                              fontWeight: AppTokens.fontWeightBold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: AppTokens.space16),
                TextButton(
                  onPressed: _loading
                      ? null
                      : () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                            (route) => false,
                          );
                        },
                  child: Text(
                    'Cancelar e iniciar sesión de nuevo',
                    style: context.textStyles.bodyMedium?.copyWith(
                      color: context.colors.primary,
                      fontWeight: AppTokens.fontWeightMedium,
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
